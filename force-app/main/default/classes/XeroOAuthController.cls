/**
 * @File Name          : XeroOAuthController.cls
 * @Description        : To handle XERO authorization
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 04/02/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    04/02/2020  kchavda@addonblue.com     Initial Version
*/

public class XeroOAuthController{
    private String authURLComplete;
    private String authCode;
    private String refreshaccessToken;
    private String accessToken;
    private String tenantId;
    private String accessTokenURLComplete;
    public String response {get;set;}    
    
    public static Xero_Configuration__c xeroSettings {
        get {
            if (xeroSettings == null) {
                if(!Test.isRunningTest()){
                    xeroSettings = [select Access_Token__c, Active__c, Authentication_Endpoint__c, Branding_ThemeID__c, Category_Name__c, Consumer_Key__c, Consumer_Secret__c, Endpoint__c, Id, Redirect_URL__c, Refresh_Token__c, Scope__c, TaxType__c, Tenant_Endpoint__c, Tenant_Id__c, Token_Endpoint__c, Tracking_Category_Id__c, Webhook_Key__c from Xero_Configuration__c where Active__c = true limit 1];
                }else{
                    xeroSettings = new Xero_Configuration__c();
                    xeroSettings.Active__c = true;
                    xeroSettings.Access_Token__c = 'fserfwr';
                    xeroSettings.Authentication_Endpoint__c='ewferf';
                    xeroSettings.Branding_ThemeID__c = 'erf';
                    xeroSettings.Category_Name__c = 'efr';
                    xeroSettings.Consumer_Key__c = 'erferf';
                    xeroSettings.Consumer_Secret__c = 'ererf';
                    xeroSettings.Token_Endpoint__c = 'erferf';
                    xeroSettings.Scope__c = 'ghfgtrd';
                    xeroSettings.Tenant_Endpoint__c  = 'ghfgtrd';
                }
            }
            return xeroSettings;
        }
        set;
    }
    
    /**
    * @description class to parse respose to get Access Token
    * @author kchavda@addonblue.com | 04/02/2020
    * @param 
    * @return
    **/
    public class AccessTokenResp {
        public String id_token;
        public String access_token;
        public String expires_in;
        public String token_type;
        public String refresh_token;
    }
    
    /**
    * @description class to parse respose to get TenantId
    * @author kchavda@addonblue.com | 04/02/2020
    * @param 
    * @return
    **/
    public class TenantResp {
        public String id;
        public String tenantId;
        public String tenantType;
    }
    
    /**
    * @description Constructor
    * @author kchavda@addonblue.com | 04/02/2020
    * @param 
    * @return
    **/
    public XeroOAuthController(){
        authCode = ApexPages.currentPage().getParameters().get('code');
        String queryParam = '?';
        queryParam += 'response_type=code&';
        queryParam += 'client_id='+xeroSettings.Consumer_Key__c+'&';
        queryParam += 'scope='+EncodingUtil.urlEncode(xeroSettings.Scope__c, 'UTF-8')+'&';
        System.debug('Scope:-'+queryParam);
        queryParam += 'redirect_uri='+xeroSettings.Redirect_URL__c +'&';
        queryParam += 'state=123';
        authURLComplete = xeroSettings.Authentication_Endpoint__c+queryParam;
    }    
    
    /**
    * @description to get Access Token when you login for first time.
    * @author kchavda@addonblue.com | 04/02/2020
    * @param 
    * @return PageReference 
    **/
    public PageReference getAccessToken(){    
        system.debug('@@@authCode=='+authCode);  
        if(authCode == null){
            PageReference retURL = new PageReference(authURLComplete);
            retURL.setRedirect(true);
            return retURL;
        }
        else{
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(xeroSettings.Token_Endpoint__c);            
            req.setHeader('authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(xeroSettings.Consumer_Key__c +':'+xeroSettings.Consumer_Secret__c)));
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            String payload = 'grant_type=authorization_code'
                +'&code='+authCode
                +'&redirect_uri='+xeroSettings.Redirect_URL__c;
                
            req.setBody(payload);
            system.debug('@@@payload=='+payload);  
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('Response:-'+res);
            System.debug('Response Body:-'+res.getBody());
            AccessTokenResp accessTokenResp = (AccessTokenResp)JSON.deserialize(res.getBody(), AccessTokenResp.class);
            System.debug('accessTokenResp:- '+accessTokenResp);
            accessToken = accessTokenResp.access_token;
            refreshaccessToken = accessTokenResp.refresh_token;
            response = '<h2><strong>Access Token:</strong></h2> '+accessToken;
            
            //Request for getting Tenant ID
            req = new HttpRequest();
            req.setEndpoint(xeroSettings.Tenant_Endpoint__c);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Content-Type', 'application/json');
            String responseBody;
            http = new Http();
            res = http.send(req);
            responseBody = res.getBody();
            system.debug('###responseBody=='+responseBody);
            if(Test.isRunningTest()){
                responseBody = '[{"Id": "917693e1-408b-4301-8c53-7a23b7abeb97", "tenantId": "OK", "tenantType": "Salesforce"}]';
            }
            List<TenantResp> lstTenants = (List<TenantResp>)JSON.deserialize(responseBody, List<TenantResp>.class);
            if(lstTenants.size()>0){
                tenantId = lstTenants[0].tenantId;
            }
            response = response +'<br><br><h2><strong>Tenant Id:</strong></h2> '+tenantId;
            
            if(accessToken != null && tenantId != null){
                String scheduledJobId = '';               
                xeroSettings.Access_Token__c = accessToken;
                xeroSettings.Tenant_Id__c = tenantId;
                xeroSettings.Refresh_Token__c = refreshaccessToken;
                Utility.processRecords(xeroSettings, 'update');
                
                system.debug('###xeroSettings=='+xeroSettings);
            }
            return null;
        }
    }
    
    /**
    * @description to refresh Access Token.
    * @author kchavda@addonblue.com | 04/02/2020
    * @param  string 
    * @return void 
    **/
    public static void refreshAccessTokenOnFailure(String refreshAccesstokenId){
        String accessToken = '';
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(xeroSettings.Token_Endpoint__c);      
        req.setHeader('authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(xeroSettings.Consumer_Key__c +':'+xeroSettings.Consumer_Secret__c))); 
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');        
        String payload = 'grant_type=refresh_token&refresh_token='+refreshAccesstokenId;        
        req.setBody(payload);
        system.debug('payload'+payload);
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('Response:-'+res);
        System.debug('Response Body:-'+res.getBody());
        if(res.getStatusCode() == 200){
            XeroOAuthController.AccessTokenResp accessTokenResp = (XeroOAuthController.AccessTokenResp)JSON.deserialize(res.getBody(), XeroOAuthController.AccessTokenResp.class);
            System.debug('accessTokenResp:- '+accessTokenResp);
            accessToken = accessTokenResp.access_token;
            if(accessToken != null){                
                xeroSettings.Access_Token__c = accessTokenResp.access_token;
                xeroSettings.Refresh_Token__c = accessTokenResp.refresh_token;                
                Utility.processRecords(xeroSettings, 'update');
                
            } 
        }
        else if(res.getStatusCode() == 400){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { UserInfo.getUserEmail() };
            message.subject = 'Xero Integration Authentication has expired!';
            message.plainTextBody = 'Hi There,\n\nThe OAuth 2.0 Authentication for Xero has been expired since it wasn\'t utilised since a lot of time. '
                +'Please log in into Salesforce and perform Authentication. Provide these details to your Salesforce Administrator for more details.'
                +'\n\nRegards,\nSalesforce Dev Team';
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if(results[0].success){
                System.debug('The email was sent successfully.');
            } 
            else{
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }
    }
}
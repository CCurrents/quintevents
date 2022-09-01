/**
 * @File Name          : XeroCalloutUtility.cls
 * @Description        : To execute callout and return
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 04/02/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    04/02/2020  kchavda@addonblue.com     Initial Version
**/

public class XeroCalloutUtility {

     /**
    * @description Execute callout and return
    * @author kchavda@addonblue.com | 04/02/2020
    * @param String  
    * @return HttpRequest 
    **/
    public static HttpRequest executeCallout (String method, String resourceName, String requestBody) {  
       
        // Instantiate a new request
        HttpRequest request = new HttpRequest();
        Xero_Configuration__c xeroSettings;
        if(Test.isRunningTest()){
            xeroSettings = new Xero_Configuration__c();
            xeroSettings.Active__c = true;
            xeroSettings.Access_Token__c = 'fserfwr';
            xeroSettings.Authentication_Endpoint__c='ewferf';
            xeroSettings.Branding_ThemeID__c = 'erf';
            xeroSettings.Category_Name__c = 'efr';
            xeroSettings.Consumer_Key__c = 'erferf';
            xeroSettings.Consumer_Secret__c = 'ererf';
            xeroSettings.Endpoint__c = 'erferf';
            xeroSettings.Tenant_Id__c = 'ghfgtrd';
        }else{
            xeroSettings = [select Access_Token__c, Active__c, Authentication_Endpoint__c, Branding_ThemeID__c, Category_Name__c, Consumer_Key__c, Consumer_Secret__c, Endpoint__c, Id, Redirect_URL__c, Refresh_Token__c, Scope__c, TaxType__c, Tenant_Endpoint__c, Tenant_Id__c, Token_Endpoint__c, Tracking_Category_Id__c, Webhook_Key__c from Xero_Configuration__c where Active__c = true limit 1];
        }
        if(xeroSettings != null){
            request.setMethod(method);
            // Set end point
            System.debug('endpoint--'+xeroSettings.Endpoint__c + resourceName);
            System.debug('header-'+xeroSettings.Tenant_Id__c);
            request.setEndpoint(xeroSettings.Endpoint__c + resourceName);
            // Accept a JSON response from the call
            request.setHeader('Accept', 'application/json');
            request.setHeader('Authorization', 'Bearer '+ xeroSettings.Access_Token__c);
            request.setHeader('Xero-tenant-id', xeroSettings.Tenant_Id__c);
            // If the callout includes a body (POST and PUT requests)
            if (String.isNotBlank(requestBody)) {
                // Set the body to the callout
                request.setBody(requestBody);
                // Set the content to XML
                request.setHeader('Content-Type', 'text/json');
                request.setTimeout(10000);
            }            
        }
        // Execute callout and return
        return request;
    }  
    
     /**
    * @description Execute callout and return
    * @author kchavda@addonblue.com | 04/02/2020
    * @params String, Xero_Configuration__c 
    * @return HttpRequest 
    **/  
    public static HttpRequest executeCallout (String method, String resourceName, String requestBody, Xero_Configuration__c xeroSettings) {
        // Instantiate a new request
        HttpRequest request = new HttpRequest();
        if(xeroSettings != null){
            request.setMethod(method);
            request.setEndpoint(xeroSettings.Endpoint__c + resourceName);
            request.setHeader('Accept', 'application/json');
            request.setHeader('Authorization', 'Bearer '+ xeroSettings.Access_Token__c);
            request.setHeader('Xero-tenant-id', xeroSettings.Tenant_Id__c);
            request.setHeader('grant_type',xeroSettings.Scope__c);
            if (String.isNotBlank(requestBody)) {
                request.setBody(requestBody);
                request.setHeader('Content-Type', 'text/json');
            }
        }
        return request;
    }

}
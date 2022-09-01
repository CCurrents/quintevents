/**
 * @File Name          : GenerateSlackToken.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 11-19-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/11/2020   jagrawal@addonblue.com     Initial Version
**/
public class GenerateSlackToken {
    
    
    @AuraEnabled
    public static String generateToken(){        
        Slack_API_Detail__c slackapiobj = Slack_API_Detail__c.getOrgDefaults();
        String redirectURL = System.URL.getSalesforceBaseURL().toExternalForm()+'/apex/GenerateSlackToken';
        String url = 'https://slack.com/oauth/authorize?client_id='+slackapiobj.Slack_Client_Id__c
            			+'&scope='+slackapiobj.Slack_Scope__c
            			+'&redirect_uri='+redirectURL;
        System.debug('@@Generate Slack Token URL:-'+url);
    	return url;
    }
    
    @AuraEnabled  
    public static string getaccesstoken(String code){
        String accessToken;
        Slack_API_Detail__c slackapiobj = Slack_API_Detail__c.getOrgDefaults();
        System.debug('@@Slack Auth Code:-'+code);
        if(code != null){
                String endPoint = 'https://slack.com/api/oauth.access?';
                
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                String redirectURL = System.URL.getSalesforceBaseURL().toExternalForm()+'/apex/GenerateSlackToken';
                req.setEndpoint(endpoint+'client_id='+slackapiobj.Slack_Client_Id__c+'&client_secret='+slackapiobj.Slack_Client_Secret__c+'&code='+code+'&redirect_uri='+redirectURL);
               
            	req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                System.debug('httpReq-->'+req);
                if(!Test.isRunningTest()) {
                	res = http.send(req); 
                }
                System.debug('HttpRes-->'+res.getBody());
            	String jsonReposne = !Test.isRunningTest() ? res.getBody() : '{"ok":true,"access_token":"xoxp-457674332738-902972345305-1162227911493-460531d9d15978a1f343e832e3d215ad","scope":"identify,team:read,channels:write,chat:write:bot","user_id":"USJUL608Z","team_id":"TDFKYF2MQ","enterprise_id":null,"team_name":"AddonBlue"}';
            
                System.JSONParser parser = System.JSON.createParser(jsonReposne);
                while(parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME){
                    	String text = parser.getText();
                        if(parser.nextToken() != System.JSONToken.VALUE_NULL) {
                            if(text == 'access_token'){
                                accessToken = parser.getText();
                            }
                        }
                    }
                }
                System.debug('accessToken-->'+accessToken);
        }
        
        slackapiobj.Slack_API_Token__c = accessToken;
        System.debug('@@slackapiobj:- '+slackapiobj);
        if(!Test.isRunningTest()){
            update slackapiobj;
            System.debug('@@Updated slackapiobj:- '+slackapiobj);
        }
        return accessToken;
    }
}
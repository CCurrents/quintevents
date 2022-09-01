/**
* @File Name          : OutReachAuthTokenBatch.cls
* @Description        : Batch class to make a callout to get the access token on hourly basis.
* @Author             : Ravindra Kumar
* @Group              : QE360V3
* @Last Modified By   : ravindra.isakapatla@addonblue.com
* @Last Modified On   : 25-07-2022
* @Modification Log   : 
* Ver       Date            Author                  Modification
* 1.0       7/25/2022       Ravindra Kumar          Initial Version
*/
public class OutReachAuthTokenBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {
    //
    // Start method will always Query integration token records   
    public Database.QueryLocator start(Database.BatchableContext BC){
        string oauthQuery = 'Select id,name,client_id__c,Client_secret__c,refresh_token__c,Grant_Type__c,Redirect_Uri__c,endpoint__c,access_token__c from IntegrationTokens__c where name=\'Outreach\' ';
        return Database.getQueryLocator(oauthQuery);
    } 
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        IntegrationTokens__c objOutreach = (IntegrationTokens__c) Scope[0];
        System.debug('@objOutreach...'+objOutreach);
        try{
            string endpointUrl =  objOutreach.endpoint__c+'client_id='+objOutreach.client_id__c+'&client_secret='+objOutreach.Client_Secret__c+'&grant_type='+objOutReach.Grant_Type__c+'&redirect_uri='+objOutreach.Redirect_Uri__c+'&refresh_token='+objOutreach.Refresh_Token__c;
            Http http = new Http();
            HttpRequest r = new HttpRequest(); 
            r.setendpoint(endpointUrl);
            r.setMethod('POST');        
            HttpResponse res = http.send(r);
            System.debug(res.getbody());
            Map<String,Object> resMap = new Map<String,Object>();
        if(res.getStatusCode()==200){
            resMap =(MAP<String,Object>) JSON.deserializeUntyped(res.getbody()) ;
            objOutreach.Refresh_Token__c = (string) resmap.get('refresh_token');
            objOutreach.Access_Token__c =(string) resmap.get('access_token');
            update objOutreach;
             Requestresponse_log__c resp = new Requestresponse_log__c();
            resp.Request__c = endpointUrl;
            resp.Response__c = Json.serialize(resMap);
            resp.Method_Name__c ='outreach';
            insert resp;
         } 
          
        }
        catch(exception e){
            system.debug('exception---'+e.getMessage());
        }
    }
    
    public void finish(Database.BatchableContext BC){}
}
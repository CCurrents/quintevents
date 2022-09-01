/**
 * @File Name          : RenameSlackPriceBookChannel.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 4/27/2020, 3:46:40 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/23/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class RenameSlackPriceBookChannel implements Queueable,Database.AllowsCallouts {
    public List<Id> lstPriceBookIds = new List<Id>();

    public RenameSlackPriceBookChannel(List<Id> lstPriceBookIds){
        this.lstPriceBookIds = lstPriceBookIds;
    }
    
    public void execute(QueueableContext context) {
        system.debug('lstPriceBookIds-->'+lstPriceBookIds);
        List<Pricebook2> pricebookDetails = new List<Pricebook2>([Select Id,Name,Slack_Channel_Id__c,Slack_Channel_Name__c from Pricebook2 where Id In :lstPriceBookIds and Slack_Channel_Name__c != null]);
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        for(Pricebook2 qePricebook : pricebookDetails) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://slack.com/api/conversations.rename?token='+ slackAPI.Slack_API_Token__c + '&channel=' + qePricebook.Slack_Channel_Id__c + '&name=' +
                            (qePricebook.Slack_Channel_Name__c.replace(' ', '-').left(21).tolowercase()));
            System.debug(req.getEndpoint());
            req.setMethod('POST');
            req.setHeader('Content-type','application/json');
            Http http = new Http();
            HttpResponse res;
            if(!Test.isRunningTest()) {
                res = http.send(req);
            }
            System.debug('response plain: ' + res);
            Map<String, Object> renameResponse = (Map<String, Object>) 
                                                    JSON.deserializeUntyped(!Test.isRunningTest() ? res.getBody() : '{ "ok": true, "channel": { "id": "CFATL949H", "name": "test44444", "is_channel": true, "created": 1547146800, "is_archived": false, "is_general": false, "unlinked": 0, "creator": "UDFF8NGDS", "name_normalized": "test44444", "is_member": true, "members": [ "UDFF8NGDS" ]}}');
            System.debug('response: ' + renameResponse);
        }
    }
}
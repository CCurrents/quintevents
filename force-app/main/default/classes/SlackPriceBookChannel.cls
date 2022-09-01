/**
 * @File Name          : SlackPriceBookChannel.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 03-22-2021
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/23/2020   jagrawal@addonblue.com     Initial Version
 * 1.1    3/25/2021   kchavda@addonblue.com      #879 Slack channel not being created through code
**/
public with sharing class SlackPriceBookChannel implements Queueable, Database.AllowsCallouts {
    public List<Id> pricebookIds = new List<Id>();

    public SlackPriceBookChannel(List<Id> pricebookIds){
        this.pricebookIds = pricebookIds;
    }
    
    public void execute(QueueableContext context) {
        List<PriceBook2> priceDetails = new List<Pricebook2>([Select Id, Name, IsActive, Post_to_Slack_Channel__c, Slack_Channel_Name__c, Slack_Channel_Id__c FROM Pricebook2 where Id In :pricebookIds and Slack_Channel_Id__c = null]);
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        
        List<User> lstSlackChannelUsers = new List<User>([Select Id,Slack_User_Id__c from User
                                                            where IsActive = true and Slack_User_Id__c != null and
                                                                (Profile.Name In ('QE360 - Sales Admin', 'QE360 - Sales', 'Sales Team Lead', 'QE360 - Operations', 'QE360 - GPE Sales Team', 'QE360 - Exclusive GP Sales Team') OR Id In : Label.Slack_Additional_Member_Ids.split(','))]);
        for(PriceBook2 qePrice : priceDetails) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://slack.com/api/conversations.create?token='+ slackAPI.Slack_API_Token__c + '&name=' +
                            (qePrice.Slack_Channel_Name__c.replace(' ', '-').left(21).toLowerCase()));
            System.debug(req.getEndpoint());
            req.setMethod('POST');
            req.setHeader('Content-type','application/json');
            Http http = new Http();
            HttpResponse res;
            if(!Test.isRunningTest()) {
                res = http.send(req);
            }
            System.debug('response plain: ' + res);
            Map<String, Object> createResponse = (Map<String, Object>) 
                                                    JSON.deserializeUntyped(Test.isRunningTest() ? '{ "ok": true, "channel": { "id": "CFATL949H", "name": "test44444", "is_channel": true, "created": 1547146800, "is_archived": false, "is_general": false, "unlinked": 0, "creator": "UDFF8NGDS", "name_normalized": "test44444", "is_member": true, "members": [ "UDFF8NGDS" ]}}' :
                                                        res.getBody());
            System.debug('response: ' + createResponse);
            Map<String, Object> channelDetails = (Map<String, Object>) createResponse.get('channel');
            String channelID = (String) channelDetails.get('id');
            System.debug('Channel Id: ' + channelID);
            qePrice.Slack_Channel_Id__c = channelID;
            
            // 06/07/2019 commented
            // 06/28/2019 uncommented
            if(String.isNotBlank(channelID)) {
                addMembersInChannel(lstSlackChannelUsers, channelID, slackAPI.Slack_API_Token__c);
            }
            postMessageInChannel(qePrice);
        }
        Utility.processRecords(priceDetails, 'update');
    }

    public static Boolean addMembersInChannel(List<User> lstMembers, String channelId, String slackAPIToken) {
        for(User memb : lstMembers) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://slack.com/api/conversations.invite?token='+ slackAPIToken + '&channel=' +
                            channelId + '&users=' + memb.Slack_User_Id__c);
            System.debug(req.getEndpoint());
            req.setMethod('POST');
            req.setHeader('Content-type','application/json');
            Http http = new Http();
            HttpResponse res;
            if(!Test.isRunningTest()) {
                res = http.send(req);
                System.debug('response plain: ' + res);
                System.debug('@@Add Member response Body: ' + res.getBody());
            }
        }
        return true;
    }

    public static void postMessageInChannel(Pricebook2 qePrice) {
        system.debug('qePrice'+qePrice);
        if(qePrice.Post_to_Slack_Channel__c) {
            Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
            HttpRequest req = new HttpRequest();
            String message = EncodingUtil.urlEncode('Event: ' + qePrice.Name + '\n' + 'Status: ' + (qePrice.IsActive ? 'Active' : 'Inactive'), 'UTF-8');
            req.setEndpoint('https://slack.com/api/chat.postMessage?token='+ slackAPI.Slack_API_Token__c + '&pretty=1&text=' +
                            message + '&channel=' + qePrice.Slack_Channel_Id__c);
            System.debug(req.getEndpoint());
            req.setMethod('POST');
            req.setHeader('Content-type','application/json');
            Http http = new Http();
            if(!Test.isRunningTest()){
                HttpResponse res = http.send(req);
                System.debug('response plain: ' + res);
                System.debug('response plain body:' + res.getBody());
            }
        }
    }
}
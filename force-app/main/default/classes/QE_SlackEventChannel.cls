public class QE_SlackEventChannel {

    @InvocableMethod(label='SlackEventChannel Create' description='Inserts Slack channel for event')
    public static void createChannel(List<Id> eventIds) {
        createChannelInSlack(eventIds);
    }

    @Future(callout=true)
    Public static void createChannelInSlack(List<Id> lstEventIds) {
        List<QE360_Event__c> eventDetails = new List<QE360_Event__c>([Select Id, Name, Active__c, Post_to_Slack_Channel__c, Slack_Channel_Name__c FROM QE360_Event__c where Id In :lstEventIds and Slack_Channel_Id__c = null]);
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        
        // 06/07/2019 commented
        // 06/28/2019 uncommented
        List<User> lstSlackChannelUsers = new List<User>([Select Id,Slack_User_Id__c from User
                                                            where IsActive = true and Slack_User_Id__c != null and
                                                                (Profile.Name In ('QE360 - Sales Admin', 'QE360 - Sales', 'QE360 - Operations', 'QE360 - GPE Sales Team', 'QE360 - Exclusive GP Sales Team') OR Id In : Label.Slack_Additional_Member_Ids.split(','))]);
        for(QE360_Event__c qeEvent : eventDetails) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://slack.com/api/channels.create?token='+ slackAPI.Slack_API_Token__c + '&name=' +
                            (qeEvent.Slack_Channel_Name__c.replace(' ', '+').left(21)));
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
            qeEvent.Slack_Channel_Id__c = channelID;
            
            // 06/07/2019 commented
            // 06/28/2019 uncommented
            if(String.isNotBlank(channelID)) {
                addMembersInChannel(lstSlackChannelUsers, channelID, slackAPI.Slack_API_Token__c);
            }
            QE_SlackEventChannelPost.postMessageInChannel(qeEvent);
        }
        update eventDetails;
    }

    Public static void addMembersInChannel(List<User> lstMembers, String channelId, String slackAPIToken) {
        for(User memb : lstMembers) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://slack.com/api/channels.invite?token='+ slackAPIToken + '&channel=' +
                            channelId + '&user=' + memb.Slack_User_Id__c);
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
    }
}
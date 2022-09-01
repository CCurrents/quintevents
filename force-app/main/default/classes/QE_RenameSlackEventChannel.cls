public class QE_RenameSlackEventChannel {

    @InvocableMethod(label='Slack Channel Rename' description='Rename Slack channel for event')
    public static void renameChannel(List<Id> eventIds) {
        renameChannelInSlack(eventIds);
    }

    @Future(callout=true)
    Public static void renameChannelInSlack(List<Id> lstEventIds) {
        List<QE360_Event__c> eventDetails = new List<QE360_Event__c>([Select Id,Name,Slack_Channel_Id__c,Slack_Channel_Name__c from QE360_Event__c where Id In :lstEventIds and Slack_Channel_Name__c != null]);
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        for(QE360_Event__c qeEvent : eventDetails) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://slack.com/api/conversations.rename?token='+ slackAPI.Slack_API_Token__c + '&channel=' + qeEvent.Slack_Channel_Id__c + '&name=' +
                            (qeEvent.Slack_Channel_Name__c.replace(' ', '-').left(21).tolowercase()));
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
                                                    JSON.deserializeUntyped(Test.isRunningTest() ? '{ "ok": true, "channel": { "id": "CFATL949H", "name": "test44444", "is_channel": true, "created": 1547146800, "is_archived": false, "is_general": false, "unlinked": 0, "creator": "UDFF8NGDS", "name_normalized": "test44444", "is_member": true, "members": [ "UDFF8NGDS" ]}}' :
                                                        res.getBody());
            System.debug('response: ' + renameResponse);
        }
    }
}
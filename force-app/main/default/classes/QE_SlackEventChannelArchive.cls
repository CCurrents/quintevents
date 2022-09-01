public class QE_SlackEventChannelArchive {

    @Future(callout=true)
    public static void archiveChannel(List<Id> eventIds) {
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        
        for(QE360_Event__c qeEvent : [Select Id,Slack_Channel_Id__c from QE360_Event__c where Id In : eventIds]) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://slack.com/api/channels.archive?token='+ slackAPI.Slack_API_Token__c + '&channel=' + qeEvent.Slack_Channel_Id__c);
            System.debug(req.getEndpoint());
            req.setMethod('POST');
            req.setHeader('Content-type','application/json');
            Http http = new Http();
            if(!Test.isRunningTest()){
                HttpResponse res = http.send(req);
                System.debug('response plain: ' + res);
                System.debug('response Bofdy: ' + res.getBody());
            }
        }
    }

    @InvocableMethod(label='EventChannel Archive' description='Archive Event Channel.')
    Public static void archiveChannelforEvent(List<Id> eventIds) {
        archiveChannel(eventIds);
    }
}
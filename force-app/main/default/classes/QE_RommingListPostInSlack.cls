public class QE_RommingListPostInSlack {
    
    @InvocableMethod(label='Rooming List Message in slack' description='Send message to user')
    public static void postRoomingListMessage(List<Id> opportunityIds) {
        postMessageToRooming(opportunityIds);
    }
    
    @Future(callout=true)
    public static void postMessageToRooming(List<Id> oppIds) {
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        List<User> slackUsers = new List<User>([Select Id, Slack_User_Id__c from User 
                                                where Slack_User_Id__c != null AND
                                                Id In (Select UserOrGroupId from GroupMember where Group.Name = :Label.Rooming_List_User_Group)]);
        for(Opportunity opp : [Select Id, Name,Rooming_List__c from Opportunity where Id In :oppIds]) {
            for(User sUser : slackUsers) {
                HttpRequest req = new HttpRequest();
                String message = EncodingUtil.urlEncode('Rooming List Comment has been ' + (String.isBlank(opp.Rooming_List__c) ? 'removed' : ('added:\n' + opp.Rooming_List__c)) +
                                                        '\n' + opp.Name + ': ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id
                                                        , 'UTF-8');
                req.setEndpoint('https://slack.com/api/chat.postMessage?token=' + slackAPI.Slack_API_Token__c + '&pretty=1&text=' +
                                message + '&channel=' + sUser.Slack_User_Id__c);
                System.debug(req.getEndpoint());
                req.setMethod('POST');
                req.setHeader('Content-type','application/json');
                if(!Test.isRunningTest()){
                    HttpResponse res = new Http().send(req);
                    System.debug('response plain: ' + res);
                }
            }
        }
    }
}
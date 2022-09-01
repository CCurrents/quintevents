public class QE_opprotunityApprovalExpectedMessage {
    @InvocableMethod(label='Approval is expected to confirm Message in slack' description='Send message to user')
    public static void postSlackUserMessage(List<Id> opportunityIds) {
        postMessageToslackUser(opportunityIds);
    }
    
    @Future(callout=true)
    public static void postMessageToslackUser(List<Id> oppIds) {
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        List<User> slackUsers = new List<User>([Select Id, Slack_User_Id__c from User 
                                    where Slack_User_Id__c != null AND
                                      Id In (Select OwnerId from Opportunity where Id In :oppIds)]);
        for(Opportunity opp : [Select Id, Name,Approval_Expected__c from Opportunity where Id In :oppIds]) {
            for(User sUser : slackUsers) {
                HttpRequest req = new HttpRequest();
                String message = EncodingUtil.urlEncode( 'Opportunity Name: ' + opp.Name +  '\n'  + 'Opportunity link: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id  + '\n' + 'Approval is expected to confirm in ' + opp.Approval_Expected__c, 'UTF-8');
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
/**
 * @File Name          : QuoteApprovalExpectedMessageQueuable.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/10/2020, 9:08:26 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/28/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class QuoteApprovalExpectedMessageQueuable implements Queueable,Database.AllowsCallouts {
    public List<Id> quoteIds = new List<Id>();
    
    public QuoteApprovalExpectedMessageQueuable(List<Id> quoteIds){
        this.quoteIds = quoteIds;
    }
    
    public void execute(QueueableContext context) {
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        System.debug('query'+[Select Id, Slack_User_Id__c from User where Slack_User_Id__c != null]);
        List<User> slackUsers = new List<User>([Select Id, Slack_User_Id__c from User 
                                    where Slack_User_Id__c != null AND
                                      Id In (Select OwnerId from Quote where Id In :quoteIds)]);
        if(Test.isRunningTest()){
            slackUsers = new List<User>([Select Id, Slack_User_Id__c from User 
                                    where Id =: UserInfo.getUserId()]);
        }
        for(Quote objQuote : [Select Id, Name,Approval_Expected__c from Quote where Id In :quoteIds]) {
            for(User sUser : slackUsers) {
                HttpRequest req = new HttpRequest();
                String message = EncodingUtil.urlEncode( 'Quote Name: ' + objQuote.Name +  '\n'  + 'Quote link: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + objQuote.Id  + '\n' + 'Approval is expected to confirm in ' + objQuote.Approval_Expected__c, 'UTF-8');
                req.setEndpoint('https://slack.com/api/chat.postMessage?token=' + slackAPI.Slack_API_Token__c + '&pretty=1&text=' +
                                message + '&channel=' + sUser.Slack_User_Id__c);
                System.debug(req.getEndpoint());
                req.setMethod('POST');
                req.setHeader('Content-type','application/json');
                if(!Test.isRunningTest()){ HttpResponse res = new Http().send(req);
                    System.debug('response plain: ' + res);
                }
            }
        }
    }
}
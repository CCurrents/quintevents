/*********************************************************************************
* Controller Class: QE_SendNotificationtoSlack 
----------------------------------------------------------------------------------
* Purpose/Methods:
* - Send Awaiting Approval notification to slack channel 
*   if approval process delay with 15 mins
----------------------------------------------------------------------------------
* Unit Test: QE_SendNotificationtoSlack_Test
*********************************************************************************/
public class QE_SendNotificationtoSlack {
   
    @InvocableMethod(label='Send notification to slack channel' description='Send Awaiting Approval notification to slack channel if approval process delay with 15 mins')
    public static void SendNotificationToSlackChannel(List<Id> quoteIds) {
        postMessageInChannel(quoteIds);
    }
    
    @Future(callout=true)
    public static void postMessageInChannel(List<Id> quoteIds) {
        
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        
        for(Quote qoutes : [Select Id, Name, Awaiting_Approval_From__c, Draft_Reasons_For_Review_H4H__c, Draft_Reasons_For_Review_Sales__c,
                  Draft_Reasons_For_Review_Operations__c, Draft_Reasons_For_Review_Corporate_Sales__c, Owner.UserRole.Name From Quote where Id In :quoteIds]){
            
            String slackChannelId = '';
            String qoutesLink = URL.getSalesforceBaseUrl().toExternalForm() + '/'+qoutes.Id;
            
            String slackMessage = 'The following quote has been awaiting approval for more than 15 minutes: \n'+qoutes.Name+'\n'+ qoutesLink;
            
            if(qoutes.Awaiting_Approval_From__c == 'H4H'){
                slackChannelId = slackAPI.H4H_Approvals_Channel__c;
            }
            if(qoutes.Awaiting_Approval_From__c == 'Exclusive GP') {
                slackChannelId = slackAPI.EGP_Approvals_Channel__c;
            }
            if(qoutes.Awaiting_Approval_From__c == 'Sales'){
                slackChannelId = slackAPI.Sales_Approvals_Channel__c;
            }
            if(qoutes.Awaiting_Approval_From__c == 'Operations') {
                slackChannelId = slackAPI.Operations_Approvals_Channel__c;
            }
            if(qoutes.Awaiting_Approval_From__c == 'Corporate Sales') {
                slackChannelId = slackAPI.Corp_Sales_Approvals_Channel__c;
            }
            
            postMessageCallout(EncodingUtil.urlEncode(slackMessage, 'UTF-8'), slackChannelId, slackAPI.Slack_API_Token__c);
        }
    }
    /********************************************
    * HTTP callout for Send Message into Slack
    ********************************************/
    public static void postMessageCallout(String message, String slackChannelId, String slackAPIToken) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://slack.com/api/chat.postMessage?token='+ slackAPIToken +'&pretty=1&text=' +
                        message + '&channel=' + slackChannelId );
        req.setMethod('POST');
        req.setHeader('Content-type','application/json');
        if(!Test.isRunningTest()){
            HttpResponse res = new Http().send(req);
        }
    }
}
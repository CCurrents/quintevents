public class QE_SlackEventActivation {
     
    @InvocableMethod(label='SlackEvent Status Activation' description='Post message for Activation')
    public static void postActivation(List<Id> eventIds) {
        activationPostMessage(eventIds);
    }
    
    @Future(callout=true)
    Public static void activationPostMessage(List<Id> lstEventIds) {
        List<QE360_Event__c> eventDetails = new List<QE360_Event__c>([Select Id, Name, Active__c, Slack_Channel_Id__c, Post_to_Slack_Channel__c
                                                                         FROM QE360_Event__c where Id In :lstEventIds]);
        for(QE360_Event__c qeEvent : eventDetails) {
            QE_SlackEventChannelPost.postMessageInChannel(qeEvent);
        }
    }
}
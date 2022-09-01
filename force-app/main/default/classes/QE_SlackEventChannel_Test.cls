@isTest
public class QE_SlackEventChannel_Test {
    
    static testMethod void slackEventChannelCreateTest() {
        Test.startTest();
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', Post_to_Slack_Channel__c = true, Slack_Channel_Name__c='test slack channel');
        insert eventTest;
        
        QE_SlackEventChannel.createChannel(new List<Id>{eventTest.Id});
        QE_SlackEventChannel.addMembersInChannel(new List<User>{new User(Slack_User_Id__c = '11111')}, '123', '21213');
        Test.stopTest();
    }
}
@isTest
public class QE_RenameSlackEventChannel_Test {

    static testMethod void slackEventChannelRenameTest() {
        Test.startTest();
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', Slack_Channel_Id__c ='1233',Slack_Channel_Name__c='SLackName');
        insert eventTest;

        QE_RenameSlackEventChannel.renameChannel(new List<Id>{eventTest.Id});
        Test.stopTest();
    }
}
@isTest
public class QE_SlackEventChannelMemberShip_Test {
    
    static testMethod void addremoveMemberTest() {
        Test.startTest();
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', Post_to_Slack_Channel__c = true, End_Date__c = System.today().addDays(2), Slack_Channel_Id__c = '01235');
        insert eventTest;
        
        QE_SlackEventChannelMemberShip.manageMember(new List<Id>{UserInfo.getUserId()});
        
        Test.stopTest();
    }
}
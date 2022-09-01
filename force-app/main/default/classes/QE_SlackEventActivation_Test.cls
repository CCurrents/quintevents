@isTest
public class QE_SlackEventActivation_Test {
    
    static testMethod void eventActivationTest() {
        Test.startTest();
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', Post_to_Slack_Channel__c = true);
        insert eventTest;
        
        QE_SlackEventActivation.postActivation(new List<Id>{eventTest.Id});
        Test.stopTest();
    }
}
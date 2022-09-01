@isTest
public class QE_SlackEventChannelInactiveProduct_Test {
    
    static testMethod void slackinActiveProductTest() {
        Test.startTest();
        TestDataFactory.createTriggerSettingsEntry();      
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test');
        insert eventTest;
        
        Product2 proPro = new Product2(Name='BXCD22', isActive=true, 
                                       Event__c = eventTest.Id,Type__c='Hospitality',
                                       Send_Slack_Notifications__c=true,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        insert proPro;
        QE_SlackEventChannelInactiveProduct.postToSlackforInactiveProduct(new List<Id>{proPro.Id});
        //QE_SlackEventChannelInactiveProduct.postToSlackChannelForInactiveProduct(new List<Id>{proPro.Id});
        Test.stopTest();
    }
}
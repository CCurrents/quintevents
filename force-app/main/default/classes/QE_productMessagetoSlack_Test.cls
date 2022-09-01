@isTest
public class QE_productMessagetoSlack_Test {
    
    static testMethod void soldOutProductTest() {
        Test.startTest();
        TestDataFactory.createTriggerSettingsEntry();      
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test');
        insert eventTest;
        
        Product2 proPro = new Product2(Name='BXCD22', isActive=true, 
                                       Event__c = eventTest.Id,Type__c='Hospitality',
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1,Send_Slack_Notifications__c = true);
        insert proPro;

        QE_productMessagetoSlack.postProductSoldOutMessage(new List<Id>{proPro.Id});
        Test.stopTest();
    }
}
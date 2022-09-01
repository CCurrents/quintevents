@isTest
public class QE_SlackEventChannelPost_Test {
    
    static testMethod void lowInventoryTest() {
        Test.startTest();
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', Post_to_Slack_Channel__c = true);
        insert eventTest;
        
        Product2 proPro = new Product2(Name='BXCD22', isActive=true, 
                                       Event__c = eventTest.Id,Type__c='Hospitality',
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        insert proPro;

        QE_SlackEventChannelPost.postToSlackforLowInventory(new List<Id>{proPro.Id});
        QE_SlackEventChannelPackageInventory.postToSlackforLowPackageInventory(new List<Id>{proPro.Id});
        QE_SlackEventChannelInactiveProduct.postToSlackforInactiveProduct(new List<Id>{proPro.Id});
        QE_SlackEventChannelArchive.archiveChannelforEvent(new List<Id>{eventTest.Id});
        
        Test.stopTest();
    }
}
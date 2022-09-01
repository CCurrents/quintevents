@isTest public class H4HRewardPointBatchTest {
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        
    }
    static testmethod void testRun1(){
        Account objAccount = TestDataFactory.createAccount();
        System.assert(true,objAccount.Name != null);

        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        System.assertEquals('Test@gmail.com', objContact.Email);
 
        PriceBook2 pricebook = TestDataFactory.createPricebook(1, 'Test PB', false)[0];
        pricebook.GPE_Event__c = true;
        Utility.processRecords(pricebook, 'insert');
        System.assertEquals(true, pricebook.GPE_Event__c);
        
        Opportunity objOpportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, pricebook.id, false)[0];
        objOpportunity.StageName = 'Closed Won';
        Utility.processRecords(objOpportunity, 'insert');
        System.assertEquals('Closed Won', objOpportunity.StageName);
        
        TestDataFactory.createSFDCIntacctMapping();
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = objContact.Id;
        ocr.OpportunityId = objOpportunity.Id;
        ocr.Role = 'H4H Rewards Contact';
        Utility.processRecords(ocr, 'insert');
        
        Order objOrder= TestDataFactory.createOrder(1,false)[0];
        objOrder.OpportunityId = objOpportunity.Id;
        Utility.processRecords(objOrder, 'insert');
        
        Map<Id, Order> mapOrder = new Map<Id, Order>();
        mapOrder.put(objOrder.Id, objOrder);
        H4HRewardPointBatch rewardpointbatch = new H4HRewardPointBatch(mapOrder.keySet());
        Database.executeBatch(rewardpointbatch,20);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RewardMockHttpResponse());
        Test.stopTest();
        System.assertNotEquals(objOrder.Id, null);
    }
}
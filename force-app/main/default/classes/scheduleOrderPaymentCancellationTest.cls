/**
 * @File Name          : scheduleOrderPaymentCancellationTest.cls
 * @Description        : test class for the scheduleOrderPaymentCancellation controller
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : Lovel Panchal
 * @Last Modified On   : 5/11/2020, 5:30:10 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/20/2020   mpatel@addonblue.com     Initial Version
**/
@isTest
private with sharing class scheduleOrderPaymentCancellationTest {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void cancelOrderFirstTestExecution() {
        Account objAccount = TestDataFactory.createAccount();
        System.assert(true,objAccount.Name != null);

        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        System.assertEquals('Test@gmail.com', objContact.Email);
        PriceBook2 priceBook = TestDataFactory.createPricebook(1, 'T', false)[0];
        priceBook.Payment_Cancellation_Days__c = 2;
        priceBook.Start_Date__c = system.today();
        priceBook.Event_Payment_Window__c = 1;
        Utility.processRecords(pricebook, 'insert');

        Opportunity opportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, pricebook.id, false)[0];
        opportunity.PriceBook2Id = pricebook.Id;
        opportunity.StageName = 'Closed Won';
        Utility.processRecords(opportunity, 'insert');
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = objContact.Id;
        ocr.OpportunityId = Opportunity.Id;
        ocr.Role = 'H4H Rewards Contact';
        Utility.processRecords(ocr, 'insert');
        
        TestDataFactory.createSFDCIntacctMapping();
        
        Order order = TestDataFactory.createOrder(1,false)[0];
        order.OpportunityId = opportunity.Id;
        order.Subject_to_Cancellation__c = false;
        Utility.processRecords(order, 'insert');

        Payment_Term__c paymentTerm = TestDataFactory.createPaymentTerm(1,false)[0];
        paymentTerm.Payment_Due_Date__c = System.today().addDays(-2);
        paymentTerm.Order__c = order.Id; 
        paymentTerm.Status__c = '';
        Utility.processRecords(paymentTerm, 'insert');
        System.assert(true,paymentTerm.Name != null);
        Test.startTest();
        scheduleOrderPaymentCancellation.updateOrderPaymentCancellations();
        String CRON_EXP = '0 59 18 * * ?';
        system.schedule('name',CRON_EXP ,new scheduleOrderPaymentCancellation());
        Set<Id> orderIDs = new Set<Id>();
        orderIds.add(order.Id);
        String query = 'Select id,Opportunity.PriceBook2.Event_Payment_Window__c,Opportunity.PriceBook2.Start_Date__c,Opportunity.PriceBook2.Payment_Cancellation_Days__c,Subject_to_Cancellation__c,(Select Id,Status__c,Payment_Due_Date__c from Payment_Terms__r where Payment_Due_Date__c != null order by Payment_Due_Date__c limit 1) from Order ';//where id in: orderIDs
        UpdatePaymentCancellationsBatch newTopicsUpdate = new UpdatePaymentCancellationsBatch(query, orderIDs);
        ID batchprocessid = Database.executeBatch(newTopicsUpdate);
        Test.stopTest();
    }
}
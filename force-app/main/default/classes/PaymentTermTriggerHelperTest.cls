/**
 * @File Name          : PaymentTermTriggerHelperTest.cls
 * @Description        : 
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 02-24-2022
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    3/16/2020   mpatel@addonblue.com     Initial Version
**/
@isTest
private with sharing class PaymentTermTriggerHelperTest{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();
    }
    @isTest static void testMethodOne() {
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
        
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        
        Quote qut = TestDataFactory.createQuote(1,true)[0];

        Order order = TestDataFactory.createOrder(1,false)[0];
        order.quoteId = qut.id;
        order.OpportunityId = objOpportunity.Id;
        Utility.processRecords(order, 'insert');        
        
        Test.startTest();
        Payment_Term__c payterm = new Payment_Term__c();
        payterm.Order__c = order.Id;
        payterm.Quote__c = qut.id;
        payterm.Status__c = '';
        Utility.processRecords(payterm, 'insert');
        System.assertEquals(order.Id, payterm.Order__c);
        
        payterm.Status__c = 'Passed';
        Utility.processRecords(payterm, 'update');
        System.assertEquals('Passed', payterm.Status__c);

        Set<Id> paymentList = new Set<Id>();
        paymentList.add(payterm.Id);
        PaymentTermTriggerHelper.amountUpdatedInIntacct(paymentList);

        Utility.processRecords(payterm, 'delete');
        System.assertEquals(false ,payterm == null);
        undelete payterm;
        Test.StopTest();
    }

     @isTest static void testpaymentTermDelete() {
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
        
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        
        Quote qut = TestDataFactory.createQuote(1,true)[0];

        Order order = TestDataFactory.createOrder(1,false)[0];
        order.quoteId = qut.id;
        order.OpportunityId = objOpportunity.Id;
        Utility.processRecords(order, 'insert');        
        
        Test.startTest();
        Payment_Term__c payterm = new Payment_Term__c();
        payterm.Order__c = order.Id;
        payterm.Quote__c = qut.id;
        payterm.Status__c = '';
        Utility.processRecords(payterm, 'insert');
        System.assertEquals(order.Id, payterm.Order__c);
        payterm.Intacct_Id__c='12345';
        payterm.Record_Id__c='wertyrr';
        payterm.Status__c = 'Passed';
        Utility.processRecords(payterm, 'update');
        System.assertEquals('Passed', payterm.Status__c);
        Set<Id> paymentList = new Set<Id>();
        paymentList.add(payterm.Id);
        Utility.processRecords(payterm, 'delete');
        Test.StopTest();
    }
}
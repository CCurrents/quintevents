/**
 * @File Name          : SendOrderToGPT.cls
 * @Description        : test class for the SendOrderToGPT controller
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 06/03/2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    06/03/2021    kchavda@addonblue.com       Initial Version
**/ 
@isTest
private with sharing class SendOrderToGPTTest{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void sendOrderFistETestxecution() {

        Account objAccount = TestDataFactory.createAccount();
        System.assert(true,objAccount.Name != null);

        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        System.assertEquals('Test@gmail.com', objContact.Email);

        PriceBook2 priceBook = TestDataFactory.createPricebook(1, 'T', false)[0];
        priceBook.GPE_Event__c = true;
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
        order.Intacct_id__c = 'tet1233';  
        order.Order_Payment_Status__c = 'Fully Paid';  
        Utility.processRecords(order, 'insert');
         
        SendOrderToGPT.processOrder(order.Id);
    }
    
}
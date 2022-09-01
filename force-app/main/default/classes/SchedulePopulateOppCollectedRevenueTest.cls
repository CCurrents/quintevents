/**
 * @File Name          : SchedulePopulateOppCollectedRevenueTest.cls
 * @Description        : test class for the SchedulePopulateOppCollectedRevenue controller
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 08/21/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    08/21/2020    kchavda@addonblue.com       #506 Collected Revenue on Opportunities
**/
@isTest
private with sharing class SchedulePopulateOppCollectedRevenueTest{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void testone() {
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
        order.collected_Revenue__c = 200;
        Utility.processRecords(order, 'insert');

        string  query = 'select id,Collected_Revenue__c,Opportunity.Collected_Revenue__c,OpportunityId from order where Collected_Revenue__c != null and Opportunityid != null '; 
        PopulateOppCollectedRevenueBatch  obj2 = new PopulateOppCollectedRevenueBatch(query);
        ID batchprocessid3 = Database.executeBatch(obj2);
        SchedulePopulateOppCollectedRevenue sch = new SchedulePopulateOppCollectedRevenue();
        sch.execute(null);
    }
}
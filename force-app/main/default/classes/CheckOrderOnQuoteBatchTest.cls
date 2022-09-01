/**
 * @description       : 
 * @author            : jagrawal@addonblue.com
 * @group             : 
 * @last modified on  : 11-02-2020
 * @last modified by  : jagrawal@addonblue.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   11-02-2020   jagrawal@addonblue.com   Initial Version
**/
@isTest
public class CheckOrderOnQuoteBatchTest {
    
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }
    @isTest
    static void checkOrderOnQuoteTestExecution() {
        Account objAccount = TestDataFactory.createAccount();
        System.assert(true,objAccount.Name != null);
        
        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        PriceBook2 pricebook = TestDataFactory.createPricebook(1, 'Test PB', false)[0];
        pricebook.GPE_Event__c = true;
        Utility.processRecords(pricebook, 'insert');
        System.assertEquals(true, pricebook.GPE_Event__c);
        
        Opportunity objOpportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, pricebook.id, false)[0];
        objOpportunity.StageName = 'Closed Won';
        Utility.processRecords(objOpportunity, 'insert');
        System.assertEquals('Closed Won', objOpportunity.StageName);
        Quote quote = TestDataFactory.createQuote(1, objOpportunity.Id, pricebook.Id)[0];
        quote.OpportunityId = objOpportunity.Id;
        Utility.processRecords(quote, 'insert');
        Order order = TestDataFactory.createOrder(1, objOpportunity.Id, quote.Id,objContact.Id,pricebook.Id)[0];
        Utility.processRecords(order, 'insert');
        CheckOrderOnQuoteBatch b1 = new CheckOrderOnQuoteBatch();
        Database.executeBatch(b1);
        System.schedule('jobName', '0 0 * * * ?', b1);
        
    }
    
    @isTest
    static void checkOrderOnQuoteTestExecution1() {
        Account objAccount = TestDataFactory.createAccount();
        System.assert(true,objAccount.Name != null);
        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        PriceBook2 pricebook = TestDataFactory.createPricebook(1, 'Test PB', false)[0];
        pricebook.GPE_Event__c = true;
        Utility.processRecords(pricebook, 'insert');
        System.assertEquals(true, pricebook.GPE_Event__c);
        Opportunity objOpportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, pricebook.id, false)[0];
        objOpportunity.StageName = 'Closed Won';
        Utility.processRecords(objOpportunity, 'insert');
        System.assertEquals('Closed Won', objOpportunity.StageName);
        Quote quote = TestDataFactory.createQuote();
        Trigger_Settings__c objQuotetrigger = Trigger_Settings__c.getInstance('Quote');
        objQuotetrigger.Deactivate__c = true;
        Utility.processRecords(objQuotetrigger, 'update');
        quote.Status = 'Signed - Approved';
        Utility.processRecords(quote, 'update');
        CheckOrderOnQuoteBatch b1 = new CheckOrderOnQuoteBatch();
        Database.executeBatch(b1);
        
        
    }
    
    
}
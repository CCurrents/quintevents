/**
 * @File Name          : AddOpportunityAndQuote_LEXTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : rama.krishna@addonblue.com
 * @Last Modified On   : 11-21-2021
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    3/19/2020   mpatel@addonblue.com     Initial Version
**/ 
@isTest
private with sharing class AddOpportunityAndQuote_LEXTest {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();
    }
    @isTest static void testMethodOne() {
        
        TestDataFactory.createSFDCIntacctMapping();
        Lead lead = TestDataFactory.createLead();
        
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
        
        objOpportunity.StageName = 'Request Cancelation';
        Utility.processRecords(objOpportunity, 'update');
               
        System.assertEquals(true, lead != null);
        //Opportunity opportunity = TestDataFactory.createOpportunity();
        System.assertEquals(true, objOpportunity != null);
        AddOpportunityAndQuote_LEX.convertLead(objOpportunity.accountId,objOpportunity,objOpportunity.contactid);
        AddOpportunityAndQuote_LEX.getPricebookCurrencyDetails(TestDataFactory.createpriceBook().Id);
        AddOpportunityAndQuote_LEX.isF1EProgrammedPriceBook(pricebook.Id);
        Lead objLead = AddOpportunityAndQuote_LEX.retrieveLeadInfo(lead.Id);
        AddOpportunityAndQuote_LEX.createQuoteFromOpportunity(objOpportunity.Id);
        AddOpportunityAndQuote_LEX.convertLead('',objOpportunity,'');
        AddOpportunityAndQuote_LEX.getAccountRecordType(objOpportunity.accountId);
        System.assertEquals(objLead.Id, lead.Id);
        AddOpportunityAndQuote_LEX.fetchLookUpValues('Account', 'Contact','Opportunity');
        AddOpportunityAndQuote_LEX.fetchContactLookUpValues('Test', 'Contact',objAccount.id);
        //System.assertEquals('Request Cancelation', objOpportunity.StageName);
        Utility.processRecords(objOpportunity, 'delete');
    }
}
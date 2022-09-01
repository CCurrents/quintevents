/**
 * @File Name          : EmailQuoteTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 05-24-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/8/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
public class EmailQuoteTest {
	@isTest static void testMethod_one() {
        TestDataFactory.createTriggerSettingsEntry();
        Quote quote = TestDataFactory.createQuote();
		quote.Status = 'Draft - Approved';
        update quote;
        OpportunityContactRole contactRole = TestDataFactory.createOpportunityContactRole(quote);
        List<dsfs__DocuSign_Status__c> docuSignStatus = TestDataFactory.createDocuSignStatus(quote);
        insert docuSignStatus;
        EmailQuote.sendWithDocuSign(quote.Id);
        System.assertEquals('Draft - Approved', quote.Status);
    }
    
    @isTest static void testMethod_two() {
        TestDataFactory.createTriggerSettingsEntry();
        Quote quote = TestDataFactory.createQuote();
		quote.Status = 'Draft - Approved';
        update quote;
        OpportunityContactRole contactRole = TestDataFactory.createOpportunityContactRole(quote);
        EmailQuote.sendWithDocuSign(quote.Id);
        System.assertEquals('Draft - Approved', quote.Status);
    }
    
    @isTest static void testMethod_three() {
        TestDataFactory.createTriggerSettingsEntry();
        Quote quote = TestDataFactory.createQuote();
		quote.Status = 'Draft - Approved';
        update quote;
        OpportunityContactRole contactRole = TestDataFactory.createOpportunityContactRole(quote);
        List<dsfs__DocuSign_Status__c> docuSignStatus = TestDataFactory.createDocuSignStatus(quote);
        insert docuSignStatus;
        docuSignStatus[0].Counter_Signer_Envelope__c = true;
        update docuSignStatus;
        EmailQuote.sendWithDocuSign(quote.Id);
        System.assertEquals('Draft - Approved', quote.Status);
    }
    
    @isTest static void testMethod_four() {
        TestDataFactory.createTriggerSettingsEntry();
        Quote quote = TestDataFactory.createQuote();
		quote.Status = 'Draft';
        update quote;
        OpportunityContactRole contactRole = TestDataFactory.createOpportunityContactRole(quote);
        List<dsfs__DocuSign_Status__c> docuSignStatus = TestDataFactory.createDocuSignStatus(quote);
        insert docuSignStatus;
        docuSignStatus[0].Counter_Signer_Envelope__c = true;
        update docuSignStatus;
        EmailQuote.sendWithDocuSign(quote.Id);
        System.assertEquals('Draft', quote.Status);
    }

        
    @isTest static void testMethod_DocuSignEnvelopCompletedStatus(){
        //Issue#1135
        TestDataFactory.createTriggerSettingsEntry();   
        Quote quote = TestDataFactory.createQuote();
		quote.Status = 'Draft - Approved';
        update quote;
        OpportunityContactRole contactRole = TestDataFactory.createOpportunityContactRole(quote);
        List<dsfs__DocuSign_Status__c> docuSignStatus = TestDataFactory.createDocuSignStatus(quote);
        insert docuSignStatus;
        docuSignStatus[0].Counter_Signer_Envelope__c = true;
        docuSignStatus[0].dsfs__Envelope_Status__c = 'Completed';
        update docuSignStatus;
        EmailQuote.sendWithDocuSign(quote.Id);
        System.assertEquals('Draft - Approved', quote.Status);
    }
    

    @isTest static void testMethod_five() {
        TestDataFactory.createTriggerSettingsEntry();
        Quote quote = TestDataFactory.createQuote();
        quote.Status = 'Draft';
        update quote;
        
        Product2 objProduct = TestDataFactory.createProduct('Test Product', 'Product', 'Transportation', null, quote.PriceBook2Id);
        insert objProduct;
        
        //******* PricebookEntry *******//
        List<PricebookEntry> stdPriceBookEntries = new List<PricebookEntry>();
        
        PricebookEntry objStdPriceBook = TestDataFactory.createPricebookEntry(objProduct, Test.getStandardPricebookId());
        stdPriceBookEntries.add(objStdPriceBook);
        
        PricebookEntry objPriceBook = TestDataFactory.createPricebookEntry(objProduct, quote.PriceBook2Id);
        stdPriceBookEntries.add(objPriceBook);
        
        stdPriceBookEntries = Utility.processRecords(stdPriceBookEntries, 'insert');
        
        QuoteLineItem newChildQLI = TestDataFactory.createQuoteLineItem(quote.Id, stdPriceBookEntries[0].Id, 'Addon', null, null, true);
        
        OpportunityContactRole contactRole = TestDataFactory.createOpportunityContactRole(quote);
        List<dsfs__DocuSign_Status__c> docuSignStatus = TestDataFactory.createDocuSignStatus(quote);
        insert docuSignStatus;
        docuSignStatus[0].Counter_Signer_Envelope__c = true;
        update docuSignStatus;
        EmailQuote.sendWithDocuSign(quote.Id);
        System.assertEquals('Draft', quote.Status);
    }
}
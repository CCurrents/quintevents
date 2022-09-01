/**
 * @File Name          : Quote_ReviewQuote_Tab_LEXTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 07-19-2020
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/27/2020   mpatel@addonblue.com       Initial Version
**/
@isTest
private with sharing class Quote_ReviewQuote_Tab_LEX_Test{
    public static void createtestdata() {
        TestDataFactory.createTriggerSettingsEntry();
        
        //******* Pricebook *******//
        Pricebook2 testPricebook = TestDataFactory.createPricebook();
        
        //******* Parent Package *******//
        List<Parent_Package__c> lstParentPackage = TestDataFactory.createParentPackage(1, true, testPricebook.Id);
        
        //******* Product *******//
        List<Product2> lstProduct = new List<Product2>();
        Product2 objProduct = TestDataFactory.createProduct('Test Package Product', 'Package', 'Package', lstParentPackage[0].Id, testPricebook.Id);
        lstProduct.add(objProduct);
        
        Product2 objProduct1 = TestDataFactory.createProduct('Test Product', 'Product', 'Transportation', null, testPricebook.Id);
        lstProduct.add(objProduct1);
        
        Product2 objProduct2 = TestDataFactory.createProduct('Test Hotel', 'Hotel', 'Hospitality', null, testPricebook.Id);
        lstProduct.add(objProduct2);
        
        Product2 objProduct3 = TestDataFactory.createProduct('Test Hotel Stay', 'Hotel Stay', 'Stay', null, testPricebook.Id);
        lstProduct.add(objProduct3);
        
        lstProduct = Utility.processRecords(lstProduct, 'insert');
        
        //******* PricebookEntry *******//
        List<PricebookEntry> stdPriceBookEntries = new List<PricebookEntry>();
        
        PricebookEntry objStdPriceBook = TestDataFactory.createPricebookEntry(objProduct, Test.getStandardPricebookId());
        stdPriceBookEntries.add(objStdPriceBook);
        
        PricebookEntry objStdPriceBook1 = TestDataFactory.createPricebookEntry(objProduct1, Test.getStandardPricebookId());
        stdPriceBookEntries.add(objStdPriceBook1);
        
        PricebookEntry objStdPriceBook2 = TestDataFactory.createPricebookEntry(objProduct2, Test.getStandardPricebookId());
        stdPriceBookEntries.add(objStdPriceBook2);
        
        PricebookEntry objStdPriceBook3 = TestDataFactory.createPricebookEntry(objProduct3, Test.getStandardPricebookId());
        stdPriceBookEntries.add(objStdPriceBook3);
        
        PricebookEntry objPriceBook = TestDataFactory.createPricebookEntry(objProduct, testPricebook.Id);
        stdPriceBookEntries.add(objPriceBook);
        
        PricebookEntry objPriceBook1 = TestDataFactory.createPricebookEntry(objProduct1, testPricebook.Id);
        stdPriceBookEntries.add(objPriceBook1);
        
        PricebookEntry objPriceBook2 = TestDataFactory.createPricebookEntry(objProduct2, testPricebook.Id);
        stdPriceBookEntries.add(objPriceBook2);
        
        PricebookEntry objPriceBook3 = TestDataFactory.createPricebookEntry(objProduct3, testPricebook.Id);
        stdPriceBookEntries.add(objPriceBook3);
        
        stdPriceBookEntries = Utility.processRecords(stdPriceBookEntries, 'insert');
        
        // create Account
        Account acc = TestDataFactory.createAccount();
        
        // Create Contact
        Contact con = TestDataFactory.createContact(acc.Id);
        
        // create Opportunity
        Opportunity opportunity = TestDataFactory.createOpportunity(1, acc.Id, con.Id, testPricebook.Id, true)[0];
                
        Quote objquote = TestDataFactory.createQuote(1, opportunity, testPricebook.Id)[0];
        
        QuoteLineItem newParentQLI = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'Package', null, null, true);
        
        List<QuoteLineItem> lstLineItem = new List<QuoteLineItem>();
        
        QuoteLineItem newChildQLI = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'Package Product', newParentQLI.Id, null, false);
        lstLineItem.add(newChildQLI);
        
        QuoteLineItem newChildQLI1 = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'Package Hotel', newParentQLI.Id, null, false);
        lstLineItem.add(newChildQLI1);
        
        QuoteLineItem newChildQLI2 = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'A La Carte', newParentQLI.Id, null, false);
        lstLineItem.add(newChildQLI2);
        
        QuoteLineItem newChildQLI3 = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'Hotel Transportation', newParentQLI.Id, null, false);
        lstLineItem.add(newChildQLI3);
        
        QuoteLineItem newChildQLI4 = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'Hotel Stay', newParentQLI.Id, null, false);
        lstLineItem.add(newChildQLI4);
        
        QuoteLineItem newChildQLI5 = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'Addon', newParentQLI.Id, null, false);
        lstLineItem.add(newChildQLI5);
        
        lstLineItem = Utility.processRecords(lstLineItem, 'insert');
    }
    
    @isTest static void contactFirstTestExecution() {
        createtestdata();
        Quote quote =  [Select Id From Quote Limit 1];
        Quote_ReviewQuote_Tab_LEX.readBaseUrl();
        Quote_ReviewQuote_Tab_LEX.generateQuoteFile(quote.Id);
        Quote_ReviewQuote_Tab_LEX.getQuoteLineItemList(quote.Id);
        Quote_ReviewQuote_Tab_LEX.updateQuoteStatusLightning(quote.Id);
    }
    
    @isTest static void getDependentPicklistValuesTest() {
        createtestdata();
        Quote_ReviewQuote_Tab_LEX.getDependentPicklistValues('quote', 'BillingCountryCode', 'BillingStateCode');
    }
    @isTest static void testApprovals() {
        TestDataFactory.createTriggerSettingsEntry();
        List<Quote> quoteList = new List<Quote>();
        Quote quote = TestDataFactory.createQuote(1,false)[0]; 
        quote.Status = 'Draft';
        Quote quote2 = TestDataFactory.createQuote(1,false)[0]; 
        quote2.Status = 'Draft';
        quoteList.add(quote);
        quoteList.add(quote2);
        Utility.processRecords(quoteList, 'insert');
        
        Product2 objProduct = TestDataFactory.createProduct();
        PricebookEntry PBEObj = TestDataFactory.createPricebookEntry();
        
        
        List<QuoteLineItem> qli = new List<QuoteLineItem>();
		QuoteLineItem objQLI1 = new QuoteLineItem(
            Quantity = 2,
            Product2ID= objProduct.Id,
            QuoteId = quote.Id,
            UnitPrice = 0.01,
            PriceBookEntryId = PBEObj.Id );
        
        QuoteLineItem objQLI2 = new QuoteLineItem(
            Quantity = 2,
            Product2ID= objProduct.Id,
            QuoteId = quote2.Id,
            UnitPrice = 0.01,
            PriceBookEntryId = PBEObj.Id );	
        
        QuoteLineItem objQLI3 = new QuoteLineItem(
            Quantity = 2,
            Product2ID= objProduct.Id,
            QuoteId = quote.Id,
            UnitPrice = 0.01,
            PriceBookEntryId = PBEObj.Id );
        
        QuoteLineItem objQLI4 = new QuoteLineItem(
            Quantity = 2,
            Product2ID= objProduct.Id,
            QuoteId = quote2.Id,
            UnitPrice = 0.01,
            PriceBookEntryId = PBEObj.Id );	
        
        qli.add(objQLI1);
        qli.add(objQLI2);
        qli.add(objQLI3);
        qli.add(objQLI4);
        insert qli;
        
        Quote objQuote = new Quote();
        objQuote.Id = quote2.ID;
        objQuote.Original_Quote__c = quote.ID;
        update objQuote;
        Quote_ReviewQuote_Tab_LEX.updateQuoteStatusLightning(quote.Id);
        Quote_ReviewQuote_Tab_LEX.updateQuoteStatusLightning(quote2.Id);
        
    }

    
}
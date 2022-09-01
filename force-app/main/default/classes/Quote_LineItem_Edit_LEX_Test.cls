/**
 * @File Name          : Quote_LineItem_Edit_LEX_Test.cls
 * @Description        : This test class use for Quote_LineItem_Edit_LEX.
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 03-15-2021
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    26/04/2020   fsuraitawala@addonblue.com     Initial Version
**/
@isTest
private class Quote_LineItem_Edit_LEX_Test {
    
    /****************************************/
    @TestSetup
    static void setupTestData() {
        TestDataFactory.createTriggerSettingsEntry();
        
        //******* Pricebook *******//
        Pricebook2 testPricebook = TestDataFactory.createPricebook();
        
        //******* Parent Package *******//
        List<Parent_Package__c> lstParentPackage = TestDataFactory.createParentPackage(1, true, testPricebook.Id);
        
        //******* Pricebook *******//
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
        
        //******* Products_Bundle__c *******//
        List<Products_Bundle__c> lstBundle = new List<Products_Bundle__c>();
        
        Products_Bundle__c objBundle = TestDataFactory.createProductBundle(objProduct1.Id, objProduct.Id, 'Package Product');
        lstBundle.add(objBundle);
        
        Products_Bundle__c objBundle1 = TestDataFactory.createProductBundle(objProduct2.Id, objProduct1.Id, 'Hotel Stay');
        lstBundle.add(objBundle1);
        
        Products_Bundle__c objBundle2 = TestDataFactory.createProductBundle(objProduct3.Id, objProduct2.Id, 'Hotel Transportation');
        lstBundle.add(objBundle2);
        
        lstBundle= Utility.processRecords(lstBundle, 'insert');
        
        
        // create Account
        Account acc = TestDataFactory.createAccount();
        
        // Create Contact
        Contact con = TestDataFactory.createContact(acc.Id);
        
        // create Opportunity
        Opportunity opportunity = TestDataFactory.createOpportunity(1, acc.Id, con.Id, testPricebook.Id, true)[0];
                
        Quote objquote = TestDataFactory.createQuote(1, opportunity, testPricebook.Id)[0];
        
        QuoteLineItem newParentQLI = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'Package', null, null, true);
        
        QuoteLineItem newHotelQLI = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'Package Hotel', newParentQLI.Id, null, true);
        
        List<QuoteLineItem> lstLineItem = new List<QuoteLineItem>();
        
        QuoteLineItem newChildQLI = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'Package Product', newParentQLI.Id, null, false);
        lstLineItem.add(newChildQLI);
        
        QuoteLineItem newChildQLI2 = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'A La Carte', newParentQLI.Id, null, false);
        lstLineItem.add(newChildQLI2);
        
        QuoteLineItem newChildQLI21 = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'Hotel Transportation', newParentQLI.Id, newHotelQLI.Id, false);
        lstLineItem.add(newChildQLI21);
        
        QuoteLineItem newChildQLI22 = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'Hotel Stay', newParentQLI.Id, newHotelQLI.Id, false);
        lstLineItem.add(newChildQLI22);
        
        QuoteLineItem newChildQLI23 = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'Hotel Transportation', newParentQLI.Id, null, false);
        lstLineItem.add(newChildQLI23);
        
        QuoteLineItem newChildQLI24 = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'Hotel Stay', newParentQLI.Id, null, false);
        lstLineItem.add(newChildQLI24);
        
        QuoteLineItem newChildQLI25 = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'Addon', newParentQLI.Id, null, false);
        lstLineItem.add(newChildQLI25);
        
        QuoteLineItem newChildQLI3 = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[6].Id, 'Package Hotel', null, null, true);
        
        QuoteLineItem newChildQLI4 = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'A La Carte', null, newChildQLI3.Id, false);
        lstLineItem.add(newChildQLI4);
        
        QuoteLineItem newChildQLI41 = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'A La Carte', null, null, false);
        lstLineItem.add(newChildQLI41);
        
        QuoteLineItem newChildQLI5 = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[7].Id, 'A La Carte', null, newChildQLI3.Id, false);
        lstLineItem.add(newChildQLI5);
        
        QuoteLineItem newChildQLI51 = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[7].Id, 'A La Carte', null, null, false);
        lstLineItem.add(newChildQLI51);
        
        lstLineItem = Utility.processRecords(lstLineItem, 'insert');

        Rooming_List__c objRoomingList = new Rooming_List__c();
        objRoomingList.Hotel_Package_Id__c = newChildQLI3.Id;
        objRoomingList.Number_of_Adults__c = 2;
        objRoomingList.QuoteLineItem_Id__c = newChildQLI5.Id;
        insert objRoomingList;
    }
    
    /****************************************/
    @isTest
    static void testRunOne() {
        Quote currentQuote = [Select Id, Pricebook2Id, (Select Id From QuoteLineItems Where Record_Type__c = 'Package') From Quote Limit 1];
        List<QuoteLineItem> lstQuoteLineItem = [Select Id From QuoteLineItem Where QuoteId = :currentQuote.Id LIMIT 1];
        
        Quote_LineItem_Edit_LEX.getaLaCarteLineItems(currentQuote.Id);
        Quote_LineItem_Edit_LEX.getHotelLineItems(currentQuote.Id);
        
        Quote_LineItem_Edit_LEX.getRelatedLineItems(currentQuote.Id, currentQuote.QuoteLineItems[0].Id);
    
    }
}
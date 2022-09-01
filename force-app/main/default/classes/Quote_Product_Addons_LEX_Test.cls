/**
 * @File Name          : Quote_Product_Addons_LEX_Test.cls
 * @Description        : This test class use for Quote_Product_Addons_LEX.
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 26/04/2020
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    26/04/2020   fsuraitawala@addonblue.com     Initial Version
**/
@isTest
private class Quote_Product_Addons_LEX_Test {
    
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
        
        lstProduct = Utility.processRecords(lstProduct, 'insert');
        
        //******* PricebookEntry *******//
        List<PricebookEntry> stdPriceBookEntries = new List<PricebookEntry>();
        
        PricebookEntry objStdPriceBook = TestDataFactory.createPricebookEntry(objProduct, Test.getStandardPricebookId());
        stdPriceBookEntries.add(objStdPriceBook);
        
        PricebookEntry objStdPriceBook1 = TestDataFactory.createPricebookEntry(objProduct1, Test.getStandardPricebookId());
        stdPriceBookEntries.add(objStdPriceBook1);
        
        PricebookEntry objPriceBook = TestDataFactory.createPricebookEntry(objProduct, testPricebook.Id);
        stdPriceBookEntries.add(objPriceBook);
        
        PricebookEntry objPriceBook1 = TestDataFactory.createPricebookEntry(objProduct1, testPricebook.Id);
        stdPriceBookEntries.add(objPriceBook1);
        
        stdPriceBookEntries = Utility.processRecords(stdPriceBookEntries, 'insert');
        
        //******* Products_Bundle__c *******//
        List<Products_Bundle__c> lstBundle = new List<Products_Bundle__c>();
        
        Products_Bundle__c objBundle = TestDataFactory.createProductBundle(objProduct1.Id, objProduct.Id, 'Package Product');
        lstBundle.add(objBundle);
        
        Products_Bundle__c objBundle2 = TestDataFactory.createProductBundle(objProduct1.Id, objProduct.Id, 'addon');
        lstBundle.add(objBundle2);
        
        lstBundle= Utility.processRecords(lstBundle, 'insert');
        
        
        // create Account
        Account acc = TestDataFactory.createAccount();
        
        // Create Contact
        Contact con = TestDataFactory.createContact(acc.Id);
        
        // create Opportunity
        Opportunity opportunity = TestDataFactory.createOpportunity(1, acc.Id, con.Id, testPricebook.Id, true)[0];
                
        Quote objquote = TestDataFactory.createQuote(1, opportunity, testPricebook.Id)[0];
        
        QuoteLineItem newParentQLI = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[2].Id, 'Package', null, null, true);
        
        QuoteLineItem newChildQLI = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[3].Id, 'Addon', newParentQLI.Id, null, true);
    }
    
    /****************************************/
    @isTest
    static void testRunOne() {
        Quote currentQuote = [Select Id, Pricebook2Id, (Select Id From QuoteLineItems Where Record_Type__c = 'Package') From Quote Limit 1];
        
        Test.startTest();
        List<PricebookEntry> lstPricebookEntry = Quote_Product_Addons_LEX.getAddonRelatedProduct(currentQuote.Id);
        
        List<SW_Utility_LEX.addonListClass> lstAddonList = Quote_Product_Addons_LEX.getAddonLineItems(currentQuote.QuoteLineItems[0].Id, currentQuote.Id);
        
        List<SW_Utility_LEX.addonListClass> listAddon = Quote_Product_Addons_LEX.saveLineItems(currentQuote.Id, lstAddonList, currentQuote.QuoteLineItems[0].Id);
        
        Test.stopTest();
    }
}
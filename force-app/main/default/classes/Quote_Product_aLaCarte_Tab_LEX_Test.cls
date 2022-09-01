/**
 * @File Name          : Quote_Product_aLaCarte_Tab_LEX_Test.cls
 * @Description        : This test class use for Quote_Product_aLaCarte_Tab_LEX.
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 26/04/2020
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    26/04/2020   fsuraitawala@addonblue.com     Initial Version
**/
@isTest
private class Quote_Product_aLaCarte_Tab_LEX_Test {
    
    /****************************************/
    @TestSetup
    static void setupTestData() {
        TestDataFactory.createTriggerSettingsEntry();
        
        //******* Pricebook *******//
        Pricebook2 testPricebook = TestDataFactory.createPricebook();
        
        //******* Parent Package *******//
        List<Parent_Package__c> lstParentPackage = TestDataFactory.createParentPackage(1, true, testPricebook.Id);
        
        //******* Product *******//
        List<Product2> lstProduct = new List<Product2>();
        Product2 objProduct = TestDataFactory.createProduct('Test Product', 'Product', 'Transportation', null, testPricebook.Id);
        lstProduct.add(objProduct);
        
        lstProduct = Utility.processRecords(lstProduct, 'insert');
        
        //******* PricebookEntry *******//
        List<PricebookEntry> stdPriceBookEntries = new List<PricebookEntry>();
        
        PricebookEntry objStdPriceBook = TestDataFactory.createPricebookEntry(objProduct, Test.getStandardPricebookId());
        stdPriceBookEntries.add(objStdPriceBook);
        
        PricebookEntry objPriceBook = TestDataFactory.createPricebookEntry(objProduct, testPricebook.Id);
        stdPriceBookEntries.add(objPriceBook);
        
        stdPriceBookEntries = Utility.processRecords(stdPriceBookEntries, 'insert');
        
        // create Account
        Account acc = TestDataFactory.createAccount();
        
        // Create Contact
        Contact con = TestDataFactory.createContact(acc.Id);
        
        // create Opportunity
        Opportunity opportunity = TestDataFactory.createOpportunity(1, acc.Id, con.Id, testPricebook.Id, true)[0];
                
        Quote objquote = TestDataFactory.createQuote(1, opportunity, testPricebook.Id)[0];
        
        QuoteLineItem aLaCarteQLI = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[1].Id, 'A La Carte', null, null, true);
    }
    
    /****************************************/
    @isTest
    static void testRunOne() {
        Quote currentQuote = [Select Id, Pricebook2Id, (Select Id From QuoteLineItems Where Record_Type__c = 'Package') From Quote Limit 1];
        
        Test.startTest();
        
        Quote_Product_aLaCarte_Tab_LEX.getProductTypeOptions();
        Quote_Product_aLaCarte_Tab_LEX.getaLaCarteRelatedProduct(currentQuote.Id);
        List<SW_Utility_LEX.aLaCarteObjClass> aLaCarteItems = Quote_Product_aLaCarte_Tab_LEX.getaLaCarteLineItems(currentQuote.Id);
        Quote_Product_aLaCarte_Tab_LEX.saveLineItems(currentQuote.Id, aLaCarteItems );
        
        Test.stopTest();
    }
}
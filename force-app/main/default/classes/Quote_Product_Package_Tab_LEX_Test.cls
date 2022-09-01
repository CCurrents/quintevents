/**
 * @File Name          : Quote_Product_Package_Tab_LEX_Test.cls
 * @Description        : This test class use for Quote_Product_Package_Tab_LEX.
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/10/2020, 10:10:24 PM
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    26/04/2020   fsuraitawala@addonblue.com     Initial Version
**/
@isTest
private class Quote_Product_Package_Tab_LEX_Test {
    
    /****************************************/
    @TestSetup
    static void setupTestData() {
        TestDataFactory.createTriggerSettingsEntry();
        
        //******* Pricebook *******//
        Pricebook2 testPricebook = TestDataFactory.createPricebook();
        
        //******* Parent Package *******//
        List<Parent_Package__c> lstParentPackage = TestDataFactory.createParentPackage(1, true, testPricebook.Id);
        
        //******* Product *******//
        List<Product2> lstProduct0 = new List<Product2>();
        Product2 objProduct0 = TestDataFactory.createProduct('Test Package Product 1', 'Package', 'Package', lstParentPackage[0].Id, testPricebook.Id);
        lstProduct0.add(objProduct0);
        
        Product2 objProduct01 = TestDataFactory.createProduct('Test Package Product 2', 'Package', 'Package', lstParentPackage[0].Id, testPricebook.Id);
        lstProduct0.add(objProduct01);
        
        lstProduct0 = Utility.processRecords(lstProduct0, 'insert');
        
        List<Product2> lstProduct = new List<Product2>();
        Product2 objProduct = TestDataFactory.createProduct('Test Package Product', 'Package', 'Package', lstParentPackage[0].Id, testPricebook.Id);
        objProduct.Upgrade__c = lstProduct0[0].Id;
        objProduct.Downgrade__c = lstProduct0[1].Id;
        lstProduct.add(objProduct);
        
        Product2 objProduct1 = TestDataFactory.createProduct('Test Product', 'Product', 'Transportation', null, testPricebook.Id);
        lstProduct.add(objProduct1);
        
        lstProduct = Utility.processRecords(lstProduct, 'insert');
        
        //******* PricebookEntry *******//
        List<PricebookEntry> stdPriceBookEntries = new List<PricebookEntry>();
        
        PricebookEntry objStdPriceBook = TestDataFactory.createPricebookEntry(objProduct, Test.getStandardPricebookId());
        stdPriceBookEntries.add(objStdPriceBook);
        
        PricebookEntry objPriceBook = TestDataFactory.createPricebookEntry(objProduct, testPricebook.Id);
        stdPriceBookEntries.add(objPriceBook);
        
        PricebookEntry objStdPriceBook1 = TestDataFactory.createPricebookEntry(objProduct1, Test.getStandardPricebookId());
        stdPriceBookEntries.add(objStdPriceBook1);
        
        PricebookEntry objPriceBook1 = TestDataFactory.createPricebookEntry(objProduct1, testPricebook.Id);
        stdPriceBookEntries.add(objPriceBook1);
        
        stdPriceBookEntries = Utility.processRecords(stdPriceBookEntries, 'insert');
        
        
        List<Products_Bundle__c> lstBundle = new List<Products_Bundle__c>();
        
        Products_Bundle__c objBundle = TestDataFactory.createProductBundle(objProduct1.Id, objProduct.Id, 'Package Product');
        lstBundle.add(objBundle);
        
        lstBundle= Utility.processRecords(lstBundle, 'insert');
        
        // create Account
        Account acc = TestDataFactory.createAccount();
        
        // Create Contact
        Contact con = TestDataFactory.createContact(acc.Id);
        
        // create Opportunity
        Opportunity opportunity = TestDataFactory.createOpportunity(1, acc.Id, con.Id, testPricebook.Id, true)[0];
                
        Quote objquote = TestDataFactory.createQuote(1, opportunity, testPricebook.Id)[0];
    
    }
    
    /****************************************/
    @isTest
    static void testRunOne() {
        Quote currentQuote = [Select Id, Pricebook2Id From Quote Limit 1];
        PricebookEntry selectedPriceBookEntry = [Select Id, Product2Id From PricebookEntry Where Pricebook2Id = :currentQuote.Pricebook2Id Limit 1];
        
        Test.startTest();
        Quote_Product_Package_Tab_LEX.getProductRecords(currentQuote.Id);
        QuoteLineItem PackageLineItem = Quote_Product_Package_Tab_LEX.saveLineItemRecords(currentQuote.Id, 5, selectedPriceBookEntry);
        
        Quote_Product_Package_Tab_LEX.updateLineItemRecords(PackageLineItem);
        
        System.assertEquals(PackageLineItem.QuoteId, currentQuote.Id);
        
        Quote_Product_Package_Tab_LEX.getCurrentQuote(currentQuote.Id);
        Quote_Product_Package_Tab_LEX.getQuoteLineItem(PackageLineItem.Id);
        
        
        Quote_Product_Package_Tab_LEX.getProductRecords('');
        Quote_Product_Package_Tab_LEX.updateLineItemRecords(null);
        Quote_Product_Package_Tab_LEX.saveLineItemRecords(null, null, null);
        Quote_Product_Package_Tab_LEX.saveLineItemRecords(currentQuote.Id, null, null);
        try {
            Quote_Product_Package_Tab_LEX.validateUpDownProduct('', '');
            Quote_Product_Package_Tab_LEX.getQuoteLineItem(null);
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        
        try {
            Quote_Product_Package_Tab_LEX.validateUpDownProduct('', currentQuote.Id);
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        
        try {
            Quote_Product_Package_Tab_LEX.validateUpDownProduct(selectedPriceBookEntry.Product2Id, currentQuote.Id);
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        
        Quote_Product_Package_Tab_LEX.getProductById(selectedPriceBookEntry.Id, currentQuote.Id);
        
        Test.stopTest();
    }
}
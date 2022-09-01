/**
 * @File Name          : RL_PriceBookEntries_LEX_Test.cls
 * @Description        : This test class use for RL_PriceBookEntries_LEX.
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 26/04/2020
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    26/04/2020   fsuraitawala@addonblue.com     Initial Version
**/
@isTest
private class RL_PriceBookEntries_LEX_Test {
    
    /****************************************/
    @TestSetup
    static void setupTestData() {
        TestDataFactory.createTriggerSettingsEntry();
        
        //******* Pricebook *******//
        Pricebook2 testPricebook = TestDataFactory.createPricebook();
        
        //******* Product *******//
        List<Product2> lstProduct = new List<Product2>();
        
        Product2 objProduct = TestDataFactory.createProduct('Test Product 1', 'Product', 'Transportation', null, testPricebook.Id);
        lstProduct.add(objProduct);
        
        lstProduct = Utility.processRecords(lstProduct, 'insert');
        
        //******* PricebookEntry *******//
        List<PricebookEntry> stdPriceBookEntries = new List<PricebookEntry>();
        
        PricebookEntry objStdPriceBook = TestDataFactory.createPricebookEntry(objProduct, Test.getStandardPricebookId());
        stdPriceBookEntries.add(objStdPriceBook);
        
        PricebookEntry objPriceBook = TestDataFactory.createPricebookEntry(objProduct, testPricebook.Id);
        stdPriceBookEntries.add(objPriceBook);
        
        stdPriceBookEntries = Utility.processRecords(stdPriceBookEntries, 'insert');
    }
    
    /****************************************/
    @isTest
    static void testRunOne() {
        Product2 currentProduct = [Select Id FROM Product2 WHERE RecordType.Name = 'Product' LIMIT 1];
        
        Test.startTest();
        RL_PriceBookEntries_LEX.getPriceBookEntries(currentProduct.Id);
        Test.stopTest();
    }
}
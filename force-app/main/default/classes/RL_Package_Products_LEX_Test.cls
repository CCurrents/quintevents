/**
 * @File Name          : RL_Package_Products_LEX_Test.cls
 * @Description        : This test class use for RL_Package_Products_LEX.
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/8/2020, 4:02:55 AM
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    26/04/2020   fsuraitawala@addonblue.com     Initial Version
**/
@isTest
private class RL_Package_Products_LEX_Test {
    
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
        Product2 objProduct = TestDataFactory.createProduct('Test Package Product', 'Package', 'Package', lstParentPackage[0].Id, testPricebook.Id);
        lstProduct.add(objProduct);
        
        Product2 objProduct1 = TestDataFactory.createProduct('Test Product 1', 'Product', 'Transportation', null, testPricebook.Id);
        lstProduct.add(objProduct1);
        
        Product2 objProduct2 = TestDataFactory.createProduct('Test Product 2', 'Product', 'Transportation', null, testPricebook.Id);
        lstProduct.add(objProduct2);
        
        lstProduct = Utility.processRecords(lstProduct, 'insert');
        
        List<PricebookEntry> stdPriceBookEntries = new List<PricebookEntry>();
        
        PricebookEntry objStdPriceBook = TestDataFactory.createPricebookEntry(objProduct, Test.getStandardPricebookId());
        stdPriceBookEntries.add(objStdPriceBook);
        
        PricebookEntry objStdPriceBook1 = TestDataFactory.createPricebookEntry(objProduct1, Test.getStandardPricebookId());
        stdPriceBookEntries.add(objStdPriceBook1);
        
        PricebookEntry objStdPriceBook2 = TestDataFactory.createPricebookEntry(objProduct2, Test.getStandardPricebookId());
        stdPriceBookEntries.add(objStdPriceBook2);
        
        PricebookEntry objPriceBook = TestDataFactory.createPricebookEntry(objProduct, testPricebook.Id);
        stdPriceBookEntries.add(objPriceBook);
        
        PricebookEntry objPriceBook1 = TestDataFactory.createPricebookEntry(objProduct1, testPricebook.Id);
        stdPriceBookEntries.add(objPriceBook1);
        
        PricebookEntry objPriceBook2 = TestDataFactory.createPricebookEntry(objProduct2, testPricebook.Id);
        stdPriceBookEntries.add(objPriceBook2);
        
        stdPriceBookEntries = Utility.processRecords(stdPriceBookEntries, 'insert');
        
        //******* Products_Bundle__c *******//
        List<Products_Bundle__c> lstBundle = new List<Products_Bundle__c>();
        
        Products_Bundle__c objBundle = TestDataFactory.createProductBundle(objProduct1.Id, objProduct.Id, 'Package Product');
        lstBundle.add(objBundle);
        
        lstBundle= Utility.processRecords(lstBundle, 'insert');
    
    }
    
    /****************************************/
    @isTest
    static void testRunOne() {
        Product2 PackageProduct = [Select Id FROM Product2 WHERE RecordType.Name = 'Package' LIMIT 1];
        
        Test.startTest();
        List<SW_Utility_LEX.productListWrapper> lstProductWrapper = RL_Package_Products_LEX.fetchProductWrapper(PackageProduct.Id);
        
        if(lstProductWrapper != null && lstProductWrapper.size() > 0) {
            lstProductWrapper [0].isChecked = true;
            List<Products_Bundle__c> lstProductBundle = RL_Package_Products_LEX.AddProductsBundles(lstProductWrapper, PackageProduct.Id);
            
            System.assertEquals(lstProductBundle[0].Id != null, true);
            System.assertEquals(lstProductBundle[0].Parent_Product__c, PackageProduct.Id);
        }
        
        RL_Package_Products_LEX.fetchProductWrapper(PackageProduct.Id);
        RL_Package_Products_LEX.AddProductsBundles(null, null);
        SW_Utility_LEX.productListWrapper obj = new SW_Utility_LEX.productListWrapper();
        
        Test.stopTest();
    }
}
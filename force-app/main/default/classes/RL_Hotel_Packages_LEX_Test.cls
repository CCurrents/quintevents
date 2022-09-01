/**
 * @File Name          : RL_Hotel_Packages_LEX_Test.cls
 * @Description        : This test class use for RL_Hotel_Packages_LEX.
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 15/6/2020, 11:59:58 am
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    26/04/2020   fsuraitawala@addonblue.com     Initial Version
**/
@isTest
private class RL_Hotel_Packages_LEX_Test {
    
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
        
        Product2 objProduct1 = TestDataFactory.createProduct('Test Package Product', 'Package', 'Package', lstParentPackage[0].Id, testPricebook.Id);
        lstProduct.add(objProduct1);
        
        Product2 objProduct2 = TestDataFactory.createProduct('Test Hotel', 'Hotel', 'Hospitality', null, testPricebook.Id);
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
        
        Products_Bundle__c objBundle = TestDataFactory.createProductBundle(objProduct2.Id, objProduct.Id, 'Package Hotel');
        lstBundle.add(objBundle);
        
        lstBundle= Utility.processRecords(lstBundle, 'insert');
    
    }
    
    /****************************************/
    @isTest
    static void testRunOne() {
        Product2 hotelProduct = [Select Id FROM Product2 WHERE RecordType.Name = 'Hotel'];
        
        Test.startTest();
        List<SW_Utility_LEX.productListWrapper> lstProductWrapper = RL_Hotel_Packages_LEX.fetchProductWrapper(hotelProduct.Id);
        
        if(lstProductWrapper != null && lstProductWrapper.size() > 0) {
            lstProductWrapper [0].isChecked = true;
            List<Products_Bundle__c> lstProductBundle = RL_Hotel_Packages_LEX.AddProductsBundles(lstProductWrapper, hotelProduct.Id);
            
            System.assertEquals(lstProductBundle[0].Id != null, true);
            System.assertEquals(lstProductBundle[0].Child_product__c, hotelProduct.Id);
        }
        
        RL_Hotel_Packages_LEX.fetchProductWrapper(hotelProduct.Id);
        RL_Hotel_Packages_LEX.AddProductsBundles(null, null);
        SW_Utility_LEX.productListWrapper obj = new SW_Utility_LEX.productListWrapper();
        
        Test.stopTest();
    }
}
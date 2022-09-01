/**
 * @File Name          : ProductTriggerTest.cls
 * @Description        : Test class for code coverage of PricebookTrigger classes
 * @Author             : fsuraitawalal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 06-21-2021
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    17/3/2020   fsuraitawalal@addonblue.com     Initial Version
**/
@isTest
private class ProductTriggerTest {
     /****************************************/
    @TestSetup
    static void setupTestData() {
        TestDataFactory.createTriggerSettingsEntry();
        
        //******* Pricebook *******//
        Pricebook2 testPricebook = TestDataFactory.createPricebook();
        
        Pricebook2 testPricebook1 = TestDataFactory.createPricebook();
        testPricebook1.Name = 'Standard Price Book';
        update testPricebook1;
        
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
        objProduct.Price__c = 0;
        lstProduct.add(objProduct);
        
        Product2 objProduct1 = TestDataFactory.createProduct('Test Product', 'Product', 'Transportation', null, testPricebook.Id);
        objProduct1.Price__c = 0;
        lstProduct.add(objProduct1);
        
        Product2 objProduct2 = TestDataFactory.createProduct('Test Product2', 'Product', 'Transportation', null, testPricebook.Id);
        objProduct2.Price__c = 0;
        lstProduct.add(objProduct2);
        
        lstProduct = Utility.processRecords(lstProduct, 'insert');
        
        List<Products_Bundle__c> lstBundle = new List<Products_Bundle__c>();
        
        Products_Bundle__c objBundle = TestDataFactory.createProductBundle(objProduct1.Id, objProduct.Id, 'Package Product');
        lstBundle.add(objBundle);
        
        Products_Bundle__c objBundle1 = TestDataFactory.createProductBundle(objProduct2.Id, objProduct.Id, 'Package Product');
        lstBundle.add(objBundle1);
        
        lstBundle= Utility.processRecords(lstBundle, 'insert');
    }
    
    /**
    * @description  : Method for after Insert Event of trigger
    * @author       : fsuraitawala@addonblue.com
    * @return       : void
    **/
    @isTest static void testMethod_one() {
        List<Product2> lstProduct = new List<Product2>([Select Id FROM Product2 WHERE RecordType.Name = 'Product']);
        for(Product2 objProduct: lstProduct) {
            objProduct.Total_Inventory__c = 1;
            objProduct.Price__c = 100;
            objProduct.Cost_for_Available_Product__c = 100;
        }
        Utility.processRecords(lstProduct, 'update');
    }
    
    /**
    * @description  : Method for after Insert Event of trigger
    * @author       : fsuraitawala@addonblue.com
    * @return       : void
    **/
    @isTest static void testMethod_two() {
        List<Product2> lstProduct = new List<Product2>([Select Id FROM Product2 WHERE RecordType.Name = 'Product']);
        for(Product2 objProduct: lstProduct) {
            objProduct.Available__c = false;
        }
        Utility.processRecords(lstProduct, 'update');
        
        Utility.processRecords(lstProduct, 'delete');
    }
 }
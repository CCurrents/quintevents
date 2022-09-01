/**
 * @File Name          : RL_Hotel_Packages_LEX_Test.cls
 * @Description        : This test class use for RL_Hotel_Packages_LEX.
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/8/2020, 4:00:44 AM
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    26/04/2020   fsuraitawala@addonblue.com     Initial Version
**/
@isTest
private class RL_BundleProduct_Table_LEX_Test {
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
        
        //******* Products_Bundle__c *******//
        List<Products_Bundle__c> lstBundle = new List<Products_Bundle__c>();
        
        Products_Bundle__c objBundle = TestDataFactory.createProductBundle(objProduct2.Id, objProduct.Id, 'Package Hotel');
        lstBundle.add(objBundle);
        
        lstBundle= Utility.processRecords(lstBundle, 'insert');
    }
    
    /****************************************/
    @isTest
    static void testRunOne() {
        List<Products_Bundle__c> lstBundle = [Select Id, Child_Product__c, Parent_Product__c FROM Products_Bundle__c];
        RL_BundleProduct_Table_LEX.getProductsBundles(lstBundle[0].Parent_Product__c, 'Hotel Transportation', true);
        RL_BundleProduct_Table_LEX.getProductsBundles(lstBundle[0].Parent_Product__c, 'Package Product', false);
        
        RL_BundleProduct_Table_LEX.deleteBundleProductRecords(lstBundle[0].Parent_Product__c, 'Package Hotel', true, lstBundle);
    }
}
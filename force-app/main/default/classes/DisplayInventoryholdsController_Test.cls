/**
 * @File Name          : DisplayInventoryholdsController_Test.cls
 * @Description        : This class is test class for DisplayInventoryholdsController.cls
 * @Author             : sagarj@addonblue.com
 * @Group              : 
 * @Last Modified By   : 
 * @Last Modified On   : 
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    26/09/2021   sagarj@addonblue.com     Initial Version
**/
@isTest
public with sharing class DisplayInventoryholdsController_Test {
    @TestSetup
    static void setupTestData() {
        TestDataFactory.createTriggerSettingsEntry();
        
        //******* Pricebook *******//
        Pricebook2 testPricebook = TestDataFactory.createPricebook();
        
        List<Parent_Package__c> lstParentPackage = TestDataFactory.createParentPackage(1, true, testPricebook.Id);
        
        //******* Product *******//
        List<Product2> lstProduct = new List<Product2>();
        Product2 objProduct = TestDataFactory.createProduct('Test Package Product', 'Package', 'Package', lstParentPackage[0].Id, testPricebook.Id);
        lstProduct.add(objProduct);
     
        
        lstProduct = Utility.processRecords(lstProduct, 'insert');
        
        Inventory_Transaction__c it = new Inventory_Transaction__c ();
        it.product__c = lstProduct[0].id;
        insert it;
      
    }
    
    /****************************************/
    @isTest
    static void testRunOne() {
        List<Product2> productlist = [Select Id FROM product2];
        List<Inventory_Transaction__c> inventorytranscationlist = [select id from Inventory_Transaction__c];
        DisplayInventoryholdsController.getInventoryHolds(productlist[0].Id);
        DisplayInventoryholdsController.fetchfieldconfiguration('InventoryHoldDisplayFields');
        DisplayInventoryholdsController.getrecordtypeid('Inventory_Hold');
        DisplayInventoryholdsController.deleteInventoryHolds(productlist[0].Id,inventorytranscationlist);

    }
}
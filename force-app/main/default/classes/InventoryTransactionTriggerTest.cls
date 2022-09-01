/**
 * @File Name          : PricebookTriggerTest.cls
 * @Description        : Test class for code coverage of PricebookTrigger classes
 * @Author             : fsuraitawalal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 03-04-2022
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    17/3/2020   fsuraitawalal@addonblue.com     Initial Version
**/
@isTest
private class InventoryTransactionTriggerTest {
    
    /**
    * @description  : Method for after Insert Event of trigger
    * @author       : fsuraitawala@addonblue.com
    * @return       : void
    **/
    @isTest static void testMethod_one() {
        TestDataFactory.createTriggerSettingsEntry();
        List<PriceBook2> lstPriceBook = TestDataFactory.createPricebook(1, 'Test Pricebook');
        List<Product2> lstProduct = TestDataFactory.createProduct(1, 'Product');
        
        TestDataFactory.createInventoryTransaction(2, 'Inventory Load', lstProduct[0].Id);
        List<Inventory_Transaction__c> lstInventories = [Select Id FROM Inventory_Transaction__c];
        if(lstInventories.size() > 0){
            update lstInventories;
        }
        if(lstInventories.size() > 0){
            delete lstInventories;
        }
    }
}
/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 04-18-2022
 * @last modified by  : fsuraitawala@addonblue.com
**/
@isTest
public with sharing class ReleaseInventoryBatchClassTest {
    public ReleaseInventoryBatchClassTest() {
    }
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void test1(){

        //******* Pricebook *******//
        Pricebook2 testPricebook = TestDataFactory.createPricebook();
        
        //******* Parent Package *******//
        List<Parent_Package__c> lstParentPackage = TestDataFactory.createParentPackage(1, true, testPricebook.Id);

        //******* Product *******//
        List<Product2> lstProduct = new List<Product2>();
        Product2 objProduct = TestDataFactory.createProduct('Test Package Product', 'Package', 'Package', lstParentPackage[0].Id, testPricebook.Id);
        lstProduct.add(objProduct);
        Product2 objProduct1 = TestDataFactory.createProduct('Test Product', 'Product', 'Transportation', null, testPricebook.Id);
        lstProduct.add(objProduct1);
        lstProduct = Utility.processRecords(lstProduct, 'insert');

        //******* Inventory Transaction *******//
        Id recordTypeId = [Select Id,Name From RecordType Where sObjectType='Inventory_Transaction__c' and Name='Inventory Hold'].Id;
        Inventory_Transaction__c objTransaction = new Inventory_Transaction__c(
            Quantity__c = 50,
            Product__c = lstProduct[0].Id,
            Cost_Per_Quantity__c = 100,
            recordTypeId = recordTypeId,
            Hold_Release_Date__c=System.today());
        Utility.processRecords(objTransaction, 'insert');

        ReleaseInventoryBatchClass batch = new ReleaseInventoryBatchClass('5');
        ID batchprocessid = Database.executeBatch(batch);
    }
}
/**
 * @File Name          : ScheduledInventoryholdemailClass_Test.cls
 * @Description        : This is test class for apex class - ScheduledInventoryholdemailClass
 * @Author             : sagarj@addonblue.com
 * @Group              : 
 * @Last Modified By   : 
 * @Last Modified On   : 
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    01/10/2021   sagarj@addonblue.com     Initial Version
**/
@istest
public with sharing class ScheduledInventoryholdemailClass_Test {
 
    @isTest static void testone() {
         TestDataFactory.createTriggerSettingsEntry();
        
        //******* Pricebook *******//
        Pricebook2 testPricebook = TestDataFactory.createPricebook();
        
        List<Parent_Package__c> lstParentPackage = TestDataFactory.createParentPackage(1, true, testPricebook.Id);
        
        //******* Product *******//
        List<Product2> lstProduct = new List<Product2>();
        Product2 objProduct = TestDataFactory.createProduct('Test Package Product', 'Package', 'Package', lstParentPackage[0].Id, testPricebook.Id);
        lstProduct.add(objProduct);
     
        
        lstProduct = Utility.processRecords(lstProduct, 'insert');

		opportunity opp = new opportunity();
        opp.name = 'test opp';
        opp.stagename = 'Sales Qualified Lead';
        opp.closedate = system.today();
        insert opp;
        
        Quote qt = new Quote ();
        qt.name = 'test quote';
        qt.opportunityid = opp.id;
        insert qt;        
        
        Id recordTypeId =  Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByDeveloperName().get('Inventory_Hold').getRecordTypeId();
        Inventory_Transaction__c it = new Inventory_Transaction__c ();
        it.product__c = lstProduct[0].id;
        it.recordTypeId = recordTypeId;
        
        Inventory_Transaction__c it1 = new Inventory_Transaction__c ();
        it1.product__c = lstProduct[0].id;
        it1.recordTypeId = recordTypeId;
        it1.quote__c = qt.id;
        
        List<Inventory_Transaction__c> inventorylist = new List<Inventory_Transaction__c> ();
        inventorylist.add(it);
	    inventorylist.add(it1);        
        insert inventorylist;
        
        
        
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test Check12', sch, new ScheduledInventoryholdemailClass());       
        
        InventoryHoldBatchClass  batch = new InventoryHoldBatchClass();
        database.executebatch(batch,200);
    }
}
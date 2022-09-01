/**
 * @File Name          : ScheduledDailyProductUpdateTest.cls
 * @Description        : test class for the ScheduledDailyProductUpdate controller
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 11-18-2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    04/30/2020     mpatel@addonblue.com       Initial Version
**/
@isTest
private with sharing class ScheduledDailyProductUpdateTest {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }
    @isTest static void hourlyProductFirstTestExecution() {
        Pricebook2 pricebook = TestDataFactory.createPricebook(1,'TB',false)[0];
        pricebook.GPT_Event_Id__c = '35467';
        pricebook.End_date__c = system.today();
        pricebook.gpe_event__c = true;
        Utility.processRecords(pricebook, 'insert');

        Product2 productObj = TestDataFactory.createProduct(1, 'Product', pricebook.Id, false)[0];
        productObj.GPT_Article_Id__c = '89073';
        productObj.Total_Inventory__c = 123;
        Utility.processRecords(productObj, 'insert');
        
        Inventory_Transaction__c inventoryObj = new Inventory_Transaction__c();
        inventoryObj.Quantity__c = 10;
        inventoryObj.Product__c = productObj.Id;
        Utility.processRecords(productObj, 'insert');
         
        product2 product = [Select Id,GPT_Article_Id__c,Primary_Price_Book__r.GPT_Event_Id__c,Primary_Price_Book__r.GPT_Price_Markup_Percentage__c,GPT_Gross_Price__c,Price__c,Primary_Price_Book__r.End_date__c, Total_Inventory__c, Current_Inventory__c,
                            Name,(Select id,Quantity__c,Product__c from Inventory_Transactions__r) from Product2 limit 1];
        Map<String, Product2> proMap = new Map<String, Product2>();
        product.Total_Inventory__c = 123;
        proMap.put('89073', product);

        ScheduledDailyProductUpdate sh1 = new ScheduledDailyProductUpdate();
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test Check', sch, sh1);
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GPTJson');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        String query = 'Select Id, GPT_Event_Id__c from PriceBook2 where IsActive = true and GPE_Event__c = true  and GPT_Event_Id__c != null and End_date__c >=: toDate';

        ProductUpdateBatchClass batch = new ProductUpdateBatchClass(query);
        ID batchprocessid = Database.executeBatch(batch);

    }
}
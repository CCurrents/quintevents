/**
 * @File Name          : CreatePBSixHourlyQueueableClassTest.cls
 * @Description        : test class for the PriceBookScheduler controller
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : rama.krishna@addonblue.com
 * @Last Modified On   : 12/15/2021, 3:23:57 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/22/2020   mpatel@addonblue.com     Initial Version
**/
@isTest 
private with sharing class CreatePBTwelveHourlyQueueableClassTest{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void PBFirstTestExecution() {
        List<Product2> productList = TestDataFactory.createProduct(1);
        PriceBook2 priceBook = TestDataFactory.CreatePriceBook(1,'Test PB',false)[0];
        priceBook.GPE_Event__c = true;
        priceBook.GPT_Event_Id__c = '12356';
        Utility.processRecords(priceBook, 'insert');
        PriceBook2 priceBook1 = TestDataFactory.CreatePriceBook(1,'Test PB',false)[0];
        priceBook1.GPE_Event__c = false;
        priceBook1.GPT_Event_Id__c = '89073';
        Utility.processRecords(priceBook1, 'insert');
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GPTJson');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Map<Integer, Product2> productMap = new Map<Integer, Product2>();
        productMap.put(1,productList[0]);
        Map<Integer, Inventory_Transaction__c> transactionMap = new Map<Integer, Inventory_Transaction__c>();
        Inventory_Transaction__c transactionObj = new Inventory_Transaction__c();
        transactionObj.Quantity__c = 1;
        Utility.processRecords(transactionObj, 'insert');
        System.assert(true, transactionObj != null);
        transactionMap.put(1,transactionObj);
        System.enqueueJob(new CreatePBTwelveHourlyQueueableClass());
        System.enqueueJob(new CreatePBTwelveHourlyQueueableClass(productMap,transactionMap));
        }
        @isTest static void PBFirstTestExecution1() {
        List<Product2> productList = TestDataFactory.createProduct(1);
        PriceBook2 priceBook = TestDataFactory.CreatePriceBook(1,'Test PB',false)[0];
        priceBook.GPE_Event__c = true;
        priceBook.GPT_Event_Id__c = '12356';
        priceBook.Start_date__C = system.today();
        priceBook.End_date__C = system.today();
        Utility.processRecords(priceBook, 'insert');
        PriceBook2 priceBook1 = TestDataFactory.CreatePriceBook(1,'Test PB',false)[0];
        priceBook1.GPE_Event__c = false;
        priceBook1.GPT_Event_Id__c = '89073';
        Utility.processRecords(priceBook1, 'insert');
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      
        Map<Integer, Product2> productMap = new Map<Integer, Product2>();
        productMap.put(1,productList[0]);
        Map<Integer, Inventory_Transaction__c> transactionMap = new Map<Integer, Inventory_Transaction__c>();
        Inventory_Transaction__c transactionObj = new Inventory_Transaction__c();
        transactionObj.Quantity__c = 1;
        Utility.processRecords(transactionObj, 'insert');
        System.assert(true, transactionObj != null);
        transactionMap.put(1,transactionObj);
        Test.setMock(HttpCalloutMock.class, mock);
        Set<String> pricebookIdSet = new Set<String>();
        pricebookIdSet.add(priceBook.GPT_Event_Id__c);
        System.enqueueJob(new CreatePBTwelveHourlyQueueableClass());
        System.enqueueJob(new CreatePBTwelveHourlyQueueableClass(productMap,transactionMap));
        }
}
/**
 * @File Name          : CreatePBSixHourlyQueueableClassTest.cls
 * @Description        : test class for the PriceBookScheduler controller
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 4/22/2020, 3:23:57 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/22/2020   mpatel@addonblue.com     Initial Version
**/
@isTest
private with sharing class CreatePBSixHourlyQueueableClassTest{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void PBFirstTestExecution() {
        List<Product2> productList = TestDataFactory.createProduct(1);
        PriceBook2 priceBook = TestDataFactory.CreatePriceBook(1,'Test PB',false)[0];
        priceBook.GPE_Event__c = true;
        priceBook.GPT_Event_Id__c = '12356';
        Utility.processRecords(priceBook, 'insert');

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GPTJson');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        Set<String> pricebookIdSet = new Set<String>();
        pricebookIdSet.add(priceBook.GPT_Event_Id__c);
        System.enqueueJob(new CreatePBSixHourlyQueueableClass(pricebookIdSet));
        System.enqueueJob(new CreatePBSixHourlyQueueableClass(productList,productList));
    }
}
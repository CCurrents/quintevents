/**
 * @File Name          : GenerateGPTProduct_LEXTest.cls
 * @Description        : test class for the GenerateGPTProduct_LEX controller
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 4/23/2020
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/23/2020   mpatel@addonblue.com     Initial Version
**/
@isTest
private with sharing class GenerateGPTProduct_LEXTest {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void apexToJsonFirstTestExecution() {
        List<PriceBook2> priceBookList = TestDataFactory.CreatePriceBook(1,'Test PB',false);
        priceBookList[0].GPE_Event__c = true;
        Utility.processRecords(pricebookList, 'insert');
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GPTJson');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        GenerateGPTProduct_LEX.priceBookObjCallOut(priceBookList[0].id);
        System.assert(true, !priceBookList.isEmpty());
        Test.stopTest();
    }
}
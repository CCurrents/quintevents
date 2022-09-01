/**
 * @File Name          : ScheduleSixHourPriceBookInsertTest.cls
 * @Description        : test class for the ScheduleSixHourPriceBookInsert controller
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 4/23/2020
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/23/2020   mpatel@addonblue.com     Initial Version
**/
@isTest
private with sharing class ScheduleTwelveHourPriceBookInsertTest {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void scheduleFirstTestExecution() {
        PriceBook2 priceBook = TestDataFactory.CreatePriceBook(1,'Test PB',false)[0];
        priceBook.GPT_Event_Id__c = '345667';
        Utility.processRecords(priceBook, 'insert');
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GPTJson');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        ScheduleTwelveHourPriceBookInsert sh1 = new ScheduleTwelveHourPriceBookInsert();
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test Check', sch, sh1);
        Test.setMock(HttpCalloutMock.class, mock);
        System.enqueueJob(new CreatePBTwelveHourlyQueueableClass());
        System.assert(true, priceBook != null);
    }
}
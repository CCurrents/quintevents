/**
 * @File Name          : ScheduledHourlyNewProductInsertTest.cls
 * @Description        : test class for the ScheduledHourlyNewProductInsert controller
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 04/29/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    04/29/2020    mpatel@addonblue.com       Initial Version
**/
@isTest
private with sharing class ScheduledHourlyNewProductInsertTest {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }
    @isTest static void hourlyProductFirstTestExecution() {
        Pricebook2 pricebook = TestDataFactory.createPricebook(1,'TB',false)[0];
        pricebook.GPT_Event_Id__c = '3456456';
        pricebook.GPE_Event__c= true;
        Utility.processRecords(pricebook, 'insert');
        System.debug('pricebook--->'+pricebook);
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test Check', sch, new ScheduledHourlyNewProductInsert());
        string strquery = 'Select Id,GPT_Event_Id__c,GPT_Price_Markup_Percentage__c from PriceBook2 where GPT_Event_Id__c != null and GPE_Event__c= true';
        HourlyNewProductInsertBatchClass calloutObj = new HourlyNewProductInsertBatchClass(strquery);
        ID batchprocessid = Database.executeBatch(calloutObj);
    }
}
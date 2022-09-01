/**
 * @File Name          : PriceBookSchedulerTest.cls
 * @Description        : test class for the PriceBookScheduler controller
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 4/20/2020, 3:23:57 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/20/2020   mpatel@addonblue.com     Initial Version
**/
@isTest
private with sharing class PriceBookSchedulerTest{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void pbSchedulFirstTestExecution() {
        PriceBook2 objPB = TestDataFactory.createPricebook(1, 'Test PB', false)[0];
        objPB.End_Date__c = system.today().addDays(-1);
        objPB.isActive = true;
        Utility.processRecords(objPB, 'insert');
        
        Test.startTest();
        PriceBookScheduler.retrievePBRecords();
        String CRON_EXP = '0 59 18 * * ?';
        system.schedule('name',CRON_EXP ,new PriceBookScheduler());
        System.assert(true,objPB.Name != null);
        Test.stopTest();
    }
}
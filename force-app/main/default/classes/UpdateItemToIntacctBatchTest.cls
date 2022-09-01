/**
 * @File Name          : UpdateItemToIntacctBatchTest.cls
 * @Description        : test class for the UpdateItemToIntacctBatch controller
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 5/13/2020
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    5/13/2020   kchavda@addonblue.com     Initial Version
**/
@isTest
private class UpdateItemToIntacctBatchTest{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    
    @isTest static void test1() {
        Pricebook2 pb = TestDataFactory.createPricebook(1,'Pb894test',false)[0];
        pb.Legacy_Id__c = TestDataFactory.createAccount().id;
        Utility.processRecords(pb, 'insert');
        Pricebook2 pbook = [select id,Legacy_Id__c,Legacy_15_Digit_Id__c from pricebook2 where id=: pb.id];       
        set<Id> setSFDCId = new set<Id>{pbook.id};
        map<Id,string> mapsfdcIdwithRecNo = new map<Id,string>{pbook.id=>'205'};
        string strquery = 'select Id,Legacy_15_Digit_Id__c,Name from pricebook2 where id in:setSFDCId';
        UpdateItemToIntacctBatch objbatch = new UpdateItemToIntacctBatch(strquery,mapsfdcIdwithRecNo,setSFDCId);
        ID batchprocessid = Database.executeBatch(objbatch);       
    }
}
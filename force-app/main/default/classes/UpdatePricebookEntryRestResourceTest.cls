/**
 * @File Name          : UpdatePricebookEntryBatchTest.cls
 * @Description        : test class for the UpdatePricebookEntryRestResource controller
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 4/20/2020, 3:23:57 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/20/2020   mpatel@addonblue.com     Initial Version
**/
@isTest 
private with sharing class UpdatePricebookEntryRestResourceTest {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void priceBookFirstTestExecution() {
        List<PricebookEntry> listOfPricebookEntry = TestDataFactory.CreatePricebookEntry(2);
        RestRequest request = new RestRequest();
        request.requestUri = '/runUpdatePricebookEntryRestBatch';
        request.httpMethod = 'POST';
        RestContext.request = request;
        String strId = UpdatePricebookEntryRestResource.UpdatePricebookEntryMethod();
        
        DatedConversionRate dateRate = new DatedConversionRate();
        dateRate.StartDate = system.today();
        Utility.processRecords(dateRate, 'insert');
        
        String pricebookEntryList;    
        pricebookEntryList = 'select id,UnitPrice,Product2Id,Product2.Price__c,CurrencyIsoCode from PricebookEntry';
        Map<string,double>  isoCodeMap = new Map<string,double>();
        Set<String> code = new Set<String>();
        isoCodeMap.put('USD', 0.15);
        code.add('USD');
        UpdatePricebookEntryBatch newTopicsUpdate = new UpdatePricebookEntryBatch(pricebookEntryList, isoCodeMap, code);
        ID batchprocessid = Database.executeBatch(newTopicsUpdate);
        System.assert(true, strId != null);
    }
}
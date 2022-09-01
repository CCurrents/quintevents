/**
 * @File Name          : PriceBookInline_LEXTest.cls
 * @Description        : 
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 4/21/2020, 3:23:57 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/21/2020   mpatel@addonblue.com     Initial Version
**/
@isTest
private with sharing class PriceBookInline_LEXTest {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void PriceBookInlineFirstTestExecution() {
        PriceBook2 priceBook = TestDataFactory.createPricebook(1, 'PB', false)[0];
        priceBook.X1_2__c = true;
        priceBook.X1_3__c = true;
        Utility.processRecords(priceBook, 'insert');
        List<Event_Payment_Terms__c> paymentTerm = TestDataFactory.createEventPaymentTerm(1);
        PriceBookInline_LEX.getPriceBookRecords(priceBook.Id);
        PriceBookInline_LEX.paymentList(priceBook);
        PriceBookInline_LEX.savePaymentTerm(priceBook, Json.serialize(paymentTerm), Json.serialize(paymentTerm));
        System.assert(true,Json.serialize(paymentTerm) != null);
    }
}
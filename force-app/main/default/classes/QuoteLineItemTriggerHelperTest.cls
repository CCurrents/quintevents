/**
 * @description       : 
 * @author            : fsuraitawala@addonblue.com
 * @group             : 
 * @last modified on  : 06-29-2021
 * @last modified by  : fsuraitawala@addonblue.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   06-29-2021   fsuraitawala@addonblue.com   Initial Version
**/
@isTest public class QuoteLineItemTriggerHelperTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();	
    }
    
    @isTest static void test1(){
        QuoteLineItem objQLI = TestDataFactory.createQuoteLineItem();
        System.debug('objQLI-->'+objQLI);
        
        List<QuoteLineItem> lstQLI = Utility.processRecords(objQLI, 'update');
        system.debug('lstQLI-->'+lstQLI);
        Map<Id,QuoteLineItem> mapQuote = new Map<Id,QuoteLineItem>();
        for(QuoteLineItem objQuote: lstQLI){
            mapQuote.put(objQuote.Id,objQuote);
        }
        system.debug('mapQuote-->'+mapQuote);
        //QuoteLineItemTriggerHelper objQLITrigger = new QuoteLineItemTriggerHelper();
        //objQLITrigger.calculateRewardPoints(lstQLI,mapQuote);
        
    }
    @isTest static void test2(){
        QuoteLineItem objQLI = TestDataFactory.createQuoteLineItem();
        Utility.processRecords(objQLI, 'delete');
    }
    @isTest static void test3(){
        QuoteLineItem objQLI = TestDataFactory.createQuoteLineItem();
        System.debug('objQLI-->'+objQLI);
        objQLI.Quantity = 2;
        objQLI.Record_Type__c = 'Package';
        Utility.processRecords(objQLI, 'update');
        List<QuoteLineItem> lstQLI = Utility.processRecords(objQLI, 'update');
        system.debug('lstQLI-->'+lstQLI);

        Utility.processRecords(lstQLI, 'delete');
    }   
}
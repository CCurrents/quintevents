/**
 * @File Name          : SW_Product_Billing_LEX_Test.cls
 * @Description        : 
 * @Author             : jthakkar@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 03-30-2021
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/27/2020   jthakkar@addonblue.com     Initial Version
**/
@isTest public with sharing class SW_Product_Billing_LEX_Test {
    
    @isTest static void test1(){        
        TestDataFactory.createTriggerSettingsEntry();
        Trigger_Settings__c triggerSetting = TestDataFactory.createTriggerSettingsEntry('Quote', 0, true);        
        List<Payment_Term__c> lstPaymentTerm = new List<Payment_Term__c>();
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm(100);
        lstPaymentTerm.add(payTerm);
        Id quoteId = payTerm.Quote__c;
		system.debug('###quoteId=='+quoteId);
        String paymentTerm = '100%'; 
        Test.startTest();
        SW_Product_Billing_LEX.fetchRecordTypeId();
        SW_Product_Billing_LEX.saveOpportunityPaymentTerm(quoteId,JSON.serialize(lstPaymentTerm),paymentTerm,true,'Credit Card');
        SW_Product_Billing_LEX.fetchQuoteSubtotal(quoteId);
        SW_Product_Billing_LEX.fetchEventPaymentTerms(quoteId);
        SW_Product_Billing_LEX.fetchEventPaymentTermRecords(quoteId);
        SW_Product_Billing_LEX.fetchOppPaymentTermRecords(quoteId);
        SW_Product_Billing_LEX.fetchTotalOfOppPaymentTermRecords(quoteId);
        SW_Product_Billing_LEX.fetchAmountForDupQuote(quoteId);
        SW_Product_Billing_LEX.fetchPaymentStatusForDupQuote(quoteId);
        SW_Product_Billing_LEX.fetchEventPaymentTermHighestDate(quoteId);
        SW_Product_Billing_LEX.savePaymentMethodQuote(quoteId, 'Credit Card');
        Quote quote = SW_Product_Billing_LEX.getTotalCreditFromAccount(quoteId);
        delete triggerSetting;
        Test.stopTest();
        //System.assertEquals(1, [Select Id from Order where QuoteId = :objQuote.Id].size());
    }
}
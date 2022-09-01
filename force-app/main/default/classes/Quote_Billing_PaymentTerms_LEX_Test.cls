/**
 * @File Name          : SW_Product_Billing_LEX_Test.cls
 * @Description        : 
 * @Author             : jthakkar@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 7/2/2020, 4:50:02 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/27/2020   jthakkar@addonblue.com     Initial Version
**/
@isTest public with sharing class Quote_Billing_PaymentTerms_LEX_Test {
    
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
        Quote_Billing_PaymentTerms_LEX.saveOpportunityPaymentTerm(quoteId,JSON.serialize(lstPaymentTerm),paymentTerm,true,'Credit Card');
        Quote_Billing_PaymentTerms_LEX.fetchQuoteSubtotal(quoteId);
        Quote_Billing_PaymentTerms_LEX.fetchEventPaymentTerms(quoteId);
        Quote_Billing_PaymentTerms_LEX.fetchEventPaymentTermRecords(quoteId);
        Quote_Billing_PaymentTerms_LEX.fetchOppPaymentTermRecords(quoteId);
        Quote_Billing_PaymentTerms_LEX.fetchTotalOfOppPaymentTermRecords(quoteId);
        Quote_Billing_PaymentTerms_LEX.fetchAmountForDupQuote(quoteId);
        Quote_Billing_PaymentTerms_LEX.fetchPaymentStatusForDupQuote(quoteId);
        Quote_Billing_PaymentTerms_LEX.fetchEventPaymentTermHighestDate(quoteId);
        Quote_Billing_PaymentTerms_LEX.savePaymentMethodQuote(quoteId, 'Credit Card');
        Quote quote = Quote_Billing_PaymentTerms_LEX.getTotalCreditFromAccount(quoteId);
        delete triggerSetting;
        Test.stopTest();
        //System.assertEquals(1, [Select Id from Order where QuoteId = :objQuote.Id].size());
    }
}
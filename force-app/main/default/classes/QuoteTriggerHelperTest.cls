/**
 * @File Name          : QuoteTriggerHelperTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 12-21-2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    3/16/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest public with sharing class QuoteTriggerHelperTest {
    
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    
    @isTest static void test0(){
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        payTerm.Amount__c = 100;
        payTerm.Status__c = 'Passed';
        List<Quote> objQuote = [select Id, Status, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode from Quote where Id=: payTerm.Quote__c];
        for(Quote objQuo : objQuote){
            objQuo.Status = 'Signed - Approved';        
        }
        List<Quotelineitem> lstQli = TestDataFactory.createQuoteLineItem(1, objQuote[0].Id, true);
        Test.startTest();
        Utility.processRecords(objQuote, 'update');        
        Test.stopTest();
    }
    
    @isTest static void test1(){
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        payTerm.Amount__c = 100;
        payTerm.Status__c = 'Passed';
        //update payTerm;
        List<Quote> newobjQuote = new List<Quote>();
        List<Quote> objQuote = [select Id, Status, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode, Pricebook2Id from Quote where Id=: payTerm.Quote__c];
        for(Quote objQuo : objQuote){
            objQuo.Status = 'Signed - Approved';
            objQuo.Selected_Payment_Term__c = '100%';
            objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Description = 'Paid#100';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        
        List<Payment_Term__c> lstPaymentTerms = new List<Payment_Term__c>();
        lstPaymentTerms.add(payTerm);
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms, false);
    }
    
    @isTest static void test2(){        
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        payTerm.Amount__c = 100;        
        payTerm.Status__c = 'Passed';
        Trigger_Settings__c productTriggerSetting = Trigger_Settings__c.getInstance('Product2');  
        productTriggerSetting.Deactivate__c = true;
        update productTriggerSetting;   
        List<Quote> newobjQuote = new List<Quote>();
        List<Quote> objQuote = [select Id,GPE_Online_Order__c,Status, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode, Pricebook2Id from Quote where Id=: payTerm.Quote__c];
        List<PricebookEntry> lstPriceBookEntry = TestDataFactory.createPricebookEntry(1);
        triggerSetting = Trigger_Settings__c.getInstance('QuoteLineItem');  
           
        Test.startTest();
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        
        QuoteTriggerHelper.createShippingLineItem(objQuote, lstPriceBookEntry);        
        Test.stopTest();
    }
    
    @isTest static void test3(){
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;        
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        payTerm.Amount__c = 200;
        payTerm.Credit__c = true;
        payTerm.RecordTypeId = Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
        payTerm.Status__c = 'Passed';
        update payTerm;
        List<Quote> newobjQuote = new List<Quote>();
        List<Quote> objQuote = [select Id, Status, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode, Pricebook2Id from Quote where Id=: payTerm.Quote__c];
        List<Payment_Term__c> lstPaymentTerms = new List<Payment_Term__c>();
        lstPaymentTerms.add(payTerm);
        for(Quote objQuo : objQuote){
            objQuo.Status = 'Signed - Approved';
            objQuo.Selected_Payment_Term__c = '1/2';
            objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Description = 'Unpaid#100';
            //newobjQuote.add(objQuo);
        }
        Utility.processRecords(objQuote, 'update');
        QuoteTriggerHelper.savePaymentTerm(objQuote, lstPaymentTerms, false);
        
        for(Quote objQuo : objQuote){
            objQuo.Status = 'Signed - Approved';
            objQuo.Selected_Payment_Term__c = '1/2';
            objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Description = 'Partially Paid#100';
            //newobjQuote.add(objQuo);
        }
        Utility.processRecords(objQuote, 'update');
        QuoteTriggerHelper.savePaymentTerm(objQuote, lstPaymentTerms, false);
        
        for(Quote objQuo : objQuote){
            objQuo.Status = 'Signed - Approved';
            objQuo.Selected_Payment_Term__c = '1/2';
            objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Description = 'Partially Paid#-100';
            //newobjQuote.add(objQuo);
        }
        Utility.processRecords(objQuote, 'update');        
        QuoteTriggerHelper.savePaymentTerm(objQuote, lstPaymentTerms, false);
    }
    
    @isTest static void test4(){
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        payTerm.Amount__c = 100;
        List<Quote> newobjQuote = new List<Quote>();
        List<Quote> objQuote = [select Id, Status, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode, Pricebook2Id from Quote where Id=: payTerm.Quote__c];
        for(Quote objQuo : objQuote){
            objQuo.Status = 'Signed - Approved';
            objQuo.Selected_Payment_Term__c = '1/3';
            objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Description = 'Unpaid#-100';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        
        List<Payment_Term__c> lstPaymentTerms = new List<Payment_Term__c>();
        lstPaymentTerms.add(payTerm);
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms, false);
        
        newobjQuote = new List<Quote>();
        for(Quote objQuo : objQuote){
            objQuo.Status = 'Signed - Approved';
            objQuo.Selected_Payment_Term__c = '1/3';
            objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Description = 'Partially Paid#100';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms, false);
        
        newobjQuote = new List<Quote>();
        for(Quote objQuo : objQuote){
            objQuo.Status = 'Signed - Approved';
            objQuo.Selected_Payment_Term__c = '1/3';
            objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Description = 'Partially Paid#-100';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms,false);
    }
    
    @isTest static void test5(){
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        payTerm.Amount__c = 100;
        payTerm.Percentage_Of_Payment__c = 100;
        update payTerm;
        List<Quote> newobjQuote = new List<Quote>();
        List<Quote> objQuote = [select Id, Status, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode, Pricebook2Id from Quote where Id=: payTerm.Quote__c];
        List<Payment_Term__c> lstPaymentTerms = new List<Payment_Term__c>();
        lstPaymentTerms.add(payTerm);
        
        for(Quote objQuo : objQuote){
            objQuo.Status = 'Signed - Approved';
            objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Selected_Payment_Term__c = 'Custom';
            objQuo.Description = 'Partially Paid#100';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms, true);
        
        newobjQuote = new List<Quote>();
        for(Quote objQuo : objQuote){
            objQuo.Status = 'Signed - Approved';
            objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Selected_Payment_Term__c = 'Custom';
            objQuo.Description = 'Unpaid#100';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms,true);
    }
    
    @isTest static void test6(){
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;        
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        payTerm.Amount__c = 200;
        payTerm.Credit__c = true;
        payTerm.RecordTypeId = Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
        payTerm.Status__c = 'Passed';
        update payTerm;
        List<Quote> newobjQuote = new List<Quote>();
        List<Quote> objQuote = [select Id, Status, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode, Pricebook2Id from Quote where Id=: payTerm.Quote__c];
        for(Quote objQuo : objQuote){
            objQuo.Selected_Payment_Term__c = '1/2';
            objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Description = 'Partially Paid#100';
            objQuo.Payment_Method__c = 'Value-In-Kind';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        
        List<Payment_Term__c> lstPaymentTerms = new List<Payment_Term__c>();
        lstPaymentTerms.add(payTerm);
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms,false);
        
        newobjQuote = new List<Quote>();
        for(Quote objQuo : objQuote){
            objQuo.Status = 'Signed - Approved';
            objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Selected_Payment_Term__c = 'Custom';
            objQuo.Description = 'Paid#-100';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms,false);
        
        newobjQuote = new List<Quote>();
        for(Quote objQuo : objQuote){
            objQuo.Status = 'Signed - Approved';
            objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Selected_Payment_Term__c = '100%';
            objQuo.Description = 'Paid#-100';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms, true);
    }
    
    @isTest static void test7(){        
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();        
        payTerm.Amount__c = 200;
        payTerm.Credit__c = true;
        payTerm.RecordTypeId = Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
        payTerm.Status__c = 'Passed';
        update payTerm;
        List<Quote> newobjQuote = new List<Quote>();
        List<Quote> objQuote = [select Id, Status, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode, Pricebook2Id from Quote where Id=: payTerm.Quote__c];
        for(Quote objQuo : objQuote){
            objQuo.Selected_Payment_Term__c = '1/2';
            //objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Description = 'Partially Paid#100';
            objQuo.Payment_Method__c = 'Value-In-Kind';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        
        List<Payment_Term__c> lstPaymentTerms = new List<Payment_Term__c>();
        lstPaymentTerms.add(payTerm);
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms, false);        
    }
    
    @isTest static void test8(){        
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        payTerm.Amount__c = 500;
        payTerm.Credit__c = true;
        payTerm.RecordTypeId = Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
        update payTerm;
        List<Quote> newobjQuote = new List<Quote>();
        List<Quote> objQuote = [select Id, Status, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode, Pricebook2Id from Quote where Id=: payTerm.Quote__c];
        for(Quote objQuo : objQuote){
            objQuo.Selected_Payment_Term__c = '100%';
            //objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Description = 'Unpaid#-100';
            objQuo.Payment_Method__c = 'Value-In-Kind';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        
        List<Payment_Term__c> lstPaymentTerms = new List<Payment_Term__c>();
        lstPaymentTerms.add(payTerm);
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms, false);        
    }
    
    @isTest static void test9(){        
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        payTerm.Amount__c = 500;
        payTerm.Credit__c = true;
        payTerm.RecordTypeId = Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
        update payTerm;
        List<Quote> newobjQuote = new List<Quote>();
        List<Quote> objQuote = [select Id, Status, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode, Pricebook2Id from Quote where Id=: payTerm.Quote__c];
        for(Quote objQuo : objQuote){
            objQuo.Selected_Payment_Term__c = '100%';
            //objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Description = 'Unpaid#100';
            objQuo.Payment_Method__c = 'Value-In-Kind';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        
        List<Payment_Term__c> lstPaymentTerms = new List<Payment_Term__c>();
        lstPaymentTerms.add(payTerm);
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms, false);        
    }
    
    @isTest static void test10(){        
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        payTerm.Amount__c = 0;
        payTerm.Credit__c = false;
        //payTerm.Status__c = 'Passed';
        update payTerm;
        List<Quote> newobjQuote = new List<Quote>();
        List<Quote> objQuote = [select Id, Status, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode, Pricebook2Id from Quote where Id=: payTerm.Quote__c];
        for(Quote objQuo : objQuote){
            objQuo.Selected_Payment_Term__c = '100%';
            //objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Description = 'Unpaid#-100';
            objQuo.Payment_Method__c = 'Value-In-Kind';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        
        List<Payment_Term__c> lstPaymentTerms = new List<Payment_Term__c>();
        lstPaymentTerms.add(payTerm);
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms, false);        
    }
    
    @isTest static void test11(){        
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        payTerm.Amount__c = 0;
        payTerm.Credit__c = true;
        payTerm.RecordTypeId = Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
        payTerm.Status__c = 'Passed';
        update payTerm;
        List<Quote> newobjQuote = new List<Quote>();
        List<Quote> objQuote = [select Id, Status, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode, Pricebook2Id from Quote where Id=: payTerm.Quote__c];
        for(Quote objQuo : objQuote){
            objQuo.Selected_Payment_Term__c = '1/3';
            //objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Description = 'Partially Paid#100';
            objQuo.Payment_Method__c = 'Value-In-Kind';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        
        List<Payment_Term__c> lstPaymentTerms = new List<Payment_Term__c>();
        lstPaymentTerms.add(payTerm);
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms, false);        
    }
    
    @isTest static void test12(){        
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        payTerm.Amount__c = 200;
        payTerm.Credit__c = false;
        payTerm.Status__c = 'Passed';
        update payTerm;
        List<Quote> newobjQuote = new List<Quote>();
        List<Quote> objQuote = [select Id, Status, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode, Pricebook2Id from Quote where Id=: payTerm.Quote__c];
        for(Quote objQuo : objQuote){
            objQuo.Selected_Payment_Term__c = '1/3';
            //objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Description = 'Partially Paid#100';
            objQuo.Payment_Method__c = 'Value-In-Kind';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        
        List<Payment_Term__c> lstPaymentTerms = new List<Payment_Term__c>();
        lstPaymentTerms.add(payTerm);
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms, false);        
    }
    
    @isTest static void test13(){        
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        payTerm.Amount__c = 0;
        payTerm.Credit__c = false;
        payTerm.Status__c = 'Passed';
        update payTerm;
        
        Payment_Term__c payTerm1 = TestDataFactory.createPaymentTerm();
        payTerm1.Amount__c = 0;
        payTerm1.Credit__c = false;
        payTerm1.Status__c = 'Passed';
        update payTerm1;
        List<Quote> newobjQuote = new List<Quote>();
        List<Quote> objQuote = [select Id, Status, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode, Pricebook2Id from Quote where Id=: payTerm.Quote__c];
        for(Quote objQuo : objQuote){
            objQuo.Selected_Payment_Term__c = '1/3';
            //objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Description = 'Partially Paid#100';
            objQuo.Payment_Method__c = 'Value-In-Kind';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        
        List<Payment_Term__c> lstPaymentTerms = new List<Payment_Term__c>();
        lstPaymentTerms.add(payTerm);
        lstPaymentTerms.add(payTerm1);
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms,false);        
    }
    
    @isTest static void test14(){
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        payTerm.Amount__c = 200;
        payTerm.Credit__c = true;
        payTerm.RecordTypeId = Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
        payTerm.Status__c = 'Passed';
        update payTerm;
        
        List<Quote> newobjQuote = new List<Quote>();
        List<Quote> objQuote = [select Id, Status, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode, Pricebook2Id from Quote where Id=: payTerm.Quote__c];
        for(Quote objQuo : objQuote){
            objQuo.Status = 'Signed - Approved';
            objQuo.Selected_Payment_Term__c = '100%';
            objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Description = 'Paid#100';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        
        List<Payment_Term__c> lstPaymentTerms = new List<Payment_Term__c>();
        lstPaymentTerms.add(payTerm);
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms, false);
    }
    
    @isTest static void test15(){
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        payTerm.Amount__c = 200;
        payTerm.Credit__c = true;
        payTerm.RecordTypeId = Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
        payTerm.Status__c = 'Passed';
        update payTerm;
        
        List<Quote> newobjQuote = new List<Quote>();
        List<Quote> objQuote = [select Id, Status, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode, Pricebook2Id from Quote where Id=: payTerm.Quote__c];
        for(Quote objQuo : objQuote){
            objQuo.Status = 'Signed - Approved';
            objQuo.Selected_Payment_Term__c = 'Custom';
            objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Description = 'Partially Paid#100';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        
        List<Payment_Term__c> lstPaymentTerms = new List<Payment_Term__c>();
        lstPaymentTerms.add(payTerm);
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms, false);
    }
    
    @isTest static void test16(){
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        payTerm.Amount__c = 500;
        payTerm.Credit__c = true;
        payTerm.RecordTypeId = Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
        payTerm.Status__c = 'Passed';
        update payTerm;
        
        List<Quote> newobjQuote = new List<Quote>();
        List<Quote> objQuote = [select Id, Status, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode, Pricebook2Id from Quote where Id=: payTerm.Quote__c];
        for(Quote objQuo : objQuote){
            objQuo.Status = 'Signed - Approved';
            objQuo.Selected_Payment_Term__c = '1/2';
            objQuo.Original_Quote__c = objQuo.Id;
            objQuo.Description = 'Partially Paid#-300';
            newobjQuote.add(objQuo);
        }
        Utility.processRecords(newobjQuote, 'update');
        
        List<Payment_Term__c> lstPaymentTerms = new List<Payment_Term__c>();
        lstPaymentTerms.add(payTerm);
        QuoteTriggerHelper.savePaymentTerm(newobjQuote, lstPaymentTerms, false);
    }
    @isTest static void test17(){
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        payTerm.Amount__c = 100;
        payTerm.Status__c = 'Passed';
        List<Quote> objQuote = [select Id, Status, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode from Quote where Id=: payTerm.Quote__c];
        for(Quote objQuo : objQuote){
            objQuo.Status = 'Sent from QNG';        
        }
        List<Quotelineitem> lstQli = TestDataFactory.createQuoteLineItem(1, objQuote[0].Id, true);
        Test.startTest();
        Utility.processRecords(objQuote, 'update');        
        Test.stopTest();
    }
}
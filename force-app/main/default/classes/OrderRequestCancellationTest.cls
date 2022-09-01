/**
 * @File Name          : OrderRequestCancellationTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 12-23-2020
 * @Last Modified On   : 01-18-2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    5/9/2020   Lovel Panchal     Initial Version
 * 1.1    12/23/2020    jagrawal@addonblue.com      #685 Reduced unnecessary SOQL
**/
@isTest
public with sharing class OrderRequestCancellationTest {
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        Quote objQuote = TestDataFactory.createQuote();
        List<Order> lstOrder = new List<Order>();
        for(Order objOrder : TestDataFactory.createOrder(1,false)){
            objOrder.Order_Payment_Status__c = 'Fully Paid';
            lstOrder.add(objOrder);
        }
        insert lstOrder;
        System.debug('objQuote@@@'+objQuote);
        Product2 objProd =TestDataFactory.createProduct();
        objProd.Price__c = 120;
        objProd.CurrencyIsoCode = 'USD';
        update objProd;
        Test.startTest();
        TestDataFactory.createQuoteLineItem(2,objQuote.Id,true);
        Payment_Term__c objPT = TestDataFactory.createPaymentTerm(1,objQuote.OpportunityId,objQuote.Id,null)[0];
        System.debug('objQuot update@@@'+objQuote);
        Test.stopTest();
    }
    
    @isTest static void test1(){
        Test.startTest();
        Quote objQuote = TestDataFactory.createQuote();       
        OrderRequestCancellationController.reasonsForCancellation(objQuote,'Language__c');
        OrderRequestCancellationController.updateQuoteStatus(objQuote.id,'test','test',true);
        Test.stopTest();
    }
    @isTest static void test2(){
        Test.startTest();
        List<Order> lstOrder = new List<Order>();
         Map<Id,Decimal> mapOrderAmount = new  Map<Id,Decimal>();
        Order objParentOrder =  [Select Id from Order Limit 1];
        for(Order objOrd : TestDataFactory.createOrder(2, False)){
            objOrd.Original_Order__c = objOrd.Id;
            lstOrder.add(objOrd);
            mapOrderAmount.put(objOrd.QuoteId,10);
        }
        Insert lstOrder;
        OrderRequestCancellationController.processRefund(lstOrder,mapOrderAmount);
        Test.stopTest();
    }
    @isTest static void test3(){
        
        Quote objQuote = [Select Id from Quote Limit 1];
        objQuote.Status = 'Signed - Approved';
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        triggerSetting = Trigger_Settings__c.getInstance('Opportunity');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        triggerSetting = Trigger_Settings__c.getInstance('QuoteLineItem');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        triggerSetting = Trigger_Settings__c.getInstance('Product2');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        triggerSetting = Trigger_Settings__c.getInstance('Payment_Term__c');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        test.startTest();
        update objQuote;
		
        
        Order objorder = [Select Id,Status,AccountId,Pricebook2Id,OpportunityId,QuoteId,Original_Order__c,CurrencyIsoCode,OwnerId from Order limit 1];
        Map<Id,Order> mapordr= new Map<Id,Order>();
        Map<Id,Order> mapoldorder = new Map<Id,Order>();
        mapordr.put(objorder.id,objorder);
        mapoldorder.put(objorder.id, objorder);       	
        
        triggerSetting = Trigger_Settings__c.getInstance('Quote');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;        
        triggerSetting = Trigger_Settings__c.getInstance('OrderItem');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        
        OrderRequestCancellationController.callCreditRefundApproval(objorder.id, 50);
        OrderRequestCancellationController.processCancelOrder(mapordr, mapoldorder, new List<Charge__c>()); 
        OrderRequestCancellationController.updateQuoteStatus(objorder.id,'test','test',true);
        OrderRequestCancellationController.processCreditRefund(mapordr);
        test.stopTest();
    }
    @isTest static void test4(){
        Quote objQuote = [Select Id from Quote Limit 1];
        objQuote.Status = 'Signed - Approved';
        
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Opportunity');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        triggerSetting = Trigger_Settings__c.getInstance('Payment_Term__c');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        triggerSetting = Trigger_Settings__c.getInstance('Order');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        triggerSetting = Trigger_Settings__c.getInstance('QuoteLineItem');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        System.debug('SOQL before update '+Utility.getSOQLCount());
        update objQuote;
        System.debug('SOQL after update '+Utility.getSOQLCount());
        
        triggerSetting = Trigger_Settings__c.getInstance('Quote');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        triggerSetting = Trigger_Settings__c.getInstance('OrderItem');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        triggerSetting = Trigger_Settings__c.getInstance('Product2');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        triggerSetting = Trigger_Settings__c.getInstance('Charge__c');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        
        
        List<Order> lstorder = [Select id from Order where QuoteId =: objQuote.Id];
        Test.startTest();
        Id quoteId = OrderChange.createQuotePaymentTerms(lstorder[0].Id,'yes','no');
        
        List<QuoteLineItem> lstQLI = [Select id,Quantity from QuoteLineItem where QuoteId =:quoteId];
        for(QuoteLineItem objnewqli : lstQLI){
            objnewqli.Quantity = 4;
        }
        update lstQLI;
        Test.stopTest();
    }
    @isTest static void test5(){
        Trigger_Settings__c triggerSetting = new Trigger_Settings__c(); 
        triggerSetting.Name = 'Test';
        triggerSetting.Max_Loop_Count__c = 1.0;
        triggerSetting.Deactivate__c = true;
		Utility.processRecords(triggerSetting, 'insert', true);
        Utility.convertCurrencyFromIsoToIso(100, 'GBP', 'EUR');
        Utility.convert(100, 'CAD', System.today());
    }
}
/**
 * @description       : 
 * @author            : jagrawal@addonblue.com
 * @group             : 
 * @last modified on  : 04-20-2022
 * @last modified by  : fsuraitawala@addonblue.com
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   07-31-2020   Jheel Agrawal   Initial Version
**/
@isTest public class BrandFuelBatchTest {
    
    @testSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        Quote objQuote = TestDataFactory.createQuote();
        Product2 objBFProduct = TestDataFactory.createProduct('GiftBag', 'Product', 'Giftbag', null, Test.getStandardPricebookId());
        objBFProduct.Brandfuel_Points__c = 5;
        insert objBFProduct;
        PriceBookEntry objPBE = TestDataFactory.createPricebookEntry(objBFProduct, Test.getStandardPricebookId());
        insert objPBE;
        QuoteLineItem objQLI = TestDataFactory.createQuoteLineItem(objQuote.Id, objPBE.Id, 'A La Carte', null, null, true);
        TestDataFactory.createPaymentTerm(1, objQuote.OpportunityId, objQuote.Id, null, 100);
        Test.startTest();
        Trigger_Settings__c objTriggerSetting = Trigger_Settings__c.getValues('Quote');
        objTriggerSetting.Max_Loop_Count__c = 10;
        update objTriggerSetting;
        objQuote.Status = 'Signed - Approved';
        update objQuote;
        Order objOrder = [Select Id, Order_Payment_Status__c from Order];
        System.debug('@@Order_Payment_Status__c:- '+objOrder.Order_Payment_Status__c);
        objOrder.Order_Payment_Status__c = 'Not Paid';
        update objOrder;
        Test.stopTest();
    }
    
    @isTest static void method1(){
        Order objOrder = [Select Id, Order_Payment_Status__c from Order];
        System.debug('@@Order_Payment_Status__c:- '+objOrder.Order_Payment_Status__c);
        objOrder.Order_Payment_Status__c = 'Fully Paid';
        update objOrder;
        
        Set<Id> setOrderIdsBF = new Set<Id>();
        Set<Id> setOrderItemIdsBF = new Set<Id>();
        for(OrderItem oitem: [Select id,orderId from orderitem]){
            setOrderIdsBF.add(oitem.orderId);
            setOrderItemIdsBF.add(oitem.id);
        }
        
        if(setOrderIdsBF.size() > 0 || Test.isrunningtest()){
            String query = 'Select Id, Status, Order_Payment_Status__c, OpportunityId, PriceBook2Id, PriceBook2.End_Date__c, PriceBook2.Name, PriceBook2.Brandfuel_End_Date__c, Brandfuel_Customer_Link__c from Order';
            BrandFuelBatch objBFBatch = new BrandFuelBatch(query, setOrderIdsBF, setOrderItemIdsBF); Database.executeBatch(objBFBatch, 1);
        }
    }
}
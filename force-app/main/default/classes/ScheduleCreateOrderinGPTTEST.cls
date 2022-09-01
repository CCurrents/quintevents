/**
 * @File Name          : ScheduleCreateOrderinGPTTEST.cls
 * @Description        : Test class for ScheduleCreateOrderinGPTTEST
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 11/04/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    11/04/2020  kchavda@addonblue.com     Initial Version
**/
@isTest
private class ScheduleCreateOrderinGPTTEST{      
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    
    @isTest static void testone() {
         PriceBook2 priceBook = TestDataFactory.createPricebook(1, 'T', false)[0];
        priceBook.Payment_Cancellation_Days__c = 2;
        priceBook.Start_Date__c = system.today();
        priceBook.Event_Payment_Window__c = 1;
        priceBook.GPE_Event__c = true;
        Utility.processRecords(pricebook, 'insert');
        
        Order order = TestDataFactory.createOrder(1,false)[0];
        order.Order_Payment_Status__c = 'Fully Paid'; 
        order.PriceBook2Id = pricebook.id;       
        Utility.processRecords(order, 'insert');        
        Test.startTest();
        ScheduleCreateOrderinGPT sch = new ScheduleCreateOrderinGPT();
        sch.execute(null);
        
        string query = 'select id,createddate,Xero_Invoice_ID__c from order';
        CreateOrderinGPTBatch batch = new CreateOrderinGPTBatch(query,new set<id>{order.id});
        database.executebatch(batch,1);  
        
        Test.stoptest();
    }
    
}
/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 03-24-2022
 * @last modified by  : ratiksinghal@addonblue.com
**/
@isTest
private with sharing class IntacctPaymentTermSyncScheduleTest{
    
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }
    @isTest static void testOne() {
        List<Order> lstOrder = TestDataFactory.createOrder(1, true);
        Payment_Term__c pt = TestDataFactory.createPaymentTerm();   
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test IntacctPaymentTermSyncScheduleTest', sch, new IntacctPaymentTermSyncSchedule());
    }

    @isTest static void testTwo() {
        List<Order> lstOrder = TestDataFactory.createOrder(1, true);
        Payment_Term__c pt = TestDataFactory.createPaymentTerm();
       
        String q = 'select id, order__c from payment_term__c limit 1';
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test IntacctPaymentTermSyncScheduleTest', sch, new IntacctPaymentTermSyncSchedule(10,30,15,q));
    }
}
/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 04-06-2022
 * @last modified by  : fsuraitawala@addonblue.com
**/
@isTest
private with sharing class IntacctChargeSyncScheduleTest{
     
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }
    @isTest static void testOne() {
        List<Order> lstOrder = TestDataFactory.createOrder(1, true);
        Payment_Term__c pt = TestDataFactory.createPaymentTerm();
        Charge__c objCharge = new Charge__c();
        objCharge.Payment_Terms__c = pt.Id;
        objCharge.Amount__c = 100;
        objCharge.Account__c = [select id,accountid from order where id=:lstOrder[0].id].AccountId;    
        objCharge.Recordtypeid =Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Debit').getRecordTypeId();  
        insert objCharge;     
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test Check', sch, new IntacctChargeSyncSchedule());
    }

    @isTest static void testTwo() {
        List<Order> lstOrder = TestDataFactory.createOrder(1, true);
        Payment_Term__c pt = TestDataFactory.createPaymentTerm();
        Charge__c objCharge1 = new Charge__c();
        objCharge1.Payment_Terms__c = pt.Id;
        objCharge1.Amount__c = 100;
        objCharge1.Account__c = [select id,accountid from order where id=:lstOrder[0].id].AccountId;    
        objCharge1.Recordtypeid =Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Account Credit').getRecordTypeId();
        insert objCharge1;
        String q = 'Select Id, Payment_Terms__c, Payment_Terms__r.Order__c, Payment_Terms__r.Order__r.International_Stripe__c, Payment_Terms__r.Opportunity_Currency__c, CurrencyIsoCode, Credit_Used__c, RecordType.Name FROM charge__c limit 1';
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test Check', sch, new IntacctChargeSyncSchedule(10,30,15,q));
    }
}
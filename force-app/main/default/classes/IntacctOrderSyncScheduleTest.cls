/**
 * @File Name          : IntacctOrderSyncScheduleTest.cls
 * @Description        : test class for the IntacctOrderSyncSchedule controller
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 06/29/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    06/29/2020    kchavda@addonblue.com       Initial Version
**/
@isTest
private with sharing class IntacctOrderSyncScheduleTest{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }
    @isTest static void testone() {
        List<Order> lstOrder = TestDataFactory.createOrder(1, true);
        Payment_Term__c pt = TestDataFactory.createPaymentTerm();
        Charge__c objCharge = new Charge__c();
        objCharge.Payment_Terms__c = pt.Id;
        objCharge.Amount__c = 100;
        objCharge.Account__c = [select id,accountid from order where id=:lstOrder[0].id].AccountId;    
        objCharge.Recordtypeid =Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Debit').getRecordTypeId();  
        insert objCharge;    
        Charge__c objCharge1 = new Charge__c();
        objCharge1.Payment_Terms__c = pt.Id;
        objCharge1.Amount__c = 100;
        objCharge1.Account__c = [select id,accountid from order where id=:lstOrder[0].id].AccountId;    
        objCharge1.Recordtypeid =Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
        insert objCharge1;  
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test Check', sch, new IntacctOrderSyncSchedule());
        
    }
}
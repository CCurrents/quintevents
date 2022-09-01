/**
 * @File Name          : RefundTriggerHelperTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 01-07-2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    5/8/2020   jagrawal@addonblue.com     Initial Version
 * 1.1    08/24/2020 kchavda@addonblue.com      #465 Refund Orders
 * 1.2    12/28/2020 kchavda@addonblue.com      #673 Inventory being added twice if there are 2 refunds created at the same time
**/
@isTest
public class RefundTriggerHelperTest {
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        TestDataFactory.createSFDCIntacctMapping();
    }
    @isTest static void test1(){
        Account acc = TestDataFactory.createAccount();
        Payment_Term__c objPT = TestDataFactory.createPaymentTerm();
        Charge__c objcharge = new Charge__c();
        objcharge.Account__c = acc.Id;
        Refund__c objrefund = new Refund__c();
        objrefund.Charge__c = objcharge.Id;
        objrefund.Opportunity_Payment_Terms__c = objPT.Id;
        insert objrefund;
        
        Refund__c objrefundupdate = [Select Id from Refund__c where id =: objrefund.Id];
        objrefundupdate.Status__c = 'succeeded';
        update objrefundupdate;
    }
    @isTest static void test2(){
        
        Payment_Term__c objPT = TestDataFactory.createPaymentTerm();
        objPT.Payment_Method__c ='Bank Account';
        update objPt;
        Order objorder = [Select Id,AccountId,status,QuoteId from Order where Id =: objPT.Order__c];
        Quote objquote = [Select id,OpportunityId from Quote where Id =:objOrder.QuoteId];
        QuoteLineItem QLI = TestDataFactory.createQuoteLineItem(1,objquote.id,true)[0];
        orderItem item = TestDataFactory.createOrderItem(1,objorder.id,QLI)[0];
        objorder.status = 'Active';
        update objorder;
        Account acc = [Select id from Account where id =: objorder.AccountId];
        acc.Intacct_Id__c = '1234';
        update acc;
        Charge__c objcharge = new Charge__c();
        objcharge.Account__c = objorder.AccountId;
        objcharge.Payment_Terms__c = objPT.Id;
        objcharge.Order__c = objorder.Id;
        objcharge.RecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Debit').getRecordTypeId();
        objcharge.Amount__c = 1000;
        opportunity opp = [Select Id,Refund_response__c from opportunity where Id =: objPT.opportunity__c];
        opp.Refund_response__c = 'Confirm Refund';
        update opp;
        Test.startTest();
        insert objcharge;
        Refund__c objrefund = new Refund__c();
        objrefund.Charge__c = objcharge.Id;
        objrefund.Amount__c = 1000;
        objrefund.Order__c = objorder.Id;
        objrefund.Opportunity_Payment_Terms__c = objPT.Id;
        objrefund.Status__c = 'succeeded';
        insert objrefund;
        
        objrefund = new Refund__c();
        objrefund.Charge__c = objcharge.Id;
        objrefund.Amount__c = 1000;
        objrefund.Order__c = objorder.Id;
        objrefund.Opportunity_Payment_Terms__c = objPT.Id;
        objrefund.Status__c = 'succeeded';
        insert objrefund;
        
        Test.stopTest();
    }
}
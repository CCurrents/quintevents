/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 03-16-2022
 * @last modified by  : ratiksinghal@addonblue.com
**/
@isTest
private with sharing class IntacctRetryPaymentTermBatchTest {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }

    @isTest static void testone() {
        List<Order> lstOrder = TestDataFactory.createOrder(1, true);
        Payment_Term__c pt = TestDataFactory.createPaymentTerm();
        pt.Intacct_Status__c = 'Failure';
        update pt;
                
        String q = 'select id, order__c from payment_term__c limit 1';
        IntacctRetryPaymentTermBatch batch = new IntacctRetryPaymentTermBatch(q);
        Database.executeBatch(batch,1);
    }
    
    @isTest static void testTwo() {
        List<Order> lstOrder = TestDataFactory.createOrder(1, true);
        Payment_Term__c pt = TestDataFactory.createPaymentTerm();
        pt.Intacct_Status__c = 'Failure';
        update pt;
        
        IntacctRetryPaymentTermBatch batch = new IntacctRetryPaymentTermBatch();
        Database.executeBatch(batch,1);
    }
}
/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 03-16-2022
 * @last modified by  : ratiksinghal@addonblue.com
**/
global class IntacctRetryPaymentTermBatch implements Database.AllowsCallouts, Database.Batchable<sObject>, Schedulable {
    String query = null;

    public IntacctRetryPaymentTermBatch(){
        this.query = 'select id, order__c from payment_term__c where Intacct_Status__c!= \'Success\' and Intacct_Id__c = null and Order__r.Intacct_Id__c != null';
    }
    public IntacctRetryPaymentTermBatch(String strQuery){
         this.query = strQuery;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Payment_term__c> scope){
        for(Payment_term__c pt : scope) {
            System.debug('IntacctRetryPaymentTermBatch:execute, Payment Term Id: '+pt.Id);
            IntacctInvoiceSyncBatch batchId = new IntacctInvoiceSyncBatch(pt.order__c,pt.id,new list<String> { 'Sales Invoice'}); 
        }
        System.debug('IntacctRetryPaymentTermBatch:execute  == Finish ==');    
    }
    
    public void finish(Database.BatchableContext BC){
    }

    public void execute(SchedulableContext sc){
        Database.executeBatch(new IntacctRetryPaymentTermBatch(), 5);
    }
}
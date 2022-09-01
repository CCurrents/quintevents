/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 02-09-2022
 * @last modified by  : ratiksinghal@addonblue.com
**/
global class IntacctAppyAdjustmentBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{ 
    
    Set<Id> setPaymentTermIds = new Set<Id>();
    public IntacctAppyAdjustmentBatch(Set<Id> setIds){
        setPaymentTermIds = setIds;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('Select Id, CurrencyISOCode, Intacct_Adjustment_Id__c, Commission_Paid__c, Commission__c, Intacct_Id__c, Order__r.Location_Id__c, Order__r.Account.Intacct_Id__c  FROM Payment_Term__c WHERE Id = :setPaymentTermIds');
    }
    
    global void execute(Database.BatchableContext bc, List<Payment_Term__c> scope){
        for(Payment_Term__c objPT : scope) {
            if(objPT != null && objPT.Commission_Paid__c == false && objPT.Intacct_Adjustment_Id__c == null) {
                IntacctOrderSyncBatchHelper IntacctOrderSyncBatchHelper = new IntacctOrderSyncBatchHelper();
                IntacctOrderSyncBatchHelper.createAdujusmentCallout(objPT.Id);
            }
        }
    }    
    global void finish(Database.BatchableContext bc) {
        System.debug('Records processed. Shazam!');
    }    
}
/**
 * @File Name          : IntacctChargeSync.cls
 * @Description        : 
 * @Author             : lpanchal@addonblue.com
 * @Group              : 
 * @Last Modified By   : Lovel Panchal
 * @Last Modified On   : 5/9/2020, 7:40:27 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    3/27/2020   lpanchal@addonblue.com     Initial Version
 * 1.1    09/18/2020  kchavda@addonblue.com      #544 ARPayment not being created in intacct.
**/
public class IntacctChargeSync {
    @InvocableMethod(label='Sync Charge' description='Syncs Charge objects Payment Term to Intacct.')
    public static void syncCharge(List<Id> lstId) {
        System.debug('lstId---'+lstId);       
        Id debitRecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Debit').getRecordTypeId();
        for(Charge__c chg :[Select Id,RecordTypeId,Payment_Terms__c,Payment_Terms__r.Order__c,Payment_Terms__r.Opportunity_Currency__c,Payment_Terms__r.Payment_Method__c from Charge__c WHERE Id in :lstId and RecordTypeId =: debitRecordTypeId and Payment_Terms__r.Order__r.pricebook2.GPE_Event__c = false]){ 
            if(!Test.isrunningTest()){ IntacctOrderSyncBatch batchId = new IntacctOrderSyncBatch(chg.Payment_Terms__r.Order__c, new list<String> { 'arpayment'},chg.Payment_Terms__c+'###'+chg.id); System.debug('batchId---'+batchId); Database.executebatch(batchId);
            }
        }    
    }
}
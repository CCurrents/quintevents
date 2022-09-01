/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 04-19-2022
 * @last modified by  : fsuraitawala@addonblue.com
**/

global with sharing class ReleaseInventoryBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
    global String query;
    public ReleaseInventoryBatchClass(String days) {
        String toDate = 'TODAY';
        if(days != null){
            toDate = 'LAST_N_DAYS:'+days;
        }
        query = 'Select Id, RecordTypeId, Quantity__c, Hold_Release_Date__c, Hold_Released__c, Quote__c, Quote_Line_Item__c, Hold_Released_Processed__c, Product__c from Inventory_Transaction__c where Hold_Released_Processed__c = false and Hold_Release_Date__c != null and RecordType.Name = \'Inventory Hold\' and Hold_Release_Date__c <='+ toDate;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Inventory_Transaction__c> scope){
        List<Inventory_Transaction__c> lstOfholdInventory = scope;
        List<Inventory_Transaction__c> lstOfReleasedInventory = new List<Inventory_Transaction__c>();

        for(Inventory_Transaction__c holdIT: lstOfholdInventory) {
            if(holdIT.Quantity__c > 0 && holdIT.Hold_Released_Processed__c == false){
                Inventory_Transaction__c releaseIT = new Inventory_Transaction__c();
                releaseIT.Quantity__c = -holdIT.Quantity__c;
                if(holdIT.Quote__c != null){
                    releaseIT.Quote__c = holdIT.Quote__c;
                }
                if(holdIT.Quote_Line_Item__c != null){
                    releaseIT.Quote_Line_Item__c = holdIT.Quote_Line_Item__c;
                }
                releaseIT.RecordTypeId = holdIT.RecordTypeId;
                releaseIT.Product__c = holdIT.Product__c;
                releaseIT.Hold_Released__c = holdIT.Id;
                releaseIT.Hold_Released_Processed__c = true;

                holdIT.Hold_Released_Processed__c = true; 
                lstOfReleasedInventory.add(releaseIT);
                lstOfReleasedInventory.add(holdIT);
            }
            
        }
        if(lstOfReleasedInventory.size() > 0){
            Utility.processRecords(lstOfReleasedInventory, 'upsert');
        }
    }

    global void finish(Database.BatchableContext BC){
    }
}
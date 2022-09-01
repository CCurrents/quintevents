/**
 * @File Name          : InventoryTransactionTrigger.trigger
 * @Description        : This trigger use for Inventory Transaction object
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 3:01:45 AM
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    17/01/2020   fsuraitawala@addonblue.com    Initial Version
 * 1.1    11/03/2020   fsuraitawala@addonblue.com    Refactored the code by changing the name of Trigger, Handler and the Custom Setting
**/
trigger InventoryTransactionTrigger on Inventory_Transaction__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Inventory_Transaction__c');
    if(!triggerSetting.Deactivate__c){
        new InventoryTransactionTriggerHandler().run();
    }
}
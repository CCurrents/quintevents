/**
 * @File Name          : OrderItemTrigger.trigger
 * @Description        : 
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 12-23-2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    12/22/2020   fsuraitawala@addonblue.com   Initial Version
**/
trigger OrderItemTrigger on OrderItem (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('OrderItem');
    if(!triggerSetting.Deactivate__c){
        new OrderItemTriggerHandler().run();
    }
}
/**
 * @File Name          : OrderTrigger.trigger
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 2:59:41 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    6/3/2020   jagrawal@addonblue.com     Initial Version
**/
trigger OrderTrigger on Order (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');
    if(!triggerSetting.Deactivate__c){
        new OrderTriggerHandler().run();
    }
}
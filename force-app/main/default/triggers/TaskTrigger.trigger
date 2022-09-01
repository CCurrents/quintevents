/**
 * @File Name          : TaskTrigger.trigger
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 2:49:03 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/03/2020   jagrawal@addonblue.com     Initial Version
**/
trigger TaskTrigger on Task (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Task');
    if(!triggerSetting.Deactivate__c){
        new TaskTriggerHandler().run();
    }
}
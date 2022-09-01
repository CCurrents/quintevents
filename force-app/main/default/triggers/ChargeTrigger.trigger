/**
 * @File Name          : ChargeTrigger.trigger
 * @Description        : Trigger for Charge object
 * @Author             : lpanchal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/8/2020, 4:09:38 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/23/2020   lpanchal@addonblue.com     Initial Version
**/

trigger ChargeTrigger on Charge__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
   
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Charge__c');
    if(!triggerSetting.Deactivate__c){
        new ChargeTriggerHandler().run();
    }
}
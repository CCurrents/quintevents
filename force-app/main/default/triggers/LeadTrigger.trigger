/**
 * @description       : 
 * @author            : jagrawal@addonblue.com
 * @group             : 
 * @last modified on  : 01-26-2021
 * @last modified by  : jagrawal@addonblue.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   01-26-2021   jagrawal@addonblue.com    Initial Version
**/
trigger LeadTrigger on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Lead');
    if(!triggerSetting.Deactivate__c){
        new LeadTriggerHandler().run();
    }	
}
/**
 * @File Name          : GiftCodeTrigger.trigger
 * @Description        : Trigger for Gift Code object
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 3:03:34 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/3/2020   jagrawal@addonblue.com     Initial Version
**/
trigger GiftCodeTrigger on Gift_Code__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Gift_Code__c');
    if(!triggerSetting.Deactivate__c){
        new GiftCodeTriggerHandler().run();
    }        
}
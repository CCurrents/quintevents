/**
 * @File Name          : ContactTrigger.trigger
 * @Description        : This is Trigger for Contact object.
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 3:05:00 AM
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    19/08/2019   fsuraitawala@addonblue.com     Initial Version
 * 1.1    05/03/2020   fsuraitawala@addonblue.com    Refactored the code by changing the name of Trigger, Handler and the Custom Setting
**/
trigger ContactTrigger on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Contact');
    if(!triggerSetting.Deactivate__c){
        new ContactTriggerHandler().run();
    }
}
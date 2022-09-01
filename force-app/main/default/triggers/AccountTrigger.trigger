/**
 * @File Name          : AccountTrigger.trigger
 * @Description        : This is Trigger for Account object.
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 5/18/2020, 3:05:00 AM
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    5/18/2020       mpatel@addonblue.com       Initial Version
**/
trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Account');
    if(!triggerSetting.Deactivate__c){
        new AccountTriggerHandler().run();
    }
}
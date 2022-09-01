/**
 * @File Name          : APIImageTrigger.tgr
 * @Description        : 
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 09/17/2020, 2:52:12 AM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0     09/17/2020   mpatel@addonblue.com     Initial Version
**/
trigger APIImageTrigger on API_Image__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('API_Image__c');
    if(!triggerSetting.Deactivate__c){
        new APIImageTriggerHandler().run();
    }
}
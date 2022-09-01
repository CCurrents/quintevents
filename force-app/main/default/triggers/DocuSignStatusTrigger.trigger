/**
 * @File Name          : DocuSign_Status_Trigger.trigger
 * @Description        : Trigger for Quote Docusign Status
 * @Author             : jthakkar@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 3:04:01 AM
 * @Modification Log   :  
 * Ver       Date            Author              Modification
 * 1.0    3/3/2020   jthakkar@addonblue.com     Initial Version
 * 1.1    3/3/2020   jthakkar@addonblue.com    Refactored the code by changing the name of Trigger, Handler and the Custom Setting
**/
trigger DocuSignStatusTrigger on dsfs__DocuSign_Status__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('dsfs__DocuSign_Status__c');
    if(!triggerSetting.Deactivate__c){
        new DocuSignStatusTriggerHandler().run();
    } 
}
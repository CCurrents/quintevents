/**
 * @File Name          : AttachmentTrigger.trigger
 * @Description        : Trigger for Attachment object
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 9:24:46 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    3/30/2020   kchavda@addonblue.com     Initial Version
**/

trigger AttachmentTrigger on Attachment (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Attachment');
    if(!triggerSetting.Deactivate__c){
        new AttachmentTriggerHandler().run();
    }
}
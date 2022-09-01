/**
 * @File Name          : SalesAgentProgramTrigger.tgr
 * @Description        : 
 * @Author             : jthakkar@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 2:51:12 AM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    27/1/2020   jthakkar@addonblue.com     Initial Version
**/
trigger SalesAgentProgramTrigger on Sales_Agent_Program__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Sales_Agent_Program__c');
    if(!triggerSetting.Deactivate__c){
        new SalesAgentProgramTriggerHandler().run();
    }
}
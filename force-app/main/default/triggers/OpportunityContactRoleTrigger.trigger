/**
 * @File Name          : OpportunityContactRoleTrigger.cls
 * @Description        : Trigger on Opportunity Contact Role object
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 11/11/2020
 * @Modification Log   : 
 * @Unit Test          : 
 * Ver       Date            Author                     Modification
 * 1.0     11/11/2020     kchavda@addonblue.com    Initial Version * 
**/
trigger OpportunityContactRoleTrigger on OpportunityContactRoleChangeEvent (after insert) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('OpportunityContactRoleChangeEvent');
    if(!triggerSetting.Deactivate__c){
        new OpportunityContactRoleTriggerHandler().run();
    }   
}
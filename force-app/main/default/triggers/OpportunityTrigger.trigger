/**
 * @File Name          : OpportunityTrigger.cls
 * @Description        : Trigger on Opportunity object
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 3:00:43 AM
 * @Modification Log   : 
 * @Unit Test          : OpportunityHandler_Test
 * Ver       Date            Author                     Modification
 * 1.0     9/26/2019     fsuraitawala@addonblue.com    Initial Version
 * 1.1     2/3/2020      mpatel@addonblue.com          Refactored the code by changing the name of Trigger, Handler, helper and the Custom Setting
**/
trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {  
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Opportunity');
    if(!triggerSetting.Deactivate__c){
        new OpportunityTriggerHandler().run();
    }
}
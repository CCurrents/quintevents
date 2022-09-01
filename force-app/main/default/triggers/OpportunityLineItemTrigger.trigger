/**
 * @File Name          : OpportunityLineItemTrigger.cls
 * @Description        : Trigger on OpportunityLineItem object
 * @Author             : jthakkar@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 6/22/2020, 8:40:58 PM
 * @Modification Log   : 
 * @Unit Test          : OpportunityHandler_Test
 * Ver       Date            Author                     Modification
 * 1.0     9/26/2019     jthakkar@addonblue.com    Initial Version
**/
trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update, before delete, after insert, after update, after delete, after undelete) {  
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('OpportunityLineItem');
    if(!triggerSetting.Deactivate__c){
        new OpportunityLineItemTriggerHandler().run();
    }
}
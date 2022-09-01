/**
 * @File Name          : PricebookTrigger.trigger
 * @Description        : This is Trigger on Pricebook object.
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 2:58:25 AM
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    30/09/2019   fsuraitawala@addonblue.com   Initial Version
 * 1.1    11/03/2020   fsuraitawala@addonblue.com    Refactored the code by changing the name of Trigger, Handler and the Custom Setting
**/
trigger PricebookTrigger on Pricebook2 (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Pricebook2');
    if(!triggerSetting.Deactivate__c){
        new PricebookTriggerHandler().run();
    }
}
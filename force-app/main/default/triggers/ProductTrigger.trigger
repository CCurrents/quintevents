/**
 * @File Name          : ProductTrigger.trigger
 * @Description        : This is Trigger on Product object.
 * @Author             : fsuraitawalal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 2:57:10 AM
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    19/08/2019   fsuraitawalal@addonblue.com     Initial Version
 * 1.1    06/03/2020   fsuraitawala@addonblue.com    Refactored the code by changing the name of Trigger, Handler and the Custom Setting
**/
trigger ProductTrigger on Product2(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Product2');
    if(!triggerSetting.Deactivate__c){
        new ProductTriggerHandler().run();
    }
}
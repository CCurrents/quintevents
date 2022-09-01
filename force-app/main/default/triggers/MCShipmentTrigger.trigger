/**
 * @File Name          : MCShipmentTrigger.cls
 * @Description        : Trigger on Shipment object
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 3:01:06 AM
 * @Modification Log   : 
 * Ver       Date            Author                     Modification
 * 1.0     9/26/2019     mpatel@addonblue.com          Initial Version
 * 1.1     2/3/2020      mpatel@addonblue.com          Refactored the code by changing the name of Trigger, Handler, helper and the Custom Setting
**/
trigger MCShipmentTrigger on zkmulti__MCShipment__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {  
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('zkmulti__MCShipment__c');
    if(!triggerSetting.Deactivate__c){
        new MCShipmentTriggerHandler().run();
    }
}
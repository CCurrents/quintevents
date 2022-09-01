/**
 * @File Name          : EventPaymentTermTriggerHandler.cls
 * @Description        : Trigger handler on Event Payment Term object and calling from the Event Payment Term Trigger
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 3:16:21 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.1     2/3/2020      mpatel@addonblue.com      Refactored the code by changing the name of Handler
**/
public with sharing class EventPaymentTermTriggerHandler extends TriggerHandler {

    /**
    * @description: Constructor
    * @author mpatel@addonblue.com | 2/28/2020 
    **/
    public EventPaymentTermTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Event_Payment_Terms__c');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
    /**
    * @description  : its a after delete method call while record is deleted in the Event Payment Term object
    * @author       : mpatel@addonblue.com | 1/28/2020 
    * @return       : void 
    **/
    public override void afterDelete() {
        EventPaymentTermTriggerHelper objEventPaymentTermTriggerHelper = new EventPaymentTermTriggerHelper();
    }    
}
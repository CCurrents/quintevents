/**
 * @File Name          : ChargeTriggerHandler.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/8/2020, 3:51:28 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    5/8/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class ChargeTriggerHandler extends TriggerHandler {
    public ChargeTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Charge__c');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
    public override void afterInsert() {
        ChargeTriggerHelper objChargeTriggerHelper = new ChargeTriggerHelper();
    }
    public override void beforeInsert() {
        ChargeTriggerHelper objChargeTriggerHelper = new ChargeTriggerHelper();
    }
    public override void beforeUpdate() {
        ChargeTriggerHelper objChargeTriggerHelper = new ChargeTriggerHelper();
    }
    public override void afterUpdate() {
        ChargeTriggerHelper objChargeTriggerHelper = new ChargeTriggerHelper();
    }

}
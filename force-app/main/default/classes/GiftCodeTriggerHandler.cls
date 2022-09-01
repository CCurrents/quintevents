/**
 * @File Name          : GiftCodeTriggerHandler.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 3:17:05 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/3/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class GiftCodeTriggerHandler extends TriggerHandler {
    
    /**
    * @description Constructor
    * @author jagrawal@addonblue.com | 6/3/2020 
    * @return void 
    **/
    public GiftCodeTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Gift_Code__c');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }

    /**
    * @description After Insert Trigger Event Handling method
    * @author jagrawal@addonblue.com | 6/3/2020 
    * @return void 
    **/
    public override void afterInsert() {
        GiftCodeTriggerHelper objGCTriggerHelper = new GiftCodeTriggerHelper();
    }

    /**
    * @description After Update Trigger Event Handling method
    * @author jagrawal@addonblue.com | 6/3/2020 
    * @return void 
    **/
    public override void afterUpdate() {
        GiftCodeTriggerHelper objGCTriggerHelper = new GiftCodeTriggerHelper();
    }

    /**
    * @description After Delete Trigger Event Handling method
    * @author jagrawal@addonblue.com | 6/3/2020 
    * @return void 
    **/
    public override void afterDelete() {
        GiftCodeTriggerHelper objGCTriggerHelper = new GiftCodeTriggerHelper();
    }

}
/**
 * @File Name          : OrderTriggerHandler.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 12-25-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/3/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class OrderTriggerHandler extends TriggerHandler {
    
    /**
    * @description Constructor
    * @author jagrawal@addonblue.com | 6/3/2020 
    * @return void 
    **/
    public OrderTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
    
    /**
    * @description Before Insert Trigger Event Handling method
    * @author lpanchal@addonblue.com | 15/4/2020 
    * @return void 
    **/
    public override void beforeInsert() {
        OrderTriggerHelper objOrderTriggerHelper = new OrderTriggerHelper();
    }

    /**
    * @description Before Update Trigger Event Handling method
    * @author lpanchal@addonblue.com | 23/4/2020 
    * @return void 
    **/
    public override void beforeUpdate() {
        OrderTriggerHelper objOrderTriggerHelper = new OrderTriggerHelper();
    }


    /**
    * @description After Insert Trigger Event Handling method
    * @author jagrawal@addonblue.com | 6/3/2020 
    * @return void 
    **/
    public override void afterInsert() {
        OrderTriggerHelper objOrderTriggerHelper = new OrderTriggerHelper();
    }

    /**
    * @description After Update Trigger Event Handling method
    * @author jagrawal@addonblue.com | 6/3/2020 
    * @return void 
    **/
    public override void afterUpdate() {
        OrderTriggerHelper objOrderTriggerHelper = new OrderTriggerHelper();
    }

    /**
    * @description After Update Trigger Event Handling method
    * @author fsuraitawala@addonblue.com | 12/25/2020 
    * @return void 
    **/
    public override void beforeDelete() {
        OrderTriggerHelper objOrderTriggerHelper = new OrderTriggerHelper();
    }

}
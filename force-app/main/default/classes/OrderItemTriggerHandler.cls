/**
 * @File Name          : OrderItemTriggerHandler.cls
 * @Description        : 
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 06-04-2021
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    22/12/2020   fsuraitawala@addonblue.com     Initial Version
**/
public with sharing class OrderItemTriggerHandler extends TriggerHandler {
    
    /**
    * @description Constructor
    * @author fsuraitawala@addonblue.com | 22/12/2020
    * @return void 
    **/
    public OrderItemTriggerHandler() {
        
    }
    
    /**
    * @description Before Delete Trigger Event Handling method
    * @author fsuraitawala@addonblue.com | 22/12/2020 
    * @return void 
    **/
    public override void beforeDelete() {
        OrderItemTriggerHelper objOrderItemTriggerHelper = new OrderItemTriggerHelper();
    }

     /**
    * @description After Insert Trigger Event Handling method
    * @author fsuraitawala@addonblue.com | 06/04/2021 
    * @return void 
    **/
    public override void afterInsert() {
        OrderItemTriggerHelper objOrderItemTriggerHelper = new OrderItemTriggerHelper();
    }
    
    /**
    * @description After Delete Trigger Event Handling method
    * @author fsuraitawala@addonblue.com | 06/04/2021
    * @return void 
    **/
    public override void afterDelete() {
        OrderItemTriggerHelper objOrderItemTriggerHelper = new OrderItemTriggerHelper();
    }

}
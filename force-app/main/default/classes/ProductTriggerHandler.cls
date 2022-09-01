/**
 * @File Name          : ProductTriggerHandler.cls
 * @Description        : Handle trigger's events of Product2 object
 * @Author             : fsuraitawalal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 3:21:54 AM
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    08/23/2019   fsuraitawala@addonblue.com    Initial Version
 * 1.1    06/03/2020   fsuraitawala@addonblue.com    Refactored the code by changing the name of Trigger, Handler and the Custom Setting
**/
global class ProductTriggerHandler extends TriggerHandler {
    
    /**
    * @description: Constructor
    * @author fsuraitawalal@addonblue.com
    **/
    public ProductTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Product2');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
    
    /**
    * @description: before insert 
    * @author fsuraitawala@addonblue.com
    * @return void 
    **/
    public override void beforeInsert() {
        ProductTriggerHelper objProductTriggerHelper = new ProductTriggerHelper();
    }
    
    /**
    * @description: after insert 
    * @author fsuraitawala@addonblue.com
    * @return void 
    **/
    public override void afterInsert() {
        ProductTriggerHelper objProductTriggerHelper = new ProductTriggerHelper();
    }
    
    /**
    * @description: before update 
    * @author fsuraitawala@addonblue.com
    * @return void 
    **/
    public override void beforeUpdate() {
        ProductTriggerHelper objProductTriggerHelper = new ProductTriggerHelper();
    }
    
    /**
    * @description: after update 
    * @author fsuraitawala@addonblue.com
    * @return void 
    **/
    public override void afterUpdate() {
        ProductTriggerHelper objProductTriggerHelper = new ProductTriggerHelper();
    }
    
    /**
    * @description: before delete 
    * @author fsuraitawala@addonblue.com
    * @return void 
    **/
    public override void beforeDelete() {
        ProductTriggerHelper objProductTriggerHelper = new ProductTriggerHelper();
    }
    
    /**
    * @description: after delete 
    * @author fsuraitawala@addonblue.com
    * @return void 
    **/
    public override void afterDelete() {
        ProductTriggerHelper objProductTriggerHelper = new ProductTriggerHelper();
    }
}
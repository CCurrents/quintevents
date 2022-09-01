/**
 * @File Name          : PricebookTriggerHandler.cls
 * @Description        : Handle trigger's events of Pricebook2 object
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 3:21:38 AM
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    30/09/2019   fsuraitawala@addonblue.com    Initial Version
 * 1.1    11/03/2020   fsuraitawala@addonblue.com    Refactored the code by changing the name of Trigger, Handler and the Custom Setting
 * 1.2    02/21/2022   vaibhav.khopade@addonblue.com changes for issue 1169
**/
global class PricebookTriggerHandler extends TriggerHandler {
    
    /**
    * @description: Constructor
    * @author fsuraitawalal@addonblue.com
    **/
    public PricebookTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Pricebook2');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
    
    /**
    * @description  : Method for before Insert Event of trigger
    * @author       : vaibhav.khopade@addonblue.com
    * @param        : newPricebooks(New list of object)
    * @return       : void
    **/
    public override void beforeInsert() {
        PricebookTriggerHelper objPricebookTriggerHelper = new PricebookTriggerHelper();
    }
    
    public override void beforeUpdate() {
        PricebookTriggerHelper objPricebookTriggerHelper = new PricebookTriggerHelper();
    }
    
    /**
    * @description  : Method for after Insert Event of trigger
    * @author       : fsuraitawala@addonblue.com
    * @param        : newPricebooks(New list of object)
    * @return       : void
    **/
    public override void afterInsert() {
        PricebookTriggerHelper objPricebookTriggerHelper = new PricebookTriggerHelper();
    }
    
    /**
    * @description  : Method for after Update Event of trigger
    * @author       : fsuraitawala@addonblue.com
    * @param        : newPricebooks(New list of object)
    * @return       : void
    **/
    public override void afterUpdate() {
        PricebookTriggerHelper objPricebookTriggerHelper = new PricebookTriggerHelper();
    }
}
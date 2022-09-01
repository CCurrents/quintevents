/**
 * @File Name          : InventoryTransactionTriggerHandler.trg
 * @Description        : Handle trigger's events of QE360V3_Inventory_Transaction__c object
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 03-04-2022
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    02/07/2019   fsuraitawala@addonblue.com    Initial Version
 * 1.1    11/03/2020   fsuraitawala@addonblue.com    Refactored the code by changing the name of Trigger, Handler and the Custom Setting
 * 1.2    28/04/2020    jagrawal@addonblue.com       Added Before Update method
**/
public class InventoryTransactionTriggerHandler extends TriggerHandler {
    
    /**
    * @description: Constructor
    * @author fsuraitawalal@addonblue.com
    **/
    public InventoryTransactionTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Inventory_Transaction__c');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
    
    /**
    * @description  : Method for before Insert Event of trigger
    * @author       : fsuraitawala@addonblue.com
    * @return       : void
    **/    
    public override void beforeInsert() {
        InventoryTransactionTriggerHelper objInventoryTriggerHelper = new InventoryTransactionTriggerHelper();
    }

    /**
    * @description  : Method for before Insert Event of trigger
    * @author       : jagrawal@addonblue.com
    * @return       : void
    **/    
    public override void beforeUpdate() {
        InventoryTransactionTriggerHelper objInventoryTriggerHelper = new InventoryTransactionTriggerHelper();
    }
    
    /**
    * @description  : Method for after Insert Event of trigger
    * @author       : fsuraitawala@addonblue.com
    * @return       : void
    **/
    public override void afterInsert() {
        InventoryTransactionTriggerHelper objInventoryTriggerHelper = new InventoryTransactionTriggerHelper();
    }
    /**
    * @description  : Method for before Delete Event of trigger
    * @author       : fsuraitawala@addonblue.com
    * @return       : void
    **/
    public override void beforeDelete() {
        InventoryTransactionTriggerHelper objInventoryTriggerHelper = new InventoryTransactionTriggerHelper();
    }
    /**
    * @description  : Method for after Delete Event of trigger
    * @author       : fsuraitawala@addonblue.com
    * @return       : void
    **/
    public override void afterDelete() {
        InventoryTransactionTriggerHelper objInventoryTriggerHelper = new InventoryTransactionTriggerHelper();
    }
}
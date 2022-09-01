/**
 * @File Name          : MCShipmentTriggerHandler.cls
 * @Description        : Trigger handler on shipment object
 * @Author             : jthakkar@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 3:18:50 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0     1/27/2020     jthakkar@addonblue.com    Initial Version
 * 1.1     2/3/2020      mpatel@addonblue.com      Refactored the code by changing the name of Handler
**/
public with sharing class MCShipmentTriggerHandler extends TriggerHandler {

    /**
    * @description: Constructor
    * @author mpatel@addonblue.com | 2/28/2020 
    **/
    public MCShipmentTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('zkmulti__MCShipment__c');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
    /**
    * @description  : its a after insert method call while record is created in the shipment object
    * @author       : mpatel@addonblue.com | 1/28/2020
    * @return       : void 
    **/
    public override void afterInsert() {        
        MCShipmentTriggerHelper objMCShipmentTriggerHelper = new MCShipmentTriggerHelper();
    }
    
    /**
    * @description  : its a after update method call while record is updated in the shipment object
    * @author       : mpatel@addonblue.com | 1/28/2020 
    * @return       : void 
    **/
    public override void afterUpdate() {
        MCShipmentTriggerHelper objMCShipmentTriggerHelper = new MCShipmentTriggerHelper();
    }
    /**
    * @description  : its a after delete method call while record is deleted in the shipment object
    * @author       : mpatel@addonblue.com | 1/28/2020 
    * @return       : void 
    **/
    public override void afterDelete() {
        MCShipmentTriggerHelper objMCShipmentTriggerHelper = new MCShipmentTriggerHelper();
    }
    /**
    * @description  : its a after undelete method call while record is undeleted in the shipment object
    * @author       : mpatel@addonblue.com | 1/28/2020 
    * @return       : void 
    **/
    public override void afterUndelete() {
        MCShipmentTriggerHelper objMCShipmentTriggerHelper = new MCShipmentTriggerHelper();
    }
}
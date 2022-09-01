/**
 * @File Name          : OpportunityLineItemTriggerHandler.cls
 * @Description        : Trigger handler on Opportunitylineitem object and calling from the OpportunitylineitemTrigger
 * @Author             : jthakkar@addonblue.com
 * @Group              : 
 * @Last Modified By   : jthakkar@addonblue.com
 * @Last Modified On   : 6/19/2020, 3:00:43 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0     1/27/2020     jthakkar@addonblue.com    Initial Version
 * 1.1     2/3/2020      jthakkar@addonblue.com      Refactored the code by changing the name of Handler
**/
public with sharing class OpportunityLineItemTriggerHandler extends TriggerHandler {

    /**
    * @description: Constructor
    * @author jthakkar@addonblue.com | 2/28/2020 
    **/
    public OpportunityLineItemTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('OpportunityLineItem');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
    
    /**
    * @description  : its a before insert method call while record is created in the opportunity object
    * @author       : jthakkar@addonblue.com | 1/18/2020 
    * @return       : void 
    **/
    public override void beforeInsert() {
        OpportunityLineItemTriggerHelper objOpportunityLineItemTriggerHelper = new OpportunityLineItemTriggerHelper();
    }
    /**
    * @description  : its a before update method call while record is updated in the opportunity object
    * @author       : jthakkar@addonblue.com | 1/28/2020 
    * @return       : void 
    **/
    public override void beforeUpdate() {        
        OpportunityLineItemTriggerHelper objOpportunityLineItemTriggerHelper = new OpportunityLineItemTriggerHelper();
    }
    /**
    * @description  : its a after insert method call while record is created in the opportunity object
    * @author       : jthakkar@addonblue.com | 1/28/2020
    * @return       : void 
    **/
    public override void afterInsert() {        
        OpportunityLineItemTriggerHelper objOpportunityLineItemTriggerHelper = new OpportunityLineItemTriggerHelper();
    }
    
    /**
    * @description  : its a after update method call while record is updated in the opportunity object
    * @author       : jthakkar@addonblue.com | 1/28/2020 
    * @return       : void 
    **/
    public override void afterUpdate() {
        OpportunityLineItemTriggerHelper objOpportunityLineItemTriggerHelper = new OpportunityLineItemTriggerHelper();  
    }
    /**
    * @description  : its a after delete method call while record is deleted in the opportunity object
    * @author       : jthakkar@addonblue.com | 1/28/2020 
    * @return       : void 
    **/
    public override void afterDelete() {
        OpportunityLineItemTriggerHelper objOpportunityLineItemTriggerHelper = new OpportunityLineItemTriggerHelper();
    }
}
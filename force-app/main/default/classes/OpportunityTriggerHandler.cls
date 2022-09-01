/**
 * @File Name          : OpportunityTriggerHandler.cls
 * @Description        : Trigger handler on Opportunity object and calling from the OpportunityTrigger
 * @Author             : jthakkar@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 12-17-2020
 * @Modification Log   : 
 * @Unit Test          : QE360V3_opportunityHandler_Test
 * Ver       Date            Author                 Modification
 * 1.0     1/27/2020     jthakkar@addonblue.com    Initial Version
 * 1.1     2/3/2020      mpatel@addonblue.com      Refactored the code by changing the name of Handler
**/
public with sharing class OpportunityTriggerHandler extends TriggerHandler {

    /**
    * @description: Constructor
    * @author mpatel@addonblue.com | 2/28/2020 
    **/
    public OpportunityTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Opportunity');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
    
    /**
    * @description  : its a before insert method call while record is created in the opportunity object
    * @author       : mpatel@addonblue.com | 1/18/2020 
    * @return       : void 
    **/
    public override void beforeInsert() {
        OpportunityTriggerHelper objOpportunityTriggerHelper = new OpportunityTriggerHelper();
    }
    /**
    * @description  : its a before update method call while record is updated in the opportunity object
    * @author       : mpatel@addonblue.com | 1/28/2020 
    * @return       : void 
    **/
    public override void beforeUpdate() {        
        OpportunityTriggerHelper objOpportunityTriggerHelper = new OpportunityTriggerHelper();
    }
     /**
    * @description  : its a before delete method call while record is deleted in the opportunity object
    * @author       : jagrawal@addonblue.com | 1/28/2020 
    * @return       : void 
    **/
    public override void beforeDelete() {        
        OpportunityTriggerHelper objOpportunityTriggerHelper = new OpportunityTriggerHelper();
    }
    /**
    * @description  : its a after insert method call while record is created in the opportunity object
    * @author       : mpatel@addonblue.com | 1/28/2020
    * @return       : void 
    **/
    public override void afterInsert() {        
        OpportunityTriggerHelper objOpportunityTriggerHelper = new OpportunityTriggerHelper();
    }
    
    /**
    * @description  : its a after update method call while record is updated in the opportunity object
    * @author       : mpatel@addonblue.com | 1/28/2020 
    * @return       : void 
    **/
    public override void afterUpdate() {
        OpportunityTriggerHelper objOpportunityTriggerHelper = new OpportunityTriggerHelper();  
    }
    /**
    * @description  : its a after delete method call while record is deleted in the opportunity object
    * @author       : mpatel@addonblue.com | 1/28/2020 
    * @return       : void 
    **/
    public override void afterDelete() {
        OpportunityTriggerHelper objOpportunityTriggerHelper = new OpportunityTriggerHelper();
    }
}
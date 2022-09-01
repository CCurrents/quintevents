/**
 * @File Name          : OpportunityContactRoleTriggerHandler.cls
 * @Description        : Trigger handler on OpportunityContactRole object and calling from the OpportunityContactRoleTrigger
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 11/11/2020
 * @Modification Log   : 
 * @Unit Test          : 
 * Ver       Date            Author                 Modification
 * 1.0     11/11/2020     kchavda@addonblue.com    Initial Version

**/
public with sharing class OpportunityContactRoleTriggerHandler extends TriggerHandler {

    /**
    * @description: Constructor
    * @author kchavda@addonblue.com | 11/11/2020
    **/
    public OpportunityContactRoleTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('OpportunityContactRoleChangeEvent');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
   
    /**
    * @description  : its a after insert method call while record is created in the OpportunityContactRole object
    * @author       : kchavda@addonblue.com | 11/11/2020
    * @return       : void 
    **/
    public override void afterInsert() {        
        OpportunityContactRoleTriggerHelper objOpportunityContactRoleTriggerHelper = new OpportunityContactRoleTriggerHelper();
    }
    
    
}
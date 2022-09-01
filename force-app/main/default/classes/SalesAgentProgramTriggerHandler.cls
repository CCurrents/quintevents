/**
 * @File Name          : SalesAgentProgramTriggerHandler.cls
 * @Description        : 
 * @Author             : jthakkar@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 3:24:30 AM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    27/1/2020   jthakkar@addonblue.com     Initial Version
**/
global class SalesAgentProgramTriggerHandler extends TriggerHandler{ 

    /**
    * @description: Constructor
    * @author jthakkar@addonblue.com | 2/3/2020 
    **/    
    public SalesAgentProgramTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Sales_Agent_Program__c');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
   
    /**
    * @description  : after insert trigger call
    * @author       : jthakkar@addonblue.com | 28/2/2020 
    * @param        : 
    * @return       : 
    **/    
    public override void afterInsert() {
        SalesAgentProgramTriggerHelper salesAgentProgramTriggerHelper = new SalesAgentProgramTriggerHelper();
    }
}
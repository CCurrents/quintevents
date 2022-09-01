/**
 * @File Name          : DocuSignStatusTriggerHandler.cls
 * @Description        : 
 * @Author             : jthakkar@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 3:15:37 AM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    3/3/2020   jthakkar@addonblue.com     Initial Version
**/
global class DocuSignStatusTriggerHandler extends TriggerHandler{
    /**
    * @description: Constructor
    * @author jthakkar@addonblue.com | 2/3/2020 
    **/
    public DocuSignStatusTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('dsfs__DocuSign_Status__c');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
    
    /**
    * @description  : after insert trigger call
    * @author       : jthakkar@addonblue.com | 3/3/2020 
    * @param        : 
    * @return       : 
    **/   
    /*********************************************************************************/
    public override void afterInsert() {
        DocuSignStatusTriggerHelper docuSignStatusTriggerHelper = new DocuSignStatusTriggerHelper();
    }
    
    /**
    * @description  : after update trigger call
    * @author       : jthakkar@addonblue.com | 3/3/2020 
    * @param        : 
    * @return       : 
    **/   
    /*********************************************************************************/
    public override void afterUpdate() {
        DocuSignStatusTriggerHelper docuSignStatusTriggerHelper = new DocuSignStatusTriggerHelper();
    }
}
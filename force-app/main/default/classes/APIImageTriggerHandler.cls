/**
 * @File Name          : APIImageTriggerHandler.cls
 * @Description        : 
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 09/17/2020, 2:52:12 AM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    09/17/2020   mpatel@addonblue.com     Initial Version
**/
global class APIImageTriggerHandler extends TriggerHandler{
        
    /**
    * @description: Constructor
    * @author mpatel@addonblue.com | 09/17/2020  
    **/
    public APIImageTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('API_Image__c');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
    
    /**
    * @description  : after delete trigger call
    * @author       : mpatel@addonblue.com | 09/17/2020
    * @param        : 
    * @return       : 
    **/     
    public override void afterDelete() {
        APIImageTriggerHelper APIImageTriggerHelper = new APIImageTriggerHelper();
    }
}
/**
 * @File Name          : ProgramTriggerHandler.cls
 * @Description        : Helper class for ProgramTriggerHandler
 * @Author             : vaibhav.khopade@addonblue.com
 * @Group              : 
 * @Last Modified By   : vaibhav.khopadea@addonblue.com
 * @Last Modified On   : 05-23-2022
 * @Modification Log   : 
 * Ver       Date            Author                  		Modification
 * 1.0    05/23/2022   vaibhav.khopade@addonblue.com     	Initial Version, created for issue 1194

**/
global class ProgramTriggerHandler extends TriggerHandler{
    public ProgramTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Program__c');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
    
    public override void afterUpdate() {
        ProgramTriggerHelper objProgramTriggerHelper = new ProgramTriggerHelper();
    }
}
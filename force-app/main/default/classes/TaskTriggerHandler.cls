/**
 * @File Name          : TaskTriggerHandler.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 3:25:17 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/03/2020   jagrawal@addonblue.com     Initial Version
**/
public class TaskTriggerHandler extends TriggerHandler {
    
    /**
    * @description Constructor
    * @author jagrawal@addonblue.com | 11/3/2020 
    * @return void 
    **/
    public TaskTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Task');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
    
    /**
    * @description Before Insert Trigger Event Handling method
    * @author jagrawal@addonblue.com | 11/3/2020 
    * @return void 
    **/
    public override void beforeInsert() {
        TaskTriggerHelper objTaskTriggerHelper = new TaskTriggerHelper();
    }

    /**
    * @description After Insert Trigger Event Handling method
    * @author jagrawal@addonblue.com | 11/3/2020 
    * @return void 
    **/
    public override void afterInsert() {
        TaskTriggerHelper objTaskTriggerHelper = new TaskTriggerHelper();
    }

    /**
    * @description After Update Trigger Event Handling method
    * @author jagrawal@addonblue.com | 11/3/2020 
    * @return void 
    **/
    public override void afterUpdate() {
        TaskTriggerHelper objTaskTriggerHelper = new TaskTriggerHelper();
    }
    
}
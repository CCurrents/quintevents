/**
 * @File Name          : ContactTriggerHandler.cls
 * @Description        : Handle trigger's events of Contact object
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 01-26-2021
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    8/23/2019   fsuraitawala@addonblue.com     Initial Version
**/
public class ContactTriggerHandler extends TriggerHandler {
    
    /**
    * @description: Constructor
    * @author: fsuraitawala@addonblue.com
    **/
    public ContactTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Contact');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }

    /**
    * @description: Method for before insert event of trigger
    * @author: jagrawal@addonblue.com
    * @return: void 
    **/
    public override void beforeInsert() {
        ContactTriggerHelper objContactTriggerHelper = new ContactTriggerHelper();
    }

    /**
    * @description: Method for before update event of trigger
    * @author: jagrawal@addonblue.com
    * @return: void 
    **/
    public override void beforeUpdate() {
        ContactTriggerHelper objContactTriggerHelper = new ContactTriggerHelper();
    }
    
    /**
    * @description: Method for after insert event of trigger
    * @author: fsuraitawala@addonblue.com
    * @return: void 
    **/
    public override void afterInsert() {
        ContactTriggerHelper objContactTriggerHelper = new ContactTriggerHelper();
    }
    
    /**
    * @description: Method for after update event of trigger
    * @author: fsuraitawala@addonblue.com
    * @return: void 
    **/
    public override void afterUpdate() {
        ContactTriggerHelper objContactTriggerHelper = new ContactTriggerHelper();
    }
}
/**
 * @description       : 
 * @author            : jagrawal@addonblue.com
 * @group             : 
 * @last modified on  : 01-26-2021
 * @last modified by  : Jheel Agrawal
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   01-26-2021   jagrawal@addonblue.com   Initial Version
**/
public class LeadTriggerHandler extends TriggerHandler {

    public LeadTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Lead');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }

    /**
    * @description: Method for before insert event of trigger
    * @author: jagrawal@addonblue.com
    * @return: void 
    **/
    public override void beforeInsert() {
        LeadTriggerHelper objLeadTriggerHelper = new LeadTriggerHelper();
    }

    /**
    * @description: Method for before update event of trigger
    * @author: jagrawal@addonblue.com
    * @return: void 
    **/
    public override void beforeUpdate() {
        LeadTriggerHelper objLeadTriggerHelper = new LeadTriggerHelper();
    }
    
    /**
    * @description: Method for after insert event of trigger
    * @author: jagrawal@addonblue.com
    * @return: void 
    **/
    public override void afterInsert() {
        LeadTriggerHelper objLeadTriggerHelper = new LeadTriggerHelper();
    }
    
    /**
    * @description: Method for after update event of trigger
    * @author: jagrawal@addonblue.com
    * @return: void 
    **/
    public override void afterUpdate() {
        LeadTriggerHelper objLeadTriggerHelper = new LeadTriggerHelper();
    }
}
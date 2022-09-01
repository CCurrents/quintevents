/**
 * @File Name          : AccountTriggerHandler.trigger
 * @Description        : Handler trigger's events of Account object.
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 01-26-2021
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    5/18/2020       mpatel@addonblue.com       Initial Version
**/
public class AccountTriggerHandler extends TriggerHandler {
    
    /**
    * @description: Constructor
    * @author: mpatel@addonblue.com
    **/
    public AccountTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Account');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }

    /**
    * @description: Method for before insert event of trigger
    * @author: jagrawal@addonblue.com
    * @return: void 
    **/
    public override void beforeInsert() {
        AccountTriggerHelper objAccountTriggerHelper = new AccountTriggerHelper ();
    }

    /**
    * @description: Method for before update event of trigger
    * @author: jagrawal@addonblue.com
    * @return: void 
    **/
    public override void beforeUpdate() {
        AccountTriggerHelper objAccountTriggerHelper = new AccountTriggerHelper ();
    }
    
    /**
    * @description: Method for after insert event of trigger
    * @author: mpatel@addonblue.com
    * @return: void 
    **/
    public override void afterInsert() {
        AccountTriggerHelper objAccountTriggerHelper = new AccountTriggerHelper ();
    }
    
    /**
    * @description: Method for after update event of trigger
    * @author: mpatel@addonblue.com
    * @return: void 
    **/
    public override void afterUpdate() {
        AccountTriggerHelper objAccountTriggerHelper = new AccountTriggerHelper ();
    }
}
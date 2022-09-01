/**
 * @File Name          : QuoteTriggerHandler.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 6/18/2020, 3:19:34 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0      9/3/2020    jagrawal@addonblue.com      Initial Version
 * 1.1      6/18/2020   jagrawal@addonblue.com      Added After Delete Method
**/
public class QuoteTriggerHandler extends TriggerHandler {
    
    /**
    * @description Constructor
    * @author jagrawal@addonblue.com | 9/3/2020 
    * @return void 
    **/
    public QuoteTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Quote');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }

    /**
    * @description Before Insert Trigger Event Handling method
    * @author jagrawal@addonblue.com | 9/3/2020 
    * @return void 
    **/
    public override void beforeInsert() {
        QuoteTriggerHelper objQuoteTriggerHelper = new QuoteTriggerHelper();
    }

    /**
    * @description Before Update Trigger Event Handling method
    * @author jagrawal@addonblue.com | 9/3/2020 
    * @return void 
    **/
    public override void beforeUpdate() {
        QuoteTriggerHelper objQuoteTriggerHelper = new QuoteTriggerHelper();
    }

    /**
    * @description Before Delete Trigger Event Handling method
    * @author jagrawal@addonblue.com | 6/18/2020 
    * @return void 
    **/
    public override void beforeDelete() {
        QuoteTriggerHelper objQuoteTriggerHelper = new QuoteTriggerHelper();
    }

    /**
    * @description After Insert Trigger Event Handling method
    * @author jagrawal@addonblue.com | 9/3/2020 
    * @return void 
    **/
    public override void afterInsert() {
        QuoteTriggerHelper objQuoteTriggerHelper = new QuoteTriggerHelper();
    }

    /**
    * @description After Update Trigger Event Handling method
    * @author jagrawal@addonblue.com | 9/3/2020 
    * @return void 
    **/
    public override void afterUpdate() {
        QuoteTriggerHelper objQuoteTriggerHelper = new QuoteTriggerHelper();
    }
}
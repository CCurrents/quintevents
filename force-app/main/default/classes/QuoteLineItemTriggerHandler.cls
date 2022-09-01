/**
 * @File Name          : QuoteLineItemTriggerHandler.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 10-07-2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    11/3/2020   jagrawal@addonblue.com     Initial Version
**/
public class QuoteLineItemTriggerHandler extends TriggerHandler {
 
    /**
    * @description Constructor
    * @author jagrawal@addonblue.com | 11/3/2020 
    * @return void 
    **/
    public QuoteLineItemTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('QuoteLineItem');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
    
    /**
    * @description Before Insert Trigger Event Handling method
    * @author jagrawal@addonblue.com | 11/3/2020 
    * @return void 
    **/
    public override void beforeInsert() {
        QuoteLineItemTriggerHelper objQuoteLineItemTriggerHelper = new QuoteLineItemTriggerHelper();
    }

    /**
    * @description Before Delete Trigger Event Handling method
    * @author fsuraitawala@addonblue.com | 10/07/2021 
    * @return void 
    **/
    public override void beforeDelete() {
        QuoteLineItemTriggerHelper objQuoteLineItemTriggerHelper = new QuoteLineItemTriggerHelper();
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 4/3/2020 
    * @return void 
    **/ 
    public override void beforeUpdate(){
        QuoteLineItemTriggerHelper objQuoteLineItemTriggerHelper = new QuoteLineItemTriggerHelper();
    }

    /**
    * @description After Insert Trigger Event Handling method
    * @author jagrawal@addonblue.com | 11/3/2020 
    * @return void 
    **/
    public override void afterInsert() {
        QuoteLineItemTriggerHelper objQuoteLineItemTriggerHelper = new QuoteLineItemTriggerHelper();
    }

    /**
    * @description After Update Trigger Event Handling method
    * @author jagrawal@addonblue.com | 11/3/2020 
    * @return void 
    **/
    public override void afterUpdate() {
        QuoteLineItemTriggerHelper objQuoteLineItemTriggerHelper = new QuoteLineItemTriggerHelper();
    }
    
    /**
    * @description After Delete Trigger Event Handling method
    * @author jthakkar@addonblue.com | 11/3/2020 
    * @return void 
    **/
    public override void afterDelete() {
        QuoteLineItemTriggerHelper objQuoteLineItemTriggerHelper = new QuoteLineItemTriggerHelper();
    }
}
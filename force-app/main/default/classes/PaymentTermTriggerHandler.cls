/**
 * @File Name          : PaymentTermTriggerHandler.cls
 * @Description        : Trigger handler on Opportunity payment term object and calling from the OpportunityPaymentTermTrigger
 * @Author             : jthakkar@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/16/2020, 3:21:11 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0     1/27/2020     jthakkar@addonblue.com    Initial Version
 * 1.1     2/3/2020      mpatel@addonblue.com      Refactored the code by changing the name of Handler
 * 1.2    09/22/2020    kchavda@addonblue.com           #542 Revenue fields on Order
**/
public with sharing class PaymentTermTriggerHandler extends TriggerHandler {

    /**
    * @description: Constructor
    * @author mpatel@addonblue.com | 2/28/2020 
    **/
    public PaymentTermTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Payment_Term__c');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
    /**
    * @description  : its a before delete method call while record is deleted in the Opportunity Payment Term  object
    * @author       : mpatel@addonblue.com | 1/28/2020 
    * @return       : void 
    **/
    public override void beforeDelete() {
        PaymentTermTriggerHelper objPaymentTermTriggerHelper = new PaymentTermTriggerHelper();
    }
    
    /**
    * @description  : its a after insert method call while record is created in the Opportunity Payment Term object
    * @author       : mpatel@addonblue.com | 1/28/2020
    * @return       : void 
    **/
    public override void afterInsert() {        
        PaymentTermTriggerHelper objPaymentTermTriggerHelper = new PaymentTermTriggerHelper();
    }
    
    /**
    * @description  : its a after update method call while record is updated in the Opportunity Payment Term object
    * @author       : mpatel@addonblue.com | 1/28/2020 
    * @return       : void 
    **/
    public override void afterUpdate() {
        PaymentTermTriggerHelper objPaymentTermTriggerHelper = new PaymentTermTriggerHelper();
    }
    /**
    * @description  : its a after delete method call while record is deleted in the Opportunity Payment Term object
    * @author       : mpatel@addonblue.com | 1/28/2020 
    * @return       : void 
    **/
    public override void afterDelete() {
        PaymentTermTriggerHelper objPaymentTermTriggerHelper = new PaymentTermTriggerHelper();
    }
    
    /**
    * @description  : After undelete method execute while record is restored from recyclebin
    * @author       : kchavda@addonblue.com | 09/22/2020 
    * @return       : void 
    **/
    public override void afterUnDelete() {
        PaymentTermTriggerHelper objPaymentTermTriggerHelper = new PaymentTermTriggerHelper();
    }
}
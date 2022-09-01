public with sharing class RefundTriggerHandler extends TriggerHandler {

    public RefundTriggerHandler(){
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Refund__c');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }

    public override void afterInsert() {
        RefundTriggerHelper obRefundTriggerHelper = new RefundTriggerHelper();
    }
    
    public override void afterUpdate() {
        RefundTriggerHelper obRefundTriggerHelper = new RefundTriggerHelper();
    }
}
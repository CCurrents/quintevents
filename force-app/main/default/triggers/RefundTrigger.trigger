trigger RefundTrigger on Refund__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Refund__c');
    if(!triggerSetting.Deactivate__c){
        new RefundTriggerHandler().run();
    }
}
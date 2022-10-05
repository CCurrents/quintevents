/**
 * Created by joshlequire1 on 9/20/22.
 */

trigger ConsentTransactionTrigger on ConsentTransaction__c (after insert, after update) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('ConsentTransaction__c');
    if (!triggerSetting.Deactivate__c) {

        // ALWAYS process the Campaign Member relationship on insert
        if (Trigger.isInsert) {
            ConsentTransactionTriggerHandler.processCampaignMemberRelationships(Trigger.new);
        }

        // ONLY process the Campaign Member relationship after update when a change to Program__c occurs
        if (Trigger.isUpdate) {
            List<ConsentTransaction__c> recordsToProcess = new List<ConsentTransaction__c>();

            for (ConsentTransaction__c ct : Trigger.newMap.values()) {
                if (ct.Program__c != null && (ct.Program__c != Trigger.oldMap.get(ct.Id).Program__c)) {
                    recordsToProcess.add(ct);
                }
            }
            if(recordsToProcess.size() >0){
                ConsentTransactionTriggerHandler.processCampaignMemberRelationships(Trigger.new);
            }
        }
    }

}
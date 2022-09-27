/**
 * Created by joshlequire1 on 9/20/22.
 */

trigger ConsentTransactionTrigger on ConsentTransaction__c (after insert) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('ConsentTransaction__c');
    if(!triggerSetting.Deactivate__c){
        ConsentTransactionTriggerHandler.processCampaignMemberRelationships(Trigger.new);
    }

}
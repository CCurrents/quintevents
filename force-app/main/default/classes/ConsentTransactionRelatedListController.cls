/**
 * Created by joshlequire1 on 9/19/22.
 */

public with sharing class ConsentTransactionRelatedListController {

    @AuraEnabled(Cacheable=true)
    public static List<ConsentTransaction__c> getConsentTransactionsForCampaignMember(Id recordId) {
        List<ConsentTransaction__c> consentRecords = [SELECT Id, Name, Contact__r.Name, Lead__r.Name, Type__c, QNGInfoRequest__r.Name, CreatedDate FROM ConsentTransaction__c WHERE CampaignMemberId__c = :recordId ORDER BY CreatedDate DESC];

        return consentRecords;

    }

}
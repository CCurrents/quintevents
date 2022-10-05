/**
 * Created by joshlequire1 on 9/20/22.
 */

public without sharing class CampaignSelector {

    public static Campaign getCampaignByContactSite(String contactSite){
        Campaign cpgn = [SELECT Id, Program__c FROM Campaign WHERE ContactSite__c = :contactSite AND Program__c != NULL AND IsActive = TRUE AND Type = 'Email' ORDER BY CreatedDate DESC LIMIT 1][0];

        return cpgn;
    }

    public static List<Campaign> getCampaignsByProgramIds (Set<Id> programIds){
        List<Campaign> cpgns = [SELECT Id, Program__c FROM Campaign WHERE Program__c IN :programIds];

        return cpgns;
    }

}
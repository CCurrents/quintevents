/**
 * Created by joshlequire1 on 9/20/22.
 */

public without sharing class CampaignMemberSelector {

    public static List<CampaignMember> getCampaignMembersForProgramIds(Set<Id> programIds, Set<Id> leadIds, Set<Id> contactIds){
        List<CampaignMember> cms = [SELECT Id, CampaignId, Campaign.Program__c, LeadId, ContactId, Status FROM CampaignMember WHERE Campaign.Program__c IN :programIds AND (LeadId IN :leadIds OR ContactId IN :contactIds)];

        return cms;
    }

}
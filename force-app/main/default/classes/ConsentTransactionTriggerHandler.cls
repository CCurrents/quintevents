/**
 * Created by joshlequire1 on 9/20/22.
 */

public without sharing class ConsentTransactionTriggerHandler {

    public static void processCampaignMemberRelationships(List<ConsentTransaction__c> newCTs) {
        Set<Id> programIds = new Set<Id>();
        List<ConsentTransaction__c> ctUpdatesFromMatchedCMs = new List<ConsentTransaction__c>();
        List<ConsentTransaction__c> ctUpdatesFromNewCMs = new List<ConsentTransaction__c>();
        Map<Id, Campaign> programIdsToCampaigns = new Map<Id, Campaign>();
        Map<Id, ConsentTransaction__c> leadCTsToProcess = new Map<Id, ConsentTransaction__c>();
        Map<Id, ConsentTransaction__c> contactCTsToProcess = new Map<Id, ConsentTransaction__c>();
        Set<Id> matchedCTsInCMs = new Set<Id>();
        List<CampaignMember> newCMs = new List<CampaignMember>();
        Map<String, Id> ctToNewCMMap = new Map<String, Id>();

        for (ConsentTransaction__c ct : newCTs) {
            if (ct.Program__c != null) {
                programIds.add(ct.Program__c);

                if (ct.Contact__c != null) {
                    contactCTsToProcess.put(ct.Contact__c, ct);
                }

                if (ct.Lead__c != null) {
                    leadCTsToProcess.put(ct.Lead__c, ct);
                }

            }
        }

        if (programIds.size() > 0) {

            // get Campaigns for Program Ids
            for (Campaign cp : CampaignSelector.getCampaignsByProgramIds(programIds)) {
                programIdsToCampaigns.put(cp.Program__c, cp);
            }

            if (programIdsToCampaigns.size() > 0) {
                // Get matched Campaign Members for this list of CTs
                for (CampaignMember cm : CampaignMemberSelector.getCampaignMembersForProgramIds(programIds, leadCTsToProcess.keySet(), contactCTsToProcess.keySet())) {
                    ConsentTransaction__c ctUpdate = new ConsentTransaction__c();

                    if (cm.ContactId != null) {
                        ctUpdate.Id = contactCTsToProcess.get(cm.ContactId).Id;
                        matchedCTsInCMs.add(ctUpdate.Id);
                        ctUpdate.CampaignMemberId__c = cm.Id;
                        ctUpdatesFromMatchedCMs.add(ctUpdate);
                    }

                    if (cm.LeadId != null) {
                        ctUpdate.Id = leadCTsToProcess.get(cm.LeadId).Id;
                        matchedCTsInCMs.add(ctUpdate.Id);
                        ctUpdate.CampaignMemberId__c = cm.Id;
                        ctUpdatesFromMatchedCMs.add(ctUpdate);
                    }

                }

                // Create new Campaign members for CTs that were not matched
                for (ConsentTransaction__c ct : newCTs) {
                    if (!matchedCTsInCMs.contains(ct.Id)) {
                        CampaignMember newCM = new CampaignMember();
                        newCM.CampaignId = programIdsToCampaigns.get(ct.Program__c).Id;

                        if (ct.Contact__c != null) {
                            newCM.ContactId = ct.Contact__c;
                            String campaignContactValue = String.valueOf(newCM.CampaignId) + String.valueOf(newCM.ContactId);
                            ctToNewCMMap.put(campaignContactValue, ct.Id);
                        }

                        else if (ct.Lead__c != null) {
                            newCM.LeadId = ct.Lead__c;
                            String campaignLeadValue = String.valueOf(newCM.CampaignId) + String.valueOf(newCM.LeadId);
                            ctToNewCMMap.put(campaignLeadValue, ct.Id);
                        }

                        newCMs.add(newCM);

                    }
                }

                // Run the DML Calls

                try {
                    if (ctUpdatesFromMatchedCMs.size() > 0) {
                        Utility.processRecords(ctUpdatesFromMatchedCMs, 'update');
                    }

                    if (newCMs.size() > 0) {
                        Utility.processRecords(newCMs, 'insert');

                        for (CampaignMember cm : newCMs) {
                            ConsentTransaction__c ct = new ConsentTransaction__c();

                            if (cm.ContactId != null) {
                                String campaignContactValue = String.valueOf(cm.CampaignId) + String.valueOf(cm.ContactId);
                                ct.Id = ctToNewCMMap.get(campaignContactValue);
                                ct.CampaignMemberId__c = cm.Id;
                                ctUpdatesFromNewCMs.add(ct);
                            }

                            else if (cm.LeadId != null) {
                                String campaignLeadValue = String.valueOf(cm.CampaignId) + String.valueOf(cm.LeadId);
                                ct.Id = ctToNewCMMap.get(campaignLeadValue);
                                ct.CampaignMemberId__c = cm.Id;
                                ctUpdatesFromNewCMs.add(ct);
                            }

                        }

                        if (ctUpdatesFromNewCMs.size() > 0) {
                            Utility.processRecords(ctUpdatesFromNewCMs, 'update');
                        }

                    }

                } catch (DmlException e) {
                    System.debug('Error occurred: ' + e.getMessage() + e.getCause());
                }
            }
        }

    }


}
/**
 * Created by joshlequire1 on 10/5/22.
 */

@IsTest
private class ConsentTransactionTriggerHandlerTest {

    @TestSetup
    static void createTestData() {
        TestDataFactory.createCampaignMemberHarness();
    }

    @IsTest
    static void testCreateConsentTransactions() {

        Test.startTest();

        Campaign testCampaign = [SELECT Id, Program__c, Name FROM Campaign WHERE Name = 'Test Campaign'][0];
        Map<Id, CampaignMember> existingLeadCampaignMembers = new Map<Id, CampaignMember>();
        Map<Id, CampaignMember> existingContactCampaignMembers = new Map<Id, CampaignMember>();
        for (CampaignMember cm : [SELECT Id, LeadId, ContactId, CampaignId, Status FROM CampaignMember WHERE CampaignId = :testCampaign.Id]) {
            if (cm.ContactId != null) {
                existingContactCampaignMembers.put(cm.ContactId, cm);
            }

            else if (cm.LeadId != null) {
                existingLeadCampaignMembers.put(cm.LeadId, cm);
            }
        }

        // Test Creation of new CMs for Leads without Campaign Members, for the same Program
        List<ConsentTransaction__c> ctsWithoutExistingCMs = new List<ConsentTransaction__c>();
        Set<Id> leadsWithNewCMsCreated = new Set<Id>();
        for (Lead ld : [SELECT Id FROM Lead WHERE Id NOT IN :existingLeadCampaignMembers.keySet() LIMIT 5]) {
            ConsentTransaction__c newCT = new ConsentTransaction__c();
            leadsWithNewCMsCreated.add(ld.Id);
            newCT.Lead__c = ld.Id;
            newCT.CurrencyIsoCode = CONSTANTS.CURRENCY_ISO_CODE_USD;
            newCT.Source__c = CONSTANTS.CONSENT_TRANSACTION_SOURCE_WEBFORM;
            newCT.ContactSite__c = CONSTANTS.CAMPAIGN_CONTACT_SITE_TEST_VALUE;
            newCT.Program__c = testCampaign.Program__c;
            ctsWithoutExistingCMs.add(newCT);
        }

        List<CampaignMember> newLeadCMs = Utility.processRecords(ctsWithoutExistingCMs, 'insert');

        List<CampaignMember> existngCMsForNewCTs = [SELECT LeadId, ContactId, CampaignId FROM CampaignMember WHERE LeadId IN :existingLeadCampaignMembers.keySet() OR ContactId IN :existingContactCampaignMembers.keySet()];

        Integer existingLeadCMCounter = 0;
        Integer existingContactCMCounter = 0;
        List<ConsentTransaction__c> newCtsForExistingCMs = new List<ConsentTransaction__c>();
        Set<Id> existingLeadCMsSelected = new Set<Id>();
        Set<Id> existingContactCMsSelected = new Set<Id>();

        for (CampaignMember cm : existngCMsForNewCTs) {
            if (existingContactCMCounter < 2 && cm.ContactId != null) {
                ConsentTransaction__c newCT = new ConsentTransaction__c();
                newCT.Contact__c = cm.ContactId;
                newCT.CurrencyIsoCode = CONSTANTS.CURRENCY_ISO_CODE_USD;
                newCT.Source__c = CONSTANTS.CONSENT_TRANSACTION_SOURCE_WEBFORM;
                newCT.ContactSite__c = CONSTANTS.CAMPAIGN_CONTACT_SITE_TEST_VALUE;
                newCT.Program__c = testCampaign.Program__c;
                newCtsForExistingCMs.add(newCT);
                existingContactCMsSelected.add(cm.ContactId);
                existingContactCMCounter++;
            }

            else if (existingLeadCMCounter < 2 && cm.LeadId != null) {
                ConsentTransaction__c newCT = new ConsentTransaction__c();
                newCT.Lead__c = cm.LeadId;
                newCT.CurrencyIsoCode = CONSTANTS.CURRENCY_ISO_CODE_USD;
                newCT.Source__c = CONSTANTS.CONSENT_TRANSACTION_SOURCE_WEBFORM;
                newCT.ContactSite__c = CONSTANTS.CAMPAIGN_CONTACT_SITE_TEST_VALUE;
                newCT.Program__c = testCampaign.Program__c;
                newCtsForExistingCMs.add(newCT);
                existingLeadCMsSelected.add(cm.LeadId);
                existingLeadCMCounter++;
            }
        }

        List<ConsentTransaction__c> newCtsForExistingLeadsContacts = Utility.processRecords(newCtsForExistingCMs, 'insert');

        Test.stopTest();

        // Let's make sure the Test Setup and Data Factory Create Campaign Member Harness did what they were supposed to do to start... A test for the test factory. AND make sure no new CMs were created for these Leads and Contacts.
        System.assert(existingLeadCampaignMembers.size() == 5);
        System.assert(existingContactCampaignMembers.size() == 5);

        // Test how many new Lead CMs were created above and beyond the existing test data, should be 5
        List<CampaignMember> newCMsCreated = [SELECT Id FROM CampaignMember WHERE LeadId NOT IN :existingContactCampaignMembers.keySet()];
        System.assert(newLeadCMs.size() == 5);

        // Test that CTs for Leads with new CMs are updated with the Campaign Member Id
        List<ConsentTransaction__c> requeriedCtsWithoutExistingCMs = [SELECT Id, Lead__c, Program__c, CampaignMemberId__c FROM ConsentTransaction__c WHERE Lead__c IN :leadsWithNewCMsCreated AND CampaignMemberId__c != NULL];
        System.assert(requeriedCtsWithoutExistingCMs.size() == 5);

        // Ensure the CTs created for Existing CMs have those CM campaign Ids on them
        List<ConsentTransaction__c> verifyNewCtsForExistingCMs = [SELECT Id FROM ConsentTransaction__c WHERE (Lead__c IN :existingLeadCMsSelected OR Contact__c IN :existingContactCMsSelected) AND CampaignMemberId__c != NULL];
        System.assert(verifyNewCtsForExistingCMs.size() == 4);
        
    }
}
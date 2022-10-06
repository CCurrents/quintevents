/**
 * Created by joshlequire1 on 10/5/22.
 */

@IsTest
private class ConsentTransactionRLControllerTest {

    @TestSetup
    static void createTestData() {
        TestDataFactory.createCampaignMemberHarness();
    }

    @IsTest
    static void testGetConsentTransactionsForCampaignMember() {
        Campaign testCampaign = [SELECT Id, Program__c FROM Campaign WHERE Name = 'Test Campaign'][0];

        Lead testLead = new Lead();
        CampaignMember testLeadCM = [SELECT Id, LeadId FROM CampaignMember WHERE LeadId != NULL LIMIT 1][0];
        testLead.Id = testLeadCM.LeadId;
        Id leadCMId = testLeadCM.Id;

        Contact testContact = new Contact();
        CampaignMember testContactCM = [SELECT Id, ContactId FROM CampaignMember WHERE ContactId != NULL LIMIT 1][0];
        testContact.Id = testContactCM.ContactId;
        Id contactCMId = testContactCM.Id;

        Test.startTest();

        List<ConsentTransaction__c> newCTs = new List<ConsentTransaction__c>{
                new ConsentTransaction__c(
                        Contact__c = testContact.Id,
                        CurrencyIsoCode = CONSTANTS.CURRENCY_ISO_CODE_USD,
                        Source__c = CONSTANTS.CONSENT_TRANSACTION_SOURCE_WEBFORM,
                        ContactSite__c = CONSTANTS.CAMPAIGN_CONTACT_SITE_TEST_VALUE,
                        Program__c = testCampaign.Program__c,
                        Type__c = CONSTANTS.CONSENT_TRANSACTION_TYPE_OPTIN
                ),
                new ConsentTransaction__c(
                        Lead__c = testLead.Id,
                        CurrencyIsoCode = CONSTANTS.CURRENCY_ISO_CODE_USD,
                        Source__c = CONSTANTS.CONSENT_TRANSACTION_SOURCE_WEBFORM,
                        ContactSite__c = CONSTANTS.CAMPAIGN_CONTACT_SITE_TEST_VALUE,
                        Program__c = testCampaign.Program__c,
                        Type__c = CONSTANTS.CONSENT_TRANSACTION_TYPE_OPTIN
                )
        };

        Utility.processRecords(newCTs, 'insert');

        ConsentTransaction__c contactUnsubscribeCT = new ConsentTransaction__c(
                Contact__c = testContact.Id,
                CurrencyIsoCode = CONSTANTS.CURRENCY_ISO_CODE_USD,
                Source__c = CONSTANTS.CONSENT_TRANSACTION_SOURCE_AGENT,
                Program__c = testCampaign.Program__c,
                Type__c = CONSTANTS.CONSENT_TRANSACTION_TYPE_UNSUBSCRIBE
        );

        Utility.processRecords(contactUnsubscribeCT, 'insert');

        Test.stopTest();

        // Test Lead CM related CTs
        List<ConsentTransaction__c> leadCMCTs = ConsentTransactionRelatedListController.getConsentTransactionsForCampaignMember(leadCMId);
        System.assert(leadCMCTs.size() == 1);

        // Test Contact CM related CTs
        List<ConsentTransaction__c> contactCMCTs = ConsentTransactionRelatedListController.getConsentTransactionsForCampaignMember(contactCMId);
        System.debug(contactCMCTs.size());
        System.assert(contactCMCTs.size() == 2);

    }
}
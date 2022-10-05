/**
 * Created by joshlequire1 on 9/20/22.
 */

public without sharing class CONSTANTS {

    // _global (all)
    public static final String CURRENCY_ISO_CODE_USD = 'USD';

    // Campaign
    public static final Id CAMPAIGN_RECORDTYPE_OTHER = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Other').getRecordTypeId();
    public static final String CAMPAIGN_CONTACT_SITE_VALUE = 'motogppremier.com';

    // ConsentTransaction__c
    public static final String CONSENT_TRANSACTION_TYPE_OPTIN = 'Opt-in';
    //public static final String CONSENT_TRANSACTION_TYPE_UNSUBSCRIBE = 'Unsubscribe';
    public static final String CONSENT_TRANSACTION_SOURCE_WEBFORM = 'Web Form';

    // Lead
    public static final Id LEAD_RECORDTYPE_STANDARD = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();

    // Program__c
    public static final String PROGRAM_CONTACT_SITE_PICKLIST_VALUE = 'barrettjacksonvip.com';

}
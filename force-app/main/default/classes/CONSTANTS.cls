/**
 * Created by joshlequire1 on 9/20/22.
 */

public without sharing class CONSTANTS {

    // _global (all)
    public static final String CURRENCY_ISO_CODE_USD = 'USD';

    // Account
    public static final Id ACCOUNT_RECORDTYPE_PERSONACCOUNT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

    // ConsentTransaction__c
    public static final String CONSENT_TRANSACTION_TYPE_OPTIN = 'Opt-in';
    public static final String CONSENT_TRANSACTION_TYPE_UNSUBSCRIBE = 'Unsubscribe';
    public static final String CONSENT_TRANSACTION_SOURCE_WEBFORM = 'Web Form';
    public static final String CONSENT_TRANSACTION_SOURCE_AGENT = 'Agent';

    // Lead
    public static final Id LEAD_RECORDTYPE_STANDARD = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();

}
/**
 * Created by joshlequire1 on 9/20/22.
 */

public without sharing class CONSTANTS {

    public static final String CONSENT_TRANSACTION_TYPE_OPTIN = 'Opt-in';
    public static final String CONSENT_TRANSACTION_TYPE_UNSUBSCRIBE = 'Unsubscribe';
    public static final Id LEAD_RECORDTYPE_STANDARD = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();

}
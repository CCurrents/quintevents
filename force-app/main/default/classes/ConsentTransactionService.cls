/**
 * Created by joshlequire1 on 9/20/22.
 */

public with sharing class ConsentTransactionService {

    public static ConsentTransaction__c createConsentTransactionFromInfoRequest(QNG_Info_Request__c infoRec, String ctType) {

        ConsentTransaction__c newCT = new ConsentTransaction__c();

        newCT.Program__c = CampaignSelector.getCampaignByContactSite(infoRec.Contact_Site__c)?.Program__c;

        newCT.Contact__c = infoRec.Contact__c;
        newCT.CurrencyIsoCode = 'USD';
        newCT.QNGInfoRequest__c = infoRec.Id;
        newCT.Lead__c = infoRec.Lead__c;
        newCT.Source__c = 'Web Form';
        newCT.ContactSite__c = infoRec.Contact_Site__c;
        newCT.Type__c = ctType;

        insert newCT;

        return newCT;

    }

}
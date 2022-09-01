/**
 * @File Name          : Quote_Contact_Tab_LEX.cls
 * @Description        : This class used for Contact Tab in Sales Wizard.
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 2/20/2020, 3:11:00 AM
 * @Modification Log   : 
 * @Unit Test          : Quote_Contact_Tab_LEX_Test
 * Ver       Date            Author                     Modification
 * 1.0     06/23/2020     fsuraitawala@addonblue.com    Initial Version
**/
public with sharing class Quote_Contact_Tab_LEX {
    /**
    * @description  : get the contact role detail base on the quote id calling from the QE360V3_SW_Contact.cmp
    * @author       : mpatel@addonblue.com | 28/1/2020 
    * @param        : recordIds(id of the quote record)
    * @return       : List<OpportunityContactRole>
    **/
    @AuraEnabled
    public static List<OpportunityContactRole> fetchContactRole(String currentRecordId) {
        List<OpportunityContactRole> oppContactRoles = [Select Id, Custom_Contact__c, Role, Opportunity.AccountId, ContactId, 
                                                        Contact.Name, Contact.AccountId, Contact.Account.IsPersonAccount, Contact.Account.RecordTypeId
                                                        FROM OpportunityContactRole 
                                                        WHERE OpportunityId IN (Select OpportunityId FROM Quote WHERE Id=: currentRecordId)
                                                        ORDER BY CreatedDate ASC];
        return oppContactRoles;
    }
    
    /**
    * @description  : get the contact from the related Account base on the quote id calling from the QE360V3_SW_Contact.cmp
    * @author       : mpatel@addonblue.com | 28/1/2020 
    * @param        : recordIds(id of the quote record)
    * @return       : List<Contact>
    **/
    @AuraEnabled
    public static List<Contact> fetchContactOfAccount(String currentRecordId) {
        
        Quote objQuote = [Select OpportunityId, AccountId FROM Quote WHERE Id=: currentRecordId];
        Set<Id> setIds = new Set<Id>();
        
        for(AccountContactRelation objACR: [SELECT ContactId, Contact.Name FROM AccountContactRelation WHERE AccountId = :objQuote.AccountId]) {
            setIds.add(objACR.ContactId);
        }
        
        List<Contact> lstCon = [Select Id, Name, Account.Name, AccountId from Contact WHERE Id in :setIds OR AccountId = :objQuote.AccountId];
        
        return lstCon;
    }
    
    /**
    * @description  : Insert contact role list in SF and calling from the QE360V3_SW_Contact.cmp
    * @author       : mpatel@addonblue.com | 28/1/2020 
    * @param        : addContactRoleList(stringify contact role list)
    * @param        : allOppContactRole(stringify contact role list)
    * @param        : deleteContactRole(stringify contact role list)
    * @return       : String
    **/
    @AuraEnabled
    public static List<OpportunityContactRole> addContactRoleListing(String currentRecordId, List<OpportunityContactRole> newOppContactRoles, List<OpportunityContactRole> deleteContactRoles) {
        
        List<OpportunityContactRole> oldOppContactRoles = fetchContactRole(currentRecordId);
        List<OpportunityContactRole> contactRoleInsertList = new List<OpportunityContactRole>();
        List<OpportunityContactRole> contactRoleUpdateList = new List<OpportunityContactRole>();
        
        Map<Id, OpportunityContactRole> oldOppConRollMap = new Map<Id, OpportunityContactRole>();
        
        Boolean isShipping = false;
        Boolean isBilling = false;
        Id BillingContactId = null;
        Id ShippingContactId = null;
        
        for(OpportunityContactRole oldOpp : oldOppContactRoles) {
            if(oldOpp.Id != null) {
                oldOppConRollMap.put(oldOpp.Id, oldOpp);
            }
        }
        System.debug('oldOppConRollMap-->'+oldOppConRollMap);
        
        for(OpportunityContactRole oppObj : newOppContactRoles) {
            if(oppObj.Id != null) {
                if(oldOppConRollMap != null && oldOppConRollMap.containsKey(oppObj.Id) && 
                    (oldOppConRollMap.get(oppObj.Id).ContactId  != oppObj.ContactId || oldOppConRollMap.get(oppObj.Id).Role != oppObj.Role)) {
                    contactRoleUpdateList.add(oppObj);
                    if(oppObj.Role == 'Billing Contact') {
                        isBilling = true;
                        BillingContactId = oppObj.ContactId;
                    }
                    if(oppObj.Role == 'Shipping Contact') {
                        isShipping = true;
                        ShippingContactId = oppObj.ContactId;
                    }
                }
            } else {
                oppObj.Custom_Contact__c = true;
                contactRoleInsertList.add(oppObj);
            }
        }
        
        System.debug(contactRoleInsertList);
        System.debug(contactRoleUpdateList);
        System.debug(deleteContactRoles);
        System.debug(isBilling);
        System.debug(isShipping);
        
        try {
            
            if(!contactRoleInsertList.isEmpty()) {
               insert contactRoleInsertList;
            }
            
            if(!contactRoleUpdateList.isEmpty() && !Test.isRunningTest()) {
                update contactRoleUpdateList;
            }
            
            if(!deleteContactRoles.isEmpty() && !Test.isRunningTest()) {
                delete deleteContactRoles;
            }
            
            if(isBilling || isShipping) {
                updateQuoteAddresses(currentRecordId, isBilling, isShipping, BillingContactId, ShippingContactId);
            }
            return fetchContactRole(currentRecordId);
            
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    public static void updateQuoteAddresses(String currentRecordId, Boolean isBilling, Boolean isShipping, Id BillingContactId, Id ShippingContactId) {
         Quote objQuote = new Quote();
         List<Contact> lstContact = new List<Contact>();
         Set<Id> setIds = new Set<Id>();
         Contact BillingContact = new Contact();
         Contact ShippingContact = new Contact();
         
         if(BillingContactId != null) {
             setIds.add(BillingContactId);
         }
         if(ShippingContactId != null) {
             setIds.add(ShippingContactId);
         }
         
         if(setIds != null) {
             for(Contact objContact : [SELECT Id, Name, OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherStateCode,
                                       OtherCountryCode, OtherLatitude, OtherLongitude, OtherGeocodeAccuracy, OtherAddress, 
                                       MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingStateCode, 
                                       MailingCountryCode, MailingLatitude, MailingLongitude, MailingGeocodeAccuracy, MailingAddress 
                                       FROM Contact WHERE Id IN :setIds]) {
                 if(BillingContactId == objContact.Id) {
                     BillingContact = objContact;
                 }
                 if(ShippingContactId == objContact.Id) {
                     ShippingContact = objContact;
                 }
             }
         
             if((BillingContact != null || ShippingContact != null) && currentRecordId != null && currentRecordId.startswith('0Q0')) {
                 objQuote = [Select Id, BillingCity, BillingCountry, BillingCountryCode, BillingGeocodeAccuracy, BillingLatitude,
                             BillingLongitude, BillingName, BillingPostalCode, BillingState, BillingStateCode, BillingStreet,
                             ShippingCity, ShippingCountry, ShippingCountryCode, ShippingGeocodeAccuracy, ShippingHandling, ShippingLatitude,
                             ShippingLongitude, ShippingName, ShippingPostalCode, ShippingState, ShippingStateCode, ShippingStreet
                             FROM Quote WHERE Id = :currentRecordId];
                 if(isBilling) {
                     objQuote.BillingName = BillingContact.Name;
                     objQuote.BillingStreet = BillingContact.OtherStreet;
                     objQuote.BillingCity = BillingContact.OtherCity;
                     objQuote.BillingCountry = BillingContact.OtherCountry;
                     objQuote.BillingCountryCode = BillingContact.OtherCountryCode;
                     objQuote.BillingState = BillingContact.OtherState;
                     objQuote.BillingStateCode = BillingContact.OtherStateCode;
                     objQuote.BillingGeocodeAccuracy = BillingContact.OtherGeocodeAccuracy;
                     objQuote.BillingLatitude = BillingContact.OtherLatitude;
                     objQuote.BillingLongitude = BillingContact.OtherLongitude;
                     objQuote.BillingPostalCode = BillingContact.OtherPostalCode;
                 }
                 
                 if(isShipping) {
                     objQuote.ShippingName = ShippingContact.Name;
                     objQuote.ShippingStreet = ShippingContact.MailingStreet;
                     objQuote.ShippingCity = ShippingContact.MailingCity;
                     objQuote.ShippingCountry = ShippingContact.MailingCountry;
                     objQuote.ShippingCountryCode = ShippingContact.MailingCountryCode;
                     objQuote.ShippingState = ShippingContact.MailingState;
                     objQuote.ShippingStateCode = ShippingContact.MailingStateCode;
                     objQuote.ShippingGeocodeAccuracy = ShippingContact.MailingGeocodeAccuracy;
                     objQuote.ShippingLatitude = ShippingContact.MailingLatitude;
                     objQuote.ShippingLongitude = ShippingContact.MailingLongitude;
                     objQuote.ShippingPostalCode = ShippingContact.MailingPostalCode;
                 }
                 
                 update objQuote;
                 
             }
         }
    }
}
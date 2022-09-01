/**
 * @File Name          : SW_Contact_LEX.cls
 * @Description        : Creating the contact role calling from the QE360V3_LeadConvertClass_LEX.cmp
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 2/20/2020, 3:11:00 AM
 * @Modification Log   : 
 * @Unit Test          : QE360V3_ContactTabController_LEX_Test
 * Ver       Date            Author                     Modification
 * 1.0     9/10/2020     mpatel@addonblue.com      Initial Version
**/
public with sharing class SW_Contact_LEX {
    /**
    * @description  : get the contact role detail base on the quote id calling from the QE360V3_SW_Contact.cmp
    * @author       : mpatel@addonblue.com | 28/1/2020 
    * @param        : recordIds(id of the quote record)
    * @return       : List<OpportunityContactRole>
    **/
    @AuraEnabled
    public static List<OpportunityContactRole> fetchContactRole(String recordIds){
        System.debug('recordId-->'+recordIds);
        Opportunity opp = [Select id,(Select id,Contact.Name,ContactId,Custom_Contact__c,Role,Opportunity.AccountId from OpportunityContactRoles Order by Custom_Contact__c ASC) from Opportunity where Id IN (Select OpportunityId from quote where id=: recordIds)];
        System.debug(opp.OpportunityContactRoles.size());
        System.debug(opp.OpportunityContactRoles);
        return opp.OpportunityContactRoles;
    }
    /**
    * @description  : get the contact from the related Account base on the quote id calling from the QE360V3_SW_Contact.cmp
    * @author       : mpatel@addonblue.com | 28/1/2020 
    * @param        : recordIds(id of the quote record)
    * @return       : List<Contact>
    **/
    @AuraEnabled
    public static List<Contact> fetchContactOfAccount(String recordIds){
        Account account = [Select id,(Select id from Contacts) from Account where Id IN (Select AccountId from Quote where id=: recordIds)];
        return account.Contacts;
    }
    /**
    * @description  : get the contact from the related Account base on the quote id calling from the QE360V3_SW_Contact.cmp
    * @author       : mpatel@addonblue.com | 28/1/2020 
    * @param        : searchString(Search contact by name)
    * @param        : accountId(id of the account record)
    * @return       : List<Contact>
    **/
    @AuraEnabled
    public static List<Contact> filtterContactRole(String searchString, String accountId){
        string searchString1 = '%'+searchString+'%';
        //List<OpportunityContactRole> opp = [Select id,Contact.Name,ContactId,Role from OpportunityContactRole where Contact.Name Like : searchString1];
        //return opp;
        List<Contact> contactList = [Select id,Name from Contact where Name Like : searchString1 and AccountId = :accountId];
        List<Contact> contactList1 = [Select id,Name from Contact where AccountId = :accountId];
        System.debug('accountId-->'+accountId);
        System.debug('contactList1-->'+contactList1);
        return contactList;
    }
    /**
    * @description  : get the role picklist values excluding the Attendee Contact and Communication Contact and calling from the QE360V3_SW_Contact.cmp
    * @author       : mpatel@addonblue.com | 28/1/2020 
    * @param        : contectRoleList(stringify contact role list)
    * @return       : List<String>
    **/
    @AuraEnabled        
    public static List<String> getPickListValuesIntoList(String contectRoleList){
        List<OpportunityContactRole> newOppContactRoleList = (List<OpportunityContactRole>)JSON.deserialize(contectRoleList,List<OpportunityContactRole>.class);
        List<String> pickListValuesList = new List<String>();
        //List<String> filterPickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = OpportunityContactRole.Role.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
            System.debug('Values in Rating are: '+pickListValuesList);
        }
        for(OpportunityContactRole ocr : newOppContactRoleList){
            if((ocr.Role != 'Attendee Contact' || ocr.Role != 'Communications Contact') && ocr.Custom_Contact__c == false ){
                for(Integer i = 0; i< pickListValuesList.size(); i++){
                    if(ocr.Role == pickListValuesList[i]){
                        pickListValuesList.remove(i);
                        break;
                    }
                }
            }
        }
        return pickListValuesList;
    }
    /**
    * @description  : Add Contact role input and calling from the QE360V3_SW_Contact.cmp
    * @author       : mpatel@addonblue.com | 28/1/2020 
    * @param        : contactRoleList(stringify contact role list)
    * @return       : List<OpportunityContactRole>
    **/
    @AuraEnabled
    public static List<OpportunityContactRole> addinputFieldMethod(String contactRoleList){
        List<OpportunityContactRole> OpportunityContactRoleList = (List<OpportunityContactRole>)JSON.deserialize(contactRoleList,List<OpportunityContactRole>.class);
        OpportunityContactRoleList.add(new OpportunityContactRole());
        return OpportunityContactRoleList;
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
    public static String addContactRoleListing(String addContactRoleList,String allOppContactRole, String deleteContactRole){
        System.debug('deleteContactRole-->'+deleteContactRole);
        List<OpportunityContactRole> newOppContactRoleList = (List<OpportunityContactRole>)JSON.deserialize(addContactRoleList,List<OpportunityContactRole>.class);
        List<OpportunityContactRole> oldOppContactRoleList = (List<OpportunityContactRole>)JSON.deserialize(allOppContactRole,List<OpportunityContactRole>.class);
        
        List<OpportunityContactRole> deleteOppContactRoleList = new List<OpportunityContactRole>();
        if(deleteOppContactRoleList != null)
        {
            deleteOppContactRoleList = (List<OpportunityContactRole>)JSON.deserialize(deleteContactRole,List<OpportunityContactRole>.class);
        }
        Map<Id, OpportunityContactRole> newOppConRollMap = new Map<Id, OpportunityContactRole>();
        Map<Id, OpportunityContactRole> oldOppConRollMap = new Map<Id, OpportunityContactRole>();
        List<OpportunityContactRole> contactRoleInsertList = new List<OpportunityContactRole>();
        List<OpportunityContactRole> contactRoleUpdateList = new List<OpportunityContactRole>();
        String message = 'fail';
        
        for(OpportunityContactRole newOpp : newOppContactRoleList){
            System.debug('newOpp-->'+newOpp);
            newOppConRollMap.put(newOpp.ContactId, newOpp);
        }
        for(OpportunityContactRole oldOpp : oldOppContactRoleList){
            System.debug('oldOpp-->'+oldOpp);
            oldOppConRollMap.put(oldOpp.ContactId, oldOpp);
        }
        System.debug('newOppConRollMap-->'+newOppConRollMap);
        System.debug('oldOppConRollMap-->'+oldOppConRollMap);
        for(OpportunityContactRole oppObj : newOppConRollMap.values()){
            if(oldOppConRollMap.containsKey(oppObj.ContactId) && oldOppConRollMap.get(oppObj.ContactId).Role == oppObj.Role){
                contactRoleUpdateList.add(oppObj);
            }
            else {
                OpportunityContactRole oppObject = new OpportunityContactRole();
                oppObject.ContactId = oppObj.ContactId;
                oppObject.OpportunityId = oppObj.OpportunityId;
                oppObject.Role = oppObj.Role;
                oppObject.Custom_Contact__c = true;
                System.debug('oppObject-->'+oppObject);
                contactRoleInsertList.add(oppObject);
            }
        }
        //System.debug('contactRoleInsertList-->'+contactRoleInsertList);
        //System.debug('contactRoleUpdateList-->'+contactRoleUpdateList);
        if(!contactRoleInsertList.isEmpty()){
           insert contactRoleInsertList;
           message = 'success';
        }
        if(!contactRoleUpdateList.isEmpty() && !Test.isRunningTest()){
            update contactRoleUpdateList;
            message = 'success';
        }
        if(!deleteOppContactRoleList.isEmpty() && !Test.isRunningTest())
        {
            delete deleteOppContactRoleList;
        }
        return message;
    }
    /**
    * @description  : Add Contact and relate this contact with account wich is associated with quote and calling from the QE360V3_SW_Contact.cmp
    * @author       : mpatel@addonblue.com | 28/1/2020 
    * @param        : newContact(contact object)
    * @param        : currentQuoteId(contact Id)
    * @return       : Contact
    **/
    @AuraEnabled
    public static Contact saveNewContact(Contact newContact, String currentQuoteId){
        System.debug(newContact);
        Quote currentQuote = [Select AccountId from Quote where id=: currentQuoteId];
        
        newContact.AccountId = currentQuote.AccountId;
        insert newContact;
        
        return newContact;
    }
}
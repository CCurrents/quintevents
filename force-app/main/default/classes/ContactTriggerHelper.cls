/**
 * @File Name          : ContactTriggerHelper.cls
 * @Description        : Helper class for ContactTriggerHandler
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 01-26-2021
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    05/03/2020   fsuraitawala@addonblue.com     Initial Version
**/
public with sharing class ContactTriggerHelper {
    
    private Map<Id, Contact> newContactMap; 
    private Map<Id, Contact> oldContactMap;
    private List<Contact> newContactList;
    private List<Contact> oldContactList;
    
    /**
    * @description: Constructor
    * @author: fsuraitawala@addonblue.com
    **/
    public ContactTriggerHelper() {
        
        this.newContactMap = (Map<Id, Contact>) Trigger.newMap;
        this.oldContactMap = (Map<Id, Contact>) Trigger.oldMap;
        this.newContactList = (List<Contact>) Trigger.new;
        this.oldContactList = (List<Contact>) Trigger.old;
        
        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
                System.debug('In Before Insert!');
                updateEmailOptOut();
            }
            
            when BEFORE_UPDATE {
                System.debug('In Before Update!');
                updateEmailOptOut();
            }
            
            when BEFORE_DELETE {
                System.debug('In Before Delete!');
            }
            
            when AFTER_INSERT {
                System.debug('In After Insert!');
                onAfterInsertContact();
            }
            
            when AFTER_UPDATE {
                System.debug('In After Update!');
                onAfterUpdateContact();
            }
            
            when AFTER_DELETE {
                System.debug('In After Delete!');
            }
            
            when AFTER_UNDELETE {
                System.debug('In After Undelete!');
            }
            
            when else {
                System.debug('Undefined Trigger Operation!');
            }
        }
    }
    
    /**
    * @description  : 
    * @author       : 
    * @param        : newObjectList (list of new product)
    * @return       : void
    **/
    public void onAfterInsertContact() {
        Set<Id> setContactId = new Set<Id>();
        Set<Id> setNewContactId = new Set<Id>();
        Set<Id> setAccountId = new Set<Id>();
        Set<Id> setNewAccountId = new Set<Id>();
        Map<Id, Id> mapAccContact = new Map<Id, Id>();
        List<Contact> lstContactUpdate = new List<Contact>();
        List<Account> lstAccountUpdate = new List<Account>();
        
        try {
            for(Contact objContact: newContactList) {
                if(objContact.Primary_Contact__c) {
                    setContactId.add(objContact.Id);
                    if(objContact.AccountId != null) {
                        setAccountId.add(objContact.AccountId);
                        mapAccContact.put(objContact.AccountId, objContact.Id);
                    }
                }
                setNewAccountId.add(objContact.AccountId);
                setNewContactId.add(objContact.Id);
            }
            
            if(setAccountId.size() > 0 && setContactId.size() > 0) {
                for(Contact objContact: [SELECT Id, Name, AccountId, Primary_Contact__c FROM Contact WHERE AccountId IN: setAccountId AND Id NOT IN: setContactId]) {
                    if(objContact.Primary_Contact__c) {
                        objContact.Primary_Contact__c = FALSE;
                        lstContactUpdate.add(objContact);                   
                    }
                }
            }
            
            if(setNewAccountId.size() > 0 && setNewContactId.size() > 0) {
                List<Contact> lstContact = new List<Contact>();
                Map<Id, List<Contact>> newAccountMap =new Map<Id, List<Contact>>();
                
                for(Account objAccount: [SELECT Id, 
                                        (SELECT Id, Name, AccountId, Primary_Contact__c, Account.RecordType.Name FROM Contacts ORDER BY createddate ASC LIMIT 1) 
                                         From Account 
                                         WHERE ID IN : setNewAccountId]) {
                    newAccountMap.put(objAccount.Id, objAccount.Contacts) ;
                }
                
                for(Id item: newAccountMap.keyset()) {  
                    List<Contact> tempContactList = newAccountMap.get(item);
                    
                    if(tempContactList.size() > 0 && tempContactList[0].Account.RecordType.Name == 'Business Account') {
                        tempContactList[0].Primary_Contact__c = true;
                        lstContactUpdate.add(tempContactList[0]);
                    }
                }
            }
            
            if(setAccountId.size() > 0) {
                for(Account acc: [SELECT Id, Name, Primary_Contact__c FROM Account WHERE Id IN: setAccountId]) {
                    acc.Primary_Contact__c = mapAccContact.get(acc.Id);    
                    lstAccountUpdate.add(acc);
                }
            }
            
            if(lstContactUpdate.size() > 0){
                Utility.processRecords(lstContactUpdate, 'update');
            }
            
            if(lstAccountUpdate.size() > 0){
                Utility.processRecords(lstAccountUpdate, 'update');
            }
        } catch(Exception ex) {
            //Custom Error logging
            Log.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
            system.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
        }  
    }
    
    /**
    * @description  : 
    * @author       : 
    * @param        : newObjectList (list of new product)
    * @return       : void
    **/
    public void onAfterUpdateContact() {
        Set<Id> setContactIds = new Set<Id>();
        Set<Id> setConIds = new Set<Id>();
        Set<Id> setAccountIds = new Set<Id>();
        Map<Id,Id> mapAccCon = new Map<Id,Id>();
        Set<Id> setofEmailChangeIds = new Set<Id>();
        try {
            for(Contact objContact : newContactList) {

                Contact objOldContact = oldContactMap.get(objContact.Id);
                String newContactName = objContact.Salutation +' '+ objContact.FirstName +' '+objContact.LastName;
                String oldContactName = objOldContact.Salutation+' '+objOldContact.FirstName+' '+objOldContact.LastName;
                
                
                if(newContactName != null && newContactName != oldContactName) {
                    setcontactIds.add(objContact.Id);
                }
                
                if(oldContactMap.get(objContact.Id).Primary_Contact__c == FALSE && objContact.Primary_Contact__c == TRUE) {
                    setConIds.add(objContact.Id);
                    if(objContact.AccountId != null) {
                        setAccountIds.add(objContact.AccountId);
                        mapAccCon.put(objContact.AccountId, objContact.Id);
                    }
                }
            }
            
            if(!setcontactIds.isEmpty()) {
                calloutToupdateIntacctContact(setcontactIds);
            }
            onAfterUpdateContact(setAccountIds, setConIds, mapAccCon);
        
        } catch(Exception ex) {
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
    
    /**
    * @description  : 
    * @author       : 
    * @param        : newObjectList (list of new product)
    * @return       : void
    **/
    public static void onAfterUpdateContact(set<Id> setAccountIDs, set<Id> setContactIDs, Map<Id,Id> mapAccountContact) {
        
        List<Contact> lstUpdateContact = new List<Contact>();
        List<Account> lstUpdateAccount = new List<Account>();
        
        try {
            if(setAccountIDs.size() > 0 && setContactIDs.size() > 0){
                for(Contact objContact: [SELECT Id, Name, AccountId, Primary_Contact__c 
                                         FROM Contact WHERE AccountId IN: setAccountIDs AND Id NOT IN: setContactIDs]){
                    if(objContact.Primary_Contact__c == TRUE) {
                        objContact.Primary_Contact__c = FALSE;
                        lstUpdateContact.add(objContact);
                    }
                }
            }
            if(setAccountIDs.size() > 0) {
                for(Account acc: [SELECT Id, Name, Primary_Contact__c FROM Account WHERE Id IN: setAccountIDs]){
                    acc.Primary_Contact__c = mapAccountContact.get(acc.Id);    
                    lstUpdateAccount.add(acc);
                }
            }
            
            if(lstUpdateContact.size() > 0) {
                Utility.processRecords(lstUpdateContact, 'update');
            }
            
            if(lstUpdateAccount.size() > 0){
                Utility.processRecords(lstUpdateAccount, 'update');
            }
        } catch(Exception ex) {
            //Custom Error logging
            Log.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
            system.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
        }
    }
    
    /**
    * @description  : Future method for update contact name in Intacct
    * @author       : 
    * @param        : setcontactIds (set of updated contact's Id)
    * @return       : void
    **/
    @future(callout=true)
    public static void calloutToupdateIntacctContact(Set<Id> setContactIds) {
        Intacct_API_Details__c objIntacctDetails = Intacct_API_Details__c.getOrgDefaults();
        
        if(setcontactIds.size() > 0) {
            for(contact objContact: [Select Id, Name, Salutation, FirstName, LastName, Record_Id__c, Intacct_Id__c, Sandbox_Intacct_Id__c, Sandbox_Record_Id__c 
                            From contact WHERE Id IN: setContactIds]) {
                            IntacctOrderSyncBatchHelper helper = new IntacctOrderSyncBatchHelper();
                            helper.contactDataUpdateCallout(objContact);
            }
        }
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 01-26-2021 
    **/
    public void updateEmailOptOut(){
        for(Contact objCon : newContactList){
            if(objCon.Marketing_Email_Consent__c != null && objCon.Marketing_Email_Consent__c == 'Yes'){
                objCon.HasOptedOutOfEmail = false;
            }
            else if(objCon.Marketing_Email_Consent__c == null || objCon.Marketing_Email_Consent__c == 'No'){
                objCon.HasOptedOutOfEmail = true;
            }
        }
    }
}
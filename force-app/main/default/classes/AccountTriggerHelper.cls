/**
 * @File Name          : AccountTriggerHelper.cls
 * @Description        : Helper class for ContactTriggerHandler
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 01-27-2021
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    05/18/2020   mpatel@addonblue.com     Initial Version
**/
public with sharing class AccountTriggerHelper {
    
    private Map<Id, Account> newAccountMap; 
    private Map<Id, Account> oldAccountMap;
    private List<Account> newAccountList;
    private List<Account> oldAccountList;
    
    /**
    * @description: Constructor
    * @author: mpatel@addonblue.com
    **/
    public AccountTriggerHelper() {
        
        this.newAccountMap = (Map<Id, Account>) Trigger.newMap;
        this.oldAccountMap = (Map<Id, Account>) Trigger.oldMap;
        this.newAccountList = (List<Account>) Trigger.new;
        this.oldAccountList = (List<Account>) Trigger.old;
        
        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
                System.debug('In Before Insert!');
                updateEmailOptOut();
            }
            
            when BEFORE_UPDATE {
                System.debug('In Before Update!');
                updateEmailOptOut();
                updateAllowOnlineCredit(newAccountList, oldAccountMap, newAccountMap);
            }
            
            when BEFORE_DELETE {
                System.debug('In Before Delete!');
            }
            
            when AFTER_INSERT {
                updateShippingAddress(newAccountList, oldAccountMap, newAccountMap);
            }
            
            when AFTER_UPDATE {
                updateShippingAddress(newAccountList, oldAccountMap, newAccountMap);
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
    * @description  : update shipping address with billing address
    * @author       : mpatel@addonblue.com | 05/18/2020
    * @return       : void 
    **/
    private static void updateShippingAddress(List<Account> newAccountList, Map<Id, Account> oldAccountMap, Map<Id, Account> newAccountMap){
        List<Contact> contactObj = [Select Id,AccountId,OtherStreet,OtherState,OtherCity,OtherCountry,OtherPostalCode,MailingStreet,MailingState,MailingCity,MailingCountry,MailingPostalCode from Contact where AccountId IN: newAccountMap.keySet()];
        Map<Id, List<Contact>> contactMap = new Map<Id, List<Contact>>();
        for(Contact con : contactObj){
            
            if(contactMap.containskey(con.AccountId)){
                contactMap.get(con.AccountId).add(con);
            }else{
                contactMap.put(con.AccountId, New List<Contact> {con});
            }
        }
        List<Contact> updateContactList = new List<Contact>();
        List<Account> accList = new List<Account>();
        for(Account account : newAccountList){
            System.debug('account.isPersonAccount-->'+account.isPersonAccount);
            //System.debug('account.BillingCountry-->'+account.BillingCountry);
            //System.debug('account.ShippingCountry-->'+account.ShippingCountry);
            if(account.isPersonAccount){
                List<Contact> contactList = contactMap.get(account.Id);
                if(account.BillingStreet != contactList[0].OtherStreet || account.BillingState != contactList[0].OtherState ||
                  account.BillingCity != contactList[0].OtherCity || account.BillingCountry != contactList[0].OtherCountry ||
                  account.BillingPostalCode != contactList[0].OtherPostalCode||
                  account.ShippingStreet != contactList[0].MailingStreet || account.ShippingState != contactList[0].MailingState ||
                  account.ShippingCity != contactList[0].MailingCity || account.ShippingCountry != contactList[0].MailingCountry ||
                  account.ShippingPostalCode != contactList[0].MailingPostalCode){
                      
                    Contact con = new Contact();
                    con.Id = contactList[0].Id;
                    con.OtherStreet = account.BillingStreet;
                    con.OtherState = account.BillingState;
                    con.OtherCity = account.BillingCity;
                    con.OtherCountry = account.BillingCountry;
                    con.OtherPostalCode = account.BillingPostalCode;
                    
                    con.MailingStreet = account.ShippingStreet;
                    con.MailingState = account.ShippingState;
                    con.MailingCity = account.ShippingCity;
                    con.MailingCountry = account.ShippingCountry;
                    con.MailingPostalCode = account.ShippingPostalCode;
                    updateContactList.add(con);  
                }                
            }    
            if(account.Copy_Billing_to_Shipping_Address__c == true && (oldAccountMap == null || account.BillingStreet != oldAccountMap.get(account.Id).ShippingStreet || 
            account.BillingCity != oldAccountMap.get(account.Id).ShippingCity || account.BillingState != oldAccountMap.get(account.Id).ShippingState || 
            account.BillingCountry != oldAccountMap.get(account.Id).ShippingCountry || account.BillingPostalCode != oldAccountMap.get(account.Id).ShippingPostalCode )){//&& oldAccountMap.get(account.Id).Copy_Billing_to_Shipping_Address__c != account.Copy_Billing_to_Shipping_Address__c)
                Account acc = new Account();
                acc.id = account.Id;
                acc.ShippingStreet = account.BillingStreet;
                acc.ShippingState = account.BillingState;
                acc.ShippingCity = account.BillingCity;
                acc.ShippingCountry = account.BillingCountry;
                acc.ShippingPostalCode = account.BillingPostalCode;
                accList.add(acc);
            }
        }
        if(!updateContactList.isEmpty()){
            utility.processRecords(updateContactList,'update');
            System.debug('updateContactList-->'+updateContactList);
        }
        if(!accList.isEmpty()){
            utility.processRecords(accList,'update');
            System.debug('accList-->'+accList);
        }
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 01-26-2021 
    **/
    public void updateEmailOptOut(){
        for(Account objAcc : newAccountList){
            if(objAcc.IsPersonAccount){
                if(objAcc.Marketing_Email_Consent__c != null && objAcc.Marketing_Email_Consent__c == 'Yes'){
                    objAcc.PersonHasOptedOutOfEmail = false;
                }
                else if(objAcc.Marketing_Email_Consent__c == null || objAcc.Marketing_Email_Consent__c == 'No'){
                    objAcc.PersonHasOptedOutOfEmail = true;
                }
            }
        }
    }
    
    //VKHOPADE - issue 1153 - start
    private void updateAllowOnlineCredit (List<Account> newAccountList, Map<Id, Account> oldAccountMap, Map<Id, Account> newAccountMap){
        for(Account account : newAccountList){
            if(account.Allow_Online_Credit_Usage__c == false)
            {
                if((isCreditEarnedChanged(account, oldAccountMap) || isCreditUsedChanged(account, oldAccountMap) || isCreditExpirationChanged(account, oldAccountMap)) && CalcIsCreditAvailable(account, oldAccountMap)){
                    //if(CalcIsCreditAvailable(account, oldAccountMap))
                        account.Allow_Online_Credit_Usage__c = true;
                }
            }
        }
        
    }
    
    private boolean isCreditEarnedChanged(Account account, Map<Id, Account> oldAccountMap)
    {
        return ((account.AUD_Total_Credit_Earned__c != oldAccountMap.get(account.Id).AUD_Total_Credit_Earned__c) || (account.CAD_Total_Credit_Earned__c != oldAccountMap.get(account.Id).CAD_Total_Credit_Earned__c) || (account.EUR_Total_Credit_Earned__c != oldAccountMap.get(account.Id).EUR_Total_Credit_Earned__c) || (account.GBP_Total_Credit_Earned__c != oldAccountMap.get(account.Id).GBP_Total_Credit_Earned__c) ||(account.USD_Total_Credit_Earned__c != oldAccountMap.get(account.Id).USD_Total_Credit_Earned__c) || (account.SAR_Total_Credit_Earned__c != oldAccountMap.get(account.Id).SAR_Total_Credit_Earned__c) || (account.THB_Total_Credit_Earned__c  != oldAccountMap.get(account.Id).THB_Total_Credit_Earned__c)); //Issues #1209 - Sai
    }
    
   private boolean isCreditUsedChanged(Account account, Map<Id, Account> oldAccountMap)
    {
        return ((account.AUD_Total_Credit_Used__c != oldAccountMap.get(account.Id).AUD_Total_Credit_Used__c) || (account.CAD_Total_Credit_Used__c != oldAccountMap.get(account.Id).CAD_Total_Credit_Used__c) || (account.EUR_Total_Credit_Used__c != oldAccountMap.get(account.Id).EUR_Total_Credit_Used__c) || (account.GBP_Total_Credit_Used__c != oldAccountMap.get(account.Id).GBP_Total_Credit_Used__c) ||(account.USD_Total_Credit_Used__c != oldAccountMap.get(account.Id).USD_Total_Credit_Used__c) || (account.SAR_Total_Credit_Used__c != oldAccountMap.get(account.Id).SAR_Total_Credit_Used__c) || (account.THB_Total_Credit_Used__c  != oldAccountMap.get(account.Id).THB_Total_Credit_Used__c )); //Issues #1209 - Sai
    }
    
    private boolean isCreditExpirationChanged(Account account, Map<Id, Account> oldAccountMap)
    {
        return ((account.AUD_Total_Credit_Expiration__c != oldAccountMap.get(account.Id).AUD_Total_Credit_Expiration__c) || (account.CAD_Total_Credit_Expiration__c != oldAccountMap.get(account.Id).CAD_Total_Credit_Expiration__c) || (account.EUR_Total_Credit_Expiration__c != oldAccountMap.get(account.Id).EUR_Total_Credit_Expiration__c) || (account.GBP_Total_Credit_Expiration__c != oldAccountMap.get(account.Id).GBP_Total_Credit_Expiration__c) ||(account.USD_Total_Credit_Expiration__c != oldAccountMap.get(account.Id).USD_Total_Credit_Expiration__c) || (account.SAR_Total_Credit_Expiration__c != oldAccountMap.get(account.Id).SAR_Total_Credit_Expiration__c) ||(account.THB_Total_Credit_Expiration__c != oldAccountMap.get(account.Id).THB_Total_Credit_Expiration__c)); //Issues #1209 - Sai
    }
    
    private boolean CalcIsCreditAvailable(Account account, Map<Id, Account> oldAccountMap){
        if(((account.AUD_Total_Credit_Earned__c - account.AUD_Total_Credit_Used__c - account.AUD_Total_Credit_Expiration__c) > 0) ||
           ((account.CAD_Total_Credit_Earned__c - account.CAD_Total_Credit_Used__c - account.CAD_Total_Credit_Expiration__c) > 0) ||
           ((account.EUR_Total_Credit_Earned__c - account.EUR_Total_Credit_Used__c - account.EUR_Total_Credit_Expiration__c) > 0) ||
           ((account.GBP_Total_Credit_Earned__c - account.GBP_Total_Credit_Used__c - account.GBP_Total_Credit_Expiration__c) > 0) ||
		   ((account.SAR_Total_Credit_Earned__c  - account.SAR_Total_Credit_Used__c - account.SAR_Total_Credit_Expiration__c) > 0) || //Issues #1209 - Sai
		   ((account.THB_Total_Credit_Earned__c  - account.THB_Total_Credit_Used__c  - account.THB_Total_Credit_Expiration__c ) > 0) || //Issues #1209 - Sai
           ((account.USD_Total_Credit_Earned__c - account.USD_Total_Credit_Used__c - account.USD_Total_Credit_Expiration__c) > 0))
        {
            return true;
        }
        else
            return false;
    }
    //VKHOPADE - issue 1153 - End
}
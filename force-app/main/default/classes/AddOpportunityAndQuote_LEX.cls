/**
 * @File Name          : AddOpportunityAndQuote_LEX.cls
 * @Description        : Converting the lead into opportuntiy and Update the acconunt details and calling from the LeadConvert.cmp
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 12-18-2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    10/31/2019     smaddi@addonblue.com      Initial Version
 * 1.1    7/30/2020      jagrawal@addonblue.com    #463 Added code to make Quote Owner same as Opportunity Owner
 * 1.2    08/25/2020     jagrawal@addonblue.com    #485 Added new field Travel Agent for Travel Agencies
 * 1.3    10-27-2020     jagrawal@addonblue.com    #596 Changed RecordType name from Travel Agent to Reseller
 * 1.4    12-26-2020     jagrawal@addonblue.com    #664 "Create Quote" button on opportunity page should not allow to create quote if that opportunity already has "Active" order on it.
 * 1.5    12-02-2021     gbanker@addonblue.com     #758 added isF1EProgrammedPriceBook method
 * 1.5    02/12/2021     cshah@addonblue.com       #741 Prevent all users regardless of profile from creating new quote if opportunity status is already Canceled.       
 * 1.5    15-02-2021     vshah@addonblue.com       #758 added isF1EProgrammedPriceBook method
 * 1.8    21-11-2021     rama.krishna@addonblue.com#1110 Allow user to select Primary contact for Business and Reseller Account while creating Opportunity
**/ 

public class AddOpportunityAndQuote_LEX{
@AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName,String accountId) {
        String searchKey = searchKeyWord + '%';
         String sQuery='';
        List < sObject > returnList = new List < sObject > ();
        if(ObjectName == 'contact' || ObjectName == 'opportunity'){
            sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey and accountId =: accountId order by createdDate ASC limit 5';
        } else {
            // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5  
            sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate ASC limit 5';
        }
        List < sObject > lstOfRecords = Database.query(sQuery);
       
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    /**
    * @description  : This method to create opportunity on the button click from the lead convert component calling from the QE360V3_AddOpportunityAndQuote.cmp
    * @author       : mpatel@addonblue.com | 28/1/2020 
    * @param        : accountId(id of the account record)
    * @param        : opportunity(opportunity record)
    * @return       : String 
    **/
    @AuraEnabled
    public static String convertLead(String accountId, Opportunity opportunity,String primaryConId) {
        system.debug('====='+primaryConId);
        string message = '';
        Boolean primaryContactFlag = true;
        Boolean skipOpportunityDML = false;
        Quote objquote;
        try {
            String LeadType = '';
            if(accountId != null) {
                try {                      
                        List<account> lstAccount = new List<account>();
                            lstAccount = [Select Id, Primary_Contact__c, PersonContactId, BillingStreet, BillingCity, BillingState, BillingCountry,RecordType.Name,
                                          BillingPostalCode, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, IsPersonAccount
                                          ,(Select Id,Name,Primary_Contact__c from Contacts)FROM Account WHERE Id =: accountId];//where Primary_Contact__c = true
                    
                    List<Contact> lstcon = [select id,Name from contact where accountid=:accountId];
                       
                    Pricebook2 objPricebook = new Pricebook2();
                        objPricebook.Id = opportunity.Pricebook2Id;
                        
                        pricebook2 pbObj=[Select Name,Chargeable_Currencies__c from pricebook2 where id=:opportunity.Pricebook2Id];//21/10/2019
             
                        opportunity.Name = pbObj.Name; 
                        opportunity.StageName = 'Qualified'; 
                        opportunity.Pricebook2Id = opportunity.Pricebook2Id;
                        opportunity.Pricebook2 = null;
                        // #485 Added new field Travel Agent for Travel Agencies -- START
                        system.debug('travel-->'+opportunity.Travel_Agent__c);
                        // #596 Changed RecordType name from Travel Agent to Reseller
                        if(opportunity.Travel_Agent__c == null && lstAccount[0].RecordType.Name == 'Reseller'){
                            message = 'Error: You must select a Travel Agent for the Opportunity.';
                            return message;
                        }
                        // #485 Added new field Travel Agent for Travel Agencies -- END
                        if(!lstAccount[0].IsPersonAccount) {
                            opportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
                            //opportunity.Primary_Contact__c = (!lstAccount[0].Contacts.isEmpty() ? lstAccount[0].Contacts[0].Id : lstAccount[0].Primary_Contact__c);
                            Set<Id> contactIds = new Set<Id>();
                            for(Contact con : lstAccount[0].Contacts){
                                contactIds.add(con.Id);
                                if(con.Primary_Contact__c == true){
                                    primaryContactFlag = false;
                                    opportunity.Primary_Contact__c = con.Id;
                                }
                            }
                            // #485 Added new field Travel Agent for Travel Agencies -- START
                            // #596 Changed RecordType name from Travel Agent to Reseller
                            if(lstAccount[0].RecordType.Name == 'Reseller' && opportunity.Travel_Agent__c != null){
                                opportunity.Primary_Contact__c = opportunity.Travel_Agent__c;
                            }
                            
                            // #596 Changed RecordType name from Travel Agent to Reseller
                            if(opportunity.Travel_Agent__c != null && contactIds.size() > 0 && !contactIds.contains(opportunity.Travel_Agent__c) && lstAccount[0].RecordType.Name == 'Reseller'){
                                message = 'Error: You must select a related Contact of the Reseller for the Opportunity.';
                                return message;
                            }
                            // #485 Added new field Travel Agent for Travel Agencies -- END
                            if(primaryContactFlag){
                                if(lstAccount[0].Contacts.size() == 1){
                                    Contact contact = new Contact();
                                    contact.Id = lstAccount[0].Contacts[0].Id;
                                    contact.Primary_Contact__c = true;
                                    Utility.processRecords(contact, 'update');
                                    opportunity.Primary_Contact__c = lstAccount[0].Contacts[0].Id;
                                }else{
                                    message = 'Alert! '+System.Label.Primary_Contact_Error_Str;
                                    skipOpportunityDML = true;
                                }
                            }
                            if(primaryConId !=null && primaryConId !=''){
                            	opportunity.Primary_Contact__c =primaryConId ;
                       		 }
                            
                        } else {
                            opportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Person Opportunity').getRecordTypeId();
                            opportunity.Primary_Contact__c = lstAccount[0].PersonContactId;
                        }
                        opportunity.AccountId = accountId;
                        
                        
                        if(skipOpportunityDML == false){
                            Utility.processRecords(opportunity, 'insert');              
                            message = opportunity.id + '##' + opportunity.AccountId;  
                        }
                        system.debug('message @@@' + message);                         
                        return message;                            
                }
                catch (DMLException dmlEx) {                   
                    message = 'Error: '+dmlEx.getdmlMessage(0);
                    System.debug('lead convert status test class: '+message+'-->'+dmlEx.getLineNumber());
                    return message;
                }
            } else {
                message ='Error: Account Id found Null for Opportunity Creation.';
                return message;
            }
        }
        catch(exception ex){
            system.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
            message = 'Error: '+ ex.getMessage();
            return message;
        }
    }
    
    /**
    * @description  : retrive the lead detail from the id calling from the QE360V3_AddOpportunityAndQuote.cmp
    * @author       : mpatel@addonblue.com | 28/1/2020 
    * @param        : leadid(id of the lead record)
    * @return       : Lead 
    **/
    @AuraEnabled
    public static Lead retrieveLeadInfo(String leadid) {
        Lead objlead = [Select Id, Name FROM Lead Where Id =: leadid limit 1];
        return objlead;
    }
    
    /**
    * @description  : get the list of the Active Currency to display picklist values on the lead convert poup calling from the QE360V3_AddOpportunityAndQuote.cmp
    * @author       : mpatel@addonblue.com | 28/1/2020 
    * @param        : pbId(id of the pricebook record)
    * @return       : List<OpportunityCurrency>
    **/
    @AuraEnabled
    public static List<OpportunityCurrency> getPricebookCurrencyDetails(String pbId){
        List<OpportunityCurrency> oppCurrList = new List<OpportunityCurrency>();
        OpportunityCurrency oppCurrObj; 
        try{
            pricebook2 pbObj=[Select Chargeable_Currencies__c from pricebook2 where id=:pbId];
            if(pbObj != null){
                List<String> currencyList=new List<String>();
                currencyList.add('');
                currencyList.addAll(pbObj.Chargeable_Currencies__c.split(';'));
                Schema.DescribeFieldResult fieldResult = Opportunity.CurrencyIsoCode.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                oppCurrObj=new OpportunityCurrency();
                oppCurrList.add(oppCurrObj);
                for( Schema.PicklistEntry pleObj : ple)       {
                    if(currencyList.contains(pleObj.getValue())){
                        oppCurrObj=new OpportunityCurrency();
                        oppCurrObj.code=pleObj.getValue();
                        oppCurrObj.Name=' - '+pleObj.getLabel();
                        oppCurrList.add(oppCurrObj);
                    }
                }
            } 
        }catch(Exception ex){
            System.debug('ex'+ex);
        }
        return oppCurrList;
    }
    Class OpportunityCurrency{
        @Auraenabled
        public String code=null;
        @Auraenabled
        public String Name;
    } 
    
    /**
    * @description  : get the opportunity from the id and create the quote calling from the QE360V3_AddOpportunityAndQuote.cmp
    * @author       : mpatel@addonblue.com | 28/1/2020 
    * @param        : opportunityId(id of the opportunity record)
    * @return       : String
    **/
    @AuraEnabled
    public static String createQuoteFromOpportunity(String opportunityId) {
        String message = '';
        try{ 
            System.debug('opportunityId-->'+opportunityId);
            // #664 "Create Quote" button on opportunity page should not allow to create quote if that opportunity already has "Active" order on it.
            List<Order> lstorder = [select Id,Status from Order where OpportunityId=:opportunityId AND Status = 'Active'];
            if(lstorder.size() > 0){
                message = 'Error : '+System.Label.CreateQuoteOrderErrorMessage;
                return message;
            }
            List<Opportunity> opportunityList = [Select id,Name,Primary_Contact__c,Pricebook2Id,Pricebook2.Name,Primary_Contact__r.Name,StageName,
                                              Primary_Contact__r.MailingStreet,Primary_Contact__r.MailingCity,Primary_Contact__r.MailingState,Primary_Contact__r.MailingCountry,
                                              Primary_Contact__r.MailingPostalCode,Primary_Contact__r.OtherStreet,Primary_Contact__r.OtherCity,Primary_Contact__r.OtherState,Primary_Contact__r.OtherCountry,
                                              Primary_Contact__r.OtherPostalCode, OwnerId,Travel_Agent__c from Opportunity where id=: opportunityId];
            System.debug('opportunityList-->'+opportunityList);
            if(!opportunityList.isEmpty()){
                    Quote objquote = new Quote(Name = opportunityList[0].Pricebook2.Name,
                                           opportunityId = opportunityList[0].Id,
                                           Pricebook2Id = opportunityList[0].Pricebook2Id,
                                           BillingStreet = opportunityList[0].Primary_Contact__r.OtherStreet,
                                           BillingCity = opportunityList[0].Primary_Contact__r.OtherCity,
                                           BillingState = opportunityList[0].Primary_Contact__r.OtherState,
                                           BillingCountry = opportunityList[0].Primary_Contact__r.OtherCountry,
                                           BillingPostalCode = opportunityList[0].Primary_Contact__r.OtherPostalCode,
                                           // #463 Added code to make Quote Owner same as Opportunity Owner
                                           OwnerId = opportunityList[0].OwnerId,
                                           ShippingStreet = opportunityList[0].Primary_Contact__r.MailingStreet,
                                           ShippingCity = opportunityList[0].Primary_Contact__r.MailingCity,
                                           ShippingState = opportunityList[0].Primary_Contact__r.MailingState,
                                           ShippingCountry = opportunityList[0].Primary_Contact__r.MailingCountry,
                                           ShippingPostalCode = opportunityList[0].Primary_Contact__r.MailingPostalCode,
                                           BillingName = opportunityList[0].Primary_Contact__r.Name,
                                           ShippingName = opportunityList[0].Primary_Contact__r.Name
                                           );
                
                if(opportunityList[0].StageName == 'Closed Won'){
                    message = 'Error : '+System.Label.CreateQuoteErrorMessage;//Opportunity is closed Won you can not create a Quote.';
                }
                else if(opportunityList[0].StageName == 'Canceled'){
                    message = 'Error : '+System.Label.Canceled_Opportunity_Error_Message;//Opportunity is Canceled you can not create a Quote.';
                }
                else{
                    Utility.processRecords(objquote, 'insert');
                    message = objquote.id;
                }
            }
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
            message = 'Error: '+ ex.getMessage();
        }
        return message;
    }
    
    /**
    * @description  : This method to get Account RecordType
    * @author       : jagrawal@addonblue.com | 19/8/2020 
    * @param        : accountId(id of the account record)
    * @param        : opportunity(opportunity record)
    * @return       : String 
    **/
    @AuraEnabled
    public static String getAccountRecordType(String accountId) {
        Account objAccount = [Select Id,RecordType.Name From Account where id =: accountId];
        return objAccount.RecordType.Name;
    }


    /**
    * @description  : checks if the pricebook is F1E or not
    * @author       : vshah@addonblue.com 25/02/2021
    * @param        : priceBookId(id of the pricebook record)
    * @return       : Boolean 
    **/
    @AuraEnabled
    public static Boolean isF1EProgrammedPriceBook(String priceBookId) {
        Pricebook2 objPriceBook = [Select Id, Program__r.Name FROM Pricebook2 Where id = :priceBookId];
        if(objPriceBook.Program__r.Name == 'F1E'){
            return true;
        }
        else {
            return false;
        }
    }
    
    @AuraEnabled
    public static List < sObject > fetchContactLookUpValues(String searchKeyWord, String ObjectName,String recordIdVal) {
        system.debug('ObjectName-->' + ObjectName);
        String sQuery ;
        List <sObject> returnList = new List <sObject> ();
        if(searchKeyWord !=null){
        	sQuery = 'SELECT Id,Name from ' +ObjectName + ' WHERE Name LIKE '+ '\'' + String.escapeSingleQuotes(searchKeyWord.trim()) +'%\'' + ' AND AccountId ='+'\''+recordIdVal+'\''+' LIMIT 100';

        }
        else{
          sQuery = 'SELECT Id,Name from ' +ObjectName + ' WHERE AND AccountId ='+'\''+recordIdVal+'\''+' LIMIT 100';
         
        }
        List < sObject > lstOfRecords = Database.query(sQuery);
        
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
        	return returnList;
    }

    
}
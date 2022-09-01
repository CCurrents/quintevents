/**
 * @File Name          : LeadConvertClass_LEX.cls
 * @Description        : Converting the lead into opportuntiy and the quote and calling from the LeadConvert.cmp
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 03-15-2022
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    7/1/2019     fsuraitawala@addonblue.com      Initial Version
 * 2.0    4/5/2021     cshah@addonblue.com          #866 Reseller lead convert and agreement changes  
 * 2.1    03/04/2022     vaibhav.khopade@addonblue.com  #1166 update opportunity Id on Lead on LeadConvert
**/

public class LeadConvertClass_LEX {
    
    /**
    * @description  : This method convert Lead, generate account,contact and also create opportunity as well as Quote this method calling from the QE360V3_LeadConvert.cmp
    * @author       : mpatel@addonblue.com | 28/1/2020 
    * @param        : LeadId(id of the lead record)
    * @param        : opportunity(opportunity record)
    * @return       : String 
    **/
    @AuraEnabled
    public static String convertLead(String LeadId, Opportunity opportunity, Account account, Lead lead) {
        string message = '';
        Quote objquote;
        try {
            
            List<Lead> leadLst = new List<Lead>();
            if(LeadId != null && LeadId.startswith('00Q')){
                leadLst = [Select Id, Name, Company, Company_Name__c, Lead_Type__c, Street, City, State, Country, Postalcode,Name_of_Currently_Active_Sequence__c
                           From Lead Where Id = :LeadId];
            }
            
            String LeadType = '';
            if(leadLst.size() > 0) {
                Lead leadObj = leadLst[0];
                Database.LeadConvert objLeadConvert = new database.LeadConvert();
                objLeadConvert.setLeadId(leadObj.id);
                objLeadConvert.setConvertedStatus('Converted');
                objLeadConvert.setDoNotCreateOpportunity(true);
                leadObj.Lead_Type__c = lead.Lead_Type__c;
                if(leadObj.Lead_Type__c == 'Business') {
                    LeadType = 'Business';
                    if(leadObj.Company == null || leadObj.Company == '') {
                        if(leadObj.Company_Name__c != null ){
                            leadObj.Company = leadObj.Company_Name__c;
                        } else {
                            leadObj.Company = leadObj.Name;
                        }
                    }                    
                }
                else if(leadObj.Lead_Type__c == 'Person') {
                    LeadType = 'Person';
                    leadObj.Company = null;                   
                }
                else if(leadObj.Lead_Type__c == 'Reseller') {
                    LeadType = 'Reseller';
                    leadObj.Company = null;                   
                }
                leadObj.From_Lead_Convert__c = true;
                Utility.processRecords(leadObj, 'update');
                
                Savepoint sp;
                try {
                    sp = Database.setSavepoint();
                    Database.LeadConvertResult objLeadConvertResult = Database.convertLead(objLeadConvert);
                    if(objLeadConvertResult.isSuccess()){                           
                        
                        List<account> lstAccount = new List<account>();
                        if(objLeadConvertResult.getAccountId() != null) {
                            lstAccount = [Select Id,Name,RecordTypeId, Primary_Contact__c, PersonContactId, BillingStreet, BillingCity, BillingState, BillingCountry,
                                          BillingPostalCode, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode,
                                          (Select id,Preferred_Method_of_Contact__c,Email,RecordTypeId from Contacts where Id=:objLeadConvertResult.getContactId())
                                          FROM Account WHERE Id =: objLeadConvertResult.getAccountId()];
                        }
                        //String EmailString = '';
                        if(lstAccount.size()>0) {                            
                            lstAccount[0].BillingStreet = leadObj.Street;
                            lstAccount[0].BillingCity = leadObj.City;
                            lstAccount[0].BillingState = leadObj.State;
                            lstAccount[0].BillingCountry = leadObj.Country;
                            lstAccount[0].BillingPostalCode = leadObj.PostalCode;
                            
                            lstAccount[0].ShippingStreet = leadObj.Street;
                            lstAccount[0].ShippingCity = leadObj.City;
                            lstAccount[0].ShippingState = leadObj.State;
                            lstAccount[0].ShippingCountry = leadObj.Country;
                            lstAccount[0].ShippingPostalCode = leadObj.PostalCode;                                               
                            if(lead.Lead_Type__c != 'Business'){
                                lstAccount[0].Preferred_Method_of_Contact__pc = account.Preferred_Method_of_Contact__pc;
                                if(LeadType == 'Reseller') {
                                    lstAccount[0].primary_contact__c = lstAccount[0].Contacts[0].Id;
                                }
                                system.debug('###=='+lstAccount[0].id);
                                if(lstAccount[0].Contacts != null){
                                    Contact con = new Contact();
                                    con.id = lstAccount[0].Contacts[0].Id;
                                    con.OtherStreet = leadObj.Street;
                                    con.OtherState = leadObj.State;
                                    con.OtherCity = leadObj.City;
                                    con.OtherCountry = leadObj.Country;
                                    con.OtherPostalCode = leadObj.PostalCode;
                                    
                                    con.MailingStreet = leadObj.Street;
                                    con.MailingState = leadObj.State;
                                    con.MailingCity = leadObj.City;
                                    con.MailingCountry = leadObj.Country;
                                    con.MailingPostalCode = leadObj.PostalCode;    
                                    if(LeadType == 'Reseller') con.primary_contact__c = true;                                  
                                    Utility.processRecords(con, 'Update');                                     
                                    //EmailString = lstAccount[0].Contacts[0].Email;
                                }
                            }else{
                                if(lstAccount[0].Contacts != null){
                                    lstAccount[0].Contacts[0].Preferred_Method_of_Contact__c = account.Preferred_Method_of_Contact__pc;
                                    Utility.processRecords(lstAccount[0].Contacts[0], 'Update');                                    
                                    //EmailString = lstAccount[0].Contacts[0].Email;
                                }
                            }
                            
                            Utility.processRecords(lstAccount[0], 'Update');                            
                            
                            if(LeadType == 'Reseller'){
                                Account objAcc = new Account(id = lstAccount[0].id);
                                objAcc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Reseller').getRecordTypeId();
                                Utility.processRecords(objAcc, 'Update');                                 
                                
                                Contact newcon = new Contact(id=lstAccount[0].Contacts[0].Id);                                  
                                newcon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Reseller Client').getRecordTypeId();
                                Utility.processRecords(newcon, 'Update');                                
                            }
                            
                            if(LeadType == 'Reseller') { //---- #866
                                Account objAcc = new Account(id = lstAccount[0].id);
                                objAcc.Name = leadObj.Company_Name__c;
                                update objAcc;
                            }
                        }
                        
                        Pricebook2 objPricebook = new Pricebook2();
                        objPricebook.Id = opportunity.Pricebook2Id;
                        
                        pricebook2 pbObj=[Select Name from pricebook2 where id=:opportunity.Pricebook2Id];
                         
                        opportunity.Name = pbObj.Name; 
                        opportunity.StageName = 'Qualified'; 
                        opportunity.Pricebook2Id = opportunity.Pricebook2Id;
                        opportunity.Pricebook2 = null;
                        opportunity.Last_Touch_Sequence__c = leadObj.Name_of_Currently_Active_Sequence__c;
                        
                        if(LeadType == 'Business' || LeadType == 'Reseller') {
                            opportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
                            opportunity.Primary_Contact__c = lstAccount[0].Primary_Contact__c;
                            if(LeadType == 'Reseller') opportunity.Travel_Agent__c = lstAccount[0].Primary_Contact__c;
                        }                        
                        else {
                            opportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Person Opportunity').getRecordTypeId();
                            opportunity.Primary_Contact__c = lstAccount[0].PersonContactId;
                        }
                        opportunity.AccountId = objLeadConvertResult.getAccountId();  
                        Utility.processRecords(opportunity, 'Insert');

                        if(opportunity.Id != null){
                            leadObj.Converted_Opportunity__c = opportunity.Id; //VKHOPADE - issue 1166
                            objquote=null;
                            objquote = new Quote(Name = pbObj.Name, opportunityId = opportunity.Id,
                                                 Pricebook2Id = opportunity.Pricebook2Id,
                                                 BillingStreet = leadObj.Street,
                                                 BillingCity = leadObj.City,
                                                 BillingState = leadObj.State,
                                                 BillingCountry = leadObj.country,
                                                 BillingPostalCode = leadObj.PostalCode,
                                                 ShippingStreet = leadObj.Street,
                                                 ShippingCity = leadObj.City,
                                                 ShippingState = leadObj.State,
                                                 ShippingCountry = leadObj.country,
                                                 ShippingPostalCode = leadObj.PostalCode,
                                                 BillingName = leadLst[0].Name,
                                                 ShippingName = leadLst[0].Name
                                                 //Email = EmailString
                                                );
                            Utility.processRecords(objquote, 'Insert');
                        }
                        Utility.processRecords(leadObj, 'update'); //VKHOPADE - #1166
                        message = opportunity.id + '##' + opportunity.AccountId + '##' + objquote.id; 
                        system.debug('message @@@' + message);                         
                        return message;                            
                    }
                    else {                            
                        message = 'Error: '+objLeadConvertResult.getErrors()[0].getMessage();
                        return message;                            
                    }
                }
                catch (DMLException dmlEx) {  
                    // Rollback to the previous value
                    Database.rollback(sp);                      
                    message = 'Error: '+dmlEx.getdmlMessage(0);
                    System.debug('lead convert status test class: '+message);
                    return message;
                }
            } else {
                message ='Error: Did not find a lead for conversion.';
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
    * @description  : retrive the lead detail from the id calling from the QE360V3_LeadConvert.cmp
    * @author       : mpatel@addonblue.com | 28/1/2020 
    * @param        : leadid(id of the lead record)
    * @return       : Lead 
    **/
    @AuraEnabled
    public static Lead retrieveLeadInfo(String leadid) {
        Lead objlead = [Select Id, Name, Lead_Type__c, Company_Name__c, Marketing_Email_Consent__c, Preferred_Contact_Method__c 
                        FROM Lead Where Id =: leadid limit 1];
        return objlead;
    }
    
    /**
    * @description  : get the list of the Active Currency to display picklist values on the lead convert popup calling from the QE360V3_LeadConvert.cmp
    * @author       : mpatel@addonblue.com | 28/1/2020 
    * @param        : pbId(price book id)
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
    //Wrapper class
    Class OpportunityCurrency{
        @Auraenabled
        public String code=null;
        @Auraenabled
        public String Name;
    }
    
}
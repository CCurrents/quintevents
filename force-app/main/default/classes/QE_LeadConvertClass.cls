public class QE_LeadConvertClass{

        
    @AuraEnabled
    public static Lead retrieveLeadInfo(String leadid) {
        Lead objlead = [Select Id, Name,Lead_Type__c FROM Lead Where Id =: leadid limit 1];
        return objlead;
    }
    @AuraEnabled
    public static String convertLead(String leadid, Opportunity opportunity, Account account, Lead lead){
        string message = '';
        try{
            List<Lead> leadLst = [Select Id,Name,Company,Company_Name__c,Lead_Type__c,Street,City,State,Country,Postalcode From Lead Where Id=:leadid];
            //String LeadType = '';
                if(leadLst.size()>0){
                    Lead ld = leadLst[0];
                    Database.LeadConvert lc = new database.LeadConvert();
                    lc.setLeadId(ld.id);
                    lc.setConvertedStatus('Converted');
                    lc.setDoNotCreateOpportunity(true);
                    System.debug('Company_Name__c=>'+ld.Company_Name__c);
                    ld.Lead_Type__c = lead.Lead_Type__c;
                    if(ld.Lead_Type__c == 'Business'){
                        //LeadType = 'Business';
                        if(ld.Company == null || ld.Company == ''){
                            if(ld.Company_Name__c != null ){
                                ld.Company = ld.Company_Name__c;
                            }else {
                                ld.Company = ld.Name;
                            }
                        }
                        //ld.Lead_Type__c = 'Business';
                    }
                    else if(ld.Lead_Type__c == 'Person'){
                        //LeadType = 'Person';
                        ld.Company = null;       
                        //ld.Lead_Type__c = 'Person';
                    }            
                    ld.From_Lead_Convert__c = true;
                    update ld;
                    Savepoint sp;
                    try {
                        String strMsg = validateopportunity(opportunity, account, ld);
                        if(!string.isblank(strMsg)){                                
                            return strMsg;    
                        }
                        sp = Database.setSavepoint();
                        Database.LeadConvertResult lcr = Database.convertLead(lc);   
                        System.debug('lcr-->'+lcr);
                        if(lcr.isSuccess()){                           
                             List<account> lstAccount = new List<account>([Select Id,Primary_Contact__c,PersonContactId,BillingStreet,BillingCity,BillingState,BillingCountry,
                                 BillingPostalCode,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCode,Preferred_Method_of_Contact__pc,
                                 (Select id,Preferred_Method_of_Contact__c from Contacts where Id=:lcr.getContactId())from account where Id =: lcr.getAccountId()]);
                             if(lstAccount.size()>0){
                                lstAccount[0].BillingStreet = ld.Street;
                                lstAccount[0].BillingCity = ld.City;
                                lstAccount[0].BillingState = ld.State;
                                lstAccount[0].BillingCountry = ld.Country;
                                lstAccount[0].BillingPostalCode = ld.PostalCode;
                                
                                lstAccount[0].ShippingStreet = ld.Street;
                                lstAccount[0].ShippingCity = ld.City;
                                lstAccount[0].ShippingState = ld.State;
                                lstAccount[0].ShippingCountry = ld.Country;
                                lstAccount[0].ShippingPostalCode = ld.PostalCode;
                                if(lead.Lead_Type__c != 'Business'){
                                    lstAccount[0].Preferred_Method_of_Contact__pc = account.Preferred_Method_of_Contact__pc;
                                }else{
                                    if(lstAccount[0].Contacts != null){
                                        lstAccount[0].Contacts[0].Preferred_Method_of_Contact__c = account.Preferred_Method_of_Contact__pc;
                                        Update lstAccount[0].Contacts[0];
                                    }
                                }
                                Update lstAccount[0];
                               
                            }
                             if(!string.isblank(opportunity.Event__c)){
                                opportunity.Event__r = null; 
                                opportunity.Name = 'Opt Name'; 
                                
                                                                
                                if(lead.Lead_Type__c == 'Business'){
                                    opportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
                                    opportunity.Primary_Contact__c = lstAccount[0].Primary_Contact__c;
                                    opportunity.StageName = 'Discovery/Demo'; 
                                }else{
                                    opportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Person Opportunity').getRecordTypeId();
                                    opportunity.Primary_Contact__c = lstAccount[0].PersonContactId;
                                    opportunity.StageName = 'Scoping/Proposal'; 
                                }
                                opportunity.accountid = lcr.getAccountId();
                                
                                opportunity.Billing_Street__c = ld.Street;
                                opportunity.Billing_City__c = ld.City;
                                opportunity.Billing_State_Province__c = ld.State;
                                opportunity.Billing_Country__c = ld.Country;
                                opportunity.Billing_Zip_Postal_Code__c = ld.PostalCode;
                                
                                opportunity.Shipping_Street__c = ld.Street;
                                opportunity.Shipping_City__c = ld.City;
                                opportunity.Shipping_State_Province__c = ld.State;
                                opportunity.Shipping_Country__c = ld.Country;
                                opportunity.Shipping_Zip_Postal_Code__c = ld.PostalCode;
                                
                                Insert opportunity;                                
                                
                            }
                            
                            message = opportunity.id;                            
                            return message;                            
                        }
                        else{                            
                            message = 'Error: '+lcr.getErrors()[0].getMessage();
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
              }else{
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
    
    private static string validateopportunity(Opportunity opp, Account account, Lead lead){
        String msg = ''; 
        if(string.isblank(opp.Event__c)){
            if(!string.isblank(msg)) msg += '\n';
            msg += 'Event: You must enter a value';
        }      
        if(string.isblank(opp.Payment_Method__c)){
            if(!string.isblank(msg)) msg += '\n';
            msg += 'Payment Method: You must enter a value';
        }       
        if(opp.Closedate == null){
            if(!string.isblank(msg)) msg += '\n';
            msg += 'Close Date: You must enter a value';
        }
        if(string.isblank(opp.Contact_Site__c)){
            if(!string.isblank(msg)) msg += '\n';
            msg += 'Contact Site: You must enter a value';
        }
        if(string.isblank(opp.CurrencyIsoCode)){
            if(!string.isblank(msg)) msg += '\n';
            msg += 'Opportunity Currency: You must enter a value';
        }
        if(string.isblank(account.Preferred_Method_of_Contact__pc)){
            if(!string.isblank(msg)) msg += '\n';
            msg += 'Preferred Method of Contact: You must enter a value';
        } 
        if(string.isblank(lead.Lead_Type__c)){
            if(!string.isblank(msg)) msg += '\n';
            msg += 'Lead Type: You must enter a value';
        }
        if(opp.Projected_Revenue__c == null ){
            if(!string.isblank(msg)) msg += '\n';
            msg += 'Projected Revenue: You must enter a value';
        }
        return msg;
    }
}
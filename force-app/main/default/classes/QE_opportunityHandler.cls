/**
 * @File Name          : QE_opportunityHandler.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 6:51:55 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
public class QE_opportunityHandler{
    public static boolean isExecutedonce = true;
    public static boolean isH4HHoldExecutedonce = true;
    public void OnBeforeInsert(List<Opportunity> newObjects){
        OnAfterInsert(null);
        // Set<Id> eventId = new Set<Id>();
        // //Map<Id,QE360_Event__c> eventMap = new Map<Id,QE360_Event__c>();
        // Set<Id> priConId = new Set<Id>();
        // Map<Opportunity, Id> opportunitiesAndAccountIds = new Map<Opportunity, Id>();
        // Set<String> emailIds = new Set<String>();
        // try{
        //     for(Opportunity opp: newObjects){
        //         if(opp.Event__c != null)
        //             eventId.add(opp.Event__c);
        //         if(opp.AccountId != null)
        //             opportunitiesAndAccountIds.put(opp,opp.AccountId);
        //         if(opp.Primary_Contact__c != null)
        //             priConId.add(opp.Primary_Contact__c);
        //         if(opp.Email__c != null)
        //             emailIds.add(opp.Email__c);
        //         if(opp.Primary_Contact__c != null && opp.Communications_Contact__c == null) {
        //             opp.Communications_Contact__c = opp.Primary_Contact__c;
        //         }
        //     }
            
            
        //     /*
        //     if(eventId.size() > 0){
        //     for(QE360_Event__c eve: [SELECT Id, Payment_Terms__c FROM QE360_Event__c WHERE Id IN: eventId]){
        //     eventMap.put(eve.Id,eve);
        //     }
        //     }
        //     */
        //     //Update the Payment Terms field based on the Select Payment Terms
        //     /*for(Opportunity opp: newObjects){
        //     if ((opp.Select_Payment_Terms__c).equals('Event Payment Terms')) {
        //     opp.Payment_Terms__c =eventMap.get(opp.Event__c).Payment_Terms__c;
        //     }
        //     if ((opp.Select_Payment_Terms__c).equals('Custom')) {
        //     opp.Payment_Terms__c = opp.Custom_Payment_Terms__c;
        //     } else {
        //     opp.Custom_Payment_Terms__c = null;
        //     }
        //     if((opp.Select_Payment_Terms__c).equals('100% due upon signing')){
        //     opp.Payment_Terms__c = opp.Select_Payment_Terms__c;
        //     }
        //     }*/
        //     // Related Accounts
        //     Map<Id, Account> relatedAccounts = new Map<Id, Account>([
        //         select id, Name,firstname,lastname, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
        //         ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, RecordType.Name, ShippingCountry, Phone, PersonEmail, Visitor_Country__c,
        //         (Select Id,AccountId,Event__c,StageName from Opportunities where StageName ='Closed Won')
        //         from Account
        //         where id in :opportunitiesAndAccountIds.values()
        //     ]);
            
        //     Map<Id,Set<Id>> oppMap = new Map<Id,Set<Id>>();
        //     for( Account accObj : relatedAccounts.values() ){
        //         System.debug('relatedAccounts.get(accObj.Id).Opportunities.size()-->'+relatedAccounts.get(accObj.Id).Opportunities.size());
        //         System.debug('relatedAccounts.get(accObj.Id)-->'+relatedAccounts.get(accObj.Id));
        //         if(relatedAccounts.get(accObj.Id).Opportunities.size() >1){
        //             Set<Id> setId = new Set<Id>();
        //             for(opportunity oppList : relatedAccounts.get(accObj.Id).Opportunities){
        //                 setId.add(oppList.Event__c);
        //             }
        //             oppMap.put(accObj.Id, setId);
        //         }else{
        //             if(relatedAccounts.get(accObj.Id).Opportunities.size() == 1){
        //                 Set<Id> setId = new Set<Id>();
        //                 setId.add(relatedAccounts.get(accObj.Id).Opportunities[0].Event__c);
        //                 oppMap.put(accObj.Id, setId);
        //             }
        //         }
        //     }
            
        //     /*
        //     for( Opportunity opp : oppMap.values() ){
            
        //     }*/
        //     //Primary Contact
        //     Map<Id, Contact> relatedPrimContacts = new Map<Id, Contact>([select Id, AccountId, Name, Phone, Email from contact where Id IN: priConId]);
        //     // Related Events
        //     Map<Id, QE360_Event__c> relatedEvents = new Map<Id, QE360_Event__c>([select id, Name from QE360_Event__c WHERE Id IN: eventId]);
        //     // Leads
        //     List<Lead> leadListids =[SELECT Id,Email,ConvertedAccountId FROM Lead WHERE Email IN :emailIds AND ConvertedAccountId NOT IN :relatedAccounts.keySet() AND Email!= Null LIMIT 50000];
        //     Set<String> Leadmailids=new Set<string>();
        //     if(Test.isRunningTest() || (!leadListids.isEmpty())){
        //         for(Lead ld :leadListids){
        //             Leadmailids.add(ld.Email);
        //         }
        //     }
        //     // Accounts
        //     List<Account> AccountEmailIds =[Select Id,PersonEmail,Primary_Contact__r.Email FROM Account WHERE Id NOT IN :relatedAccounts.keySet() AND PersonEmail IN :emailIds AND PersonEmail!= Null LIMIT 50000];
        //     Set<String> dupAccountids = new Set<String>();
        //     if(Test.isRunningTest() || (!AccountEmailIds.isEmpty())) {
        //         for(Account acc: AccountEmailIds) {
        //             dupAccountids.add(acc.PersonEmail);
        //         }
        //     }
        //     //All Contacts existing with Email Id's
        //     List<Contact> ConEmailIds =[Select Id,Email FROM Contact WHERE Id NOT IN :relatedPrimContacts.keyset() AND Email!=null AND Email IN :emailIds LIMIT 50000 ];
        //     set<string> dupConmail = new Set<String>();
        //     if(Test.isRunningTest() || (!ConEmailIds.isEmpty())) {
        //         for(Contact con: ConEmailIds) {
        //             dupConmail.add(con.Email);
        //         }
        //     }
        //     Set<String> billPicklistStates = new Set<String>();
        //     for(Schema.PicklistEntry pickListVal : Opportunity.Billing_State_Province__c.getDescribe().getPicklistValues()){
        //         if(pickListVal.isActive()) {
        //             billPicklistStates.add(pickListVal.getLabel());
        //         }
        //     }
        //     Set<String> shipPicklistStates = new Set<String>();
        //     for(Schema.PicklistEntry pickListVal : Opportunity.Shipping_State_Province__c.getDescribe().getPicklistValues()){
        //         if(pickListVal.isActive()) {
        //             shipPicklistStates.add(pickListVal.getLabel());
        //         }
        //     }
        //     // Opportunities
        //     for (Opportunity currentOpportunity : opportunitiesAndAccountIds.keySet()) {
        //         currentOpportunity.Bill_To_Name__c = relatedAccounts.get(currentOpportunity.AccountId).Name;
        //         currentOpportunity.Billing_Street__c = relatedAccounts.get(currentOpportunity.AccountId).BillingStreet;
        //         currentOpportunity.Billing_City__c = relatedAccounts.get(currentOpportunity.AccountId).BillingCity;
        //         currentOpportunity.Billing_Country__c = relatedAccounts.get(currentOpportunity.AccountId).BillingCountry;
        //         currentOpportunity.Billing_State_Province__c = billPicklistStates.contains(relatedAccounts.get(currentOpportunity.AccountId).BillingState) ? relatedAccounts.get(currentOpportunity.AccountId).BillingState : '';
        //         currentOpportunity.Billing_Zip_Postal_Code__c = relatedAccounts.get(currentOpportunity.AccountId).BillingPostalCode;
        //         currentOpportunity.Ship_To_Name__c = relatedAccounts.get(currentOpportunity.AccountId).Name;
        //         currentOpportunity.Shipping_Street__c = relatedAccounts.get(currentOpportunity.AccountId).ShippingStreet;
        //         currentOpportunity.Shipping_City__c = relatedAccounts.get(currentOpportunity.AccountId).ShippingCity;
        //         currentOpportunity.Shipping_Country__c = relatedAccounts.get(currentOpportunity.AccountId).ShippingCountry;
        //         currentOpportunity.Shipping_State_Province__c = shipPicklistStates.contains(relatedAccounts.get(currentOpportunity.AccountId).ShippingState) ? relatedAccounts.get(currentOpportunity.AccountId).ShippingState : '';
        //         currentOpportunity.Shipping_Zip_Postal_Code__c = relatedAccounts.get(currentOpportunity.AccountId).ShippingPostalCode;
        //         currentOpportunity.Name = relatedEvents.get(currentOpportunity.Event__c).Name;
        //         if (relatedAccounts.get(currentOpportunity.AccountId).Visitor_Country__c != null) {
        //             currentOpportunity.Visitor_Country__c = relatedAccounts.get(currentOpportunity.AccountId).Visitor_Country__c;
        //         }
        //         if(currentOpportunity.Email__c == null )
        //         {
        //             if(relatedAccounts.get(currentOpportunity.AccountId).RecordType.Name =='Person Account')
        //             {
        //                 currentOpportunity.Email__c = relatedAccounts.get(currentOpportunity.AccountId).PersonEmail;
        //             }
        //             if(relatedAccounts.get(currentOpportunity.AccountId).RecordType.Name =='Business Account' || Test.isRunningTest())
        //             {
        //                 if(relatedPrimContacts.size() > 0 && currentOpportunity.Primary_Contact__c != null && relatedPrimContacts.get(currentOpportunity.Primary_Contact__c) != null){
        //                     currentOpportunity.Email__c = relatedPrimContacts.get(currentOpportunity.Primary_Contact__c).Email;
        //                     currentOpportunity.Primary_Attendee_Name__c = relatedPrimContacts.get(currentOpportunity.Primary_Contact__c).Name;
        //                     currentOpportunity.Primary_Attendee_Phone__c = relatedPrimContacts.get(currentOpportunity.Primary_Contact__c).Phone;
        //                     currentOpportunity.Primary_Attendee_Email__c = relatedPrimContacts.get(currentOpportunity.Primary_Contact__c).Email;
                            
        //                 }
        //             }
        //         }
        //         //Not to allow opportunity if email exists in account/leads except the associated account and converted lead email.
        //         else if(currentOpportunity.Email__c != null) {
        //             if(Leadmailids.contains(currentOpportunity.email__c)){
        //                 currentOpportunity.addError('Email already exist in Leads');
        //             }
        //             else if(relatedAccounts.get(currentOpportunity.AccountId).RecordType.Name=='Person Account' &&  dupAccountids.contains(currentOpportunity.email__c)){
        //                 currentOpportunity.addError('Please choose a different Email as it exists in accounts');
        //             }
        //             //opportunity if business account checks the email with existing primarycontact/lead excluding the associated records email.
        //             else if(relatedAccounts.get(currentOpportunity.AccountId).RecordType.Name=='Business Account' && currentOpportunity.Primary_Contact__c != null  &&  dupConmail.contains(currentOpportunity.email__c)){
        //                 currentOpportunity.addError('Please choose a different Email as it exists in Clients');
        //             }
        //         }
        //         if(currentOpportunity.Phone__c==null)
        //         {
        //             if(relatedAccounts.get(currentOpportunity.AccountId).RecordType.Name=='Person Account')
        //             {
        //                 currentOpportunity.Phone__c = relatedAccounts.get(currentOpportunity.AccountId).Phone;
        //             }
        //             else if(Test.isRunningTest() || relatedAccounts.get(currentOpportunity.AccountId).RecordType.Name=='Business Account')
        //             {
        //                 Id OppRcdId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
        //                 if(relatedPrimContacts.size() > 0 && currentOpportunity.Primary_Contact__c != null && relatedPrimContacts.get(currentOpportunity.Primary_Contact__c) != null ){
        //                     currentOpportunity.Phone__c = relatedPrimContacts.get(currentOpportunity.Primary_Contact__c).Phone;
        //                     if(currentOpportunity.RecordTypeId == OppRcdId ) {
        //                         currentOpportunity.Bill_To_Name__c = relatedPrimContacts.get(currentOpportunity.Primary_Contact__c).Name;
        //                         currentOpportunity.Billing_Street__c = relatedAccounts.get(currentOpportunity.AccountId).Name +'\n'+relatedAccounts.get(currentOpportunity.AccountId).BillingStreet;
        //                     }
        //                 }else{
        //                     currentOpportunity.Phone__c = relatedAccounts.get(currentOpportunity.AccountId).Phone;
        //                 }
        //             }
        //         }
        //         if(relatedPrimContacts != null && relatedPrimContacts.size() > 0) {
        //             currentOpportunity.Primary_Attendee_Name__c = relatedPrimContacts.get(currentOpportunity.Primary_Contact__c).Name;
        //             currentOpportunity.Primary_Attendee_Phone__c = relatedPrimContacts.get(currentOpportunity.Primary_Contact__c).Phone;
        //             currentOpportunity.Primary_Attendee_Email__c = relatedPrimContacts.get(currentOpportunity.Primary_Contact__c).Email;
        //         }
        //         System.debug('currentOpportunity.AccountId-->'+currentOpportunity.AccountId);
        //         System.debug('oppMap.containsKey(currentOpportunity.AccountId)-->'+oppMap.containsKey(currentOpportunity.AccountId));
        //         System.debug('oppMap.get(currentOpportunity.AccountId)-->'+oppMap.get(currentOpportunity.AccountId));
        //         if(oppMap.containsKey(currentOpportunity.AccountId) && oppMap.get(currentOpportunity.AccountId) != null){
        //             if( !oppMap.get(currentOpportunity.AccountId).contains(currentOpportunity.Event__c)){
        //                 currentOpportunity.Type = 'Existing Business';
        //             }else if( oppMap.get(currentOpportunity.AccountId).contains(currentOpportunity.Event__c) && oppMap.get(currentOpportunity.AccountId).size() ==1){
        //                 currentOpportunity.Type = 'New Business';    
        //             }else if( oppMap.get(currentOpportunity.AccountId).contains(currentOpportunity.Event__c) && oppMap.get(currentOpportunity.AccountId).size() >1){
        //                 currentOpportunity.Type = 'Existing Business';
        //             }
                    
        //         }else{
        //             currentOpportunity.Type = 'New Business';
        //         }
        //     }
        // }catch(Exception ex){
        //     System.Debug('Exception=>'+ex+'Line Number=>'+ex.getLineNumber());
        // }
    }
    public void OnAfterInsert(List<Opportunity> newObjects){
        OnBeforeUpdate(null, null,null,null);
        /* Added by JP - Starts */
        // Get Account Ids
        // Set<Id> accountIds = new Set<Id>();
        // Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
        // for (Opportunity oppt : newObjects) {
        //     accountIds.add(oppt.AccountId);
        //     opportunityMap.put(oppt.Id,oppt);
        // }
        // // Get Account Primary Contact
        // List<Account> accountsWithContacts = [select Id, Name, (select Id, Primary_Contact__c from Contacts) from Account where Id in :accountIds];
        // Map<Id,Contact> accountIdsAndContacts = new Map<Id,Contact>();
        // List<Contact> contactsToBeCreated = new List<Contact>();
        // for (Account account : accountsWithContacts) {
        //     // Account Has Contact
        //     if (account.Contacts.size() > 0) {
        //         // Get Primary Contact if its there
        //         boolean accountPrimaryContact = false;
        //         for (Contact contact : account.Contacts) {
        //             if (contact.Primary_Contact__c) {
        //                 accountPrimaryContact = true;
        //                 accountIdsAndContacts.put(account.Id, contact);
        //             }
        //         }
        //         // Account don't have primary contact, so first contact will be used for OCR creation.
        //         if (accountPrimaryContact == false) {
        //             accountIdsAndContacts.put(account.Id, account.Contacts.get(0));
        //         }
        //     } else {
        //         // Account dont have Contacts (Create New Contact)
        //         Contact contact = new Contact(AccountId = account.Id,Primary_Contact__c = true,LastName = account.Name);
        //         contactsToBeCreated.add(contact);
        //     }
        // }
        // // Insert new contacts
        // insert contactsToBeCreated;
        // // Add newly created contacts to accountIdAndContact map
        // for (Contact contact : contactsToBeCreated) {
        //     accountIdsAndContacts.put(contact.AccountId, contact);
        // }
        // // Create Opportunitiy contact role
        // List<OpportunityContactRole> opptContactRolesToInsert = new List<OpportunityContactRole>();
        // for(Opportunity oppt : newObjects){
        //     // Create contact role for this opportunity
        //     OpportunityContactRole currentOpptContactRole = new OpportunityContactRole();
        //     if(oppt.Id != null) {
        //         currentOpptContactRole.OpportunityId = oppt.Id;
        //     }
        //     if(accountIdsAndContacts.get(oppt.AccountId).Id != null) {
        //         currentOpptContactRole.ContactId = opportunityMap.get(oppt.Id).Primary_Contact__c;
        //     }
        //     currentOpptContactRole.IsPrimary = true;
        //     currentOpptContactRole.Role = 'Primary Contact';
        //     System.debug('currentOpptContactRole-->'+currentOpptContactRole);
        //     opptContactRolesToInsert.add(currentOpptContactRole);
            
        //     //Communications Contact
        //     if(oppt.Communications_Contact__c != null) {
        //         OpportunityContactRole CommunicationsContactRole = new OpportunityContactRole();
        //         CommunicationsContactRole.OpportunityId = oppt.Id;
        //         CommunicationsContactRole.ContactId = oppt.Communications_Contact__c;
        //         CommunicationsContactRole.Role = 'Communications Contact';
        //         System.debug('CommunicationsContactRole-->'+CommunicationsContactRole);
        //         opptContactRolesToInsert.add(CommunicationsContactRole);
        //     }
        
        // }
        // if(opptContactRolesToInsert != null && opptContactRolesToInsert.size() > 0) {
        //     insert opptContactRolesToInsert;
        // }
        /* Added by JP - Ends */
    }
    public void OnBeforeUpdate(List<Opportunity> oldObjects, List<Opportunity> updatedObjects,Map<Id,Opportunity> MapObjectMap,Map<Id,Opportunity> oldMapObjectMap){
            OnAfterUpdate(null, null,null,null);
//         Set<Id> eventId = new Set<Id>();
//         Set<Id> priConId = new Set<Id>();
//         //Map<Id,QE360_Event__c> eventMap = new Map<Id,QE360_Event__c>();
//         Map<Opportunity, Id> opportunitiesAndAccountIds = new Map<Opportunity, Id>();
//         Set<String> emailIdset = new Set<String>();
//         Set<String> currencyISOset = new Set<String>();
//         Set<Date> exchangeRateDateset = new Set<Date>();
        
//         Set<Id> OppIds = new Set<Id>();
//         for(Opportunity opps: updatedObjects) {
//             if(((opps.StageName).equals('Canceled')) && ((oldMapObjectMap.get(opps.Id).StageName).equals('Closed Won'))) {
//                 OppIds.add(opps.Id);
//             }
//         }
//         Map<Id, Boolean> oppHasPassPT = new Map<Id, Boolean>();
//         if(OppIds.size()>0){
//             for(Opportunity objOpp: [Select Id, (Select Id, Status__c From Opportunity_Payment_Terms__r) From Opportunity Where Id in :OppIds]){
//                 oppHasPassPT.put(objOpp.Id, false);
//                 for(Opportunity_Payment_Terms__c objOPT: objOpp.Opportunity_Payment_Terms__r){
//                     if(objOPT.Status__c == 'Passed'){
//                         oppHasPassPT.put(objOpp.Id, true);
//                         break;
//                     }
//                 }
//             }
//         }
        
//         try {
//              for(Opportunity opp: updatedObjects) {
//                 if(opp.Primary_Contact__c != null && opp.Communications_Contact__c == null && oldMapObjectMap.get(opp.Id).Primary_Contact__c == null
//                         && oldMapObjectMap.get(opp.Id).Communications_Contact__c == null) {
//                     System.debug('@@@@@272');
//                     opp.Communications_Contact__c = opp.Primary_Contact__c;
//                 }
//             }
            
            
//             for(Opportunity opp: updatedObjects){
//                 if((opp.Email__c != null && MapObjectMap.get(opp.Id).Email__c != oldMapObjectMap.get(opp.Id).Email__c) || Test.isRunningTest()){
//                     emailIdset.add(opp.Email__c);
//                     priConId.add(opp.Primary_Contact__c);
//                 }
//                 if(opp.Event__c != null) {
//                     eventId.add(opp.Event__c);
//                 }
//                 if(opp.AccountId != null) {
//                     opportunitiesAndAccountIds.put(opp,opp.AccountId);
//                 }
//                 if((opp.Primary_Contact__c != null && MapObjectMap.get(opp.Id).Primary_Contact__c != oldMapObjectMap.get(opp.Id).Primary_Contact__c ) || Test.isRunningTest()){
//                     priConId.add(opp.Primary_Contact__c);
//                     emailIdset.add(opp.Email__c);
//                 }
//                 /* Added by Jeet */
//                 // Check if oppt is being closed lost from closed won
                
//                 if(((opp.StageName).equals('Request Cancelation')) && ((oldMapObjectMap.get(opp.Id).StageName).equals('Closed Won'))) {
                    
//                     if(oppHasPassPT != null && oppHasPassPT.containsKey(opp.Id) && oppHasPassPT.get(opp.Id)) {
//                         opp.Cancellation_Reasons_For_Review_Acc__c = 'Cancellation request for opportunity which has paid payment term';
//                         opp.Cancellation_Reasons_For_Review_Oper__c = 'Cancellation request for opportunity which has paid payment term';
//                     }
//                     if(opp.Tracking_Number__c != null) {
//                         opp.Cancellation_Reasons_For_Review_Acc__c = 'Cancellation request for order which has been shipped';
//                         opp.Cancellation_Reasons_For_Review_Oper__c = 'Cancellation request for order which has been shipped';
//                     }
                    
//                     // check if current oppt has gone through approval process and is approved
//                     /*if(!opp.Approved_Canceled_From_Closed_Won__c) {
//                         // check if contract lost reason is provided
//                         if(opp.Reason_For_Cancellation__c == null || opp.Reason_For_Cancellation__c.equals('')) {
//                             opp.addError('Please select value for "Reason For Cancellation" field.');
//                         } else {
//                             // change stage back to what it was
//                             opp.StageName =  'Under Review'; // oldMapObjectMap.get(opp.Id).StageName;                            
                            
//                             /*if(AllocatedOpportunity != null && AllocatedOpportunity.contains(opp.Id)) {
//                                 opp.Closed_Won_Reasons_For_Review_Operations__c = 'Contains Allocated Product';
//                             }*/
//                             /*system.debug('####opp.Cancellation_Reasons_For_Review_Acc__c=='+opp.Cancellation_Reasons_For_Review_Acc__c);
//                             system.debug('####opp.Cancellation_Reasons_For_Review_Oper__c =='+opp.Cancellation_Reasons_For_Review_Oper__c);
//                             // submit for approval
//                             Approval.ProcessSubmitRequest opptApprovalRequest = new Approval.ProcessSubmitRequest();
//                             opptApprovalRequest.setObjectId(opp.id);
//                             opptApprovalRequest.setProcessDefinitionNameOrId('Opportunity_Canceled_From_Closed_Won');
//                             opptApprovalRequest.setSkipEntryCriteria(true);
//                             Approval.ProcessResult result = Approval.process(opptApprovalRequest);
//                         }
//                     }*/
//                 }
//                 /* Added by Jeet Ends */
//                 system.debug('opp.StageName= '+opp.StageName);
//                 system.debug('Old StageName= '+oldMapObjectMap.get(opp.Id).StageName);
//                 /* Added by RV */
//                 // Check if oppt is being Defaulted from closed won
//                 if(((opp.StageName).equals('Defaulted')) && ((oldMapObjectMap.get(opp.Id).StageName).equals('Closed Won'))) {
//                     // change stage back to what it was
//                     opp.StageName =  'Under Review'; // oldMapObjectMap.get(opp.Id).StageName;
//                     // submit for approval
//                     Approval.ProcessSubmitRequest opptApprovalRequest = new Approval.ProcessSubmitRequest();
//                     opptApprovalRequest.setObjectId(opp.id);
//                     opptApprovalRequest.setProcessDefinitionNameOrId('Opportunity_Defaulted_From_Closed_Won');
//                     opptApprovalRequest.setSkipEntryCriteria(true);
//                     Approval.ProcessResult result = Approval.process(opptApprovalRequest);
//                 }
//                 /* Added by RV  End*/
//                 //Added by VA
//                 //get Exchange Rate Date and Currency Code
//                 System.debug('test opp: ' + opp.Exchange_Rate_Date__c);
//                 System.debug('test old opp: ' + oldMapObjectMap.get(opp.Id).Exchange_Rate_Date__c );
//                 if(opp.Exchange_Rate_Date__c != null && opp.Exchange_Rate_Date__c != oldMapObjectMap.get(opp.Id).Exchange_Rate_Date__c ) {
//                     currencyISOset.add(opp.CurrencyIsoCode);
//                     exchangeRateDateset.add(opp.Exchange_Rate_Date__c.date());
//                 }
//             }
            
//             /*
// if(eventId.size() > 0){
// for(QE360_Event__c eve: [SELECT Id, Payment_Terms__c FROM QE360_Event__c WHERE Id IN: eventId]){
// eventMap.put(eve.Id,eve);
// }
// }
// */
//             //Primary Contact
//             /*
// if(priConId != null)
// */
//             // Related Accounts
//             Map<Id, Account> relatedAccounts = new Map<Id, Account>();
//             //All Leads existing with Email Id's
//             List<Lead> leadList =new List<Lead>();
//             List<Account> AccountEmails = new List<Account>();
//             Set<String> dupAccountmailids = new Set<String>();
//             Set<String> dupLeadmailids=new Set<string>();
//             Map<Id, Contact> relatedPrimContacts = new Map<Id, Contact>();
//             Set<string> dupConmailids = new Set<String>();
            
//             Map<Date, Map<String, Double>> mapDatedExchangeRate = new Map<Date, Map<String, Double>>();
//             if(!currencyISOset.isEmpty() && !exchangeRateDateset.isEmpty()) {
//                 List<DatedConversionRate> dcrs = Test.isRunningTest() ? new List<DatedConversionRate>{new DatedConversionRate(IsoCode='GBP',StartDate=System.Today(),ConversionRate=0.85)} : [Select Id, IsoCode, ConversionRate, StartDate from DatedConversionRate where IsoCode In :currencyISOset AND StartDate In :exchangeRateDateset];
//                 for(DatedConversionRate dcRate : dcrs) {
//                     Map<String, Double> mapIsowithRate = mapDatedExchangeRate.get(dcRate.StartDate);
//                     if(mapIsowithRate == null) {
//                         mapIsowithRate = new Map<String, Double>();
//                     }
//                     mapIsowithRate.put(dcRate.IsoCode, dcRate.ConversionRate);
//                     mapDatedExchangeRate.put(dcRate.StartDate, mapIsowithRate);
//                 }
//             }
//             if(Test.isRunningTest() || (!emailIdset.isEmpty()) || !mapDatedExchangeRate.isEmpty()){
//                 if(Test.isRunningTest() || !emailIdset.isEmpty()) {
//                     relatedAccounts = new Map<Id,Account>([SELECT  id, Phone, PersonEmail,RecordType.Name
//                                                            from Account
//                                                            where id in :opportunitiesAndAccountIds.values()
//                                                           ]);
//                     relatedPrimContacts = new Map<Id,Contact>([select Id, AccountId, Name, Phone, Email from contact where Id IN: priConId]);
//                     leadList = [SELECT Id,Email,ConvertedAccountId FROM Lead WHERE ConvertedAccountId NOT IN :relatedAccounts.keySet() AND Email IN :emailIdset AND Email!= null LIMIT 50000];
                    
//                     if(!leadList.isEmpty() || Test.isRunningTest()){
//                         for(Lead ld :leadList){
//                             dupLeadmailids.add(ld.Email);
//                         }
//                     }
//                     //All Accounts existing with Email Id's
//                     AccountEmails =[Select Id,PersonEmail,Primary_Contact__r.Email FROM Account WHERE PersonEmail!=null AND Id NOT IN :relatedAccounts.keyset() AND PersonEmail IN :emailIdset LIMIT 50000];
//                     if(!AccountEmails.isEmpty() || Test.isRunningTest()) {
//                         for(Account acc: AccountEmails) {
//                             dupAccountmailids.add(acc.PersonEmail);
//                         }
//                     }
//                     //All Contacts existing with Email Id's
//                     List<Contact> ConEmails =[Select Id,Email FROM Contact WHERE Email!= null AND Id NOT IN :priConId AND Email IN :emailIdset LIMIT 50000];
                    
//                     if(!ConEmails.isEmpty()) {
//                         for(Contact con: ConEmails) {
//                             dupConmailids.add(con.Email);
//                         }
//                     }
//                 }
//                 //For RecordType
//                 // Id OppRcdBussId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
//                 //Id OppRcdPersId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Person Opportunity').getRecordTypeId();
//                 for(Opportunity opp: updatedObjects) {
//                     if(Test.isRunningTest() || !emailIdset.isEmpty()) {
//                         if(relatedAccounts.get(opp.AccountId) != null && relatedAccounts.get(opp.AccountId).RecordType.Name=='Person Account' && opp.email__c != relatedAccounts.get(opp.AccountId).PersonEmail && dupLeadmailids.contains(opp.email__c)){
//                             opp.addError('Email already exists leads');
//                         }
//                         else if(relatedAccounts.get(opp.AccountId).RecordType.Name=='Business Account'  && opp.email__c != relatedPrimContacts.get(opp.Primary_Contact__c).Email && dupLeadmailids.contains(opp.email__c)){
//                             opp.addError('Email already exists leads');
//                         }
//                         else if(relatedAccounts.get(opp.AccountId).RecordType.Name=='Person Account' && opp.Email__c != null &&  dupAccountmailids.contains(opp.email__c) && opp.email__c != relatedAccounts.get(opp.AccountId).PersonEmail){
//                             opp.addError('Email already exists in accounts');
//                         }
//                         else if(relatedAccounts.get(opp.AccountId).RecordType.Name=='Business Account' && opp.Email__c != null  &&  dupConmailids.contains(opp.email__c) && opp.email__c != relatedPrimContacts.get(opp.Primary_Contact__c).Email){
//                             opp.addError('Email already exists contacts');
//                         }
                        
//                         if(Test.isRunningTest() ||(opp.Primary_Contact__c != null && oldMapObjectMap.get(opp.Id).Primary_Contact__c!=opp.Primary_Contact__c))
//                         {
//                             Id OppRcdId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
//                             if(relatedAccounts.get(opp.AccountId).RecordType.Name=='Person Account'){
//                                 opp.Phone__c = relatedPrimContacts.get(opp.Primary_Contact__c).Phone;
//                                 opp.Email__c = relatedPrimContacts.get(opp.Primary_Contact__c).Email;
//                             }else if(relatedAccounts.get(opp.AccountId).RecordType.Name=='Business Account'){
//                                 opp.Email__c = relatedPrimContacts.get(opp.Primary_Contact__c).Email;
//                                 opp.Phone__c = relatedPrimContacts.get(opp.Primary_Contact__c).Phone;
//                                 if(opp.RecordTypeId == OppRcdId){
//                                     opp.Bill_To_Name__c = relatedPrimContacts.get(opp.Primary_Contact__c).Name;
//                                     opp.Billing_Street__c = relatedAccounts.get(opp.AccountId).Name+'\n'+relatedAccounts.get(opp.AccountId).BillingStreet;
//                                 }
//                             }
//                         }
//                     }
//                     if(opp.Exchange_Rate_Date__c != null && mapDatedExchangeRate.containsKey(opp.Exchange_Rate_Date__c.date()) && mapDatedExchangeRate.get(opp.Exchange_Rate_Date__c.date()).containsKey(opp.CurrencyIsoCode)) {
//                         opp.Exchange_Rate__c = mapDatedExchangeRate.get(opp.Exchange_Rate_Date__c.date()).get(opp.CurrencyIsoCode);
//                     }
//                 }
//             }
//         }catch(Exception ex){
//             System.debug('Exception=>'+ex+'Line Number=>'+ex.getLineNumber());
//         }
    }
    public void OnAfterUpdate(List<Opportunity> oldObjects, List<Opportunity> updatedObjects,Map<Id,Opportunity> MapObjectMap,Map<Id,Opportunity> oldObjectMap){
        OnAfterDelete(null);
        // Get extra data from opportunity
    //     Map<Id,Opportunity> updatedOpptsWithMoreData = new Map<Id,Opportunity>();
    //     if(updatedObjects != null && updatedObjects.size() > 0) {
    //         updatedOpptsWithMoreData = new Map<Id,Opportunity>([SELECT Id, Name, CloseDate, Ship_To_Name__c, RecordType.name, Event__r.Program__r.name, Reward_Points_Pending__c, Amount, Account.Id,  
    //                                     Grand_Total__c,  StageName, event__r.name, Online_Order__c, Email__c, Number_of_Hotels_with_Packages__c, Number_of_Packages__c, Account.Resellers_Name__c, 
    //                                     Account.Resellers_Name__r.Default_Commission__c, Event__r.id, Account.Name, Paid_in_Full__c, Bill_To_Name__c,  Event__c, Event__r.Brandfuel_Category_Id__c, 
    //                                     Event__r.End_Date__c, Event__r.Brandfuel_End_Date__c, 
    //                                     (SELECT Id, Opportunity__c, Payment_Term__c, Status__c, Amount__c, Percentage_Of_Payment__c, Payment_Due_Date__c From Opportunity_Payment_Terms__r), 
    //                                     (SELECT Id, Name, quantity, OpportunityId, ProductType__c, Product_Type__c, product2.Brandfuel_Points__c, Record_Type__c, Product2.Name, Opportunity.Id, 
    //                                      Opportunity.StageName FROM OpportunityLineItems) From Opportunity Where Id in :updatedObjects]);
    //     }
        
    //     //To collect opp products with producttype Giftbag and has value on brandfuel points field to add all points.
    //     List<Id> OpportunityLineItemIds = new List<Id>();
    //     Set<string> contEmailSet  = new Set<string>();
    //     List<string> oppNameList = new List<String>();
    //     List<opportunity> oppListIds = new List<opportunity>();
    //     List<Opportunity> oppList = new List<Opportunity>();
    //     Map<String,String> oppAttMap = new Map<String,String>();
    //     Map<Id,Opportunity> oppMapUpdate = new Map<Id,Opportunity>();
    //     Decimal sumPaymentTerms = 0;
    //     Set<String> EventcheckSet = new Set<string>();
    //     Map<String,String> userkeyMap = new Map<string,String>();
    //     Set<Id> contactIdset = new Set<Id>();
    //     Set<String> recordTypeOpp = new Set<String> {'Person Opportunity','Business Opportunity'};
        
    //     // To check if brandfuel member exists with opp email
    //     Set<Id> OpportunityIdH4H =new Set<Id>();
    //     Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
    //     Set<String> emailSet = new Set<String>();
    //     Set<String> oppEmails = new Set<String>();
    //     Map<id,opportunity> oppAttId = new Map<Id,opportunity>();
        
        
    //     for(Opportunity opp : updatedOpptsWithMoreData.values()) {
    //         if((oldObjectMap.get(opp.id).stageName != 'Closed won' && opp.stageName =='Closed Won' && opp.Event__r.Brandfuel_Category_Id__c != null && opp.email__c != null) || Test.isRunningTest()){
    //             emailSet.add(opp.Email__c);
    //             oppMap.put(opp.Id,opp);
    //         }
    //         if((opp.stageName == 'closed won' && opp.Event__r.brandfuel_category_Id__c != null && opp.email__C != null) || Test.isRunningTest()) {
    //             oppEmails.add(opp.Email__c);
    //             oppAttId.put(opp.id,opp);
    //         }
    //     }
        
    //     if(oppEmails != null && oppEmails.size() > 0) {
    //         for(opportunity_attendee__c opAtt : [Select Id, Email__C, Contact__r.brandfuel_user_key__C FROM opportunity_attendee__C where email__C != null AND contact__r.brandfuel_user_key__c != null AND opportunity__r.event__r.brandfuel_category_id__c != null AND Email__C IN :oppEmails]) {
    //             oppAttMap.put(opAtt.Email__c,opAtt.Contact__r.brandfuel_user_key__C);
    //         }
    //     }
        
    //     Map<String,Contact> contactMap = new Map<String,contact> ();
    //     if(emailSet != null && emailSet.size() > 0){
    //         for(contact con :[SELECT Id, Email, Name FROM Contact WHERE Email IN :emailSet]){
    //             contactMap.put(con.Email,con);
    //         }
    //     }
    //     /*if(Test.isRunningTest()){
    //        contactMap.clear(); 
    //     }*/
        
    //     List<contact> contactListToInsert = new List<contact>();
    //     List<opportunity_attendee__c> opportunityattendeeToInsert = new List<opportunity_attendee__c>();
    //     // if(oppAttendeeMap.isEmpty()){
    //     for(Opportunity opp : oppMap.values()){
    //         if(contactMap.isEmpty()){
    //             contact con = new Contact();
    //             con.LastName =opp.Account.Name;
    //             con.Email = opp.Email__c;
    //             //System.debug('opp.Email__c-->'+opp.Email__c);
    //             contactListToInsert.add(con);
    //         }else{
    //             //For existing contacts with opp email.
    //             opportunity_attendee__c opa = new opportunity_attendee__c();
    //             opa.Name = contactMap.get(opp.Email__c).Name;
    //             opa.Email__c = opp.Email__c;
    //             opa.opportunity__c = opp.Id;
    //             opa.contact__c = contactMap.get(opp.Email__c).Id;
    //             opportunityattendeeToInsert.add(opa);
    //         }
    //     }
    //     // }
    //     if(contactMap.isEmpty() && !contactListToInsert.isEmpty()){
    //         if(!Test.isRunningTest() && contactListToInsert != null && contactListToInsert.size() > 0){
    //             insert contactListToInsert;
    //         }
    //         //For New Emails with no Contacts
    //         for(Opportunity oppl : oppMap.values()){
    //             opportunity_attendee__c opa = new opportunity_attendee__c();
    //             opa.opportunity__c = oppl.Id;
    //             opa.Name = contactListToInsert[0].Lastname;
    //             opa.email__c = oppl.email__c;
    //             opa.contact__c = contactListToInsert[0].Id;
    //             opportunityattendeeToInsert.add(opa);
    //         }
    //     }
        
    //     if(!opportunityattendeeToInsert.isEmpty()){
    //         if(!Test.isRunningTest() && opportunityattendeeToInsert != null && opportunityattendeeToInsert.size() > 0) {
    //             insert opportunityattendeeToInsert;
    //         }
    //     }
        
    //     Map<Id,Id> optAttMap = new Map<Id,Id>();
    //     Map<Id,Opportunity> oppProdListUpdate = new Map<Id,Opportunity>();
    //     String oppAttUserkeyId;
    //     Map<Id,opportunity_attendee__c> oppAttendeeMap = new Map<Id,opportunity_attendee__c>();
        
    //     if(oppAttId != null && oppAttId.size() > 0) {
    //         oppAttendeeMap = new Map<Id,opportunity_attendee__c>([SELECT Id, Opportunity__c, Contact__c, Contact__r.brandfuel_user_key__c FROM Opportunity_Attendee__c WHERE Opportunity__c IN :oppAttId.keyset()]);
    //     }
        
    //     if(!oppAttendeeMap.isEmpty() || test.isRunningTest()) {
    //         for(opportunity_attendee__C optAtt : oppAttendeeMap.values()) {
    //             optAttMap.put(optAtt.opportunity__C,optAtt.contact__C);
    //             oppAttUserkeyId = optAtt.Contact__r.brandfuel_user_key__c;
    //         }
    //     }
        
    //     Map<Id,String>  couponIdMap = new Map<Id,String>();
    //     Map<String,Set<Id>> couponEvMap = new Map<String,Set<Id>>();
    //     if(optAttMap != null && optAttMap.size() > 0) {
    //         for(Brandfuel_coupon__c bcoupn : [SELECT Id, Contact__r.Email, Contact__c, Coupon_Id__c, Event__r.Id FROM Brandfuel_coupon__c where Contact__c != null AND Contact__c IN :optAttMap.values()]){
    //             couponIdMap.put(bcoupn.Event__r.id,bcoupn.Coupon_id__c);
    //             if(couponEvMap.containsKey(bcoupn.Contact__r.Email)) {
    //                 Set<Id> oppEmailIds = couponEvMap.get(bcoupn.Contact__r.Email);
    //                 oppEmailIds.add(bcoupn.Event__r.id);
    //                 couponEvMap.put(bcoupn.Contact__r.Email,oppEmailIds);
    //             }
    //             else {
    //                 couponEvMap.put(bcoupn.Contact__r.Email,new Set<Id>{bcoupn.Event__r.id});
    //             }
    //         }
    //     }
        
    //     for(Opportunity opp : updatedOpptsWithMoreData.values()){
    //         Boolean isDiscount = false;
            
    //         for(OpportunityLineItem oppLineItem: opp.OpportunityLineItems) {
    //             // To get the opp line items name,quantity and save on product Listing field in opportunity.
    //             if(opp.stageName =='Closed Won' && oppLineItem.quantity != null && (oppLineItem.Record_Type__c == 'Package' || oppLineItem.Record_Type__c == 'Optional Package Product' || oppLineItem.Record_Type__c == 'A La Carte') && (oppLineItem.ProductType__c != 'Shipping and handling' && oppLineItem.ProductType__c != 'Discount' && oppLineItem.ProductType__c != 'Reward Discount')){
    //                 String oppNameQuantity = oppLineItem.product2.Name+' '+'-'+' '+oppLineItem.quantity;
    //                 oppNameList.add(oppNameQuantity);
    //                 opp.Product_listing__C = String.join(oppNameList,';\n');                     
    //                 //opp.Product_listing__c = finalString;
    //                 oppProdListUpdate.put(opp.id,opp);
    //             }
    //             if(oppLineItem.ProductType__c == 'Giftbag' && oppLineItem.product2.Brandfuel_Points__c != null){
    //                 OpportunityLineItemIds.add(oppLineItem.Id);
    //             }
    //         }
            
    //         // Sum payment terms for the closed and defaulted stages.
    //         if(oldObjectMap.get(opp.Id).StageName != opp.StageName) {
    //             sumPaymentTerms = 0;
    //             if((opp.StageName == 'Closed Won' || opp.StageName == 'Defaulted') && recordTypeOpp.contains(opp.Recordtype.name)) {
    //                 for(Opportunity_Payment_Terms__c objPT: opp.Opportunity_Payment_Terms__r) {
    //                     if(opp.StageName == 'Defaulted' || Test.isRunningTest()) {
    //                         if(objPT.Status__c == 'Passed' || Test.isRunningTest()) {
    //                             sumPaymentTerms += objPT.Amount__c;
    //                         }
    //                     } else{
    //                         sumPaymentTerms += objPT.Amount__c;
    //                     }
    //                 }
    //                 opp.Revenue_Total__c = sumPaymentTerms;
    //             } else {
    //                 opp.Revenue_Total__c = sumPaymentTerms;
    //             }
    //             oppMapUpdate.put(opp.id,opp);
    //         }
            
    //         if(!system.isFuture()) {
    //             Boolean isClosedWon = false;
    //             //To make a callout and get the latest available points when discount line item is added.
    //             if((Test.isRunningTest()) || ((!QE_H4HRecursive4Callout.inFutureContext) && (opp.stageName == 'Closed Won' && oldObjectMap.get(opp.id).stageName != 'Closed Won' && oldObjectMap.get(opp.id).stageName != 'Under Review')  && opp.Event__r.program__r.name != null && opp.Event__r.program__r.name.contains('F1E') && opp.Reward_Points_Pending__c != null && isExecutedonce)) {
    //                 OpportunityLineItem discountOLI = new OpportunityLineItem();
    //                 for(OpportunityLineItem oli :opp.OpportunityLineItems ){
    //                     if(oli.ProductType__c == 'Reward Discount' || Test.isRunningTest()){
    //                         isDiscount = true;
    //                     }
    //                 }
    //                 if(isDiscount && opp.event__r.program__r.Name != null && opp.event__r.program__r.Name.contains('F1E')){
    //                     if(!Test.isRunningTest()) {
    //                         QE_H4HCalloutClass.getTokenSiteAdmin(opp.id, true);
    //                         isClosedWon = true;
    //                         isExecutedonce = false;
    //                     }
    //                 }
    //             }if((!QE_H4HRecursive4Callout.inFutureContext) && (oldObjectMap.get(opp.id).stageName != 'Under Review' && oldObjectMap.get(opp.id).stageName != 'Closed Won' && opp.stageName == 'Closed Won') && opp.Event__r.program__r.name != null && opp.Reward_Points_Pending__c != null && opp.Event__r.program__r.name.contains('F1E') && opp.Paid_in_full__C == true && isClosedwon == false && isExecutedonce) {
    //                 if(!Test.isRunningTest()) {
    //                     QE_H4HCalloutClass.getTokenSiteAdmin(opp.id, false);
    //                     isExecutedonce = false;
    //                 }
    //             }
    //             else if((!QE_H4HRecursive4Callout.inFutureContext) && oldObjectMap.get(opp.id).stageName != 'Under Review' &&  opp.stageName == 'Closed Won' && opp.Event__r.program__r.name != null && opp.Event__r.program__r.name.contains('F1E') && (oldObjectMap.get(opp.id).paid_in_full__c != true && opp.Paid_in_full__C == true) && isClosedwon == false && opp.Reward_Points_Pending__c != null && isExecutedonce) {
    //                 if(!Test.isRunningTest()) {
    //                     QE_H4HCalloutClass.getTokenSiteAdmin(opp.id, false);
    //                     isExecutedonce = false;
    //                 }
    //             }
    //         }
            
    //         if(!system.isFuture()) {
    //             // To create user in brandfuel if new email when opp event has brandfuel category id stored when closed won and paid in full.
    //             if(oldObjectMap.get(opp.Id).Paid_in_Full__c == false && oldObjectMap.get(opp.id).stageName != 'Under Review' && opp.StageName == 'Closed Won' && oppAttMap.isEmpty() &&  opp.Paid_in_Full__c == true && opp.Event__r.Brandfuel_Category_Id__c != null && oppAttendeeMap.size() > 0 && isExecutedonce){
    //                 QE_brandFuelDatainsert.checkUserExists(opp.Ship_To_Name__C,opp.Email__c, opp.Id,OpportunityLineItemIds,opp.Event__c,opp.Event__r.name,Date.valueOf(opp.Event__r.End_Date__c),Boolean.valueOf(opp.Paid_in_Full__c),optAttMap.get(opp.id),opp.Event__r.Brandfuel_End_Date__c);
    //                 isExecutedonce = false;
    //             }
    //             // Makes Call to Brandfuel only when condition met (Paid in full true and Closed won) for user creation.
    //             else if( oppAttMap.isEmpty() && opp.StageName == 'Closed Won' && oldObjectMap.get(opp.Id).StageName != 'Closed Won' && oldObjectMap.get(opp.id).stageName != 'Under Review' && opp.Paid_in_Full__c == true && opp.Event__r.Brandfuel_Category_Id__c != null && oppAttendeeMap.size() > 0 && isExecutedonce ){
    //                 QE_brandFuelDatainsert.checkUserExists(opp.Ship_To_Name__C,opp.Email__c, opp.Id,OpportunityLineItemIds,opp.Event__c,opp.Event__r.Name,Date.valueOf(opp.Event__r.End_Date__c),Boolean.valueOf(opp.Paid_in_Full__c),optAttMap.get(opp.id),opp.Event__r.Brandfuel_End_Date__c);
    //                 isExecutedonce = false;
    //             }
    //             // Updating Coupon for existing member in Brandfuel for same event.
    //             else if( opp.StageName == 'Closed Won' && opp.Paid_in_Full__c == true && oldObjectMap.get(opp.id).stageName != 'Under Review' && oldObjectMap.get(opp.Id).StageName != 'Closed Won' && !oppAttMap.isEmpty() && oppAttMap.containsKey(opp.Email__c) && oppAttMap.get(opp.Email__c)!= null && opp.Event__r.Brandfuel_Category_Id__c != null && !couponEvMap.isEmpty() && couponEvMap.get(opp.Email__c).contains(opp.Event__r.id) && isExecutedonce){
    //                 QE_brandFuelDatainsert.cuponDataSubMethod(opp.Id,OpportunityLineItemIds,couponIdMap.get(opp.Event__r.id),opp.Event__r.name,opp.Email__c,Date.valueOf(opp.Event__r.End_Date__c),oppAttUserkeyId,opp.Event__r.Brandfuel_End_Date__c);
    //                 isExecutedonce = false;
    //             }
    //             // Makes Call to Brandfuel only when condition met (Paid in full true and Closed won) for updating Coupon for existing user.
    //             else if( opp.StageName == 'Closed Won' && oldObjectMap.get(opp.id).stageName != 'Under Review' && opp.Paid_in_Full__c == true && oldObjectMap.get(opp.Id).Paid_in_Full__c == false && !oppAttMap.isEmpty() && oppAttMap.containsKey(opp.Email__c) && oppAttMap.get(opp.Email__c)!= null && opp.Event__r.Brandfuel_Category_Id__c != null && !couponEvMap.isEmpty() && couponEvMap.get(opp.Email__c).contains(opp.Event__r.id) && isExecutedonce){
    //                 QE_brandFuelDatainsert.cuponDataSubMethod(opp.Id,OpportunityLineItemIds,couponIdMap.get(opp.Event__r.id),opp.Event__r.name,opp.Email__c,Date.valueOf(opp.Event__r.End_Date__c),oppAttUserkeyId,opp.Event__r.Brandfuel_End_Date__c);
    //                 isExecutedonce = false;
    //             }
                
    //             //Creating Coupon for returing member in Brandfuel with different event.
    //             else if(opp.StageName == 'Closed Won' && opp.Paid_in_Full__c == true && oldObjectMap.get(opp.Id).Paid_in_Full__c == false && !oppAttMap.isEmpty() && oppAttMap.containsKey(opp.Email__c) && oppAttMap.get(opp.Email__c)!= null && opp.Event__r.Brandfuel_Category_Id__c != null && !couponEvMap.isEmpty() && !couponEvMap.get(opp.Email__c).contains(opp.Event__r.id) && isExecutedonce){
    //                 QE_brandFuelDatainsert.couponRecCreateOldEmail(opp.Id,OpportunityLineItemIds,opp.Event__c,opp.Event__r.name,opp.Email__c,Date.valueOf(opp.Event__r.End_Date__c),optAttMap.get(opp.id),oppAttUserkeyId,opp.Event__r.Brandfuel_End_Date__c);
    //                 isExecutedonce = false;
    //             }
                
    //             // Makes Call to Brandfuel only when condition met (Paid in full true and Closed won) for Creating Coupon for existing user.
    //             else if(opp.StageName == 'Closed Won' && oldObjectMap.get(opp.id).stageName != 'Under Review' && opp.Paid_in_Full__c == true && oldObjectMap.get(opp.Id).StageName != 'Closed Won' && !oppAttMap.isEmpty() && oppAttMap.containsKey(opp.Email__c) && oppAttMap.get(opp.Email__c)!= null && opp.Event__r.Brandfuel_Category_Id__c != null && !couponEvMap.isEmpty() && !couponEvMap.get(opp.Email__c).contains(opp.Event__r.id) && isExecutedonce){
    //                 QE_brandFuelDatainsert.couponRecCreateOldEmail(opp.Id,OpportunityLineItemIds,opp.Event__c,opp.Event__r.name,opp.Email__c,Date.valueOf(opp.Event__r.End_Date__c),optAttMap.get(opp.id),oppAttUserkeyId,opp.Event__r.Brandfuel_End_Date__c);
    //                 isExecutedonce = false;
    //             }
    //         }
            
    //     }
        
    //     //Added by Kinnari 09-06-2019 Start      
    //    // Check if oppt is being closed lost from closed won
    //    for(Opportunity opp: updatedObjects) {         
    //         if(((opp.StageName).equals('Request Cancelation')) && ((oldObjectMap.get(opp.Id).StageName).equals('Closed Won'))) {                                
    //             // check if current oppt has gone through approval process and is approved
    //             Approval.ProcessSubmitRequest opptApprovalRequest = new Approval.ProcessSubmitRequest();
    //             opptApprovalRequest.setObjectId(opp.id);
    //             opptApprovalRequest.setProcessDefinitionNameOrId('Opportunity_Canceled_From_Closed_Won');
    //             //opptApprovalRequest.setSkipEntryCriteria(true);
    //             Approval.ProcessResult result = Approval.process(opptApprovalRequest);  
    //         }    
    //    } 
    //    //Added by Kinnari 09-06-2019 Ended
        
    //     if(!oppMapUpdate.isEmpty()){
    //         isExecutedonce =false;
    //         update oppMapUpdate.values();
    //     }
        
    //     if(!oppProdListUpdate.isEmpty()) {
    //         isExecutedonce = false;
    //         update oppProdListUpdate.values();
    //     }
        
    //     //the Below Code is to update the Line Item on update of Payment Method
    //     Set<Id> oppIdSet = new Set<Id>();
    //     List<OpportunityLineItem> oppLineUpdate = new List<OpportunityLineItem>();
    //     List<Id> canceledOpps = new list<Id>();
    //     Set<Id> closedWonOpps = new Set<Id>();
    //     List<Opportunity_Payment_Terms__c> listOfPaymentTermsWithoutDueDate = new List<Opportunity_Payment_Terms__c>();
    //     for(Opportunity opp: updatedObjects){
    //         if(oldObjectMap.get(opp.Id).Payment_Method__c != opp.Payment_Method__c || Test.isRunningTest()) {
    //             oppIdSet.add(opp.Id);
    //         }
    //         // Oppt Closed Won
    //         if(opp.StageName == 'Closed Won' && oldObjectMap.get(opp.Id).StageName != 'Closed Won' && oldObjectMap.get(opp.Id).StageName != 'Under Review' || Test.isRunningTest()) {
    //             QE_GaCallout.SendTransaction(opp.Id, false);
    //             // Update first opportunity payment term's due date.
    //             // Find payment term with blank due date, and set its due date to today/oppt close date.
    //             for(Opportunity_Payment_Terms__c paymentTerm : updatedOpptsWithMoreData.get(opp.Id).Opportunity_Payment_Terms__r) {
    //                 if(paymentTerm.Payment_Due_Date__c == null || Test.isRunningTest()) {
    //                     paymentTerm.Payment_Due_Date__c = Date.today();
    //                     listOfPaymentTermsWithoutDueDate.add(paymentTerm);
    //                 }
    //             }
    //         }
    //         //// Added by Sowmya
    //         if(opp.StageName == 'Canceled' && oldObjectMap.get(opp.Id).StageName != 'Canceled') {
    //             canceledOpps.add(opp.Id);
    //         }
            
    //         if(opp.StageName == 'Closed Won' && (Label.Not_Assigned_UserId == opp.LastModifiedById || oldObjectMap.get(opp.Id).StageName != 'Closed Won')) { // && oldObjectMap.get(opp.Id).StageName != 'Closed Won'
    //             closedWonOpps.add(opp.Id);
    //         }
    //         if(opp.StageName == 'Closed Lost' && oldObjectMap.get(opp.Id).StageName == 'Closed Won') {
    //             QE_GaCallout.SendTransaction(opp.Id, true);
    //         }
    //     }
    //     //// Added by Sowmya
    //     List<Quote> quotesList = new List<Quote>();
    //     List<Id> quoteIds = new List<Id>();
    //     if(canceledOpps.size() > 0 || Test.isRunningTest()) {
    //         quotesList = [Select Id From quote Where Opportunityid in:canceledOpps];
    //         QE_H4HHotelProcess.h4hHoldCancellation(canceledOpps);
    //     }
    //     if(closedWonOpps.size() > 0 && QE_opportunityHandler.isH4HHoldExecutedonce && !system.isFuture()) {
    //         QE_opportunityHandler.isH4HHoldExecutedonce = false;
    //         QE_H4HHotelProcess.h4hCallProductSelection(closedWonOpps);
    //     }
    //     if(quotesList.size() > 0 || Test.isRunningTest()) {
    //         for(quote q : quotesList) {
    //             quoteIds.add(q.Id);
    //         }
    //     }
    //     if(quoteIds.size() > 0 || Test.isRunningTest()){
    //         QE_DSStatusHelper.VoidEnvelopeFromOpp(quoteIds);
    //     }
    //     //// Added by sowmya ends
    //     // Update Reseller's Commission Amount
    //     // Get Opportunity Events and Resellers
    //     Set<Id> OpptEventIds = new Set<Id>();
    //     Set<Id> OpptResellerIds = new Set<Id>();
    //     for(Opportunity opp: updatedOpptsWithMoreData.values()) {
    //         OpptEventIds.add(opp.Event__c);
    //         OpptResellerIds.add(opp.Account.Resellers_Name__c);
    //     }
    //     // Get reseller's commission by event.
    //     List<Reseller_Event__c> lstEventCommissions = new List<Reseller_Event__c>([
    //         Select Id, Commission_Percent__c, Event__c, Reseller__c
    //         From Reseller_Event__c
    //         Where Reseller__c in :OpptResellerIds And Event__c in : OpptEventIds
    //     ]);
    //     // Loop over oppts and calculate reseller's commission.
    //     List<Opportunity> opptsToUpdate = new List<Opportunity>();
    //     for(Opportunity opp: updatedOpptsWithMoreData.values()) {
    //         // Check if oppt is Closed Won and was not already Closed Won and is not an Online order
    //         if(opp.StageName == 'Closed Won' && oldObjectMap.get(opp.Id).StageName != 'Closed Won' && oldObjectMap.get(opp.Id).StageName != 'Under Review' && opp.Online_Order__c == false && Account.Resellers_Name__c != null || Test.isRunningTest()) {
    //             // Temp opportunity to update
    //             Opportunity tempOppt = new Opportunity();
    //             tempOppt.Id = opp.Id;
    //             // Find current reseller's commission by event
    //             for(Reseller_Event__c eventCommission : lstEventCommissions) {
    //                 // Checking if event commission has sam event and resellers ans oppt's.
    //                 if(eventCommission.Event__c == opp.Event__c && eventCommission.Reseller__c == opp.Account.Resellers_Name__c && eventCommission.Commission_Percent__c != null) {
    //                     tempOppt.Reseller_Commission_Amount__c = opp.Grand_Total__c * (eventCommission.Commission_Percent__c/100);
    //                 }
    //             }
    //             // If reseller does not have event specific commission, user Default commission.
    //             if(tempOppt.Reseller_Commission_Amount__c == null && opp.Account.Resellers_Name__c != null && opp.Account.Resellers_Name__r.Default_Commission__c != null){
    //                 tempOppt.Reseller_Commission_Amount__c = opp.Grand_Total__c * (opp.Account.Resellers_Name__r.Default_Commission__c/100);
    //             }
    //             if( (Test.isRunningTest()) || (opp.StageName == 'Closed Won' && oldObjectMap.get(opp.Id).StageName != 'Closed Won')) {
    //                 if(oldObjectMap.get(opp.Id).Primary_Attendee_Name__c == null) {
    //                     tempOppt.Primary_Attendee_Name__c = opp.Ship_To_Name__c;
    //                 }
    //             }
    //             opptsToUpdate.add(tempOppt);
    //         }
    //     }
        
    //     if(opptsToUpdate != null && opptsToUpdate.size() > 0) {
    //         update opptsToUpdate;
    //     }
    //     // Update oppt payment terms
    //     Set<Id> opptIdsForPaymentTermsUpdate = new Set<Id>();
    //     for(Opportunity opp: updatedObjects){
    //         if(oldObjectMap.get(opp.Id).Amount != opp.Amount && !opp.StageName.equals('Closed Won')) {
    //             opptIdsForPaymentTermsUpdate.add(opp.Id);
    //         }
    //     }
    //     if(opptIdsForPaymentTermsUpdate.size() > 0 || Test.isRunningTest()) {
    //         QE_OpportunityPaymentTermsHelper opptPaymentTermsHelper = new QE_OpportunityPaymentTermsHelper();
    //         opptPaymentTermsHelper.updateOpptPaymentTerms(opptIdsForPaymentTermsUpdate);
    //     }
    //     if(oppIdSet.size() > 0 || Test.isRunningTest()){
    //         // Update oppt line items
    //         for(OpportunityLineItem oppLine: [SELECT Id, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN: oppIdSet]){
    //             oppLineUpdate.add(oppLine);
    //         }
    //     }
    //     // Update payment terms with blank payment due date
    //     if((listOfPaymentTermsWithoutDueDate != null && listOfPaymentTermsWithoutDueDate.size() > 0) || Test.isRunningTest()) {
    //         update listOfPaymentTermsWithoutDueDate;
    //     }
    //     if((oppLineUpdate != null && oppLineUpdate.size() > 0) || Test.isRunningTest()) {
    //         update oppLineUpdate;
    //     }
    //     //Make sure first payment duexdate is after closed won date
    //     //update payment terms due date for below close date.
    //     List<Opportunity_Payment_Terms__c> updatePaymentTermsDueDate = new List<Opportunity_Payment_Terms__c>();
    //     for(Opportunity opp: updatedObjects){
    //         // Oppt Closed Won
    //         if((Test.isRunningTest()) || (opp.StageName == 'Closed Won' && oldObjectMap.get(opp.Id).StageName != 'Closed Won' && oldObjectMap.get(opp.Id).StageName != 'Canceled')) {
    //             // Update first opportunity payment term's due date.
    //             // Find payment term with due date below closed date, and set its due date to today/oppt close date. 
    //             for(Opportunity_Payment_Terms__c paymentTerm : updatedOpptsWithMoreData.get(opp.Id).Opportunity_Payment_Terms__r) {
    //                 if((paymentTerm.Payment_Due_Date__c != null && paymentTerm.Payment_Due_Date__c < Date.today()) || Test.isRunningTest()) {
    //                     paymentTerm.Payment_Due_Date__c = Date.today();
    //                     updatePaymentTermsDueDate.add(paymentTerm);
    //                 }
    //             }
    //         }
    //     }
    //     if(!updatePaymentTermsDueDate.isEmpty()) {
    //         update updatePaymentTermsDueDate;
    //     }
    
    }
    // After delete
    public void OnAfterDelete(List<Opportunity> oldList) {
        updateOpportunityContactRole(null,null,null);
        // Capture Deleted Opporunitites
        // List<QE_Deleted_Record__c> recordsBeingDeleted = new List<QE_Deleted_Record__c>();
        // for (Opportunity opt : oldList) {
        //     QE_Deleted_Record__c deletedRecord = new QE_Deleted_Record__c();
        //     deletedRecord.Name = opt.Name;
        //     deletedRecord.DeletedId__c = opt.Id;
        //     recordsBeingDeleted.add(deletedRecord);
        // }
        // try {
        //     insert recordsBeingDeleted;
        // } catch (Exception e) {
        //     System.debug('Exception: '+e);
        // }
    }
    public void updateOpportunityContactRole(List<Opportunity> newOpportunities, Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap) {
        sendEmailtoAccounting(null);
    //     Map<String, List<OpportunityContactRole>> OppwithPrimaryContactRole = new Map<String, List<OpportunityContactRole>>();
    //     Map<String, List<OpportunityContactRole>> OppwithCCRole = new Map<String, List<OpportunityContactRole>>();
        
    //     List<OpportunityContactRole> opptContactRolesToUpsert = new List<OpportunityContactRole>();
    //     List<OpportunityContactRole> opptContactRolesToDelete = new List<OpportunityContactRole>();
    //     List<Opportunity> lstOpprtunities = [SELECT Id, Primary_Contact__c, Communications_Contact__c, 
    //                                         (SELECT Id, OpportunityId, ContactId, Role  FROM OpportunityContactRoles) 
    //                                          FROM Opportunity WHERE Id IN : newOpportunities];
        
    //     for(Opportunity objOpp : lstOpprtunities) {
    //         for(OpportunityContactRole obj : objOpp.OpportunityContactRoles) {                
                
    //             if(obj.Role == 'Primary Contact') {
    //                 if(OppwithPrimaryContactRole == null || (OppwithPrimaryContactRole != null && !OppwithPrimaryContactRole.containskey(objOpp.Id))){
    //                     OppwithPrimaryContactRole.put(objOpp.Id, new List<OpportunityContactRole> {obj});
    //                 } else if(OppwithPrimaryContactRole != null && OppwithPrimaryContactRole.containskey(objOpp.Id)) {
    //                     OppwithPrimaryContactRole.get(objOpp.Id).add(obj);
    //                 }
    //             }
                
    //             if(obj.Role == 'Communications Contact') {
    //                 if(OppwithCCRole == null || (OppwithCCRole != null && !OppwithCCRole.containskey(objOpp.Id))){
    //                     OppwithCCRole.put(objOpp.Id, new List<OpportunityContactRole> {obj});
    //                 } else if(OppwithCCRole != null && OppwithCCRole.containskey(objOpp.Id)) {
    //                     OppwithCCRole.get(objOpp.Id).add(obj);
    //                 }
    //             }
    //         }
    //     }
    //     if(Test.isRunningTest()){
    //          for(Opportunity newOpp : newOpportunities) {
    //              if(oldMap.get(newOpp.Id).Communications_Contact__c != null){
    //                  newOpp.Communications_Contact__c = null;
    //              }
    //              IF(oldMap.get(newOpp.Id).Primary_Contact__c != null){
    //             //newOpp.Communications_Contact__c = null;
    //                 newOpp.Primary_Contact__c = null;
    //              }
    //          }
    //     }
    //     for(Opportunity newOpp : newOpportunities) {
            
    //         System.debug('oldMap.get(newOpp.Id).Primary_Contact__c :'+ oldMap.get(newOpp.Id).Primary_Contact__c);
    //         System.debug('newOpp.Primary_Contact__c :'+ newOpp.Primary_Contact__c);
    //         /**********Primary Contact**********/
    //         if (oldMap.get(newOpp.Id).Primary_Contact__c == null && newOpp.Primary_Contact__c != null) {
    //             OpportunityContactRole PrimaryAttendeeContactRole = new OpportunityContactRole();
    //             PrimaryAttendeeContactRole.OpportunityId = newOpp.Id;
    //             PrimaryAttendeeContactRole.ContactId = newOpp.Primary_Contact__c;
    //             PrimaryAttendeeContactRole.IsPrimary = true;
    //             PrimaryAttendeeContactRole.Role = 'Primary Contact';
    //             opptContactRolesToUpsert.add(PrimaryAttendeeContactRole);
    //         } else if (oldMap.get(newOpp.Id).Primary_Contact__c != null && newOpp.Primary_Contact__c == null) {
    //             if(OppwithPrimaryContactRole != null && OppwithPrimaryContactRole.containsKey(newOpp.Id)){
    //                 opptContactRolesToDelete.addAll(OppwithPrimaryContactRole.get(newOpp.Id));
    //             }
    //         } else if (newOpp.Primary_Contact__c != oldMap.get(newOpp.Id).Primary_Contact__c) {
    //             if(OppwithPrimaryContactRole != null && OppwithPrimaryContactRole.containsKey(newOpp.Id)) {
    //                 for(OpportunityContactRole ocr: OppwithPrimaryContactRole.get(newOpp.Id)) {
    //                     OpportunityContactRole PrimaryAttendeeContactRole = ocr;
    //                     if(oldMap.get(newOpp.Id).Primary_Contact__c == PrimaryAttendeeContactRole.ContactId) {
    //                         PrimaryAttendeeContactRole.ContactId = newOpp.Primary_Contact__c;
    //                         opptContactRolesToUpsert.add(PrimaryAttendeeContactRole);
    //                     }
    //                 }
    //             }
    //         }
            
    //         /**********Communications Contact**********/
    //         if (oldMap.get(newOpp.Id).Communications_Contact__c == null && newOpp.Communications_Contact__c != null) {
    //             OpportunityContactRole PrimaryAttendeeContactRole = new OpportunityContactRole();
    //             PrimaryAttendeeContactRole.OpportunityId = newOpp.Id;
    //             PrimaryAttendeeContactRole.ContactId = newOpp.Communications_Contact__c;
    //             PrimaryAttendeeContactRole.Role = 'Communications Contact';
    //             opptContactRolesToUpsert.add(PrimaryAttendeeContactRole);
    //         } else if (oldMap.get(newOpp.Id).Communications_Contact__c != null && newOpp.Communications_Contact__c == null) {
    //             if(OppwithCCRole != null && OppwithCCRole.containsKey(newOpp.Id)){
    //                 opptContactRolesToDelete.addAll(OppwithCCRole.get(newOpp.Id));
    //             }
    //         } else if (newOpp.Communications_Contact__c != oldMap.get(newOpp.Id).Communications_Contact__c) {
    //             if(OppwithCCRole != null && OppwithCCRole.containsKey(newOpp.Id)) {
    //                 for(OpportunityContactRole ocr: OppwithCCRole.get(newOpp.Id)) {
    //                     OpportunityContactRole CommunicationContactRole = ocr;
    //                     if(oldMap.get(newOpp.Id).Communications_Contact__c  == CommunicationContactRole.ContactId) {
    //                         CommunicationContactRole.ContactId = newOpp.Communications_Contact__c;
    //                         opptContactRolesToUpsert.add(CommunicationContactRole);
    //                     }
    //                 }
    //             }
    //         }
    //     }
        
    //     if(opptContactRolesToUpsert.size() > 0){
    //         upsert opptContactRolesToUpsert;
    //     }
    //     if(opptContactRolesToDelete.size() > 0){
    //         delete opptContactRolesToDelete;
    //     }
    }
    
     public void sendEmailtoAccounting(set<Id> seteventId){
    //     List<QE360_Event__c> eve = [Select id,Name,Xero_Account_Code__c,Xero_Event_Name__c,Xero_Item_Id__c from QE360_Event__c where id in: seteventId and (Xero_Account_Code__c = null or Xero_Event_Name__c = null or Xero_Item_Id__c = null) limit 1];
    //     if(!eve.isempty()){
    //         Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
    //         for(QE360_Event__c event: eve){         
    //             Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();      
    //             message.setToAddresses(new string[]{'accounts@grandprixevents.com'}); //acc@grand1prixevents.com
    //             message.subject = 'SalesForce Event Missing Xero Code';
    //             String str = 'The event linked below is missing the Xero code. Xero invoices will not be generated until the event is updated with the Xero Account Code, Xero Event Name and Xero Item Id. <br/>';
    //             str += '<a href = "'+system.label.Current_Org_URL+'/'+event.id+'/view">'+event.name+'</a>';
    //             message.setHtmlBody(str);
    //             messages.add(message);          
    //         }
    //         Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    //     }
    }
    
}
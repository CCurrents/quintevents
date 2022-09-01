/**
 * @File Name          : QE_Xero_FutureCallout.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 1:03:44 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class QE_Xero_FutureCallout{
    // public enum SortOrder {ASCENDING, DESCENDING}    
    // public static string contactBody{get;set;}
    //public static string responseBody{get;set;}
    //ublic static string xeroInvoiceId{get;set;}
    //public static string responseInvoiceBody{get;set;}
    //public static string invoiceBodys{get;set;}
    // public static string responsePostInvoiceBody{get;set;}  
    //public static string PaymentBodys{get;set;}
    //public static string invoiceResponseBody{get;set;}
    //public static string invoicePostBody{get;set;}
    
  
    // public static Xero_Settings__c xeroSettings {

    //     get {

    //         if (xeroSettings == null) {
                
    //             xeroSettings = Xero_Settings__c.getOrgDefaults();
    //         }
    //         return xeroSettings;
    //     }
    //     set;
    // }
    
    /***********************************************************************************
    if gpe event is true and stage is closed won then it will call this future method for call out, 
    createContactJson is call when opportunity is created and callout with xero and store xero contact id to the contact and status with 
    *************************************************************************************/
    // @future (callout=true)
    public static void createContactJson(Id sObjectId){
        createContact(null);
        createInvoice(null);
        createMultipleInvoicJosn(null, null, null, null, null);
        EmailInvoice(null);
    //     try{
    //         List<Opportunity> opportunityList = [Select Id,Primary_Contact__r.Name,Primary_Contact__r.FirstName,Primary_Contact__r.LastName,
    //                                             Primary_Contact__r.Phone,Primary_Contact__r.Email,Primary_Contact__r.MailingCity,Primary_Contact__r.MailingState,
    //                                             Primary_Contact__r.MailingCountry,Primary_Contact__r.MailingPostalCode,Primary_Contact__r.MailingStreet,
    //                                             Primary_Contact__c,Event__r.GPE_Event__c,StageName,(Select Id from Opportunity_Payment_Terms__r) From Opportunity where Id=:sObjectId];

    //         if(!opportunityList.isEmpty()){
    //             JSONGenerator gen = JSON.createGenerator(true);
    //             gen.writeStartObject();
    //             gen.writeFieldName('Contacts');
    //             gen.writeStartArray();
    //             gen.writeStartObject();
    //             gen.writeStringField('Name',(opportunityList[0].Primary_Contact__r.Name != null ? opportunityList[0].Primary_Contact__r.Name : ''));
    //             gen.writeStringField('FirstName',(opportunityList[0].Primary_Contact__r.FirstName!= null ? opportunityList[0].Primary_Contact__r.FirstName : ''));
    //             gen.writeStringField('LastName',(opportunityList[0].Primary_Contact__r.LastName!= null ? opportunityList[0].Primary_Contact__r.LastName : ''));
    //             gen.writeStringField('EmailAddress',(opportunityList[0].Primary_Contact__r.Email != null ? opportunityList[0].Primary_Contact__r.Email : ''));

    //                 gen.writeFieldName('Addresses');
    //                 gen.writeStartArray();

    //                 gen.writeStartObject();
    //                 gen.writeStringField('AddressType','POBOX');
    //                 gen.writeStringField('AddressLine1',(opportunityList[0].Primary_Contact__r.MailingStreet != null ? opportunityList[0].Primary_Contact__r.MailingStreet : ''));
    //                 gen.writeStringField('City',(opportunityList[0].Primary_Contact__r.MailingCity != null ? opportunityList[0].Primary_Contact__r.MailingCity : ''));
    //                 gen.writeStringField('PostalCode',(opportunityList[0].Primary_Contact__r.MailingPostalCode != null ? opportunityList[0].Primary_Contact__r.MailingPostalCode: ''));
    //                 gen.writeEndObject();

    //                 gen.writeEndArray(); 
                    
    //                 gen.writeFieldName('Phones');
    //                 gen.writeStartArray(); 

    //                 gen.writeStartObject();
    //                 gen.writeStringField('PhoneType','DEFAULT');
    //                 gen.writeStringField('PhoneNumber',(opportunityList[0].Primary_Contact__r.Phone != null ? opportunityList[0].Primary_Contact__r.Phone: ''));
    //                 gen.writeEndObject();

    //                 gen.writeEndArray();
                    
    //             gen.writeEndObject();
    //             gen.writeEndArray(); 
    //             gen.writeEndObject();
    //             String str = gen.getAsString(); 
    //             System.debug('str -->'+str );                           
    //             XeroContact xeroContact = createContact(str);
                
    //             System.debug('xeroContact -->'+xeroContact); 
    //             Contact contact = new Contact();
    //             contact.Id = opportunityList[0].Primary_Contact__c;
    //             contact.Xero_Contact_ID__c = xeroContact.contactID;

    //             opportunityList[0].Xero_Contact_Status__c = xeroContact.xeroContactStatus;
    //             opportunityList[0].Xero_Failure_Reason__c = xeroContact.xeroContactFailureReason;
                
    //             Set<Id> OppPaymentTermList = new Set<Id>();
    //             for(Opportunity_Payment_Terms__c optList : opportunityList[0].Opportunity_Payment_Terms__r){
    //                 OppPaymentTermList.add(optList.Id);
    //             }
    //             system.debug('#####opportunityList[0].Event__r.GPE_Event__c=='+opportunityList[0].Event__r.GPE_Event__c);
    //             system.debug('#####opportunityList[0].StageName=='+opportunityList[0].StageName);
    //             if(opportunityList[0].Event__r.GPE_Event__c == true && opportunityList[0].StageName == 'Closed Won'){                      
    //                 createMultipleInvoicJosn(OppPaymentTermList, contact.Xero_Contact_ID__c, sObjectId,contact,opportunityList[0]);
    //             }

    //             //update contact;
    //             //update opportunityList[0];
    //         }
    //    }
    //    catch(Exception e){
    //        System.debug(e.getMessage()+'-->'+e.getLineNumber());
    //    }
    }

    /*******************************************************************************
    this is method used to create contact call out with the xero and have handel all the callouts 
    and its called from createContactJson future method
    ********************************************************************************/

    public static XeroContact createContact(String contactBody) {   
        // The created contact to return
        XeroContact createdContact;
        // // Execute the callout to the Contacts resource
        // HttpResponse response = XeroCalloutUtility.executeCallout('POST', 'Contacts', contactBody);
        // system.debug('#####response =='+response );
        // // If successful response
        // if (response.getStatusCode() == 200) {
        //     // Use the parser to convert the response into Xero objects
        //     createdContact = XeroCalloutResponseParser.parseContacts(response.getBody())[0];
        //     createdContact.xeroContactStatus = 'Success';
        //     system.debug('#####createdContact=='+createdContact);
        // }
        // else {
        //     // Raise error
        //     createdContact = new XeroContact();
        //     createdContact.xeroContactStatus = 'Failed';
        //     createdContact.xeroContactFailureReason = response.getBody();
        //     //throw new XeroAccountingApiException(response.getStatusCode() + ': ' + response.getBody());
        //     system.debug('#####createdContact.xeroContactStatus=='+createdContact.xeroContactStatus);
        // }
        return createdContact;
    }

    /*******************************************************************************
    this is method used to create multiple invoice using callout with the xero
    and its called from createContactJson future method
    ********************************************************************************/
    //@future (callout=true)
    public static void createMultipleInvoicJosn(Set<Id> setId, String contactID, Id oppId, Contact con,Opportunity Opp){//createInvoiceJson(Id sObjectId){
    //     try{
    //         List<Opportunity> oppList = [Select Id,Xero_Reference_No__c,GPE_Online_Order__c,Event__r.Xero_Item_Id__c,Event__r.Apply_20_VAT_Tax__c,Event__r.Xero_Event_Name__c,Event__r.Xero_Account_Code__c,(Select Id,Opportunity__r.name,Opportunity__r.GPE_Online_Order__c,Xero_Invoice_ID__c,
    //         Opportunity__r.Primary_Contact__r.Xero_Contact_ID__c,Status__c,CreatedDate,Payment_Due_Date__c,Amount__c,Xero_Payment_Status__c,
    //         Xero_Failure_Reason__c,Opportunity_Currency__c,Opportunity__c,opportunity__r.Event__r.Xero_Account_Code__c From Opportunity_Payment_Terms__r where Id IN: setId),(Select Id,Quantity,Description,UnitPrice,Product2.Name from OpportunityLineItems) from Opportunity where Id =: oppId];
    //         system.debug('#####oppList =='+oppList );
    //         If(!oppList.isEmpty()){
    //             List<Opportunity_Payment_Terms__c> opportunityPaymentList = oppList[0].Opportunity_Payment_Terms__r;
    //             List<OpportunityLineItem> oppLineItem = oppList[0].OpportunityLineItems;
    //             system.debug('#####opportunityPaymentList =='+opportunityPaymentList );
    //             system.debug('#####oppLineItem =='+oppLineItem );                                                             
    //             if(!opportunityPaymentList.isEmpty()){
    //                 JSONGenerator gen = JSON.createGenerator(true);
    //                 gen.writeStartObject(); 
    //                     gen.writeFieldName('Invoices');                
    //                     gen.writeStartArray(); 
    //                     for(Opportunity_Payment_Terms__c oppLine : opportunityPaymentList){
    //                         gen.writeStartObject();
    //                             gen.writeStringField('Type','ACCREC');
    //                             gen.writeStringField('CurrencyCode', oppLine.Opportunity_Currency__c);
    //                             gen.writeFieldName('Contact');
    //                             gen.writeStartObject();
    //                                 gen.writeStringField('ContactID',(oppLine.Opportunity__r.Primary_Contact__r.Xero_Contact_ID__c != null ? oppLine.Opportunity__r.Primary_Contact__r.Xero_Contact_ID__c : contactID));
    //                             gen.writeEndObject();
    //                             gen.writeStringField('Status','AUTHORISED');
    //                             gen.writeStringField('BrandingThemeID', xeroSettings.Branding_ThemeID__c);
    //                             gen.writeStringField('Reference' , (oppList[0].Xero_Reference_No__c != null ? oppList[0].Xero_Reference_No__c : ''));
    //                             gen.writeDateTimeField('Date',oppLine.CreatedDate);
    //                             gen.writeDateField('DueDate',oppLine.Payment_Due_Date__c);
    //                             gen.writeFieldName('LineItems');
    //                                 gen.writeStartArray(); 
    //                                 if(oppList[0].Event__r.Xero_Item_Id__c != null){
    //                                     gen.writeStartObject();                                    
    //                                         gen.writeStringField('ItemCode', oppList[0].Event__r.Xero_Item_Id__c); 
    //                                         gen.writeStringField('UnitAmount', ''); 
    //                                         gen.writeStringField('Quantity', '');                                
    //                                     gen.writeEndObject();
    //                                 }
    //                                 for(integer i=0 ; i<oppLineItem.size() ; i++){                                        
    //                                     gen.writeStartObject();
    //                                         if(oppLineItem[i].Product2.Name != 'Shipping and Handling'){
    //                                             gen.writeStringField('Description', oppLineItem[i].Description != null ? oppLineItem[i].Description : oppLineItem[i].Product2.Name);
    //                                             gen.writeNumberField('Quantity',oppLineItem[i].Quantity != null ? oppLineItem[i].Quantity :0);
    //                                             Decimal unitPrices = 0;
    //                                             Decimal netPrice = 0;
    //                                             unitPrices = oppLineItem[i].UnitPrice / 1.20;
    //                                             netPrice = oppLineItem[i].UnitPrice - unitPrices;
    //                                             gen.writeNumberField('UnitAmount', (oppList[0].Event__r.Apply_20_VAT_Tax__c == true ? oppLineItem[i].UnitPrice - netPrice : oppLineItem[i].UnitPrice));
    //                                             if(oppList[0].Event__r.Xero_Account_Code__c != null){
    //                                                 gen.writeNumberField('AccountCode',Integer.valueof(oppList[0].Event__r.Xero_Account_Code__c));
    //                                             }
    //                                             if(oppList[0].Event__r.Apply_20_VAT_Tax__c == true){
    //                                                 gen.writeStringField('TaxType', xeroSettings.TaxType__c);
    //                                             }
    //                                             if(oppList[0].Event__r.Xero_Event_Name__c != null){
    //                                                 gen.writeFieldName('Tracking');
    //                                                     gen.writeStartArray(); 
    //                                                         gen.writeStartObject();
    //                                                             gen.writeStringField('TrackingCategoryID', xeroSettings.Tracking_Category_Id__c);
    //                                                             gen.writeStringField('Name', xeroSettings.CategoryName__c);
    //                                                             gen.writeStringField('Option', (oppList[0].Event__r.Xero_Event_Name__c));        
    //                                                         gen.writeEndObject();
    //                                                     gen.writeEndArray();
    //                                             }
    //                                         }else{
    //                                             gen.writeStringField('Description', 'Combined Service Fee');
    //                                             gen.writeNumberField('Quantity',oppLineItem[i].Quantity != null ? oppLineItem[i].Quantity :0);
    //                                             gen.writeNumberField('UnitAmount', (oppLineItem[i].UnitPrice != null ? oppLineItem[i].UnitPrice : 0));
    //                                             if(oppList[0].Event__r.Xero_Account_Code__c != null){
    //                                                 gen.writeNumberField('AccountCode',Integer.valueof(oppList[0].Event__r.Xero_Account_Code__c));
    //                                             }
    //                                             if(oppList[0].Event__r.Xero_Event_Name__c != null){
    //                                                 gen.writeFieldName('Tracking');
    //                                                     gen.writeStartArray(); 
    //                                                         gen.writeStartObject();
    //                                                             gen.writeStringField('TrackingCategoryID', xeroSettings.Tracking_Category_Id__c);
    //                                                             gen.writeStringField('Name', xeroSettings.CategoryName__c);
    //                                                             gen.writeStringField('Option', ( oppList[0].Event__r.Xero_Event_Name__c != null ? oppList[0].Event__r.Xero_Event_Name__c : ''));        
    //                                                         gen.writeEndObject();
    //                                                     gen.writeEndArray();
    //                                             }
    //                                         }
    //                                     gen.writeEndObject();
    //                                 }                                    
    //                                 gen.writeEndArray();
    //                         gen.writeEndObject();
    //                     }
    //                     gen.writeEndArray();
    //                 gen.writeEndObject();

    //                 String str = gen.getAsString();
    //                 System.debug('str-->'+str);
                    
    //                 List<XeroInvoice> xeroInvoiceList;// = createInvoice(str);
    //                 if(!Test.isRunningTest()){
	// 			      xeroInvoiceList = createInvoice(str);                  
    //                 }else{
    //                     xeroInvoiceList =new  List<XeroInvoice>();
    //                     XeroInvoice xeros = new XeroInvoice();
    //                     xeros.InvoiceID = 'test';
    //                     xeroInvoiceList.add(xeros);
    //                 }
    //                 Opportunity oppObj = new Opportunity();
    //                 oppObj = Opp;
    //                 list<Opportunity_Payment_Terms__c> updateOppPayTermList = new list<Opportunity_Payment_Terms__c>();
    //                 for(integer i=0; i<xeroInvoiceList.size(); i++){
    //                     opportunityPaymentList[i].Xero_Invoice_ID__c = xeroInvoiceList[i].InvoiceID;                   
                        
    //                     oppObj.Id = opportunityPaymentList[i].Opportunity__c;
    //                     oppObj.Xero_Invoice_Status__c = xeroInvoiceList[i].xeroInvoiceStatus;
                        
    //                     oppObj.Xero_Failure_Reason__c = xeroInvoiceList[i].xeroInvoiceFailureReason;

    //                     if(opportunityPaymentList[i].Xero_Invoice_ID__c != null){ //opportunityPaymentList[0].Status__c == 'Passed' &&
    //                         System.debug('in if');
    //                         if(oppList[0].GPE_Online_Order__c == false){
    //                             EmailInvoice(opportunityPaymentList[i].Xero_Invoice_ID__c);
    //                         }
    //                         else if(oppList[0].GPE_Online_Order__c == true){
    //                             Opportunity_Payment_Terms__c updateOppPayTermObj = createPaymentCallOutAfterInvoiceCreate(opportunityPaymentList[i]);
    //                             updateOppPayTermList.add(updateOppPayTermObj);
    //                         }
    //                     }
    //                 }
    //                 if(con.id != null){
    //                     update con;
    //                 }
    //                 if(updateOppPayTermList.size()>0){
    //                     update updateOppPayTermList;
    //                 }
    //                 if(oppObj.Id != null){
    //                     update oppObj;
    //                 }
    //                 if(opportunityPaymentList.size()>0){
    //                     update opportunityPaymentList;
    //                 }
    //             }
    //         }
    //    }
    //    catch(Exception e){
    //        System.debug(e.getMessage()+'-->'+e.getLineNumber());
    //    }
    }

    
    /*******************************************************************************
    this is method used to handel callout with the xero
    and its called from createMultipleInvoicJosnFromTrigger,createMultipleInvoicJosn
    ********************************************************************************/
    public static List<XeroInvoice> createInvoice(String invoiceBody) {
        // The created invoice to return
        List<XeroInvoice> createdInvoice;
        // Execute the callout to the Contacts GET resource
        // HttpResponse response = XeroCalloutUtility.executeCallout('POST', 'Invoices', invoiceBody);
        // system.debug('###response=='+response.getBody());
        // // If successful response
        // if (response.getStatusCode() == 200) {
        //     // Use the parser to convert the response into Xero objects
        //     createdInvoice = XeroCalloutResponseParser.parseInvoices(response.getBody());
        //     for(integer i = 0 ; i < createdInvoice.size() ; i++){
        //         createdInvoice[i].xeroInvoiceStatus = 'Success';
        //     }
        // }
        // else {
        //     // Raise error
        //     createdInvoice = new List<XeroInvoice>();
        //     for(integer i = 0 ; i < createdInvoice.size() ; i++ ){
        //         createdInvoice[i].xeroInvoiceStatus = 'Failed';
        //         JSONParser parser = JSON.createParser(response.getBody());
        //         while (parser.nextToken() != null) {
        //             if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
        //                 XeroPaymentError inv = (XeroPaymentError)parser.readValueAs(XeroPaymentError.class);
        //                 createdInvoice[0].xeroInvoiceFailureReason = inv.Type; //System.debug(inv);
        //             }
        //         }
        //     }
        //     //throw new XeroAccountingApiException(response.getStatusCode() + ': ' + response.getBody());
        // }
        // responsePostInvoiceBody = string.valueof(createdInvoice);
        // System.debug('createdInvoice-->'+createdInvoice);
        return createdInvoice;
    }
    
     public static Void EmailInvoice(String invoiceId) {
         createPaymentJson(null);
        //  system.debug('###EmailInvoice');
        // // The created invoice to return
        // List<XeroInvoice> createdInvoice;
        // // Execute the callout to the Contacts GET resource
        // HttpResponse response = XeroCalloutUtility.executeCallout('POST', 'Invoices/'+invoiceId+'/Email','');
        // system.debug('###response=='+response.getBody());
        
    }

    /*******************************************************************************
    this is method used to handel callout of payment with the xero and store response in payment term object
    its called from createMultipleInvoicJosn method after finish creating invoicing in xero
    ********************************************************************************/
    // public static Opportunity_Payment_Terms__c createPaymentCallOutAfterInvoiceCreate(Opportunity_Payment_Terms__c opportunityPayment){
    //     try{
    //         //List<Opportunity_Payment_Terms__c> opportunityList = [Select Id,Opportunity__r.name,Xero_Invoice_ID__c,CreatedDate,Payment_Due_Date__c,Amount__c From
    //         //                                                    Opportunity_Payment_Terms__c where Id=:sObjectId];
    //         if(opportunityPayment != null || Test.isRunningTest()){ // && opportunityPayment.Opportunity__r.GPE_Online_Order__c == true

    //             JSONGenerator gen = JSON.createGenerator(true);
    //             gen.writeStartObject(); 
    //             gen.writeFieldName('Payments');
    //                 gen.writeStartObject();
    //                     gen.writeFieldName('Invoice');
    //                         gen.writeStartObject();
    //                             gen.writeStringField('InvoiceID',(opportunityPayment.Xero_Invoice_ID__c != null ? opportunityPayment.Xero_Invoice_ID__c : ''));
    //                         gen.writeEndObject();
    //                     gen.writeFieldName('Account');
    //                         gen.writeStartObject();
    //                             gen.writeStringField('Code',opportunityPayment.opportunity__r.Event__r.Xero_Account_Code__c);
    //                         gen.writeEndObject();
    //                     if(!Test.isRunningTest()){
    //                         gen.writeDateTimeField('Date',opportunityPayment.CreatedDate);
    //                     }else{
    //                         gen.writeDateTimeField('Date',System.today());
    //                     }
    //                     gen.writeNumberField('Amount',(opportunityPayment.Amount__c != null ? opportunityPayment.Amount__c : 0));
    //                 gen.writeEndObject();
    //             gen.writeEndObject();
    
    //             String str = gen.getAsString();
    //             str = str.replace('"Payments" : {','');
    //             str = str.removeEnd('}');
    //             System.debug('str-->'+str);
    //             List<XeroPayment> XeroPayment = createPayment(str);
    //             for(integer i = 0 ; i < XeroPayment.size() ; i++ ){
    //                 opportunityPayment.Xero_Payment_Status__c = XeroPayment[i].xeroPaymentStatus;
    //                 opportunityPayment.Xero_Failure_Reason__c = XeroPayment[i].xeroPaymentFailureReason;
    //             }
    //             //update opportunityPayment;
    //         }
    //    }
    //    catch(Exception e){
    //        System.debug(e.getMessage()+'-->'+e.getLineNumber());
    //    }
    //    return opportunityPayment;
    // }

    /*******************************************************************************
    this method called when Xero_Invoice_ID__c is not null and status__c is Passed and related opportunity field gpe_online_order is true
    this is method used to handel callout of payment with the xero and store response in payment term object
    its called from QE_OpportunityPaymentTermTrigger on update of payment term
    ********************************************************************************/ 
    // @future (callout=true)
    public static void createPaymentJson(Id sObjectId){
        createPayment(null);
    //         List<Opportunity_Payment_Terms__c> opportunityPaymentList = [Select Id,Opportunity__r.name,Opportunity__r.GPE_Online_Order__c,Xero_Invoice_ID__c,
    //                     CreatedDate,Payment_Due_Date__c,Amount__c,Xero_Payment_Status__c From Opportunity_Payment_Terms__c where Id=:sObjectId AND
    //                      Opportunity__r.GPE_Online_Order__c =: true];
    //     try{
    //         if(!opportunityPaymentList.isEmpty()){
    //             JSONGenerator gen = JSON.createGenerator(true);
    //             gen.writeStartObject(); 
    //             gen.writeFieldName('Payments');
    //                 gen.writeStartObject();
    //                     gen.writeFieldName('Invoice');
    //                         gen.writeStartObject();
    //                             gen.writeStringField('InvoiceID',(opportunityPaymentList[0].Xero_Invoice_ID__c != null ? opportunityPaymentList[0].Xero_Invoice_ID__c : ''));
    //                         gen.writeEndObject();
    //                     gen.writeFieldName('Account');
    //                         gen.writeStartObject();
    //                             gen.writeStringField('Code','200');
    //                         gen.writeEndObject();
    //                     gen.writeDateTimeField('Date',opportunityPaymentList[0].CreatedDate);
    //                     gen.writeNumberField('Amount',(opportunityPaymentList[0].Amount__c != null ? opportunityPaymentList[0].Amount__c : 0));
    //                 gen.writeEndObject();
    //             gen.writeEndObject();
    
    //             String str = gen.getAsString();
    //             str = str.replace('"Payments" : {','');
    //             str = str.removeEnd('}');

    //             List<XeroPayment> xeroInvoice = createPayment(str);
    //             for(integer i = 0 ; i < xeroInvoice.size() ; i++ ){
    //                 opportunityPaymentList[i].Xero_Payment_Status__c = xeroInvoice[i].xeroPaymentStatus;
    //                 opportunityPaymentList[i].Xero_Failure_Reason__c = xeroInvoice[i].xeroPaymentFailureReason;
    //             }
    //             update opportunityPaymentList;
    //         }
    //    }
    //    catch(Exception e){
    //         System.debug(e.getMessage()+'-->'+e.getLineNumber());
    //    }
    }
   
    /*******************************************************************************
    this is method used to handel payment callout with the xero
    and its called from createPaymentCallOutAfterInvoiceCreate,createPaymentJson methods
    ********************************************************************************/
    public static List<XeroPayment> createPayment (String paymentBody) {
        // The created invoice to return
        List<XeroPayment> createPayment;

        // Execute the callout to the Contacts GET resource
        // HttpResponse response = XeroCalloutUtility.executeCallout('POST', 'Payments', paymentBody);
        // system.debug('###response=='+response.getBody());
        // // If successful response
        // if (response.getStatusCode() == 200) {
        //     // Use the parser to convert the response into Xero objects       
        //     createPayment = XeroCalloutResponseParser.parsePayment(response.getBody());

        //     for(integer i = 0 ; i < createPayment.size() ; i++){
        //         createPayment[i].xeroPaymentStatus = 'Sucesss';
        //     }
        // }
        // else {
        //     // Raise error
        //     createPayment = new List<XeroPayment>();
        //     for(integer i = 0 ; i < createPayment.size() ; i++ ){
        //         createPayment[i].xeroPaymentStatus = 'Failed';
        //         JSONParser parser = JSON.createParser(response.getBody());
        //         while (parser.nextToken() != null) {
        //             if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
        //                 XeroPaymentError inv = (XeroPaymentError)parser.readValueAs(XeroPaymentError.class);
        //                 createPayment[i].xeroPaymentFailureReason = inv.Type; //System.debug(inv);
        //             }
        //         }
        //     }
        //     //throw new XeroAccountingApiException(response.getStatusCode() + ': ' + response.getBody());
        // }
        // responsePostInvoiceBody = string.valueof(createPayment);
        return createPayment;
    }

    // public class XeroPaymentError{
    //     public String Type{get; set;}
    //     //public String Message{get; set;}
    //     //public ValidationErrors[] ValidationErrors{get; set;}
    // }
    // public class XeroAccountingApiException extends Exception {}
    
}
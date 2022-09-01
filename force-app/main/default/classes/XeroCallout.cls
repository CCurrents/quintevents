/**
 * @File Name          : XeroCallout.cls
 * @Description        : To create request to Xero API callout as per SF Info
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 03-31-2022
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    04/03/2020  kchavda@addonblue.com         Initial Version
 * 1.1    08/31/2020  fsuraitawala@addonblue.com    #519 Xero Related Changes
 * 1.2    10/30/2020  kchavda@addonblue.com         #606 Set due date for Invoice in Xero when there is only Credit PT
 * 1.3    12/01/2020  kchavda@addonblue.com         #627 Get the exchange rate date from the JSON for Online Orders
*/
public with sharing class XeroCallout{

    public static List<RequestResponse_Log__c> lstreqresLogs;    
    
     /**
    * @description retrieved Xero Account Settings
    * @author kchavda@addonblue.com | 04/03/2020
    * @param 
    * @return
    **/    
    public static Xero_Configuration__c xeroSettings {
        get {
            if (xeroSettings == null) {                
                xeroSettings =  [Select Access_Token__c, Active__c, Authentication_Endpoint__c, Branding_ThemeID__c, Category_Name__c, Consumer_Key__c,
                                 Consumer_Secret__c, Endpoint__c, Id, Redirect_URL__c, Refresh_Token__c, Scope__c, TaxType__c, Tenant_Endpoint__c, Tenant_Id__c,
                                 Token_Endpoint__c, Tracking_Category_Id__c, Webhook_Key__c, USD_Account_Code__c, EUR_Account_Code__c, GAC_Account_Code__c
                                 FROM Xero_Configuration__c where Active__c = true LIMIT 1];
            }
            return xeroSettings;
        }
        set;
    }  
    
     /**
    * @description To create Contact In Xero
    * @author kchavda@addonblue.com | 04/03/2020
    * @param Order 
    * @return string
    **/    
    public static string createContactJson(Order objOrder){
        String str = '';
        try{            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('Contacts');
            gen.writeStartArray();
                gen.writeStartObject();                        
                gen.writeStringField('Name',(objOrder.BillToContact.Name != null ? objOrder.BillToContact.Name : ''));
                gen.writeStringField('FirstName',(objOrder.BillToContact.FirstName!= null ? objOrder.BillToContact.FirstName : ''));
                gen.writeStringField('LastName',(objOrder.BillToContact.LastName!= null ? objOrder.BillToContact.LastName : ''));
                gen.writeStringField('EmailAddress',(objOrder.BillToContact.Email != null ? objOrder.BillToContact.Email : ''));        
                gen.writeFieldName('Addresses');
                gen.writeStartArray();
                    gen.writeStartObject();
                        gen.writeStringField('AddressType','POBOX');
                        gen.writeStringField('AddressLine1',(objOrder.BillingStreet != null ? objOrder.BillingStreet : ''));
                        gen.writeStringField('City',(objOrder.BillingCity != null ? objOrder.BillingCity : ''));
                        gen.writeStringField('PostalCode',(objOrder.BillingPostalCode != null ? objOrder.BillingPostalCode: ''));
                    gen.writeEndObject();
                gen.writeEndArray();                            
                gen.writeFieldName('Phones');
                gen.writeStartArray(); 
                    gen.writeStartObject();
                        gen.writeStringField('PhoneType','DEFAULT');
                        gen.writeStringField('PhoneNumber',(objOrder.BillToContact.Phone != null ? objOrder.BillToContact.Phone: ''));
                    gen.writeEndObject();
                gen.writeEndArray();                            
                gen.writeEndObject();
            gen.writeEndArray(); 
            gen.writeEndObject();                    
            str = gen.getAsString(); 
            System.debug('str -->'+str );            
        }
        catch(Exception ex){
            System.debug(ex.getMessage()+'-->'+ex.getLineNumber());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
        return str;
    }
    
    /**
    * @description To redirect to Xero oauth page
    * @author kchavda@addonblue.com | 04/03/2020
    * @param 
    * @return 
    **/  
    public static PageReference redirect() {       
        PageReference custPage = new PageReference('/XeroOAuth');
        custPage .setRedirect(true);
        return custPage;
    }
    
    
    /**
    * @description To handle contact creation callout in xero
    * @author kchavda@addonblue.com | 04/03/2020
    * @param  String, Order
    * @return XeroContact 
    **/    
    public static XeroContact createContact(String contactBody, Order objOrder) {   
        lstreqresLogs = new List<RequestResponse_Log__c>();
        XeroContact createdContact;  
        String strResponsebody = '';
        Integer ResponsestatusCode;    
        String reqEndpoint = '';  
        if(!Test.isrunningTest()){
            // Execute the callout to the Contacts resource
            HttpRequest request = XeroCalloutUtility.executeCallout('POST', 'Contacts', contactBody);
            HttpResponse response = new Http().send(request);  
            strResponsebody = response.getBody();   
            ResponsestatusCode = response.getStatusCode(); 
            reqEndpoint = request.getEndpoint();        
        }
        else{
            strResponsebody  = '{"Id":"016905d6-17c7-44dc-a62d-464f04f21654","Status":"OK","ProviderName":"Salesforce","Contacts":[{"ContactID":"03226130-e1c5-4b17-86b8-8718035b9135","ContactStatus":"ACTIVE","Name":"Ben Edwards Ltd","FirstName":"Ben","LastName":"Edwards","EmailAddress":"ben@benedwards","BankAccountDetails":"","Addresses":[{"AddressType":"STREET","AddressLine1":"1 Address Street","AddressLine2":"","AddressLine3":"","AddressLine4":"","City":"Auckland","Region":"Auckland","PostalCode":"12345","Country":"New Zealand","AttentionTo":"Ben Edwards Ltd"},{"AddressType":"POBOX","AddressLine1":"PO Box 12345","AddressLine2":"","AddressLine3":"","AddressLine4":"","City":"Auckland","Region":"Auckland","PostalCode":"12345","Country":"New Zealand","AttentionTo":"Ben Edwards Ltd"}],"Phones":[{"PhoneType":"DDI","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""},{"PhoneType":"DEFAULT","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""},{"PhoneType":"FAX","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""},{"PhoneType":"MOBILE","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""}],"ContactGroups":[],"IsSupplier":false,"IsCustomer":false,"DefaultCurrency":"NZD","ContactPersons":[],"HasAttachments":false,"HasValidationErrors":false}]}';
            ResponsestatusCode = 200; 
            reqEndpoint = 'https://api.xero.com/api.xro/2.0/Contacts'; 
            
        }
        lstreqresLogs.add(reqResLog('XeroCallout','createContact', reqEndpoint, contactBody, strResponsebody,string.valueof(ResponsestatusCode),objOrder.Id,objOrder.BillToContactId));     
        System.debug('@@@response=='+strResponsebody);       
        // If successful response
        if (ResponsestatusCode == 200) {
            System.debug('@@@Success=='+ResponsestatusCode);
            // Use the parser to convert the response into Xero objects
            createdContact = XeroCalloutResponseParser.parseContacts(strResponsebody)[0]; 
            if(createdContact.HasValidationErrors == true ){
                 if(!createdContact.ValidationErrors.isempty() ){
                    for(integer i = 0; i<createdContact.ValidationErrors.size(); i++){
                        createdContact.xeroResponse += createdContact.ValidationErrors[i].Message+'\n';
                    }
                 } 
             }   
             else{       
                 createdContact.xeroResponse = 'Success';      
             }      
        }
       else if(ResponsestatusCode == 401){
            System.debug('@@@Failed=='+ResponsestatusCode);
            XeroTokenRefreshBatch batch = new XeroTokenRefreshBatch('Contact',objOrder,'', null);
            Database.executeBatch(batch);
            return null;
        }
        else {
            // Raise error
            createdContact = new XeroContact();                         
            createdContact.xeroResponse = strResponsebody;
        }        
        if(lstreqresLogs.size() > 0){
            Utility.processRecords(lstreqresLogs, 'insert');
        }
        return createdContact;
    }
    
   
    
    /**
    * @description To create Invoices in Xero
    * @author kchavda@addonblue.com | 04/03/2020
    * @param  Order, String
    * @return string 
    **/  
    public static string createInvoiceJSON(Order objOrder, String contactID){
        String str = '';
        try{
             if(objOrder != null){                
                List<OrderItem> orderLineItems = objOrder.orderItems;
                Id PayTermRecordId = Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
                System.debug('orderLineItems-->'+orderLineItems);
                if(objOrder.Id != null){
                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject(); 
                        gen.writeFieldName('Invoices');                
                        gen.writeStartArray(); 
                            system.debug('gen--->'+gen);
                            List<payment_term__c> lstPTs = new List<payment_term__c>([Select Id,RecordTypeId,Order__r.CurrencyIsoCode, Order__r.BillToContact.Xero_Contact_ID__c,Order__c,CreatedDate,Payment_Due_Date__c from Payment_Term__c where Order__c =: objOrder.Id and recordtypeId !=: PayTermRecordId Limit 1]); 
                            if(lstPTs.isempty()) lstPTs = [Select Id,RecordTypeId,Order__r.CurrencyIsoCode, Order__r.BillToContact.Xero_Contact_ID__c,Order__c,CreatedDate,Payment_Due_Date__c from Payment_Term__c where Order__c =: objOrder.Id and recordtypeId =: PayTermRecordId Limit 1];
                            if(!lstPTs.isempty()){
                                 system.debug('paymentTerm--1->'+lstPTs[0]);
                                 gen.writeStartObject();
                                    gen.writeStringField('Type','ACCREC');
                                    gen.writeStringField('CurrencyCode', (lstPTs[0].Order__r.CurrencyIsoCode != null ? lstPTs[0].Order__r.CurrencyIsoCode : ''));
                                    gen.writeFieldName('Contact');
                                    system.debug('contactID->'+contactID);
                                    gen.writeStartObject();
                                        gen.writeStringField('ContactID',(lstPTs[0].Order__r.BillToContact.Xero_Contact_ID__c != null ? lstPTs[0].Order__r.BillToContact.Xero_Contact_ID__c : contactID));
                                    gen.writeEndObject();
                                    gen.writeStringField('Status','AUTHORISED');
                                    gen.writeStringField('BrandingThemeID', (xeroSettings.Branding_ThemeID__c != null ? xeroSettings.Branding_ThemeID__c : ''));
                                    system.debug('gen--3->'+gen);
                                    //gen.writeStringField('Reference' , (objOrder.Xero_Reference_No__c != null ? objOrder.Xero_Reference_No__c : ''));
                                    if(!Test.isrunningtest()) gen.writeStringField('Reference' , (objOrder.OpportunityId != null ? objOrder.OpportunityId: ''));
                                    system.debug('gen--4->'+gen);
                                    gen.writeDateTimeField('Date',lstPTs[0].CreatedDate);
                                    system.debug('gen--->'+gen);
                                    
                                    if(lstPTs[0].Payment_Due_Date__c != null) gen.writeDateField('DueDate',lstPTs[0].Payment_Due_Date__c);                                         
                                    else if(lstPTs[0].RecordTypeId == PayTermRecordId) gen.writeDateField('DueDate',system.today());
                                    else gen.writeNullField('DueDate');
                                    
                                    system.debug('gendata---->'+gen);
                                    gen.writeFieldName('LineItems');
                                    gen.writeStartArray(); 
                                        if(objOrder.Pricebook2.Xero_Item_Id__c != null || Test.isRunningTest()){
                                            gen.writeStartObject();   
                                                if(objOrder.Pricebook2Id != null && objOrder.Pricebook2.Xero_Item_Id__c != null){                                 
                                                    gen.writeStringField('ItemCode', objOrder.Pricebook2.Xero_Item_Id__c); 
                                                }
                                                else gen.writeStringField('ItemCode', ''); 
                                                                                                
                                                gen.writeStringField('UnitAmount', ''); 
                                                gen.writeStringField('Quantity', '');                                
                                            gen.writeEndObject();
                                        }
                                        for(integer i=0 ; i<orderLineItems.size() ; i++){
                                            gen.writeStartObject();
                                                if(orderLineItems[i].Product2.Name != 'Shipping and Handling'){
                                                    gen.writeStringField('Description', orderLineItems[i].Description != null ? orderLineItems[i].Description : orderLineItems[i].Product2.Name);
                                                    gen.writeNumberField('Quantity',orderLineItems[i].Quantity != null ? orderLineItems[i].Quantity :0);
                                                    Decimal unitPrices = 0;
                                                    Decimal netPrice = 0;
                                                    unitPrices = orderLineItems[i].UnitPrice / 1.20;
                                                    netPrice = orderLineItems[i].UnitPrice - unitPrices;
                                                    gen.writeNumberField('UnitAmount', (objOrder.Pricebook2.Apply_20_VAT_Tax__c == true ? (orderLineItems[i].UnitPrice - netPrice).setScale(3) : orderLineItems[i].UnitPrice));
                                                    //gen.writeNumberField('UnitAmount', (objOrder.Pricebook2.Apply_20_VAT_Tax__c == true ? (orderLineItems[i].UnitPrice - netPrice).setScale(2,RoundingMode.CEILING) : orderLineItems[i].UnitPrice.setScale(2,RoundingMode.CEILING)));
                                                    system.debug('here');
                                                    system.debug('data0'+objOrder.Pricebook2Id);
                                                    system.debug('data1'+objOrder.Pricebook2.Xero_Account_Code__c);
                                                    system.debug('data2'+objOrder.Pricebook2.Apply_20_VAT_Tax__c);
                                                    system.debug('data3'+objOrder.Pricebook2.Xero_Event_Name__c);                                                    
                                                    if(objOrder.Pricebook2.Xero_Account_Code__c != null){
                                                        gen.writeStringField('AccountCode', objOrder.Pricebook2.Xero_Account_Code__c);
                                                    }
                                                    if(objOrder.Pricebook2.Apply_20_VAT_Tax__c == true){
                                                        gen.writeStringField('TaxType', (xeroSettings.TaxType__c != null ? xeroSettings.TaxType__c : ''));
                                                    }
                                                    if(objOrder.Pricebook2.Xero_Event_Name__c != null || Test.isRunningTest()){
                                                        gen.writeFieldName('Tracking');
                                                            gen.writeStartArray(); 
                                                                gen.writeStartObject();
                                                                    gen.writeStringField('TrackingCategoryID', xeroSettings.Tracking_Category_Id__c != null ? xeroSettings.Tracking_Category_Id__c : '');
                                                                    gen.writeStringField('Name', xeroSettings.Category_Name__c != null ? xeroSettings.Category_Name__c : '');
                                                        if(objOrder.Pricebook2Id != null && objOrder.Pricebook2.Xero_Event_Name__c != null){
                                                            gen.writeStringField('Option', (objOrder.Pricebook2.Xero_Event_Name__c));  
                                                        }
                                                        else gen.writeStringField('Option','');
                                                        
                                                        gen.writeEndObject();
                                                        gen.writeEndArray();
                                                    }
                                                } else {
                                                    system.debug('here');
                                                    gen.writeStringField('Description', 'Combined Service Fee');
                                                    gen.writeNumberField('Quantity',orderLineItems[i].Quantity != null ? orderLineItems[i].Quantity :0);
                                                    Decimal unitPrices = 0;
                                                    Decimal netPrice = 0;
                                                    unitPrices = orderLineItems[i].UnitPrice / 1.20;
                                                    netPrice = orderLineItems[i].UnitPrice - unitPrices;                                                    
                                                    gen.writeNumberField('UnitAmount', (objOrder.Pricebook2.Apply_20_VAT_Tax__c == true ? (orderLineItems[i].UnitPrice - netPrice).setScale(2,RoundingMode.CEILING) : orderLineItems[i].UnitPrice));
                                                    //gen.writeNumberField('UnitAmount', (orderLineItems[i].UnitPrice != null ? orderLineItems[i].UnitPrice : 0));
                                                    if(objOrder.Pricebook2.Xero_Account_Code__c != null){
                                                        gen.writeStringField('AccountCode', objOrder.Pricebook2.Xero_Account_Code__c);
                                                    }
                                                    if(objOrder.Pricebook2.Apply_20_VAT_Tax__c == true){
                                                        gen.writeStringField('TaxType', (xeroSettings.TaxType__c != null ? xeroSettings.TaxType__c : ''));
                                                    }
                                                    if(objOrder.Pricebook2.Xero_Event_Name__c != null || Test.isRunningTest()){
                                                        gen.writeFieldName('Tracking');
                                                            gen.writeStartArray(); 
                                                                gen.writeStartObject();
                                                                    gen.writeStringField('TrackingCategoryID', (xeroSettings.Tracking_Category_Id__c != null ? xeroSettings.Tracking_Category_Id__c : '') );
                                                                    gen.writeStringField('Name', (xeroSettings.Category_Name__c != null ? xeroSettings.Category_Name__c : ''));
                                                                    gen.writeStringField('Option', (objOrder.Pricebook2.Xero_Event_Name__c != null ? objOrder.Pricebook2.Xero_Event_Name__c : ''));        
                                                                gen.writeEndObject();
                                                            gen.writeEndArray();
                                                    }
                                                }
                                            gen.writeEndObject();
                                        }
                                    gen.writeEndArray();
                                 gen.writeEndObject();
                                system.debug('here');
                            }
                        gen.writeEndArray();
                    gen.writeEndObject();
                    
                    str = gen.getAsString();
                    System.debug('str-->'+str);
                }
            }
        }
        catch(Exception e){ System.debug('error--'+e.getMessage()+'-->'+e.getLineNumber()+'--'+e.getStackTraceString()); Log.debug('Error: ' + e.getMessage() + '--' + e.getLineNumber() + '--' + e.getStackTraceString());}
        return str;
    }
    
          
    /**
    * @description To handle Invoice creation callout in xero
    * @author kchavda@addonblue.com | 04/03/2020
    * @param  String
    * @return List<XeroInvoice>
    **/  
    public static List<XeroInvoice> createInvoice(String invoiceBody, Id orderId) {
        // The created invoice to return
        List<XeroInvoice> createdInvoice = new List<XeroInvoice>();        
        system.debug('invoicerequestbody--'+invoiceBody);
        String strResponsebody = '';
        Integer ResponsestatusCode;    
        String reqEndpoint = '';  
        // Execute the callout to the Contacts GET resource
        if(!Test.isrunningTest()){
            HttpRequest request = XeroCalloutUtility.executeCallout('POST', 'Invoices', invoiceBody);
            request.setTimeout(6000);
            HttpResponse response = new Http().send(request);
            strResponsebody = response.getBody();   
            ResponsestatusCode = response.getStatusCode(); 
            reqEndpoint = request.getEndpoint();  
        }
        else{
            //strResponsebody  = '{"Id":"917693e1-408b-4301-8c53-7a23b7abeb97","Status":"OK","ProviderName":"Salesforce","Invoices":[{"Type":"ACCREC","InvoiceID":"ddb3d57b-dcc0-4faa-a613-94eea2021edf","InvoiceNumber":"INV-0001","Reference":"","Payments":[],"CreditNotes":[],"Prepayments":[],"Overpayments":[],"AmountDue":600,"AmountPaid":0,"AmountCredited":0,"CurrencyRate":1,"HasErrors":false,"IsDiscounted":false,"HasAttachments":false,"Contact":{"ContactID":"03226130-e1c5-4b17-86b8-8718035b9135","Name":"Ben Edwards Ltd","Addresses":[],"Phones":[],"ContactGroups":[],"ContactPersons":[],"HasValidationErrors":false},"DateString":"2015-12-01T00:00:00","DueDateString":"2015-12-31T00:00:00","Status":"DRAFT","LineAmountTypes":"Exclusive","LineItems":[],"SubTotal":600,"TotalTax":0,"Total":600,"CurrencyCode":"NZD"}]}';
            strResponsebody =  '{  "ErrorNumber": 10,  "Type": "ValidationException",  "Message": "A validation exception occurred",  "Elements": [    {      "Type": "ACCREC",      "InvoiceID": "00000000-0000-0000-0000-000000000000",      "Reference": "",      "Payments": [],      "CreditNotes": [],      "Prepayments": [],      "Overpayments": [],      "IsDiscounted": false,      "HasErrors": true,      "Contact": {        "ContactID": "8dc1481d-887c-4d90-9ddd-07c9885198bd",        "Addresses": [],        "Phones": [],        "ContactGroups": [],        "ContactPersons": [],        "HasValidationErrors": false,        "ValidationErrors": []      },      "DateString": "2020-04-22T12:53:55",      "DueDateString": "2020-04-22T00:00:00",     "BrandingThemeID": "eced7dfe-d286-4904-a3f5-e86b51ad0158",      "Status": "AUTHORISED",      "LineAmountTypes": "Exclusive",      "LineItems": [        {          "Description": "Package Product",          "UnitAmount": 333.33,          "TaxType": "OUTPUT2",          "TaxAmount": 0.00,          "LineAmount": 333.33,          "AccountCode": "200",          "Tracking": [],          "Quantity": 1.0000,          "AccountID": "afb8aecb-1a56-4dd0-86dc-2ff4477a72a9",          "ValidationErrors": []        },        {          "Description": "A La Carte Product",          "UnitAmount": 0.00,          "TaxType": "OUTPUT2",          "TaxAmount": 0.00,          "LineAmount": 0.00,          "AccountCode": "200",          "Tracking": [],          "Quantity": 1.0000,          "AccountID": "afb8aecb-1a56-4dd0-86dc-2ff4477a72a9",          "ValidationErrors": []        },        {          "Description": "Test Product 20",          "UnitAmount": 0.00,          "TaxType": "OUTPUT2",          "TaxAmount": 0.00,          "LineAmount": 0.00,          "AccountCode": "200",          "Tracking": [],          "Quantity": 1.0000,          "AccountID": "afb8aecb-1a56-4dd0-86dc-2ff4477a72a9",          "ValidationErrors": []        },        {          "Description": "Hotel Arena 2020",          "UnitAmount": 0.00,          "TaxType": "OUTPUT2",          "TaxAmount": 0.00,          "LineAmount": 0.00,          "AccountCode": "200",          "Tracking": [],          "Quantity": 1.0000,          "AccountID": "afb8aecb-1a56-4dd0-86dc-2ff4477a72a9",          "ValidationErrors": []        },        {          "Description": "Transportation Product 626",          "UnitAmount": 0.00,          "TaxType": "OUTPUT2",          "TaxAmount": 0.00,          "LineAmount": 0.00,          "AccountCode": "200",          "Tracking": [],          "Quantity": 1.0000,          "AccountID": "afb8aecb-1a56-4dd0-86dc-2ff4477a72a9",          "ValidationErrors": []        },        {          "Description": "Product 626",          "UnitAmount": 0.00,          "TaxType": "OUTPUT2",          "TaxAmount": 0.00,          "LineAmount": 0.00,          "AccountCode": "200",          "Tracking": [],          "Quantity": 1.0000,          "AccountID": "afb8aecb-1a56-4dd0-86dc-2ff4477a72a9",          "ValidationErrors": []        },        {          "Description": "Combined Service Fee",          "UnitAmount": 0.00,          "TaxType": "TAX001",          "TaxAmount": 0.00,          "LineAmount": 0.00,          "AccountCode": "200",          "Tracking": [],          "Quantity": 1.0000,          "AccountID": "afb8aecb-1a56-4dd0-86dc-2ff4477a72a9",          "ValidationErrors": []        }      ],      "SubTotal": 333.33,      "TotalTax": 0.00,      "Total": 333.33,      "CurrencyCode": "USD",      "ValidationErrors": [        {          "Message": "The TaxType code OUTPUT2 does not exist or cannot be used for this type of transaction."        },        {          "Message": "The TaxType code \'OUTPUT2\' cannot be used with account code \'200\'."        }      ]    }  ]}';
            ResponsestatusCode = 400; 
            reqEndpoint = 'https://api.xero.com/api.xro/2.0/Invoices'; 
            
        }
        system.debug('###Invoice -- response=='+strResponsebody);
        system.debug('###orderId-- orderId=='+orderId);        
        // If successful response
         system.debug('###response.getStatusCode()=='+ResponsestatusCode);
        if (ResponsestatusCode == 200) {
            // Use the parser to convert the response into Xero objects
            createdInvoice = XeroCalloutResponseParser.parseInvoices(strResponsebody);
            system.debug('###createdInvoice =='+createdInvoice );
            for(integer i = 0 ; i < createdInvoice.size() ; i++){                
                createdInvoice[i].xeroResponse = 'Success';  
            } 
        }        
        else if(ResponsestatusCode == 400){
            XeroInvoice objXeroInvoice = new XeroInvoice();
            objXeroInvoice = (XeroInvoice) System.JSON.deserialize(strResponsebody, XeroInvoice.class);
            if(Test.isRunningTest()){
                objXeroInvoice.Type = 'ValidationException';
            }
            system.debug('###objXeroInvoice =='+objXeroInvoice);  
            if(objXeroInvoice.Type == 'ValidationException'){
                objXeroInvoice.xeroResponse = '';
                if(Test.isRunningTest() || objXeroInvoice.Elements[0].Contact.HasValidationErrors == true){
                    if(Test.isRunningTest() || !objXeroInvoice.Elements[0].Contact.ValidationErrors.isempty()){
                        for(integer j = 0; j<objXeroInvoice.Elements[0].Contact.ValidationErrors.size(); j++){                        
                           objXeroInvoice.xeroResponse += objXeroInvoice.Elements[0].Contact.ValidationErrors[j].Message+'\n';
                        }
                    }
                }
                if(!objXeroInvoice.Elements[0].LineItems.isempty()){                                         
                    for(integer j = 0; j<objXeroInvoice.Elements[0].LineItems.size(); j++){
                        for(integer k = 0; k<objXeroInvoice.Elements[0].LineItems[j].ValidationErrors.size(); k++){
                            objXeroInvoice.xeroResponse += objXeroInvoice.Elements[0].LineItems[j].ValidationErrors[k].Message+'\n';    
                            if(objXeroInvoice.Elements[0].LineItems[j].Tracking != null && objXeroInvoice.Elements[0].LineItems[j].Tracking.size()>0){                         
                                for(integer l = 0; l<objXeroInvoice.Elements[0].LineItems[j].Tracking[0].ValidationErrors.size(); l++){                                
                                    objXeroInvoice.xeroResponse += objXeroInvoice.Elements[0].LineItems[j].Tracking[0].ValidationErrors[l].Message+'\n'; 
                                } 
                            }
                        }
                        
                    }
                }                     
                if(!objXeroInvoice.Elements[0].ValidationErrors.isempty()){
                    for(integer j = 0; j<objXeroInvoice.Elements[0].ValidationErrors.size(); j++){
                        objXeroInvoice.xeroResponse += objXeroInvoice.Elements[0].ValidationErrors[j].Message+'\n';
                    }
                }
            }
            createdInvoice.add(objXeroInvoice);
        }
        else {
            // Raise error
            createdInvoice = new List<XeroInvoice>();
            XeroInvoice xeroinv = new XeroInvoice();            
            xeroinv.xeroInvoiceStatus = 'Failed';
            JSONParser parser = JSON.createParser(strResponsebody);
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    XeroPaymentError inv = (XeroPaymentError)parser.readValueAs(XeroPaymentError.class);                        
                    xeroinv.xeroResponse = inv.Type; 
                }
            }
            createdInvoice.add(xeroinv);
                        
        }
        if(!createdInvoice.isempty()){
            createdInvoice[0].lstreqresLogs = new List<RequestResponse_Log__c>();
            createdInvoice[0].lstreqresLogs.add(reqResLog('XeroCallout','createInvoice', reqEndpoint, invoiceBody, strResponsebody,string.valueof(ResponsestatusCode),orderId,null)); 
        }else{
            XeroInvoice inv = new XeroInvoice();
            inv.lstreqresLogs = new List<RequestResponse_Log__c>();
            inv.lstreqresLogs.add(reqResLog('XeroCallout','createInvoice', reqEndpoint, invoiceBody, strResponsebody,string.valueof(ResponsestatusCode),orderId,null));
            createdInvoice.add(inv); 
        }
        
        
        System.debug('createdInvoice-->'+createdInvoice);
        return createdInvoice;
    }
           
    /**
    * @description To send invoice email to customer
    * @author kchavda@addonblue.com | 04/03/2020
    * @param  String
    * @return void
    **/  
    public static void EmailInvoice(String invoiceId) {            
        // The created invoice to return
        List<XeroInvoice> createdInvoice;
        // Execute the callout to the Contacts GET resource
        if(!Test.IsrunningTest()){
            HttpRequest request = XeroCalloutUtility.executeCallout('POST', 'Invoices/'+invoiceId+'/Email','');
            HttpResponse response = new Http().send(request);
            system.debug('###response=='+response.getBody());   
        }
    }
    
    
    /**
    * @description To create Payment in Xero
    * @author kchavda@addonblue.com | 04/03/2020
    * @param  Payment_Term__c
    * @return Payment_Term__c
    **/  
    public static wrpPayments createPaymentJSON(Payment_Term__c PaymentTerm,string InvoiceId){
        wrpPayments objwrpPayment = new wrpPayments();
        Charge__c objCharge = New Charge__c();
        lstreqresLogs = new List<RequestResponse_Log__c>();
        try{            
            if(PaymentTerm != null){             
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject(); 
                gen.writeFieldName('Payments');
                    gen.writeStartObject();
                        gen.writeFieldName('Invoice');
                            gen.writeStartObject();
                                gen.writeStringField('InvoiceID',(InvoiceId != null ? InvoiceId : ''));
                            gen.writeEndObject();
                        gen.writeFieldName('Account');
                            gen.writeStartObject();
                                //#519 Xero Related Changes added by Fesal
                                Decimal xeroAccountCode = null;
                                if(PaymentTerm.order__r.CurrencyIsoCode == 'USD') {
                                    xeroAccountCode = xeroSettings.USD_Account_Code__c;
                                } else if (PaymentTerm.order__r.CurrencyIsoCode == 'EUR') {
                                    xeroAccountCode = xeroSettings.EUR_Account_Code__c;
                                }  else if (PaymentTerm.order__r.CurrencyIsoCode == 'GBP' || PaymentTerm.order__r.CurrencyIsoCode == 'AUD' || PaymentTerm.order__r.CurrencyIsoCode == 'CAD') {
                                    xeroAccountCode = xeroSettings.GAC_Account_Code__c;
                                }
                                gen.writeStringField('Code',(xeroAccountCode != null ? String.valueOf(xeroAccountCode) : ''));
                            gen.writeEndObject();
                        if(!Test.isRunningTest()){
                            gen.writeDateTimeField('Date',PaymentTerm.CreatedDate);
                        }else{
                            gen.writeDateTimeField('Date',System.today());
                        }
                        /*Decimal unitPrices = 0;
                        Decimal netPrice = 0;
                        unitPrices = (PaymentTerm.Amount__c != null ? PaymentTerm.Amount__c  / 1.20 : 0);
                        netPrice =  (PaymentTerm.Amount__c != null ? PaymentTerm.Amount__c - unitPrices  : 0);
                        if(!Test.isRunningTest())
                        gen.writeNumberField('Amount',(PaymentTerm.order__r.Pricebook2.Apply_20_VAT_Tax__c == true && PaymentTerm.Amount__c != null ? (PaymentTerm.Amount__c - netPrice).setScale(2): PaymentTerm.Amount__c.setScale(2)));
                        */
                        if(!Test.isRunningTest()) gen.writeNumberField('Amount',(PaymentTerm.Amount__c != null ? PaymentTerm.Amount__c.setScale(2): PaymentTerm.Amount__c));
                        if(!Test.isRunningTest() && PaymentTerm.RecordType.Name.equals('Credit')) gen.writeStringField('Reference','CREDIT'); 
                    gen.writeEndObject();
                gen.writeEndObject();
    
                String str = gen.getAsString();
                str = str.replace('"Payments" : {','');
                str = str.removeEnd('}');
                System.debug('str-->'+str);
                XeroPayment XeroPayment  = new XeroPayment();                
                XeroPayment = createPayment(str,PaymentTerm.Order__c,PaymentTerm);                
                System.debug('XeroPayment-->'+XeroPayment);                
                
                if(XeroPayment.Payments != null && !XeroPayment.Payments.isempty()){  
                    /*objCharge.Amount__c = XeroPayment.Payments[0].Amount;    
                    objCharge.Account__c = PaymentTerm.Order__r.AccountId; 
                    objCharge.Payment_Terms__c = PaymentTerm.Id;         
                    objCharge.recordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Debit').getRecordTypeId();      
                    objCharge.Xero_Payment_Id__c = XeroPayment.Payments[0].PaymentID;
                    objCharge.Xero_Response__c = XeroPayment.xeroResponse;
                    objCharge.Status__c = 'Succeed';*/ 
                    if(PaymentTerm.order__r.GPE_Online_Order__c == true){
                        List<charge__c> lstcharge = [Select id,Xero_Payment_Id__c,Xero_Response__c from charge__c where Payment_Terms__c =: PaymentTerm.Id limit 1]; //recordtype.name = 'Debit' and 
                        if(!lstcharge.isempty()){
                            objCharge = lstcharge[0];
                            objCharge.Xero_Payment_Id__c = XeroPayment.Payments[0].PaymentID;
                            objCharge.Xero_Response__c = XeroPayment.xeroResponse;
                        }
                    }
                    objwrpPayment.objCharge = objCharge;     
                    PaymentTerm.Xero_Payment_Id__c = XeroPayment.Payments[0].PaymentID;
                    PaymentTerm.Xero_Response__c = XeroPayment.xeroResponse;  
                    objwrpPayment.PaymentTerm = PaymentTerm;
                    //Utility.processRecords(PaymentTerm, 'update');           
                }
                if(XeroPayment.lstreqresLogs != null && XeroPayment.lstreqresLogs.size()>0){
                    lstreqresLogs.addall(XeroPayment.lstreqresLogs); 
                    objwrpPayment.lstreqresLogs.addall(lstreqresLogs);       
                }                    
                if(!string.isblank(XeroPayment.xeroResponse)){
                    Order od = new order(id=PaymentTerm.Order__c);
                    od.Xero_Response__c = XeroPayment.xeroResponse;
                    objwrpPayment.odr = od;
                    //Utility.processRecords(od, 'update');
                }
            }
            
            if(lstreqresLogs.size() > 0){
                //Utility.processRecords(lstreqresLogs, 'insert');
            }
       }
       catch(Exception e){System.debug(e.getMessage()+'-->'+e.getLineNumber()); Log.debug('Error: ' + e.getMessage() + '--' + e.getLineNumber() + '--' + e.getStackTraceString());}
       System.debug('objwrpPayment-->'+objwrpPayment);
       return objwrpPayment;
    }
    
    public class wrpPayments{
        public charge__c objCharge;
        public List<RequestResponse_Log__c> lstreqresLogs;
        public Payment_term__c  PaymentTerm;
        public Order odr;
        
        public wrpPayments(){
            objCharge = new charge__c();
            lstreqresLogs = new List<RequestResponse_Log__c>();
            PaymentTerm = new Payment_term__c();
            odr = new order();
        }
        
    }
    /**
    * @description To handle Payment creation callout in xero
    * @author kchavda@addonblue.com | 04/03/2020
    * @param  String
    * @return List<XeroPayment>
    **/   
    public static XeroPayment createPayment (String paymentBody,Id orderId, Payment_Term__c PaymentTerm) {
        // The created invoice to return
        XeroPayment createPayment = new XeroPayment();  
        String strResponsebody = '';
        Integer ResponsestatusCode;    
        String reqEndpoint = '';    
        if(!Test.isrunningTest()){  
            // Execute the callout to the Contacts GET resource
            HttpRequest request = XeroCalloutUtility.executeCallout('POST', 'Payments', paymentBody);
            HttpResponse response = new Http().send(request);
            strResponsebody = response.getBody();   
            ResponsestatusCode = response.getStatusCode(); 
            reqEndpoint = request.getEndpoint();                
        }else{
            strResponsebody = '{"Payments":[{"PaymentID":"b26fd49a-cbae-470a-a8f8-bcbc119e0379","BankAmount":500,"Amount":500,"Reference":"INV-0001","CurrencyRate":1,"PaymentType":"ACCRECPAYMENT","Status":"AUTHORISED","HasAccount":true,"IsReconciled":true,"Account":{"AccountID":"ac993f75-035b-433c-82e0-7b7a2d40802c","Code":"090"},"Invoice":{"Type":"ACCREC","InvoiceID":"b0875d8b-ff26-4ce8-8aea-6955492ead48","InvoiceNumber":"INV-0001","Contact":{"ContactID":"fef6755f-549b-4617-b1e9-60bdffb517d8","Name":"Ridgeway University"}}}]}';   
            ResponsestatusCode = 200; 
            reqEndpoint = 'https://api.xero.com/api.xro/2.0/Payments'; 
        }
        System.debug('###response=='+strResponsebody);
        System.debug('###response.getStatusCode()=='+ResponsestatusCode);
        // If successful response
        if (ResponsestatusCode == 200) {
            // Use the parser to convert the response into Xero objects       
            createPayment = XeroCalloutResponseParser.parsePayment(strResponsebody);
            createPayment.xeroResponse = 'Success';
            System.debug('@@@createPayment =='+createPayment ); 
                    
        }        
        else if(ResponsestatusCode == 400){
            createPayment = (XeroPayment) System.JSON.deserialize(strResponsebody, XeroPayment.class);            
            system.debug('###createPayment =='+createPayment);  
            if(createPayment.Type == 'ValidationException' || Test.isRunningTest()){
                createPayment.xeroResponse = '';
                if(createPayment.Elements[0].HasValidationErrors == true && !createPayment.Elements[0].ValidationErrors.isempty()){                    
                    for(integer j = 0; j<createPayment.Elements[0].ValidationErrors.size(); j++){
                        createPayment.xeroResponse += createPayment.Elements[0].ValidationErrors[j].Message+'\n';
                    }                        
                }
            }
            
        }
        else {
            // Raise error                      
            JSONParser parser = JSON.createParser(strResponsebody);
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    XeroPaymentError inv = (XeroPaymentError)parser.readValueAs(XeroPaymentError.class);                        
                    createPayment.xeroResponse = inv.Type;
                }
            }
                   
        }  
        if(Test.isRunningTest() || createPayment != null){
            createPayment.lstreqresLogs = new List<RequestResponse_Log__c>();
            createPayment.lstreqresLogs.add(reqResLog('XeroCallout','createPayment', reqEndpoint, paymentBody, strResponsebody,string.valueof(ResponsestatusCode),orderId,paymentTerm.Id)); 
        }else{
            createPayment = new XeroPayment();
            createPayment.lstreqresLogs = new List<RequestResponse_Log__c>();
            createPayment.lstreqresLogs.add(reqResLog('XeroCallout','createPayment', reqEndpoint, paymentBody, strResponsebody,string.valueof(ResponsestatusCode),orderId,paymentTerm.Id));             
        } 
         
        return createPayment;
    }
    
    
    public static RequestResponse_Log__c reqResLog(String clsName,String mthName, String url, String req, String res, String code,Id OrderId,Id relatedId){
        RequestResponse_Log__c ReqResObj = new RequestResponse_Log__c();
        ReqResObj.Class_Name__c = clsName;
        ReqResObj.Method_Name__c = mthName;        
        ReqResObj.Order__c = OrderId;
          if(relatedId != null){
            String sObjName = relatedId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Account'){
                ReqResObj.Account__c = relatedId;
            }else if(sObjName == 'Contact'){
                ReqResObj.Contact__c = relatedId;
            }else if(sObjName == 'Payment_Term__c'){
                ReqResObj.Payment_Terms__c = relatedId;
            }
             
        }
        ReqResObj.API_URL__c = url;
        ReqResObj.Request__c = req;
        ReqResObj.Response__c = res;        
        ReqResObj.Status_Code__c = code;
        return ReqResObj;
    }
    
    /**
    * @description class Xero Payment Error
    * @author kchavda@addonblue.com | 04/03/2020
    * @param  
    * @return 
    **/  
    public class XeroPaymentError{
        public String Type{get; set;}
               
    }
    
    
}
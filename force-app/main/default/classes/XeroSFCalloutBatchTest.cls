/**
 * @File Name          : XeroSFCalloutBatchTest.cls
 * @Description        : test class for the SendOrderToXero controller
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 10-19-2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    04/24/2020    mpatel@addonblue.com       Initial Version
**/
@isTest
private with sharing class XeroSFCalloutBatchTest {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }
    
    @isTest static void xeroFirstTestExecution() {
        Test.StartTest();
        Account objAccount = TestDataFactory.createAccount();
        System.assert(true,objAccount.Name != null);

        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        System.assertEquals('Test@gmail.com', objContact.Email);

        PriceBook2 priceBook = TestDataFactory.createPricebook(1, 'T', false)[0];
        priceBook.Payment_Cancellation_Days__c = 2;
        priceBook.Start_Date__c = system.today();
        priceBook.Event_Payment_Window__c = 1;
        Utility.processRecords(pricebook, 'insert');

        /*Opportunity opportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, pricebook.id, false)[0];
        opportunity.PriceBook2Id = pricebook.Id;
        opportunity.StageName = 'Closed Won';
        Utility.processRecords(opportunity, 'insert');
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = objContact.Id;
        ocr.OpportunityId = Opportunity.Id;
        ocr.Role = 'H4H Rewards Contact';
        Utility.processRecords(ocr, 'insert');*/
        
        TestDataFactory.createSFDCIntacctMapping();
        
        Order order = TestDataFactory.createOrder(1,false)[0];
        //order.OpportunityId = opportunity.Id;
        order.priceBook2Id = Test.getStandardPricebookId();
        Utility.processRecords(order, 'insert');        
        order od = [select id,QuoteId,pricebook2id from order where id =: order.id];
        quote qt = [select id,GPE_Online_Order__c from quote where id =: od.QuoteId];
        qt.GPE_Online_Order__c = true;
        update qt;               
        Set<Id> orderSet = new Set<Id>();
        orderSet.add(order.Id);
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('XeroContactsMock');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
        XeroSFCalloutBatch calloutObj = new XeroSFCalloutBatch(orderSet);
        ID batchprocessid = Database.executeBatch(calloutObj);
        Test.StopTest();
    }
    
    @isTest static void xeroSecondTestExecution() {
        Test.StartTest();
        
        Xero_Configuration__c xeroConfiguration = new Xero_Configuration__c();
        xeroConfiguration.Active__c = true;
        xeroConfiguration.Access_Token__c = 'fserfwr';
        xeroConfiguration.Authentication_Endpoint__c='ewferf';
        xeroConfiguration.Branding_ThemeID__c = 'erf';
        xeroConfiguration.Category_Name__c = 'efr';
        xeroConfiguration.Consumer_Key__c = 'erferf';
        xeroConfiguration.Consumer_Secret__c = 'ererf';
        xeroConfiguration.Endpoint__c = 'erferf';
        xeroConfiguration.Tenant_Id__c = 'ghfgtrd';
        xeroConfiguration.Scope__c = 'offline transaction';
        Utility.processRecords(xeroConfiguration, 'insert');        
        
        Account objAccount = TestDataFactory.createAccount();
        System.assert(true,objAccount.Name != null);

        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        objContact.Xero_Contact_Id__c = '234566';
        Utility.processRecords(objContact, 'insert');
        System.debug('objContact-->'+objContact);

        PriceBook2 PriceBook = TestDataFactory.createPricebook(1, 'Test TB', false)[0];
        pricebook.Xero_Item_Id__c = 'test';
        pricebook.Xero_Account_Code__c = 'test';
        pricebook.Apply_20_VAT_Tax__c = true;
        pricebook.Xero_Event_Name__c = 'test';
        Utility.processRecords(PriceBook, 'insert');

        Product2 product = TestDataFactory.createProduct(1, 'Hotel Stay')[0];
        
        Product2 product1 = TestDataFactory.createProduct(1, 'Product', Test.getStandardPricebookId(),false)[0];
        product1.name = 'Shipping and Handling';
        Utility.processRecords(product1, 'insert');
        
        PriceBook2 priceBook1 = new PriceBook2(id=Test.getStandardPricebookId());
        priceBook1.Xero_Account_Code__c = '200';
        priceBook1.Apply_20_VAT_Tax__c = true;        
        priceBook1.Xero_Item_Id__c = 'test 521';
        priceBook1.Xero_Event_Name__c = 'test 521d';
        update priceBook1;
        
        PricebookEntry pricebookentry = new PricebookEntry(
                unitprice = 0.01,
                Product2Id = product.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                isActive = true,
                UseStandardPrice = false
        ); 
        Utility.processRecords(pricebookentry, 'insert');        
        System.debug('pricebookentry-->'+pricebookentry);
        PricebookEntry pricebookentry1 = new PricebookEntry(
                unitprice = 0.01,
                Product2Id = product1.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                isActive = true,
                UseStandardPrice = false
        ); 
        Utility.processRecords(pricebookentry1, 'insert');
        
        /*Opportunity opportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.Id, priceBookEntry.Pricebook2Id )[0];

        Utility.processRecords(opportunity, 'insert');
        TestDataFactory.createSFDCIntacctMapping();
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = Opportunity.Id;
        ocr.ContactId = objContact.Id;
        Utility.processRecords(ocr, 'insert');*/

        Order order = TestDataFactory.createOrder(1, false)[0];        
        //order.OpportunityId = Opportunity.Id;
        order.BillToContactId = objContact.Id;
        Order.Status = 'Draft';
        Order.Pricebook2Id = priceBookEntry.Pricebook2Id;
        Utility.processRecords(order, 'insert');
        
        System.debug('order-->'+order);
        OrderItem orderItem = new OrderItem(
                Quantity = 2,
                OrderId = order.Id,
                ProductType__c = 'F1 Access Code',
                UnitPrice = 232,
                PricebookEntryId = priceBookEntry.Id,
                Description = 'test'
            );
        Utility.processRecords(orderItem, 'insert');
        System.debug('orderItem-->'+orderItem);
        
        System.debug('order-->'+order);
        OrderItem orderItem1 = new OrderItem(
                Quantity = 2,
                OrderId = order.Id,
                ProductType__c = 'F1 Access Code',
                UnitPrice = 232,
                PricebookEntryId = pricebookentry1.Id,
                Description = 'test'
            );
        Utility.processRecords(orderItem1, 'insert');
        
        Payment_Term__c paymentterm = TestDataFactory.createPaymentTerm(1, false)[0];
        paymentterm.Order__c = order.id;
        paymentterm.Amount__c = 54464;
        paymentterm.Payment_Due_Date__c = system.today().adddays(1);
        Utility.processRecords(paymentterm, 'insert');
        
        Order orderObj = [Select id,BillToContactId,Xero_Reference_No__c,OpportunityId,Pricebook2Id,Pricebook2.Xero_Item_Id__c,Pricebook2.Xero_Account_Code__c, Pricebook2.Apply_20_VAT_Tax__c,Pricebook2.Xero_Event_Name__c, (Select id,Product2Id,Product2.Name,Description,
                            Quantity,UnitPrice from OrderItems) from order where id =: order.Id limit 1];
       // System.debug('###orderObj=='+orderObj.Pricebook2.Xero_Item_Id__c);
        System.assertEquals(orderObj.Id, order.id);
        
        XeroCallout.createContactJson(orderObj);
        XeroCallout.createInvoiceJSON(orderObj,'1234555');
        XeroCallout.redirect();
        
        
        XeroCallout.reqResLog('','', '', '', '', '',objContact.AccountId,objContact.AccountId);
        XeroCallout.reqResLog('','', '', '', '', '',objContact.AccountId,objContact.Id);
        XeroCallout.reqResLog('','', '', '', '', '',objContact.AccountId,paymentterm.Id);
        
        xerocallout.createContact('tsttest',order);
        xerocallout.createInvoice('tsttest',order.id);
        XeroCallout.createPaymentJSON(paymentterm, 'XeroInvoiceID');
        XeroCallout.XeroPaymentError obj = new XeroCallout.XeroPaymentError();  
        
        XeroCalloutUtility.executeCallout('Post', 'Contact', 'test');
        XeroCalloutUtility.executeCallout('Post', 'Contact', 'test',xeroConfiguration);
        
        
        Test.StopTest();
        
    }    
    
    
   static testMethod  void xeroThirdTestExecution() {
      Test.StartTest();      
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('XeroContactsMock');
        mock.setStatusCode(401);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        HttpRequest request = XeroCalloutUtility.executeCallout('POST', 'Contacts', '');
        HttpResponse response = new Http().send(request); 
        system.debug('###response=='+response.getbody()); 
        XeroContact objXeroContact  = XeroCalloutResponseParser.parseContacts(response.getbody())[0];
        system.debug('###objXeroContact=='+objXeroContact); 
        objXeroContact.Contactstatus = objXeroContact.Contactstatus;
        objXeroContact.ContactID= objXeroContact.ContactID;
        objXeroContact.Name= objXeroContact.Name;
        objXeroContact.FirstName= objXeroContact.FirstName;
        objXeroContact.LastName = objXeroContact.LastName;
        objXeroContact.EmailAddress= objXeroContact.EmailAddress;
        objXeroContact.BankAccountDetails= objXeroContact.BankAccountDetails;
        objXeroContact.SkypeUserName= objXeroContact.SkypeUserName;
        objXeroContact.Addresses= objXeroContact.Addresses;
        objXeroContact.Phones= objXeroContact.Phones;
        objXeroContact.UpdatedDateUTC= objXeroContact.UpdatedDateUTC;        
        objXeroContact.IsSupplier= objXeroContact.IsSupplier;
        objXeroContact.DefaultCurrency= objXeroContact.DefaultCurrency;        
        objXeroContact.IsCustomer= objXeroContact.IsCustomer;        
        objXeroContact.HasAttachments= objXeroContact.HasAttachments;
        objXeroContact.HasValidationErrors= objXeroContact.HasValidationErrors;        
        objXeroContact.xeroContactStatus= objXeroContact.xeroContactStatus;
        objXeroContact.xeroContactFailureReason= objXeroContact.xeroContactFailureReason;
        objXeroContact.xeroResponse= objXeroContact.xeroResponse;
        objXeroContact.ValidationErrors= objXeroContact.ValidationErrors;
        XeroContact.XeroPhone phone = new XeroContact.XeroPhone();  
        phone.PhoneType = objXeroContact.Phones[0].PhoneType;    
        phone.PhoneNumber = objXeroContact.Phones[0].PhoneNumber; 
        phone.PhoneAreaCode= objXeroContact.Phones[0].PhoneAreaCode; 
        phone.PhoneCountryCode= objXeroContact.Phones[0].PhoneCountryCode;
        XeroContact.ValidationErrors err = new XeroContact.ValidationErrors();
        err.Message = '';  
        XeroContact.XeroAddress address = new XeroContact.XeroAddress();
        address.AddressType = objXeroContact.Addresses[0].AddressType;   
        address.AddressLine1 = objXeroContact.Addresses[0].AddressLine1; 
        address.AddressLine2 = objXeroContact.Addresses[0].AddressLine2; 
        address.AddressLine3 = objXeroContact.Addresses[0].AddressLine3; 
        address.AddressLine4 = objXeroContact.Addresses[0].AddressLine4; 
        address.City = objXeroContact.Addresses[0].City; 
        address.Region = objXeroContact.Addresses[0].Region;
        address.PostalCode = objXeroContact.Addresses[0].PostalCode;
        address.Country = objXeroContact.Addresses[0].Country;
        address.AttentionTo = objXeroContact.Addresses[0].AttentionTo;
        Test.StopTest();
    }

    static testMethod  void xeroFourthTestExecution() {
      Test.StartTest();      
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('XeroInvoicesMock');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        HttpRequest request = XeroCalloutUtility.executeCallout('POST', 'Invoices', '');
        HttpResponse response = new Http().send(request); 
        system.debug('###response=='+response.getbody()); 
        XeroInvoice objXeroInvoice  = XeroCalloutResponseParser.parseInvoices(response.getbody())[0];
        system.debug('###objXeroInvoice=='+objXeroInvoice); 
        objXeroInvoice.Type = objXeroInvoice.Type;
        objXeroInvoice.InvoiceID  = objXeroInvoice.InvoiceID;
        objXeroInvoice.InvoiceNumber = objXeroInvoice.InvoiceNumber;
        objXeroInvoice.Reference  = objXeroInvoice.Reference;
        objXeroInvoice.Payments  = objXeroInvoice.Payments;
        objXeroInvoice.AmountDue  = objXeroInvoice.AmountDue;
        objXeroInvoice.AmountPaid  = objXeroInvoice.AmountPaid;
        objXeroInvoice.SentToContact  = objXeroInvoice.SentToContact;
        objXeroInvoice.CurrencyRate  = objXeroInvoice.CurrencyRate ;
        objXeroInvoice.IsDiscounted  = objXeroInvoice.IsDiscounted;
        objXeroInvoice.Contact   = objXeroInvoice.Contact;
        objXeroInvoice.Date_x  = objXeroInvoice.Date_x ;
        objXeroInvoice.DueDate  = objXeroInvoice.DueDate;

        objXeroInvoice.HasErrors = objXeroInvoice.HasErrors;
        objXeroInvoice.FullyPaidOnDate  = objXeroInvoice.FullyPaidOnDate;
        objXeroInvoice.Status = objXeroInvoice.Status;
        objXeroInvoice.LineAmountTypes = objXeroInvoice.LineAmountTypes;
        objXeroInvoice.LineItems = objXeroInvoice.LineItems;
        objXeroInvoice.SubTotal = objXeroInvoice.SubTotal;
        objXeroInvoice.TotalTax = objXeroInvoice.TotalTax;
        objXeroInvoice.Total = objXeroInvoice.Total;
        objXeroInvoice.UpdatedDateUTC  = objXeroInvoice.UpdatedDateUTC;
        objXeroInvoice.CurrencyCode  = objXeroInvoice.CurrencyCode;
        objXeroInvoice.xeroInvoiceStatus   = objXeroInvoice.xeroInvoiceStatus;
        objXeroInvoice.xeroInvoiceFailureReason  = objXeroInvoice.xeroInvoiceFailureReason;
        objXeroInvoice.xeroResponse  = objXeroInvoice.xeroResponse;

        objXeroInvoice.lstreqresLogs  = objXeroInvoice.lstreqresLogs;
        objXeroInvoice.ErrorNumber   = objXeroInvoice.ErrorNumber;
        objXeroInvoice.Message  = objXeroInvoice.Message;
        objXeroInvoice.Elements  = objXeroInvoice.Elements;
        XeroInvoice.cls_Elements ele = new XeroInvoice.cls_Elements();
        ele.Contact = objXeroInvoice.Contact;
        ele.LineItems =  objXeroInvoice.LineItems;
        XeroInvoice.Payment pay = new XeroInvoice.Payment();
        pay.PaymentID = '12345656';
        XeroInvoice.ValidationErrors ve = new XeroInvoice.ValidationErrors();
        ve.message = '';
        XeroInvoice.LineItem litem = new XeroInvoice.LineItem();
        litem.ItemCode = 'test';
        litem.Description = 'testdesc';
        litem.UnitAmount = 10;
        litem.TaxType = 'tetype';
        litem.TaxAmount  = 10;
        litem.LineAmount  = 10;
        litem.AccountCode  = '200';
        litem.Tracking  = null;
        litem.Quantity  = 20;
        litem.LineItemID  = '852';
        Test.StopTest();
    }

    static testMethod  void xeroFifthTestExecution() {
      Test.StartTest();   
        String str = '{  "Id": "22d38a44-58b3-45b2-a51e-4275e3c72a83",  "Status": "OK",  "ProviderName": "QE360 Cleanup App",  "DateTimeUTC": "Date(1588257814973)",  "Payments": [    {      "PaymentID": "78428354-4717-4cdc-bc89-5e32d74ec774",      "Date": "Date(1588204800000+0000)",      "BankAmount": 14177.18,      "Amount": 188.84,      "CurrencyRate": 0.013320,      "PaymentType": "ACCRECPAYMENT",      "Status": "AUTHORISED",      "UpdatedDateUTC": "Date(1588257814907+0000)",      "HasAccount": true,      "IsReconciled": false,      "Account": {        "AccountID": "afb8aecb-1a56-4dd0-86dc-2ff4477a72a9",        "Code": "200",        "Name": "Sales"      },      "Invoice": {        "Type": "ACCREC",        "InvoiceID": "6a01693e-da81-41ab-8730-244fe00cbc28",        "InvoiceNumber": "INV-0047",        "Reference": "",        "Prepayments": [],        "Overpayments": [],        "AmountDue": 0.00,        "AmountPaid": 188.84,        "SentToContact": false,        "CurrencyRate": 0.013320,        "IsDiscounted": false,        "HasErrors": false,        "Contact": {          "ContactID": "5649fde6-1472-41c0-893e-b3adeef433f1",          "Name": "L1 Panchal1",          "ContactPersons": [],          "HasValidationErrors": false        },        "DateString": "2020-04-30T00:00:00",        "Date": "Date(1588204800000+0000)",        "DueDateString": "2020-04-30T00:00:00",        "DueDate": "Date(1588204800000+0000)",        "BrandingThemeID": "eced7dfe-d286-4904-a3f5-e86b51ad0158",        "Status": "PAID",        "LineAmountTypes": "Exclusive",        "LineItems": [          {            "Description": "Ticket to Race",            "UnitAmount": 94.42,            "TaxType": "OUTPUT",            "TaxAmount": 0.00,            "LineAmount": 188.84,            "AccountCode": "200",            "Tracking": [],            "Quantity": 2.0000,            "LineItemID": "f08ecc91-65e9-44e8-96c2-c22d5dd9593c",            "ValidationErrors": []          },          {            "Description": "Combined Service Fee",            "UnitAmount": 0.00,            "TaxAmount": 0.00,            "LineAmount": 0.00,            "Tracking": [],            "Quantity": 1.0000,            "LineItemID": "4299d70a-c788-4a96-a625-0e7bd4bb7dea",            "ValidationErrors": []          }        ],        "SubTotal": 188.84,        "TotalTax": 0.00,        "Total": 188.84,        "UpdatedDateUTC": "Date(1588257814907+0000)",        "CurrencyCode": "USD",        "FullyPaidOnDate": "Date(1588204800000+0000)"      },      "HasValidationErrors": false    }  ]}';
         XeroPayment objXeroPayment = XeroCalloutResponseParser.parsePayment(str);
         objXeroPayment.Dates=objXeroPayment.Dates;
        objXeroPayment.BankAmount=objXeroPayment.BankAmount;
        objXeroPayment.Amount=objXeroPayment.Amount;
        objXeroPayment.Reference=objXeroPayment.Reference;
        objXeroPayment.CurrencyRate=objXeroPayment.CurrencyRate;
        objXeroPayment.PaymentType=objXeroPayment.PaymentType;
        objXeroPayment.Status=objXeroPayment.Status;
        objXeroPayment.Accounts=objXeroPayment.Accounts;
        objXeroPayment.Invoices=objXeroPayment.Invoices;
        objXeroPayment.UpdatedDateUTC=objXeroPayment.UpdatedDateUTC;
        objXeroPayment.HasAccount=objXeroPayment.HasAccount;
        objXeroPayment.IsCustomer=objXeroPayment.IsCustomer;
        objXeroPayment.Contacts=objXeroPayment.Contacts;
        objXeroPayment.xeroPaymentStatus=objXeroPayment.xeroPaymentStatus;
        objXeroPayment.xeroPaymentFailureReason=objXeroPayment.xeroPaymentFailureReason;
        objXeroPayment.xeroResponse=objXeroPayment.xeroResponse;
        objXeroPayment.ValidationErrors=objXeroPayment.ValidationErrors;
        objXeroPayment.lstreqresLogs=objXeroPayment.lstreqresLogs;
        objXeroPayment.ErrorNumber=objXeroPayment.ErrorNumber;
        objXeroPayment.Type=objXeroPayment.Type;
        objXeroPayment.Message=objXeroPayment.Message;
        objXeroPayment.Elements=objXeroPayment.Elements;
        objXeroPayment.Id=objXeroPayment.Id;
        objXeroPayment.ProviderName=objXeroPayment.ProviderName;
        objXeroPayment.DateTimeUTC=objXeroPayment.DateTimeUTC;
        objXeroPayment.Payments=objXeroPayment.Payments;
        objXeroPayment.PaymentID=objXeroPayment.PaymentID;

        XeroPayment.cls_Elements ele = new XeroPayment.cls_Elements();
        ele.Amount = 0;
        ele.HasAccount = false;
        ele.Invoice = null;
        ele.HasValidationErrors = false;

        XeroPayment.xeroAccount acc = new XeroPayment.xeroAccount();
        acc.AccountID = null;
        acc.Code = '123';
       
        XeroPayment.xeroContact con = new XeroPayment.xeroContact();
        con.ContactID = null;
        con.Name = 'test';

        XeroPayment.XeroInvoice inv = new XeroPayment.XeroInvoice();
        inv.Type = 'bank';
        inv.InvoiceID = '456123789';
        inv.InvoiceNumber = '456123789';
        inv.Contact = null;
        inv.ContentLength = 10;
        inv.HasErrors = false;
        inv.LineItems = null;

      Test.StopTest();
    }
}
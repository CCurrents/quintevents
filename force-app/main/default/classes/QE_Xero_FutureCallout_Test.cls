/**
 * @File Name          : QE_Xero_FutureCallout_Test.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : Lovel Panchal
 * @Last Modified On   : 5/11/2020, 9:45:35 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
public class QE_Xero_FutureCallout_Test {
    @isTest
    static void createContactSuccess(){


        // Test.startTest();
        // Xero_Settings__c xeroSetting = [Select Id From Xero_Settings__c];
       
        // StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        // mock.setStaticResource('XeroContactsMock');
        // mock.setStatusCode(200);
        // mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Test.setMock(HttpCalloutMock.class, mock);

        // QE360_Event__c eventTest = new QE360_Event__c();
        // eventTest.Name = 'test';
        // eventTest.Xero_Item_Id__c = '123';
        // eventTest.Xero_Event_Name__c = 'testss';
        // eventTest.GPE_Event__c = true;
        // eventTest.Xero_Account_Code__c = '819';
        // //eventTest.Apply_20_VAT_Tax__c = true;
        // Insert eventTest;

        // Lead lead = new Lead();
        // lead.Google_Analytics_ID__c = 'gaID';
        // lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        // lead.FirstName = 'testName';
        // lead.LastName = 'testName';
        // lead.Status = 'Interested';
        // lead.Source__c = 'call Virtuoso';
        // lead.Email = 'testemail@quintevents.com';
        // insert lead;

        // Database.LeadConvert lc = new database.LeadConvert();
        // lc.setLeadId(lead.id);
        // lc.setDoNotCreateOpportunity(true);
        // lc.setConvertedStatus('Converted');
        // Database.LeadConvertResult lcr = Database.convertLead(lc);
        // System.assert(lcr.isSuccess());

        // Lead testLead = [select Id, IsConverted, ConvertedAccountId,ConvertedContactId from Lead where Id = :lead.Id];
        // /*Account account = new Account();
        // account.Name = 'Test';
        // account.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        // insert account;
        // Contact contact = new Contact();
        // contact.LastName = 'test';
        // contact.accountId = account.Id;
        // insert contact;  */
        // Opportunity oppTest = new Opportunity();
        // oppTest.Name = 'oppName';
        // oppTest.AccountId = testLead.ConvertedAccountId;
        // oppTest.Event__c = eventTest.Id;
        // oppTest.StageName = 'Prospecting';
        // oppTest.CloseDate = System.today();
        // oppTest.Primary_Contact__c = testLead.ConvertedContactId;
        // oppTest.Contact_Site__c = 'quintevents.com';
        // oppTest.GPE_Online_Order__c = true;
        // oppTest.CurrencyIsoCode = 'USD';
        // insert oppTest;

        // Id pricebookId = Test.getStandardPricebookId();

        // Parent_Package__c parentPakg = new Parent_Package__c(Event__c = eventTest.Id, Name='Test Parent pkg');
        // insert parentPakg;
        // //Create your product
        // Product2 prod = new Product2(
        //      Name = 'Product X',
        //      ProductCode = 'Pro-X',
        //      isActive = true,
        //      Parent_Package__c = parentPakg.Id,
        //      Event__c = eventTest.Id
        // );
        // insert prod;
        
              
        // //Create your pricebook entry
        // PricebookEntry pbEntry = new PricebookEntry(
        //      Pricebook2Id = pricebookId,
        //      Product2Id = prod.Id,
        //      UnitPrice = 100.00,
        //      IsActive = true
        // );
        // insert pbEntry;
        
        
        // OpportunityLineItem oli = new OpportunityLineItem();
        // oli.OpportunityId = oppTest.Id;
        // oli.Quantity = 5;
        // oli.producttype__c ='F1 access code';
        // oli.PricebookEntryId = pbEntry.Id;
        // oli.TotalPrice = 10000; 
        // insert oli;
        
                
        // QE_Xero_FutureCallout.contactBody = '';
        // //QE_Xero_FutureCallout.responseBody = ''; 
        // //QE_Xero_FutureCallout.xeroInvoiceId = '';
        // //QE_Xero_FutureCallout.responseInvoiceBody = ''; 
        // //QE_Xero_FutureCallout.invoiceBodys = ''; 
        // //QE_Xero_FutureCallout.PaymentBodys = ''; 
        // //QE_Xero_FutureCallout.invoiceResponseBody = ''; 
        // //QE_Xero_FutureCallout.invoicePostBody = ''; 
        // QE_Xero_FutureCallout.createContactJson(oppTest.Id);
        // // Opportunity_Payment_Terms__c opt = new Opportunity_Payment_Terms__c();
        // // opt.Opportunity__c = oppTest.Id;
        // // opt.Payment_Due_Date__c = System.Today();
        // // opt.Amount__c = 150;
        // // opt.CurrencyIsoCode  = 'USD';
        // // insert opt;

        // Set<Id> obj = new Set<Id>();
        // // obj.add(opt.Id);
        // QE_Xero_FutureCallout.createMultipleInvoicJosn(obj,'axy',oppTest.Id,null,oppTest);
        // // QE_Xero_FutureCallout.createPaymentCallOutAfterInvoiceCreate(opt);
        // QE_Xero_FutureCallout.createPaymentJson(oli.Id);        
        // XeroContact con = new XeroContact();
        // con.ContactStatus = 'Sucess';
        // con.Name = 'ef';
        // con.FirstName = 'g';
        // con.LastName = 'fdg';
        // con.EmailAddress = 'test@gmail.com';
        // con.BankAccountDetails = '23r432';
        // con.SkypeUserName = 'd';
        // con.UpdatedDateUTC = 'a';
        // con.IsSupplier = true;
        // con.IsCustomer = true; 
        // con.DefaultCurrency = 'USD';
        // con.HasValidationErrors = true;
        // List<XeroContact.XeroAddress> xeroAddressList = new List<XeroContact.XeroAddress>();
        // XeroContact.XeroAddress xeroAddressObj = new XeroContact.XeroAddress();
        // xeroAddressObj.AddressType = 'df';
        // xeroAddressObj.AddressLine1 = 'df';
        // xeroAddressObj.AddressLine2 = 'df';
        // xeroAddressObj.AddressLine3 = 'df';
        // xeroAddressObj.AddressLine4 = 'df';
        // xeroAddressObj.City = 'df';
        // xeroAddressObj.Region = 'df';
        // xeroAddressObj.PostalCode = 'df';
        // xeroAddressObj.Country = 'df';
        // xeroAddressObj.AttentionTo = 'df';
        // xeroAddressList.add(xeroAddressObj);
        
        // List<XeroContact.XeroPhone> xeroPhoneList = new List<XeroContact.XeroPhone>();
        // XeroContact.XeroPhone xeroPhoneObj = new XeroContact.XeroPhone();
        // xeroPhoneObj.PhoneType = '4';
        // xeroPhoneObj.PhoneNumber = 'r';
        // xeroPhoneObj.PhoneAreaCode = 'r';
        // xeroPhoneObj.PhoneCountryCode = 'r';
        // xeroPhoneList.add(xeroPhoneObj);

        // List<XeroContact.XeroContactPerson> xeroContactpersonList = new List<XeroContact.XeroContactPerson>();
        // XeroContact.XeroContactPerson xeroContactPersonObj = new XeroContact.XeroContactPerson();
        // xeroContactPersonObj.FirstName = 'erf';
        // xeroContactPersonObj.LastName = 'ferf';
        // xeroContactPersonObj.EmailAddress = 'sfd';
        // xeroContactPersonObj.IncludeInEmails = true;
        // xeroContactpersonList.add(xeroContactPersonObj);

        // List<XeroContact.XeroAttachment> XeroAttachmentList = new List<XeroContact.XeroAttachment>();
        // XeroContact.XeroAttachment XeroAttachmentObj = new XeroContact.XeroAttachment();
        // XeroAttachmentObj.AttachmentID = 'f';
        // XeroAttachmentObj.FileName = 'd';
        // XeroAttachmentObj.Url = 'ded';
        // XeroAttachmentObj.MimeType = 'de';
        // XeroAttachmentObj.ContentLength = 1;
        // XeroAttachmentList.add(XeroAttachmentObj);

        // XeroContact.XeroBalance xeroBalanceObj = new XeroContact.XeroBalance();
    
        // XeroContact.AccountsPayable xeroAccPayObj = new XeroContact.AccountsPayable();
        // xeroAccPayObj.Overdue = 12.23;
        // xeroAccPayObj.Outstanding = 12.23;

        // XeroContact.AccountsReceivable xeroAccRecObj = new XeroContact.AccountsReceivable();
        // xeroAccRecObj.Overdue = 12.23;
        // xeroAccRecObj.Outstanding = 12.23;
        
        // List<XeroInvoice.LineItem> xeroLineList = new List<XeroInvoice.LineItem>();
        // XeroInvoice.LineItem xeroLineObj = new XeroInvoice.LineItem();
        // xeroLineObj.ItemCode = 'f';
        // xeroLineObj.Description = '4';
        // xeroLineObj.UnitAmount = 5;
        // xeroLineObj.TaxType = 'df';
        // xeroLineObj.TaxAmount = 34;
        // xeroLineObj.LineAmount = 43;
        // xeroLineObj.AccountCode = 'dfg';
        // xeroLineObj.Quantity = 4;
        // xeroLineObj.LineItemID = 'erf';
        // xeroLineList.add(xeroLineObj);
        
        // XeroInvoice inv = new XeroInvoice();
        // inv.Type = 'Sucess';
        // inv.InvoiceID = 'ef';
        // inv.InvoiceNumber = 'g';
        // inv.Reference = 'fdg';
        // inv.AmountDue = 1;
        // inv.AmountPaid = 2;
        // inv.SentToContact = true;
        // inv.CurrencyRate = 12;
        // inv.HasErrors = true;
        // inv.IsDiscounted = true; 
        // inv.Date_x = 'USD';
        // inv.DueDate = 'USD';
        // inv.Status = 'USD';
        // inv.LineAmountTypes = 'USD';
        // inv.SubTotal = 3; 
        // inv.TotalTax = 4;
        // inv.Total = 5;
        // inv.UpdatedDateUTC = 'USD';
        // inv.CurrencyCode = 'USD';
        // inv.Contact = con ;
        // inv.xeroInvoiceFailureReason = 'Test';
        // inv.LineItems = xeroLineList;
        
        // XeroInvoice.cls_Bills invoiceBill = new XeroInvoice.cls_Bills();
        // invoiceBill.Day = 3;
        // invoiceBill.Type = 'def';

        // XeroPayment pay = new XeroPayment();
        // pay.PaymentID = 'Sucess';
        // pay.Dates = System.today();
        // pay.BankAmount = 2;
        // pay.Amount = 3;
        // pay.Reference = '1';
        // pay.CurrencyRate = 2;
        // pay.PaymentType = 'true';
        // pay.Status = '12';
        // pay.UpdatedDateUTC = 'true';
        // pay.HasAccount = true; 
        // pay.IsCustomer = true;
        // pay.xeroPaymentStatus = 'USD';
        // pay.xeroPaymentFailureReason = 'USD';
    
        // List<XeroPayment.xeroAccount> xeroAccountList = new List<XeroPayment.xeroAccount>();
        // XeroPayment.xeroAccount xeroAccountObj = new XeroPayment.xeroAccount();
        // xeroAccountObj.AccountID = 'er';
        // xeroAccountObj.Code = 'erf';
        // xeroAccountList.add(xeroAccountObj);

        // List<XeroPayment.xeroContact> xeroContactList = new List<XeroPayment.xeroContact>();
        // XeroPayment.xeroContact xeroContactObj = new XeroPayment.xeroContact();
        // xeroContactObj.ContactID = 'erf';
        // xeroContactObj.Name = 'erf';
        // xeroContactList.add(xeroContactObj);
        
        // List<XeroPayment.XeroInvoice> XeroInvoiceList = new List<XeroPayment.XeroInvoice>();
        // XeroPayment.XeroInvoice XeroInvoiceObj = new XeroPayment.XeroInvoice();
        // XeroInvoiceObj.Type = 'erf';
        // XeroInvoiceObj.InvoiceID = 'erf';
        // XeroInvoiceObj.InvoiceNumber = 'erf';
        // XeroInvoiceObj.ContentLength = 234;
        // XeroInvoiceList.add(XeroInvoiceObj);        
        // Test.stopTest();
    }

    @isTest
    static void createContactsFail () {

        // // Set the Mock Class for the callout
        // Test.setMock(HttpCalloutMock.class, getStaticMock(500, 'XeroContactsMock'));

        // Test.startTest();

        // // Execute the callout
        // try {

        //     XeroContact createdContact = QE_Xero_FutureCallout.createContact('<Contact><Name>Test Contact</Name></Contact>');
        // } 
        // catch (Exception ex) {

        //     // Error expected, as failed callout raises an exception
        //     system.assert(
        //         String.valueOf(ex).contains('500'),
        //         'The 500 error code should be contained in the string.'
        //     );
        // }

        // Test.stopTest();
    }

    @isTest
    static void createInvoiceSuccess() {

        // // Set the Mock Class for the callout
        // Test.setMock(HttpCalloutMock.class, getStaticMock(200, 'XeroInvoicesMock'));

        // Test.startTest();

        // // Execute the callout
        
        // List<XeroInvoice> createdInvoice = QE_Xero_FutureCallout.createInvoice('<Invoice>BODY</Invoice>');
        // QE_Xero_FutureCallout.EmailInvoice('123');
        // Test.stopTest();

        // // Assert that a contact exists
        // system.assertNotEquals(
        //     null,
        //     createdInvoice,
        //     'There should be one invoice created from the callout'
        // );
    }

    @isTest
    static void createInvoiceFail() {

    //     // Set the Mock Class for the callout
    //     Test.setMock(HttpCalloutMock.class, getStaticMock(500, 'XeroInvoicesMock'));

    //     Test.startTest();

    //     // Execute the callout
    //     try {

    //         List<XeroInvoice> createdInvoice = QE_Xero_FutureCallout.createInvoice('<Invoice>BODY</Invoice>');
    //     } 
    //     catch (Exception ex) {

    //         // Error expected, as failed callout raises an exception
    //         system.assert(
    //             String.valueOf(ex).contains('500'),
    //             'The 500 error code should be contained in the string.'
    //         );
    //     }

    //     Test.stopTest();
    }

    @isTest
    static void getXeroSettingsError() {

        // // Delete the Xero Settings created
        // delete [Select Id From Xero_Settings__c];

        // // Assert no Xero Settings found in Utility
        // system.assertEquals(
        //     null,
        //     XeroCalloutUtility.xeroSettings.Id,
        //     'There should be no Xero Setting record found.'
        // );

    }

    private static void getStaticMock (Integer responseCode, String mockName) {

        // StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        // mock.setStaticResource(mockName);
        // mock.setStatusCode(responseCode);
        // mock.setHeader('Content-Type', 'application/json');

        // return mock;
    }
    
    // @testSetup
    // static void setupTestData () {

    //     // Create a test Xero Setting record
    //     insert new Xero_Settings__c(
    //         SetupOwnerId = Userinfo.getOrganizationId(),
    //         Consumer_Key__c = '123456789',
    //         Endpoint__c = 'https://api.xero-test.com?param1=value1&param2=value2/',
    //         Account_Code__c = '200',
    //         Branding_ThemeID__c = 'e8d74023-201f-4fb9-9a95-ca799cb4d87b',
    //         Tracking_Category_Id__c = '19bf1999-9af2-4c41-bde2-6799668ad126',
    //         CategoryName__c = 'Event'
    //     );

    // }
    
}
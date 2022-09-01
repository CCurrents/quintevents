/**
 * @File Name          : QE_TestClass.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 4:15:54 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
public class QE_TestClass {

    public static testMethod void test_PaymentProcess() {
        
        // Test Data
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
        Insert eventTest;
        
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Source__c = 'call Virtuoso';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
        Opportunity oppTest = new Opportunity(Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '100%',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,StageName = 'Prospecting',CloseDate = System.today(), Send_Payment_Email__c=true);
        insert oppTest;
        
        Pricebook2 pb22 = new Pricebook2(Name='testDIE');
        insert pb22;
        
        Product2 proPack = new Product2(Name='BXCD1', isActive=true, 
                                        Event__c = eventTest.Id,
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId());
        insert proPack ;
        Product2 proPro = new Product2(Name='BXCD2', isActive=true, 
                                       Event__c = eventTest.Id,
                                       A_La_Carte__c = true,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId());
        insert proPro;
        Product2 proHotel = new Product2(Name='BXCD3', isActive=true, 
                                       Event__c = eventTest.Id,
                                         A_La_Carte__c = true,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId());
        insert proHotel;
        Product2 proPack1 = new Product2(Name='BXCD4', isActive=true, 
                                        Event__c = eventTest.Id,
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId());
        insert proPack1 ;
        Product2 proPro2 = new Product2(Name='BXCD5', isActive=true, 
                                       Event__c = eventTest.Id,
                                       A_La_Carte__c = true,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId());
        insert proPro2;
        Product2 proHotel2 = new Product2(Name='BXCD6', isActive=true, 
                                       Event__c = eventTest.Id,
                                         A_La_Carte__c = true,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId());
        insert proHotel2;
        
        Package_Products__c packPro1 = new Package_Products__c(Package__c = proPack.Id, Products_and_Hotels__c = proPro.Id);
        insert packPro1;
        Package_Products__c packPro2 = new Package_Products__c(Package__c = proPack.Id, Products_and_Hotels__c = proHotel.Id);
        insert packPro2;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=proPack.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        PricebookEntry pbe3 =new PricebookEntry(unitprice=0.01,Product2Id=proPro.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe3;
        PricebookEntry pbe4 =new PricebookEntry(unitprice=0.01,Product2Id=proHotel.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe4;
        PricebookEntry pbe5 =new PricebookEntry(unitprice=0.01,Product2Id=proPro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe5;
        PricebookEntry pbe6 =new PricebookEntry(unitprice=0.01,Product2Id=proHotel2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe6;
        PricebookEntry pbe7 =new PricebookEntry(unitprice=0.01,Product2Id=proPack1.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe7;
        
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert OPplineitem2;
        OpportunityLineItem OPplineitem1 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe3.Id);
        insert OPplineitem1;
        OpportunityLineItem OPplineitem3 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe4.Id);
        insert OPplineitem3;
        OpportunityLineItem OPplineitem4 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe4.Id);
        insert OPplineitem4;
        
        // Testing Update/Delete of Hotel from Opportunity
        OpportunityLineItem opptPackage = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe4.Id);
        insert opptPackage;
        Opportunity_Product_Package_Hotel__c opptProdPackageHotel_1 = new Opportunity_Product_Package_Hotel__c (
            Quantity__c = 2,
            Opportunity__c = oppTest.Id,
            Package__c = proPack1.Id
        );
        insert opptProdPackageHotel_1;
        opptProdPackageHotel_1.Quantity__c = 1;
        update opptProdPackageHotel_1;
        delete opptProdPackageHotel_1;
        
        Quote quoteTest = new Quote(
            Name = 'test',
            Status='Draft - Approved', 
            Payment_Method__c = 'Credit Card',
            OpportunityId = oppTest.Id,
            Email = 'jpatel@quintevents.com',
            Payment_Terms__c = '100%',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert quoteTest;
        
        QuoteLineItem Quolineitem2 = new QuoteLineItem (Quantity=2, QuoteId=quoteTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert Quolineitem2;
        QuoteLineItem Quolineitem1 = new QuoteLineItem (Quantity=2, QuoteId=quoteTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe3.Id);
        insert Quolineitem1;
        
        /*** QE_Payments ***/

        /// QUOTE
        Quote testQuoteWithPaymentToken = [select id,Name,Status,Payment_Terms__c,Payment_Method__c,OpportunityId,Email,Pricebook2Id,Payment_Page_Access_Token__c from Quote where Id = :quoteTest.Id];

        PageReference page_Payment = Page.QE_Payments;
        Test.setCurrentPage(page_Payment);
        page_Payment.getParameters().put('id', String.valueOf(testQuoteWithPaymentToken.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuoteWithPaymentToken);
        QE_Payments qePayments = new QE_Payments(sc);
        
        // Methods
        qePayments.userAuthToken = testQuoteWithPaymentToken.Payment_Page_Access_Token__c;
        qePayments.selectedStripeCardId = 'newcard';
        qePayments.authenticateUser();
        qePayments.getExistingCardOptions();
        qePayments.confirmPaymentInfo();
        //controller_QE_Payments.getExistingCardOptions();
        //controller_QE_Payments.confirmPaymentInfo();

        /// ADDITIONAL SIGNEE
        QE360_Quote_Additional_Signee__c  testAdditionalSignee = new QE360_Quote_Additional_Signee__c(
            Amount__c = 10.00,
            Quote_Standard__c = testQuoteWithPaymentToken.Id,
            Email__c = 'jpatel@quintevents.com',
            Street_Address__c = '123 Test Harris Blvd',
            City__c = 'Charlotte',
            State__c = 'NC',
            Zip_Code__c = '28262',
            Country__c = 'US',
            Payment_Page_Access_Token__c = 'testtoken'
        );
        insert testAdditionalSignee;
        
        // Update quote payment terms to cover if else statements
        testQuoteWithPaymentToken.Payment_Terms__c = '1/2';
        update testQuoteWithPaymentToken;
        
        // Insert Payment terms
        // Opportunity_Payment_Terms__c testPaymentTerm = new Opportunity_Payment_Terms__c(
        //     Amount__c = 5.00,
        //     Opportunity__c = oppTest.Id,
        //     Payment_Term__c = '1/2'
        // );
        // insert testPaymentTerm;
        
        // Insert Additional signees   
        QE360_Quote_Additional_Signee__c testAdditionalSigneeWithPaymentToken = [select id,Amount__c,Email__c,Street_Address__c,City__c,State__c,Zip_Code__c,Country__c,Payment_Page_Access_Token__c from QE360_Quote_Additional_Signee__c where Id = :testAdditionalSignee.Id];

        PageReference page_Payment2 = Page.QE_Payments;
        Test.setCurrentPage(page_Payment2);
        page_Payment2.getParameters().put('id', String.valueOf(testQuoteWithPaymentToken.Id));
        page_Payment2.getParameters().put('asid', String.valueOf(testAdditionalSigneeWithPaymentToken.Id));
        ApexPages.StandardController sc2 = new ApexPages.StandardController(testQuoteWithPaymentToken);
        QE_Payments qePayments2 = new QE_Payments(sc2);

        // Methods
        qePayments2.userAuthToken = testAdditionalSigneeWithPaymentToken.Payment_Page_Access_Token__c;
        qePayments2.selectedStripeCardId = 'newcard';

        qePayments2.authenticateUser();
        qePayments2.getExistingCardOptions();
        qePayments2.confirmPaymentInfo();                
        
        /*** QE_EmailHelper ***/
        Test.startTest();
        
        quoteTest.Payment_Terms__c = '100%';
        quoteTest.Status = 'Signed - Approved';
        update quoteTest;
        
        Quote testQuoteWithPaymentToken2 = [select id,Name,Status,Payment_Terms__c,Payment_Method__c,OpportunityId,Email,Pricebook2Id,Payment_Page_Access_Token__c from Quote where Id = :quoteTest.Id];
        
        QE360_Stripe_Charge__c qeStripeChargePaymentTermsNot100 = new QE360_Stripe_Charge__c (Amount__c=10.00, Last4__c='4343', Quote__c=quoteTest.Id);
        insert qeStripeChargePaymentTermsNot100;        

        QE360_Stripe_Charge__c qeStripeChargePaymentTerms100 = new QE360_Stripe_Charge__c (Amount__c=10.00, Last4__c='4343', Quote__c=quoteTest.Id);
        insert qeStripeChargePaymentTerms100;

        List<Quote> testQuoteList = new List<Quote>();
        testQuoteList.add(testQuoteWithPaymentToken2);
        List<QE360_Stripe_Charge__c> testQeStripeChargeList = new List<QE360_Stripe_Charge__c>();
        testQeStripeChargeList.add(qeStripeChargePaymentTermsNot100);
        testQeStripeChargeList.add(qeStripeChargePaymentTerms100);
        Map<Id,Quote> oldMap = new Map<Id,Quote>(testQuoteList);
        QE_EmailHelper qeEmailHelper = new QE_EmailHelper();
        qeEmailHelper.sendPaymentTokenEmails(testQuoteList,oldMap);
        qeEmailHelper.sendPaymentConfirmationEmails(testQeStripeChargeList);
        
    }
    
    public static testMethod void test_QE_StripeListener() {
        Test.startTest();
        
        System.RestRequest req1 = new System.RestRequest();
        req1.requestBody = Blob.valueOf(QE_StripeEventTests.testData_ChargeFailed);
        RestContext.request = req1;
        RestContext.response = new System.RestResponse();
        QE_StripeListener.doPost();
        
        System.RestRequest req2 = new System.RestRequest();
        req2.requestBody = Blob.valueOf(QE_StripeEventTests.testData_ChargeRefunded);
        RestContext.request = req2;
        RestContext.response = new System.RestResponse();
        QE_StripeListener.doPost();
        
        System.RestRequest req4 = new System.RestRequest();
        req4.requestBody = Blob.valueOf(QE_StripeEventTests.testData_ChargeCaptured);
        RestContext.request = req4;
        RestContext.response = new System.RestResponse();
        QE_StripeListener.doPost();
        
        System.RestRequest req6 = new System.RestRequest();
        req6.requestBody = Blob.valueOf(QE_StripeEventTests.testData_ChargeUnknownEvent);
        RestContext.request = req6;
        RestContext.response = new System.RestResponse();
        QE_StripeListener.doPost();
        
        System.RestRequest req7 = new System.RestRequest();
        req7.requestBody = Blob.valueOf(QE_StripeEventTests.testData_Ping);
        RestContext.request = req7;
        RestContext.response = new System.RestResponse();
        QE_StripeListener.doPost();
        
        System.RestRequest req5 = new System.RestRequest();
        req5.requestBody = Blob.valueOf('');
        RestContext.request = req5;
        RestContext.response = new System.RestResponse();
        QE_StripeListener.doPost();

    }
    
    static testMethod void test_QE360StripeCustomerHelper() {
        QE360_Stripe_Customer__c testQeStripeCustomer = new QE360_Stripe_Customer__c(
            Email__c = 'jeetpatel24@quintevents.com',
            Stripe_Customer_Id__c = 'cus_2uDWpGJXnH0pyT'
        );
        insert testQeStripeCustomer;
        
        QE360_Stripe_Customer_Helper qe360StripeCustomerHelper = new QE360_Stripe_Customer_Helper();
        qe360StripeCustomerHelper.getStripeCustomer('jeetpatel24@quintevents.com', 'Test Patel');
        qe360StripeCustomerHelper.getStripeCustomer('jeetpatel@test.com', 'Test Patel');
        
        // Old methods
        QE360_Stripe_Customer_Helper stripeCustomerHelper = new QE360_Stripe_Customer_Helper();
        stripeCustomerHelper.getStripeCustomerJson(testQeStripeCustomer.Stripe_Customer_Id__c, 'sk_test_SurYJ8OlNJrWNofwIOroEGfp');
        stripeCustomerHelper.searchCustomerRaw(testQeStripeCustomer.Email__c);
        stripeCustomerHelper.getQEStripeCustomer(testQeStripeCustomer.Email__c);
    }
    
}
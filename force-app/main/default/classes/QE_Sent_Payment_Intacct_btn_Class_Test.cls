@isTest
public class QE_Sent_Payment_Intacct_btn_Class_Test {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }
    static testMethod void method1() {
        Test.startTest();

        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        Insert eventTest;

        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Interested';
        lead.Source__c = 'call Virtuoso';
        lead.Email = 'testemail@quintevents.com';
        insert lead;

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
        Account account = new Account();
        account.RecordTypeId = '012i00000015Y4x';
        account.Name = 'Test Account';
        account.CurrencyIsoCode = 'USD';
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Test Last Name';
        contact.AccountId = account.Id;
        contact.CurrencyIsoCode = 'USD';
        contact.Email = 'test@gmail.com';
        insert contact;


        Opportunity oppTest = new Opportunity();
        oppTest.Name = 'oppName';
        oppTest.AccountId = account.Id;
        oppTest.Event__c = eventTest.Id;
        oppTest.StageName = 'Prospecting';
        oppTest.CloseDate = System.today();
        oppTest.Primary_Contact__c = contact.Id;
        oppTest.Contact_Site__c = 'quintevents.com';
        oppTest.Pricebook2Id = Test.getStandardPricebookId();
        insert oppTest;
              

        Payment_term__c oppPayTermTest1 = new Payment_term__c(Status__c = 'Passed',Payment_Term__c = '1/2', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id);
        insert oppPayTermTest1;

        //DEFINING STANDARD CONTROLLER
        ApexPages.StandardController sc = new ApexPages.StandardController(oppPayTermTest1);
        Test.setCurrentPageReference(new PageReference('Page.QE_Sent_Payment_Intacct_btn_Page'));
        ApexPages.currentPage().getParameters().put('payId', oppPayTermTest1.id);
        QE_Sent_Payment_Intacct_btn_Class testQuoteRecord = new QE_Sent_Payment_Intacct_btn_Class(sc);

        testQuoteRecord.closePopup();
        testQuoteRecord.displayMsg='Error';
        testQuoteRecord.displayPopup = true;
        testQuoteRecord.payRec = oppPayTermTest1;
        Intacct_API_Details__c Intacct = new Intacct_API_Details__c();
        Intacct.CompanyId__c = 'test';
        Intacct.EndpointURL__c = 'test';
        Intacct.Active__c = true;
        Intacct.Production__c = true;
        insert Intacct;

        testQuoteRecord.RedirectMethod();

        /*oppPayTermTest1.Status__c = 'Passed';
        update oppPayTermTest1;
        Test.setCurrentPageReference(new PageReference('Page.QE_Sent_Payment_Intacct_btn_Page'));
        ApexPages.currentPage().getParameters().put('payId', oppPayTermTest1.id);
        QE_Sent_Payment_Intacct_btn_Class testQuoteRecord2 = new QE_Sent_Payment_Intacct_btn_Class(sc);
        testQuoteRecord2.RedirectMethod();

        oppPayTermTest1.Status__c = 'Passed';
        oppPayTermTest1.Intacct_Status__c = 'Success';
        update oppPayTermTest1;
        Test.setCurrentPageReference(new PageReference('Page.QE_Sent_Payment_Intacct_btn_Page'));
        ApexPages.currentPage().getParameters().put('payId', oppPayTermTest1.id);
        QE_Sent_Payment_Intacct_btn_Class testQuoteRecord3 = new QE_Sent_Payment_Intacct_btn_Class(sc);
        testQuoteRecord3.RedirectMethod();*/

        Test.stopTest();
    }
    
    
    static testMethod void method2() {
        Test.startTest();

        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        Insert eventTest;

        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Interested';
        lead.Source__c = 'call Virtuoso';
        lead.Email = 'testemail@quintevents.com';
        insert lead;

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
        Account account = new Account();
        account.RecordTypeId = '012i00000015Y4x';
        account.Name = 'Test Account';
        account.CurrencyIsoCode = 'USD';
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Test Last Name';
        contact.AccountId = account.Id;
        contact.CurrencyIsoCode = 'USD';
        contact.Email = 'test@gmail.com';
        insert contact;


        Opportunity oppTest = new Opportunity();
        oppTest.Name = 'oppName';
        oppTest.AccountId = account.Id;
        oppTest.Event__c = eventTest.Id;
        oppTest.StageName = 'Prospecting';
        oppTest.CloseDate = System.today();
        oppTest.Primary_Contact__c = contact.Id;
        oppTest.Contact_Site__c = 'quintevents.com';
        oppTest.Pricebook2Id = Test.getStandardPricebookId();
        insert oppTest;
              

        Payment_term__c oppPayTermTest1 = new Payment_term__c(Intacct_Status__c = 'Success',Payment_Term__c = '1/2', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id);
        insert oppPayTermTest1;

        //DEFINING STANDARD CONTROLLER
        ApexPages.StandardController sc = new ApexPages.StandardController(oppPayTermTest1);
        Test.setCurrentPageReference(new PageReference('Page.QE_Sent_Payment_Intacct_btn_Page'));
        ApexPages.currentPage().getParameters().put('payId', oppPayTermTest1.id);
        QE_Sent_Payment_Intacct_btn_Class testQuoteRecord = new QE_Sent_Payment_Intacct_btn_Class(sc);

        testQuoteRecord.closePopup();
        testQuoteRecord.displayMsg='Error';
        testQuoteRecord.displayPopup = true;
        testQuoteRecord.payRec = oppPayTermTest1;
        Intacct_API_Details__c Intacct = new Intacct_API_Details__c();
        Intacct.CompanyId__c = 'test';
        Intacct.EndpointURL__c = 'test';
        Intacct.Active__c = true;
        Intacct.Production__c = true;
        insert Intacct;

        testQuoteRecord.RedirectMethod();

        Test.stopTest();
    }
}
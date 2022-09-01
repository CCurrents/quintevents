/**
 * @File Name          : QE_Opportunity_Inline_Test.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : Lovel Panchal
 * @Last Modified On   : 5/11/2020, 9:44:57 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest(seeAllData=false)
public class QE_Opportunity_Inline_Test {
    @isTest
    public static void init(){
        
    }
    
    //  @isTest static void test_method_one1234() {
    //     QE_Opportunity_Inline objCtrl = new QE_Opportunity_Inline(new Opportunity());
    //     List<SelectOption> payTerm = objCtrl.payTerm;
    //     String selectedPayTerm = objCtrl.selectedPayTerm;
    //     Opportunity currentRecord = objCtrl.currentRecord;
    //     List<Event_Payment_Terms__c> eventPayTermsList = objCtrl.eventPayTermsList;
    //     boolean showChPay = objCtrl.showChPay;
    //     boolean desableRadio  = objCtrl.desableRadio;
    //     boolean saveBtn  = objCtrl.saveBtn;
    //     boolean errorflag = objCtrl.errorflag;
    //     Integer numOfCustomTerms  = objCtrl.numOfCustomTerms;
    //     Id chosenPaymentTermIdForDelete  = objCtrl.chosenPaymentTermIdForDelete;
    //     Integer chosenPaymentTermRowForDelete  = objCtrl.chosenPaymentTermRowForDelete;
    //     objCtrl.paymentList();
    //     objCtrl.saveCustomOpptTerms();
    //     objCtrl.delOpportuntiyCustomTerm();
    //     objCtrl.delOpportuntiyCustomTermRow();
    //     objCtrl.savePaymentTerm();
    //     objCtrl.cangePaymentTerm();
    //     objCtrl.populateIntacctRecordURLs();
    //     objCtrl.getIntcctData(null,null,null,null);
    //     objCtrl.SendHttpRequest(null,null,null,null);
    //  }

    // @isTest static void test_method_one() {
    //     Test.startTest();
    //     init();
    //     QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1, Start_Date__c = System.today().Adddays(-10));
    //     Insert eventTest;
        
    //     Event_Payment_Terms__c evePayTermTest = new Event_Payment_Terms__c(Payment_Term__c = '100%',Event__c = eventTest.Id);
    //     insert evePayTermTest;
    //     Event_Payment_Terms__c evePayTermTest1 = new Event_Payment_Terms__c(Payment_Term__c = '1/2', Start_Date__c=Date.today(), End_Date__c=Date.today(), Event__c = eventTest.Id);
    //     insert evePayTermTest1;
    //     Event_Payment_Terms__c evePayTermTest2 = new Event_Payment_Terms__c(Payment_Term__c = '1/3', Start_Date__c=Date.today(), End_Date__c=Date.today(), Event__c = eventTest.Id);
    //     insert evePayTermTest2;
    //     Event_Payment_Terms__c evePayTermTest3 = new Event_Payment_Terms__c(Payment_Term__c = 'Custom', Start_Date__c=Date.today(), End_Date__c=Date.today(), Event__c = eventTest.Id);
    //     insert evePayTermTest3;
        
    //     //Account accTest = new Account(Name = 'testAccount');
    //     //insert accTest;
        
    //     Lead lead = new Lead();
    //     lead.Google_Analytics_ID__c = 'gaID';
    //     lead.Google_Analytics_Site_Id__c = 'gaSiteId';
    //     lead.IsConverted = false;
    //     lead.FirstName = 'testName';
    //     lead.LastName = 'testName';
    //     lead.Source__c = 'call Virtuoso';
    //     lead.Email = 'test@quinteventstesttest.com';
    //     insert lead;
        
    //     Database.LeadConvert lc = new database.LeadConvert();
    //     lc.setLeadId(lead.id);
    //     lc.setDoNotCreateOpportunity(true);
    //     lc.setConvertedStatus('Converted');
    //     Database.LeadConvertResult lcr = Database.convertLead(lc);
    //     System.assert(lcr.isSuccess());
        
    //     Lead convertedLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
    //     Account acct = new Account();
    //     acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
    //     acct.Name = 'Test Account';
    //     acct.CurrencyIsoCode = 'USD';
    //     insert acct;
        
    //     Contact conn = new Contact();
    //     conn.LastName = 'Test Last Name';
    //     conn.AccountId = acct.Id;
    //     conn.CurrencyIsoCode = 'USD';
    //     conn.Email = 'test@gmail.com';
    //     insert conn;
        
    //     Opportunity oppTest = new Opportunity(Name = 'oppName',Amount=1000,Contact_Site__c='quintevents.com',Payment_Terms__c= '1/2',AccountId = acct.Id,Event__c = eventTest.Id,StageName = 'Prospecting',CloseDate = System.today(), Primary_contact__c = conn.Id);
    //     oppTest.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
    //     insert oppTest;
        
    //     // Opportunity_Payment_Terms__c oppPayTermTest = new Opportunity_Payment_Terms__c(Payment_Term__c = '100%', Amount__c=100,Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id);
    //     // insert oppPayTermTest;
    //     // Opportunity_Payment_Terms__c oppPayTermTest1 = new Opportunity_Payment_Terms__c(Payment_Term__c = '1/2', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id);
    //     // insert oppPayTermTest1;
    //     // Opportunity_Payment_Terms__c oppPayTermTest2 = new Opportunity_Payment_Terms__c(Payment_Term__c = '1/3', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id);
    //     // insert oppPayTermTest2;
    //     // Opportunity_Payment_Terms__c oppPayTermTest3 = new Opportunity_Payment_Terms__c(Payment_Term__c = 'Custom', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id);
    //     // insert oppPayTermTest3;
    //     // Opportunity_Payment_Terms__c oppPayTermTest4 = new Opportunity_Payment_Terms__c(Payment_Term__c = 'Custom Terms', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id);
    //     // insert oppPayTermTest4;
    //     // Opportunity_Payment_Terms__c oppPayTermTest5 = new Opportunity_Payment_Terms__c(Payment_Term__c = 'Net 30', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id);
    //     // insert oppPayTermTest5;
        
    //     ApexPages.StandardController stdEvent = new ApexPages.StandardController(oppTest);
    //     ApexPages.currentPage().getParameters().put('id',oppTest.id);
    //     QE_Opportunity_Inline QEClass = new QE_Opportunity_Inline(stdEvent);
        
                
    //     QEClass.selectedPayTerm = '100%';
    //     QEClass.paymentList();
    //     QEClass.savePaymentTerm();
        
    //     QEClass.selectedPayTerm = '1/2';
    //     QEClass.paymentList();
    //     QEClass.cangePaymentTerm();
    //     QEClass.savePaymentTerm();
        
    //     QEClass.selectedPayTerm = '1/3';
    //     QEClass.paymentList();
    //     QEClass.savePaymentTerm();
        
    //     QEClass.selectedPayTerm = 'Custom';
    //     QEClass.paymentList();
    //     QEClass.savePaymentTerm();
    //     QEClass.saveCustomOpptTerms();
        
    //     QEClass.chosenPaymentTermIdForDelete = oppTest.id;
    //     QEClass.chosenPaymentTermRowForDelete= 1;
    //     //QEClass.delOpportuntiyCustomTermRow(); 
    //     //QEClass.delOpportuntiyCustomTerm(); 
        
    //     ApexPages.StandardController sc = new ApexPages.StandardController(oppTest);
    //     QE_Add_Packages_and_Products_btn_Class obj_Packages_Products=new QE_Add_Packages_and_Products_btn_Class(sc);
    //     obj_Packages_Products.closePopup();
    //     obj_Packages_Products.RedirectMethod();
        
    //     Test.stopTest();
    // }
    
    // @isTest static void test_method_two() {
    //     Test.startTest();
    //     init();
    //     QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1, Start_Date__c = System.today().Adddays(-10), Last_Payment_Due_Date__c = system.today().adddays(5));
    //     Insert eventTest;
        
    //     Event_Payment_Terms__c evePayTermTest = new Event_Payment_Terms__c(Payment_Term__c = '100%',Event__c = eventTest.Id);
    //     insert evePayTermTest;
    //     Event_Payment_Terms__c evePayTermTest1 = new Event_Payment_Terms__c(Payment_Term__c = '1/2', Start_Date__c=Date.today(), End_Date__c=Date.today(), Event__c = eventTest.Id);
    //     insert evePayTermTest1;
    //     Event_Payment_Terms__c evePayTermTest2 = new Event_Payment_Terms__c(Payment_Term__c = '1/3', Start_Date__c=Date.today(), End_Date__c=Date.today(), Event__c = eventTest.Id);
    //     insert evePayTermTest2;
    //     Event_Payment_Terms__c evePayTermTest3 = new Event_Payment_Terms__c(Payment_Term__c = 'Custom', Start_Date__c=Date.today(), End_Date__c=Date.today(), Event__c = eventTest.Id);
    //     insert evePayTermTest3;
        
    //     //Account accTest = new Account(Name = 'testAccount');
    //     //insert accTest;
        
    //     Lead lead = new Lead();
    //     lead.Google_Analytics_ID__c = 'gaID';
    //     lead.Google_Analytics_Site_Id__c = 'gaSiteId';
    //     lead.IsConverted = false;
    //     lead.FirstName = 'testName';
    //     lead.LastName = 'testName';
    //     lead.Source__c = 'call Virtuoso';
    //     lead.Email = 'test@quinteventstesttest.com';
    //     insert lead;
        
    //     Database.LeadConvert lc = new database.LeadConvert();
    //     lc.setLeadId(lead.id);
    //     lc.setDoNotCreateOpportunity(true);
    //     lc.setConvertedStatus('Converted');
    //     Database.LeadConvertResult lcr = Database.convertLead(lc);
    //     System.assert(lcr.isSuccess());
        
    //     Lead convertedLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
    //     Account acct = new Account();
    //     acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
    //     acct.Name = 'Test Account';
    //     acct.CurrencyIsoCode = 'USD';
    //     insert acct;
        
    //     Contact conn = new Contact();
    //     conn.LastName = 'Test Last Name';
    //     conn.AccountId = acct.Id;
    //     conn.CurrencyIsoCode = 'USD';
    //     conn.Email = 'test@gmail.com';
    //     insert conn;
        
    //     Opportunity oppTest = new Opportunity(Name = 'oppName',Amount=1000,Contact_Site__c='quintevents.com',Payment_Terms__c= 'Custom Terms',AccountId = acct.Id,Event__c = eventTest.Id,StageName = 'Prospecting',CloseDate = System.today(), Primary_contact__c = conn.Id);
    //     oppTest.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
    //     insert oppTest;
        
    //     // Opportunity_Payment_Terms__c oppPayTermTest = new Opportunity_Payment_Terms__c(Payment_Term__c = '100%', Amount__c=100,Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id);
    //     // insert oppPayTermTest;
    //     // Opportunity_Payment_Terms__c oppPayTermTest1 = new Opportunity_Payment_Terms__c(Payment_Term__c = '1/2', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id);
    //     // insert oppPayTermTest1;
    //     // Opportunity_Payment_Terms__c oppPayTermTest2 = new Opportunity_Payment_Terms__c(Payment_Term__c = '1/3', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id);
    //     // insert oppPayTermTest2;
    //     // Opportunity_Payment_Terms__c oppPayTermTest3 = new Opportunity_Payment_Terms__c(Payment_Term__c = 'Custom', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id);
    //     // insert oppPayTermTest3;
        
    //     ApexPages.StandardController stdEvent = new ApexPages.StandardController(oppTest);
    //     ApexPages.currentPage().getParameters().put('id',oppTest.id);
    //     QE_Opportunity_Inline QEClass = new QE_Opportunity_Inline(stdEvent);
    //     // QEClass.chosenPaymentTermIdForDelete = oppPayTermTest3.id;
    //     QEClass.chosenPaymentTermRowForDelete= 1;
    //     QEClass.delOpportuntiyCustomTermRow(); 
    //     QEClass.delOpportuntiyCustomTerm(); 
        
    //     QEClass.selectedPayTerm = 'Net 30';
    //     QEClass.paymentList();
    //     QEClass.savePaymentTerm();
    //     QEClass.saveCustomOpptTerms();
        
    //     QEClass.selectedPayTerm = 'Custom Terms';
    //     QEClass.numOfCustomTerms = 1;
    //     QEClass.paymentList();
    //     QEClass.savePaymentTerm();
    //     QEClass.saveCustomOpptTerms();
        
    //     ApexPages.StandardController sc = new ApexPages.StandardController(oppTest);
    //     QE_Add_Packages_and_Products_btn_Class obj_Packages_Products=new QE_Add_Packages_and_Products_btn_Class(sc);
    //     obj_Packages_Products.closePopup();
    //     obj_Packages_Products.RedirectMethod();
        
    //     Test.stopTest();
    // }
    
    // @isTest static void test_method_three() {
    //     Test.startTest();
    //     init();
    //     QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1,Start_Date__c = system.today().Adddays(10));
    //     Insert eventTest;
        
    //     Event_Payment_Terms__c evePayTermTest = new Event_Payment_Terms__c(Payment_Term__c = '100%',Event__c = eventTest.Id);
    //     insert evePayTermTest;
    //     Event_Payment_Terms__c evePayTermTest1 = new Event_Payment_Terms__c(Payment_Term__c = '1/2', Start_Date__c=Date.today(), End_Date__c=Date.today(), Event__c = eventTest.Id);
    //     insert evePayTermTest1;
    //     Event_Payment_Terms__c evePayTermTest2 = new Event_Payment_Terms__c(Payment_Term__c = '1/3', Start_Date__c=Date.today(), End_Date__c=Date.today(), Event__c = eventTest.Id);
    //     insert evePayTermTest2;
    //     Event_Payment_Terms__c evePayTermTest3 = new Event_Payment_Terms__c(Payment_Term__c = 'Custom', Start_Date__c=Date.today(), End_Date__c=Date.today(), Event__c = eventTest.Id);
    //     insert evePayTermTest3;
        
    //     //Account accTest = new Account(Name = 'testAccount');
    //     //insert accTest;
        
    //     Lead lead = new Lead();
    //     lead.Google_Analytics_ID__c = 'gaID';
    //     lead.Google_Analytics_Site_Id__c = 'gaSiteId';
    //     lead.IsConverted = false;
    //     lead.FirstName = 'testName';
    //     lead.LastName = 'testName';
    //     lead.Source__c = 'call Virtuoso';
    //     lead.Email = 'test@quinteventstesttest.com';
    //     insert lead;
        
    //     Database.LeadConvert lc = new database.LeadConvert();
    //     lc.setLeadId(lead.id);
    //     lc.setDoNotCreateOpportunity(true);
    //     lc.setConvertedStatus('Converted');
    //     Database.LeadConvertResult lcr = Database.convertLead(lc);
    //     System.assert(lcr.isSuccess());
        
    //     Lead convertedLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
    //     Account acct = new Account();
    //     acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
    //     acct.Name = 'Test Account';
    //     acct.CurrencyIsoCode = 'USD';
    //     insert acct;
        
    //     Contact conn = new Contact();
    //     conn.LastName = 'Test Last Name';
    //     conn.AccountId = acct.Id;
    //     conn.CurrencyIsoCode = 'USD';
    //     conn.Email = 'test@gmail.com';
    //     insert conn;
        
    //     Opportunity oppTest = new Opportunity(Name = 'oppName',Amount=1000,Contact_Site__c='quintevents.com',Payment_Terms__c= '1/2',AccountId = acct.Id,Event__c = eventTest.Id,StageName = 'Prospecting',CloseDate = System.today(), Primary_contact__c = conn.Id);
    //     oppTest.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
    //     oppTest.Intacct_Status__c = 'Success';
    //     oppTest.Sandbox_Intacct_Id__c = 'INV26148';
    //     insert oppTest;
        
    //     // Opportunity_Payment_Terms__c oppPayTermTest = new Opportunity_Payment_Terms__c(Payment_Term__c = '100%', Amount__c=100,Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id,Sandbox_Intacct_Id__c='INV26148');
    //     // insert oppPayTermTest;
    //     // Opportunity_Payment_Terms__c oppPayTermTest1 = new Opportunity_Payment_Terms__c(Payment_Term__c = '1/2', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id,Sandbox_Intacct_Id__c='INV26148');
    //     // insert oppPayTermTest1;
    //     // Opportunity_Payment_Terms__c oppPayTermTest2 = new Opportunity_Payment_Terms__c(Payment_Term__c = '1/3', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id,Sandbox_Intacct_Id__c='INV26148');
    //     // insert oppPayTermTest2;
    //     // Opportunity_Payment_Terms__c oppPayTermTest3 = new Opportunity_Payment_Terms__c(Payment_Term__c = 'Custom', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id,Sandbox_Intacct_Id__c='INV26148');
    //     // insert oppPayTermTest3;
        
        
    //     Intacct_API_Details__c Intacct = new Intacct_API_Details__c();
    //     Intacct.Sandbox_CompanyId__c = 'test';
    //     Intacct.Sandbox_EndpointURL__c = 'test';
    //     Intacct.Sandbox_Password__c = 'test';
    //     Intacct.Sandbox_SenderId__c = 'test';
    //     Intacct.Sandbox_SenderPassword__c = 'test';
    //     Intacct.Sandbox_UserName__c = 'test';
    //     Intacct.Production__c = false;
    //     insert Intacct;
        
    //     Account acc = new account(Id=convertedLead.ConvertedAccountId);
    //     acc.Sandbox_Record_Id__c = '1082';
    //     update acc;
        
    //     ApexPages.StandardController stdEvent = new ApexPages.StandardController(oppTest);
    //     ApexPages.currentPage().getParameters().put('id',oppTest.id);
    //     QE_Opportunity_Inline QEClass = new QE_Opportunity_Inline(stdEvent);
        
    //     ApexPages.currentPage().getParameters().put('id',oppTest.id);
    //     QEClass.populateIntacctRecordURLs();
        
    //     Test.stopTest();
    // }
    
    // @isTest static void test_method_four() {
        
    //     Test.startTest();
    //     init();
    //     QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1, Start_Date__c = System.today().Adddays(-10));
    //     Insert eventTest;
        
    //     Event_Payment_Terms__c evePayTermTest = new Event_Payment_Terms__c(Payment_Term__c = '100%',Event__c = eventTest.Id);
    //     insert evePayTermTest;
    //     Event_Payment_Terms__c evePayTermTest1 = new Event_Payment_Terms__c(Payment_Term__c = '1/2', Start_Date__c=Date.today(), End_Date__c=Date.today(), Event__c = eventTest.Id);
    //     insert evePayTermTest1;
    //     Event_Payment_Terms__c evePayTermTest2 = new Event_Payment_Terms__c(Payment_Term__c = '1/3', Start_Date__c=Date.today(), End_Date__c=Date.today(), Event__c = eventTest.Id);
    //     insert evePayTermTest2;
    //     Event_Payment_Terms__c evePayTermTest3 = new Event_Payment_Terms__c(Payment_Term__c = 'Custom', Start_Date__c=Date.today(), End_Date__c=Date.today(), Event__c = eventTest.Id);
    //     insert evePayTermTest3;
        
    //     //Account accTest = new Account(Name = 'testAccount');
    //     //insert accTest;
        
    //     Lead lead = new Lead();
    //     lead.Google_Analytics_ID__c = 'gaID';
    //     lead.Google_Analytics_Site_Id__c = 'gaSiteId';
    //     lead.IsConverted = false;
    //     lead.FirstName = 'testName';
    //     lead.LastName = 'testName';
    //     lead.Source__c = 'call Virtuoso';
    //     lead.Email = 'test@quinteventstesttest.com';
    //     insert lead;
        
    //     Database.LeadConvert lc = new database.LeadConvert();
    //     lc.setLeadId(lead.id);
    //     lc.setDoNotCreateOpportunity(true);
    //     lc.setConvertedStatus('Converted');
    //     Database.LeadConvertResult lcr = Database.convertLead(lc);
    //     System.assert(lcr.isSuccess());
        
    //     Lead convertedLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
    //     List<RecordType> lstrec = [Select id from recordtype where sobjecttype = 'opportunity' and developername='Business_Opportunity' limit 1];
        
    //     Account acct = new Account();
    //     acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
    //     acct.Name = 'Test Account';
    //     acct.CurrencyIsoCode = 'USD';
    //     insert acct;
        
    //     Contact conn = new Contact();
    //     conn.LastName = 'Test Last Name';
    //     conn.AccountId = acct.Id;
    //     conn.CurrencyIsoCode = 'USD';
    //     conn.Email = 'test@gmail.com';
    //     insert conn;
        
    //     Opportunity oppTest = new Opportunity(Name = 'oppName',Amount=1000,Contact_Site__c='quintevents.com',Payment_Terms__c= '1/2',AccountId = acct.Id,Event__c = eventTest.Id,StageName = 'Prospecting',CloseDate = System.today(), Primary_contact__c = conn.Id);
    //     insert oppTest;
        
        
    //     // Opportunity_Payment_Terms__c oppPayTermTest = new Opportunity_Payment_Terms__c(Payment_Term__c = '100%', Amount__c=100,Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id,Intacct_Id__c='INV26148');
    //     // insert oppPayTermTest;
    //     // Opportunity_Payment_Terms__c oppPayTermTest1 = new Opportunity_Payment_Terms__c(Payment_Term__c = '1/2', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id,Intacct_Id__c='INV26148');
    //     // insert oppPayTermTest1;
    //     // Opportunity_Payment_Terms__c oppPayTermTest2 = new Opportunity_Payment_Terms__c(Payment_Term__c = '1/3', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id,Intacct_Id__c='INV26148');
    //     // insert oppPayTermTest2;
    //     // Opportunity_Payment_Terms__c oppPayTermTest3 = new Opportunity_Payment_Terms__c(Payment_Term__c = 'Custom', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id,Intacct_Id__c='INV26148');
    //     // insert oppPayTermTest3;
        
        
    //     Intacct_API_Details__c Intacct = new Intacct_API_Details__c();
    //     Intacct.CompanyId__c = 'test';
    //     Intacct.EndpointURL__c = 'test';
    //     Intacct.Password__c = 'test';
    //     Intacct.SenderId__c = 'test';
    //     Intacct.SenderPassword__c = 'test';
    //     Intacct.UserName__c = 'test';
    //     Intacct.Production__c = true;
    //     insert Intacct;
        
    //     Account acc = new account(Id=convertedLead.ConvertedAccountId);
    //     acc.Record_Id__c = '1082';
    //     update acc;
        
    //     ApexPages.StandardController stdEvent = new ApexPages.StandardController(oppTest);
    //     ApexPages.currentPage().getParameters().put('id',oppTest.id);
    //     QE_Opportunity_Inline QEClass = new QE_Opportunity_Inline(stdEvent);       
    //     QEClass.populateIntacctRecordURLs();
        
    //     Test.stopTest();
    // }
}
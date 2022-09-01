/**
 * @File Name          : QE_OpportunityPaymentTermsHelper_Test.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 3:34:06 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
public class QE_OpportunityPaymentTermsHelper_Test {

    static testMethod void method1() {
        Program__c program = new Program__c();
        program.Name = 'test prgram F1E';
        insert program;

        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        eventTest.start_date__C = system.today();
        eventTest.End_date__C = System.today();
        eventTest.GPE_Event__c = true;
        Insert eventTest;

        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = eventTest.Id;
        insert parentPackage;

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
        Test.startTest();
        Opportunity oppTest = new Opportunity();
        oppTest.RecordTypeId = '012i00000012AaS';
        oppTest.AccountId = account.Id;
        oppTest.Name = 'Test oppTest';
        oppTest.StageName = 'Closed Won';
        oppTest.Probability =  10;
        oppTest.Payment_Method__c ='Check';
        oppTest.Event__c = eventTest.Id;
        oppTest.CloseDate = System.today();
        oppTest.Contact_Site__c = 'barrettjacksonvip.com';
        oppTest.CurrencyIsoCode = 'USD';
        oppTest.Primary_Contact__c = contact.Id;
        oppTest.Email__c = 'test@gmail.com';
        oppTest.Phone__c = '1234567896';
        oppTest.is_Applied_Rewards__c = true;
        oppTest.Amount = 125;
        
        insert oppTest;
        
        Pricebook2 pb22 = new Pricebook2(Name='testDIE');
        insert pb22;
        
        Product2 proPack = new Product2(Name='BXCD11', isActive=true, 
                                        Event__c = eventTest.Id,
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId(), Parent_Package__c=parentPackage.Id);
        insert proPack ;
        Product2 proPro = new Product2(Name='BXCD22', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1,Type__c = 'ticket');
        insert proPro;
        Product2 proPro2 = new Product2(Name='BXCD33', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1,Type__c = 'Giftbag');
        insert proPro2;
        Product2 proHotel = new Product2(Name='BXCD44', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        insert proHotel;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=proPack.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        //insert OPplineitem2;
        
        Id RecordTypeIdOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Person Opportunity').getRecordTypeId();

    //     Opportunity_Payment_Terms__c oppPayTermTest1 = new Opportunity_Payment_Terms__c(Payment_Term__c = '1/2', Amount__c=100, Percentage_Of_Payment__c=5, Opportunity__c = oppTest.Id,Status__c ='Passed',Requested_Due_Date__c=System.today(),Xero_Invoice_ID__c = 'test');
    //     insert oppPayTermTest1;
    //     oppPayTermTest1.Requested_Due_Date__c = System.today().addDays(1);
    //    // oppPayTermTest1.Payment_Due_Date__c = System.today().addDays(5);
    //     update oppPayTermTest1;
        //OPplineitem2.Quantity = 1;
        //update OPplineitem2;
        
        Set<Id> opptIds = new Set<Id>();
        opptIds.add(oppTest.Id);
        QE_OpportunityPaymentTermsHelper oppPaymentTerm = new QE_OpportunityPaymentTermsHelper();
        oppPaymentTerm.updateOpptPaymentTerms(opptIds);
        // oppPaymentTerm.captureDeletedOpportunityPaymentTerms(new List<Opportunity_Payment_Terms__c>{oppPayTermTest1});
        
        //Delete oppPayTermTest1;
        
        Test.stopTest();
    }
    
    
    static testMethod void method2() {
        Program__c program = new Program__c();
        program.Name = 'test prgram F1E';
        insert program;

        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        eventTest.start_date__C = system.today();
        eventTest.End_date__C = System.today();
        eventTest.GPE_Event__c = true;
        Insert eventTest;

        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = eventTest.Id;
        insert parentPackage;

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
        Test.startTest();
        Opportunity oppTest = new Opportunity();
        oppTest.RecordTypeId = '012i00000012AaS';
        oppTest.AccountId = account.Id;
        oppTest.Name = 'Test oppTest';
        oppTest.StageName = 'Qualified';
        oppTest.Probability =  10;
        oppTest.Payment_Method__c ='Check';
        oppTest.Event__c = eventTest.Id;
        oppTest.CloseDate = System.today();
        oppTest.Contact_Site__c = 'barrettjacksonvip.com';
        oppTest.CurrencyIsoCode = 'USD';
        oppTest.Primary_Contact__c = contact.Id;
        oppTest.Email__c = 'test@gmail.com';
        oppTest.Phone__c = '1234567896';
        oppTest.is_Applied_Rewards__c = true;
        insert oppTest;
        
        Pricebook2 pb22 = new Pricebook2(Name='testDIE');
        insert pb22;
        
        Product2 proPack = new Product2(Name='BXCD11', isActive=true, 
                                        Event__c = eventTest.Id,
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId(), Parent_Package__c=parentPackage.Id);
        insert proPack ;
        Product2 proPro = new Product2(Name='BXCD22', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1,Type__c = 'ticket');
        insert proPro;
        Product2 proPro2 = new Product2(Name='BXCD33', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1,Type__c = 'Giftbag');
        insert proPro2;
        Product2 proHotel = new Product2(Name='BXCD44', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        insert proHotel;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=proPack.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        //insert OPplineitem2;
        
        Id RecordTypeIdOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Person Opportunity').getRecordTypeId();

        // Opportunity_Payment_Terms__c oppPayTermTest1 = new Opportunity_Payment_Terms__c(Payment_Term__c = '1/2', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id,Status__c ='Passed',Requested_Due_Date__c=System.today(),Xero_Invoice_ID__c = 'test',Record_Id__c='2345');
        // insert oppPayTermTest1;
        // oppPayTermTest1.Requested_Due_Date__c = System.today().addDays(1);
        // oppPayTermTest1.Payment_Due_Date__c = System.today().addDays(5);
        // update oppPayTermTest1;
        //OPplineitem2.Quantity = 1;
        //update OPplineitem2;
        
        Intacct_API_Details__c Intacct = new Intacct_API_Details__c();
        Intacct.CompanyId__c = 'test';
        Intacct.EndpointURL__c = 'test';
        Intacct.Password__c = 'test';
        Intacct.SenderId__c = 'test';
        Intacct.SenderPassword__c = 'test';
        Intacct.UserName__c = 'test';
        Intacct.Production__c = true;
        insert Intacct;
        
        Set<Id> opptIds = new Set<Id>();
        opptIds.add(oppTest.Id);
        QE_OpportunityPaymentTermsHelper oppPaymentTerm = new QE_OpportunityPaymentTermsHelper();        
        // QE_OpportunityPaymentTermsHelper.createIntacctInvoiceDateRequest(Intacct,oppPayTermTest1);
        QE_OpportunityPaymentTermsHelper.updateOrderpayStatus(opptIds);
        // Delete oppPayTermTest1;
        
        Test.stopTest();
    }
    
    static testMethod void method3() {
        Program__c program = new Program__c();
        program.Name = 'test prgram F1E';
        insert program;

        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        eventTest.start_date__C = system.today();
        eventTest.End_date__C = System.today();
        eventTest.GPE_Event__c = true;
        Insert eventTest;

        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = eventTest.Id;
        insert parentPackage;

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
        Test.startTest();
        Opportunity oppTest = new Opportunity();
        oppTest.RecordTypeId = '012i00000012AaS';
        oppTest.AccountId = account.Id;
        oppTest.Name = 'Test oppTest';
        oppTest.StageName = 'Qualified';
        oppTest.Probability =  10;
        oppTest.Payment_Method__c ='Check';
        oppTest.Event__c = eventTest.Id;
        oppTest.CloseDate = System.today();
        oppTest.Contact_Site__c = 'barrettjacksonvip.com';
        oppTest.CurrencyIsoCode = 'USD';
        oppTest.Primary_Contact__c = contact.Id;
        oppTest.Email__c = 'test@gmail.com';
        oppTest.Phone__c = '1234567896';
        oppTest.is_Applied_Rewards__c = true;
        insert oppTest;
        
        Pricebook2 pb22 = new Pricebook2(Name='testDIE');
        insert pb22;
        
        Product2 proPack = new Product2(Name='BXCD11', isActive=true, 
                                        Event__c = eventTest.Id,
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId(), Parent_Package__c=parentPackage.Id);
        insert proPack ;
        Product2 proPro = new Product2(Name='BXCD22', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1,Type__c = 'ticket');
        insert proPro;
        Product2 proPro2 = new Product2(Name='BXCD33', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1,Type__c = 'Giftbag');
        insert proPro2;
        Product2 proHotel = new Product2(Name='BXCD44', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        insert proHotel;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=proPack.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        //insert OPplineitem2;
        
        
        Id RecordTypeIdOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Person Opportunity').getRecordTypeId();

        // Opportunity_Payment_Terms__c oppPayTermTest1 = new Opportunity_Payment_Terms__c(Payment_Term__c = '1/2', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id,Status__c ='Passed',Requested_Due_Date__c=System.today(),Xero_Invoice_ID__c = 'test',Record_Id__c='2345');
        // insert oppPayTermTest1;
        // oppPayTermTest1.Requested_Due_Date__c = System.today().addDays(1);
        // //oppPayTermTest1.Payment_Due_Date__c = System.today().addDays(5);
        // update oppPayTermTest1;
        //OPplineitem2.Quantity = 1;
        //update OPplineitem2;
        
        Intacct_API_Details__c Intacct = new Intacct_API_Details__c();
        Intacct.CompanyId__c = 'test';
        Intacct.EndpointURL__c = 'test';
        Intacct.Password__c = 'test';
        Intacct.SenderId__c = 'test';
        Intacct.SenderPassword__c = 'test';
        Intacct.UserName__c = 'test';
        Intacct.Production__c = true;
        insert Intacct;
        
        Set<Id> opptIds = new Set<Id>();
        opptIds.add(oppTest.Id);
        QE_OpportunityPaymentTermsHelper oppPaymentTerm = new QE_OpportunityPaymentTermsHelper();         
        QE_OpportunityPaymentTermsHelper.updateOrderpayStatus(opptIds);
        //Delete oppPayTermTest1;
        
        Test.stopTest();
    }
    
}
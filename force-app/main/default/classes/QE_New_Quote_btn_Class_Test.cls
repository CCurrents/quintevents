/**
 * @File Name          : QE_New_Quote_btn_Class_Test.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 11:38:46 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest(SeeAllData = false)
private class QE_New_Quote_btn_Class_Test { 
    // public static void init(){  
    //     //
    // }
    
    static testMethod void newQuotebtnClassTest() {
        
    //     init();
        
    //     // Insert Test Account
    //     Lead lead = new Lead();
    //     lead.Google_Analytics_ID__c = 'gaID';
    //     lead.Google_Analytics_Site_Id__c = 'gaSiteId';
    //     lead.FirstName = 'testName';
    //     lead.LastName = 'testName';
    //     lead.Status = 'Interested';
    //     lead.Source__c = 'call Virtuoso';
    //     insert lead;
        
    //     Database.LeadConvert lc = new database.LeadConvert();
    //     lc.setLeadId(lead.id);
    //     lc.setDoNotCreateOpportunity(true);
    //     lc.setConvertedStatus('Converted');
    //     Database.LeadConvertResult lcr = Database.convertLead(lc);
    //     System.assert(lcr.isSuccess());
        
    //     Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
    //     Program__c testProgram = new Program__c(Name = 'F1E');
    //     insert testProgram;
        
    //     QE360_Event__c testEvent = new QE360_Event__c(Name='Test Event', Program__c = testProgram.Id);
    //     insert testEvent;
        
    //     Account testLeadConvertedAccount = new Account();
        
    //     testLeadConvertedAccount.Id = testLead.ConvertedAccountId;
    //     testLeadConvertedAccount.PersonEmail = 'test@tets.com';
    //     testLeadConvertedAccount.ShippingStreet = 'test';
    //     testLeadConvertedAccount.ShippingState= 'Iowa';
    //     testLeadConvertedAccount.ShippingPostalCode = 'test';
    //     testLeadConvertedAccount.ShippingCountry = 'United States of America';
    //     testLeadConvertedAccount.ShippingCity = 'test';
        
    //     testLeadConvertedAccount.BillingStreet = 'test';
    //     testLeadConvertedAccount.BillingState= 'Iowa';
    //     testLeadConvertedAccount.BillingPostalCode = 'test';
    //     testLeadConvertedAccount.BillingCountry = 'United States of America';
    //     testLeadConvertedAccount.BillingCity = 'test';
        
    //     update testLeadConvertedAccount;
        
    //     Account account = new Account();
    //     account.RecordTypeId = '012i00000015Y4x';
    //     account.Name = 'Test Account';
    //     account.CurrencyIsoCode = 'USD';
    //     insert account;     
        
    //     Contact contact = new Contact();
    //     contact.LastName = 'Test Last Name';
    //     contact.AccountId = account.Id;
    //     contact.CurrencyIsoCode = 'USD';
    //     contact.Email = 'test@gmail.com';
    //     insert contact;
        
        
    //     //INSERT OPPORTUNITY RECORD
    //     Opportunity opp = new Opportunity();
    //     opp.AccountId = account.Id;
    //     opp.Name = 'test record'; 
    //     opp.StageName = 'Prospecting';
    //     opp.CloseDate = date.today();
    //     opp.Event__c = testEvent.Id;
    //     opp.Contact_Site__c = 'barrettjacksonvip.com';
    //     opp.Primary_Contact__c = contact.Id;
    //     opp.Phone__c = '123456789';
    //     opp.Email__c = 'test@gamil.com';
    //     opp.Shipping_City__c = 'Ahmedabad1';
    //     opp.Shipping_Country__c = 'India';
    //     opp.Shipping_Street__c = 'Bili';
    //     opp.Shipping_Zip_Postal_Code__c = '456768';
    //     opp.Payment_Method__c = 'check';
    //     insert opp;
        
    //     //INSERT QUOTE RECORD
    //     Quote quot = new Quote();
    //     quot.OpportunityId = opp.Id;
    //     quot.Name='Test Quote1';
    //     quot.Status='Draft';
    //     insert quot;
        
    //     QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1, Program__c = testProgram.Id);
    //     Insert eventTest;
        
    //     //Id prodRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Package'].Id;
    //     Id prodRecType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId();
    //     Parent_Package__c  pp1 = new Parent_Package__c(Name = 'Legend', Event__c = eventTest.Id);
    //     Insert pp1; 
        
    //     List<product2> lstprod = New List<product2>();
        
    //     Product2 prod = new Product2(Name='Test Prod',Available__c=true,Quantity_Per_Order_Threshold__c=1,Event__c=eventTest.Id,RecordTypeId=prodRecType,isActive=true,Parent_Package__c = pp1.Id,Type__c = 'Parking Pass');
    //     //insert prod; 
    //     lstprod.add(prod);
        
    //     //Id hotelRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Hotels'].Id;
    //     Id hotelRecType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId();
    //     Product2 prod1 = new Product2(Name='Test Prod1',Available__c=true,Quantity_Per_Order_Threshold__c=1,Event__c=eventTest.Id,RecordTypeId=hotelRecType,Inventory__c=-10,isActive=true);
    //     //insert prod1; 
    //     lstprod.add(prod1);
        
    //     insert lstprod;
        
    //     Package_Products__c packageProd = new Package_Products__c();
    //     packageProd.Package__c = prod.id;
    //     packageProd.Products_and_Hotels__c = prod1.id;
    //     //insert packageProd;
    //     //priceBook2 pricebook1 = new priceBook2(Name='testPricebook1');
    //     //insert priceBook1;
    //     PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=prod.Id, Pricebook2Id=Test.getStandardPricebookId(),
    //                                             isActive=true,UseStandardPrice = false);
    //     insert pbe2;
        
    //     Test.StartTest();
    //     Opportunity oppTest = new Opportunity(Name = 'oppName',Amount=1000,Payment_Terms__c= '1/2',AccountId = account.Id,Event__c = eventTest.Id,StageName = 'Prospecting',CloseDate = System.today(),
    //                                           Payment_Method__c = 'Credit Card',Shipping_City__c='xyz', Billing_City__c = 'abc',Contact_Site__c = 'barrettjacksonvip.com',Primary_Contact__c = contact.Id,
    //                                           Phone__c = '1234567890',Email__c = 'test1@gamil.com',Shipping_Country__c = 'India',Shipping_Street__c = 'Bili',Shipping_Zip_Postal_Code__c = '456768', 
    //                                           Reward_Percentage__c = 10);
    //     insert oppTest;
        
    //     // Opportunity_Payment_Terms__c oppPayment = new Opportunity_Payment_Terms__c();
    //     // oppPayment.Payment_Term__c = 'Net 30';
    //     // oppPayment.Opportunity__c = oppTest.ID;
    //     // insert oppPayment;
        
    //     OpportunityLineItem opplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id, UnitPrice=0.01, PriceBookEntryId=pbe2.Id, Record_Type__c='Package');
    //     insert opplineitem2;
        
        
    //     //List<Opportunity> lstoppr =[select id from opportunity where accountId=: testLead.ConvertedAccountId];
    //     //system.debug('list of opp '+lstoppr);
        
    //     //DEFINING STANDARD CONTROLLER
    //     ApexPages.StandardController sc = new ApexPages.StandardController(quot);        
    //     Test.setCurrentPageReference(new PageReference('Page.QE_New_Quote_btn')); 
    //     ApexPages.currentPage().getParameters().put('Oppid', oppTest.id);
    //     QE_New_Quote_btn_Class testQuoteRecord = new QE_New_Quote_btn_Class(sc);
        
    //     testQuoteRecord.closePopup();
    //     testQuoteRecord.displayMsg='Error';
    //     testQuoteRecord.displayPopup = true;
    //     testQuoteRecord.oppRec = oppTest;
    //     testQuoteRecord.RedirectMethod();
        
    //     Test.StopTest();
    // }
    
    
    // static testMethod void newQuotebtnClassTest4() {
        
    //     init();
        
    //     // Insert Test Account
    //     Lead lead = new Lead();
    //     lead.Google_Analytics_ID__c = 'gaID';
    //     lead.Google_Analytics_Site_Id__c = 'gaSiteId';
    //     lead.FirstName = 'testName';
    //     lead.LastName = 'testName';
    //     lead.Status = 'Interested';
    //     lead.Source__c = 'call Virtuoso';
    //     insert lead;
        
    //     Database.LeadConvert lc = new database.LeadConvert();
    //     lc.setLeadId(lead.id);
    //     lc.setDoNotCreateOpportunity(true);
    //     lc.setConvertedStatus('Converted');
    //     Database.LeadConvertResult lcr = Database.convertLead(lc);
    //     System.assert(lcr.isSuccess());
        
    //     Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
    //     Program__c testProgram = new Program__c(Name = 'F1E');
    //     insert testProgram;
        
    //     QE360_Event__c testEvent = new QE360_Event__c(Name='Test Event', Program__c = testProgram.Id);
    //     insert testEvent;
        
    //     Account testLeadConvertedAccount = new Account();
        
    //     testLeadConvertedAccount.Id = testLead.ConvertedAccountId;
    //     testLeadConvertedAccount.PersonEmail = 'test@tets.com';
    //     testLeadConvertedAccount.ShippingStreet = 'test';
    //     testLeadConvertedAccount.ShippingState= 'Iowa';
    //     testLeadConvertedAccount.ShippingPostalCode = 'test';
    //     testLeadConvertedAccount.ShippingCountry = 'United States of America';
    //     testLeadConvertedAccount.ShippingCity = 'test';
        
    //     testLeadConvertedAccount.BillingStreet = 'test';
    //     testLeadConvertedAccount.BillingState= 'Iowa';
    //     testLeadConvertedAccount.BillingPostalCode = 'test';
    //     testLeadConvertedAccount.BillingCountry = 'United States of America';
    //     testLeadConvertedAccount.BillingCity = 'test';
        
    //     update testLeadConvertedAccount;
        
    //     Account account = new Account();
    //     account.RecordTypeId = '012i00000015Y4x';
    //     account.Name = 'Test Account';
    //     account.CurrencyIsoCode = 'USD';
    //     insert account;     
        
    //     Contact contact = new Contact();
    //     contact.LastName = 'Test Last Name';
    //     contact.AccountId = account.Id;
    //     contact.CurrencyIsoCode = 'USD';
    //     contact.Email = 'test@gmail.com';
    //     insert contact;
        
        
    //     //INSERT OPPORTUNITY RECORD
    //     Opportunity opp = new Opportunity();
    //     opp.AccountId = account.Id;
    //     opp.Name = 'test record'; 
    //     opp.StageName = 'Prospecting';
    //     opp.CloseDate = date.today();
    //     opp.Event__c = testEvent.Id;
    //     opp.Contact_Site__c = 'barrettjacksonvip.com';
    //     opp.Primary_Contact__c = contact.Id;
    //     opp.Phone__c = '123456789';
    //     opp.Email__c = 'test@gamil.com';
    //     opp.Shipping_City__c = 'Ahmedabad1';
    //     opp.Shipping_Country__c = 'India';
    //     opp.Shipping_Street__c = 'Bili';
    //     opp.Shipping_Zip_Postal_Code__c = '456768';
    //     opp.Payment_Method__c = 'check';
    //     insert opp;
        
    //     //INSERT QUOTE RECORD
        
    //     Quote quot = new Quote();
    //     quot.OpportunityId = opp.Id;
    //     quot.Name='Test Quote1';
    //     quot.Status='Draft';
    //     insert quot;
        
    //     QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1, Program__c = testProgram.Id);
    //     Insert eventTest;
        
    //     //Id prodRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Package'].Id;
    //     Id prodRecType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId();
    //     Parent_Package__c  pp1 = new Parent_Package__c(Name = 'Legend', Event__c = eventTest.Id);
    //     Insert pp1; 
        
    //     List<product2> lstprod = New List<product2>();
        
    //     Product2 prod = new Product2(Name='Test Prod',Available__c=true,Quantity_Per_Order_Threshold__c=1,Event__c=eventTest.Id,RecordTypeId=prodRecType,isActive=true,Parent_Package__c = pp1.Id);
    //     //insert prod; 
    //     lstprod.add(prod);
        
    //     //Id hotelRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Hotels'].Id;
    //     Id hotelRecType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId();
    //     Product2 prod1 = new Product2(Name='Test Prod1',Available__c=true,Quantity_Per_Order_Threshold__c=1,Event__c=eventTest.Id,RecordTypeId=hotelRecType,Inventory__c=-10,isActive=true);
    //     //insert prod1; 
    //     lstprod.add(prod1);
        
    //     insert lstprod;
        
    //     Package_Products__c packageProd = new Package_Products__c();
    //     packageProd.Package__c = prod.id;
    //     packageProd.Products_and_Hotels__c = prod1.id;
    //     //insert packageProd;
    //     //priceBook2 pricebook1 = new priceBook2(Name='testPricebook1');
    //     //insert priceBook1;
    //     PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=prod.Id, Pricebook2Id=Test.getStandardPricebookId(),
    //                                             isActive=true,UseStandardPrice = false);
    //     insert pbe2;
    //     Test.StartTest();
    //     Opportunity oppTest = new Opportunity(Name = 'oppName',Amount=1000,Payment_Terms__c= '1/2',AccountId = account.Id,Event__c = eventTest.Id,StageName = 'Prospecting',CloseDate = System.today(),
    //                                           Payment_Method__c = 'Credit Card',Shipping_City__c='xyz', Billing_City__c = 'abc',Contact_Site__c = 'barrettjacksonvip.com',Primary_Contact__c = contact.Id,
    //                                           Phone__c = '1234567890',Email__c = 'test1@gamil.com',Shipping_Country__c = 'India',Shipping_Street__c = 'Bili',Shipping_Zip_Postal_Code__c = '456768',
    //                                           Reward_Percentage__c = 10);
    //     insert oppTest;
    //     // Opportunity_Payment_Terms__c oppPayment = new Opportunity_Payment_Terms__c();
    //     // oppPayment.Payment_Term__c = 'Net 30';
    //     // oppPayment.Opportunity__c = oppTest.ID;
    //     // insert oppPayment;
        
    //     OpportunityLineItem opplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id,Record_Type__c='Package');
    //     insert opplineitem2;
        
    //     //List<Opportunity> lstoppr =[select id from opportunity where accountId=: testLead.ConvertedAccountId];
    //     //system.debug('list of opp '+lstoppr);
        
    //     //DEFINING STANDARD CONTROLLER
    //     ApexPages.StandardController sc = new ApexPages.StandardController(quot);        
    //     Test.setCurrentPageReference(new PageReference('Page.QE_New_Quote_btn')); 
    //     ApexPages.currentPage().getParameters().put('Oppid', oppTest.id);
    //     QE_New_Quote_btn_Class testQuoteRecord = new QE_New_Quote_btn_Class(sc);
        
    //     testQuoteRecord.closePopup();
    //     testQuoteRecord.displayMsg='Error';
    //     testQuoteRecord.displayPopup = true;
    //     testQuoteRecord.oppRec = oppTest;
    //     testQuoteRecord.RedirectMethod();
        
    //     Test.StopTest();
    // }
    
    // static testMethod void newQuotebtnClassTest2() {
        
    //     init();
        
        
    //     QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
    //     Insert eventTest;
        
    //     // Insert Test Account
    //     Lead lead = new Lead();
    //     lead.Google_Analytics_ID__c = 'gaID';
    //     lead.Google_Analytics_Site_Id__c = 'gaSiteId';
    //     lead.FirstName = 'testName';
    //     lead.LastName = 'testName';
    //     lead.Status = 'Interested';
    //     lead.Source__c = 'call Virtuoso';
    //     insert lead;
        
    //     Database.LeadConvert lc = new database.LeadConvert();
    //     lc.setLeadId(lead.id);
    //     lc.setDoNotCreateOpportunity(true);
    //     lc.setConvertedStatus('Converted');
    //     Database.LeadConvertResult lcr = Database.convertLead(lc);
    //     System.assert(lcr.isSuccess());
        
    //     Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
    //     Account testLeadConvertedAccount = new Account();
        
    //     testLeadConvertedAccount.Id = testLead.ConvertedAccountId;
    //     testLeadConvertedAccount.PersonEmail = 'test@tets.com';
    //     testLeadConvertedAccount.ShippingStreet = 'test';
    //     testLeadConvertedAccount.ShippingState= 'Iowa';
    //     testLeadConvertedAccount.ShippingPostalCode = 'test';
    //     testLeadConvertedAccount.ShippingCountry = 'United States of America';
    //     testLeadConvertedAccount.ShippingCity = 'test';
        
    //     testLeadConvertedAccount.BillingStreet = 'test';
    //     testLeadConvertedAccount.BillingState= 'Iowa';
    //     testLeadConvertedAccount.BillingPostalCode = 'test';
    //     testLeadConvertedAccount.BillingCountry = 'United States of America';
    //     testLeadConvertedAccount.BillingCity = 'test';
        
    //     update testLeadConvertedAccount;
    //     //Id prodRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Package'].Id;
    //     Id prodRecType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId();
    //     Parent_Package__c  pp1 = new Parent_Package__c(Name = 'Parent Package 1 Demo', Event__c = eventTest.Id);
    //     Insert pp1; 
    //     Product2 prod = new Product2(Name='Test Prod',Available__c=true,Quantity_Per_Order_Threshold__c=1,Event__c=eventTest.Id,RecordTypeId=prodRecType,isActive=true,Parent_Package__c = pp1.Id);
    //     insert prod; 
    //     //Id hotelRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Hotels'].Id;
    //     Id hotelRecType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId();
    //     Product2 prod1 = new Product2(Name='Test Prod1',Available__c=true,Quantity_Per_Order_Threshold__c=1,Event__c=eventTest.Id,RecordTypeId=hotelRecType,Inventory__c=-10,isActive=true);
    //     insert prod1; 
    //     Package_Products__c packageProd = new Package_Products__c();
    //     packageProd.Package__c = prod.id;
    //     packageProd.Products_and_Hotels__c = prod1.id;
    //     insert packageProd;
    //     PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=prod.Id, Pricebook2Id=Test.getStandardPricebookId(),
    //                                             isActive=true,UseStandardPrice = false);
    //     insert pbe2;
    //     Test.StartTest();
        
    //     Account account = new Account();
    //     account.RecordTypeId = '012i00000015Y4x';
    //     account.Name = 'Test Account';
    //     account.CurrencyIsoCode = 'USD';
    //     insert account;     
        
    //     Contact contact = new Contact();
    //     contact.LastName = 'Test Last Name';
    //     contact.AccountId = account.Id;
    //     contact.CurrencyIsoCode = 'USD';
    //     contact.Email = 'test@gmail.com';
    //     insert contact;
        
        
    //     Opportunity oppTest = new Opportunity(Name = 'oppName',
    //                                           Amount=1000,Payment_Terms__c= '1/2',AccountId = account.Id,Event__c = eventTest.Id,StageName = 'Prospecting',
    //                                           CloseDate = System.today(), Payment_Method__c = 'Credit Card',Shipping_City__c ='test',
    //                                           Billing_City__c='test1',Shipping_Country__c ='United States of America',
    //                                           Billing_Country__c='United States of America',Shipping_State_Province__c='Iowa',
    //                                           Billing_State_Province__c='Iowa',Shipping_Street__c ='test',
    //                                           Billing_Street__c='test1',Shipping_Zip_Postal_Code__c='9999',
    //                                           Billing_Zip_Postal_Code__c='10000',Phone__c='990990990',Contact_Site__c = 'barrettjacksonvip.com',
    //                                           Email__c='tst@tst.com', Primary_Contact__c = contact.Id);
    //     insert oppTest;
    //     OpportunityLineItem opplineitem2 = new OpportunityLineItem 
    //         (Quantity=2, 
    //          OpportunityId=oppTest.Id,
    //          UnitPrice=0.01,
    //          PriceBookEntryId=pbe2.Id);
    //     insert opplineitem2;
        
        
    //     List<Opportunity> lstoppr =[select id from opportunity where accountId=: testLead.ConvertedAccountId];
    //     system.debug('list of opp '+lstoppr);
    //     Quote quot1 = new Quote(OpportunityId=oppTest.Id, Name='Test Quote1', Status='Draft',Payment_Method__c='Credit Card',Pricebook2Id = Test.getStandardPricebookId());
    //     insert quot1;
    //     dsfs__DocuSign_Status__c docSign = new dsfs__DocuSign_Status__c();
    //     docSign.dsfs__DocuSign_Envelope_ID__c ='test';
    //     docSign.Standard_Quote__c= quot1.id;
    //     docSign.dsfs__Envelope_Status__c= 'test';
    //     insert docSign;
    //     //DEFINING STANDARD CONTROLLER
    //     ApexPages.StandardController sc = new ApexPages.StandardController(quot1);        
    //     Test.setCurrentPageReference(new PageReference('Page.QE_New_Quote_btn')); 
    //     ApexPages.currentPage().getParameters().put('Oppid', oppTest.id);
        
    //     Test.StopTest();
    // }
    // static testMethod void newQuotebtnClassTest3() {
        
    //     init();
        
        
    //     QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
    //     Insert eventTest;
        
    //     // Insert Test Account
    //     Lead lead = new Lead();
    //     lead.Google_Analytics_ID__c = 'gaID';
    //     lead.Google_Analytics_Site_Id__c = 'gaSiteId';
    //     lead.FirstName = 'testName';
    //     lead.LastName = 'testName';
    //     lead.Status = 'Interested';
    //     lead.Source__c = 'call Virtuoso';
    //     insert lead;
        
    //     Database.LeadConvert lc = new database.LeadConvert();
    //     lc.setLeadId(lead.id);
    //     lc.setDoNotCreateOpportunity(true);
    //     lc.setConvertedStatus('Converted');
    //     Database.LeadConvertResult lcr = Database.convertLead(lc);
    //     System.assert(lcr.isSuccess());
        
    //     Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];        
        
    //     Account testLeadConvertedAccount = new Account();
        
    //     testLeadConvertedAccount.Id = testLead.ConvertedAccountId;
    //     testLeadConvertedAccount.PersonEmail = 'test@tets.com';
    //     testLeadConvertedAccount.ShippingStreet = 'test';
    //     testLeadConvertedAccount.ShippingState= 'Iowa';
    //     testLeadConvertedAccount.ShippingPostalCode = 'test';
    //     testLeadConvertedAccount.ShippingCountry = 'United States of America';
    //     testLeadConvertedAccount.ShippingCity = 'test';
        
    //     testLeadConvertedAccount.BillingStreet = 'test';
    //     testLeadConvertedAccount.BillingState= 'Iowa';
    //     testLeadConvertedAccount.BillingPostalCode = 'test';
    //     testLeadConvertedAccount.BillingCountry = 'United States of America';
    //     testLeadConvertedAccount.BillingCity = 'test';
        
    //     update testLeadConvertedAccount;
    //     //Id prodRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Package'].Id;
    //     Id prodRecType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId();
    //     Parent_Package__c  pp1 = new Parent_Package__c(Name = 'Parent Package 1 Demo', Event__c = eventTest.Id);
    //     Insert pp1; 
    //     Product2 prod = new Product2(Name='Test Prod',Available__c=true,Quantity_Per_Order_Threshold__c=1,Event__c=eventTest.Id,RecordTypeId=prodRecType,isActive=true,Parent_Package__c = pp1.Id);
    //     insert prod; 
    //     //Id hotelRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Hotels'].Id;
    //     Id hotelRecType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId();
    //     Product2 prod1 = new Product2(Name='Test Prod1',Available__c=true,Quantity_Per_Order_Threshold__c=1,Event__c=eventTest.Id,RecordTypeId=hotelRecType,Inventory__c=-10,isActive=true);
    //     insert prod1; 
    //     Package_Products__c packageProd = new Package_Products__c();
    //     packageProd.Package__c = prod.id;
    //     packageProd.Products_and_Hotels__c = prod1.id;
    //     insert packageProd;
    //     PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=prod.Id, Pricebook2Id=Test.getStandardPricebookId(),
    //                                             isActive=true,UseStandardPrice = false);
    //     insert pbe2;
    //     Test.StartTest();
        
    //     Account account = new Account();
    //     account.RecordTypeId = '012i00000015Y4x';
    //     account.Name = 'Test Account';
    //     account.CurrencyIsoCode = 'USD';
    //     insert account;     
        
    //     Contact contact = new Contact();
    //     contact.LastName = 'Test Last Name';
    //     contact.AccountId = account.Id;
    //     contact.CurrencyIsoCode = 'USD';
    //     contact.Email = 'test@gmail.com';
    //     insert contact;
        
    //     Opportunity oppTest = new Opportunity(Name = 'oppName',
    //                                           Amount=1000,Payment_Terms__c= '1/2',AccountId = account.Id,Event__c = eventTest.Id,StageName = 'Prospecting',
    //                                           CloseDate = System.today(),Shipping_City__c ='test',
    //                                           Billing_City__c='test1',Payment_Method__c='Credit Card', Shipping_Country__c ='United States of America',
    //                                           Billing_Country__c='United States of America',Shipping_State_Province__c='Iowa',
    //                                           Billing_State_Province__c='Iowa',Shipping_Street__c ='test',
    //                                           Billing_Street__c='test1',Shipping_Zip_Postal_Code__c='9999',
    //                                           Billing_Zip_Postal_Code__c='10000', Contact_Site__c = 'barrettjacksonvip.com',
    //                                           Email__c='tst@tst.com',Primary_Contact__c = contact.Id);
    //     insert oppTest;
    //     OpportunityLineItem opplineitem2 = new OpportunityLineItem 
    //         (Quantity=2, 
    //          OpportunityId=oppTest.Id,
    //          UnitPrice=0.01,
    //          PriceBookEntryId=pbe2.Id);
    //     insert opplineitem2;
        
    //     List<Opportunity> lstoppr =[select id from opportunity where accountId=: testLead.ConvertedAccountId];
    //     system.debug('list of opp '+lstoppr);
    //     Quote quot1 = new Quote(OpportunityId=oppTest.Id, Name='Test Quote1', Status='Draft',Payment_Method__c='Credit Card',Pricebook2Id = Test.getStandardPricebookId());
    //     insert quot1;
        
    //     //DEFINING STANDARD CONTROLLER
    //     ApexPages.StandardController sc = new ApexPages.StandardController(quot1);        
    //     Test.setCurrentPageReference(new PageReference('Page.QE_New_Quote_btn')); 
    //     ApexPages.currentPage().getParameters().put('Oppid', oppTest.id);
        
    //     Test.StopTest();
    }
    
}
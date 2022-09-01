@isTest
private class QE_Add_Packages_and_Products_btn_Test { 
    public static void init(){  
    }
    static testMethod void newQuotebtnClassTest() {
       Test.StartTest();
        init();
        
        // Insert Test Account
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
        
        QE360_Event__c testEvent = new QE360_Event__c(Name='Test Event');
        insert testEvent;
        
        Account testLeadConvertedAccount = new Account();
        
        testLeadConvertedAccount.Id = testLead.ConvertedAccountId;
        testLeadConvertedAccount.PersonEmail = 'test@tets.com';
        testLeadConvertedAccount.ShippingStreet = 'test';
        testLeadConvertedAccount.ShippingState= 'test';
        testLeadConvertedAccount.ShippingPostalCode = 'test';
        testLeadConvertedAccount.ShippingCountry = 'test';
        testLeadConvertedAccount.ShippingCity = 'test';
        
        testLeadConvertedAccount.BillingStreet = 'test';
        testLeadConvertedAccount.BillingState= 'test';
        testLeadConvertedAccount.BillingPostalCode = 'test';
        testLeadConvertedAccount.BillingCountry = 'test';
        testLeadConvertedAccount.BillingCity = 'test';
        
        update testLeadConvertedAccount;
        
        //INSERT OPPORTUNITY RECORD
        Opportunity opp = new Opportunity();
        opp.AccountId = testLead.ConvertedAccountId;
        opp.Name = 'test record'; 
        opp.StageName = 'Prospecting';
        opp.CloseDate = date.today();
        opp.Event__c = testEvent.Id;
        opp.Contact_Site__c = 'barrettjacksonvip.com';
        insert opp;
        
        //INSERT QUOTE RECORD
        
        Quote quot = new Quote();
        quot.OpportunityId = opp.Id;
        quot.Name='Test Quote1';
        quot.Status='Draft';
        insert quot;
        
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
        Insert eventTest;

        
        Id prodRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Package'].Id;
        Product2 prod = new Product2(Name='Test Prod',Available__c=true,Quantity_Per_Order_Threshold__c=1,Event__c=eventTest.Id,RecordTypeId=prodRecType,isActive=true);
        insert prod; 
         Id hotelRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Hotels'].Id;
        Product2 prod1 = new Product2(Name='Test Prod1',Available__c=true,Quantity_Per_Order_Threshold__c=1,Event__c=eventTest.Id,RecordTypeId=hotelRecType,Inventory__c=-10,isActive=true);
        insert prod1; 
        Package_Products__c packageProd = new Package_Products__c();
        packageProd.Package__c = prod.id;
        packageProd.Products_and_Hotels__c = prod1.id;
        insert packageProd;
        //priceBook2 pricebook1 = new priceBook2(Name='testPricebook1');
        //insert priceBook1;
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=prod.Id, Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        Opportunity oppTest = new Opportunity(Name = 'oppName',Amount=1000,Payment_Terms__c= '1/2',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,StageName = 'Prospecting',CloseDate = System.today(),
                                            Payment_Method__c = 'Credit Card',Shipping_City__c='xyz', Billing_City__c = 'abc',Contact_Site__c = 'barrettjacksonvip.com');
        insert oppTest;
        
        
       /* Opportunity oppTest2 = new Opportunity(Name = 'oppName2', Amount=1000, Payment_Terms__c= '1/2', Payment_Method__c = 'Credit Card',
                                               AccountId = accTest.Id, Event__c = eventTest.Id, StageName = 'Prospecting', Billing_City__c = 'abc',
                                               Shipping_City__c='xyz',
                                               CloseDate = System.today());
        insert oppTest2;*/
        
        OpportunityLineItem opplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert opplineitem2;
        
        
        List<Opportunity> lstoppr =[select id from opportunity where accountId=: testLead.ConvertedAccountId];
        system.debug('list of opp '+lstoppr);

        //DEFINING STANDARD CONTROLLER
        ApexPages.StandardController sc = new ApexPages.StandardController(quot);        
        Test.setCurrentPageReference(new PageReference('Page.QE_New_Quote_btn')); 
        ApexPages.currentPage().getParameters().put('Oppid', oppTest.id);
        QE_New_Quote_btn_Class testQuoteRecord = new QE_New_Quote_btn_Class(sc);
        
        testQuoteRecord.closePopup();
        testQuoteRecord.displayPopup = true;
        testQuoteRecord.oppRec = oppTest;
        
        Quote quot1 = new Quote(OpportunityId=oppTest.Id, Name='Test Quote1', Status='Draft',Payment_Method__c='Credit Card',Pricebook2Id = Test.getStandardPricebookId());
        //insert quot1;
        
        QuoteLineItem Quolineitem2 = new QuoteLineItem (Quantity=2, QuoteId=quot1.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        //insert Quolineitem2;
        
        Quote quot2 = new Quote(OpportunityId=oppTest.Id, Name='Test Quote2', Status='Draft - Approved',Payment_Method__c='Credit Card',Email='test@test435.com',Pricebook2Id = Test.getStandardPricebookId());
        //insert quot2;
        QuoteLineItem Quolineitem3 = new QuoteLineItem (Quantity=2, QuoteId=quot2.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        //insert Quolineitem3;
        
        Test.StopTest();
    }
    }
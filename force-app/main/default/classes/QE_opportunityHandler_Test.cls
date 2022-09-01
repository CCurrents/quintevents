@isTest(seeAllData=false)
public class QE_opportunityHandler_Test {
    public static Id OppRcdId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
    public static Id accBussinessRcdId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
    
    static testMethod void test_method_one() {
        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        eventTest.GPE_Event__c = true;
        Insert eventTest;
        
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'lgaID';
        lead.Google_Analytics_Site_Id__c = 'lgaSiteId';
        lead.FirstName = 'testNamelead';
        lead.LastName = 'test';
        lead.Status = 'Qualified';
        lead.Source__c = 'call cotaexperiences.com';
        lead.Email = 'testemails@quintevents.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');//Converted
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        
        Lead lead1 = new Lead();
        lead1.Google_Analytics_ID__c = 'gaID';
        lead1.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead1.FirstName = 'testNameabc';
        lead1.LastName = 'test';
        lead1.Status = 'Qualified';
        lead1.Source__c = 'call Virtuoso';
        lead1.Email = 'testemail12@quintevents.com';
        insert lead1;
        
        Database.LeadConvert lc1 = new database.LeadConvert();
        lc1.setLeadId(lead1.id);
        lc1.setDoNotCreateOpportunity(true);
        lc1.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr1 = Database.convertLead(lc1);
        
        Lead testLead = [select Id, IsConverted, ConvertedAccountId,ConvertedContactId  from Lead where Id = :lead.Id];
        
        Lead testLead1 = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead1.Id];
        
        Reseller__c testReseller = new Reseller__c(Default_Commission__c =1.00);
        Insert testReseller;
        
        Promoter__c testPromoter = new Promoter__c(Online_Sales_Commission__c=1.00, A_La_Carte_Commission__c=2.00, 
                                                   Package_with_Hotel_Commission__c=3.00, Package_without_Hotel_Commission__c=4.00);
        Insert testPromoter;
        
        Account acct = new Account();
        acct.RecordTypeId = '012i00000015Y4x';
        acct.Name = 'Test Account';
        acct.CurrencyIsoCode = 'USD';
        insert acct;
        // Products to be inserted
        List<Product2> productsToBeInserted = new List<Product2>();
        
        Parent_Package__c parentPakg = new Parent_Package__c(Event__c = eventTest.Id, Name='Test Parent pkg');
        insert parentPakg;
        // Package
        Product2 testPackage = new Product2(Name='BXCD11', Price__c=1.00, Type__c='Package', isActive=true,Event__c = eventTest.Id,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId(), Parent_Package__c = parentPakg.Id);
        productsToBeInserted.add(testPackage);
        
        // Products
        Product2 testProduct = new Product2(Name='BXCD22',Brandfuel_Points__c = 55, Price__c=1.00, Type__c='Giftbag', isActive=true,Event__c = eventTest.Id,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),
                                            A_La_Carte__c = true, Available__c=true,Quantity_Per_Order_Threshold__c=1, Allocated__c = true);
        productsToBeInserted.add(testProduct);
        
        insert productsToBeInserted;
        
        Contact conn = new Contact();
        conn.LastName = 'Test Last Name';
        conn.AccountId = acct.Id;
        conn.CurrencyIsoCode = 'USD';
        conn.Email = 'test@gmail.com';
        insert conn;
        
        Contact conn1 = new Contact();
        conn1.LastName = 'Test Last Name';
        conn1.AccountId = acct.Id;
        conn1.CurrencyIsoCode = 'USD';
        conn1.Email = 'tesdfgdt@gmail.com';
        insert conn1;
        
        acct.Primary_Contact__c = conn.Id;
        acct.Visitor_Country__c = 'In';
        update acct;
 
        Opportunity oppTest = new Opportunity();
        oppTest.Name = 'oppName';
        oppTest.AccountId = testLead.ConvertedAccountId;//acct.Id;
        oppTest.Event__c = eventTest.Id;
        oppTest.StageName = 'Closed Won';
        oppTest.CloseDate = System.today();
        oppTest.Contact_Site__c = 'quintevents.com';
        oppTest.Payment_Method__c = 'Check';
        //oppTest.email__c = 'abcedgft@gmail.com';
        oppTest.Amount = 1;
        oppTest.Primary_Contact__c = testLead.ConvertedContactId;//conn.id; 
        //oppTest.Communications_Contact__c = conn1.id;
        oppTest.Email__c = 'test@gmail.com';
        oppTest.Reason_For_Cancellation__c = '';
        //try{
        insert oppTest;
        /*}
        catch(dmlException e) {
        }*/
        oppTest.StageName = 'Defaulted';
        update oppTest;
        // oppTest.StageName = 'Canceled';
        // oppTest.Reason_For_Cancellation__c = 'Upgrade';
        // update oppTest;
        Account a = new Account();
        a.Id = testLead.convertedAccountId;
        a.personEmail = 'nhdgr@gmail.com';
        
        a.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'BusinessAccount' LIMIT 1].Id;
        
        Contact c = new Contact();
        c.Lastname = 'abdcgname';
        c.firstname = 'abcname';
        c.email = 'test@test.com';
        c.primary_contact__C = true;
        insert c;
        Test.startTest();
        
        // a.Primary_Contact__c = c.id;
        // update a;
        
        Opportunity oppTest1 = new Opportunity();
        oppTest1.Name = eventTest.name;
        oppTest1.AccountId = a.Id;
        oppTest1.Event__c = eventTest.Id;
        oppTest1.StageName = 'Value Proposition';
        oppTest1.CloseDate = System.today();
        oppTest1.Contact_Site__c = 'quintevents.com';
        oppTest1.Payment_Method__c = 'Check'; 
        //oppTest1.Email__c = 'ahgtest@gmail.com'; 
        oppTest1.Primary_contact__c = conn.Id;//a.primary_Contact__C;  
        //oppTest1.Reason_For_Cancellation__c          
        try{ 
            insert oppTest1;            
        }
        catch(dmlexception e)
        {       
            system.debug('::::::::::::ERROR'+e.getmessage());
        }
       
        //oppTest1.StageName = 'Closed Won';------------
        //update oppTest1;---------------------
        //oppTest1.StageName = 'Defaulted';------------------------Updated by manan
        //update oppTest1;-------------------------
        // Add quote to validate validation rule.
        Quote testQuote = new Quote();
        testQuote.OpportunityId = oppTest.Id;
        testQuote.Email = 'htevv@gmail.com';//oppTest.Email__c;
        try{
            insert testQuote;
            System.debug('testQuote Id:'+testQuote.id);
        }
        catch(DMLException e) {
            System.debug('Error:::'+e);
        }
        
        //testQuote.Status = 'Signed - Approved';----------------
        //update testQuote; ------------------------Updated by manan
        
        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity> ();
        oldMap.put(oppTest.Id,oppTest);
        List<Opportunity> oldList = new List<Opportunity>();
        oldList.add(oppTest);
        
        
        
        oppTest.StageName =  'Closed won';
        //oppTest.Reason_For_Cancellation__c = 'Defaulted';
        //oppTest.Primary_Contact__c = conn1.id;
        oppTest.Online_Order__c = False;
        //oppTest.Email__c = 'test1s2de@gmail.com';
        
        Map<Id,Opportunity> newMap = new Map<Id,Opportunity> ();
        newMap.put(oppTest.Id,oppTest);
        List<Opportunity> newList = new List<Opportunity>();
        newList.add(oppTest);
        QE_opportunityHandler handler = new QE_opportunityHandler();
        handler.OnAfterUpdate(oldList, newList, newMap,oldMap);
        handler.OnBeforeUpdate(oldList, newList, newMap,oldMap);
        
        oppTest.Primary_Contact__c = conn1.id;
        oppTest.Communications_Contact__c = conn.id;
        newMap = new Map<Id,Opportunity> ();
        newMap.put(oppTest.Id,oppTest);
        handler.OnBeforeUpdate(oldList, newList, newMap,oldMap);
        
        handler.OnAfterDelete(oldList);
        
        try {
            update oppTest;
        }
        catch(DMLException e) {
        }      
        oppTest.StageName =  'Canceled';
        oppTest.Approved_Canceled_From_Closed_Won__c = False;
        oppTest.Reason_For_Cancellation__c = 'Defaulted';
        oppTest.Change_Request_Detail__c = 'Test Detail';
        QE_checkRecursiveOpportunity.run = True;
        try{
            update oppTest;
        }
        catch(DMLException e) {
        }
        
        
        
        /*PricebookEntry pricebookentry = new PricebookEntry();
        pricebookentry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookentry.Product2Id = testProduct.Id;
        pricebookentry.UnitPrice = 100;
        pricebookentry.CurrencyIsoCode = 'USD';
        pricebookentry.isActive = true;
        insert pricebookentry;
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = oppTest.Id;
        oppLineItem.PricebookEntryId = pricebookentry.Id;
        oppLineItem.Quantity = 100;
        oppLineItem.UnitPrice = 10;
        oppLineItem.Product2Id = testProduct.Id;
        oppLineItem.ApexProductType__c = 'Hotel';
        oppLineItem.ApexProductName__c = testProduct.Name;
        oppLineItem.ApexCost__c = 120;  
        oppLineItem.Opportunity_Product_Package_Hotel__c = true;
        oppLineItem.Package__c = testProduct.Id;
        insert oppLineItem;*/
        Test.stopTest();
    }
    static testMethod void test_method_two() {
        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        Insert eventTest;
        
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'lgaID';
        lead.Google_Analytics_Site_Id__c = 'lgaSiteId';
        lead.FirstName = 'testNamelead';
        lead.LastName = 'test';
        lead.Status = 'Qualified';
        lead.Source__c = 'call cotaexperiences.com';
        lead.Email = 'testemails@quintevents.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');//Converted
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        
        Lead lead1 = new Lead();
        lead1.Google_Analytics_ID__c = 'gaID';
        lead1.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead1.FirstName = 'testNameabc';
        lead1.LastName = 'test';
        lead1.Status = 'Qualified';
        lead1.Source__c = 'call Virtuoso';
        lead1.Email = 'testemail12@quintevents.com';
        insert lead1;
        
        Database.LeadConvert lc1 = new database.LeadConvert();
        lc1.setLeadId(lead1.id);
        lc1.setDoNotCreateOpportunity(true);
        lc1.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr1 = Database.convertLead(lc1);
        
        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
        Lead testLead1 = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead1.Id];
        
        Reseller__c testReseller = new Reseller__c(Default_Commission__c =1.00);
        Insert testReseller;
        
        Promoter__c testPromoter = new Promoter__c(Online_Sales_Commission__c=1.00, A_La_Carte_Commission__c=2.00, 
                                                   Package_with_Hotel_Commission__c=3.00, Package_without_Hotel_Commission__c=4.00);
        Insert testPromoter;
        
        Account acct = new Account();
        acct.RecordTypeId = '012i00000015Y4x';
        acct.Name = 'Test Account';
        acct.CurrencyIsoCode = 'USD';
        insert acct;
        // Products to be inserted
        List<Product2> productsToBeInserted = new List<Product2>();
        
        Parent_Package__c parentPakg = new Parent_Package__c(Event__c = eventTest.Id, Name='Test Parent pkg');
        insert parentPakg;
        // Package
        Product2 testPackage = new Product2(Name='BXCD11', Price__c=1.00, Type__c='Package', isActive=true,Event__c = eventTest.Id,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId(), Parent_Package__c = parentPakg.Id);
        productsToBeInserted.add(testPackage);
        
        // Products
        Product2 testProduct = new Product2(Name='BXCD22',Brandfuel_Points__c = 55, Price__c=1.00, Type__c='Giftbag', isActive=true,Event__c = eventTest.Id,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),
                                            A_La_Carte__c = true, Available__c=true,Quantity_Per_Order_Threshold__c=1, Allocated__c = true);
        productsToBeInserted.add(testProduct);
        
        insert productsToBeInserted;
        
        Contact conn = new Contact();
        conn.LastName = 'Test Last Name';
        conn.AccountId = acct.Id;
        conn.CurrencyIsoCode = 'USD';
        conn.Email = 'test@gmail.com';
        insert conn;
        
        Contact conn1 = new Contact();
        conn1.LastName = 'Test Last Name';
        conn1.AccountId = acct.Id;
        conn1.CurrencyIsoCode = 'USD';
        conn1.Email = 'tesdfgdt@gmail.com';
        insert conn1;
        
        acct.Primary_Contact__c = conn.Id;
        acct.Visitor_Country__c = 'In';
        update acct;
 
        Opportunity oppTest = new Opportunity();
        oppTest.Name = 'oppName';
        oppTest.AccountId = acct.Id;//testLead.ConvertedAccountId;
        oppTest.Event__c = eventTest.Id;
        oppTest.StageName = 'Closed Won';
        oppTest.CloseDate = System.today();
        oppTest.Contact_Site__c = 'quintevents.com';
        oppTest.Payment_Method__c = 'Check';
        //oppTest.email__c = 'abcedgft@gmail.com';
        oppTest.Amount = 1;
        oppTest.Primary_Contact__c = conn.id; 
        //oppTest.Communications_Contact__c = conn1.id;
        oppTest.Email__c = 'test@gmail.com';
        oppTest.Reason_For_Cancellation__c = '';
        //try{
        insert oppTest;
        
        oppTest.StageName = 'Defaulted';
        update oppTest;
        
        Account a = new Account();
        a.Id = testLead.convertedAccountId;
        a.personEmail = 'nhdgr@gmail.com';
        
        a.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'BusinessAccount' LIMIT 1].Id;
        
        Contact c = new Contact();
        c.Lastname = 'abdcgname';
        c.firstname = 'abcname';
        c.email = 'test@test.com';
        c.primary_contact__C = true;
        insert c;
        Test.startTest();
        
        Opportunity oppTest1 = new Opportunity();
        oppTest1.Name = eventTest.name;
        oppTest1.AccountId = a.Id;
        oppTest1.Event__c = eventTest.Id;
        oppTest1.StageName = 'Value Proposition';
        oppTest1.CloseDate = System.today();
        oppTest1.Contact_Site__c = 'quintevents.com';
        oppTest1.Payment_Method__c = 'Check'; 
        //oppTest1.Email__c = 'ahgtest@gmail.com'; 
        oppTest1.Primary_contact__c = conn.Id;//a.primary_Contact__C;  
        //oppTest1.Reason_For_Cancellation__c          
        try{ 
            insert oppTest1;            
        }
        catch(dmlexception e)
        {       
            system.debug('::::::::::::ERROR'+e.getmessage());
        }
        // Add quote to validate validation rule.
        Quote testQuote = new Quote();
        testQuote.OpportunityId = oppTest.Id;
        testQuote.Email = 'htevv@gmail.com';//oppTest.Email__c;
        try{
            insert testQuote;
            System.debug('testQuote Id:'+testQuote.id);
        }
        catch(DMLException e) {
            System.debug('Error:::'+e);
        }
        
        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity> ();
        oldMap.put(oppTest.Id,oppTest);
        List<Opportunity> oldList = new List<Opportunity>();
        oldList.add(oppTest);
        
        
        
        oppTest.StageName =  'Closed won';

        oppTest.Online_Order__c = False;
        
        try {
            update oppTest;
        }
        catch(DMLException e) {
        }      
        oppTest.StageName =  'Defaulted';
    
        try{
            update oppTest;
        }
        catch(DMLException e) {
        }
        
        Test.stopTest();
    }
/*    static testMethod void test_method_two() {
        Test.startTest();
        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        Insert eventTest;
        
        // Insert Test Account
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testNameiw';
        lead.LastName = 'testNamels';
        lead.Status = 'Qualified';
        lead.Source__c = 'call Virtuoso';
        lead.Email = 'testemailhdr@quintevents.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
        contact con2 = new contact();
        con2.email = 'testc1@gmail.com';
        con2.phone = '1234';
        con2.lastname = 'abc';
        con2.firstname = 'dgrf';
        insert con2;
        
        Account acct = new Account();
        acct.id = testLead.ConvertedAccountId;
        acct.Visitor_Country__c = 'test visitor country';
        acct.AccountSource = 'call cotaexperiences.com';
        acct.BillingStreet = 'acstreet';
        acct.Personemail = 'tst@gmail.com';
        acct.Primary_Contact__c = con2.Id;
        update acct;
        
        Account accounts = new Account();
        accounts.RecordTypeId = '012i00000015Y4x';
        accounts.Name = 'Test Account';
        accounts.CurrencyIsoCode = 'USD';
        insert accounts;
        
        contact con1 = new contact();
        con1.email = 'test1@gmail.com';
        con1.phone = '1234';
        con1.lastname = 'abc';
        con1.firstname = 'dgrf';
        con1.AccountId = accounts.Id;
        insert con1;
        
        Opportunity oppTest = new Opportunity();
        oppTest.Name = eventTest.name;
        oppTest.AccountId = accounts.Id;//testLead.ConvertedAccountId;
        oppTest.Event__c = eventTest.Id;
        oppTest.StageName = 'Value Proposition';
        oppTest.CloseDate = System.today();
        oppTest.Contact_Site__c = 'quintevents.com';
        oppTest.Payment_Method__c = 'check'; 
        oppTest.Email__c = 'testdfsuc@gmail.com';    
        oppTest.Bill_To_Name__c = con1.Name;
        oppTest.Billing_Street__c = acct.Name + ' ' +acct.BillingStreet;
        oppTest.order_payment_status__c = 'Not Paid';
        oppTest.Primary_contact__c = con1.Id; 
        //try{  
        insert oppTest;  
        system.assert(oppTest != null,'Opportunity Record inserted');
        if(oppTest.Email__c == acct.PersonEmail) {
            ApexPages.Message errMsg= new ApexPages.Message(ApexPages.severity.ERROR, 'please enter a new email');
            ApexPages.addMessage(errMsg);
        }
        
        Opportunity oppTest1 = new Opportunity();
        oppTest1.Name = eventTest.name;
        oppTest1.AccountId = accounts.Id;//testLead.ConvertedAccountId;
        oppTest1.Event__c = eventTest.Id;
        oppTest1.StageName = 'Defaulted';
        oppTest1.CloseDate = System.today();
        oppTest1.Contact_Site__c = 'quintevents.com';
        oppTest1.Payment_Method__c = 'check'; 
        oppTest1.Email__C = 'tesdtcv@gmail.com';
        oppTest1.Primary_contact__c = con1.Id;
        //oppTest1.Reason_For_Cancellation__c = 
        insert oppTest1;
        
        List<opportunity> oppLst = new List<opportunity>();
        oppLst.add(oppTest1);
        Opportunity oppTest2 = new Opportunity();
        oppTest2 = oppTest1;
        oppTest2.StageName = 'Closed Won';
        Map<Id,Opportunity> newMap = new Map<Id,Opportunity> ();
        newMap.put(oppTest2.Id,oppTest2);
        QE_opportunityHandler handlerDel = new QE_opportunityHandler();
        handlerDel.OnAfterDelete(oppLst);
        handlerDel.OnBeforeUpdate(oppLst, oppLst, newMap,newMap);
        
        Quote testQuote = new Quote();
        testQuote.OpportunityId = oppTest.Id;
        testQuote.Email = 'testvv@gmail.com';//oppTest.Email__c;
        try{
            insert testQuote;
            System.debug('testQuote Id:'+testQuote.id);
        }
        catch(DMLException e) {
            System.debug('Error:::'+e);
        }
        
        oppTest.StageName = 'Qualified';
        update oppTest;
        Id pricebookId = Test.getStandardPricebookId();
        
        Parent_Package__c parentPakg = new Parent_Package__c(Event__c = eventTest.Id, Name='Test Parent pkg');
        insert parentPakg;
        //Create your product
        Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true,
            Parent_Package__c = parentPakg.Id,
            Event__c = eventTest.Id,
            Allocated__c = true
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        //create your opportunity line item. 
        List<OpportunityLineItem> opLineItemList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> opLineItemListUpdate = new List<OpportunityLineItem>();
        
        
        for(Integer i=0;i<20;i++){
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = oppTest.Id;
            oli.Quantity = 5+i;
            oli.producttype__c ='F1 access code';
            oli.PricebookEntryId = pbEntry.Id;
            oli.TotalPrice = 10000;
            oli.Product2Id = prod.Id;
            opLineItemList.add(oli);
        }
        //insert opLineItemList;// -------------------commented by manan
        System.debug('*** oline items**'+opLineItemList.size());
       
        Test.stopTest();
    }
    
    static testmethod void testmethodvalidate(){
        
        //Map<id,opportunity> oldeveMap = new Map<id,opportunity>();
        //Map<id,opportunity> neweveMap = new Map<id,opportunity>();
        QE360_Event__c eventTest2 = new QE360_Event__c();
        eventTest2.Name = 'test21';
        Insert eventTest2;
        
        Lead leads = new Lead();
        leads.FirstName = 'testhh';
        leads.LastName = 'testzshh';
        leads.Lead_Type__c = 'Business';
        leads.Status = 'Qualified';
        leads.Source__c = 'call cotaexperiences.com';
        leads.Email = 'testmails@quintevents.com';
        insert leads;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(Leads .id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');//Converted
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        Lead testLeads = [select Id, IsConverted, ConvertedAccountId from Lead where Id =:leads.Id AND isConverted=true];
        
        Account acc = [SELECT id,RecordType.Name  FROM account where id=:testLeads.ConvertedAccountId];
        acc.RecordTypeId =accBussinessRcdId;
        update acc;
        Account acc1 = new Account();
        acc1.id =testLeads.ConvertedAccountId;
        acc1.personEmail ='testmails@quintevents.com';
        update acc1;
        
        Reseller__c testReseller = new Reseller__c(Default_Commission__c =1.00);
        Insert testReseller;
        
        Promoter__c testPromoter = new Promoter__c(Online_Sales_Commission__c=1.00, A_La_Carte_Commission__c=2.00, 
                                                   Package_with_Hotel_Commission__c=3.00, Package_without_Hotel_Commission__c=4.00);
        Insert testPromoter;
        
        contact con = new contact();
        con.email = 'test14521@gmail.com';
        con.AccountId = acc.id;
        con.phone = leads.phone;
        con.Primary_Contact__c=true;
        con.Source__c = leads.Source__c;
        con.lastname = 'telast';
        insert con;
        system.debug('*****contact inserted*****'+con);
        contact con1 = new contact();
        con1.email = leads.Email;
        con1.AccountId = acc.id;
        con1.phone = leads.phone;
        con1.Primary_Contact__c=true;
        con1.Source__c = leads.Source__c;
        con1.lastname = 'testing';
        insert con1;
        system.debug('*****contact inserted*1****'+con1);
        system.assert(con1 !=null,'contact inserted');
        
        Opportunity oppTest = new Opportunity();
        oppTest.Name = eventTest2.Name;
        if(acc.id!=null)
            oppTest.AccountId = acc.Id;
        if(eventTest2.id!=null)
            oppTest.Event__c = eventTest2.Id;
        oppTest.StageName = 'Value Proposition';
        oppTest.CloseDate = System.today();
        oppTest.Contact_Site__c = 'quintevents.com';
        oppTest.Payment_Method__c = 'check'; 
        oppTest.Email__c ='testmadils@quintevents.com';  
        oppTest.Primary_Contact__c = con.id; 
        oppTest.RecordTypeId=OppRcdId;
        try{     
            insert oppTest;
        }catch(DMLException e){
        }
        
        system.debug('****oppp#############*******'+oppTest);
        oppTest.phone__c ='122222222222';
        oppTest.Email__c ='Test22@gmail.com';
        oppTest.Bill_To_Name__c = con1.Name;
        try{
            if(oppTest!=null)
                update oppTest;
            
        }
        catch(DMLException e) {
        }
        List<Id> oppSet = new List<Id>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QE_MockHttpResEventHandler());
        QE_brandFuelDatainsert.checkUserExists('test bill1','bill@test1.com',oppTest.id,oppSet,eventTest2.id,'testName0',system.today(),true,con1.id,system.today()); 
        Test.stopTest();
    }
    
    Static testmethod void testmethodvalidate1(){
        //Test.startTest(); 
        Id oppIDtest;
        List<contact> conList = new List<contact>();
        List<Id> oppSet = new List<Id>();
        QE360_Event__c eventTest2 = new QE360_Event__c();
        eventTest2.Name = 'bdf test';
        Insert eventTest2;
        
        
        Lead leads = new Lead();
        leads.FirstName = 'testNameleads3';
        leads.LastName = 'testzs';
        leads.Lead_Type__c = 'Business';
        leads.Status = 'Qualified';
        leads.Source__c = 'call cotaexperiences.com';
        leads.Email = 'testmails@quintevents.com';
        insert leads;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(Leads .id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        Lead testLeads = [select Id, IsConverted, ConvertedAccountId from Lead where Id =:leads.Id AND isConverted=true];
        
        Account acc = [SELECT id,RecordType.Name  FROM account where id=:testLeads.ConvertedAccountId];
        acc.RecordTypeId =accBussinessRcdId;
        update acc;
        
        Reseller__c testReseller = new Reseller__c(Default_Commission__c =1.00);
        Insert testReseller;
        
        Promoter__c testPromoter = new Promoter__c(Online_Sales_Commission__c=1.00, A_La_Carte_Commission__c=2.00, 
                                                   Package_with_Hotel_Commission__c=3.00, Package_without_Hotel_Commission__c=4.00);
        Insert testPromoter;
        
        contact con = new contact();
        con.email = 'test234@gmail.com';
        con.AccountId = acc.id;
        con.phone = leads.phone;
        con.Primary_Contact__c=true;
        con.Source__c = leads.Source__c;
        con.lastname = 'telast';
        insert con;
        system.debug('*****contact inserted*****'+con);
        contact con1 = new contact();
        con1.email = leads.Email;
        con1.AccountId = acc.id;
        con1.phone = leads.phone;
        con1.Primary_Contact__c=true;
        con1.Source__c = leads.Source__c;
        con1.lastname = 'testing';
        conList.add(con1);
        insert conList;
        system.debug('*****contact inserted*1****'+con1);
        system.assert(con1 !=null,'contact inserted');
        
        
        
        Opportunity oppTest = new Opportunity();
        oppTest.Name = eventTest2.Name;
        if(acc.id!=null)
            oppTest.AccountId = acc.Id;
        if(eventTest2.id!=null)
            oppTest.Event__c = eventTest2.Id;
        oppTest.CurrencyIsoCode = 'GBP';
        oppTest.StageName = 'Value Proposition';
        oppTest.CloseDate = System.today();
        oppTest.Contact_Site__c = 'quintevents.com';
        oppTest.Payment_Method__c = 'check'; 
        oppTest.Email__c = 'tesdt131@test.com';  
        oppTest.Primary_Contact__c = conList[0].id;      
        insert oppTest;
        
        if(oppTest != null)
            oppTest.Primary_Contact__c = con1.id;    
        oppTest.brandfuel_customer_link__c = 'Https://vip.shopping.com'; 
        update oppTest;
        
        opportunity_attendee__C optAtt = new opportunity_attendee__C();
        optAtt.name = conList[0].name;
        optAtt.opportunity__C = oppTest.id;
        optAtt.contact__C = conList[0].id;
        //optAtt.email__C = oppTest.email__c;
        insert optAtt;
        
        Brandfuel_coupon__c bfC1 = new Brandfuel_coupon__c(Name='Test BF');
        bfC1.Contact__c = conList[0].id;
        bfC1.Event__c = eventTest2.Id;
        bfC1.Coupon_Id__c = '124';
        Brandfuel_coupon__c bfC2 = new Brandfuel_coupon__c(Name='Test BF11');
        bfC2.Contact__c = conList[0].id;
        bfC2.Event__c = eventTest2.Id;
        bfC2.Coupon_Id__c = '1245';
        insert new List<Brandfuel_coupon__c>{bfC1,bfC2};
            
            contact cont1 = new contact();
        cont1.email = 'testing@gmail.com';//oppTest.Email__c;
        cont1.lastname = 'atest';
        con1.AccountId = oppTest.accountID;
        insert cont1;
        
        
        if(oppTest.Email__c == con1.Email && acc.RecordtypeId == accBussinessRcdId) {
            ApexPages.Message errMsg= new ApexPages.Message(ApexPages.severity.ERROR, 'please enter a new email');
            ApexPages.addMessage(errMsg);
        }
        oppTest.Email__c = 'tgfrtest@gmail.com';
        update oppTest;
        String userKey = 'hrjrnfn76677';
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new QE_MockHttpResEventHandler());
        QE_brandFuelDatainsert.createUser('test bill','bill@test.com',oppTest.id,oppSet,eventTest2.id,'testName',system.today(),true,conList[0].id,system.today());       
        //QE_brandFuelDatainsert.cuponDataInsert('test bill1',oppSet,'testhna',oppTest.id,'60',oppTest.Email__c,oppTest.CloseDate,'ce09d8044f5821cbe261f46b3457024d',conList[0].id,'789',system.today());
        QE_brandFuelDatainsert.cuponDataSubMethod(oppTest.id,oppSet,'4417',eventTest2.id,'test@test.com',system.today(),userKey,System.today());
       
        Test.stopTest();
    }
    Static testmethod void testmethodvalidate2(){
        //Test.startTest(); 
        Id oppIDtest;
        List<contact> conList = new List<contact>();
        List<Id> oppSet = new List<Id>();
        QE360_Event__c eventTest2 = new QE360_Event__c();
        eventTest2.Name = 'bdf test';
        Insert eventTest2;
        
        
        Lead leads = new Lead();
        leads.FirstName = 'testNameleads3';
        leads.LastName = 'testzs';
        leads.Lead_Type__c = 'Business';
        leads.Status = 'Qualified';
        leads.Source__c = 'call cotaexperiences.com';
        leads.Email = 'testmails@quintevents.com';
        insert leads;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(Leads .id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        Lead testLeads = [select Id, IsConverted, ConvertedAccountId from Lead where Id =:leads.Id AND isConverted=true];
        
        Account acc = [SELECT id,RecordType.Name  FROM account where id=:testLeads.ConvertedAccountId];
        acc.RecordTypeId =accBussinessRcdId;
        update acc;
        
        Reseller__c testReseller = new Reseller__c(Default_Commission__c =1.00);
        Insert testReseller;
        
        Promoter__c testPromoter = new Promoter__c(Online_Sales_Commission__c=1.00, A_La_Carte_Commission__c=2.00, 
                                                   Package_with_Hotel_Commission__c=3.00, Package_without_Hotel_Commission__c=4.00);
        Insert testPromoter;
        
        contact con = new contact();
        con.email = 'test234@gmail.com';
        con.AccountId = acc.id;
        con.phone = leads.phone;
        con.Primary_Contact__c=true;
        con.Source__c = leads.Source__c;
        con.lastname = 'telast';
        insert con;
        system.debug('*****contact inserted*****'+con);
        contact con1 = new contact();
        con1.email = leads.Email;
        con1.AccountId = acc.id;
        con1.phone = leads.phone;
        con1.Primary_Contact__c=true;
        con1.Source__c = leads.Source__c;
        con1.lastname = 'testing';
        conList.add(con1);
        insert conList;
        system.debug('*****contact inserted*1****'+con1);
        system.assert(con1 !=null,'contact inserted');
        
        
        Opportunity oppTest = new Opportunity();
        oppTest.Name = eventTest2.Name;
        if(acc.id!=null)
            oppTest.AccountId = acc.Id;
        if(eventTest2.id!=null)
            oppTest.Event__c = eventTest2.Id;
        oppTest.CurrencyIsoCode = 'GBP';
        oppTest.StageName = 'Closed Won';
        oppTest.CloseDate = System.today();
        oppTest.Contact_Site__c = 'quintevents.com';
        oppTest.Payment_Method__c = 'check'; 
        oppTest.Email__c = 'tesdt3@test.com';  
        oppTest.Primary_Contact__c = conList[0].id;      
        insert oppTest;
        
        
        Test.startTest();
        Quote quot = new Quote();
        quot.OpportunityId = oppTest.Id;
        quot.Name='Test Quote1';
        quot.Status='Draft';
        insert quot;
        System.debug([Select Id,Exchange_Rate_Date__c from Opportunity where ID=:oppTest.Id]);
        
        Test.stopTest();
    }*/
    public static testmethod void test_method_three(){
        
        Account accounts = new Account();
        accounts.RecordTypeId = '012i00000015Y4x';
        accounts.Name = 'Test Account';
        accounts.CurrencyIsoCode = 'USD';
        //accounts.Source__pc = 'web sportevents.com';
        //accounts.PersonEmail = 'tttt@gmail.com';
        insert accounts;
        
        Contact conn1 = new Contact();
        conn1.LastName = 'Test Last Name';
        conn1.AccountId = accounts.Id;
        conn1.CurrencyIsoCode = 'USD';
        conn1.Email = 'tesdfgdt@gmail.com';
        insert conn1;
        
        Contact conn = new Contact();
        conn.LastName = 'Test Last Name1';
        conn.AccountId = accounts.Id;
        conn.CurrencyIsoCode = 'USD';
        conn.Email = 'tessdhrtfgdt@gmail.com';
        insert conn;
        
        
        QE360_Event__c eventTest2 = new QE360_Event__c();
        eventTest2.Name = 'bdf test';
        eventTest2.GPE_Event__c = true;
        Insert eventTest2;
        
        Opportunity oppTest = new Opportunity();
        oppTest.Name = eventTest2.Name;
        if(accounts.id!=null)
            oppTest.AccountId = accounts.Id;
        if(eventTest2.id!=null)
            oppTest.Event__c = eventTest2.Id;
        oppTest.CurrencyIsoCode = 'GBP';
        oppTest.StageName = 'Closed Won';
        oppTest.CloseDate = System.today();
        oppTest.Contact_Site__c = 'quintevents.com';
        oppTest.Payment_Method__c = 'check'; 
        oppTest.Email__c = 'tesdtds3@test.com';  
        oppTest.Primary_Contact__c = conn1.id;
        oppTest.Communications_Contact__c = conn.id;      
        insert oppTest;
        
        oppTest.Primary_Contact__c = null;
        oppTest.Communications_Contact__c = conn.Id;
        update oppTest;
        
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
        oldMap.put(oppTest.Id, oppTest);
        
        Opportunity oppTest1 = new Opportunity();
        oppTest1.Id = oppTest.Id;
        oppTest1.Primary_Contact__c = conn.id;
        oppTest1.StageName = 'Canceled';
        oppTest1.Tracking_Number__c ='test';
        //update opptest1;
        //update oppTest1;
        
        List<Opportunity> oppTestList = new List<Opportunity>();
        oppTestList.add(oppTest1);
        Map<Id, Opportunity> newMap = new Map<Id, Opportunity>();
        newMap.put(oppTest1.Id, oppTest1);
        QE_opportunityHandler handler = new QE_opportunityHandler();
        handler.OnBeforeUpdate(oppTestList, oppTestList, newMap, oldMap);
        
        /*StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GPEJson');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        //req.setEndpoint('http://ec2-35-157-98-201.eu-central-1.compute.amazonaws.com:8080/api/v1.1/gpt/en/order/'+oppObj.Event__r.GPT_Event_Id__c);
        mock.setHeader('Content-Type', 'application/json');
        mock.setHeader('Cache-Control', 'no-cache');
        */
        
        //mock.setHeader('Accept', '*/*');
        //mock.setHeader('Authorization', 'Bearer Qe1v0yrj9XTDwJHkWNF3Mu2lLQzlvz6swblTQJleHHncpMdqL7v6S3bmzAxu');        
        //Test.setMock(HttpCalloutMock.class, mock);
    }
}
/**
 * @File Name          : QE_GiftCodeHandler_Test.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 4:04:31 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
public class QE_GiftCodeHandler_Test{
    static testmethod void setupTestData(){

        List<QE360_Event__c> eventList = new List<QE360_Event__c>();
        QE360_Event__c eventTest = new QE360_Event__c();
        for(integer i=0;i<10;i++) {
            QE360_Event__C evntQE = new QE360_Event__C();
            evntQE.name = 'testev'+i;
            eventList.add(evntQE);
        }
        insert eventList;

        // Insert Test Account
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'lgaID';
        lead.Google_Analytics_Site_Id__c = 'lgaSiteId';
        lead.FirstName = 'testNamelead';
        lead.LastName = 'test';
        lead.Status = 'Qualified';
        lead.Source__c = 'call cotaexperiences.com';
        lead.Email = 'testemails@quintevents.com';
        //insert lead;

        Lead lead1 = new Lead();
        lead1.Google_Analytics_ID__c = 'gaID';
        lead1.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead1.FirstName = 'testNameabc';
        lead1.LastName = 'test';
        lead1.Status = 'Qualified';
        lead1.Source__c = 'call Virtuoso';
        lead1.Email = 'testemail12@quintevents.com';
        insert new List<Lead> {lead, lead1};

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Database.LeadConvert lc1 = new database.LeadConvert();
        lc1.setLeadId(lead1.id);
        lc1.setDoNotCreateOpportunity(true);
        lc1.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr1 = Database.convertLead(lc1);

        List<Lead> testLeads = [select Id, IsConverted, ConvertedAccountId from Lead where Id In (:lead.Id, :lead1.Id)];
        Lead testLead = testLeads[0];
        Lead testLead1 = testLeads[1];

        List<Account> accList = new List<Account>();
        Account acct = new Account();
        acct.id = testLead.ConvertedAccountId;
        acct.Visitor_Country__c = 'test visitor country';
        //acct.Promoters_Name__c = testPromoter.Id;
        acct.PersonEmail = 'testEmail@gmail.com';
        accList.add(acct);

        Account accn = new Account();
        accn.id = testLead1.ConvertedAccountId;
        accn.PersonEmail = 'test1@gmail.com';
        accList.add(accn);
        update accList;

        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc= new Account(
          RecordTypeID=recordTypeId ,
          FirstName='Test FName',
          LastName='Test LName',
          PersonMailingStreet='test@yahoo.com',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonEmail='test@yahoo.com',
          PersonHomePhone='1234567',
          PersonMobilePhone='12345678'
        );

        //insert acc;

        Contact cn = new Contact ();
        cn.LastName = 'testlast';
        cn.Email = 'abcedgft@gmail.com';
        //insert cn;

        Account a =new Account();
        a.Name = 'testNMe';
        //a.Primary_Contact__r.Email = cn.Email;
        //insert a;
        insert new List<Account>{a, acc};
        //acc= [SELECT Id, PersonContactId FROM Account where Id =: acc.Id];

        Contact objcon = new Contact(LastName='Test',AccountId = a.id,Email = 'testadb@gmail.com');
        insert new List<Contact>{objcon, cn};

        Id RecordTypeIdOpp = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Person Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        //opp.RecordTypeId = RecordTypeIdOpp ;
        opp.Event__c = eventList[0].Id;
        opp.AccountId = a.id;
        opp.paid_in_full__C = true;
        opp.StageName = 'Qualified';
        opp.Payment_Method__c = 'Check';
        opp.CloseDate = system.today();
        opp.email__c = 'testadb@gmail.com';
        opp.Contact_Site__c = 'quintevents.com';
        opp.Primary_Contact__c = objcon.id;
        opp.Primary_Attendee__c= objcon.id;

        insert opp;

        Contact con =new Contact(LastName='Test',Primary_Contact__c=true,AccountId=testLead.ConvertedAccountId,Opportunity__c=opp.Id);
        //insert con;

        Id pricebookId = Test.getStandardPricebookId();

        Program__c program = new Program__c();
        program.Name = 'test prgram F1E';
        insert program;

        QE360_Event__c events = new QE360_Event__c();
        events.Name = 'Test Event';
        events.CurrencyIsoCode = 'USD';
        events.Program__c = program.Id;
        insert events;

        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = events.Id;
        insert parentPackage;

        product2 prod =new product2();
        prod.RecordTypeId = '012i00000012AZs';
        prod.Name = 'Test Product';
        prod.Event__c = events.Id;
        prod.Type__c = 'Hotel';
        prod.CurrencyIsoCode = 'USD';
        prod.Price__c = 120.00;
        prod.A_La_Carte__c = true;
        prod.isActive = true;
        prod.Parent_Package__c = parentPackage.Id;
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
        for(Integer i=0;i<20;i++) {
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = opp.Id;
            oli.Quantity = 1;
            oli.producttype__c ='F1 access code';
            oli.PricebookEntryId = pbEntry.Id;
            oli.TotalPrice = 10000 + i;
            opLineItemList.add(oli);
        }
        Test.startTest();
        insert opLineItemList;

        //Test.startTest();
        //List<RecordType> lstRec = [Select id from RecordType where sobjecttype = 'Gift_Code__c' and name ='F1 access code'];
        Id giftCodeRecId = Schema.getGlobalDescribe().get('Gift_Code__c').getDescribe().getRecordTypeInfosByName().get('F1 Access Code').getRecordTypeId();
        List<Gift_Code__c> f1lst= new List<Gift_Code__c>();
        for(integer i=0;i<30;i++){
            Gift_Code__c f1 = new Gift_Code__c();
            f1.Gift_Code__c = 'test1'+i;
            f1.opportunity__c=null;
            f1.RecordTypeId = giftCodeRecId;
            f1lst.add(f1);
        }
        insert f1lst;

        List<Gift_Code__c> f1lstListForupdate = new List<Gift_Code__c>();
        //List<Gift_Code__c> f1lstList =[SELECT Id,Opportunity__c FROM Gift_Code__c where Gift_Code__c like '%test1%' LIMIT 10];
        Integer intcnt = 0;
        for(Gift_Code__c fcc : f1lst){
          fcc.opportunity__c= opp.Id;
          f1lstListForupdate.add(fcc);
          intcnt++;
          if(intcnt==10){
              break;
          }
        }
        if(!f1lstListForupdate.isEmpty()){
            update f1lstListForupdate;
        }

        // Opportunity_Payment_Terms__c oppPayTermTest = new Opportunity_Payment_Terms__c(Status__c = 'Passed',Payment_Term__c = '100%', Amount__c=100,Percentage_Of_Payment__c=1, Opportunity__c = opp.Id,Payment_Due_date__c = system.today().adddays(-4));
        // insert oppPayTermTest;

        opp.StageName ='Closed Won';
        opp.paid_in_full__C =true;
        opp.F1_Access_Code_Assignment_Pending__c = true;
        update opp;

        f1lst= new List<Gift_Code__c>();
        for(integer i=0;i<30;i++){
            Gift_Code__c f1 = new Gift_Code__c();
            f1.Gift_Code__c = 'test1'+i;
            f1.opportunity__c=null;
            f1.RecordTypeId = giftCodeRecId;
            f1lst.add(f1);
        }
        insert f1lst;
        Test.stopTest();
    }

    static testmethod void setupTestData1(){
        List<QE360_Event__c> eventList = new List<QE360_Event__c>();
        QE360_Event__c eventTest = new QE360_Event__c();
        for(integer i=0;i<10;i++) {
        QE360_Event__C evntQE = new QE360_Event__C();
        evntQE.name = 'testev'+i;
        eventList.add(evntQE);
        }
        insert eventList;


        // Insert Test Account
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
        lc.setConvertedStatus('Converted');
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

        List<Account> accList = new List<Account>();
        Account acct = new Account();
        acct.id = testLead.ConvertedAccountId;
        acct.Visitor_Country__c = 'test visitor country';
        //acct.Promoters_Name__c = testPromoter.Id;
        acct.PersonEmail = 'testEmail@gmail.com';
        accList.add(acct);

        Account accn = new Account();
        accn.id = testLead1.ConvertedAccountId;
        accn.PersonEmail = 'test1@gmail.com';
        accList.add(accn);
        update accList;


        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc= new Account(
          RecordTypeID=recordTypeId ,
          FirstName='Test FName',
          LastName='Test LName',
          PersonMailingStreet='test@yahoo.com',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonEmail='test@yahoo.com',
          PersonHomePhone='1234567',
          PersonMobilePhone='12345678'
        );

        insert acc;
        Contact cn = new Contact ();
        cn.LastName = 'testlast';
        cn.Email = 'abcedgft@gmail.com';
        insert cn;

        acc= [SELECT Id, PersonContactId FROM Account where Id =: acc.Id];
        Account a =new Account();
        a.Name = 'testNMe';
        //a.Primary_Contact__r.Email = cn.EMail;
        insert a;

        Contact objcon = new Contact(LastName='Test',AccountId= a.id,Email = 'testadb@gmail.com');
        insert objcon;

        Id RecordTypeIdOpp = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Person Opportunity').getRecordTypeId();

        Opportunity opp = new Opportunity();
        //opp.RecordTypeId = RecordTypeIdOpp ;
        opp.Name = 'Test Opp';
        opp.Event__c = eventList[0].Id;
        opp.AccountId = a.id;
        opp.paid_in_full__C = true;
        opp.StageName = 'Qualified';
        opp.Payment_Method__c = 'Check';
        opp.CloseDate = system.today();
        opp.Primary_Contact__c = objcon.id;
        opp.Primary_Attendee__c= objcon.id;
        insert opp;

        Contact con =new Contact(LastName='Test',Primary_Contact__c=true,AccountId=testLead.ConvertedAccountId,Opportunity__c=opp.Id);
        //insert con;

        Id pricebookId = Test.getStandardPricebookId();

        Program__c program = new Program__c();
        program.Name = 'test prgram F1E';
        insert program;

        QE360_Event__c events = new QE360_Event__c();
        events.Name = 'Test Event';
        events.CurrencyIsoCode = 'USD';
        events.Program__c = program.Id;
        insert events;

        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = events.Id;
        insert parentPackage;

        product2 prod =new product2();
        prod.RecordTypeId = '012i00000012AZs';
        prod.Name = 'Test Product';
        prod.Event__c = events.Id;
        prod.Type__c = 'Hotel';
        prod.CurrencyIsoCode = 'USD';
        prod.Price__c = 120.00;
        prod.A_La_Carte__c = true;
        prod.isActive = true;
        prod.Parent_Package__c = parentPackage.Id;
        insert prod;

        Test.startTest();

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
        for(Integer i=0;i<20;i++){
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = opp.Id;
            oli.Quantity = 1;
            oli.producttype__c ='Fanatics Gift Code';
            oli.PricebookEntryId = pbEntry.Id;
            oli.TotalPrice = 10000+i;
            opLineItemList.add(oli);
        }
        insert opLineItemList;

        List<RecordType> lstRec = [Select id from RecordType where sobjecttype = 'Gift_Code__c' and name = 'Fanatics Gift Code'];
        system.debug('lstRec @@@@ ' + lstRec);
        List<Gift_Code__c> f1lst= new List<Gift_Code__c>();
        for(integer i=0;i<30;i++){
            Gift_Code__c f1 = new Gift_Code__c();
            f1.Gift_Code__c = 'test1'+i;
            f1.opportunity__c=null;
            f1.RecordTypeId = lstRec[0].id;
            f1lst.add(f1);
        }
        insert f1lst;

        // Opportunity_Payment_Terms__c oppPayTermTest = new Opportunity_Payment_Terms__c(Status__c = 'Passed',Payment_Term__c = '100%', Amount__c=100,Percentage_Of_Payment__c=1, Opportunity__c = opp.Id, Payment_Due_date__c = system.today().adddays(-5));
        // insert oppPayTermTest;

        opp.StageName ='Closed Won';
        opp.paid_in_full__C =true;
        opp.Fanatics_Gift_Code_Assignment_Pending__c = true;
        update opp;

        f1lst= new List<Gift_Code__c>();
        for(integer i=0;i<30;i++){
            Gift_Code__c f1 = new Gift_Code__c();
            f1.Gift_Code__c = 'test1'+i;
            f1.opportunity__c=null;
            f1.RecordTypeId = lstRec[0].id;
            f1lst.add(f1);
        }
        insert f1lst;
        Test.stopTest();

    }
    static testmethod void setupTestData11(){
        List<QE360_Event__c> eventList = new List<QE360_Event__c>();
        QE360_Event__c eventTest = new QE360_Event__c();
        for(integer i=0;i<10;i++) {
        QE360_Event__C evntQE = new QE360_Event__C();
        evntQE.name = 'testev'+i;
        eventList.add(evntQE);
        }
        insert eventList;


        // Insert Test Account
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
        lc.setConvertedStatus('Converted');
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

        List<Account> accList = new List<Account>();
        Account acct = new Account();
        acct.id = testLead.ConvertedAccountId;
        acct.Visitor_Country__c = 'test visitor country';
        //acct.Promoters_Name__c = testPromoter.Id;
        acct.PersonEmail = 'testEmail@gmail.com';
        accList.add(acct);

        Account accn = new Account();
        accn.id = testLead1.ConvertedAccountId;
        accn.PersonEmail = 'test1@gmail.com';
        accList.add(accn);
        update accList;


        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc= new Account(
          RecordTypeID=recordTypeId ,
          FirstName='Test FName',
          LastName='Test LName',
          PersonMailingStreet='test@yahoo.com',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonEmail='test@yahoo.com',
          PersonHomePhone='1234567',
          PersonMobilePhone='12345678'
        );

        insert acc;
        Contact cn = new Contact ();
        cn.LastName = 'testlast';
        cn.Email = 'abcedgft@gmail.com';
        insert cn;

        acc= [SELECT Id, PersonContactId FROM Account where Id =: acc.Id];
        Account a =new Account();
        a.Name = 'testNMe';
        //a.Primary_Contact__r.Email = cn.EMail;
        insert a;

        Contact objcon = new Contact(LastName='Test',AccountId= a.id,Email = 'testadb@gmail.com');
        insert objcon;

        Id RecordTypeIdOpp = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Person Opportunity').getRecordTypeId();

        Opportunity opp = new Opportunity();
        //opp.RecordTypeId = RecordTypeIdOpp ;
        opp.Name = 'Test Opp';
        opp.Event__c = eventList[0].Id;
        opp.AccountId = a.id;
        opp.paid_in_full__C = true;
        opp.StageName = 'Qualified';
        opp.Payment_Method__c = 'Check';
        opp.CloseDate = system.today();
        opp.Primary_Contact__c = objcon.id;
        opp.Primary_Attendee__c= objcon.id;
        insert opp;

        Contact con =new Contact(LastName='Test',Primary_Contact__c=true,AccountId=testLead.ConvertedAccountId,Opportunity__c=opp.Id);
        //insert con;

        Id pricebookId = Test.getStandardPricebookId();

        Program__c program = new Program__c();
        program.Name = 'test prgram F1E';
        insert program;

        QE360_Event__c events = new QE360_Event__c();
        events.Name = 'Test Event';
        events.CurrencyIsoCode = 'USD';
        events.Program__c = program.Id;
        insert events;

        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = events.Id;
        insert parentPackage;

        product2 prod =new product2();
        prod.RecordTypeId = '012i00000012AZs';
        prod.Name = 'Test Product';
        prod.Event__c = events.Id;
        prod.Type__c = 'Hotel';
        prod.CurrencyIsoCode = 'USD';
        prod.Price__c = 120.00;
        prod.A_La_Carte__c = true;
        prod.isActive = true;
        prod.Parent_Package__c = parentPackage.Id;
        insert prod;

        Test.startTest();
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
        for(Integer i=0;i<20;i++){

            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = opp.Id;
            oli.Quantity = 1;
            oli.producttype__c ='Memento Premium';
            oli.PricebookEntryId = pbEntry.Id;
            oli.TotalPrice = 10000+i;
            opLineItemList.add(oli);
        }
        insert opLineItemList;


        List<RecordType> lstRec = [Select id from RecordType where sobjecttype = 'Gift_Code__c' and name = 'Memento Premium'];
        List<Gift_Code__c> f1lst= new List<Gift_Code__c>();
        for(integer i=0;i<30;i++){
            Gift_Code__c f1 = new Gift_Code__c();
            f1.Gift_Code__c = 'test1'+i;
            f1.opportunity__c=null;
            f1.RecordTypeId = lstRec[0].id;
            f1lst.add(f1);
        }
        insert f1lst;

        // Opportunity_Payment_Terms__c oppPayTermTest = new Opportunity_Payment_Terms__c(Status__c = 'Passed',Payment_Term__c = '100%', Amount__c=100,Percentage_Of_Payment__c=1, Opportunity__c = opp.Id, Payment_Due_date__c = system.today().adddays(-5));
        // insert oppPayTermTest;

        opp.StageName ='Closed Won';
        opp.paid_in_full__C =true;
        opp.Memento_Premium_Assignment_Pending__c= true;
        update opp;

        f1lst= new List<Gift_Code__c>();
        for(integer i=0;i<30;i++){
            Gift_Code__c f1 = new Gift_Code__c();
            f1.Gift_Code__c = 'test1'+i;
            f1.opportunity__c=null;
            f1.RecordTypeId = lstRec[0].id;
            f1lst.add(f1);
        }
        insert f1lst;
        Test.stopTest();

    }
    static testmethod void setupTestData12(){
        List<QE360_Event__c> eventList = new List<QE360_Event__c>();
        QE360_Event__c eventTest = new QE360_Event__c();
        for(integer i=0;i<10;i++) {
        QE360_Event__C evntQE = new QE360_Event__C();
        evntQE.name = 'testev'+i;
        eventList.add(evntQE);
        }
        insert eventList;


        // Insert Test Account
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
        lc.setConvertedStatus('Converted');
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

        List<Account> accList = new List<Account>();
        Account acct = new Account();
        acct.id = testLead.ConvertedAccountId;
        acct.Visitor_Country__c = 'test visitor country';
        //acct.Promoters_Name__c = testPromoter.Id;
        acct.PersonEmail = 'testEmail@gmail.com';
        accList.add(acct);

        Account accn = new Account();
        accn.id = testLead1.ConvertedAccountId;
        accn.PersonEmail = 'test1@gmail.com';
        accList.add(accn);
        update accList;


        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc= new Account(
          RecordTypeID=recordTypeId ,
          FirstName='Test FName',
          LastName='Test LName',
          PersonMailingStreet='test@yahoo.com',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonEmail='test@yahoo.com',
          PersonHomePhone='1234567',
          PersonMobilePhone='12345678'
        );

        insert acc;
        Contact cn = new Contact ();
        cn.LastName = 'testlast';
        cn.Email = 'abcedgft@gmail.com';
        insert cn;

        acc= [SELECT Id, PersonContactId FROM Account where Id =: acc.Id];
        Account a =new Account();
        a.Name = 'testNMe';
        //a.Primary_Contact__r.Email = cn.EMail;
        insert a;

        Contact objcon = new Contact(LastName='Test',AccountId= a.id,Email = 'testadb@gmail.com');
        insert objcon;

        Id RecordTypeIdOpp = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Person Opportunity').getRecordTypeId();

        Opportunity opp = new Opportunity();
        //opp.RecordTypeId = RecordTypeIdOpp ;
        opp.Name = 'Test Opp';
        opp.Event__c = eventList[0].Id;
        opp.AccountId = a.id;
        opp.paid_in_full__C = true;
        opp.StageName = 'Qualified';
        opp.Payment_Method__c = 'Check';
        opp.CloseDate = system.today();
        opp.Primary_Contact__c = objcon.id;
        opp.Primary_Attendee__c= objcon.id;
        insert opp;

        Contact con =new Contact(LastName='Test',Primary_Contact__c=true,AccountId=testLead.ConvertedAccountId,Opportunity__c=opp.Id);
        //insert con;

        Id pricebookId = Test.getStandardPricebookId();

        Program__c program = new Program__c();
        program.Name = 'test prgram F1E';
        insert program;

        QE360_Event__c events = new QE360_Event__c();
        events.Name = 'Test Event';
        events.CurrencyIsoCode = 'USD';
        events.Program__c = program.Id;
        insert events;

        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = events.Id;
        insert parentPackage;

        product2 prod =new product2();
        prod.RecordTypeId = '012i00000012AZs';
        prod.Name = 'Test Product';
        prod.Event__c = events.Id;
        prod.Type__c = 'Hotel';
        prod.CurrencyIsoCode = 'USD';
        prod.Price__c = 120.00;
        prod.A_La_Carte__c = true;
        prod.isActive = true;
        prod.Parent_Package__c = parentPackage.Id;
        insert prod;

        Test.startTest();

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
        for(Integer i=0;i<20;i++){
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = opp.Id;
            oli.Quantity = 1;
            oli.producttype__c ='Memento Ultimate';
            oli.PricebookEntryId = pbEntry.Id;
            oli.TotalPrice = 10000+i;
            opLineItemList.add(oli);
        }
        insert opLineItemList;

        List<RecordType> lstRec = [Select id from RecordType where sobjecttype = 'Gift_Code__c' and name = 'Memento Ultimate'];
        system.debug('lstRec @@@@ ' + lstRec);
        List<Gift_Code__c> f1lst= new List<Gift_Code__c>();
        for(integer i=0;i<30;i++){
            Gift_Code__c f1 = new Gift_Code__c();
            f1.Gift_Code__c = 'test1'+i;
            f1.opportunity__c=null;
            f1.RecordTypeId = lstRec[0].id;
            f1lst.add(f1);
        }
        insert f1lst;

        // Opportunity_Payment_Terms__c oppPayTermTest = new Opportunity_Payment_Terms__c(Status__c = 'Passed',Payment_Term__c = '100%', Amount__c=100,Percentage_Of_Payment__c=1, Opportunity__c = opp.Id, Payment_Due_date__c = system.today().adddays(-5));
        // insert oppPayTermTest;

        opp.StageName ='Closed Won';
        opp.paid_in_full__C =true;
        opp.Memento_Ultimate_Assignment_Pending__c= true;
        update opp;

        f1lst= new List<Gift_Code__c>();
        for(integer i=0;i<30;i++){
            Gift_Code__c f1 = new Gift_Code__c();
            f1.Gift_Code__c = 'test1'+i;
            f1.opportunity__c=null;
            f1.RecordTypeId = lstRec[0].id;
            f1lst.add(f1);
        }
        insert f1lst;
        Test.stopTest();

    }
}
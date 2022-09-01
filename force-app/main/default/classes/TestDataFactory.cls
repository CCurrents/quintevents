/**
 * @File Name          : TestDataFactory.cls
 * @Description        : To Insert Test Data
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 10-07-2021
 * @Modification Log   :  
 * Ver       Date            Author              Modification
 * 1.0    3/2/2020   kchavda@addonblue.com     Initial Version 
 * 2.0    4/2/2020   lpanchal@addonblue.com    Update to use util class 
 * 2.1      3/16/2020   jagrawal@addonblue.com  Refactored class with proper comments and code
**/
@isTest
public class TestDataFactory {  



    //////////////////////////////////////////////   Test Data Creation Section Starts   //////////////////////////////////////////////
    
    /**
    * @description To create all the necessary data for Test class
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @return void 
    **/
    public static void createTestRecords() {

        createTriggerSettingsEntry();

        // Person Lead       
        Lead personLead = new Lead();
        personLead.Google_Analytics_ID__c = 'gaID';
        personLead.Google_Analytics_Site_Id__c = 'gaSiteId';
        personLead.FirstName = 'Test';
        personLead.LastName = 'Person';
        personLead.Status = 'Interested';
        personLead.Source__c = 'Test';
        personLead.Lead_Type__c = 'Person';
        personLead.Email = 'testperson@quintevnts.com';
        Utility.processRecords(personLead, 'insert');

        // Business Lead
        Lead businessLead = new Lead();
        businessLead.Google_Analytics_ID__c = 'gaID';
        businessLead.Google_Analytics_Site_Id__c = 'gaSiteId';
        businessLead.FirstName = 'Test';
        businessLead.LastName = 'Business';
        businessLead.Status = 'Interested';
        businessLead.Source__c = 'Test';
        businessLead.Lead_Type__c = 'Person';
        businessLead.Email = 'testbusiness@quintevnts.com';
        Utility.processRecords(businessLead, 'insert');

        // Convert Person Lead
        //commented by Jheel
        /*Database.LeadConvert lcPerson = new database.LeadConvert();
        lcPerson.setLeadId(personLead.id);
        lcPerson.setDoNotCreateOpportunity(true);
        lcPerson.setConvertedStatus('Converted');
        Database.LeadConvertResult lcrPerson = Database.convertLead(lcPerson);
        System.assert(lcrPerson.isSuccess());
        Lead convertedPersonLead = [select Id, IsConverted, ConvertedAccountId,ConvertedContactId from Lead where Id = :personLead.Id];*/
        
        // Convert Business Lead
        /*Database.LeadConvert lcBusiness = new database.LeadConvert();
        lcBusiness.setLeadId(businessLead.id);
        lcBusiness.setDoNotCreateOpportunity(true);
        lcBusiness.setConvertedStatus('Converted');
        Database.LeadConvertResult lcrBusiness = Database.convertLead(lcBusiness);
        System.assert(lcrBusiness.isSuccess());
        Lead convertedBusinessLead = [select Id, IsConverted, ConvertedAccountId,ConvertedContactId  from Lead where Id = :businessLead.Id];*/
        
               
        // Create Event
        QE360_Event__c eventOne = new QE360_Event__c(Name='normal event',Active__c = true, start_date__c = system.today(), end_date__c = system.today() + 5);
        Utility.processRecords(eventOne, 'insert');
        
        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = eventOne.Id;
        Utility.processRecords(parentPackage, 'insert');
        
        // Create Event Products and Packages
        // Get Product2 record types
        Id recordTypeProduct = [Select Id,Name From RecordType Where sObjectType='Product2' and DeveloperName='Products'].Id;
        Id recordTypeHotel = [Select Id,Name From RecordType Where sObjectType='Product2' and DeveloperName='Hotels'].Id;
        Id recordTypePackage = [Select Id,Name From RecordType Where sObjectType='Product2' and DeveloperName='Package'].Id;
        
        // Products to insert
        List<Product2> productsToInsert = new List<Product2>();
        
        // Products
        Product2 ticketOne = new Product2(Name='tiket one',Type__c='Ticket',A_La_Carte__c=true,Total_Inventory__c=10,Event__c=eventOne.Id,RecordTypeId=recordTypeProduct,isActive=true);
        productsToInsert.add(ticketOne);
        Product2 HospitalityOne = new Product2(Name='tiket one',Type__c='Hospitality',A_La_Carte__c=true,Total_Inventory__c=10,Event__c=eventOne.Id,RecordTypeId=recordTypeProduct,isActive=true);
        productsToInsert.add(HospitalityOne);
        
        // Packages
        Product2 packageOne = new Product2(Name='package one',A_La_Carte__c=true,Event__c=eventOne.Id,RecordTypeId=recordTypePackage,isActive=true, parent_package__c=parentPackage.id,Total_Inventory__c=5);
        productsToInsert.add(packageOne);
        Utility.processRecords(productsToInsert, 'insert');
        
        // Pricebook Entries
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        PricebookEntry ticketOnePbe =new PricebookEntry(
            unitprice=0.01,Product2Id=ticketOne.Id,Pricebook2Id=Test.getStandardPricebookId(),
            isActive=true,UseStandardPrice = false);
        pricebookEntries.add(ticketOnePbe);
        PricebookEntry hospitalityOnePbe =new PricebookEntry(
            unitprice=0.01,Product2Id=hospitalityOne.Id,Pricebook2Id=Test.getStandardPricebookId(),
            isActive=true,UseStandardPrice = false);
        pricebookEntries.add(hospitalityOnePbe);
        PricebookEntry packageOnePbe =new PricebookEntry(
            unitprice=0.01,Product2Id=packageOne.Id,Pricebook2Id=Test.getStandardPricebookId(),
            isActive=true,UseStandardPrice = false);
        pricebookEntries.add(packageOnePbe);
        Utility.processRecords(pricebookEntries, 'insert');
        
        // Package Products
        Package_Products__c ticketOnePackageProduct = new Package_Products__c(Package__c=packageOne.Id,Products_and_Hotels__c=ticketOne.Id);
        Utility.processRecords(ticketOnePackageProduct, 'insert');
        
        Account account = new Account();
        account.RecordTypeId = '012i00000015Y4x';
        account.Name = 'Test Account';
        account.CurrencyIsoCode = 'USD';
        Utility.processRecords(account, 'insert');

        Contact contact = new Contact();
        contact.LastName = 'Test Last Name';
        contact.AccountId = account.Id;
        contact.CurrencyIsoCode = 'USD';
        contact.Email = 'GPE19999@gmail.com';
        contact.Phone = '8527419630';
        Utility.processRecords(contact, 'insert');
        
        // Person Opportunity
        Opportunity personOpportunity = new Opportunity();
        personOpportunity.Accountid = account.id;
        personOpportunity.Name = 'person opportunity';
        personOpportunity.Event__c = eventOne.Id;
        personOpportunity.Payment_Method__c ='Credit Card';
        personOpportunity.Email__c = 'testperson111@quintevnts.com';
        personOpportunity.Send_Payment_Email__c = false;
        personOpportunity.StageName = 'Qualified';
        personOpportunity.CloseDate = date.today(); 
        personOpportunity.Pricebook2 = createPricebook();
        personOpportunity.Contact_Site__c = 'quintevents.com';   
        personOpportunity.Primary_Contact__c =  contact.Id;
        Utility.processRecords(personOpportunity, 'insert'); 
        personOpportunity.CloseDate = date.today()+1;
        Utility.processRecords(personOpportunity, 'update'); 
        
        // Opportunity Line Items for Person Opportunity
        OpportunityLineItem ticketOneOli = new OpportunityLineItem (Quantity=2,Product2ID=ticketOne.Id,OpportunityId=personOpportunity.Id,UnitPrice=0.01,PriceBookEntryId=ticketOnePbe.Id);
        // Utility.processRecords(ticketOneOli, 'insert');
        
        // Person Qupote
        Quote quoteForPersonOpportunity = new Quote(
            Name='person opportunity quote',Payment_Terms__c = '1/2',OpportunityId=personOpportunity.Id,Status='Draft',
            Payment_Method__c='Credit Card',Email='testperson@quintevnts.com',Pricebook2Id = Test.getStandardPricebookId());
        Utility.processRecords(quoteForPersonOpportunity, 'insert');
        
        // Quote Line Items for Person Quote
        QuoteLineItem ticketOneQli = new QuoteLineItem (Quantity=2,Product2ID=ticketOne.Id, QuoteId=quoteForPersonOpportunity.Id,UnitPrice=0.01,PriceBookEntryId=ticketOnePbe.Id);
        Utility.processRecords(ticketOneQli, 'insert');
        QuoteLineItem ticketOneQli1 = new QuoteLineItem (Quantity=2,Product2ID=ticketOne.Id, QuoteId=quoteForPersonOpportunity.Id,UnitPrice=0.01,PriceBookEntryId=ticketOnePbe.Id);
        Utility.processRecords(ticketOneQli1, 'insert');
        
        //Charge__c objCharge = new Charge__c();
        //objCharge.Line_Item__c = ticketOneOli.id;
        //Utility.processRecords(objCharge, 'insert');
    }

    //////////////////////////////////////////////   Test Data Creation Section Ends   //////////////////////////////////////////////



/*-----------------------------------------------------------------------STANDARD OBJECT SECTIONS --------------------------------------------------------------------------------------*/



    //////////////////////////////////////////////   Lead Section Starts   //////////////////////////////////////////////
    
    /**
    * @description Generic Lead Creation Method
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @return Lead 
    **/
    public static Lead createLead(){
        return createLead(1)[0];
    }   

    /**
    * @description Paramterised Lead Creation Method (Overloaded)
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @return List<Lead> 
    **/
    public static List<Lead> createLead(Integer NoofRecords) {
        List<Lead> lstLeads = new List<Lead>();
        for(integer i= 0; i<NoofRecords; i++){   
            Lead objLead = new Lead();
            objLead.Google_Analytics_ID__c = 'gaID';
            objLead.Google_Analytics_Site_Id__c = 'gaSiteId';
            objLead.FirstName = 'Addon';
            objLead.LastName = 'Blue'+ Utility.getRandomNumber().SubString(0,8) + i;
            objLead.Status = 'Interested';
            objLead.Source__c = 'LinkedIn';
            objLead.Lead_Type__c = 'Person'; // Create two type of lead 
            objLead.Email = 'addonblue'+Utility.getRandomNumber().SubString(0,8)+'@quintevnts.com';
            lstLeads.add(objLead);
        }
        lstLeads = Utility.processRecords(lstLeads, 'insert');        
        return lstLeads;
    }
    
    /**
    * @description Paramterised Lead Creation Method (Overloaded)
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @param performInsert
    * @return List<Lead> 
    **/
    public static List<Lead> createLead(Integer NoofRecords, boolean performInsert) {
        List<Lead> lstLeads = new List<Lead>();
        for(integer i= 0; i<NoofRecords; i++){   
            Lead objLead = new Lead();
            objLead.Google_Analytics_ID__c = 'gaID';
            objLead.Google_Analytics_Site_Id__c = 'gaSiteId';
            objLead.FirstName = 'Addon';
            objLead.LastName = 'Blue'+ Utility.getRandomNumber().SubString(0,8) + i;
            objLead.Status = 'Interested';
            objLead.Source__c = 'LinkedIn';
            objLead.Lead_Type__c = 'Person';
            objLead.Email = 'addonblue@quintevnts.com';
            lstLeads.add(objLead);
        }
        if(performInsert) lstLeads = Utility.processRecords(lstLeads, 'insert');        
        return lstLeads;
    }

    //////////////////////////////////////////////   Lead Section Ends   //////////////////////////////////////////////

    
    
    //////////////////////////////////////////////   QuoteLineItems Ends   //////////////////////////////////////////////
    
    /**
    * @description Generic QuoteLineItem Creation Method
    * @author jagrawal@addonblue.com | 3/17/2020 
    * @return Lead 
    **/
    public static QuoteLineItem createQuoteLineItem(){
        return createQuoteLineItem(1)[0];
    }  

    /**
    * @description Paramterised QuoteLineItem Creation Method (Overloaded)
    * @author jagrawal@addonblue.com | 3/17/2020 
    * @param Integer NoofRecords 
    * @return List<QuoteLineItem> 
    **/
    public static List<QuoteLineItem> createQuoteLineItem(Integer NoofRecords){
        List<QuoteLineItem> Qlineitems = new  List<QuoteLineItem>();
        for(integer i= 0; i<NoofRecords; i++){
            QuoteLineItem objQLI = new QuoteLineItem(
            Quantity = 3,
            Product2ID= createProduct().Id,
            QuoteId = createQuote().Id,
            UnitPrice = 0.01,
            PriceBookEntryId = createPricebookEntry().Id,
            Record_Type__c = 'A La Carte',
            Roomtype_Id__c = '651126',
            ProductType__c = 'Shipping and Handling'
             ); 
            Qlineitems.add(objQLI);
         }
        Qlineitems =  Utility.processRecords(Qlineitems, 'insert');
        return Qlineitems;
    }

    /**
    * @description Paramterised QuoteLineItem Creation Method (Overloaded)
    * @author jagrawal@addonblue.com | 3/17/2020 
    * @param Integer NoofRecords 
    * @param boolean performInsert 
    * @return List<QuoteLineItem> 
    **/
    public static List<QuoteLineItem> createQuoteLineItem(Integer NoofRecords, boolean performInsert){
        List<QuoteLineItem> Qlineitems = new  List<QuoteLineItem>();
        for(integer i= 0; i<NoofRecords; i++){
            QuoteLineItem objQLI = new QuoteLineItem(
            Quantity = 2,
            Product2ID= createProduct().Id,
            QuoteId = createQuote().Id,
            UnitPrice = 0.01,
            PriceBookEntryId = createPricebook().Id ); 
            Qlineitems.add(objQLI);
         }
        if(performInsert) Qlineitems =  Utility.processRecords(Qlineitems, 'insert');
        return Qlineitems;
    }
    /**
    * @description Paramterised QuoteLineItem Creation Method (Overloaded)
    * @author jagrawal@addonblue.com | 3/17/2020 
    * @param Integer NoofRecords 
    * @param boolean performInsert 
    * @return List<QuoteLineItem> 
    **/
    public static List<QuoteLineItem> createQuoteLineItem(Integer NoofRecords,String quoteId, boolean performInsert){
        List<QuoteLineItem> Qlineitems = new  List<QuoteLineItem>();
        for(integer i= 0; i<NoofRecords; i++){
            QuoteLineItem objQLI = new QuoteLineItem(
            Quantity = 2,
            Product2ID= createProduct().Id,
            QuoteId = quoteId,
            UnitPrice = 0.01,
            PriceBookEntryId = createPricebookEntry().Id ); 
            Qlineitems.add(objQLI);
         }
        if(performInsert) Qlineitems =  Utility.processRecords(Qlineitems, 'insert');
        return Qlineitems;
    }
    
    /**
    * @description Paramterised QuoteLineItem Creation Method (Overloaded)
    * @author fsuraitawala@addonblue.com | 04/26/2020 
    * @param Integer NoofRecords 
    * @param boolean performInsert 
    * @return List<QuoteLineItem> 
    **/
    public static QuoteLineItem createQuoteLineItem(String quoteId, String PriceBookEntryId, String RecordType, String newQLIId, String HotelQLIId, Boolean performInsert) {
        List<QuoteLineItem> lstQLI = new List<QuoteLineItem>();
        QuoteLineItem objQLI = new QuoteLineItem();
        objQLI.QuoteId = quoteId;
        objQLI.Quantity = 5;
        objQLI.UnitPrice = 0;
        objQLI.PriceBookEntryId = PriceBookEntryId;
        objQLI.Record_Type__c = RecordType;
        if(newQLIId != null) {
            objQLI.Quote_Package__c = newQLIId;
        }
        if(HotelQLIId != null) {
            objQLI.Hotel_Package_Id__c = HotelQLIId;
        }
        lstQLI.add(objQLI);
        
        if(performInsert) {
            lstQLI = Utility.processRecords(lstQLI, 'insert');
        }
        return lstQLI[0];
    }

    //////////////////////////////////////////////   QuoteLineItems Ends   //////////////////////////////////////////////



    //////////////////////////////////////////////   Account Section Starts   //////////////////////////////////////////////
    
    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @return Account 
    **/
    public static Account createAccount(){
        return createAccount(1)[0];
    }
    
    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @return List<Account> 
    **/
    public static List<Account> createAccount(Integer NoofRecords) {
        List<Account> lstAccount = new List<Account>();
        for(integer i= 0; i<NoofRecords; i++){   
            Account objAccount = new Account();
            objAccount.Name = 'Addon Blue '+ Utility.getRandomNumber().SubString(0,8) + i;
            //objAccount.PersonEmail = 'test'+ Utility.getRandomNumber() +'@quintevents131.com';
            lstAccount.add(objAccount);
        }
        lstAccount = Utility.processRecords(lstAccount, 'insert');
        return lstAccount;
    }

    //////////////////////////////////////////////   Account Section Ends   //////////////////////////////////////////////



    //////////////////////////////////////////////   Contact Section Starts   //////////////////////////////////////////////
    
    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @return Contact 
    **/
    public static Contact createContact(){
        return createContact(createAccount());
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @param objAccount 
    * @return Contact 
    **/
    public static Contact createContact(Account objAccount){
        List<Account> lstAccounts = new List<Account>();
        lstAccounts.add(objAccount);
        List<Contact> lstContacts = createContact(lstAccounts);
        system.debug('lstContacts--'+lstContacts);
        return lstContacts[0];
    }
    
    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @param lstAccount 
    * @return List<Contact> 
    **/
    public static List<Contact> createContact(List<Account> lstAccount){
        List<Contact> lstContacts = createContact(1,lstAccount);
        return lstContacts;
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @param objAccount 
    * @return List<Contact> 
    **/
    public static List<Contact> createContact(Integer NoofRecords,Account objAccount){
        List<Account> lstAccounts = new List<Account>();
        lstAccounts.add(objAccount);
        List<Contact> lstContacts = createContact(NoofRecords, lstAccounts);
        return lstContacts;
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @param lstAccount 
    * @return List<Contact> 
    **/
    public static List<Contact> createContact(Integer NoofRecords, List<Account> lstAccounts) {
        List<Contact> lstContacts = new List<Contact>();
        for(integer i= 0; i<lstAccounts.size(); i++){   
            Account acct = lstAccounts[i];            
            for (Integer j=NoofRecords*i;j<NoofRecords*(i+1);j++) {
                Contact objContact = new Contact();
                objContact.FirstName = 'Test data' + j;
                objContact.LastName = 'Data'+ Utility.getRandomNumber().SubString(0,8) + j;
                objContact.Email = 'addontest'+ Utility.getRandomNumber().SubString(0,8) +'@addonblue.com';
                objContact.AccountId = acct.Id;
                lstContacts.add(objContact);
            }
        }
        lstContacts = Utility.processRecords(lstContacts, 'insert');
        if(NoofRecords == 1){
           lstAccounts[0].Primary_Contact__c = lstContacts[0].id;
           lstAccounts = Utility.processRecords(lstAccounts, 'update');     
        }
        return lstContacts;
    }
    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @param lstAccount 
    * @param dmlFlag 
    * @return List<Contact> 
    **/
    public static List<Contact> createContact(Integer NoofRecords, List<Account> lstAccounts, Boolean dmlFlag) {
        List<Contact> lstContacts = new List<Contact>();
        for(integer i= 0; i<lstAccounts.size(); i++){   
            Account acct = lstAccounts[i];            
            for (Integer j=NoofRecords*i;j<NoofRecords*(i+1);j++) {
                Contact objContact = new Contact();
                objContact.FirstName = 'Test Data' + j;
                objContact.LastName = 'Data '+ Utility.getRandomNumber().SubString(0,8) + j;
                objContact.Email = 'addontest'+ Utility.getRandomNumber().SubString(0,8) +'@addonblue.com' +j;
                objContact.AccountId = acct.Id;
                lstContacts.add(objContact);
            }
            
        }
        if(dmlFlag){
            lstContacts = Utility.processRecords(lstContacts, 'insert'); 
        }
        return lstContacts;
    }
    
    /**
    * @description 
    * @author fsuraitawala@addonblue.com | 04/26/2020 
    * @param AccountId
    * @return Contact 
    **/
    public static Contact createContact(Id AccountId) {
        List<Contact> lstContact = new List<Contact>();
        Contact objContact = new Contact();
        objContact.FirstName = 'Test Data';
        objContact.LastName = 'Data '+ Utility.getRandomNumber().SubString(0,8);
        objContact.Email = 'addontest'+ Utility.getRandomNumber().SubString(0,8) +'@addonblue.com';
        objContact.AccountId = AccountId;
        lstContact.add(objContact);
        lstContact = Utility.processRecords(lstContact, 'insert');
        
        return lstContact[0];
    }
    //////////////////////////////////////////////   Contact Section Ends   //////////////////////////////////////////////



    //////////////////////////////////////////////   Pricebook Section Starts //////////////////////////////////////////////
    
    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @return PriceBook2 
    **/
    public static PriceBook2 createPricebook() {
       return createPricebook(1,'Test PB '+ Utility.getRandomNumber().SubString(0,8))[0];
    } 

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @return List<PriceBook2> 
    **/
    public static List<PriceBook2> createPricebook(Integer NoofRecords) {
        return createPricebook(NoofRecords,'Test PB');
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @param PricbookName 
    * @return List<PriceBook2> 
    **/
    public static List<PriceBook2> createPricebook(Integer NoofRecords, String PricbookName) {
        List<PriceBook2> lstPriceBook = new List<PriceBook2>();
        for(integer i= 0; i<NoofRecords; i++){              
            Pricebook2 pricebook = new Pricebook2(
                //Name = PricbookName+'-'+ Utility.getRandomNumber() +i,
                Name = PricbookName+'-'+i,
                IsActive = true,
                GPE_Event__c = false,
                Shipping_and_Handling_Fee__c = 200,
                Shipping_and_Handling_Fee_Outside_US__c = 100,
                H4H_Site_Id__c = '51745',
                Slack_Channel_Name__c = 'UFC 243',
                Post_to_Slack_Channel__c = true,
                Slack_Channel_Id__c = 'CLZM020EL',
                End_Date__c = System.today()+2
            );
            lstPriceBook.add(pricebook);       
        }
        lstPriceBook = Utility.processRecords(lstPriceBook, 'insert');
        return lstPriceBook;
    }   
    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @param PricbookName 
    * @param dmlFlag 
    * @return List<PriceBook2> 
    **/
    public static List<PriceBook2> createPricebook(Integer NoofRecords, String PricbookName, Boolean dmlFlag) {
        List<PriceBook2> lstPriceBook = new List<PriceBook2>();
        for(integer i= 0; i<NoofRecords; i++){              
               Pricebook2 pricebook = new Pricebook2(
                Name = PricbookName+'-'+ Utility.getRandomNumber().SubString(0,8) +i,
                IsActive = true,
                GPE_Event__c = false
            );
            lstPriceBook.add(pricebook);       
        }
        if(dmlFlag){
            lstPriceBook = Utility.processRecords(lstPriceBook, 'insert');
        }
        return lstPriceBook;
    } 
    
    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @param PricbookName 
    * @param dmlFlag 
    * @return List<PriceBook2> 
    **/
    public static void createStandardPricebook() {
        Pricebook2 pricebook = new Pricebook2(
            Name = 'Standard Price Book',
            IsActive = true,
            GPE_Event__c = false
        );
        Utility.processRecords(pricebook, 'insert');
    }   
    //////////////////////////////////////////////   Pricebook Section Ends   //////////////////////////////////////////////



    ////////////////////////////////////////////// Pricebook Entry Section Starts ///////////////////////////////////////////

    public static PricebookEntry createPricebookEntry() {
        return createPricebookEntry(1)[0];
     }     

     public static List<PricebookEntry> createPricebookEntry(Integer NoofRecords) {
        List<PricebookEntry> lstPriceBookEntries = new List<PricebookEntry>();
        for(integer i= 0; i<NoofRecords; i++){              
            PricebookEntry pricebookentry = new PricebookEntry(
                unitprice = 0.01,
                Product2Id = createProduct().Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                isActive = true,
                UseStandardPrice = false
            );
            lstPriceBookEntries.add(pricebookentry);       
        }
        lstPriceBookEntries = Utility.processRecords(lstPriceBookEntries, 'insert');
        return lstPriceBookEntries;
    }
    
    public static PricebookEntry createPricebookEntry(Product2 objProduct, Id Pricebook2Id) {
        PricebookEntry objPriceBookEntry = new PricebookEntry(unitprice = objProduct.Price__c, 
                                                             Product2Id = objProduct.Id, 
                                                             Pricebook2Id = Pricebook2Id, 
                                                             isActive=true, 
                                                             UseStandardPrice = false,
                                                             CurrencyIsoCode = objProduct.CurrencyIsoCode);
                                                         
        return objPriceBookEntry;
    }
    ////////////////////////////////////////////// Pricebook Entry Section Ends /////////////////////////////////////////////



    //////////////////////////////////////////////   Opportunity Section Starts   //////////////////////////////////////////////
    
    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @return Opportunity 
    **/
    public static Opportunity createOpportunity() { 
        Account objAccount = createAccount();
        Contact objContact = createContact(objAccount);
        List<Opportunity> lstOpportunities = createOpportunity(1, objAccount.Id, objContact.Id, createPricebook().Id);
        system.debug('lstOpportunities-630 ----'+lstOpportunities);
        if(lstOpportunities.size() > 0)
            return lstOpportunities[0];
        else {
            return null;
        }    
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @param noOfRecords 
    * @return List<Opportunity> 
    **/
    public static List<Opportunity> createOpportunity(Integer noOfRecords) { 
        Account objAccount = createAccount();
        Contact objContact = createContact(objAccount);
        List<Opportunity> lstOpportunities = createOpportunity(NoofRecords, objAccount.Id, objContact.Id, createPricebook().Id);
        system.debug('lstOpportunities-647 ----'+lstOpportunities);
        return lstOpportunities;
    }
   
    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @param noOfRecords 
    * @param accountId 
    * @param contactId 
    * @param PricebookId 
    * @return List<Opportunity> 
    **/
    public static List<Opportunity> createOpportunity(Integer noOfRecords, Id accountId, Id contactId, Id PricebookId) {     
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        for(integer i= 0; i<noOfRecords; i++){ 
            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Accountid = accountId;
            objOpportunity.Name = 'tstopportunity '+ Utility.getRandomNumber().SubString(0,8) +' '+i;
            objOpportunity.Pricebook2Id = Test.getStandardPricebookId();//PricebookId;
            //objOpportunity.Pricebook2 = createPricebook(); 
            objOpportunity.Payment_Method__c ='Credit Card';
            objOpportunity.Email__c = 'testperson'+ Utility.getRandomNumber().SubString(0,8) +'@quintevnts.com';
            objOpportunity.Send_Payment_Email__c = false;
            objOpportunity.StageName = 'Closed Won';
            objOpportunity.CloseDate = date.today(); 
            objOpportunity.Contact_Site__c = 'quintevents.com';   
            objOpportunity.Primary_Contact__c =  contactId;  
            objOpportunity.Shipping_Outside_US__c = 'Yes'; 
            lstOpportunity.add(objOpportunity);
        }
        lstOpportunity = Utility.processRecords(lstOpportunity, 'insert');
        System.debug('lstOpportunity-->'+lstOpportunity);
        return lstOpportunity;
    }
    /**
    * @description 
    * @author mpatel@addonblue.com | 3/17/2020 
    * @param Integer noOfRecords 
    * @param Id accountId 
    * @param Id contactId 
    * @param Id PricebookId 
    * @param Boolean dmlFlag
    * @return List<Opportunity> 
    **/
    public static List<Opportunity> createOpportunity(Integer noOfRecords, Id accountId, Id contactId, Id PricebookId, Boolean dmlFlag) {     
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        for(integer i= 0; i<noOfRecords; i++){ 
            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Accountid = accountId;
            objOpportunity.Name = 'person opportunity'+ Utility.getRandomNumber().SubString(0,8);
            objOpportunity.Pricebook2Id = PricebookId;
            objOpportunity.Pricebook2 = createPricebook();
            objOpportunity.Payment_Method__c ='Credit Card';
            objOpportunity.Email__c = 'testperson'+ Utility.getRandomNumber().SubString(0,8) +'@quintevnts.com';
            objOpportunity.Send_Payment_Email__c = false;
            objOpportunity.StageName = 'Qualified';
            objOpportunity.CloseDate = date.today(); 
            objOpportunity.Contact_Site__c = 'quintevents.com';   
            objOpportunity.Primary_Contact__c =  contactId;  
            lstOpportunity.add(objOpportunity);
        }
        if(dmlFlag){
            lstOpportunity = Utility.processRecords(lstOpportunity, 'insert');
        }
        return lstOpportunity;
    }
    //////////////////////////////////////////////   Opportunity Section Ends   //////////////////////////////////////////////
    
    //////////////////////////////////////////////   OpportunityLineItem Section Starts ///////////////////////////////////

    public static OpportunityLineItem createOpportunityLineItem(){
       Opportunity objOpportunity = createOpportunity();
       List<OpportunityLineItem> lstOpportunityLineItem = createOpportunityLineItem(1,objOpportunity.Id);
       System.debug('lstOpportunityLineItem'+lstOpportunityLineItem);
       return lstOpportunityLineItem[0];
    }

    public static List<OpportunityLineItem> createOpportunityLineItem(Integer NoofRecords, Id oppId){
        List<OpportunityLineItem> lstOppLineItem = new List<OpportunityLineItem>();
        for(integer i= 0; i<NoofRecords; i++){ 
            OpportunityLineItem objoppLineItem = new OpportunityLineItem(
                OpportunityId = oppId,
                TotalPrice = 100,
                Quantity = 3,
                ListPrice_Used__c = 10,
                PricebookEntryId = createPricebookEntry().Id
            );
            lstOppLineItem.add(objoppLineItem);
        }
        lstOppLineItem = Utility.processRecords(lstOppLineItem, 'insert');
        return lstOppLineItem;
    }

    public static List<OpportunityLineItem> createOpportunityLineItem(Integer noofRecords, Id oppId, Id pbEntryId){
        List<OpportunityLineItem> lstOppLineItem = new List<OpportunityLineItem>();
        for(integer i= 0; i<noofRecords; i++){ 
            OpportunityLineItem objoppLineItem = new OpportunityLineItem(
                OpportunityId = oppId,
                TotalPrice = 100,
                Quantity = 3,
                ListPrice_Used__c = 10,
                PricebookEntryId = pbEntryId
            );
            lstOppLineItem.add(objoppLineItem);
        }
        lstOppLineItem = Utility.processRecords(lstOppLineItem, 'insert');
        return lstOppLineItem;
    }
    //////////////////////////////////////////////   OpportunityLineItem Section Ends //////////////////////////////////////


    //////////////////////////////////////////////   Quote Section Starts   //////////////////////////////////////////////
    
    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @return Quote 
    **/
    public static Quote createQuote(){
        //Opportunity objOpportunity = createOpportunity();
        Opportunity objOpportunity = new Opportunity();
            objOpportunity.Accountid = createAccount().Id;
            objOpportunity.Name = 'Formula '+ Utility.getRandomNumber().SubString(0,8);
            objOpportunity.Pricebook2Id = Test.getStandardPricebookId();//PricebookId;
            //objOpportunity.Pricebook2 = createPricebook(); 
            objOpportunity.Payment_Method__c ='Credit Card';
            objOpportunity.Email__c = 'testperson'+ Utility.getRandomNumber().SubString(0,8) +'@quintevnts.com';
            objOpportunity.Send_Payment_Email__c = false;
            objOpportunity.StageName = 'Closed Won';
            objOpportunity.CloseDate = date.today(); 
            objOpportunity.Contact_Site__c = 'quintevents.com';   
            objOpportunity.Primary_Contact__c =  createContact().Id;  
            objOpportunity.Shipping_Outside_US__c = 'Yes';
        insert objOpportunity;
        System.debug('createQuote OPP-->'+ objOpportunity.Pricebook2Id);
        try{
            List<Quote> objQuote = createQuote(1,objOpportunity.Id, objOpportunity.Primary_Contact__c, objOpportunity.Pricebook2Id,true);
            system.debug('objQuote--'+objQuote);
            return objQuote[0];
        }
        catch(exception ex){
            system.debug('Exception: '+ ex.getmessage());
            return null;
        }
       
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @return List<Quote> 
    **/
    public static List<Quote> createQuote(Integer NoofRecords, Id objOpportunityId, Id objContactId, Id objPriceBookId,Boolean dmlFlag){
        List<Quote> lstQuote = new List<Quote>();
        for(integer i= 0; i<NoofRecords; i++){ 
            Quote objQuote = new Quote(
                Name = 'person opportunity quote'+ Utility.getRandomNumber().SubString(0,8),
                Payment_Terms__c = '1/2',
                //OwnerId = createUser().Id,
                OpportunityId = objOpportunityId,
                Status = 'Draft',
                Payment_Method__c = 'Credit Card',
                Email = 'addonBlue@quintevnts.com',
                Primary_Contact__c = objContactId,
                ShippingCountryCode = 'IN',
                Pricebook2Id = objPriceBookId,//Test.getStandardPricebookId(),
                Approval_Expected__c = '4 Hours',//createPricebook().id
                Description = 'Paid#100'
            );
            lstQuote.add(objQuote);
        }
        lstQuote = Utility.processRecords(lstQuote, 'insert');
        return lstQuote;
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @return List<Quote> 
    **/
    public static List<Quote> createQuote(Integer NoofRecords, Boolean dmlFlag){
        List<Quote> lstQuote = new List<Quote>();
        for(integer i= 0; i<NoofRecords; i++){ 
            Quote objQuote = new Quote(
                Name = 'person opportunity quote'+ Utility.getRandomNumber().SubString(0,8),
                Payment_Terms__c = '1/2',
                OpportunityId = createOpportunity().Id,
                Status = 'Draft',
                Payment_Method__c = 'Credit Card',
                Email = 'addonBlue@quintevnts.com',
                Pricebook2Id = Test.getStandardPricebookId()//createPricebook().id
            );
            lstQuote.add(objQuote);
        }
        if(dmlFlag){
            lstQuote = Utility.processRecords(lstQuote, 'insert');
        }
        return lstQuote;
    }
    
    /**
    * @description 
    * @author jthakkar@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @return List<Quote> 
    **/
    public static List<Quote> createQuote(Integer NoofRecords, Id OpportunityId, Id priceBookId){
        List<Quote> lstQuote = new List<Quote>();
        for(integer i= 0; i<NoofRecords; i++){ 
            Quote objQuote = new Quote(
                Name = 'person opportunity quote',
                Payment_Terms__c = '1/2',
                OpportunityId = OpportunityId,
                Status = 'Signed - Approved',
                Payment_Method__c = 'Credit Card',
                Email = 'addonBlue@quintevnts.com',
                Pricebook2Id = priceBookId
            );
            lstQuote.add(objQuote);
        }
        lstQuote = Utility.processRecords(lstQuote, 'insert');
        return lstQuote;
    }
    
    /**
    * @description 
    * @author jthakkar@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @return List<Quote> 
    **/
    public static List<Quote> createQuote(Integer NoofRecords, Id OpportunityId, Id priceBookId, Id EventId){
        List<Quote> lstQuote = new List<Quote>();
        for(integer i= 0; i<NoofRecords; i++){ 
            Quote objQuote = new Quote(
                Name = 'person opportunity quote',
                Payment_Terms__c = '1/2',
                OpportunityId = OpportunityId,
                Status = 'Signed - Approved',
                Payment_Method__c = 'Credit Card',
                Email = 'addonBlue@quintevnts.com',
                Event__c = EventId,
                Pricebook2Id = priceBookId
            );
            lstQuote.add(objQuote);
        }
        lstQuote = Utility.processRecords(lstQuote, 'insert');
        return lstQuote;
    }
    
    /**
    * @description 
    * @author fsuraitawala@addonblue.com | 04/26/2020 
    * @param NoofRecords 
    * @return List<Quote> 
    **/
    public static List<Quote> createQuote(Integer NoofRecords, Opportunity opportunity, Id priceBookId) {
        List<Quote> lstQuote = new List<Quote>();
        for(integer i= 0; i< NoofRecords; i++) { 
            Quote objquote = new Quote(Name = opportunity.Name, 
                                       OpportunityId = opportunity.Id, 
                                       Pricebook2Id = priceBookId, 
                                       ContactId = opportunity.Primary_Contact__c
                                       );
            lstQuote.add(objQuote);
        }
        Utility.processRecords(lstQuote, 'insert');
        
        return lstQuote;
    }

    //////////////////////////////////////////////   Quote Section Ends   //////////////////////////////////////////////



    //////////////////////////////////////////////   Task Section Starts   //////////////////////////////////////////////
    
    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/19/2020 
    * @return Task 
    **/
    public static Task createTask(){
        return createTask(1,createLead().Id)[0];
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/19/2020 
    * @param noOfRecords 
    * @return Task 
    **/
    public static Task createTask(Integer noOfRecords){
        return createTask(noOfRecords,createLead().Id)[0];
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/19/2020 
    * @param noOfRecords 
    * @param whoId 
    * @return List<Task> 
    **/
    public static List<Task> createTask(Integer noOfRecords,Id whoId){
        List<Task> lstTasks = new List<Task>();
        for(integer i=0; i<noOfRecords; i++){
            Task objTask = new Task(
                Description = 'reset_password_token='+ Utility.getRandomNumber().SubString(0,8),
                Subject = 'Email: Thank you for contacting Derby Experiences!',
                WhoId = whoId
            );
            lstTasks.add(objTask);
        }
        lstTasks = Utility.processRecords(lstTasks, 'insert');
        return lstTasks;
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/19/2020 
    * @param noOfRecords 
    * @param whoId 
    * @param performInsert 
    * @return List<Task> 
    **/
    public static List<Task> createTask(Integer noOfRecords,Id whoId, Boolean performInsert){
        List<Task> lstTasks = new List<Task>();
        for(integer i=0; i<noOfRecords; i++){
            Task objTask = new Task(
                Description = 'reset_password_token='+ Utility.getRandomNumber().SubString(0,8),
                Subject = 'Email: Thank you for contacting Derby Experiences!',
                WhoId = whoId
            );
            lstTasks.add(objTask);
        }
        if(performInsert) lstTasks = Utility.processRecords(lstTasks, 'insert');
        return lstTasks;
    }

    //////////////////////////////////////////////   Task Section Ends   //////////////////////////////////////////////
     


    //////////////////////////////////////////////   Product Section Starts   //////////////////////////////////////////////
    
    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @return Product2 
    **/
    public static Product2 createProduct(){
        return createProduct(1)[0];
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @return List<Product2> 
    **/
    public static List<Product2> createProduct(Integer NoofRecords){
       return createProduct(NoofRecords,'Hotel Stay');
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @param RecordType 
    * @return List<Product2> 
    **/
    public static List<Product2> createProduct(Integer NoofRecords, String RecordType){
        List<Product2> lstProduct = new List<Product2>();
        Id recordTypeId = [Select Id,Name From RecordType Where sObjectType='Product2' and Name=:RecordType].Id;
        for(integer i= 0; i<NoofRecords; i++){
        Product2 objProduct = new Product2(
            Name='Testdata123 - ' + Utility.getRandomNumber().SubString(0,8),
            Primary_Price_Book__c = createPricebook().id,
            Type__c='Hotel',
            A_La_Carte__c=true,
            //Inventory__c=10,
            RecordTypeId=recordTypeId,
            Check_In_Date__c = System.today()+2,
            Check_Out_Date__c = System.today()+5,
            H4H_Room_Code__c = '987654321',
            Block_Release_Date__c = Date.today().addDays(+2),
            CurrencyISOCode = 'USD',
            Total_Inventory__c = 0,
            Total_Ordered_Quantity__c = -7, 
            Room_Type__c = 'King', 
            Hotel_Id__c = '1684628',
            H4H_RatePlan_Code__c= 'ARN987654321',
            isActive=true,
            Send_Slack_Notifications__c = true,
            Price__c = 120);
            lstProduct.add(objProduct);
        }
        lstProduct = Utility.processRecords(lstProduct, 'insert');
        return lstProduct;
    }
    /**
    * @description 
    * @author fsuraitawala@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @param RecordType 
    * @return List<Product2> 
    **/
    public static List<Product2> createProduct(Integer NoofRecords, String RecordType, Id PricebookId, Boolean dmlFlag){
        List<Product2> lstProduct = new List<Product2>();
        Id recordTypeId = [Select Id,Name From RecordType Where sObjectType='Product2' and Name=:RecordType].Id;
        for(integer i= 0; i<NoofRecords; i++) {
            Product2 objProduct = new Product2(
                Name = 'Test Product '+ Utility.getRandomNumber().SubString(0,8) +i,
                Primary_Price_Book__c = PricebookId,
                Type__c = 'Transportation',
                Price__c = 10,
                RecordTypeId = recordTypeId,
                isActive = true,
                A_La_Carte__c = true);
            lstProduct.add(objProduct);
        }
        if(dmlFlag) {
            lstProduct = Utility.processRecords(lstProduct, 'insert');
        }
        return lstProduct;
    }
    
    public static Product2 createProduct(String ProductName, String RecordType, String ProductType, Id ParentPackageId, Id PricebookId){
        Product2 objProduct = new product2();
        objProduct.RecordTypeId = [Select Id,Name From RecordType Where sObjectType='Product2' and Name=:RecordType].Id;
        objProduct.Name = ProductName;
        objProduct.Primary_Price_Book__c = PricebookId;
        objProduct.Type__c = ProductType;
        objProduct.CurrencyIsoCode = 'USD';
        objProduct.Price__c = 120.00;
        objProduct.A_La_Carte__c = true;
        objProduct.isActive = true;
        if(ParentPackageId != null) {
            objProduct.Parent_Package__c = ParentPackageId;
        }
        return objProduct;
    }
    
    /**
    * @description 
    * @author fsuraitawala@addonblue.com | 3/17/2020 
    * @param NoofRecords 
    * @param RecordType 
    * @return List<Product2> 
    **/
    public static List<Inventory_Transaction__c> createInventoryTransaction(Integer NoOfRecords, String RecordType, String ProductId) {
        List<Inventory_Transaction__c> lstInventoryTransaction = new List<Inventory_Transaction__c>();
        Id recordTypeId = [Select Id,Name From RecordType Where sObjectType='Inventory_Transaction__c' and Name=:RecordType].Id;
        
        for(integer i= 0; i < NoOfRecords; i++) {
            Inventory_Transaction__c objTransaction = new Inventory_Transaction__c(
                Quantity__c = 50,
                Product__c = ProductId,
                Cost_Per_Quantity__c = 100);
            
            lstInventoryTransaction.add(objTransaction);    
        }
        
        lstInventoryTransaction = Utility.processRecords(lstInventoryTransaction, 'insert');
        
        return lstInventoryTransaction;
    }
    // Product Bundle to add in test class Factory

    //////////////////////////////////////////////   Product Section Ends   //////////////////////////////////////////////

    ////////////////////////////////////////////// H4H Credit Card Section Starts /////////////////////////////////////////

    public static QE_H4H_Credit_Card__c createH4HCreditCard(){
        return createH4HCreditCard(1)[0];
    }

    public static List<QE_H4H_Credit_Card__c> createH4HCreditCard(Integer NoofRecords){
        List<QE_H4H_Credit_Card__c> lstH4HCreditCard = new List<QE_H4H_Credit_Card__c>();
        for(integer i= 0; i<NoofRecords; i++){
            QE_H4H_Credit_Card__c objH4HCreditCard = new QE_H4H_Credit_Card__c(
                Card_Number__c = '411111111111111',
                Card_Type__c = 'VI',
                Card_Expiration__c = '01/21',
                Card_CVV__c = '123',
                Card_Street_Address__c = '123 Main Street',
                Card_Holder_Name__c = 'Test Ritter',
                Card_City__c = 'Austin',
                Card_Region__c = 'TX',
                Card_PostalCode__c= '78745',
                Card_CountryCode__c= 'US'
                );
                lstH4HCreditCard.add(objH4HCreditCard);
            }
            lstH4HCreditCard = Utility.processRecords(lstH4HCreditCard, 'insert');
            return lstH4HCreditCard;
    }
    ////////////////////////////////////////////// H4H Credit Card Section Ends //////////////////////////////////////////

    ////////////////////////////////////////////// Rooming List Section Starts ///////////////////////////////////////////

    /**
    * @description 
    * @author jagrawal@addonblue.com | 4/2/2020 
    * @return Rooming_List__c 
    **/
    public static Rooming_List__c createRoomingList(){
        QuoteLineItem objQLI = createQuoteLineItem();
        return createRoomingList(1, objQLI.QuoteId ,objQLI.Id, objQLI.Product2Id)[0];
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 4/2/2020 
    * @param Integer NoofRecords 
    * @param Id objQuoteId 
    * @param Id objQuoteLineItemId 
    * @return List<Rooming_List__c> 
    **/
    public static List<Rooming_List__c> createRoomingList(Integer NoofRecords, Id objQuoteId, Id objQuoteLineItemId, Id objProduct){
        List<Rooming_List__c> lstRoomList = new List<Rooming_List__c>();
        for(integer i= 0; i<NoofRecords; i++){ 
            Rooming_List__c objRoomList = new Rooming_List__c(
                Guest_Name__c = 'testroomlist',
                Quote__c = objQuoteId,
                QuoteLineItem_Id__c = objQuoteLineItemId,
                Product__c = objProduct,
                H4H_Roomtype_Id__c = '653553',
                H4H_Itinerary_Id__c = '6544586',
                H4H_Reservation_Id__c = '6364551',
                Number_of_Adults__c = 1,
                H4H_Reservation_Created__c = false,
                H4H_Hold_Created__c = true,
                H4H_RatePlan_Code__c = 'ARN540644'
            );
            lstRoomList.add(objRoomList);
        }
        lstRoomList = Utility.processRecords(lstRoomList, 'insert');
        return lstRoomList;
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 4/2/2020 
    * @param Integer NoofRecords 
    * @param Id objQuoteId 
    * @param Id objQuoteLineItemId 
    * @param Boolean dmlFlag 
    * @return List<Rooming_List__c> 
    **/
    public static List<Rooming_List__c> createRoomingList(Integer NoofRecords, Id objQuoteId, Id objQuoteLineItemId, Boolean dmlFlag){
        List<Rooming_List__c> lstRoomList = new List<Rooming_List__c>();
        for(integer i= 0; i<NoofRecords; i++){ 
            Rooming_List__c objRoomList = new Rooming_List__c(
                Guest_Name__c = 'testroomlist',
                Quote__c = objQuoteId,
                QuoteLineItem_Id__c = objQuoteLineItemId,
                H4H_Roomtype_Id__c = '653553',
                H4H_Itinerary_Id__c = '6544586',
                H4H_Reservation_Id__c = '6364551',
                Number_of_Adults__c = 1
            );
            lstRoomList.add(objRoomList);
        }
        if(dmlFlag){
            lstRoomList = Utility.processRecords(lstRoomList, 'insert');
        }
        return lstRoomList;
    }
    
    public static List<Rooming_List__c> createRoomingList(Integer NoofRecords, Id objQuoteId, QuoteLineItem QuoteLineItem, Boolean dmlFlag){
        List<Rooming_List__c> lstRoomList = new List<Rooming_List__c>();
        for(integer i= 0; i<NoofRecords; i++){ 
            Rooming_List__c objRoomList = new Rooming_List__c(
                Guest_Name__c = 'testroomlist',
                Quote__c = objQuoteId,
                QuoteLineItem_Id__c = QuoteLineItem.Id,
                Quote_Package__c = QuoteLineItem.Quote_Package__c,
                Hotel_Package_Id__c = QuoteLineItem.Hotel_Package_Id__c,
                Product__c = QuoteLineItem.Product2Id,
                Quantity__c = QuoteLineItem.Quantity,
                H4H_Roomtype_Id__c = '653553',
                H4H_Itinerary_Id__c = '6544586',
                H4H_Reservation_Id__c = '6364551',
                Number_of_Adults__c = 1
            );
            lstRoomList.add(objRoomList);
        }
        if(dmlFlag){
            lstRoomList = Utility.processRecords(lstRoomList, 'insert');
        }
        return lstRoomList;
    }

    ////////////////////////////////////////////// Rooming List Section Ends /////////////////////////////////////////////
    
    //////////////////////////////////////////////   Gift Code Section Starts //////////////////////////////////////////////

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/20/2020 
    * @return Gift_Code__c 
    **/
    public static Gift_Code__c createGiftCode(){
        Order objOrder = createOrder();
        return createGiftCode(1, objOrder.Quote.OpportunityId, objOrder.Id)[0];
    }

    public static List<Gift_Code__c> createGiftCode(Integer NoofRecords, Id OpportunityId, Id OrderId){
        System.debug('In Gift Code');
        List<RecordType> lstRecordforF1 = [Select id from RecordType where sobjecttype = 'Gift_Code__c' and (name =: 'F1 Access Code' OR name =: 'Memento Premium' OR name =: 'Fanatics Gift Code' OR name=:'Memento Ultimate')];
        
        
        List<Gift_Code__c> lstGiftCodes = new List<Gift_Code__c>();
        for(integer i= 0; i<NoofRecords; i++){ 
            Gift_Code__c objGiftCode = new Gift_Code__c(
                Gift_Code__c = 'test1 - '+ Utility.getRandomNumber().SubString(0,8) +i,
                Opportunity__c = OpportunityId,
                Order__c = OrderId,
                RecordTypeId = lstRecordforF1[Math.mod(i, 3)].Id
            );
            lstGiftCodes.add(objGiftCode);
        }
        lstGiftCodes = Utility.processRecords(lstGiftCodes, 'insert');
        return lstGiftCodes;
    }

    public static List<Gift_Code__c> createGiftCode(Integer NoofRecords,Boolean dmlFlag){
        List<RecordType> lstRecordforF1 = [Select id from RecordType where sobjecttype = 'Gift_Code__c' and (name =: 'F1 Access Code' OR name =: 'Memento Premium' OR name =: 'Fanatics Gift Code' OR name=:'Memento Ultimate')];
        List<Gift_Code__c> lstGiftCodes = new List<Gift_Code__c>();
        for(integer i= 0; i<NoofRecords; i++){ 
            Gift_Code__c objGiftCode = new Gift_Code__c(
                Gift_Code__c = 'test2 - '+ Utility.getRandomNumber().SubString(0,8) +i,
                Opportunity__c = null,
                //Order__c = createOrder().Id,
                RecordTypeId = lstRecordforF1[Math.mod(i, 4)].Id
            );
            lstGiftCodes.add(objGiftCode);
        }
        if(dmlFlag){
            lstGiftCodes = Utility.processRecords(lstGiftCodes, 'insert');
        }
        return lstGiftCodes;
    }


    //////////////////////////////////////////////   Gift Code Section Ends ////////////////////////////////////////////////
    

    
    ///////////////////////////////////////////////  Order Section Starts  //////////////////////////////////////////////////

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/20/2020 
    * @return Order 
    **/
    public static Order createOrder(){
        createSFDCIntacctMapping();
        Quote objQuote = createQuote();
        System.debug('objQuote-->'+ objQuote);
        return createOrder(1, objQuote.OpportunityId, objQuote.Id, objQuote.Primary_Contact__c,objQuote.Pricebook2Id)[0];
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/20/2020 
    * @param NoofRecords 
    * @param objOpportunityId 
    * @param objQuoteId 
    * @return List<Order> 
    **/
    public static List<Order> createOrder(Integer NoofRecords, Id objOpportunityId, Id objQuoteId, Id objContactId, Id objPriceBook2Id){
        
        List<Order> lstOrders = new List<Order>();
        for(integer i= 0; i<NoofRecords; i++){ 
            Order objOrder = new Order(
                AccountId = createAccount().Id,
                QuoteId = objQuoteId,
                OpportunityId = objOpportunityId,
                ShipToContactId = createContact().Id,
                EffectiveDate = date.newInstance(2020, 3, 01),
                Status = 'Credit Adjustment Pending',
                Pricebook2Id = objPriceBook2Id,
                Order_Payment_Status__c = 'Partially Paid',
                Fanatics_Gift_Code_Assignment_Pending__c = true,
                F1_Access_Code_Assignment_Pending__c = true
            );
            lstOrders.add(objOrder);
        }
        lstOrders = Utility.processRecords(lstOrders, 'insert');
        return lstOrders;
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/20/2020 
    * @param NoofRecords 
    * @param dmlFlag 
    * @return List<Order> 
    **/
    public static List<Order> createOrder(Integer NoofRecords, Boolean dmlFlag){
        List<Order> lstOrders = new List<Order>();
        for(integer i= 0; i<NoofRecords; i++){ 
            Order objOrder = new Order(
                AccountId = createAccount().Id,
                QuoteId = createQuote().Id,
                EffectiveDate = date.newInstance(2020, 3, 01),
                Status = 'Draft'
            );
            lstOrders.add(objOrder);
        }
        if(dmlFlag){
            lstOrders = Utility.processRecords(lstOrders, 'insert');
        }
        return lstOrders;
    }

    ///////////////////////////////////////////////  Order Section Ends /////////////////////////////////////////////////////



    /////////////////////////////////////////////// OrderItem Section Starts ////////////////////////////////////////////////

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/18/2020 
    * @return OrderItem 
    **/
    public static OrderItem createOrderItem(){
        Order objOrder = createOrder();
        return createOrderItem(1, objOrder.Id)[0];
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/18/2020 
    * @param Integer NoofRecords 
    * @return List<OrderItem> 
    **/
    public static List<OrderItem> createOrderItem(Integer NoofRecords, Id objOrder){
        List<OrderItem> lstOrderItems = new List<OrderItem>();
        for(integer i= 0; i<NoofRecords; i++){ 
            OrderItem objOrderItem = new OrderItem(
                Quantity = 2,
                OrderId = objOrder,
                UnitPrice = 100,
                ProductType__c = 'F1 Access Code'
            );
            lstOrderItems.add(objOrderItem);
        }
        lstOrderItems = Utility.processRecords(lstOrderItems, 'insert');
        return lstOrderItems;
    }
    
    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/18/2020 
    * @param Integer NoofRecords 
    * @return List<OrderItem> 
    **/
    public static List<OrderItem> createOrderItem(Integer NoofRecords, Id objOrder, QuoteLineItem quoteLineItem){
        List<OrderItem> lstOrderItems = new List<OrderItem>();
        List<String> lstGiftCodeTypes = new List<String>{'F1 Access Code','Fanatics Gift Code','Memento Premium','Memento Ultimate'};
        for(integer i= 0; i<NoofRecords; i++){ 
            OrderItem objOrderItem = new OrderItem(
                Quantity = 2,
                OrderId = objOrder,
                UnitPrice = 100,
                quoteLineItemId = quoteLineItem.Id,
                PricebookEntryId = quoteLineItem.PricebookEntryId,
                ProductType__c = lstGiftCodeTypes[Math.Mod(i,4)]
            );
            lstOrderItems.add(objOrderItem);
        }
        lstOrderItems = Utility.processRecords(lstOrderItems, 'insert');
        return lstOrderItems;
    }
    
    /////////////////////////////////////////////// OrderItems Section Ends //////////////////////////////////////////////////



    //////////////////////////////////////////////   User Section Starts   //////////////////////////////////////////////
    
    public static User createUser(){
        return createUser(1)[0];
    }
    /**
    * @description 
    * @author jthakkar@addonblue.com | 3/16/2020 
    * @param 
    * @return List<User>
    **/
    public static List<User> createUser(Integer NoofRecords){
        List<User> lstUser = new List<User>(); 
        for(integer i= 0; i<NoofRecords; i++){
            User testEventManagerUser = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'QE360 - Sales Admin'].Id,
                LastName = 'last',
                Email = 'testEventManagerUser@quintevents.com',
                Username = 'testEventManagerUser@quintevents.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8', 
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                Slack_User_Id__c = 'U60CJ1YT1',
                IsActive = true
            );
            lstUser.add(testEventManagerUser);
        }
        lstUser = Utility.processRecords(lstUser, 'insert');
        return lstUser;
    }
    
    //////////////////////////////////////////////   User Section Ends   //////////////////////////////////////////////



/*----------------------------------------------------------------------- CUSTOM OBJECT SECTIONS --------------------------------------------------------------------------------------*/



    //////////////////////////////////////////////   Event Payment Term Section Starts   //////////////////////////////////////////////
    
    /**
    * @description 
    * @author mpatel@addonblue.com | 3/16/2020 
    * @return Event_Payment_Terms__c
    **/
    public static Event_Payment_Terms__c createEventPaymentTerm(){
        return createEventPaymentTerm(1)[0];
    }

    /**
    * @description 
    * @author mpatel@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @return List<Event_Payment_Terms__c> 
    **/
    public static List<Event_Payment_Terms__c> createEventPaymentTerm(Integer NoofRecords){
        List<Event_Payment_Terms__c> lstEventPaymentTerms = new List<Event_Payment_Terms__c>();
        //Id recordTypeId = [Select Id,Name From RecordType Where sObjectType='Event_Payment_Terms__c' and Name=:RecordType].Id;
        for(integer i= 0; i<NoofRecords; i++){
        Event_Payment_Terms__c objEventPaymentTerms = new Event_Payment_Terms__c(
            Price_Book__c = createPricebook().id);
            lstEventPaymentTerms.add(objEventPaymentTerms);
        }
        lstEventPaymentTerms = Utility.processRecords(lstEventPaymentTerms, 'insert');
        return lstEventPaymentTerms;
    }
    
    /**
    * @description 
    * @author mpatel@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @return List<Event_Payment_Terms__c> 
    **/
    public static List<Event_Payment_Terms__c> createEventPaymentTerm(Integer NoofRecords, Boolean dmlFlag){
        List<Event_Payment_Terms__c> lstEventPaymentTerms = new List<Event_Payment_Terms__c>();
        //Id recordTypeId = [Select Id,Name From RecordType Where sObjectType='Event_Payment_Terms__c' and Name=:RecordType].Id;
        for(integer i= 0; i<NoofRecords; i++){
        Event_Payment_Terms__c objEventPaymentTerms = new Event_Payment_Terms__c(
            Price_Book__c = createPricebook().id);
            lstEventPaymentTerms.add(objEventPaymentTerms);
        }
        if(dmlFlag){
            lstEventPaymentTerms = Utility.processRecords(lstEventPaymentTerms, 'insert');
        }
        return lstEventPaymentTerms;
    }
    //////////////////////////////////////////////   Event Payment Term Section Ends   //////////////////////////////////////////////
    

    
    //////////////////////////////////////////////   Shipment Section Starts   //////////////////////////////////////////////
    
    /**
    * @description 
    * @author mpatel@addonblue.com | 3/16/2020 
    * @return zkmulti__MCShipment__c
    **/
    public static zkmulti__MCShipment__c createMCShipment(){
        return createMCShipment(1)[0];
    }

    /**
    * @description 
    * @author mpatel@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @return List<zkmulti__MCShipment__c> 
    **/
    public static List<zkmulti__MCShipment__c> createMCShipment(Integer NoofRecords){
        List<zkmulti__MCShipment__c> lstMCShipment = new List<zkmulti__MCShipment__c>();
        for(integer i= 0; i<NoofRecords; i++){
        zkmulti__MCShipment__c objMCShipment = new zkmulti__MCShipment__c(
            Opportunity__c= createOpportunity().id
            );
            lstMCShipment.add(objMCShipment);
        }
        lstMCShipment = Utility.processRecords(lstMCShipment, 'insert');
        return lstMCShipment;
    }
    /**
    * @description 
    * @author mpatel@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @return List<zkmulti__MCShipment__c> 
    **/
    public static List<zkmulti__MCShipment__c> createMCShipment(Integer NoofRecords, Boolean dmlFlag){
        List<zkmulti__MCShipment__c> lstMCShipment = new List<zkmulti__MCShipment__c>();
        for(integer i= 0; i<NoofRecords; i++){
        zkmulti__MCShipment__c objMCShipment = new zkmulti__MCShipment__c(
            Opportunity__c= createOpportunity().id
            );
            lstMCShipment.add(objMCShipment);
        }
        if(dmlFlag){
            lstMCShipment = Utility.processRecords(lstMCShipment, 'insert');
        }
        return lstMCShipment;
    }
    
    
    /**
    * @description 
    * @author kchavda@addonblue.com | 3/23/2020 
    * @return zkmulti__MCShipmate_Preference__c
    **/
    public static zkmulti__MCShipmate_Preference__c createMCShipmatePreference(){
        return createMCShipmatePreference(1)[0];
    }    
    
    /**
    * @description 
    * @author kchavda@addonblue.com | 3/23/2020 
    * @param NoofRecords 
    * @return List<zkmulti__MCShipmate_Preference__c> 
    **/
    public static List<zkmulti__MCShipmate_Preference__c> createMCShipmatePreference(Integer NoofRecords){
        List<zkmulti__MCShipmate_Preference__c> lstMCShipmatePreference = new List<zkmulti__MCShipmate_Preference__c>();
        for(integer i= 0; i<NoofRecords; i++){
        zkmulti__MCShipmate_Preference__c objMCShipmatePreference = new zkmulti__MCShipmate_Preference__c(
            zkmulti__Shipping_Street__c = 'Test Strret',
            zkmulti__Shipping_State__c = 'CA',
            zkmulti__Shipping_Is_Residential__c = true,
            zkmulti__Shipping_Zip_Postal_Code__c = '45214',
            zkmulti__Shipping_Country__c = 'US',
            zkmulti__Shipping_City__c = 'CA',
            zkmulti__Carrier__c = 'UPS'
            );
            lstMCShipmatePreference.add(objMCShipmatePreference);
        }
        lstMCShipmatePreference = Utility.processRecords(lstMCShipmatePreference, 'insert');
        return lstMCShipmatePreference;
    }
    
    /**
    * @description 
    * @author kchavda@addonblue.com | 3/23/2020 
    * @param NoofRecords 
    * @return List<zkmulti__MCShipmate_Preference__c> 
    **/
    public static List<zkmulti__MCShipmate_Preference__c> createMCShipmatePreference(Integer NoofRecords, Boolean dmlFlag){
        List<zkmulti__MCShipmate_Preference__c> lstMCShipmatePreference = new List<zkmulti__MCShipmate_Preference__c>();
        for(integer i= 0; i<NoofRecords; i++){
        zkmulti__MCShipmate_Preference__c objMCShipmatePreference = new zkmulti__MCShipmate_Preference__c(
            zkmulti__Shipping_Street__c = 'Test Strret',
            zkmulti__Shipping_State__c = 'CA',
            zkmulti__Shipping_Is_Residential__c = true,
            zkmulti__Shipping_Zip_Postal_Code__c = '45214',
            zkmulti__Shipping_Country__c = 'US',
            zkmulti__Shipping_City__c = 'CA',
            zkmulti__Carrier__c = 'UPS'
            );
            lstMCShipmatePreference.add(objMCShipmatePreference);
        }
        if(dmlFlag){
            lstMCShipmatePreference = Utility.processRecords(lstMCShipmatePreference, 'insert');
        }
        return lstMCShipmatePreference;
    }
    
    
    /**
    * @description 
    * @author kchavda@addonblue.com | 3/23/2020 
    * @return zkmulti__MCBulk_Shipment__c
    **/
    public static zkmulti__MCBulk_Shipment__c createMCBulkShipment(){
        return createMCBulkShipment(1)[0];
    }    
    
    /**
    * @description 
    * @author kchavda@addonblue.com | 3/23/2020 
    * @param NoofRecords 
    * @return List<zkmulti__MCBulk_Shipment__c> 
    **/
    public static List<zkmulti__MCBulk_Shipment__c> createMCBulkShipment(Integer NoofRecords, Boolean dmlFlag){
        List<zkmulti__MCBulk_Shipment__c> lstMCBulkShipment = new List<zkmulti__MCBulk_Shipment__c>();
        for(integer i= 0; i<NoofRecords; i++){
        zkmulti__MCBulk_Shipment__c objMCBulkShipment = new zkmulti__MCBulk_Shipment__c(
             Processed__c = false,
             PriceBook__c = createPricebook().id,
             zkmulti__Shipmate_Preference__c = createMCShipmatePreference().id
            );
            lstMCBulkShipment.add(objMCBulkShipment);
        }
        if(dmlFlag){
            lstMCBulkShipment = Utility.processRecords(lstMCBulkShipment, 'insert');
        }
        return lstMCBulkShipment;
    }
    
    /**
    * @description 
    * @author kchavda@addonblue.com | 3/23/2020 
    * @param NoofRecords 
    * @return List<zkmulti__MCBulk_Shipment__c> 
    **/
    public static List<zkmulti__MCBulk_Shipment__c> createMCBulkShipment(Integer NoofRecords){
        List<zkmulti__MCBulk_Shipment__c> lstMCBulkShipment = new List<zkmulti__MCBulk_Shipment__c>();
        for(integer i= 0; i<NoofRecords; i++){
        zkmulti__MCBulk_Shipment__c objMCBulkShipment = new zkmulti__MCBulk_Shipment__c(
             Processed__c = false,
             PriceBook__c = createPricebook().id,
             zkmulti__Shipmate_Preference__c = createMCShipmatePreference().id
            );
            lstMCBulkShipment.add(objMCBulkShipment);
        }
        lstMCBulkShipment = Utility.processRecords(lstMCBulkShipment, 'insert');
        return lstMCBulkShipment;
    }
    
    
    //////////////////////////////////////////////   Shipment Section Ends   ////////////////////////////////////////////////
    


    //////////////////////////////////////////////   Payment Term Section Starts   //////////////////////////////////////////////
    /**
    * @description 
    * @author mpatel@addonblue.com | 3/16/2020 
    * @return List<Payment_Term__c> 
    **/
    public static Payment_Term__c createPaymentTerm(){
        Order objOrder = createOrder();
        Quote objquote = [Select id,OpportunityId from Quote where Id =:objOrder.QuoteId];
        return createPaymentTerm(1,objquote.OpportunityId, objOrder.QuoteId, objOrder.Id)[0];
    }
    /**
    * @description 
    * @author mpatel@addonblue.com | 3/16/2020 
    * @return List<Payment_Term__c> 
    **/
    public static Payment_Term__c createPaymentTerm(Decimal PercentageOfPayment){
        Order objOrder = createOrder();
        Quote objquote = [Select id,OpportunityId from Quote where Id =:objOrder.QuoteId];
        return createPaymentTerm(1,objquote.OpportunityId, objOrder.QuoteId, objOrder.Id, PercentageOfPayment)[0];
    }
    /**
    * @description 
    * @author mpatel@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @param Id OpportunityId
    * @param Id QuoteId
    * @param Id OrderId
    * @return List<Payment_Term__c > 
    **/
    public static List<Payment_Term__c> createPaymentTerm(Integer NoofRecords, Id OpportunityId, Id QuoteId , Id OrderId, Decimal PercentageOfPayment){
        system.debug('In Payment Terms');
        List<Payment_Term__c> lstPaymentTerms = new List<Payment_Term__c>();
        for(integer i= 0; i<NoofRecords; i++){
        Payment_Term__c objPaymentTerm = new Payment_Term__c(
            Quote__c = QuoteId,
            Order__c = OrderId,
            Opportunity__c= OpportunityId,
            Status__c = 'Passed',
            Amount__c = 100,
            Percentage_Of_Payment__c = PercentageOfPayment,
            Payment_Due_Date__c = System.today()
            );
            lstPaymentTerms.add(objPaymentTerm);
        } 
        system.debug('lstPaymentTerms-->'+lstPaymentTerms);
        lstPaymentTerms = Utility.processRecords(lstPaymentTerms, 'insert');
        List<Charge__c> lstCharge = new List<Charge__c>();
        for(integer i= 0; i<NoofRecords; i++){
            Charge__c objCharge = new Charge__c();
            objCharge.Payment_Terms__c = lstPaymentTerms[i].Id;
            objCharge.Amount__c = 100;
        }
        insert lstCharge;
        return lstPaymentTerms;
    }
    /**
    * @description 
    * @author mpatel@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @param Id OpportunityId
    * @param Id QuoteId
    * @param Id OrderId
    * @return List<Payment_Term__c > 
    **/
    public static List<Payment_Term__c> createPaymentTerm(Integer NoofRecords, Id OpportunityId, Id QuoteId , Id OrderId){
        system.debug('In Payment Terms');
        List<Payment_Term__c> lstPaymentTerms = new List<Payment_Term__c>();
        for(integer i= 0; i<NoofRecords; i++){
        Payment_Term__c objPaymentTerm = new Payment_Term__c(
            Quote__c = QuoteId,
            Order__c = OrderId,
            Opportunity__c= OpportunityId,
            Status__c = 'Passed',
            Payment_Due_Date__c = System.today()
            );
            lstPaymentTerms.add(objPaymentTerm);
        } 
        system.debug('lstPaymentTerms-->'+lstPaymentTerms);
        lstPaymentTerms = Utility.processRecords(lstPaymentTerms, 'insert');
        List<Charge__c> lstCharge = new List<Charge__c>();
        for(integer i= 0; i<NoofRecords; i++){
            Charge__c objCharge = new Charge__c();
            objCharge.Payment_Terms__c = lstPaymentTerms[i].Id;
            objCharge.Amount__c = 100;
        }
        insert lstCharge;
        return lstPaymentTerms;
    }

    /**
    * @description 
    * @author mpatel@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @return List<Payment_Term__c >
    **/
    public static List<Payment_Term__c> createPaymentTerm(Integer NoofRecords, Boolean dmlFlag){
        List<Payment_Term__c> lstPaymentTerm = new List<Payment_Term__c>();
        for(integer i= 0; i<NoofRecords; i++){
        Payment_Term__c objPaymentTerm = new Payment_Term__c(
            Opportunity__c= createOpportunity().id
            );
            lstPaymentTerm.add(objPaymentTerm);
        }
        if(dmlFlag){  
            lstPaymentTerm = Utility.processRecords(lstPaymentTerm, 'insert');
        }
        return lstPaymentTerm;
    }
    //////////////////////////////////////////////   Payment Term Section Ends   //////////////////////////////////////////////

    
    
    //////////////////////////////////////////////   DocuSign Status Section Starts   //////////////////////////////////////////////
    
    /**
    * @description 
    * @author jthakkar@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @return List<dsfs__DocuSign_Status__c>
    **/
    public static List<dsfs__DocuSign_Status__c> createDocuSignStatus(Quote quote){
        List<dsfs__DocuSign_Status__c> lstDocuSignStatus = new List<dsfs__DocuSign_Status__c>();
        dsfs__DocuSign_Status__c testDSStatus = new dsfs__DocuSign_Status__c(Standard_Quote__c = quote.id, dsfs__Envelope_Status__c = 'Sent',Counter_Signer_Envelope__c = false, dsfs__DocuSign_Envelope_ID__c= 'test');
        lstDocuSignStatus.add(testDSStatus);
        //Utility.processRecords(lstDocuSignStatus, 'insert');
        return lstDocuSignStatus;
    }

    //////////////////////////////////////////////   DocuSign Status Section Ends   //////////////////////////////////////////////
    
    //////////////////////////////////////////////   DocuSign Status Section Starts   //////////////////////////////////////////////
    
    /**
    * @description 
    * @author jthakkar@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @return List<dsfs__DocuSign_Status__c>
    **/
    public static List<dsfs__DocuSign_Status__c> updateDocuSignStatus(dsfs__DocuSign_Status__c testDSStatus){
        List<dsfs__DocuSign_Status__c> lstDocuSignStatus = new List<dsfs__DocuSign_Status__c>();
        testDSStatus.dsfs__Envelope_Status__c = 'Completed';
        testDSStatus.Has_Counter_Signer__c = false;
        
        lstDocuSignStatus.add(testDSStatus);
        //Utility.processRecords(lstDocuSignStatus, 'update');
        return lstDocuSignStatus;
    }

    //////////////////////////////////////////////   DocuSign Status Section Ends   //////////////////////////////////////////////
    


    //////////////////////////////////////////////   DocuSign Receipient Status Section Starts   //////////////////////////////////////////////
    
    /**
    * @description 
    * @author jthakkar@addonblue.com | 3/16/2020 
    * @param NoofRecords 
    * @return List<dsfs__DocuSign_Status__c>
    **/
    public static List<dsfs__DocuSign_Recipient_Status__c> createDocuSignRecStatus(dsfs__DocuSign_Status__c testDSStatus){
        List<dsfs__DocuSign_Recipient_Status__c> lstDocuSignRecStatus = new List<dsfs__DocuSign_Recipient_Status__c>();
        dsfs__DocuSign_Recipient_Status__c testDSRecipient_1 = new dsfs__DocuSign_Recipient_Status__c(dsfs__Recipient_Status__c = 'Start', dsfs__DocuSign_Recipient_Email__c = 'testEventManagerUser@quintevents.com', dsfs__DocuSign_Recipient_Id__c = 'testid', dsfs__Parent_Status_Record__c = testDSStatus.Id);
        lstDocuSignRecStatus.add(testDSRecipient_1);
        return lstDocuSignRecStatus;
    }

    //////////////////////////////////////////////   DocuSign Receipient Status Section Ends   //////////////////////////////////////////////



    //////////////////////////////////////////////   Sales Agent Section Starts   //////////////////////////////////////////////
    
    /**
    * @description 
    * @author jthakkar@addonblue.com | 3/16/2020 
    * @param 
    * @return List<Sales_Agent__c>
    **/
    public static List<Sales_Agent__c> createSalesAgent(Program__c program){
        Sales_Agent__c objSales = new Sales_Agent__c(Name = 'test Agent', All_Event_Access__c = true, Credit_Card__c = true,
                                                     Default_Commission__c = 50, Online_Sales_Commission__c = 50, program__c = program.Id);
        List<Sales_Agent__c> lstSales = new List<Sales_Agent__c>();
        lstSales.add(objSales);
        lstSales = Utility.processRecords(lstSales, 'insert');
        return lstSales;
    }
    //////////////////////////////////////////////   Sales Agent Section Ends   //////////////////////////////////////////////



    //////////////////////////////////////////////   Sales Agent Event Section Starts   //////////////////////////////////////////////
    
    /**
    * @description 
    * @author jthakkar@addonblue.com | 3/16/2020 
    * @param 
    * @return List<Sales_Agent_Event__c>
    **/
    public static List<Sales_Agent_Event__c> createSalesAgentEvent(PriceBook2 priceBook, Sales_Agent__c objSales){
        Sales_Agent_Event__c salesAgentEvent = new Sales_Agent_Event__c(Commission_Percent__c = 20, Price_Book__c = priceBook.Id, Sales_Agent__c = objSales.Id);
        List<Sales_Agent_Event__c> lstSalesAgentEvent = new List<Sales_Agent_Event__c>();
        lstSalesAgentEvent.add(salesAgentEvent);
        lstSalesAgentEvent = Utility.processRecords(lstSalesAgentEvent, 'insert');
        return lstSalesAgentEvent;
    }
    //////////////////////////////////////////////   Sales Agent Event Section Ends   //////////////////////////////////////////////



    //////////////////////////////////////////////   Sales Agent Program Section Starts   //////////////////////////////////////////////
    
    /**
    * @description 
    * @author jthakkar@addonblue.com | 3/16/2020 
    * @param 
    * @return List<Sales_Agent_Program__c>
    **/
    public static List<Sales_Agent_Program__c> createSalesAgentProgram(Program__c program, Sales_Agent__c objSales){
        Sales_Agent_Program__c salesAgentProgram = new Sales_Agent_Program__c(Program__c = program.Id, Sales_Agent__c = objSales.Id);
        List<Sales_Agent_Program__c> lstSalesAgentProgram = new List<Sales_Agent_Program__c>();
        lstSalesAgentProgram.add(salesAgentProgram);
        lstSalesAgentProgram = Utility.processRecords(lstSalesAgentProgram, 'insert');
        return lstSalesAgentProgram;
    }
    //////////////////////////////////////////////   Sales Agent Program Section Ends   //////////////////////////////////////////////



    //////////////////////////////////////////////   Program Section Starts   //////////////////////////////////////////////
    
    /**
    * @description 
    * @author jthakkar@addonblue.com | 3/16/2020 
    * @param 
    * @return List<Program__c>
    **/
    public static List<Program__c> createProgram(){
        Program__c program = new Program__c(
            Name = 'Test Program'
        );
        List<Program__c> lstProgram = new List<Program__c>();
        lstProgram.add(Program);
        lstProgram = Utility.processRecords(lstProgram, 'insert');
        return lstProgram;
    }
    //////////////////////////////////////////////   Program Section Ends   //////////////////////////////////////////////

    //////////////////////////////////////////////   Package Product Starts   //////////////////////////////////////////////
    
    /**
    * @description 
    * @author jthakkar@addonblue.com | 3/16/2020 
    * @param 
    * @return List<Package_Products__c>
    **/
    public static List<Package_Products__c> createPackageProduct(Id productId){
        List<Package_Products__c> lstToInsert = new List<Package_Products__c>();
        Package_Products__c ticketOnePackageProduct = new Package_Products__c(Package__c=productId,Products_and_Hotels__c=productId);
        lstToInsert.add(ticketOnePackageProduct);
        lstToInsert = Utility.processRecords(lstToInsert, 'insert');
        return lstToInsert;
    }
    
    /**
    * @description 
    * @author fsuraitawala@addonblue.com | 04/26/2020 
    * @param 
    * @return List<Parent_Package__c>
    **/
    public static List<Parent_Package__c> createParentPackage(Integer NoofRecords, Boolean dmlFlag, String PricebookId){
        List<Parent_Package__c> lstParentPackage = new List<Parent_Package__c>();
        for(integer i= 0; i < NoofRecords; i++) { 
            Parent_Package__c objParentPackage = new Parent_Package__c(Pricebook2__c = PricebookId);
            
            lstParentPackage.add(objParentPackage);
        }
        if(dmlFlag) {
            lstParentPackage = Utility.processRecords(lstParentPackage , 'insert');
        }
        return lstParentPackage;
    }
    
    
    //////////////////////////////////////////////   Package Product Ends   //////////////////////////////////////////////
    
    //////////////////////////////////////////////   Inventory Transaction Starts   //////////////////////////////////////////////
    
    /**
    * @description 
    * @author jthakkar@addonblue.com | 3/16/2020 
    * @param 
    * @return List<Inventory_Transaction__c>
    **/
    public static List<Inventory_Transaction__c> createInventoryTransaction(Id productId){
        List<Inventory_Transaction__c> lstToInsert = new List<Inventory_Transaction__c>();
        Inventory_Transaction__c InventoryTransaction = new Inventory_Transaction__c(Quantity__c = 50,Product__c = productId,Cost_Per_Quantity__c = 100);
        lstToInsert.add(InventoryTransaction);
        lstToInsert = Utility.processRecords(lstToInsert, 'insert');
        return lstToInsert;
    }
    //////////////////////////////////////////////   Inventory Transaction Ends   //////////////////////////////////////////////    

    //////////////////////////////////////////////   Product Product Starts   //////////////////////////////////////////////
    
    /**
    * @description 
    * @author jthakkar@addonblue.com | 3/16/2020 
    * @param 
    * @return List<Package_Products__c>
    **/
    public static List<Products_Bundle__c> createProductBundle(Id productId){
        List<Products_Bundle__c> lstToInsert = new List<Products_Bundle__c>();
        Products_Bundle__c ProductsBundle = new Products_Bundle__c(Child_product__c = productId, Parent_Product__c = productId, Type__c = 'Hotel');
        lstToInsert.add(ProductsBundle);
        lstToInsert = Utility.processRecords(lstToInsert, 'insert');
        return lstToInsert;
    }
    
    /**
    * @description 
    * @author fsuraitawala@addonblue.com | 04/26/2020 
    * @param 
    * @return Products_Bundle__c
    **/
    public static Products_Bundle__c createProductBundle(Id childProductId, Id parentProductId, String Type){
        Products_Bundle__c ProductsBundle = new Products_Bundle__c(Child_product__c = childProductId, Parent_Product__c = parentProductId, Type__c = Type);
        return ProductsBundle;
    }
    
    //////////////////////////////////////////////   Product Product Ends   //////////////////////////////////////////////

    public static Refund__c createRefund(){
        Refund__c objRef = new Refund__c();
        objRef.Account__c = createAccount().Id;
        objRef.Amount__c = 10;
        objRef.Status__c = 'Test';
        Utility.processRecords(objRef, 'insert');
        return objRef;
    }

    //////////////////////////////////////////////   Custom Setting and Metadata Section Starts   //////////////////////////////////////////////

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @return void 
    **/
    public static void createTriggerSettingsEntry(){
        //VKHOPADE - issue 1194 - added Program__c
        List<String> lstObjectNames = new List<String>{'Account', 'Contact', 'Lead', 'Opportunity', 'Product2', 'Pricebook2','Program__c', 'Attachment', 'Charge__c','Charge', 
                                                        'Quote','Dispute__c', 'Task', 'Order', 'QuoteLineItem', 'OrderItem', 'Gift_Code__c', 'Products_Bundle__c', 'Refund__c','OpportunityLineItem',
                                                        'Inventory_Transaction__c','Payment_Term__c','zkmulti__MCShipment__c','Event_Payment_Terms__c', 'dsfs__DocuSign_Status__c',
                                                        'dsfs__DocuSign_Recipient_Status__c', 'Sales_Agent__c', 'Sales_Agent_Event__c', 'Sales_Agent_Program__c', 'OpportunityContactRoleChangeEvent'};
                                                        
        List<Trigger_Settings__c> lstTriggerSettings = new List<Trigger_Settings__c>();
        for(String objName: lstObjectNames){
            Trigger_Settings__c objTriggerSetting = new Trigger_Settings__c();
            objTriggerSetting.Name = objName;
            objTriggerSetting.Max_Loop_Count__c = 1;
            lstTriggerSettings.add(objTriggerSetting);
        }
        Utility.processRecords(lstTriggerSettings, 'insert');
    }
    
    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/16/2020 
    * @return void 
    **/
    public static Trigger_Settings__c createTriggerSettingsEntry(String objName, Integer maxLoopCount, Boolean deactiveTrigger){
                                                        
        Trigger_Settings__c objTriggerSetting = new Trigger_Settings__c();
        objTriggerSetting.Name = objName;
        objTriggerSetting.Max_Loop_Count__c = maxLoopCount;
        objTriggerSetting.deactivate__c = deactiveTrigger;
        objTriggerSetting = (Trigger_Settings__c)Utility.processRecords(objTriggerSetting, 'insert')[0];
        return objTriggerSetting;
    }
    
    /**
    * @description 
    * @author jthakkar@addonblue.com | 3/23/2020 
    * @return Parent_Package__c 
    **/
    public static Parent_Package__c createParentPackage(Id PricebookId){
        Parent_Package__c objParentPackage = new Parent_Package__c(Name = 'test', Pricebook2__c = PricebookId, CurrencyISOCode = 'USD');
        Utility.processRecords(objParentPackage , 'insert');
        return objParentPackage ;
    }
    
    /**
    * @description 
    * @author jthakkar@addonblue.com | 3/23/2020 
    * @return contactRole 
    **/
    public static OpportunityContactRole createOpportunityContactRole(Quote quote){
        OpportunityContactRole contactRole = new OpportunityContactRole(OpportunityId = quote.opportunityId, contactId = quote.Primary_Contact__c, Role = 'Signee Contact', Custom_Contact__c = false);
        Utility.processRecords(contactRole , 'insert');
        return contactRole ;
    }

    /**
    * @description 
    * @author kchavda@addonblue.com | 3/23/2020 
    * @return void 
    **/
    public static ZK_Print_Labels_Settings__c createZKPrintLabelsSettings(){                      
        ZK_Print_Labels_Settings__c objPrintLabel = new ZK_Print_Labels_Settings__c();        
        objPrintLabel.Masterspread_Report_Id__c = system.label.Test_Shipment_Report_Id;      
        Utility.processRecords(objPrintLabel , 'insert');
        return objPrintLabel;
    }
    

    //////////////////////////////////////////////   Custom Setting and Metadata Section Ends   //////////////////////////////////////////////

    public static void uploadAttachment (Id objID){ 
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=objID;
        insert attach;
    }

    //////////////////////////////////////////////   SFDC Intacct Mapping Section Starts   //////////////////////////////////////////////

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/20/2020 
    * @return void 
    **/
    public static SFDCToIntacctMap__c createSFDCIntacctMapping(){
        return createSFDCIntacctMapping(1)[0];
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/20/2020 
    * @param NoofRecords 
    * @return List<SFDCToIntacctMap__c> 
    **/
    public static List<SFDCToIntacctMap__c> createSFDCIntacctMapping(Integer NoofRecords){
        List<SFDCToIntacctMap__c> lstSFDCIntacctMaps = new List<SFDCToIntacctMap__c>();
        for(Integer i=0; i<NoofRecords; i++){
            SFDCToIntacctMap__c SFDCToIntacctMapObj = new SFDCToIntacctMap__c();
            SFDCToIntacctMapObj.Active__c = true;
            //SFDCToIntacctMapObj.Constant_Value__c = 'each';
            SFDCToIntacctMapObj.Description__c = 'true';
            SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
            SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj.Operation__c = 'create';
            SFDCToIntacctMapObj.Sequence__c = 2.0;
            SFDCToIntacctMapObj.Type__c = 'Order';
            SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Name';
            SFDCToIntacctMapObj.SF_Object__c = 'Order';
            SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
            SFDCToIntacctMapObj.Line_Item__c = false;
            lstSFDCIntacctMaps.add(SFDCToIntacctMapObj);
            
            SFDCToIntacctMapObj = new SFDCToIntacctMap__c();
            SFDCToIntacctMapObj.Active__c = true;
            //SFDCToIntacctMapObj.Constant_Value__c = 'each';
            SFDCToIntacctMapObj.Description__c = 'true';
            SFDCToIntacctMapObj.Intacct_Node_Name__c = 'sotransitems.sotransitem.revrecenddate.da';
            SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj.Operation__c = 'create';
            SFDCToIntacctMapObj.Sequence__c = 2.0;
            SFDCToIntacctMapObj.Type__c = 'Order';
            SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Name';
            SFDCToIntacctMapObj.SF_Object__c = 'Payment_Term__c';
            SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Credit Memo';
            SFDCToIntacctMapObj.Line_Item__c = false;
            lstSFDCIntacctMaps.add(SFDCToIntacctMapObj);
            
            SFDCToIntacctMapObj = new SFDCToIntacctMap__c();
            SFDCToIntacctMapObj.Active__c = true;
            //SFDCToIntacctMapObj.Constant_Value__c = 'each';
            SFDCToIntacctMapObj.Description__c = 'true';
            SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
            SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj.Operation__c = 'create';
            SFDCToIntacctMapObj.Sequence__c = 2.0;
            SFDCToIntacctMapObj.Type__c = 'Order';
            SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Name';
            SFDCToIntacctMapObj.SF_Object__c = 'Payment_Term__c';
            SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Invoice';
            SFDCToIntacctMapObj.Line_Item__c = false;
            lstSFDCIntacctMaps.add(SFDCToIntacctMapObj);

            SFDCToIntacctMapObj = new SFDCToIntacctMap__c();
            SFDCToIntacctMapObj.Active__c = true;
            SFDCToIntacctMapObj.Constant_Value__c = 'each';
            SFDCToIntacctMapObj.Description__c = 'true';
            SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
            SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj.Operation__c = 'create';
            SFDCToIntacctMapObj.Sequence__c = 2.0;
            SFDCToIntacctMapObj.Type__c = 'Order';
            SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Name';
            SFDCToIntacctMapObj.SF_Object__c = 'Account';
            SFDCToIntacctMapObj.Intacct_Object__c = 'customer';
            SFDCToIntacctMapObj.Line_Item__c = false;
            lstSFDCIntacctMaps.add(SFDCToIntacctMapObj);

            SFDCToIntacctMapObj = new SFDCToIntacctMap__c();
            SFDCToIntacctMapObj.Active__c = true;
            //SFDCToIntacctMapObj.Constant_Value__c = 'each';
            SFDCToIntacctMapObj.Description__c = 'true';
            SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
            SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj.Operation__c = 'create';
            SFDCToIntacctMapObj.Sequence__c = 2.0;
            SFDCToIntacctMapObj.Type__c = 'Order';
            SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Name';
            SFDCToIntacctMapObj.SF_Object__c = 'Contact';
            SFDCToIntacctMapObj.Intacct_Object__c = 'Contact';
            SFDCToIntacctMapObj.Line_Item__c = false;
            lstSFDCIntacctMaps.add(SFDCToIntacctMapObj);

            SFDCToIntacctMapObj = new SFDCToIntacctMap__c();
            SFDCToIntacctMapObj.Active__c = true;
            //SFDCToIntacctMapObj.Constant_Value__c = 'each';
            SFDCToIntacctMapObj.Description__c = 'true';
            SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
            SFDCToIntacctMapObj.Intacct_Table__c = 'create_arpayment';
            SFDCToIntacctMapObj.Operation__c = 'create';
            SFDCToIntacctMapObj.Sequence__c = 2.0;
            SFDCToIntacctMapObj.Type__c = 'Order';
            SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Name';
            SFDCToIntacctMapObj.SF_Object__c = 'Charge__c';
            SFDCToIntacctMapObj.Intacct_Object__c = 'arpayment';
            SFDCToIntacctMapObj.Line_Item__c = false;
            
            lstSFDCIntacctMaps.add(SFDCToIntacctMapObj);
        }
        lstSFDCIntacctMaps = Utility.processRecords(lstSFDCIntacctMaps, 'insert');
        return lstSFDCIntacctMaps;
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/20/2020 
    * @param NoofRecords 
    * @param performInsert 
    * @return List<SFDCToIntacctMap__c> 
    **/
    public static List<SFDCToIntacctMap__c> createSFDCIntacctMapping(Integer NoofRecords, Boolean performInsert){
        List<SFDCToIntacctMap__c> lstSFDCIntacctMaps = new List<SFDCToIntacctMap__c>();
        for(Integer i=0; i<NoofRecords; i++){
            SFDCToIntacctMap__c SFDCToIntacctMapObj = new SFDCToIntacctMap__c();
            SFDCToIntacctMapObj.Active__c = true;
            SFDCToIntacctMapObj.Constant_Value__c = 'each';
            SFDCToIntacctMapObj.Description__c = 'true';
            SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
            SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj.Operation__c = 'create';
            SFDCToIntacctMapObj.Sequence__c = 2.0;
            SFDCToIntacctMapObj.Type__c = 'true';
            SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Name';
            SFDCToIntacctMapObj.SF_Object__c = 'Contact';
            SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
            SFDCToIntacctMapObj.Line_Item__c = false;
            lstSFDCIntacctMaps.add(SFDCToIntacctMapObj);
        }
        if(performInsert) lstSFDCIntacctMaps = Utility.processRecords(lstSFDCIntacctMaps, 'insert');
        return lstSFDCIntacctMaps;
    }

    //////////////////////////////////////////////   SFDC Intacct Mapping Section Ends   //////////////////////////////////////////////

}
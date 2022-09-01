@isTest
public class QE_TestDataFactory {
    public static void createTestRecords() {
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
        insert personLead;
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
        insert businessLead;
        // Convert Person Lead
        Database.LeadConvert lcPerson = new database.LeadConvert();
        lcPerson.setLeadId(personLead.id);
        lcPerson.setDoNotCreateOpportunity(true);
        lcPerson.setConvertedStatus('Converted');
        Database.LeadConvertResult lcrPerson = Database.convertLead(lcPerson);
        System.assert(lcrPerson.isSuccess());
        Lead convertedPersonLead = [select Id, IsConverted, ConvertedAccountId,ConvertedContactId from Lead where Id = :personLead.Id];
        // Convert Business Lead
        Database.LeadConvert lcBusiness = new database.LeadConvert();
        lcBusiness.setLeadId(businessLead.id);
        lcBusiness.setDoNotCreateOpportunity(true);
        lcBusiness.setConvertedStatus('Converted');
        Database.LeadConvertResult lcrBusiness = Database.convertLead(lcBusiness);
        System.assert(lcrBusiness.isSuccess());
        Lead convertedBusinessLead = [select Id, IsConverted, ConvertedAccountId,ConvertedContactId  from Lead where Id = :businessLead.Id];
        
               
        // Create Event
        QE360_Event__c eventOne = new QE360_Event__c(Name='normal event',Active__c = true, start_date__c = system.today(), end_date__c = system.today() + 5);
        insert eventOne;
        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = eventOne.Id;
        insert parentPackage;
        // Create Event Products and Packages
        // Get Product2 record types
        Id recordTypeProduct = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Products'].Id;
        Id recordTypeHotel = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Hotels'].Id;
        Id recordTypePackage = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Package'].Id;
        // Products to insert
        List<Product2> productsToInsert = new List<Product2>();
        // Products
        Product2 ticketOne = new Product2(Name='tiket one',Type__c='Ticket',A_La_Carte__c=true,Inventory__c=10,Event__c=eventOne.Id,RecordTypeId=recordTypeProduct,isActive=true);
        productsToInsert.add(ticketOne);
        Product2 HospitalityOne = new Product2(Name='tiket one',Type__c='Hospitality',A_La_Carte__c=true,Inventory__c=10,Event__c=eventOne.Id,RecordTypeId=recordTypeProduct,isActive=true);
        productsToInsert.add(HospitalityOne);
        // Packages
        Product2 packageOne = new Product2(Name='package one',A_La_Carte__c=true,Event__c=eventOne.Id,RecordTypeId=recordTypePackage,isActive=true, parent_package__c=parentPackage.id,Inventory__c=5);
        productsToInsert.add(packageOne);
        insert productsToInsert;
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
        insert pricebookEntries;
        // Package Products
        Package_Products__c ticketOnePackageProduct = new Package_Products__c(Package__c=packageOne.Id,Products_and_Hotels__c=ticketOne.Id);
        Insert ticketOnePackageProduct;
        
        Account account = new Account();
        account.RecordTypeId = '012i00000015Y4x';
        account.Name = 'Test Account';
        account.CurrencyIsoCode = 'USD';
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Test Last Name';
        contact.AccountId = account.Id;
        contact.CurrencyIsoCode = 'USD';
        contact.Email = 'GPE19999@gmail.com';
        contact.Phone = '8527419630';
        insert contact;
        
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
        personOpportunity.Contact_Site__c = 'quintevents.com';   
        personOpportunity.Primary_Contact__c =  contact.Id;           
        insert personOpportunity;
        // Opportunity Line Items for Person Opportunity
        OpportunityLineItem ticketOneOli = new OpportunityLineItem (
            Quantity=2,Product2ID=ticketOne.Id,OpportunityId=personOpportunity.Id,UnitPrice=0.01,PriceBookEntryId=ticketOnePbe.Id);
        //insert ticketOneOli;
        // Person Qupote
        Quote quoteForPersonOpportunity = new Quote(
            Name='person opportunity quote',Payment_Terms__c = '1/2',OpportunityId=personOpportunity.Id,Status='Draft',
            Payment_Method__c='Credit Card',Email='testperson@quintevnts.com',Pricebook2Id = Test.getStandardPricebookId());
        insert quoteForPersonOpportunity;
        // Quote Line Items for Person Quote
        QuoteLineItem ticketOneQli = new QuoteLineItem (Quantity=2,Product2ID=ticketOne.Id, QuoteId=quoteForPersonOpportunity.Id,UnitPrice=0.01,PriceBookEntryId=ticketOnePbe.Id);
        insert ticketOneQli;
         QuoteLineItem ticketOneQli1 = new QuoteLineItem (Quantity=2,Product2ID=ticketOne.Id, QuoteId=quoteForPersonOpportunity.Id,UnitPrice=0.01,PriceBookEntryId=ticketOnePbe.Id);
        insert ticketOneQli1;
    }
}
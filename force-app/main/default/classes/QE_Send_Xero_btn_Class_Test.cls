@isTest
private class QE_Send_Xero_btn_Class_Test { 
    @testSetup static void setup() {
        Program__c program = new Program__c();
        program.Name = 'test prgram F1E';
        insert program;

        QE360_Event__c events = new QE360_Event__c();
        events.Name = 'Test Event';
        events.CurrencyIsoCode = 'USD';
        events.Program__c = program.Id;
        events.GPE_Event__c = true;
        insert events;

        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = events.Id;
        insert parentPackage;

        product2 product = [select id,Name,RecordTypeId,Event__c,CurrencyIsoCode,Price__c,A_La_Carte__c,isActive from Product2 where Name=:'Discount' limit 1];

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
        
        Account account1 = new Account();
        account1.RecordTypeId = '012i00000015Y4x';
        account1.Name = 'Test Account';
        account1.CurrencyIsoCode = 'USD';
        account1.Primary_Contact__c = contact.Id;
        insert account1;            

        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = product.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 0.00;
        pbe.IsActive = True;
        pbe.CurrencyIsoCode = 'USD';
        insert pbe;

        Opportunity opportunity = new Opportunity();
        opportunity.RecordTypeId = '012i00000012AaS';
        opportunity.AccountId = account.Id;
        opportunity.Name = 'Test Opportunity';
        opportunity.StageName = 'Closed Won';
        opportunity.Probability =  10;
        opportunity.Payment_Method__c ='Check';
        opportunity.Event__c = events.Id;
        opportunity.CloseDate = System.today();
        opportunity.Contact_Site__c = 'barrettjacksonvip.com';
        opportunity.CurrencyIsoCode = 'USD';
        opportunity.Primary_Contact__c = contact.Id;
        opportunity.Email__c = 'test@gmail.com';
        opportunity.Phone__c = '1234567896';
        opportunity.is_Applied_Rewards__c = true;        
        insert opportunity;

        
    }    
     @isTest static void testMethodTwo() {
        Test.startTest();
        QE360_Event__c events = [Select id from QE360_Event__c];
        //events.GPE_Event__c = true;
        //update events;
        Account account = [Select Id from Account limit 1];
        Contact contact = [Select Id from Contact limit 1];
        Opportunity opportunity = new Opportunity();
        opportunity.RecordTypeId = '012i00000012AaS';
        opportunity.AccountId = account.Id;
        opportunity.Name = 'Test Opportunity';
        opportunity.StageName = 'Closed Won';
        opportunity.Probability =  10;
        opportunity.Payment_Method__c ='Check';
        opportunity.Event__c = events.Id;
        opportunity.CloseDate = System.today();
        opportunity.Contact_Site__c = 'barrettjacksonvip.com';
        opportunity.CurrencyIsoCode = 'USD';
        opportunity.Primary_Contact__c = contact.Id;
        opportunity.Email__c = 'test@gmail.com';
        opportunity.Phone__c = '1234567896';
        opportunity.is_Applied_Rewards__c = true;
        opportunity.Intacct_Status__c = 'Success';
        opportunity.Sandbox_Intacct_Status__c = 'Success';
        insert opportunity;
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opportunity);        
        Test.setCurrentPageReference(new PageReference('Page.QE_Send_Xero_btn_Page')); 
        ApexPages.currentPage().getParameters().put('Oppid', opportunity.id);
        QE_Send_Xero_btn_Class testRecord = new QE_Send_Xero_btn_Class(sc);
        testRecord.closePopup();
        testRecord.RedirectMethod();
    }
    @isTest static void testMethodThree() {
        Test.startTest();
        QE360_Event__c events = [Select id from QE360_Event__c];
        //events.GPT_Event__c = true;
        //update events;
        Account account = [Select Id from Account limit 1];
        Contact contact = [Select Id from Contact limit 1];
        Opportunity opportunity = new Opportunity();
        opportunity.RecordTypeId = '012i00000012AaS';
        opportunity.AccountId = account.Id;
        opportunity.Name = 'Test Opportunity';
        opportunity.StageName = 'Closed Won';
        opportunity.Probability =  10;
        opportunity.Payment_Method__c ='Check';
        opportunity.Event__c = events.Id;
        opportunity.CloseDate = System.today();
        opportunity.Contact_Site__c = 'barrettjacksonvip.com';
        opportunity.CurrencyIsoCode = 'USD';
        opportunity.Primary_Contact__c = contact.Id;
        opportunity.Email__c = 'test@gmail.com';
        opportunity.Phone__c = '1234567896';
        opportunity.is_Applied_Rewards__c = true;
        opportunity.Xero_Contact_Status__c = 'Success';
        opportunity.Xero_Invoice_Status__c = 'Success';
        insert opportunity;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opportunity);        
        Test.setCurrentPageReference(new PageReference('Page.QE_Send_Xero_btn_Page')); 
        ApexPages.currentPage().getParameters().put('Oppid', opportunity.id);
        QE_Send_Xero_btn_Class testRecord = new QE_Send_Xero_btn_Class(sc);
        
         testRecord.RedirectMethod();
    }
}
@isTest
private class GPE_OnlineSaleCtrl_Test {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();
        Program__c program = new Program__c();
        program.Name = 'test prgram F1E';
        insert program;

        QE360_Event__c events = new QE360_Event__c();
        events.Name = 'Test Event';
        events.CurrencyIsoCode = 'USD';
        events.Program__c = program.Id;
        events.GPT_Event_Id__c = '3401';
        insert events;

        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = events.Id;
        insert parentPackage;

        product2 product =new product2();
        Product.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotel').getRecordTypeId();
        product.Name = 'Product';
        product.Event__c = events.Id;
        product.Type__c = 'Hotels';
        product.CurrencyIsoCode = 'USD';
        product.Price__c = 120.00;
        product.A_La_Carte__c = true;
        product.isActive = true;
        product.Parent_Package__c = parentPackage.Id;
        product.GPT_Article_Id__c = '23434';
        insert product;

        Account account = new Account();
        account.RecordTypeId = '012i00000015Y4x';
        account.Name = 'Test Account';
        account.CurrencyIsoCode = 'USD';
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Test Last Name';
        contact.AccountId = account.Id;
        contact.CurrencyIsoCode = 'USD';
        contact.Email = 'GPELea1d@gmail.com';
        insert contact;

        

        PricebookEntry pricebookentry = new PricebookEntry();
        pricebookentry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookentry.Product2Id = product.Id;
        pricebookentry.UnitPrice = 100;
        pricebookentry.CurrencyIsoCode = 'USD';
        pricebookentry.isActive = true;
        insert pricebookentry;

        Opportunity opp = new Opportunity();
        opp.AccountId = account.Id;
        opp.Name = 'test recordq'; 
        opp.StageName = 'Prospecting';
        opp.CloseDate = date.today();
        opp.Event__c = events.Id;
        opp.Contact_Site__c = 'barrettjacksonvip.com';
        opp.Primary_Contact__c = contact.Id;
        insert opp;

        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.PricebookEntryId = pricebookentry.Id;
        oppLineItem.Quantity = 100;
        oppLineItem.UnitPrice = 10;
        oppLineItem.Product2Id = product.Id;
        oppLineItem.ApexProductType__c = 'Hotel';
        oppLineItem.ApexProductName__c = Product.Name;
        oppLineItem.ApexCost__c = 120;  
        oppLineItem.Opportunity_Product_Package_Hotel__c = true;
        oppLineItem.Package__c = product.Id;
        insert oppLineItem;
    }
    @isTest static void testMethodOne() {
    //static testMethod void test_method_one() {   
        //QE360_Event__c events = [Select id from QE360_Event__c limit 1];
        
        Test.startTest();
        Account account = new Account();
        account.RecordTypeId = '012i00000015Y4x';
        account.Name = 'Test Accountsded';
        account.CurrencyIsoCode = 'USD';
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Test Last Name';
        contact.AccountId = account.Id;
        contact.CurrencyIsoCode = 'USD';
        contact.Email = 'GPELea1d@gmail.comttt';
        insert contact;

        //Account account =[Select id from Account limit 1];
        //Contact contact = [Select id from contact limit1];
        Opportunity opp = [Select id,CurrencyIsoCode from Opportunity limit 1];
        List<Product2> productList = [Select id,Event__c from Product2];
        QE360_Event__c events = [Select Id,Owner.Email,Owner.Name from QE360_Event__c limit 1];
        List<OpportunityLineItem> OppLineItem = [Select id from OpportunityLineItem];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg = '{"gpesale":';
        JsonMsg += '{"city":"suzuka city","country":"Japan","currencyCharged":"USD", "email":"GPELea1d@gmail.com",  "fees":     {       "order_processing_fee":26.0,"shipping_fee":27.0';
        JsonMsg +='},  "firstName":"GPEFirstName",    "gpeEventName":"F1 Paddock Club, Formula One Paddock Clubâ„¢, Japanese Grand Prix", "gptBookingId":"",  "lastName":"TANAKA",    "lineItems":[       {       "Name":"",';
        JsonMsg +='"articleid":"96214",       "price":"200.00",     "quantity":40        },   {    "Name":"test 2","articleid":"14525",       "price":"200.00",     "quantity":40        }   ],  "phone":"+819086700184",    "state":"", "street":"5choume20-15 sanjo", "total":"54", "zip":"513-0806"}}';
        GPE_ApexToJsonClass gpeSales = (GPE_ApexToJsonClass) JSON.deserialize(JsonMsg, GPE_ApexToJsonClass.class);
        req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
    
        GPE_OnlineSaleCtrl resp = new GPE_OnlineSaleCtrl(); 
        GPE_OnlineSaleCtrl.create();
        Set<GPE_ApexToJsonClass.LineItems> OnlineSaleLineItemSet =  new Set<GPE_ApexToJsonClass.LineItems>();
        for (GPE_ApexToJsonClass.LineItems item : gpeSales.Gpesale.lineItems) {
            OnlineSaleLineItemSet.add(item);
        }
        //GPE_OnlineSaleCtrl.createEventBaseOpportunity(account, Contact, productList, gpeSales.Gpesale, OnlineSaleLineItemSet);
        Map<String, Decimal> product2PriceMap = new Map<String, Decimal>();
        product2PriceMap.put('96214', 100.10);
        Map<String, String> itemsAsProductNameMap = new Map<String, String>();
        
        GPE_OnlineSaleCtrl.addOpportunityLineItem(opp, OnlineSaleLineItemSet, productList, events.id, gpeSales.Gpesale);
        GPE_OnlineSaleCtrl.getPricebookEntries('USD', product2PriceMap, productList, itemsAsProductNameMap);
        GPE_OnlineSaleCtrl.crtQuote(opp, OppLineItem);
        GPE_OnlineSaleCtrl.createPaymentTerm(opp.Id);
        GPE_OnlineSaleCtrl.dummyCoverage();
       // GPE_OnlineSaleCtrl.createLead();
        Test.stopTest();
    }
    // @isTest static void testMethodTwo() {
        
    //     Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);        
    //     Update standardPricebook;

    //     //Product2 product = [select Id,GPT_Article_Id__c from Product2 limit 1];
   
    //     Test.startTest();
    //     Contact contact = [Select Id from Contact limit 1];
    //     QE360_Event__c events = [Select id from QE360_Event__c limit 1];
    //     Parent_Package__c parentPackage = [Select id from Parent_Package__c limit 1];
    //     product2 product1 =new product2();
    //     Product1.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId();
    //     product1.Name = 'Product';
    //     product1.Event__c = events.Id;
    //     product1.Type__c = 'Ticket';
    //     product1.CurrencyIsoCode = 'USD';
    //     product1.Price__c = 120.00;
    //     product1.A_La_Carte__c = true;
    //     product1.isActive = true;
    //     product1.Parent_Package__c = parentPackage.Id;
    //     insert product1;
    //     RestRequest req = new RestRequest(); 
    //     RestResponse res = new RestResponse();
        
    //     String JsonMsg = '{"gpesale":';
    //     JsonMsg += '{"city":"suzuka city","country":"Japan","currencyCharged":"USD", "email":"GPELea1d@gmail.com",  "fees":     {       "order_processing_fee":26.0,"shipping_fee":27.0';
    //     JsonMsg +='},  "firstName":"GPEFirstName",    "gpeEventName":"F1 Paddock Club, Formula One Paddock Clubâ„¢, Japanese Grand Prix", "gptBookingId":"",  "lastName":"TANAKA",    "lineItems":[       {       "Name":"",';
    //     JsonMsg +='"articleid":"23434",       "price":"200.00",     "quantity":40        },   {    "Name":"test 2","articleid":"",       "price":"200.00",     "quantity":40        }   ],  "phone":"+819086700184",    "state":"", "street":"5choume20-15 sanjo", "total":"54", "zip":"513-0806"}}';
        
    //     req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
    //     req.httpMethod = 'POST';//HTTP Request Type
    //     req.requestBody = Blob.valueof(JsonMsg);
    //     RestContext.request = req;
    //     RestContext.response= res;
    
    //     GPE_OnlineSaleCtrl resp = new GPE_OnlineSaleCtrl(); 
    //     GPE_OnlineSaleCtrl.create();
    //     Test.stopTest();
    // }
    // @isTest static void testMethodThree() {
        
        
    //     Test.startTest();
    //     Lead lead = new Lead();
    //     lead.Google_Analytics_ID__c = 'gaID';
    //     lead.Google_Analytics_Site_Id__c = 'gaSiteId';
    //     lead.FirstName = 'testName';
    //     lead.LastName = 'testName';
    //     lead.Status = 'Interested';
    //     lead.Source__c = 'call Virtuoso';
    //     lead.Company = 'test business';
    //     lead.email = 'GPELearegrtgtrg1d@gmail.com';
    //     insert lead;
    //     Product2 product = [select Id,GPT_Article_Id__c from Product2 limit 1];
    //     RestRequest req = new RestRequest(); 
    //     RestResponse res = new RestResponse();
        
    //     String JsonMsg = '{"gpesale":';
    //     JsonMsg += '{"city":"suzuka city","country":"Japan","currencyCharged":"USD", "email":"GPELearegrtgtrg1d@gmail.com",  "fees":     {       "order_processing_fee":26.0,"shipping_fee":27.0';
    //     JsonMsg +='},  "firstName":"GPEFirstName",    "gpeEventName":"F1 Paddock Club, Formula One Paddock Clubâ„¢, Japanese Grand Prix", "gptBookingId":"",  "lastName":"TANAKA",    "lineItems":[       {       "Name":"",';
    //     JsonMsg +='"articleid":"456456",       "price":"200.00",     "quantity":40        } ],  "phone":"+819086700184",    "state":"", "street":"5choume20-15 sanjo", "total":"54", "zip":"513-0806"}}';
        
    //     req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
    //     req.httpMethod = 'POST';//HTTP Request Type
    //     req.requestBody = Blob.valueof(JsonMsg);
    //     RestContext.request = req;
    //     RestContext.response= res;
    
    //     GPE_OnlineSaleCtrl resp = new GPE_OnlineSaleCtrl(); 
    //     GPE_OnlineSaleCtrl.create();
    //     Test.stopTest();
    // }
}
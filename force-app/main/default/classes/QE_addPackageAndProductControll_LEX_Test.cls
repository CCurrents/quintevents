@isTest
public class QE_addPackageAndProductControll_LEX_Test {

    @testSetup static void setup() {
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Source__c = 'call Virtuoso';
        lead.Company = 'test business';
        lead.email = 'test@quintevents.com';
        insert lead;

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId,ConvertedContactId from Lead where Id = :lead.Id];

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

        product2 product = [select id,Name,RecordTypeId,Event__c,CurrencyIsoCode,Price__c,A_La_Carte__c,isActive from Product2 where Name=:'Discount' limit 1];

        Contact contact = new Contact();
        contact.LastName = 'Test Last Name';
        contact.AccountId = testLead.ConvertedAccountId;
        contact.CurrencyIsoCode = 'USD';
        contact.Email = 'test@gmail.com';
        insert contact;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = product.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 0.00;
        pbe.IsActive = True;
        pbe.CurrencyIsoCode = 'USD';
        insert pbe;

        Opportunity opportunity = new Opportunity();
        opportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Person Opportunity').getRecordTypeId();
        opportunity.AccountId = testLead.ConvertedAccountId;
        opportunity.Name = 'Test Opportunity';
        opportunity.StageName = 'Qualified';
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

        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opportunity.Id;
        oppLineItem.PricebookEntryId = pbe.Id;
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

    static testMethod void testMethodOne() {
        QE_addPackageAndProductController_LEX.fetchOpportunity();
        PricebookEntry pbe = [Select Id from PricebookEntry];
        List<Opportunity> opportunity  = [select Id,is_Applied_Rewards__c from Opportunity limit 1];
        QE_addPackageAndProductController_LEX.getOpportunity(opportunity[0].Id);
        QE_addPackageAndProductController_LEX.opportunityDetails(opportunity[0].Id);
        QE_addPackageAndProductController_LEX.getProductRecprdType();
        QE_addPackageAndProductController_LEX.getOldSelectedProducts(opportunity[0].Id);
        String str = 'Hotels';
        
        Test.startTest();
        QE_addPackageAndProductController_LEX.getproduct(str,opportunity[0].Id);

        String displayString = '[{"objProduct":{"UseStandardPrice":false,"Name":"TestProductV1.1","Product2Id":"01tc0000006U2SRAA0","Pricebook2Id":"01si0000002KOY1AAO","UnitPrice":0,"Id":"01uc000000c5wwfAAA","IsActive":true,"Product2":{"Event__c":"a0bc0000007LxNeAAK","Name":"TestProductV1.1","RecordTypeId":"012i00000012AZsAAM","Type__c":"Package","Id":"01tc0000006U2SRAA0","Event__r":{"Name":"TestEventV1.1","Id":"a0bc0000007LxNeAAK"},"RecordType":{"Id":"012i00000012AZsAAM","Name":"Package"}}},"selectBit":true}]';
        String itemList = '[]';//'[{"Apex_No_of_Hotels__c":0,"Name":"TestEventV1.1 TestProductV1.0","Opportunity_Product_Package_Hotel__c":false,"Product2Id":"01tc0000006TUsRAAW","Price__c":500,"PricebookEntryId":"01uc000000bLCLcAAO","Quantity":10,"UnitPrice":500,"ApexProductType__c":"Hotels","ApexProductName__c":"TestProductV1.0","Product2":{"Price__c":500,"Id":"01tc0000006TUsRAAW"}}]';
        QE_addPackageAndProductController_LEX.getSavedOppList(displayString, opportunity[0].Id, itemList);
        QE_addPackageAndProductController_LEX.saveOpportunitys(opportunity[0].Id, itemList,opportunity[0]);
        QE_addPackageAndProductController_LEX.getFilteredProduct(str, opportunity[0].Id, 'TestProduct');
        QE_addPackageAndProductController_LEX.getFilteredListProduct(opportunity[0].Id, 'Test');

        String jsonString = '[{"objProduct":{"Products_and_Hotels__c":"01tc0000006UpjyAAC","Active__c":true,"Amount__c":150,"Product_Type__c":"Hotels","Id":"a01c000000Bql03AAB","Products_and_Hotels__r":{"RecordTypeId":"012i00000012AZrAAM","Price__c":500,"Name":"TestProductV1.13","IsActive":true,"Type__c":"Hotel","Id":"01tc0000006UpjyAAC","RecordType":{"Name":"Hotels","Id":"012i00000012AZrAAM"}}},"oliId":"00kc000000BBEPyAAP","preSelected":true,"price":500,"quantity":1,"roomType":"One Bed","selectBit":true,"selectDel":false}]';
        String jsonStringTransport = '[{"objHotelTransportation":{"Id":"a0xc0000002zke9AAA","Hotel__c":"01tc0000006TUsRAAW","Transportation__c":"01tc0000006U2SWAA0","Transportation__r":{"Name":"TestProductV1.2","RecordTypeId":"012i00000012AZtAAM","Type__c":"Ticket","Price__c":0,"IsActive":true,"Id":"01tc0000006U2SWAA0","RecordType":{"Name":"Products","Id":"012i00000012AZtAAM"}}},"preSelected":true,"price":0,"quantity":1,"selectBit":true,"selectDel":false}]';
        QE_addPackageAndProductController_LEX.addHotelPopup(opportunity[0].Id, pbe.Id, jsonString, jsonStringTransport);

        Test.setMock(HttpCalloutMock.class, new QE_restH4HCalloutTest());
        QE_H4HCalloutClass.getTokenSiteAdmin(opportunity[0].Id, true);
        QE_H4HCalloutClass.getTokenSiteAdmin(opportunity[0].Id, false);
        QE_addPackageAndProductController_LEX.h4hPoints(opportunity[0].Id);
        Test.stopTest();
    }

    static testMethod void testMethodTwo() {
        Program__c program = [Select id from Program__c];
        Account account = [Select Id from Account limit 1];
        QE360_Event__c events = [Select id from QE360_Event__c limit 1];

        product2 product =new product2();
        Product.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId();
        product.Name = 'Test Product';
        product.Event__c = events.Id;
        product.Type__c = 'Ticket';
        product.CurrencyIsoCode = 'USD';
        product.Price__c = 120.00;
        product.A_La_Carte__c = true;
        product.isActive = true;
        insert product;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = product.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 0.00;
        pbe.IsActive = True;
        pbe.CurrencyIsoCode = 'USD';
        insert pbe;

        Test.startTest();
        Opportunity opportunity = [select Id from Opportunity limit 1];
        String str = 'Products';
        QE_addPackageAndProductController_LEX.getproduct(str,opportunity.Id);
        QE_addPackageAndProductController_LEX.getFilteredProduct(str, opportunity.Id, 'TestProduct');
        Test.stopTest();
    }

    static testMethod void testMethodThree() {
        QE360_Event__c events = [Select id from QE360_Event__c limit 1];
        Parent_Package__c parentPackage = [Select id From Parent_Package__c];

        product2 product =new product2();
        Product.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId();
        product.Name = 'Test Product';
        product.Event__c = events.Id;
        product.Type__c = 'Package';
        product.CurrencyIsoCode = 'USD';
        product.Price__c = 120.00;
        product.A_La_Carte__c = true;
        product.isActive = true;
        product.Parent_Package__c = parentPackage.Id;
        insert product;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = product.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 0.00;
        pbe.IsActive = True;
        pbe.CurrencyIsoCode = 'USD';
        insert pbe;
        
        Test.startTest();
        Opportunity opportunity  = [select Id from Opportunity limit 1];
        String str = 'Package';
        QE_addPackageAndProductController_LEX.getproduct(str,opportunity.Id);
        QE_addPackageAndProductController_LEX.getFilteredProduct(str, opportunity.Id, 'TestProduct');
        Test.stopTest();
    }

    static testMethod void testMethodFour() {
        QE360_Event__c events = [Select id from QE360_Event__c limit 1];
        Parent_Package__c parentPackage = [Select id From Parent_Package__c];
        product2 product = [select id from product2 limit 1];
        
        Test.startTest();
        product2 product1 =new product2();
        Product1.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId();
        product1.Name = 'Test Product2';
        product1.Event__c = events.Id;
        product1.Type__c = 'Hotel';
        product1.CurrencyIsoCode = 'USD';
        product1.Price__c = 120.00;
        product1.A_La_Carte__c = true;
        product1.isActive = true;
        product1.Parent_Package__c = parentPackage.Id;
        insert product1;

        Package_Products__c packageProduct = new Package_Products__c();
        packageProduct.Package__c = product.Id;
        packageProduct.Products_and_Hotels__c = product1.Id;
        packageProduct.CurrencyIsoCode = 'USD';
        insert packageProduct;

        Hotel_Transportation__c hotelTrans = new Hotel_Transportation__c();
        hotelTrans.Hotel__c = product1.Id;
        hotelTrans.Transportation__c = product1.Id;
        hotelTrans.CurrencyIsoCode = 'USD';
        insert hotelTrans;

        
        Opportunity opportunity  = [select Id from Opportunity limit 1];
        PricebookEntry pbe = [Select Id from PricebookEntry];
        QE_addPackageAndProductController_LEX.showPopup(opportunity.Id, pbe.Id);
        String itemList = '[]';
        String displayString = '[{"objProduct":{"UseStandardPrice":false,"Name":"TestProductV1.1","Product2Id":"01tc0000006U2SRAA0","Pricebook2Id":"01si0000002KOY1AAO","UnitPrice":0,"Id":"01uc000000c5wwfAAA","IsActive":true,"Product2":{"Event__c":"a0bc0000007LxNeAAK","Name":"TestProductV1.1","RecordTypeId":"012i00000012AZsAAM","Type__c":"Package","Id":"01tc0000006U2SRAA0","Event__r":{"Name":"TestEventV1.1","Id":"a0bc0000007LxNeAAK"},"RecordType":{"Id":"012i00000012AZsAAM","Name":"Package"}}},"selectBit":true}]';
        QE_addPackageAndProductController_LEX.getSavedOppList(displayString, opportunity.Id, itemList);
        QE_addPackageAndProductController_LEX.selectTransportations(opportunity.Id, pbe.Id);
        Test.stopTest();
    }
}
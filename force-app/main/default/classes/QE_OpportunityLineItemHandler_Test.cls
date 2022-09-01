@isTest(seeAllData=false)

public class QE_OpportunityLineItemHandler_Test {

    @isTest static void test_method_one() {
        
        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        Insert eventTest;
        
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Source__c = 'call Virtuoso';
        lead.email = 'testtesttest@quintevents.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');//Converted //Interested
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
        Account acct = new Account();
        acct.RecordTypeId = '012i00000015Y4x';
        acct.Name = 'Test Account';
        acct.CurrencyIsoCode = 'USD';
        insert acct;
        
        Contact conn = new Contact();
        conn.LastName = 'Test Last Name';
        conn.AccountId = acct.Id;
        conn.CurrencyIsoCode = 'USD';
        conn.Email = 'test@gmail.com';
        insert conn;
        
        acct.Primary_Contact__c = conn.Id;
        update acct;
        
        // Opportunity
        Opportunity oppTest = new Opportunity();
        oppTest.Name = 'oppName';
        oppTest.AccountId = acct.Id;//testLead.ConvertedAccountId;
        oppTest.Event__c = eventTest.Id;
        oppTest.StageName = 'Prospecting';
        oppTest.CloseDate = System.today();
        oppTest.Contact_Site__c = 'quintevents.com';
        oppTest.Shipping_Outside_US__c = 'Yes';
        oppTest.Payment_Method__c = 'Credit Card';
        oppTest.Primary_Contact__c = conn.id; 
        oppTest.GPE_Online_Order__c = false;
        oppTest.CurrencyIsoCode = 'USD';
        insert oppTest;
      
        // Products to be inserted
        List<Product2> productsToBeInserted = new List<Product2>();
        Parent_Package__c parentPakg = new Parent_Package__c(Event__c = eventTest.Id, Name='Test Parent pkg');
        insert parentPakg;
        // Package
        Product2 testPackage = new Product2(Name='BXCD11', Type__c='Package', isActive=true,Event__c = eventTest.Id,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId(), Parent_Package__c = parentPakg.Id,Reward_Points_with_Hotel__c = 10, Reward_Points_without_Hotel__c = 20, Points_Redemption__c = true);
        productsToBeInserted.add(testPackage);
        
        // Products
        Product2 testProduct = new Product2(Name='BXCD22', Type__c='Ticket', isActive=true,Event__c = eventTest.Id,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(), A_La_Carte__c = true, Available__c=true,Quantity_Per_Order_Threshold__c=1, Parent_Package__c = parentPakg.Id, Points_Redemption__c = true);
        productsToBeInserted.add(testProduct);
        
        Product2 testProduct2 = new Product2(Name='BXCD33', Type__c='Ticket', isActive=true,Event__c = eventTest.Id,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1, Parent_Package__c = parentPakg.Id, Points_Redemption__c = true);
        productsToBeInserted.add(testProduct2);
        
        Product2 testHotel = new Product2(Name='BXCD44', Type__c='Hotel', isActive=true,Event__c = eventTest.Id,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1, Parent_Package__c = parentPakg.Id, Points_Redemption__c = true);
        productsToBeInserted.add(testHotel);
        
        Product2 testProductShippingAndHandling = new Product2(Name='BXCD34', isActive=true,Event__c = eventTest.Id,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Type__c='Shipping and Handling', Quantity_Per_Order_Threshold__c=1, Parent_Package__c = parentPakg.Id, Points_Redemption__c = true);
        productsToBeInserted.add(testProductShippingAndHandling);
        
        
        insert productsToBeInserted;
        System.debug('productsToBeInserted-->'+productsToBeInserted);
        
        // Package Products
        List<Package_Products__c> packageProductsToBeInserted = new List<Package_Products__c>();
        
        Package_Products__c packageProduct = new Package_Products__c(Package__c = testPackage.Id, Products_and_Hotels__c = testPackage.Id);
        packageProductsToBeInserted.add(packageProduct);
        
        Package_Products__c packageProduct2 = new Package_Products__c(Package__c = testPackage.Id, Products_and_Hotels__c = testProduct2.Id);
        packageProductsToBeInserted.add(packageProduct2);
        
        Package_Products__c packageProductHotel = new Package_Products__c(Package__c = testPackage.Id, Products_and_Hotels__c = testHotel.Id);
        packageProductsToBeInserted.add(packageProductHotel);
        
        Insert packageProductsToBeInserted;
         
        Test.startTest();

        // Price book entries
        List<PricebookEntry> pricebookEntriesToBeAdded = new List<PricebookEntry>();
        
        PricebookEntry pricebookEntryPackage =new PricebookEntry(unitprice=0.01,Product2Id=testPackage.Id,Pricebook2Id=Test.getStandardPricebookId(),isActive=true,UseStandardPrice = false);
        pricebookEntriesToBeAdded.add(pricebookEntryPackage);
        
        PricebookEntry pricebookEntryTestProduct = new PricebookEntry(unitprice=0.01,Product2Id=testProduct.Id,Pricebook2Id=Test.getStandardPricebookId(),isActive=true,UseStandardPrice = false);
        pricebookEntriesToBeAdded.add(pricebookEntryTestProduct);
        
        PricebookEntry pricebookEntryTestProduct2 = new PricebookEntry(unitprice=0.01,Product2Id=testHotel.Id,Pricebook2Id=Test.getStandardPricebookId(),isActive=true,UseStandardPrice = false);
        pricebookEntriesToBeAdded.add(pricebookEntryTestProduct2);
        
        PricebookEntry pricebookEntryShippingAndHandling = new PricebookEntry(unitprice=0.01,Product2Id=testProductShippingAndHandling.Id,Pricebook2Id=Test.getStandardPricebookId(),isActive=true,UseStandardPrice = false,CurrencyIsoCode = 'USD');
        pricebookEntriesToBeAdded.add(pricebookEntryShippingAndHandling);
        
        Insert pricebookEntriesToBeAdded;
        System.debug('pricebookEntriesToBeAdded-->'+pricebookEntriesToBeAdded);
        // Opportunity Line Items
        
        List<opportunityLineItem> lstopplines = New List<opportunityLineItem>();
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem (Record_Type__c = 'Package', ProductType__c = 'Hotel', Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pricebookEntryPackage.Id);
        lstopplines.add(opportunityLineItem);
        
        OpportunityLineItem opportunityLineItemTestProduct = new OpportunityLineItem(Record_Type__c = 'A La Carte', Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pricebookEntryTestProduct2.Id);
        lstopplines.add(opportunityLineItemTestProduct);
        
        insert lstopplines;
        //System.debug('opportunityLineItem-->'+opportunityLineItem);
        //System.debug('opportunityLineItemTestProduct-->'+opportunityLineItemTestProduct);
        // Delete opportunity line item
        
        //delete opportunityLineItem;
        List<OpportunityLineItem> oppL = new List<OpportunityLineItem>();
        Map<Id,OpportunityLineItem> oldMapOpportunityLineItems = new Map<Id,OpportunityLineItem>();
        oppl.add(opportunityLineItem);
        oldMapOpportunityLineItems.put(opportunityLineItem.Id,opportunityLineItem);
        QE_OpportunityLineItemHandler handler = new QE_OpportunityLineItemHandler(true,2);
        handler.onAfterDelete(oppl, oldMapOpportunityLineItems);
        Test.stopTest();
    }
    @isTest static void test_method_two() {
        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        Insert eventTest;
        
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Source__c = 'call Virtuoso';
        lead.email = 'testtesttest@quintevents.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');//Converted
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
        Account acct = new Account();
        acct.RecordTypeId = '012i00000015Y4x';
        acct.Name = 'Test Account';
        acct.CurrencyIsoCode = 'USD';
        insert acct;
        
        Contact conn = new Contact();
        conn.LastName = 'Test Last Name';
        conn.AccountId = acct.Id;
        conn.CurrencyIsoCode = 'USD';
        conn.Email = 'test@gmail.com';
        insert conn;
        
        acct.Primary_Contact__c = conn.Id;
        update acct;
        
        // Opportunity
        Opportunity oppTest = new Opportunity();
        oppTest.Name = 'oppName';
        oppTest.AccountId = acct.Id;//testLead.ConvertedAccountId;
        oppTest.Event__c = eventTest.Id;
        oppTest.StageName = 'Prospecting';
        oppTest.CloseDate = System.today();
        oppTest.Contact_Site__c = 'quintevents.com';
        oppTest.Shipping_Outside_US__c = 'Yes';
        oppTest.Payment_Method__c = 'Credit Card';
        oppTest.Primary_Contact__c = conn.id; 
        oppTest.GPE_Online_Order__c = false;
        oppTest.CurrencyIsoCode = 'USD';
        insert oppTest;
      
        // Products to be inserted
        List<Product2> productsToBeInserted = new List<Product2>();
        Parent_Package__c parentPakg = new Parent_Package__c(Event__c = eventTest.Id, Name='Test Parent pkg');
        insert parentPakg;
        // Package
        Product2 testPackage = new Product2(Name='BXCD15', Type__c='Package', isActive=true,Event__c = eventTest.Id,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId(), Parent_Package__c = parentPakg.Id,Reward_Points_with_Hotel__c = 10, Reward_Points_without_Hotel__c = 20, Points_Redemption__c = true);
        productsToBeInserted.add(testPackage);
        
        // Products
        Product2 testProduct = new Product2(Name='BXCD26', Type__c='Ticket', isActive=true,Event__c = eventTest.Id,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(), A_La_Carte__c = true, Available__c=true,Quantity_Per_Order_Threshold__c=1, Parent_Package__c = parentPakg.Id, Points_Redemption__c = true);
        productsToBeInserted.add(testProduct);
        
        Product2 testProduct2 = new Product2(Name='BXCD37', Type__c='Ticket', isActive=true,Event__c = eventTest.Id,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1, Parent_Package__c = parentPakg.Id, Points_Redemption__c = true);
        productsToBeInserted.add(testProduct2);
        
        //Product2 testHotel = new Product2(Name='BXCD48', Type__c='Hotel', isActive=true,Event__c = eventTest.Id,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1, Parent_Package__c = parentPakg.Id, Points_Redemption__c = true);
        //productsToBeInserted.add(testHotel);
        
        Product2 testProductShippingAndHandling = new Product2(Name='BXCD39', isActive=true,Event__c = eventTest.Id,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Type__c='Shipping and Handling', Quantity_Per_Order_Threshold__c=1, Parent_Package__c = parentPakg.Id, Points_Redemption__c = true);
        productsToBeInserted.add(testProductShippingAndHandling);
        
        
        insert productsToBeInserted;
        
        // Package Products
        List<Package_Products__c> packageProductsToBeInserted = new List<Package_Products__c>();
        
        Package_Products__c packageProduct = new Package_Products__c(Package__c = testPackage.Id, Products_and_Hotels__c = testPackage.Id);
        packageProductsToBeInserted.add(packageProduct);
        
        Package_Products__c packageProduct2 = new Package_Products__c(Package__c = testPackage.Id, Products_and_Hotels__c = testProduct2.Id);
        packageProductsToBeInserted.add(packageProduct2);
        
        //Package_Products__c packageProductHotel = new Package_Products__c(Package__c = testPackage.Id, Products_and_Hotels__c = testHotel.Id);
        //packageProductsToBeInserted.add(packageProductHotel);
        
        Insert packageProductsToBeInserted;
        
        Test.startTest();

        // Price book entries
        List<PricebookEntry> pricebookEntriesToBeAdded = new List<PricebookEntry>();
        
        PricebookEntry pricebookEntryPackage =new PricebookEntry(unitprice=0.01,Product2Id=testPackage.Id,Pricebook2Id=Test.getStandardPricebookId(),isActive=true,UseStandardPrice = false);
        pricebookEntriesToBeAdded.add(pricebookEntryPackage);
        
        PricebookEntry pricebookEntryTestProduct = new PricebookEntry(unitprice=0.01,Product2Id=testProduct.Id,Pricebook2Id=Test.getStandardPricebookId(),isActive=true,UseStandardPrice = false);
        pricebookEntriesToBeAdded.add(pricebookEntryTestProduct);
        
       // PricebookEntry pricebookEntryTestProduct2 = new PricebookEntry(unitprice=0.01,Product2Id=testHotel.Id,Pricebook2Id=Test.getStandardPricebookId(),isActive=true,UseStandardPrice = false);
        //pricebookEntriesToBeAdded.add(pricebookEntryTestProduct2);
        
        PricebookEntry pricebookEntryShippingAndHandling = new PricebookEntry(unitprice=0.01,Product2Id=testProductShippingAndHandling.Id,Pricebook2Id=Test.getStandardPricebookId(),isActive=true,UseStandardPrice = false,CurrencyIsoCode = 'USD');
        pricebookEntriesToBeAdded.add(pricebookEntryShippingAndHandling);
        
        Insert pricebookEntriesToBeAdded;
        
        // Opportunity Line Items
       
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem (Record_Type__c = 'Package', ProductType__c = 'Hotel', Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pricebookEntryPackage.Id);
        insert opportunityLineItem;
        
        //OpportunityLineItem opportunityLineItemTestProduct = new OpportunityLineItem(Record_Type__c = 'A La Carte', Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pricebookEntryTestProduct.Id);
        //insert opportunityLineItemTestProduct;
        
        //System.debug('opportunityLineItem-->'+opportunityLineItem);
        //System.debug('opportunityLineItemTestProduct-->'+opportunityLineItemTestProduct);
        // Delete opportunity line item
        
        delete opportunityLineItem;
        List<OpportunityLineItem> oppL = new List<OpportunityLineItem>();
        Map<Id,OpportunityLineItem> oldMapOpportunityLineItems = new Map<Id,OpportunityLineItem>();
        oppl.add(opportunityLineItem);
        oldMapOpportunityLineItems.put(opportunityLineItem.Id,opportunityLineItem);
        QE_OpportunityLineItemHandler handler = new QE_OpportunityLineItemHandler(true,2);
        handler.onAfterDelete(oppl, oldMapOpportunityLineItems);
        Test.stopTest();
    }
}
@isTest
public class SportsdigitaUtilitiesTest {
     @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        TestDataFactory.createSFDCIntacctMapping();
    }
    @isTest static void testSUtilities(){
        Test.startTest();
        //create Account
        Account objAccount = TestDataFactory.createAccount();
        System.assert(true,objAccount.Name != null);
        //create Contact
        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        //create PriceBook
        PriceBook2 pricebook = TestDataFactory.createPricebook(1, 'Test PB', false)[0];
        pricebook.GPE_Event__c = true;
        Utility.processRecords(pricebook, 'insert');
        System.assertEquals(true, pricebook.GPE_Event__c);
        //create Opportunity
        Opportunity objOpportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, pricebook.id, false)[0];
        objOpportunity.StageName = 'Closed Won';
        Utility.processRecords(objOpportunity, 'insert');
        //create Product
        Product2 objProd = TestDataFactory.createProduct();
        objProd.Check_In_Date__c = Date.parse('5/2/2021');
        objProd.Check_Out_Date__c = Date.parse('5/2/2021');
         Utility.processRecords(objProd, 'update');
        PricebookEntry objPriceBookEntry = TestDataFactory.createPricebookEntry(objProd,pricebook.Id);
        Utility.processRecords(objPriceBookEntry, 'insert');
        //create Quote
        Quote quote = TestDataFactory.createQuote(1, objOpportunity.Id, objOpportunity.Pricebook2Id)[0];
        Utility.processRecords(quote, 'insert');
        quote.Digideck_Comments__c = 'tetst comment';
        Utility.processRecords(quote, 'update');
        //create QuoteLineItem
       	QuoteLineItem testQuoteLineItems = TestDataFactory.createQuoteLineItem();
        testQuoteLineItems.Record_Type__c = 'Hotel Stay';
        Utility.processRecords(testQuoteLineItems, 'update');
        //Map<String, Schema.DisplayType> objectFieldMap = new Map<String, Schema.DisplayType>();
        //SportsdigitaUtilities.getObject('Quote', 'test', objectFieldMap);
        SportsdigitaUtilities.getProductImages('objProd');
        SportsdigitaUtilities.getOpportunityPriceBookImages('Test12');
        Map<String, object> quoteLineItemMap = new Map<String, object>();
        SportsdigitaUtilities.getProductHtml(quoteLineItemMap);
        SportsdigitaUtilities.replaceAnchorTags('testhtml');
        Map<String, object> packageHotel = new Map<String, object>();
        SportsdigitaUtilities.addHotelStayDataToPackageHotel(packageHotel);
        List<Map<String, Object>> quoteData = new List<Map<String, Object>>();
        SportsdigitaUtilities.addRollupSlideData(quoteData);
        Test.stopTest();
        
    }
    
    @isTest static void testSUtilities1(){
       Test.startTest();
        //create Account
        Account objAccount = TestDataFactory.createAccount();
        System.assert(true,objAccount.Name != null);
        //create Contact
        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        //create PriceBook
        PriceBook2 pricebook = TestDataFactory.createPricebook(1, 'Test PB', false)[0];
        pricebook.GPE_Event__c = true;
        Utility.processRecords(pricebook, 'insert');
        System.assertEquals(true, pricebook.GPE_Event__c);
        //create Opportunity
        Opportunity objOpportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, pricebook.id, false)[0];
        objOpportunity.StageName = 'Closed Won';
        Utility.processRecords(objOpportunity, 'insert');
        //create Product
        Product2 objProd = TestDataFactory.createProduct();
        objProd.Check_In_Date__c = Date.parse('5/2/2021');
        objProd.Check_Out_Date__c = Date.parse('5/2/2021');
         Utility.processRecords(objProd, 'update');
        PricebookEntry objPriceBookEntry = TestDataFactory.createPricebookEntry(objProd,pricebook.Id);
        Utility.processRecords(objPriceBookEntry, 'insert');
        //create Quote
        Quote quote = TestDataFactory.createQuote(1, objOpportunity.Id, objOpportunity.Pricebook2Id)[0];
        Utility.processRecords(quote, 'insert');
        quote.Digideck_Comments__c = 'tetst comment';
        Utility.processRecords(quote, 'update');
        //create QuoteLineItem
       	QuoteLineItem testQuoteLineItems = TestDataFactory.createQuoteLineItem();
        testQuoteLineItems.Record_Type__c = 'Hotel Transportation';
        Utility.processRecords(testQuoteLineItems, 'update');
        //Map<String, Schema.DisplayType> objectFieldMap = new Map<String, Schema.DisplayType>();
        //SportsdigitaUtilities.getObject('Quote', 'test', objectFieldMap);
        SportsdigitaUtilities.getProductImages('objProd');
        SportsdigitaUtilities.getOpportunityPriceBookImages('Test12');
        Map<String, object> quoteLineItemMap = new Map<String, object>();
        SportsdigitaUtilities.getProductHtml(quoteLineItemMap);
        SportsdigitaUtilities.replaceAnchorTags('testhtml');
        Map<String, object> packageHotel = new Map<String, object>();
        SportsdigitaUtilities.addHotelStayDataToPackageHotel(packageHotel);
        List<Map<String, Object>> quoteData = new List<Map<String, Object>>();
        SportsdigitaUtilities.addRollupSlideData(quoteData);
        Test.stopTest();
        
    }
    @isTest static void testSUtilities3(){
       Test.startTest();
        //create Account
        Account objAccount = TestDataFactory.createAccount();
        System.assert(true,objAccount.Name != null);
        //create Contact
        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        //create PriceBook
        PriceBook2 pricebook = TestDataFactory.createPricebook(1, 'Test PB', false)[0];
        pricebook.GPE_Event__c = true;
        Utility.processRecords(pricebook, 'insert');
        System.assertEquals(true, pricebook.GPE_Event__c);
        //create Opportunity
        Opportunity objOpportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, pricebook.id, false)[0];
        objOpportunity.StageName = 'Closed Won';
        Utility.processRecords(objOpportunity, 'insert');
        //create Product
        Product2 objProd = TestDataFactory.createProduct();
        objProd.Check_In_Date__c = Date.parse('5/2/2021');
        objProd.Check_Out_Date__c = Date.parse('5/2/2021');
         Utility.processRecords(objProd, 'update');
        PricebookEntry objPriceBookEntry = TestDataFactory.createPricebookEntry(objProd,pricebook.Id);
        Utility.processRecords(objPriceBookEntry, 'insert');
        //create Quote
        Quote quote = TestDataFactory.createQuote(1, objOpportunity.Id, objOpportunity.Pricebook2Id)[0];
        Utility.processRecords(quote, 'insert');
        quote.Digideck_Comments__c = 'tetst comment';
        quote.Email = 'test67@test.com';
        Utility.processRecords(quote, 'update');
        //create QuoteLineItem
       	QuoteLineItem testQuoteLineItems = TestDataFactory.createQuoteLineItem();
        testQuoteLineItems.Record_Type__c = 'Package';
        Utility.processRecords(testQuoteLineItems, 'update');
      
        
        List<Map<String, Object>> quoteData = new List<Map<String, Object>>();
        SportsdigitaUtilities.addRollupSlideData(quoteData);
        Test.stopTest();
        
    }


}
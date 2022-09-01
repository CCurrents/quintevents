@isTest
public with sharing class SportsdigitaQuoteGathererTest {
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        TestDataFactory.createSFDCIntacctMapping();
    }
    @isTest static void testQuoteGatherer(){
        Opportunity opp = TestDataFactory.createOpportunity();
        List<Quote> quote = TestDataFactory.createQuote(1, opp.Id, opp.Pricebook2Id);
        Test.startTest();
        List<QuoteLineItem> testQuoteLineItems = TestDataFactory.createQuoteLineItem(4, quote[0].Id, true);
        
        //Leave the first QuoteLineItem as the default
        testQuoteLineItems[0].Record_Type__c = 'Package';
        testQuoteLineItems[1].Record_Type__c = 'Package Hotel';
        testQuoteLineItems[2].Record_Type__c = 'Hotel Transportation';
        testQuoteLineItems[3].Record_Type__c = 'A La Carte';
        Utility.processRecords(testQuoteLineItems, 'update');
        Opportunity objopp = TestDataFactory.createOpportunity();
        SportsdigitaQuoteGatherer quoteGatherer = new SportsdigitaQuoteGatherer();
        quoteGatherer.mapDigideckSlides(objopp.Id, 'test');
        quoteGatherer.getRulesetData(quote[0].Id);
        
        List<Product2> productList = new List<Product2>();
        
        Product2 packageProduct = [Select Id, DisplayinDigideck__c, DigideckContent__c From Product2 Where Id = :testQuoteLineItems[0].Product2ID];
        Product2 packageHotelProduct = [Select Id, DisplayinDigideck__c, DigideckContent__c From Product2 Where Id = :testQuoteLineItems[1].Product2ID];
        Product2 hotelStayProduct = [Select Id, DisplayinDigideck__c, DigideckContent__c, Room_Type__c From Product2 Where Id = :testQuoteLineItems[2].Product2ID];
        Product2 hotelTransportationProduct = [Select Id, DisplayinDigideck__c, DigideckContent__c From Product2 Where Id = :testQuoteLineItems[3].Product2ID];
        // Product2 parkingPassProduct = [Select Id, DisplayinDigideck__c, DigideckContent__c From Product2 Where Id = :testQuoteLineItems[4].Product2ID limit 1];
        //Product2 giftbagProduct = [Select Id, DisplayinDigideck__c, DigideckContent__c From Product2 Where Id = :testQuoteLineItems[5].Product2ID];
        
        packageProduct.DigideckContent__c = '<p>This is The Single Day Package for Thursday and here are some of its details: <ul> <li> Package Product 1 description</li><li> Package Product 2 description</li><li> Package Product 3 description</li></ul></p>';
        productList.add(packageProduct);
        
        packageHotelProduct.Check_In_Date__c = Date.parse('5/2/2021');
        packageHotelProduct.Check_Out_Date__c = Date.parse('5/5/2021');
        productList.add(packageHotelProduct);
        hotelStayProduct.DisplayinDigideck__c = true;
        hotelStayProduct.DigideckContent__c = '<p>This is the hotel</p>';
        productList.add(hotelStayProduct);
        
        //parkingPassProduct.DisplayinDigideck__c = true;
        //parkingPassProduct.DigideckContent__c = '<p>This is the Parking Pass</p>';
        //productList.add(parkingPassProduct);
        
        //giftbagProduct.DisplayinDigideck__c = false;
        //productList.add(giftbagProduct);
        
        Utility.processRecords(productList, 'update');
        Test.stopTest();
        
        //System.assertEquals(2, data.size());       
    }
}
/**
 * @File Name          : Quote_Product_Hotel_Tab_LEX_Test.cls
 * @Description        : This test class use for Quote_Product_Hotel_Tab_LEX.
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 26/04/2020
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    26/04/2020   fsuraitawala@addonblue.com    Initial Version
**/
@isTest
private class Quote_Product_Hotel_Tab_LEX_Test{
    
    /****************************************/
    @TestSetup
    static void setupTestData() {
        TestDataFactory.createTriggerSettingsEntry();
        
        //******* Pricebook *******//
        Pricebook2 testPricebook = TestDataFactory.createPricebook();
        
        //******* Parent Package *******//
        List<Parent_Package__c> lstParentPackage = TestDataFactory.createParentPackage(1, true, testPricebook.Id);
        
        //******* Product *******//
        List<Product2> lstProduct = new List<Product2>();
        Product2 objProduct = TestDataFactory.createProduct('Test Package Product', 'Package', 'Package', lstParentPackage[0].Id, testPricebook.Id);
        lstProduct.add(objProduct);
        
        Product2 objProduct1 = TestDataFactory.createProduct('Test Product', 'Product', 'Transportation', null, testPricebook.Id);
        lstProduct.add(objProduct1);
        
        Product2 objProduct2 = TestDataFactory.createProduct('Test Hotel', 'Hotel', 'Hospitality', null, testPricebook.Id);
        lstProduct.add(objProduct2);
        
        Product2 objProduct3 = TestDataFactory.createProduct('Test Hotel Stay', 'Hotel Stay', 'Stay', null, testPricebook.Id);
        lstProduct.add(objProduct3);
        
        lstProduct = Utility.processRecords(lstProduct, 'insert');
        
        //******* PricebookEntry *******//
        List<PricebookEntry> stdPriceBookEntries = new List<PricebookEntry>();
        
        PricebookEntry objStdPriceBook = TestDataFactory.createPricebookEntry(objProduct, Test.getStandardPricebookId());
        stdPriceBookEntries.add(objStdPriceBook);
        
        PricebookEntry objStdPriceBook1 = TestDataFactory.createPricebookEntry(objProduct1, Test.getStandardPricebookId());
        stdPriceBookEntries.add(objStdPriceBook1);
        
        PricebookEntry objStdPriceBook2 = TestDataFactory.createPricebookEntry(objProduct2, Test.getStandardPricebookId());
        stdPriceBookEntries.add(objStdPriceBook2);
        
        PricebookEntry objStdPriceBook3 = TestDataFactory.createPricebookEntry(objProduct3, Test.getStandardPricebookId());
        stdPriceBookEntries.add(objStdPriceBook3);
        
        PricebookEntry objPriceBook = TestDataFactory.createPricebookEntry(objProduct, testPricebook.Id);
        stdPriceBookEntries.add(objPriceBook);
        
        PricebookEntry objPriceBook1 = TestDataFactory.createPricebookEntry(objProduct1, testPricebook.Id);
        stdPriceBookEntries.add(objPriceBook1);
        
        PricebookEntry objPriceBook2 = TestDataFactory.createPricebookEntry(objProduct2, testPricebook.Id);
        stdPriceBookEntries.add(objPriceBook2);
        
        PricebookEntry objPriceBook3 = TestDataFactory.createPricebookEntry(objProduct3, testPricebook.Id);
        stdPriceBookEntries.add(objPriceBook3);
        
        stdPriceBookEntries = Utility.processRecords(stdPriceBookEntries, 'insert');
        
        //******* Products_Bundle__c *******//
        List<Products_Bundle__c> lstBundle = new List<Products_Bundle__c>();
        
        Products_Bundle__c objBundle = TestDataFactory.createProductBundle(objProduct1.Id, objProduct.Id, 'Package Product');
        lstBundle.add(objBundle);
        
        Products_Bundle__c objBundle1 = TestDataFactory.createProductBundle(objProduct3.Id, objProduct2.Id, 'Hotel Stay');
        lstBundle.add(objBundle1);
        
        Products_Bundle__c objBundle2 = TestDataFactory.createProductBundle(objProduct1.Id, objProduct2.Id, 'Hotel Transportation');
        lstBundle.add(objBundle2);
        
        lstBundle= Utility.processRecords(lstBundle, 'insert');
        
        
        // create Account
        Account acc = TestDataFactory.createAccount();
        
        // Create Contact
        Contact con = TestDataFactory.createContact(acc.Id);
        
        // create Opportunity
        Opportunity opportunity = TestDataFactory.createOpportunity(1, acc.Id, con.Id, testPricebook.Id, true)[0];
                
        Quote objquote = TestDataFactory.createQuote(1, opportunity, testPricebook.Id)[0];
        
        QuoteLineItem packageQLI = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[4].Id, 'Package', null, null, true);
        
        QuoteLineItem HotelQLI = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[6].Id, 'Package Hotel', packageQLI.Id, null, true);
        
        List<QuoteLineItem> lstLineItem = new List<QuoteLineItem>();
        QuoteLineItem HotelTransportationQLI = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[5].Id, 'Hotel Transportation', packageQLI.Id, HotelQLI.Id, false);
        lstLineItem.add(HotelTransportationQLI);
        
        QuoteLineItem HotelStayQLI = TestDataFactory.createQuoteLineItem(objquote.Id, stdPriceBookEntries[7].Id, 'Hotel Stay', packageQLI.Id, HotelQLI.Id, false);
        lstLineItem.add(HotelStayQLI);
        
        lstLineItem = Utility.processRecords(lstLineItem, 'insert');
        
        TestDataFactory.createRoomingList(2, objquote.Id, lstLineItem[1], true);
    }
    
    /****************************************/
    @isTest
    static void testRunOne() {
        
        Test.startTest();
        Quote currentQuote = [Select Id, Pricebook2Id, (Select Id From QuoteLineItems Where Record_Type__c = 'Package') From Quote Limit 1];
        
        Quote_Product_Hotel_Tab_LEX.getRoomTypeOptions();
        List<PricebookEntry> HotelPBE = Quote_Product_Hotel_Tab_LEX.getProductRecords(currentQuote.Id);
        Quote_Product_Hotel_Tab_LEX.getRelatedHotelStay(currentQuote.Id, HotelPBE[0].Product2Id);
        
        Quote_Product_Hotel_Tab_LEX.getReletedHotelLineItems(currentQuote.QuoteLineItems[0].Id);
        
        List<SW_Utility_LEX.HotelBundleClass> lstHotelBundle = Quote_Product_Hotel_Tab_LEX.getRelatedLineItems(currentQuote.Id, currentQuote.QuoteLineItems[0].Id);
        
        Quote_Product_Hotel_Tab_LEX.saveLineItemRecords(currentQuote.Id, lstHotelBundle, true, currentQuote.QuoteLineItems[0].Id);
        
        Quote_Product_Hotel_Tab_LEX.getRelatedHotelsRecords(currentQuote.Id,currentQuote.QuoteLineItems[0].Id);
        
        Quote_Product_Hotel_Tab_LEX.getRelatedHotelsRecords(currentQuote.Id, currentQuote.QuoteLineItems[0].Id);
        Quote_Product_Hotel_Tab_LEX.getRelatedHotelsRecords(currentQuote.Id, null);
        
        List<SW_Utility_LEX.HotelBundleClass> newLSTHotelBundle = lstHotelBundle;
        newLSTHotelBundle[0].Hotel.Id = null;
        newLSTHotelBundle[0].HotelStay.Id = null;
        newLSTHotelBundle[0].HotelTransportations[0].Id = null;
        newLSTHotelBundle[0].RoomingList[0].Id = null;
        newLSTHotelBundle[0].RoomingList[1].Id = null;
        
        
        Quote_Product_Hotel_Tab_LEX.saveLineItemRecords(currentQuote.Id, newLSTHotelBundle, true, currentQuote.QuoteLineItems[0].Id);
        
        Test.stopTest();
    }
}
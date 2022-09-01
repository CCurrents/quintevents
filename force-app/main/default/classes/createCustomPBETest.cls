@isTest
private class createCustomPBETest {
    @testSetup 
    static void setup() {
        Pricebook2 testPricebook = new Pricebook2(Name = 'Test Pricebook', IsActive = true, Chargeable_Currencies__c = 'USD');
        insert testPricebook;
        
        List<Product2> lstProduct = new List<Product2>();
        
        Product2 objProduct =new product2();
        objProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId();
        objProduct.Name = 'Test Product';
        objProduct.Primary_Price_Book__c = testPricebook.Id;
        objProduct.Type__c = 'Transportation';
        objProduct.CurrencyIsoCode = 'USD';
        objProduct.Price__c = 100.00;
        objProduct.A_La_Carte__c = true;
        objProduct.isActive = true;
        lstProduct.add(objProduct);
        
        Product2 objProduct1 =new product2();
        objProduct1.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId();
        objProduct1.Name = 'Test Product 1';
        objProduct1.Primary_Price_Book__c = testPricebook.Id;
        objProduct1.Type__c = 'Transportation';
        objProduct1.CurrencyIsoCode = 'USD';
        objProduct1.Price__c = 100.00;
        objProduct1.A_La_Carte__c = true;
        objProduct1.isActive = true;
        lstProduct.add(objProduct1);
        
        Product2 objProduct2 =new product2();
        objProduct2.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotel').getRecordTypeId();
        objProduct2.Name = 'Test Hotel';
        objProduct2.Primary_Price_Book__c = testPricebook.Id;
        objProduct2.Type__c = 'Hospitality';
        objProduct2.CurrencyIsoCode = 'USD';
        objProduct2.Price__c = 100.00;
        objProduct2.A_La_Carte__c = true;
        objProduct2.isActive = true;
        lstProduct.add(objProduct2);
        
        Product2 objProduct3 =new product2();
        objProduct3.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotel Stay').getRecordTypeId();
        objProduct3.Name = 'Test Hotel Stay';
        objProduct3.Primary_Price_Book__c = testPricebook.Id;
        objProduct3.Type__c = 'Stay';
        objProduct3.CurrencyIsoCode = 'USD';
        objProduct3.Price__c = 100.00;
        objProduct3.A_La_Carte__c = true;
        objProduct3.isActive = true;
        lstProduct.add(objProduct3);
        
        insert lstProduct;
        
        List<PricebookEntry> stdPriceBookEntries = new List<PricebookEntry>();
        PricebookEntry objStdPriceBook = new PricebookEntry(unitprice = objProduct.Price__c, 
                                                         Product2Id = objProduct.Id, 
                                                         Pricebook2Id = Test.getStandardPricebookId(), 
                                                         isActive=true, 
                                                         UseStandardPrice = false,
                                                         CurrencyIsoCode = 'USD');
        stdPriceBookEntries.add(objStdPriceBook);
        
        PricebookEntry objStdPriceBook1 = new PricebookEntry(unitprice = objProduct1.Price__c,
                                                         Product2Id = objProduct1.Id,
                                                         Pricebook2Id = Test.getStandardPricebookId(),
                                                         isActive=true,
                                                         UseStandardPrice = false,
                                                         CurrencyIsoCode = 'USD');
        stdPriceBookEntries.add(objStdPriceBook1);
        
        PricebookEntry objStdPriceBook2 = new PricebookEntry(unitprice = objProduct2.Price__c,
                                                         Product2Id = objProduct2.Id,
                                                         Pricebook2Id = Test.getStandardPricebookId(),
                                                         isActive=true,
                                                         UseStandardPrice = false,
                                                         CurrencyIsoCode = 'USD');
        stdPriceBookEntries.add(objStdPriceBook2);
        
        PricebookEntry objStdPriceBook3 = new PricebookEntry(unitprice = objProduct3.Price__c,
                                                         Product2Id = objProduct3.Id,
                                                         Pricebook2Id = Test.getStandardPricebookId(),
                                                         isActive=true,
                                                         UseStandardPrice = false,
                                                         CurrencyIsoCode = 'USD');
        stdPriceBookEntries.add(objStdPriceBook3);
        
        PricebookEntry objPriceBook = new PricebookEntry(unitprice = objProduct.Price__c, 
                                                         Product2Id = objProduct.Id, 
                                                         Pricebook2Id = testPricebook.Id, 
                                                         isActive=true, 
                                                         UseStandardPrice = false,
                                                         CurrencyIsoCode = 'USD');
        stdPriceBookEntries.add(objPriceBook);
        
        PricebookEntry objPriceBook1 = new PricebookEntry(unitprice = objProduct1.Price__c, 
                                                         Product2Id = objProduct1.Id, 
                                                         Pricebook2Id = testPricebook.Id, 
                                                         isActive=true, 
                                                         UseStandardPrice = false,
                                                         CurrencyIsoCode = 'USD');
        stdPriceBookEntries.add(objPriceBook1);
        
        PricebookEntry objPriceBook2 = new PricebookEntry(unitprice = objProduct2.Price__c, 
                                                         Product2Id = objProduct2.Id, 
                                                         Pricebook2Id = testPricebook.Id, 
                                                         isActive=true, 
                                                         UseStandardPrice = false,
                                                         CurrencyIsoCode = 'USD');
        stdPriceBookEntries.add(objPriceBook2);
        
        PricebookEntry objPriceBook3 = new PricebookEntry(unitprice = objProduct3.Price__c, 
                                                         Product2Id = objProduct3.Id, 
                                                         Pricebook2Id = testPricebook.Id, 
                                                         isActive = true, 
                                                         UseStandardPrice = false,
                                                         CurrencyIsoCode = 'USD');
        stdPriceBookEntries.add(objPriceBook3);
        insert stdPriceBookEntries;
    }
    static testmethod void test() {        
        Test.startTest();
        createCustomPBE CustomPBE = new createCustomPBE();
        Id batchId = Database.executeBatch(CustomPBE);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(8, [select count() from Price_Book_Entry_Custom__c]);
    }
    
}
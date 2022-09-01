@isTest
private class createPricebookEnrtiesTest {
    @testSetup 
    static void setup() {
        TestDataFactory.createTriggerSettingsEntry();
        
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
    }
    
    static testmethod void test() {        
        Test.startTest();
        createPricebookEnrties objBatch = new createPricebookEnrties();
        Id batchId = Database.executeBatch(objBatch);
        Test.stopTest();
    }
}
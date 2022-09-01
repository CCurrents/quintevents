@isTest
private class updatePrimaryPricebookInProductTest {
    @testSetup 
    static void setup() {
        QE360_Event__c objEvent = new QE360_Event__c();
        objEvent.Name = 'Test Event';
        objEvent.Active__c = true;
        objEvent.Start_Date__c = System.today();
        objEvent.End_Date__c = System.today() + 30;
        insert objEvent;
        
        Pricebook2 testPricebook = new Pricebook2(Name = 'Test Pricebook', IsActive = true, Chargeable_Currencies__c = 'USD', Legacy_Id__c = objEvent.Id);
        insert testPricebook;
        
        List<Product2> lstProduct = new List<Product2>();
        
        Product2 objProduct =new product2();
        objProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId();
        objProduct.Name = 'Test Product';
        objProduct.Event__c = objEvent.Id;
        objProduct.Type__c = 'Transportation';
        objProduct.CurrencyIsoCode = 'USD';
        objProduct.Price__c = 100.00;
        objProduct.A_La_Carte__c = true;
        objProduct.isActive = true;
        lstProduct.add(objProduct);
        
        Product2 objProduct1 =new product2();
        objProduct1.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId();
        objProduct1.Name = 'Test Product';
        objProduct1.Event__c = objEvent.Id;
        objProduct1.Type__c = 'Transportation';
        objProduct1.CurrencyIsoCode = 'USD';
        objProduct1.Price__c = 100.00;
        objProduct1.A_La_Carte__c = true;
        objProduct1.isActive = true;
        lstProduct.add(objProduct1);
        
        Product2 objProduct2 =new product2();
        objProduct2.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId();
        objProduct2.Name = 'Test Hotel';
        objProduct2.Event__c = objEvent.Id;
        objProduct2.Type__c = 'Hospitality';
        objProduct2.CurrencyIsoCode = 'USD';
        objProduct2.Price__c = 100.00;
        objProduct2.A_La_Carte__c = true;
        objProduct2.isActive = true;
        lstProduct.add(objProduct2);
        
        insert lstProduct;
    }
    static testmethod void test() {        
        Test.startTest();
        updatePrimaryPricebookInProduct objBatch = new updatePrimaryPricebookInProduct();
        Id batchId = Database.executeBatch(objBatch);
        Test.stopTest();
    }
}
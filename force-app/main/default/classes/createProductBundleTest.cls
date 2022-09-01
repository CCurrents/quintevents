@isTest
private class createProductBundleTest {
    @testSetup 
    static void setup() {
        Pricebook2 testPricebook = new Pricebook2(Name = 'Test Pricebook', IsActive = true, Chargeable_Currencies__c = 'USD');
        insert testPricebook;
        
        Parent_Package__c objParentPackage = new Parent_Package__c();
        objParentPackage.Pricebook2__c = testPricebook.Id;
        insert objParentPackage;
        
        List<Product2> lstProduct = new List<Product2>();
        
        Product2 objProduct =new product2();
        objProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId();
        objProduct.Name = 'Test Package Product';
        objProduct.Primary_Price_Book__c = testPricebook.Id;
        objProduct.Type__c = 'Package';
        objProduct.CurrencyIsoCode = 'USD';
        objProduct.Price__c = 120.00;
        objProduct.A_La_Carte__c = true;
        objProduct.isActive = true;
        objProduct.Parent_Package__c = objParentPackage.Id;
        lstProduct.add(objProduct);
        
        Product2 objProduct1 =new product2();
        objProduct1.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId();
        objProduct1.Name = 'Test Product';
        objProduct1.Primary_Price_Book__c = testPricebook.Id;
        objProduct1.Type__c = 'Transportation';
        objProduct1.CurrencyIsoCode = 'USD';
        objProduct1.Price__c = 100.00;
        objProduct1.A_La_Carte__c = true;
        objProduct1.isActive = true;
        lstProduct.add(objProduct1);
        
        Product2 objProduct2 =new product2();
        objProduct2.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId();
        objProduct2.Name = 'Test Hotel';
        objProduct2.Primary_Price_Book__c = testPricebook.Id;
        objProduct2.Type__c = 'Hospitality';
        objProduct2.CurrencyIsoCode = 'USD';
        objProduct2.Price__c = 100.00;
        objProduct2.A_La_Carte__c = true;
        objProduct2.isActive = true;
        lstProduct.add(objProduct2);
        
        insert lstProduct;
        
        List<Package_Products__c> lstPP = new List<Package_Products__c>();
        Package_Products__c objPP = new Package_Products__c();
        objPP.Package__c = lstProduct[0].Id;
        objPP.Products_and_Hotels__c = lstProduct[1].Id;
        lstPP.add(objPP);
        
        Package_Products__c objPP1 = new Package_Products__c();
        objPP1.Package__c = lstProduct[0].Id;
        objPP1.Products_and_Hotels__c = lstProduct[2].Id;
        lstPP.add(objPP1);
        
        insert lstPP;
    }
    static testmethod void test() {        
        Test.startTest();
        createProductBundle objBatch = new createProductBundle();
        Id batchId = Database.executeBatch(objBatch);
        Test.stopTest();
    }
}
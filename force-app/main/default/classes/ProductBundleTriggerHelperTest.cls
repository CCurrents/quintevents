@isTest public class ProductBundleTriggerHelperTest {
    /****************************************/
    @isTest
    static void testRun() {
        TestDataFactory.createTriggerSettingsEntry();
        
        //******* Pricebook *******//
        Pricebook2 testPricebook = TestDataFactory.createPricebook();
        
        //******* Parent Package *******//
        List<Parent_Package__c> lstParentPackage = TestDataFactory.createParentPackage(1, true, testPricebook.Id);
        
        //******* PricebookEntry *******//
        List<Product2> lstProduct = new List<Product2>();
        Product2 objProduct = TestDataFactory.createProduct('Test Package Product', 'Package', 'Package', lstParentPackage[0].Id, testPricebook.Id);
        lstProduct.add(objProduct);
        
        Product2 objProduct1 = TestDataFactory.createProduct('Test Product', 'Product', 'Transportation', null, testPricebook.Id);
        objProduct.Available__c = true;
        objProduct.Quantity_Per_Order_Threshold__c = 12;
        lstProduct.add(objProduct1);
        
        Product2 objProduct2 = TestDataFactory.createProduct('Test Hotel', 'Product', 'Hospitality', null, testPricebook.Id);
        objProduct.Available__c = true;
        objProduct.Quantity_Per_Order_Threshold__c = 12;
        lstProduct.add(objProduct2);
        
        Product2 objProduct3 = TestDataFactory.createProduct('Test Hotel Stay', 'Product', 'Stay', null, testPricebook.Id);
        objProduct.Available__c = true;
        objProduct.Quantity_Per_Order_Threshold__c = 12;
        lstProduct.add(objProduct3);
        
        lstProduct = Utility.processRecords(lstProduct, 'insert');
        System.debug(lstProduct);
        
        //******* Products_Bundle__c *******//
        List<Products_Bundle__c> lstBundle = new List<Products_Bundle__c>();
        
        Products_Bundle__c objBundle = TestDataFactory.createProductBundle(objProduct1.Id, objProduct.Id, 'Package Product');
        lstBundle.add(objBundle);
        
        Products_Bundle__c objBundle1 = TestDataFactory.createProductBundle(objProduct2.Id, objProduct.Id, 'Package Product');
        lstBundle.add(objBundle1);
        
        lstBundle= Utility.processRecords(lstBundle, 'insert');
        
        Products_Bundle__c objBundle2 = TestDataFactory.createProductBundle(objProduct3.Id, objProduct.Id, 'Package Product');
        insert objBundle2;
        
        System.debug('@@@lstBundle: '+lstBundle);
        
        Utility.processRecords(lstBundle, 'delete');
    }
}
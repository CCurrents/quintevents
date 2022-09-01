/**
 * @File Name          : RL_PriceBook_Products_LEX_Test.cls
 * @Description        : This test class use for RL_PriceBook_Products_LEX.
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/8/2020, 4:03:14 AM
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    26/04/2020   fsuraitawala@addonblue.com     Initial Version
**/
@isTest
private class RL_PriceBook_Products_LEX_Test {
    
    /****************************************/
    @TestSetup
    static void setupTestData() {
        TestDataFactory.createTriggerSettingsEntry();
        
        //******* Pricebook *******//
        List<PriceBook2> testPricebook = TestDataFactory.createPricebook(2);
        
        //******* Parent Package *******//
        List<Parent_Package__c> lstParentPackage = TestDataFactory.createParentPackage(1, true, testPricebook[0].Id);
        
        //******* Product *******//
        List<Product2> lstProduct = new List<Product2>();
        Product2 objProduct = TestDataFactory.createProduct('Test Package Product', 'Package', 'Package', lstParentPackage[0].Id, testPricebook[0].Id);
        lstProduct.add(objProduct);
        
        Product2 objProduct1 = TestDataFactory.createProduct('Test Product', 'Product', 'Transportation', null, testPricebook[0].Id);
        lstProduct.add(objProduct1);
        
        Product2 objProduct2 = TestDataFactory.createProduct('Test Hotel', 'Hotel', 'Hospitality', null, testPricebook[0].Id);
        lstProduct.add(objProduct2);
        
        Product2 objProduct3 = TestDataFactory.createProduct('Test Product 1', 'Product', 'Transportation', null, testPricebook[1].Id);
        lstProduct.add(objProduct3);
        
        Product2 objProduct4 = TestDataFactory.createProduct('Test Hotel 1', 'Hotel', 'Hospitality', null, testPricebook[1].Id);
        lstProduct.add(objProduct4);
        
        lstProduct = Utility.processRecords(lstProduct, 'insert');
    }
    
    /****************************************/
    @isTest
    static void testRunOne() {
        List<Pricebook2> lstPriceBook = [SELECT Id, Name, IsActive FROM Pricebook2 Where IsActive = true];
        
        Test.startTest();
        System.assertEquals(lstPriceBook.size(), 2);
        
        RL_PriceBook_Products_LEX.getActivePriceBooks(lstPriceBook[0].Id);
        RL_PriceBook_Products_LEX.getListOfRecordType();
        RL_PriceBook_Products_LEX.getPricebookEntry(lstPriceBook[0].Id);
        List<SW_Utility_LEX.productListWrapper> SelectedProduct = RL_PriceBook_Products_LEX.fetchProductWrapper(lstPriceBook[1].Id, lstPriceBook[0].Id);
        
        for(SW_Utility_LEX.productListWrapper obj: SelectedProduct){
            obj.isChecked = true;
        }
        
        RL_PriceBook_Products_LEX.SaveProductRecords(lstPriceBook[0].Id, SelectedProduct);
        SW_Utility_LEX.productListWrapper objList = new SW_Utility_LEX.productListWrapper();
        
        try {
            List<SW_Utility_LEX.productListWrapper> SelectedProduct1 = RL_PriceBook_Products_LEX.fetchProductWrapper(lstPriceBook[0].Id, lstPriceBook[1].Id);
            
            for(SW_Utility_LEX.productListWrapper obj: SelectedProduct1){
                obj.isChecked = true;
            }
            RL_PriceBook_Products_LEX.SaveProductRecords(lstPriceBook[0].Id, SelectedProduct1);
        } catch(Exception ex){
            system.debug(ex.getmessage());
        }
        Test.stopTest();
    }
}
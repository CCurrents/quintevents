@isTest
public class ProductCloneCtlrTest {
	@isTest static void testMethod_one() {
        TestDataFactory.createTriggerSettingsEntry();
        List<Product2> lstProducts = TestDataFactory.createProduct(1);
        List<PriceBookEntry> lstPriceBookEntry = TestDataFactory.createPriceBookEntry(1);
        Package_Products__c ticketOnePackageProduct = TestDataFactory.createPackageProduct(lstProducts[0].Id)[0];        
        Inventory_Transaction__c objInvTrns = TestDataFactory.createInventoryTransaction(lstProducts[0].Id)[0];        
        Products_Bundle__c objProductBundle = TestDataFactory.createProductBundle(lstProducts[0].Id)[0];
		ProductCloneCtlr.fetchBaseUrl();
        ProductCloneCtlr.fetchPackageValues(lstProducts[0].Id);
        System.assertEquals(1, lstProducts.size());
    }
}
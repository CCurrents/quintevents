@isTest public class SlackLowPackageInventoryTest {
	@TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    @isTest static void testRun1(){
        List<Id> lstIds = new List<Id>();
        Product2 objProduct = TestDataFactory.createProduct();
        lstIds.add(objProduct.Id);
        SlackLowPackageInventory.invocableMethod(lstIds);
    }
}
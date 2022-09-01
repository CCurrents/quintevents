@isTest public class SlackEventChannelPakageInventoryTest {
	@TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    @isTest static void testRun1(){
        List<Id> lstIds = new List<Id>();
        Product2 objProduct = TestDataFactory.createProduct();
        lstIds.add(objProduct.Id);
        System.enqueueJob(new SlackEventChannelPackageInventory(lstIds));
    }
}
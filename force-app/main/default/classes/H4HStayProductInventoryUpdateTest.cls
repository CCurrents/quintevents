@isTest public class H4HStayProductInventoryUpdateTest {
	@TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    @isTest static void testRun1(){
		Product2 objRoomProduct = TestDataFactory.createProduct();
        H4HStayProductInventoryUpdate batch = new H4HStayProductInventoryUpdate(true);
        Database.executeBatch(batch);
        System.assertNotEquals(objRoomProduct.Id, null);
    }
    @isTest static void testRun2(){
		Product2 objRoomProduct = TestDataFactory.createProduct();
        H4HStayProductInventoryUpdate batch = new H4HStayProductInventoryUpdate();
        Database.executeBatch(batch);
        System.assertNotEquals(objRoomProduct.Id, null);
    }
}
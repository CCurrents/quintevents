@isTest public class RenameSlackPricecBookChannelTest {
	@TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    @isTest static void testRun1(){
        List<Id> lstIds = new List<Id>();
        Pricebook2 objPricebook = TestDataFactory.createPricebook();
        lstIds.add(objPricebook.Id);
        System.enqueueJob(new RenameSlackPriceBookChannel(lstIds));
    }
}
@isTest public class SlackPriceBookChannelMemberShipTest {
	@TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        TestDataFactory.createPricebook();
    }
    @isTest static void testRun1(){
        List<Id> lstIds = new List<Id>();
        User objUser = TestDataFactory.createUser();
        lstIds.add(objUser.Id);
        System.enqueueJob(new SlackPriceBookChannelMemberShip(lstIds));
    }
    @isTest static void testRun2(){
        List<Id> lstIds = new List<Id>();
        User objUser = TestDataFactory.createUser();
        objUser.IsActive = false;
        List<User> lstUser = Utility.processRecords(objUser, 'update');
        for(User usr : lstUser){
            lstIds.add(usr.Id);
        }
        System.enqueueJob(new SlackPriceBookChannelMemberShip(lstIds));
    }
}
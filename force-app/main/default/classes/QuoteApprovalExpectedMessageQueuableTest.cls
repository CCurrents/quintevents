@isTest public class QuoteApprovalExpectedMessageQueuableTest {
	@TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    @isTest static void testRun1(){
        List<Id> lstIds = new List<Id>();
        //TestDataFactory.createUser();
        Quote objQuote = TestDataFactory.createQuote();
        lstIds.add(objQuote.Id);
        System.enqueueJob(new QuoteApprovalExpectedMessageQueuable(lstIds));
    }
}
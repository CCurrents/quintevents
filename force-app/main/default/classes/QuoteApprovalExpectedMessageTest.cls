@isTest public class QuoteApprovalExpectedMessageTest {
	@TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    @isTest static void testRun1(){
        Quote objQuote = TestDataFactory.createQuote();
        QuoteApprovalExpectedMessage.postSlackUserMessage(new List<Id>{objQuote.Id});
    }
}
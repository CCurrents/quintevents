@isTest
public class QE_StripeWebhookListenerTests {
	
	private static testmethod void testListener() {
		QE_TestStripe.StripeDataSetup();
		
		QE_StripeWebhookListener listener = new QE_StripeWebhookListener();

		System.RestRequest req = new System.RestRequest();
		req.requestBody = Blob.valueOf(QE_StripeEventTests.testData_ChargeSucceeded);
		RestContext.request = req;
		RestContext.response = new System.RestResponse();
		
		Test.startTest();
		try {
			listener.handlePost();
		} catch (QE_StripeEvent.UnknownWebhookException e) {}
		Test.stopTest();
	}
	
	private static testmethod void testHandlerCoverage() {
		System.RestRequest req = new System.RestRequest();
		req.requestBody = Blob.valueOf(QE_StripeEventTests.testData_ChargeSucceeded);
		RestContext.request = req;
		RestContext.response = new System.RestResponse();

		QE_StripeWebhookListener listener = new QE_StripeWebhookListener();

		try {
			listener.handle_ChargeEvent(new QE_StripeCharge());
		} catch (QE_StripeEvent.UnknownWebhookException e) {}	
		
	}
	
}
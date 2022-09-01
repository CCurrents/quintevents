@isTest
public class QE_StripeCardTests {
	
	public static String testData_getCard {
		get {
			return '{'+
				'  "id": "card_103efE2BONonlYaUmcDL4YY9",'+
				'  "object": "card",'+
				'  "last4": "4242",'+
				'  "type": "Visa",'+
				'  "exp_month": 3,'+
				'  "exp_year": 2016,'+
				'  "fingerprint": "jTU2IfFVCVRg8CCh",'+
				'  "customer": "cus_2uDWpGJXnH0pyT",'+
				'  "country": "US",'+
				'  "name": null,'+
				'  "address_line1": null,'+
				'  "address_line2": null,'+
				'  "address_city": null,'+
				'  "address_state": null,'+
				'  "address_zip": null,'+
				'  "address_country": null,'+
				'  "cvc_check": null,'+
				'  "address_line1_check": null,'+
				'  "address_zip_check": null'+
				'}';
		}
	}
    
    @isTest
	public static void createStripeCardTest () {
    	Test.startTest();
        Map<String, String> testProperties = new Map<String, String>();
        testProperties.put('card[number]', '4242424242424242');
        testProperties.put('card[exp_year]', '2025');
        testProperties.put('card[exp_month]', '12');
        testProperties.put('card[cvc]', '123');
        testProperties.put('card[name]', 'Test Name');
		QE_StripeCard.create('cus_0000000000000', testProperties);
		Test.stopTest();
    }

}
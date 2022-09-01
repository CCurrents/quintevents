@IsTest
public class GPE_ApexToJsonClass_Test {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{\"gpesale\":'+
		'{'+
		'	\"city\":\"suzuka city\",\"country\":\"Japan\",\"currencyCharged\":\"USD\",	\"email\":\"princeharry@hotmail.com\",	\"fees\":		{		\"order_processing_fee\":26.0,\"shipping_fee\":27.0'+
		'		},	\"firstName\":\"KENJI\",	\"gpeEventName\":\"F1 Paddock Club, Formula One Paddock Clubâ„¢, Japanese Grand Prix\",	\"gptBookingId\":\"\",	\"lastName\":\"TANAKA\",	\"lineItems\":[		{		\"Name\":\"Aston Martin Red Bull Racing Paddock Club - 1 Day\",'+
		'		\"articleid\":null,		\"price\":\"1,292.00\",		\"quantity\":1		}	],	\"phone\":\"+819086700184\",	\"state\":\"\",	\"street\":\"5choume20-15 sanjo\", \"total\":\"54\", \"zip\":\"513-0806\"}}';
		GPE_ApexToJsonClass r = GPE_ApexToJsonClass.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		GPE_ApexToJsonClass.LineItems objLineItems = new GPE_ApexToJsonClass.LineItems(System.JSON.createParser(json));
		System.assert(objLineItems != null);
		System.assert(objLineItems.Name == null);
		System.assert(objLineItems.articleid == null);
		System.assert(objLineItems.price == null);
		System.assert(objLineItems.quantity == null);
        System.assert(objLineItems.GPTEventId == null);
		System.assert(objLineItems.packageId == null);
		System.assert(objLineItems.packagePrice == null);
		System.assert(objLineItems.packageQty == null);
        System.assert(objLineItems.hotelId == null);
		System.assert(objLineItems.hotelPrice == null);
		System.assert(objLineItems.hotelQty == null);
		System.assert(objLineItems.includeTransportation == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		GPE_ApexToJsonClass objGPE_ApexToJsonClass = new GPE_ApexToJsonClass(System.JSON.createParser(json));
		System.assert(objGPE_ApexToJsonClass != null);
		System.assert(objGPE_ApexToJsonClass.gpesale == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		GPE_ApexToJsonClass.Fees objFees = new GPE_ApexToJsonClass.Fees(System.JSON.createParser(json));
		System.assert(objFees != null);
		System.assert(objFees.order_processing_fee == null);
		System.assert(objFees.shipping_fee == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		GPE_ApexToJsonClass.Gpesale objGpesale = new GPE_ApexToJsonClass.Gpesale(System.JSON.createParser(json));
		System.assert(objGpesale != null);
		System.assert(objGpesale.city == null);
		System.assert(objGpesale.country == null);
		System.assert(objGpesale.currencyCharged == null);
		System.assert(objGpesale.email == null);
		System.assert(objGpesale.fees == null);
		System.assert(objGpesale.firstName == null);
		System.assert(objGpesale.gpeEventName == null);
		System.assert(objGpesale.gptBookingId == null);
		System.assert(objGpesale.lastName == null);
		System.assert(objGpesale.lineItems == null);
		System.assert(objGpesale.phone == null);
		System.assert(objGpesale.state == null);
		System.assert(objGpesale.street == null);
		System.assert(objGpesale.total == null);
		System.assert(objGpesale.zip == null);
        System.assert(objGpesale.GPE_Order_Id == null);
		System.assert(objGpesale.eventId == null);
		System.assert(objGpesale.discount == null);
		System.assert(objGpesale.paymentTerms == null);
		System.assert(objGpesale.googleAnalyticsId == null);
		System.assert(objGpesale.googleAnalyticsSiteId == null);
		System.assert(objGpesale.promoterId == null);
		System.assert(objGpesale.resellerId == null);
		System.assert(objGpesale.site == null);
        System.assert(objGpesale.totalAfterDiscount == null);
		System.assert(objGpesale.totalChargedInCurrency == null);
		System.assert(objGpesale.visitorCountry == null);
        
        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		GPE_ApexToJsonClass.sale objsale = new GPE_ApexToJsonClass.sale(System.JSON.createParser(json));
		System.assert(objsale != null);
		System.assert(objsale.city == null);
		System.assert(objsale.country == null);
		System.assert(objsale.currencyCharged == null);
		System.assert(objsale.email == null);
		System.assert(objsale.fees == null);
		System.assert(objsale.firstName == null);
		System.assert(objsale.gpeEventName == null);
		System.assert(objsale.gptBookingId == null);
		System.assert(objsale.lastName == null);
		System.assert(objsale.lineItems == null);
		System.assert(objsale.phone == null);
		System.assert(objsale.state == null);
		System.assert(objsale.street == null);
		System.assert(objsale.total == null);
		System.assert(objsale.zip == null);
        System.assert(objsale.GPE_Order_Id == null);
		System.assert(objsale.eventId == null);
		System.assert(objsale.discount == null);
		System.assert(objsale.paymentTerms == null);
		System.assert(objsale.googleAnalyticsId == null);
		System.assert(objsale.googleAnalyticsSiteId == null);
		System.assert(objsale.promoterId == null);
		System.assert(objsale.resellerId == null);
		System.assert(objsale.site == null);
		System.assert(objsale.totalAfterDiscount == null);
		System.assert(objsale.totalChargedInCurrency == null);
		System.assert(objsale.visitorCountry == null);
	}
}
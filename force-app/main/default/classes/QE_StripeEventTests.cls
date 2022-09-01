@isTest
public class QE_StripeEventTests {
    
	private static testMethod void testParse_ChargeSucceeded() {
		String json = testData_ChargeSucceeded;
		QE_StripeEvent event = QE_StripeEvent.parse(json);
		System.assert(event != null);
		System.assert(event.stripeData.QE_StripeCharge != null);
		System.debug(System.LoggingLevel.INFO, '\n**** Charge: '+event.stripeData.QE_StripeCharge); 
	}
    
    private static testMethod void testParse_ChargeFailed() {
		String json = testData_ChargeFailed;
		QE_StripeEvent event = QE_StripeEvent.parse(json);
		System.assert(event != null);
		System.assert(event.stripeData.QE_StripeCharge != null);
		System.debug(System.LoggingLevel.INFO, '\n**** Charge: '+event.stripeData.QE_StripeCharge); 
	}
	
	private static testMethod void testParse_ChargeRefunded() {
		String json = testData_ChargeRefunded;
		QE_StripeEvent event = QE_StripeEvent.parse(json);
		System.assert(event != null);
		System.assert(event.stripeData.QE_StripeCharge != null);
		System.debug(System.LoggingLevel.INFO, '\n**** Charge: '+event.stripeData.QE_StripeCharge); 
	}

	public static String testData_ChargeSucceeded {
		get {
			return '{'+
				'  "object": "event",'+
				'  "type": "charge.succeeded",'+
				'  "created": 1342422128,'+
				'  "pending_webhooks": 1,'+
				'  "data": {'+
				'    "object": {'+
				'      "id": "ch_sHBUQHlTQzx5S8",'+
				'      "amount": 2000,'+
				'      "object": "charge",'+
				'      "fee_details": ['+
				'        {'+
				'          "type": "stripe_fee",'+
				'          "currency": "usd",'+
				'          "description": "Stripe processing fees",'+
				'          "amount": 88,'+
				'          "application": null'+
				'        }'+
				'      ],'+
				'      "created": 1342422128,'+
				'      "fee": 88,'+
				'      "livemode": false,'+
				'      "paid": true,'+
				'      "currency": "usd",'+
				'      "card": {'+
				'        "fingerprint": "pmVir47Ti9dNLS50",'+
				'        "cvc_check": "pass",'+
				'        "type": "Visa",'+
				'        "object": "card",'+
				'        "last4": "4242",'+
				'        "country": "US",'+
				'        "exp_month": 12,'+
				'        "exp_year": 2012'+
				'      },'+
				'      "disputed": false,'+
				'      "customer": "cus_00000000000000",'+
				'      "description": "sample description",'+
				'      "refunded": true'+
				'    }'+
				'  },'+
				'  "livemode": false,'+
				'  "id": "evt_7RJPM7Dh5rFA2R"'+
				'}';
		}
	}

	public static String testData_ChargeRefunded {
		get {
			return '{'+
				'  "pending_webhooks": 1,'+
				'  "type": "charge.refunded",'+
				'  "livemode": false,'+
				'  "object": "event",'+
				'  "created": 1353304503,'+
				'  "id": "evt_0lKAu5rQvWZlGJ",'+
				'  "data": {'+
				'    "object": {'+
				'      "paid": true,'+
				'      "amount": 9900,'+
				'      "amount_refunded": 6000,'+
				'      "fee": 317,'+
				'      "livemode": false,'+
				'      "invoice": null,'+
				'      "card": {'+
				'        "type": "Visa",'+
				'        "address_zip": null,'+
				'        "address_state": null,'+
				'        "cvc_check": "pass",'+
				'        "object": "card",'+
				'        "address_country": null,'+
				'        "address_line1": null,'+
				'        "address_zip_check": null,'+
				'        "exp_month": 12,'+
				'        "fingerprint": "pmVir47Ti9dNLS50",'+
				'        "country": "US",'+
				'        "name": null,'+
				'        "address_line2": null,'+
				'        "address_line1_check": null,'+
				'        "last4": "4242",'+
				'        "exp_year": 2012,'+
				'        "address_city": null'+
				'      },'+
				'      "created": 1353301554,'+
				'      "object": "charge",'+
				'      "customer": "cus_00000000000000",'+
				'      "failure_message": null,'+
				'      "fee_details": ['+
				'        {'+
				'          "type": "stripe_fee",'+
				'          "amount": 317,'+
				'          "currency": "usd",'+
				'          "application": null,'+
				'          "description": "Stripe processing fees"'+
				'        }'+
				'      ],'+
				'      "id": "ch_0lJN69c0Q4D1lL",'+
				'      "dispute": null,'+
				'      "currency": "usd",'+
				'      "description": "Charge for test@example.com",'+
				'      "refunded": false'+
				'    }'+
				'  }'+
				'}';
		}
	}

	public static String testData_ChargeFailed {
		get {
			return '{'+
				'  "type": "charge.failed",'+
				'  "livemode": false,'+
				'  "object": "event",'+
				'  "created": 1326853478,'+
				'  "id": "evt_00000000000000",'+
				'  "data": {'+
				'    "object": {'+
				'      "fee_details": ['+
				'        {'+
				'          "type": "stripe_fee",'+
				'          "application": null,'+
				'          "currency": "usd",'+
				'          "amount": 0,'+
				'          "description": "Stripe processing fees"'+
				'        }'+
				'      ],'+
				'      "invoice": null,'+
				'      "dispute": null,'+
				'      "livemode": false,'+
				'      "failure_message": null,'+
				'      "card": {'+
				'        "address_country": null,'+
				'        "country": "US",'+
				'        "type": "Visa",'+
				'        "last4": "4242",'+
				'        "address_line1": null,'+
				'        "exp_year": 2012,'+
				'        "fingerprint": "pmVir47Ti9dNLS50",'+
				'        "address_line2": null,'+
				'        "cvc_check": "pass",'+
				'        "address_city": null,'+
				'        "object": "card",'+
				'        "address_zip_check": null,'+
				'        "address_zip": null,'+
				'        "address_line1_check": null,'+
				'        "name": null,'+
				'        "address_state": null,'+
				'        "exp_month": 12'+
				'      },'+
				'      "object": "charge",'+
				'      "created": 1353301843,'+
				'      "fee": 0,'+
				'      "amount": 1000,'+
				'      "currency": "usd",'+
				'      "refunded": false,'+
				'      "customer": "cus_00000000000000",'+
				'      "id": "ch_00000000000000",'+
				'      "paid": false,'+
				'      "amount_refunded": 0,'+
				'      "description": null'+
				'    }'+
				'  }'+
				'}';
		}
	}

    public static String testData_ChargeCaptured {
		get {
			return '{'+
				'  "type": "charge.captured",'+
				'  "livemode": false,'+
				'  "object": "event",'+
				'  "created": 1326853478,'+
				'  "id": "evt_00000000000000",'+
				'  "data": {'+
				'    "object": {'+
				'      "fee_details": ['+
				'        {'+
				'          "type": "stripe_fee",'+
				'          "application": null,'+
				'          "currency": "usd",'+
				'          "amount": 0,'+
				'          "description": "Stripe processing fees"'+
				'        }'+
				'      ],'+
				'      "invoice": null,'+
				'      "dispute": null,'+
				'      "livemode": false,'+
				'      "failure_message": null,'+
				'      "card": {'+
				'        "address_country": null,'+
				'        "country": "US",'+
				'        "type": "Visa",'+
				'        "last4": "4242",'+
				'        "address_line1": null,'+
				'        "exp_year": 2012,'+
				'        "fingerprint": "pmVir47Ti9dNLS50",'+
				'        "address_line2": null,'+
				'        "cvc_check": "pass",'+
				'        "address_city": null,'+
				'        "object": "card",'+
				'        "address_zip_check": null,'+
				'        "address_zip": null,'+
				'        "address_line1_check": null,'+
				'        "name": null,'+
				'        "address_state": null,'+
				'        "exp_month": 12'+
				'      },'+
				'      "object": "charge",'+
				'      "created": 1353301843,'+
				'      "fee": 0,'+
				'      "amount": 1000,'+
				'      "currency": "usd",'+
				'      "refunded": false,'+
				'      "customer": "cus_00000000000000",'+
				'      "id": "ch_00000000000000",'+
				'      "paid": false,'+
				'      "amount_refunded": 0,'+
				'      "description": null'+
				'    }'+
				'  }'+
				'}';
		}
	}
    
    public static String testData_ChargeUnknownEvent {
		get {
			return '{'+
				'  "type": "unknownevent",'+
				'  "livemode": false,'+
				'  "object": "event",'+
				'  "created": 1326853478,'+
				'  "id": "evt_00000000000000",'+
				'  "data": {'+
				'    "object": {'+
				'      "fee_details": ['+
				'        {'+
				'          "type": "stripe_fee",'+
				'          "application": null,'+
				'          "currency": "usd",'+
				'          "amount": 0,'+
				'          "description": "Stripe processing fees"'+
				'        }'+
				'      ],'+
				'      "invoice": null,'+
				'      "dispute": null,'+
				'      "livemode": false,'+
				'      "failure_message": null,'+
				'      "card": {'+
				'        "address_country": null,'+
				'        "country": "US",'+
				'        "type": "Visa",'+
				'        "last4": "4242",'+
				'        "address_line1": null,'+
				'        "exp_year": 2012,'+
				'        "fingerprint": "pmVir47Ti9dNLS50",'+
				'        "address_line2": null,'+
				'        "cvc_check": "pass",'+
				'        "address_city": null,'+
				'        "object": "card",'+
				'        "address_zip_check": null,'+
				'        "address_zip": null,'+
				'        "address_line1_check": null,'+
				'        "name": null,'+
				'        "address_state": null,'+
				'        "exp_month": 12'+
				'      },'+
				'      "object": "charge",'+
				'      "created": 1353301843,'+
				'      "fee": 0,'+
				'      "amount": 1000,'+
				'      "currency": "usd",'+
				'      "refunded": false,'+
				'      "customer": "cus_00000000000000",'+
				'      "id": "ch_00000000000000",'+
				'      "paid": false,'+
				'      "amount_refunded": 0,'+
				'      "description": null'+
				'    }'+
				'  }'+
				'}';
		}
	}
    
    public static String testData_Ping {
		get {
			return '{'+
				'  "type": "ping",'+
				'  "livemode": false,'+
				'  "object": "event",'+
				'  "created": 1326853478,'+
				'  "id": "evt_00000000000000",'+
				'  "data": {'+
				'    "object": {'+
				'      "fee_details": ['+
				'        {'+
				'          "type": "stripe_fee",'+
				'          "application": null,'+
				'          "currency": "usd",'+
				'          "amount": 0,'+
				'          "description": "Stripe processing fees"'+
				'        }'+
				'      ],'+
				'      "invoice": null,'+
				'      "dispute": null,'+
				'      "livemode": false,'+
				'      "failure_message": null,'+
				'      "card": {'+
				'        "address_country": null,'+
				'        "country": "US",'+
				'        "type": "Visa",'+
				'        "last4": "4242",'+
				'        "address_line1": null,'+
				'        "exp_year": 2012,'+
				'        "fingerprint": "pmVir47Ti9dNLS50",'+
				'        "address_line2": null,'+
				'        "cvc_check": "pass",'+
				'        "address_city": null,'+
				'        "object": "card",'+
				'        "address_zip_check": null,'+
				'        "address_zip": null,'+
				'        "address_line1_check": null,'+
				'        "name": null,'+
				'        "address_state": null,'+
				'        "exp_month": 12'+
				'      },'+
				'      "object": "charge",'+
				'      "created": 1353301843,'+
				'      "fee": 0,'+
				'      "amount": 1000,'+
				'      "currency": "usd",'+
				'      "refunded": false,'+
				'      "customer": "cus_00000000000000",'+
				'      "id": "ch_00000000000000",'+
				'      "paid": false,'+
				'      "amount_refunded": 0,'+
				'      "description": null'+
				'    }'+
				'  }'+
				'}';
		}
	}
    
	private static testMethod void test_general() {
		new QE_StripeEvent();
		new QE_StripeEvent.EventData();
		new QE_StripeEvent.UnknownWebhookException();
	}

}
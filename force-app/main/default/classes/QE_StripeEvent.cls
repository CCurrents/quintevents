global class QE_StripeEvent {
	
	global String 	stripeType;
	global Integer 	created;
	global EventData stripeData;
	global Boolean 	livemode;
	global String 	id;
	global QE_StripeError error;
	global String 	stripeObject;
	global String 	apiVersion;
	global Integer 	pendingWebhooks;
	global String 	request;
	
	// map the event to the stripeData object that will be filled
	private static Map<String, String> supported_events = new Map<String, String>{
        'charge.captured' => 'QE_StripeCharge',
		'charge.succeeded' => 'QE_StripeCharge',
		'charge.failed' => 'QE_StripeCharge',
		'charge.refunded' => 'QE_StripeCharge',
		'ping' => 'object'
	};

	// Fix to serialize values that formerly broke the webservice
	// SOBCRM-38
	// https://interaktiv.jira.com/projects/SOBCRM/issues/SOBCRM-38
	// DSt 2016-02-05

	global class PreviousAttributes {
		Integer amount_refunded;
		Boolean refunded;
        String default_card;
	}

	global class EventData {
		// One of the following members will be populated, depending on the event type
		global QE_StripeCharge QE_StripeCharge;
        global QE_StripeCustomer QE_StripeCustomer;
		global QE_StripeCard QE_StripeCard;
	}
	
	// SOBCRM 38 --> 
	public static QE_StripeEvent parse(String json) {
		json = rationalize(json);
        json = QE_StripeUtil.cleanJson(json);
        
		System.debug(System.LoggingLevel.INFO, '\n**** QE_StripeEvent Parsed JSON:\n'+json);
        QE_StripeEvent oQE_StripeEvent = (QE_StripeEvent) System.JSON.deserialize(json, QE_StripeEvent.class);
        
        return oQE_StripeEvent;
	}
	
	// changes the generic 'object' property to a typed property that Apex can serialize into the appropriate object based on the event type
	// Accepts the raw JSON string from the webhook listener
	private static String rationalize(String jsonStr) {
		// identify the type of event
		 
        JSONParser parser = JSON.createParser(jsonStr);
        EventObject eventObject = (EventObject)parser.readValueAs(QE_StripeEvent.EventObject.class);                    

        String data_member = supported_events.get(eventObject.type);
		if (data_member == null) throw new UnknownWebhookException('Unknown webhook event');
		jsonStr = jsonStr.replaceFirst('"object":\\s?\\{',  '"'+data_member+'": {');
		
        return jsonStr;
	}
    
    private class EventObject {
        public String id {get; set;}
        public String type {get; set;}
    }
	
	global class UnknownWebhookException extends Exception {}
}
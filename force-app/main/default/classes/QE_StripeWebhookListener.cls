global virtual class QE_StripeWebhookListener {
    public QE_StripeEvent event;
    
    global void handlePost() {
        RestResponse response = RestContext.response;
        response.addHeader('Content-type','application/json');
        System.debug(System.LoggingLevel.INFO, '\n**** '+RestContext.request.requestBody.toString());
        
        try {
            event = QE_StripeEvent.parse(RestContext.request.requestBody.toString());
        } catch (QE_StripeEvent.UnknownWebhookException e) {
            // gracefully decline
            response.responseBody = Blob.valueOf(JSON.serializePretty(e)+e);
            response.statusCode = 200;
            return;
        } catch (System.Exception e) {
            System.debug(System.LoggingLevel.INFO, '\n**** Exception: '+e); 
            
            Map<String, String> error = new Map<String, String>{
                'type' => e.getTypeName(), 
                    'error' => e.getMessage()
                    };
                        response.responseBody = Blob.valueOf(JSON.serializePretty(error));
            response.statusCode = 500;
            return;
        }
        
        // prevent tests from hitting production
        if (event.livemode == false && QE_StripeAPI.isTest == false) {
            System.debug(System.LoggingLevel.INFO, '\n**** Bailing out'); 
            return;
        }
        
        System.debug(System.LoggingLevel.INFO, '\n**** Event Type in Listener: '+event.stripeType); 
        
        try {
            // Charge webhooks 
            if (event.stripeType == 'charge.succeeded' ||
                event.stripeType == 'charge.failed' ||
                event.stripeType == 'charge.refunded' ||
                event.stripeType == 'charge.captured') {
                    
                    handle_ChargeEvent(event.stripeData.QE_StripeCharge);
                    
                } else if (event.stripeType == 'ping') {
                    // Do nothing - will be responded with status 200
                } else {
                    response.statusCode = 400;
                    response.responseBody = Blob.valueOf('{success:false, event:"'+event.stripeType+'",message:"Unhandled event"}');
                    return;
                }
        } catch (QE_StripeException e) {
            response.responseBody = Blob.valueOf(JSON.serializePretty(e));
            System.debug(System.LoggingLevel.INFO, '\n**** Listener Handler Error: '+response.responseBody.toString()); 
            response.statusCode = 406;
            return;
        }
        
        // OK
        response.statusCode = 200;
        response.responseBody = Blob.valueOf('{success:true, event:"'+event.stripeType+'"}');
    }
    
    // Handle the charge.event webhook
    global virtual void handle_ChargeEvent(QE_StripeCharge charge) {
        throw new QE_StripeEvent.UnknownWebhookException('Not implemented');
    }
    
}
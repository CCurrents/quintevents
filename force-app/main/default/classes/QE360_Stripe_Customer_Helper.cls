public class QE360_Stripe_Customer_Helper {
    
    String CUSTOMER_SEARCH_URL = 'https://admin.quintevents.com/charge/find-customer.php?token=Q1BBNXDMSRGFAJZ2JVEY';
    String INTERNATIONAL_CUSTOMER_SEARCH_URL = 'https://admin.quintevents.com/charge-int-dev/find-customer.php?token=Q1BBNXDMSRGFAJZ2JVEY';
    
    // Constructor
    public QE360_Stripe_Customer_Helper(){}
    
    // Get QE stripe customer data, return null if dont exist 
    public QE360_Stripe_Customer__c getQEStripeCustomer(String email) {
        QE360_Stripe_Customer__c qeQE360StripeCustomer;
        try {
            qeQE360StripeCustomer = [SELECT Id, Email__c, Stripe_Customer_Id__c, International_Stripe_Customer_Id__c FROM QE360_Stripe_Customer__c WHERE Email__c = :email];
        } catch(Exception ex) {
            qeQE360StripeCustomer = null;
        }
        return qeQE360StripeCustomer;
    }
    
    // Get Stripe customer data
    public String getStripeCustomerJson(String stripeCustomerId, String sKey) {
        Stripe request = new Stripe(sKey);
        return request.retrieveCustomerRaw(stripeCustomerId);
    }
    
    // Search stripe customer in stirpe via AO's endpoing
    public String searchCustomerRaw(String clientEmail) {
        HttpRequest http = new HttpRequest();
        String mainUrl=CUSTOMER_SEARCH_URL+'&email='+clientEmail;
        http.setEndpoint(mainUrl);
        http.setMethod('GET');
        //Blob headerValue = Blob.valueOf(API_KEY + ':');
        //String authorizationHeader = 'BASIC ' +
        //EncodingUtil.base64Encode(headerValue);
        //http.setHeader('Authorization', authorizationHeader);
        String response;
        if(!Test.isRunningTest()){
            Http con = new Http();
            HttpResponse hs = con.send(http);
            
            system.debug('#### '+ hs.getBody());
            
            response = hs.getBody();
            //statusCode=hs.getStatusCode();
        }
        
        return response;
    }
    
    public QE360_Stripe_Customer__c getStripeCustomer(String email, String name) {
        QE360_Stripe_Customer__c qeQE360StripeCustomer;
        try {
            qeQE360StripeCustomer = [SELECT Id, Email__c, Stripe_Customer_Id__c FROM QE360_Stripe_Customer__c WHERE Email__c = :email];
        } catch(Exception ex) {
            qeQE360StripeCustomer = null;
        }
        // NO QE360_Stripe_Customer with current email
        if (qeQE360StripeCustomer == null) {
            qeQE360StripeCustomer = new QE360_Stripe_Customer__c();
            // Seach: If Stripe cusomter with this email exists
            SearchedStripeCustomer searchedStripeCustomer = searchStripeCustomer(email);
            Boolean custExist = searchedStripeCustomer.cust_exists;
            String custId = searchedStripeCustomer.stripe_id;
            // Stripe Customer exsits with current email
            if (custExist) {
                // Create new QE Stripe Customer with Stripe Customer Id
                qeQE360StripeCustomer.Name = name;
                qeQE360StripeCustomer.Email__c = email;
                qeQE360StripeCustomer.Stripe_Customer_Id__c = custId;
                insert qeQE360StripeCustomer;
            } else {
                // Create new QE Stripe Customer without Stripe Customer Id
                qeQE360StripeCustomer.Name = name;
                qeQE360StripeCustomer.Email__c = email;
                insert qeQE360StripeCustomer;
            }
        }
        
        return qeQE360StripeCustomer;
    }  
    
    public QE360_Stripe_Customer__c getStripeCustomer(String email, String name, Boolean internationalStripe) {
        QE360_Stripe_Customer__c qeQE360StripeCustomer;
        try {
            qeQE360StripeCustomer = [SELECT Id, Email__c, Stripe_Customer_Id__c, International_Stripe_Customer_Id__c FROM QE360_Stripe_Customer__c WHERE Email__c = :email];
        } catch(Exception ex) {
            qeQE360StripeCustomer = null;
        }
        // NO QE360_Stripe_Customer with current email
        if (qeQE360StripeCustomer == null) {
            qeQE360StripeCustomer = new QE360_Stripe_Customer__c();
            // Seach: If Stripe cusomter with this email exists
            SearchedStripeCustomer searchedStripeCustomer = searchStripeCustomer(email, internationalStripe);
            Boolean custExist = searchedStripeCustomer.cust_exists;
            String custId = searchedStripeCustomer.stripe_id;
            // Stripe Customer exsits with current email
            if (custExist) {
                // Create new QE Stripe Customer with Stripe Customer Id
                qeQE360StripeCustomer.Name = name;
                qeQE360StripeCustomer.Email__c = email;
                if(internationalStripe) {
                    // International Stripe
                   qeQE360StripeCustomer.International_Stripe_Customer_Id__c = custId;
                } else {
                    // Regular Stripe
                   qeQE360StripeCustomer.Stripe_Customer_Id__c = custId;
                }
                
                insert qeQE360StripeCustomer;
            } else {
                // Create new QE Stripe Customer without Stripe Customer Id
                qeQE360StripeCustomer.Name = name;
                qeQE360StripeCustomer.Email__c = email;
                insert qeQE360StripeCustomer;
            }
        }
        
        return qeQE360StripeCustomer;
    }  
    
    public SearchedStripeCustomer searchStripeCustomer(String clientEmail) {
        HttpRequest http = new HttpRequest();
        String mainUrl=CUSTOMER_SEARCH_URL+'&email='+clientEmail;
        http.setEndpoint(mainUrl);
        http.setMethod('GET');
        String response;
        if(!Test.isRunningTest()){
            Http con = new Http();
            HttpResponse hs = con.send(http);
            system.debug('#### '+ hs.getBody());
            response = hs.getBody();
        } else {
            response = '{"authorized":true,"cust_exists":true,"stripe_id":"cus_8w0XLWv0UWxVv3"}';
        }
        JSONParser parser = JSON.createParser(response);
        return (SearchedStripeCustomer)parser.readValueAs(QE360_Stripe_Customer_Helper.SearchedStripeCustomer.class); 
    }
    
    public SearchedStripeCustomer searchStripeCustomer(String clientEmail, Boolean internationalStripe) {
        HttpRequest http = new HttpRequest();
        String mainUrl = '';
        if(internationalStripe) {
            // International Stripe
           mainUrl = INTERNATIONAL_CUSTOMER_SEARCH_URL+'&email='+clientEmail;
        } else {
            // Regular Stripe
           mainUrl = CUSTOMER_SEARCH_URL+'&email='+clientEmail;
        }
        
        http.setEndpoint(mainUrl);
        http.setMethod('GET');
        String response;
        if(!Test.isRunningTest()){
            Http con = new Http();
            HttpResponse hs = con.send(http);
            system.debug('#### '+ hs.getBody());
            response = hs.getBody();
        } else {
            response = '{"authorized":true,"cust_exists":true,"stripe_id":"cus_8w0XLWv0UWxVv3"}';
        }
        JSONParser parser = JSON.createParser(response);
        return (SearchedStripeCustomer)parser.readValueAs(QE360_Stripe_Customer_Helper.SearchedStripeCustomer.class); 
    }
    
    public class SearchedStripeCustomer {
        public Boolean authorized {get; set;}
        public Boolean cust_exists {get; set;}
        public String stripe_id {get; set;}
    }
    
}
public class QE_Stripe_Customer_Helper {

    String CUSTOMER_SEARCH_URL = 'https://admin.quintevents.com/charge/find-customer.php?token=Q1BBNXDMSRGFAJZ2JVEY';
    String response;
    
    // Constructor
    public QE_Stripe_Customer_Helper(){}
    
    // Get QE stripe customer data, return null if dont exist 
    public QE360_Stripe_Customer__c getQEStripeCustomer(String email) {
        QE360_Stripe_Customer__c qeQE360StripeCustomer;
        try {
            qeQE360StripeCustomer = [SELECT Id, Email__c, Stripe_Customer_Id__c FROM QE360_Stripe_Customer__c WHERE Email__c = :email];
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
        
        if(!Test.isRunningTest()){
            Http con = new Http();
            HttpResponse hs = con.send(http);
    
            system.debug('#### '+ hs.getBody());
            
            response = hs.getBody();
            //statusCode=hs.getStatusCode();
        }
        
       return response;
    }
    
}
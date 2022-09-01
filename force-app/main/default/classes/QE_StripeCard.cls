global class QE_StripeCard {

    private static final String SERVICE_URL = 'https://api.stripe.com/v1/customers/';

  global String stripeType;
  global String brand;
  global String country;
  global Integer exp_month;
  global String fingerprint;
  global Integer exp_year;
  global String last4;
  global String stripeObject;
  global String id;
  global String name;
  global QE_StripeError error;
  global String customer_id;
  
  global Date expirationDate {
    get {
      Date d = Date.newInstance(this.exp_year, this.exp_month, Date.daysInMonth(this.exp_year, this.exp_month));
      return d;
    }
  }
    
    global static QE_StripeCard create(String customerId, Map<String, String> properties) {
        HttpRequest http = new HttpRequest();
        http.setEndpoint(SERVICE_URL + customerId + '/sources');
        http.setMethod('POST');
        Blob headerValue = Blob.valueOf(QE_StripeAPI.ApiKey + ':');
        String authorizationHeader = 'BASIC ' +
        EncodingUtil.base64Encode(headerValue);
        http.setHeader('Authorization', authorizationHeader);
    
        http.setBody(QE_StripeUtil.urlify(properties));
        System.debug(System.LoggingLevel.INFO, '\n**** REQUEST BODY:\n'+http.getBody());   
        
        String response;
        Integer statusCode;
        Http con = new Http();
        HttpResponse hs = new HttpResponse();
        
        if (!Test.isRunningTest()) {
          try {
            hs = con.send(http);
          } catch (CalloutException e) {
            return null;
          }
        } else {
          hs.setBody(QE_StripeCardTests.testData_getCard);
          hs.setStatusCode(200);
        }
    
        system.debug('#### '+ hs.getBody());
        
        response = hs.getBody();
        statusCode = hs.getStatusCode();
        
        try {
          QE_StripeCard o = QE_StripeCard.parse(response);
          System.debug(System.LoggingLevel.INFO, '\n**** QE_StripeCard object: '+o); 
          return o;
        } catch (System.JSONException e) {
          System.debug(System.LoggingLevel.INFO, '\n**** JSONException: '+e); 
          return null;
        }
  }
  
  global static QE_StripeCard create(String customerId, Map<String, String> properties, Boolean internationalStripe) {
        HttpRequest http = new HttpRequest();
        http.setEndpoint(SERVICE_URL + customerId + '/sources');
        http.setMethod('POST');
        Blob headerValue = Blob.valueOf(QE_StripeAPI.apiKeyByAccount(internationalStripe) + ':');
        String authorizationHeader = 'BASIC ' +
        EncodingUtil.base64Encode(headerValue);
        http.setHeader('Authorization', authorizationHeader);
    
        http.setBody(QE_StripeUtil.urlify(properties));
        System.debug(System.LoggingLevel.INFO, '\n**** REQUEST BODY:\n'+http.getBody());   
        
        String response;
        Integer statusCode;
        Http con = new Http();
        HttpResponse hs = new HttpResponse();
        
        if (!Test.isRunningTest()) {
          try {
            hs = con.send(http);
          } catch (CalloutException e) {
            return null;
          }
        } else {
          hs.setBody(QE_StripeCardTests.testData_getCard);
          hs.setStatusCode(200);
        }
    
        system.debug('#### '+ hs.getBody());
        
        response = hs.getBody();
        statusCode = hs.getStatusCode();
        
        try {
          QE_StripeCard o = QE_StripeCard.parse(response);
          System.debug(System.LoggingLevel.INFO, '\n**** QE_StripeCard object: '+o); 
          return o;
        } catch (System.JSONException e) {
          System.debug(System.LoggingLevel.INFO, '\n**** JSONException: '+e); 
          return null;
        }
  }

  public static QE_StripeCard parse(String json) {
    // rough string replacement to simplify json parsing and avoid Apex reserved words
    json = QE_StripeUtil.cleanJson(json);
    return (QE_StripeCard) System.JSON.deserialize(json, QE_StripeCard.class);
  }
    
}
global class QE_StripeCustomer {

    private static final String SERVICE_URL = 'https://api.stripe.com/v1/customers';
  global static final String TEST_ID = 'cus_00000000000000';

  global Integer created;
  global Integer account_balance;
  global String description;
  global QE_StripeError error;
  global Boolean livemode;
  global String token;
  global String id;
  global Map<String, String> metadata;
  
  global CardList cards;
  global CardList sources;
  
  global String default_card;
  
  global class CardList {
    global Integer count;
    global String url;
    global List<QE_StripeCard> stripeData;
  }

  // static cache to eliminate multiple lookups in same transaction
  private static Map<String, QE_StripeCustomer> mCustomers = new Map<String, QE_StripeCustomer>();

  global static QE_StripeCustomer getCustomer(String customerId) {
    if (mCustomers.containsKey(customerId)) {
      return mCustomers.get(customerId);
    }
    
    HttpRequest http = new HttpRequest();
    http.setEndpoint(QE_StripeCustomer.SERVICE_URL+'/'+customerId);
    http.setMethod('GET');
    Blob headerValue = Blob.valueOf(QE_StripeAPI.ApiKey + ':');
    String authorizationHeader = 'BASIC ' +
    EncodingUtil.base64Encode(headerValue);
    http.setHeader('Authorization', authorizationHeader);
    
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
      hs.setBody(QE_StripeCustomerTests.testData);
      hs.setStatusCode(200);
    }
    system.debug('#### '+ hs.getBody());
    
    response = hs.getBody();
    statusCode = hs.getStatusCode();
    system.debug('$$statusCode = '+hs.getStatusCode());
    
    try {
      QE_StripeCustomer o = QE_StripeCustomer.parse(response);
      System.debug(System.LoggingLevel.INFO, '\n**** Stripe Customer: '+o); 
      //if (o.error != null) throw new QE_StripeException(o.error);
      mCustomers.put(customerId, o);
      return o;
    } catch (System.JSONException e) {
      return null;
    }
  }
  
  global static QE_StripeCustomer getCustomer(String customerId, Boolean internationalStripe) {
    if (mCustomers.containsKey(customerId)) {
      return mCustomers.get(customerId);
    }
    
    HttpRequest http = new HttpRequest();
    http.setEndpoint(QE_StripeCustomer.SERVICE_URL+'/'+customerId);
    http.setMethod('GET');
    Blob headerValue = Blob.valueOf(QE_StripeAPI.apiKeyByAccount(internationalStripe) + ':');
    String authorizationHeader = 'BASIC ' +
    EncodingUtil.base64Encode(headerValue);
    http.setHeader('Authorization', authorizationHeader);
    
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
      hs.setBody(QE_StripeCustomerTests.testData);
      hs.setStatusCode(200);
    }
    system.debug('#### '+ hs.getBody());
    
    response = hs.getBody();
    statusCode = hs.getStatusCode();
    system.debug('$$statusCode = '+hs.getStatusCode());
    
    try {
      QE_StripeCustomer o = QE_StripeCustomer.parse(response);
      System.debug(System.LoggingLevel.INFO, '\n**** Stripe Customer: '+o); 
      //if (o.error != null) throw new QE_StripeException(o.error);
      mCustomers.put(customerId, o);
      return o;
    } catch (System.JSONException e) {
      return null;
    }
  }

  global static QE_StripeCustomer create(Map<String, String> properties, Map<String, String> metadata) {
    return updateCustomer(null, properties, metadata);    
  }
  
  global static QE_StripeCustomer updateCustomer(String customerId, Map<String, String> properties, Map<String, String> metadata) {
    HttpRequest http = new HttpRequest();
    
    if (customerId == null) 
      http.setEndpoint(QE_StripeCustomer.SERVICE_URL);
    else 
      http.setEndpoint(QE_StripeCustomer.SERVICE_URL+'/'+customerId);

    http.setMethod('POST');
    Blob headerValue = Blob.valueOf(QE_StripeAPI.ApiKey + ':');
    String authorizationHeader = 'BASIC ' +
    EncodingUtil.base64Encode(headerValue);
    http.setHeader('Authorization', authorizationHeader);
    
    Map<String, String> payload = new Map<String, String>();
    if (properties != null) {
      for (String key : properties.keySet()) {
        if (properties.get(key) != null) {
          payload.put(key, properties.get(key));
        }
      }
    }

    if (metadata != null) {
      for (String key : metadata.keySet()) {
        if (metadata.get(key) != null) {
          payload.put('metadata['+key+']', metadata.get(key));
        }
      }
    }

    http.setBody(QE_StripeUtil.urlify(payload));
    System.debug(System.LoggingLevel.INFO, '\n**** REQUEST BODY:\n'+http.getBody());   
    
    String response;
    Integer statusCode;
    Http con = new Http();
    HttpResponse hs = new HttpResponse();
    
    if (!Test.isRunningTest()) {
      try {
        hs = con.send(http);
        system.debug('#### [1]'+ hs.getBody());
        
      } catch (CalloutException e) {
        return null;
      }
    } else {
      hs.setBody(QE_StripeCustomerTests.testData);
      hs.setStatusCode(200);
    }
    
    statusCode = hs.getStatusCode();
    system.debug('$$statusCode = '+hs.getStatusCode());
    
    try {
      QE_StripeCustomer new_customer = QE_StripeCustomer.parse(hs.getBody());
      if (new_customer.error != null) throw new QE_StripeException(new_customer.error);

      System.debug(System.LoggingLevel.INFO, '\n**** Customer: '+new_customer); 
      mCustomers.put(new_customer.id, new_customer);
      return new_customer;
    } catch (System.JSONException e) {
      return null;
    }
  }
  
  global static QE_StripeCustomer create(Map<String, String> properties, Map<String, String> metadata, Boolean internationalStripe) {
    return updateCustomer(null, properties, metadata, internationalStripe);    
  }
  
  global static QE_StripeCustomer updateCustomer(String customerId, Map<String, String> properties, Map<String, String> metadata,  Boolean internationalStripe) {
    HttpRequest http = new HttpRequest();
    
    if (customerId == null) 
      http.setEndpoint(QE_StripeCustomer.SERVICE_URL);
    else 
      http.setEndpoint(QE_StripeCustomer.SERVICE_URL+'/'+customerId);

    http.setMethod('POST');
    Blob headerValue = Blob.valueOf(QE_StripeAPI.apiKeyByAccount(internationalStripe) + ':');
    String authorizationHeader = 'BASIC ' +
    EncodingUtil.base64Encode(headerValue);
    http.setHeader('Authorization', authorizationHeader);
    
    Map<String, String> payload = new Map<String, String>();
    if (properties != null) {
      for (String key : properties.keySet()) {
        if (properties.get(key) != null) {
          payload.put(key, properties.get(key));
        }
      }
    }

    if (metadata != null) {
      for (String key : metadata.keySet()) {
        if (metadata.get(key) != null) {
          payload.put('metadata['+key+']', metadata.get(key));
        }
      }
    }

    http.setBody(QE_StripeUtil.urlify(payload));
    System.debug(System.LoggingLevel.INFO, '\n**** REQUEST BODY:\n'+http.getBody());   
    
    String response;
    Integer statusCode;
    Http con = new Http();
    HttpResponse hs = new HttpResponse();
    
    if (!Test.isRunningTest()) {
      try {
        hs = con.send(http);
        system.debug('#### [1]'+ hs.getBody());
        
      } catch (CalloutException e) {
        return null;
      }
    } else {
      hs.setBody(QE_StripeCustomerTests.testData);
      hs.setStatusCode(200);
    }
    
    statusCode = hs.getStatusCode();
    system.debug('$$statusCode = '+hs.getStatusCode());
    
    try {
      QE_StripeCustomer new_customer = QE_StripeCustomer.parse(hs.getBody());
      if (new_customer.error != null) throw new QE_StripeException(new_customer.error);

      System.debug(System.LoggingLevel.INFO, '\n**** Customer: '+new_customer); 
      mCustomers.put(new_customer.id, new_customer);
      return new_customer;
    } catch (System.JSONException e) {
        System.debug('Exception in QE_StripeCustomer: '+e);
      return null;
    }
  }

  global static QE_StripeCustomer setDefaultCard(String customerId, QE_StripeCard card) {
    Map<String, String> properties = new Map<String, String>{
      'default_card' => card.id
    };
    
    return updateCustomer(customerId, properties, null);
  }

  global static List<QE_StripeCustomer> getCustomers(Integer pageSize, Integer offset) {
    HttpRequest http = new HttpRequest();
    http.setEndpoint(QE_StripeCustomer.SERVICE_URL+'?count='+pageSize+'&offset='+offset);
    http.setMethod('GET');
    Blob headerValue = Blob.valueOf(QE_StripeAPI.ApiKey + ':');
    String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
    http.setHeader('Authorization', authorizationHeader);
    
    String t_json;
    Integer statusCode;
    
    List<QE_StripeCustomer> customers = new List<QE_StripeCustomer>();
    Http con = new Http();
    HttpResponse hs = new HttpResponse();
    
    if (!Test.isRunningTest()) {
      try {
        hs = con.send(http);
      } catch (CalloutException e) {
        return null;
      }
    } else {
      hs.setBody(QE_StripeCustomerTests.testData_getCustomers);
      hs.setStatusCode(200);
    }

    t_json = hs.getBody();
    statusCode = hs.getStatusCode();
    
    try {
      t_json = QE_StripeUtil.cleanJson(t_json);
      t_json = t_json.substring(t_json.indexOf('['), t_json.lastIndexOf(']')+1);
      customers = (List<QE_StripeCustomer>) JSON.deserialize(t_json, List<QE_StripeCustomer>.class);
      return customers;
      
    } catch (System.JSONException e) {
      return null;
    }
  }
  
  public QE_StripeCard getDefaultCard() {
    for (QE_StripeCard card : this.cards.stripeData) {
      if (card.id == this.default_card) {
        return card;
      }
    }

    return null;
  }

  public static QE_StripeCustomer parse(String json) {
    json = QE_StripeUtil.cleanJson(json);
    return (QE_StripeCustomer) System.JSON.deserialize(json, QE_StripeCustomer.class);
  }
    
}
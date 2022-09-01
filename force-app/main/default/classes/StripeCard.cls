public class StripeCard {

    public StripeGetResponseValues StripeGetResponseValue{get;set;}    
    public StripeResponseModel StripeResponseModel{get;set;}
    
    Integer statusCode;
    string response;
    
    String CARD_URL = 'https://api.stripe.com/v1/customers';
    String API_KEY = '';
    
    public StripeCard(String apikey){
        API_KEY=apikey;
        StripeGetResponseValue=new StripeGetResponseValues();
        StripeResponseModel=new StripeResponseModel();
    }
    
    // Add Card
    public String addCard(String customerId, String cnumber,String exp_month,String exp_year,String cvc,String name,String addressLine1,String addressCity,String addressState, String addressZip){
        HttpRequest http = new HttpRequest();
        http.setEndpoint(CARD_URL+'/'+customerId+'/sources');
        http.setMethod('POST');
        Blob headerValue = Blob.valueOf(API_KEY + ':');
        String authorizationHeader = 'BASIC ' +
        EncodingUtil.base64Encode(headerValue);
        http.setHeader('Authorization', authorizationHeader);
        http.setBody('card[number]='+cnumber+'&card[exp_year]='+exp_year+'&card[exp_month]='+exp_month+'&card[cvc]='+cvc+'&card[name]='+name+'&card[address_line1]='+addressLine1+'&card[address_city]='+addressCity+'&card[address_state]='+addressState+'&card[address_zip]='+addressZip+'&card[metadata][savedb]=true');    

        if(!Test.isRunningTest()){
            Http con = new Http();
            HttpResponse hs = con.send(http);
    
            system.debug('#### '+ hs.getBody());
            
            response = hs.getBody();
            statusCode=hs.getStatusCode();
            system.debug('$$statusCode='+hs.getStatusCode());
        }
		return response; 
    }
    
}
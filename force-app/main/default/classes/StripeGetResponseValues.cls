/*
@Name             : StripeGetResponseValues
@Author           : Aslam Bari/Sanjay Mankani (http://www.aslambari.com/stripe_apex_toolkit.html)
@Date             : 6 Oct, 2011
@Description      : This class contains methods to parse response from Stripe.
                      
*/

public class StripeGetResponseValues{

    public string getValue(string accRecordJson, string fieldName){
        integer startIdx = accRecordJson.indexOf(fieldName);
        integer endIdx = -1;
        if(startIdx > 0){
            endIdx = accRecordJson.indexOf('",', startIdx);
        }
        if(startIdx > 0 && endIdx > startIdx){
            
            return accRecordJson.substring(startIdx + fieldName.length() + 2,endIdx);
        }
        return '';
   }
  
   public string getNumValue(string accRecordJson, string fieldName){
    integer startIdx = accRecordJson.indexOf(fieldName);
    integer endIdx = -1;
    if(startIdx > 0){
        endIdx = accRecordJson.indexOf(',', startIdx);
    }
    if(startIdx > 0 && endIdx > startIdx){
        //system.debug('### ' +startIdx + '---' + endIdx);
        return accRecordJson.substring(startIdx + fieldName.length() + 1,endIdx);
    }
    return '';
   }
   
   public string getLastValue(string accRecordJson, string fieldName){
        integer startIdx = accRecordJson.indexOf(fieldName);
        integer endIdx = -1;
        if(startIdx > 0){
            endIdx = accRecordJson.indexOf('"\n', startIdx);
        }
        system.debug('$$startIdx='+startIdx);
        system.debug('$$endIdx='+endIdx);
        if(startIdx > 0 && endIdx > startIdx){                    
            return accRecordJson.substring(startIdx + fieldName.length() + 2,endIdx);
        }
        return '';
   }
    
    
   public string getCardId(string accRecordJson){
        // Parse entire JSON response.
       JSONParser parser = JSON.createParser(accRecordJson);
       String stripeCardId;
       while (parser.nextToken() != null) {
           // Start at the array of invoices.
           if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
               (parser.getText() == 'sources')){
                   
                   while (parser.nextToken() != null) {
                       if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                           (parser.getText() == 'data')){
                               
                               parser.nextToken();
                               if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                                   while (parser.nextToken() != null) {
                                       if(parser.getCurrentToken() == JSONToken.END_ARRAY) {break;}
                                       if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                                           (parser.getText() == 'id')){
                                               parser.nextToken();
                                               stripeCardId = parser.getText();
                                               parser.skipChildren();
                                               break;
                                       }
                                       
                                   }
                               }
                               break;
                           }
                   }
                   break;
               }
       }
       return stripeCardId;
   }
   
   /*public string getLastNumValue(string accRecordJson, string fieldName){
        integer startIdx = accRecordJson.indexOf(fieldName);
        integer endIdx = -1;
        if(startIdx > 0){
            endIdx = accRecordJson.indexOf('\n', startIdx);
        }
        system.debug('$$startIdx='+startIdx);
        system.debug('$$endIdx='+endIdx);
        if(startIdx > 0 && endIdx > startIdx){                    
            return accRecordJson.substring(startIdx + fieldName.length() + 2,endIdx);
        }
        return '';
   }*/
}
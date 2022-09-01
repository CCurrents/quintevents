/**
 * @File Name          : XeroCalloutResponseParser.cls
 * @Description        : To parse callout response
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 04/02/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    04/02/2020  kchavda@addonblue.com     Initial Version
**/
public with sharing class XeroCalloutResponseParser {
    
     /**
    * @description To prase contact response
    * @author kchavda@addonblue.com | 04/02/2020
    * @param String  
    * @return List<XeroContact>
    **/
    public static List<XeroContact> parseContacts(String jsonBody) {

        // Re-serialize just the Contacts portion back to JSOn
        String jsonSerialized = generateJsonStringForParsing (jsonBody, 'Contacts');
        
        // And finally parse the now re-serialized contact list back into Contact objects
        return (List<XeroContact>) JSON.deserialize(jsonSerialized, List<XeroContact>.class);
    }
    
     /**
    * @description To prase invoice response
    * @author kchavda@addonblue.com | 04/02/2020
    * @param String  
    * @return List<XeroInvoice>
    **/
    public static List<XeroInvoice> parseInvoices(String jsonBody) {

        // Re-serialize just the Contacts portion back to JSOn
        String jsonSerialized = generateJsonStringForParsing (jsonBody, 'Invoices');

        // And finally parse the now re-serialized contact list back into Contact objects
        return (List<XeroInvoice>) JSON.deserialize(jsonSerialized, List<XeroInvoice>.class);
    }
    
     /**
    * @description To prase payment response
    * @author kchavda@addonblue.com | 04/02/2020
    * @param String  
    * @return List<XeroPayment>
    **/
    public static XeroPayment parsePayment(String jsonBody) {
        // Re-serialize just the Contacts portion back to JSOn
        String jsonSerialized = generateJsonStringForParsing (jsonBody, 'Payments');        
        // And finally parse the now re-serialized contact list back into Contact objects
        return (XeroPayment) JSON.deserialize(jsonBody, XeroPayment.class);
    }
    
    /**
    * @description To prase json
    * @author kchavda@addonblue.com | 04/02/2020
    * @param String  
    * @return String 
    **/
    private static String generateJsonStringForParsing (String jsonBody, String objectName) {        
        // Parse the JSON response
        Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);

        // Re-serialize just the object portion back to JSON
        return JSON.serialize((List<Object>) jsonResponseMap.get(objectName));
    }
}
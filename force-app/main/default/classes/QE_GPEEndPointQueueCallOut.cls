/**
 * @File Name          : QE_GPEEndPointQueueCallOut.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 6:18:02 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
public class QE_GPEEndPointQueueCallOut /*implements Queueable, Database.AllowsCallouts*/ {

    // Id oppId;      
      
    public QE_GPEEndPointQueueCallOut () { 
        // this.oppId = oppId;        
    }  
    // public void execute(QueueableContext context) {
    // System.debug('oppId-->'+oppId);
    //     Opportunity oppObj = [Select Id,Event__r.GPT_Event_Id__c,Account.PersonEmail,Account.FirstName,Account.LastName,Account.Salutation,
    //                         Account.BillingStreet,Account.BillingPostalCode,Account.BillingCity,Account.BillingCountry,
    //                         Account.phone,Primary_Contact__r.FirstName,Primary_Contact__r.LastName,Primary_Contact__r.Email,Primary_Contact__r.Salutation,
    //                         Shipping_City__c,Shipping_Country__c,Shipping_State_Province__c,Shipping_Street__c,Shipping_Zip_Postal_Code__c,
    //                         Primary_Contact__r.phone, (Select Id,Product2.GPT_Article_Id__c,Quantity from OpportunityLineItems), 
    //                         (Select id, xero_invoice_Id__c from opportunity_Payment_Terms__r limit 1) from Opportunity where Id=: oppId];
    //     Map<String, String> countryMap = new Map<String, String>();
    //     Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
    //     List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    //     for( Schema.PicklistEntry f : ple){
    //       countryMap.put(f.getLabel(), f.getValue());
    //     }

    //    String randStr = '';
    //    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    //    while (randStr.length() < 10) {
    //    Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
    //    randStr += chars.substring(idx, idx+1);
    //    }
       
    //     JSONGenerator genJson = JSON.createGenerator(true);
    //     //genJson.writeStartArray();
    //     genJson.writeStartObject();
    //         genJson.writeFieldName('articles');
    //             genJson.writeStartArray();
    //                 for(OpportunityLineItem oppLineItem : oppObj.OpportunityLineItems)
    //                 {
    //                 if(oppLineItem.Product2.GPT_Article_Id__c != null){
    //                     genJson.writeStartObject();
    //                     genJson.writeObjectField('id',(oppLineItem.Product2.GPT_Article_Id__c != null ? oppLineItem.Product2.GPT_Article_Id__c : ''));
    //                     genJson.writeObjectField('qty',(oppLineItem.Quantity != null ? oppLineItem.Quantity.round(System.RoundingMode.UNNECESSARY) : 0));
    //                     genJson.writeEndObject();
    //                 }
    //                 }                    
    //             genJson.writeEndArray();
    //         genJson.writeFieldName('customer');
    //         genJson.writeStartObject();                
    //             genJson.writeObjectField('email',(oppObj.Primary_Contact__r.Email != null ? oppObj.Primary_Contact__r.Email : ''));
    //             genJson.writeObjectField('first_name',(oppObj.Primary_Contact__r.FirstName != null ? oppObj.Primary_Contact__r.FirstName : ''));
    //             genJson.writeObjectField('last_name',(oppObj.Primary_Contact__r.LastName != null ? oppObj.Primary_Contact__r.LastName : ''));
    //             genJson.writeObjectField('salutation',(oppObj.Primary_Contact__r.Salutation != null ? oppObj.Primary_Contact__r.Salutation : ''));
    //             genJson.writeObjectField('address',(oppObj.Shipping_Street__c != null ? oppObj.Shipping_Street__c : ''));
    //             genJson.writeObjectField('zip',(oppObj.Shipping_Zip_Postal_Code__c != null ? oppObj.Shipping_Zip_Postal_Code__c : ''));
    //             genJson.writeObjectField('city',(oppObj.Shipping_City__c != null ? oppObj.Shipping_City__c : ''));
    //             genJson.writeObjectField('country',(countryMap.containsKey(oppObj.Shipping_Country__c) ? countryMap.get(oppObj.Shipping_Country__c) : ''));
    //             genJson.writeObjectField('mobile',(oppObj.Primary_Contact__r.phone != null ? oppObj.Primary_Contact__r.phone : ''));
    //         genJson.writeEndObject();
    //         genJson.writeObjectField('paymeth','UEBERWEISUNG');
    //         genJson.writeObjectField('key', randStr);//oppObj.Id); randStr
    //         if(oppObj.opportunity_Payment_Terms__r != null && oppObj.opportunity_Payment_Terms__r[0].xero_invoice_Id__c != null){
    //             genJson.writeObjectField('cust_invoice', oppObj.opportunity_Payment_Terms__r[0].xero_invoice_Id__c);
    //         }
    //     genJson.writeEndObject();
    //     //genJson.writeEndArray();
    //     String jsonString = genJson.getAsString();
    //     system.debug('jsonString-->'+jsonString);
    //     //GPE_Api_Detail__c GPEDetails = GPE_Api_Detail__c.getOrgDefaults();
    //     HttpRequest req = new HttpRequest();
    //     req.setMethod('POST');
    //     //system.debug('Label.GPE_Endpoint+oppObj-->'+Label.GPE_Endpoint);
    //     //req.setEndpoint(GPEDetails.Production__c ? GPEDetails.EndpointURL__c : GPEDetails.Sandbox_EndpointURL__c);
    //     //req.setEndpoint('http://ec2-35-157-98-201.eu-central-1.compute.amazonaws.com:8080/api/v1.1/gpt/en/order/'+oppObj.Event__r.GPT_Event_Id__c);
    //     req.setEndpoint(Label.GPE_Endpoint+oppObj.Event__r.GPT_Event_Id__c);
    //     req.setHeader('Content-Type', 'application/json');
    //     req.setHeader('Cache-Control', 'no-cache');
    //     req.setHeader('Accept', '*/*');
    //     req.setHeader('Authorization', 'Bearer Qe1v0yrj9XTDwJHkWNF3Mu2lLQzlvz6swblTQJleHHncpMdqL7v6S3bmzAxu');        
    //     req.setBody(jsonString);
    //     String stringResponce;
    //     Http http = new Http();
    //     if(!Test.isRunningTest()){
    //         HttpResponse res = http.send(req);
    //         stringResponce = res.getBody();
    //     }
    //     else{
    //         stringResponce = '{"success": false,"message": "WRONG_ARTICLE"}';
    //     }
    //         System.debug('stringResponce-->'+stringResponce);
    //         String[] str1 = stringResponce.split(':');
    //         String[] str2 = str1[1].split(',');
    //         str1[2] = str1[2].replace('"','');
    //         str1[2] = str1[2].replace('}','');
    //         /*orderJSON2Apex jsonData = (orderJSON2Apex) JSON.deserialize(stringResponce, orderJSON2Apex.class);
    //         system.debug('jsonData-->'+jsonData);*/
    //         if( str2[0] == 'true' ){
    //             Opportunity opp = new Opportunity();
    //             opp.Id = oppObj.Id;
    //             opp.GPT_Booking_Id__c = str1[2];                
    //             //System.debug('opp-->'+opp);
    //             update opp;
    //             //System.debug('opp-->'+opp);
    //         }
         
    // }
    
    
}
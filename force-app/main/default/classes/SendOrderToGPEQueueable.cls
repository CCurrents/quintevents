/**
 * @File Name          : SendOrderToGPEQueueable.cls
 * @Description        : To send order to GPE
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 11-09-2020
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    04/10/2020   kchavda@addonblue.com      Initial Version
 * 1.1    09/07/2020   kchavda@addonblue.com      #519 Xero Related Changes
 * 1.2    11/02/2020   kchavda@addonblue.com      #612 GPT Order - Add Phone to the request if the Contact in SF doesn't have Phone number
**/
public class SendOrderToGPEQueueable implements Queueable, Database.AllowsCallouts {

    Id orderId; 
    
     /**
    * @description Constructor
    * @author kchavda@addonblue.com | 04/10/2020
    * @param  Id 
    * @return
    **/       
    public SendOrderToGPEQueueable(Id oId) { 
        this.orderId = oId;        
    }  
    
     /**
    * @description Execute Method
    * @author kchavda@addonblue.com | 04/10/2020
    * @param  Id 
    * @return
    **/  
    public void execute(QueueableContext context) {
        try{
            System.debug('orderId-->'+orderId);
            // To retrieve Order Info
            Order objOrder = [Select Id,Pricebook2.GPT_Event_Id__c,BilltoContact.FirstName,BilltoContact.LastName,BilltoContact.Email,BilltoContact.Salutation,
                                ShippingCity,ShippingCountry,ShippingState,Shippingstreet,Shippingpostalcode,
                                BilltoContact.phone, (Select Id,Product2.GPT_Article_Id__c,Quantity from OrderItems), 
                                (Select id, xero_invoice_Id__c from Payment_Terms__r limit 1) from order where Id=: orderId];
            
            // To fil standard country states map                     
            Map<String, String> countryMap = new Map<String, String>();
            Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple){
              countryMap.put(f.getLabel(), f.getValue());
            }
            
            // To generate random string
            String randStr = '';
            final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
            while (randStr.length() < 10) {
               Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
               randStr += chars.substring(idx, idx+1);
            }
           
            JSONGenerator genJson = JSON.createGenerator(true);        
            genJson.writeStartObject();
                genJson.writeFieldName('articles');
                    genJson.writeStartArray();
                        for(OrderItem orderItem : objOrder.OrderItems){
                            if(orderItem.Product2.GPT_Article_Id__c != null){
                                genJson.writeStartObject();
                                genJson.writeObjectField('id',(orderItem.Product2.GPT_Article_Id__c != null ? orderItem.Product2.GPT_Article_Id__c : ''));
                                genJson.writeObjectField('qty',(orderItem.Quantity != null ? orderItem.Quantity.round(System.RoundingMode.UNNECESSARY) : 0));
                                genJson.writeEndObject();
                            }
                        }                    
                    genJson.writeEndArray();
                genJson.writeFieldName('customer');
                genJson.writeStartObject();                
                    genJson.writeObjectField('email',(objOrder.BilltoContact.Email != null ? objOrder.BilltoContact.Email : ''));
                    genJson.writeObjectField('first_name',(objOrder.BilltoContact.FirstName != null ? objOrder.BilltoContact.FirstName : ''));
                    genJson.writeObjectField('last_name',(objOrder.BilltoContact.LastName != null ? objOrder.BilltoContact.LastName : ''));
                    genJson.writeObjectField('salutation',(objOrder.BilltoContact.Salutation != null ? objOrder.BilltoContact.Salutation : 'None'));
                    genJson.writeObjectField('address',(objOrder.ShippingStreet != null ? objOrder.ShippingStreet : ''));
                    genJson.writeObjectField('zip',(objOrder.ShippingPostalCode != null ? objOrder.ShippingPostalCode : ''));
                    genJson.writeObjectField('city',(objOrder.ShippingCity != null ? objOrder.ShippingCity : ''));
                    genJson.writeObjectField('country',(countryMap.containsKey(objOrder.ShippingCountry) ? countryMap.get(objOrder.ShippingCountry) : ''));
                    genJson.writeObjectField('mobile',(objOrder.BilltoContact.phone != null ? objOrder.BilltoContact.phone : '0000000000'));
                genJson.writeEndObject();
                genJson.writeObjectField('paymeth','UEBERWEISUNG');
                genJson.writeObjectField('key', randStr);
                if(objOrder.Payment_Terms__r != null && objOrder.Payment_Terms__r[0].xero_invoice_Id__c != null){
                    genJson.writeObjectField('cust_invoice', objOrder.Payment_Terms__r[0].xero_invoice_Id__c);
                }
            genJson.writeEndObject();        
            String jsonString = genJson.getAsString();
            system.debug('jsonString-->'+jsonString);
            
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');        
            req.setEndpoint(Label.GPE_Endpoint+objOrder.Pricebook2.GPT_Event_Id__c);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Cache-Control', 'no-cache');
            req.setHeader('Accept', '*/*');
            req.setHeader('Authorization', 'Bearer Qe1v0yrj9XTDwJHkWNF3Mu2lLQzlvz6swblTQJleHHncpMdqL7v6S3bmzAxu');        
            req.setBody(jsonString);
            String stringResponce;
            String code;
            Http http = new Http();
            if(!Test.isRunningTest()){
                HttpResponse res = http.send(req);
                stringResponce = res.getBody();
                code = string.valueof(res.getStatusCode());
            }
            else{
                stringResponce = '{"success": false,"message": "WRONG_ARTICLE"}';
            }
            
            System.debug('stringResponce-->'+stringResponce);
            RequestResponse_Log__c  objReqRes = XeroCallout.reqResLog('SendOrderToGPEQueueable','execute',Label.GPE_Endpoint+objOrder.Pricebook2.GPT_Event_Id__c,jsonString,stringResponce,code,objOrder.id,null);
            String[] str1 = stringResponce.split(':');
            String[] str2 = str1[1].split(',');
            str1[2] = str1[2].replace('"','');
            str1[2] = str1[2].replace('}','');
            
            if(str2[0] == 'true' ){
                Order order = new Order();
                order.Id = objOrder.Id;
                order.GPT_Booking_Id__c = str1[2];                
                System.debug('order-->'+order);
                utility.processRecords(order,'update');            
                System.debug('order-->'+order);
            }
            utility.processRecords(objReqRes,'insert');   
        }
        catch(exception ex){
            System.debug('Exception :'+ex.getlinenumber()+'--'+ex.getmessage());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
}
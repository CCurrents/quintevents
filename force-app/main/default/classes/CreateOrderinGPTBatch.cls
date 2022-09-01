/**
 * @File Name          : CreateOrderinGPTBatch.cls
 * @Description        : To create order in GPT
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 02/25/2021
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    11/05/2020   kchavda@addonblue.com      Initial Version 
 * 1.1    02/25/2021   kchavda@addonblue.com     #823 Duplicate GPT Order
 * 1.2    05/27/2021   kchavda@addonblue.com     #976 Orders being sent to GPT multiple times
**/
public class CreateOrderinGPTBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{ 
   
    string query;
    set<Id> orderIds = new set<id>();
    /**
    * @description Constructor
    * @author kchavda@addonblue.com | 11/05/2020
    * @param  set<Id>
    * @return
    **/        
    public CreateOrderinGPTBatch(string strquery,Set<id> setOrderIds){
        this.query = strquery;        
        this.orderIds = setOrderIds;
    }
    
   
     /**
    * @description Start method
    * @author kchavda@addonblue.com | 11/05/2020
    * @param  Database.BatchableContext
    * @return Database.QueryLocator
    **/  
    public Database.QueryLocator start(Database.BatchableContext BC){                
        return Database.getQueryLocator(query);
    }
    
    /**
    * @description Execute method
    * @author kchavda@addonblue.com | 11/05/2020
    * @param  Database.BatchableContext, List<sObject>
    * @return void
    **/  
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        
            if(!Scope.isempty()){               
               // To retrieve Order Info
                Order objOrder = [Select Id,GPT_Response__c,Pricebook2.GPT_Event_Id__c,BilltoContact.FirstName,BilltoContact.LastName,BilltoContact.Email,BilltoContact.Salutation,
                                    ShippingCity,ShippingCountry,ShippingState,Shippingstreet,Shippingpostalcode,GPT_Booking_Id__c,Sent_to_GPT__c,
                                    BilltoContact.phone, (Select Id,Product2.GPT_Article_Id__c,Quantity from OrderItems),xero_invoice_Id__c  
                                    from order where Id=: Scope[0].id];
                try{
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
                    if(string.isempty(objOrder.GPT_Response__c)){
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
                                genJson.writeObjectField('zip',(objOrder.ShippingPostalCode != null ? objOrder.ShippingPostalCode : '000000'));
                                genJson.writeObjectField('city',(objOrder.ShippingCity != null ? objOrder.ShippingCity : ''));
                                genJson.writeObjectField('country',(countryMap.containsKey(objOrder.ShippingCountry) ? countryMap.get(objOrder.ShippingCountry) : ''));
                                genJson.writeObjectField('mobile',(objOrder.BilltoContact.phone != null ? objOrder.BilltoContact.phone : '0000000000'));
                            genJson.writeEndObject();
                            genJson.writeObjectField('paymeth','UEBERWEISUNG');
                            genJson.writeObjectField('key', randStr);
                            if(objOrder.xero_invoice_Id__c != null){
                                genJson.writeObjectField('cust_invoice', objOrder.xero_invoice_Id__c);
                            }
                        genJson.writeEndObject();        
                        String jsonString = genJson.getAsString();
                        system.debug('jsonString-->'+jsonString);
                        
                        HttpRequest req = new HttpRequest();
                        req.setTimeout(120000);
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
                        objOrder.GPT_Response__c = stringResponce;
                        System.debug('stringResponce-->'+stringResponce);
                        RequestResponse_Log__c  objReqRes = XeroCallout.reqResLog('SendOrderToGPEQueueable','execute',Label.GPE_Endpoint+objOrder.Pricebook2.GPT_Event_Id__c,jsonString,stringResponce,code,objOrder.id,null);
                        String[] str1 = stringResponce.split(':');
                        String[] str2 = str1[1].split(',');
                        str1[2] = str1[2].replace('"','');
                        str1[2] = str1[2].replace('}','');
                        
                        if(str2[0] == 'true' ){                    
                            objOrder.GPT_Booking_Id__c = str1[2]; 
                        }
                        //objOrder.Sent_to_GPT__c = true;
                        TriggerHandler.bypass('OrderTriggerHandler');
                        utility.processRecords(objOrder,'update');   
                        TriggerHandler.clearBypass('OrderTriggerHandler');         
                        System.debug('order-->'+objOrder);
                        utility.processRecords(objReqRes,'insert');    
                } 
            } 
            catch(exception ex){                
                System.debug('Exception :'+ex.getlinenumber()+'--'+ex.getmessage());
                Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            }                           
        }        
       
    }
    
    /**
    * @description Finish method
    * @author kchavda@addonblue.com | 11/05/2020
    * @param  Database.BatchableContext
    * @return void
    **/  
    public void finish(Database.BatchableContext BC){       
    }
}
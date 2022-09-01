/**
 * @File Name          : GPEOnlineSalesTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 07-13-2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    5/8/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
public class GPEOnlineSalesTest {
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        TestDataFactory.createSFDCIntacctMapping();
    }
    @isTest
    static void testHttpPost() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/gpeonlinesaleV2'; 
        req.httpMethod = 'POST';
        Product2 objProd =TestDataFactory.createProduct();
        objProd.Price__c = 120;
        objProd.CurrencyIsoCode = 'USD';
        objProd.Primary_Price_Book__c = Test.getStandardPricebookId();
        update objProd;
        Pricebook2 pb = new pricebook2(id=Test.getStandardPricebookId());
        pb.GPT_Event_Id__c = '4542';
        pb.GPE_Event__c = true;
        pb.CurrencyIsoCode = 'USD';
        update pb;        
        String postData = '{"gpesale":{"GPE_ Order_Id": "2020","city" : "Ahmedabad","country" : "United States of America","currencyCharged" : "USD","email" : "gpelpanchal115@addonblue.com","fees" : {"order_processing_fee" : "20.0","shipping_fee" : "10.0"},"firstName" : "L1","gpeEventName" : "","gptBookingId" : "LP-3845-55458","lastName" : "Panchal1","lineItems" : [{"GPTEventId" : "4542","Name" : "IPL Motera1","articleid" : "12341","price" : "115.25","quantity" : 2}],"phone" : "2063911839","state" : "Washington","street" : "17632 157th Ave SE","total" : "239.50","zip" : "98058"}}';
        String JsonMsg = postData;
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        GPEOnlineSales.create();
        GPEOnlineSales objctrl = new GPEOnlineSales();
        objctrl.ResponseMessage = new List<OnlineSalesHelper.ResponseMessage>();
        OnlineSalesHelper.insertedProductMap = new Map<Id,Product2>();
        Map<String, Decimal> product2PriceMap = new Map<String, Decimal>();
        List<Product2> productList = new List<Product2>();
        OnlineSalesHelper.getPricebookEntries('USD',product2PriceMap,productList,new Map<String, String>());
        Test.stopTest();
    }
    
    @isTest
    static void testHttpPost1() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/gpeonlinesaleV2'; 
        req.httpMethod = 'POST';
        Product2 objProd =TestDataFactory.createProduct();
        objProd.Price__c = 120;
        objProd.CurrencyIsoCode = 'USD';
        objProd.Primary_Price_Book__c = Test.getStandardPricebookId();
        update objProd;
        Pricebook2 pb = new pricebook2(id=Test.getStandardPricebookId());
        pb.GPT_Event_Id__c = '4542';
        pb.GPE_Event__c = true;
        pb.CurrencyIsoCode = 'USD';
        update pb;
        Contact con = TestDataFactory.createContact();
        con.email = 'gpelpanchal115@addonblue.com';
        update con;
        String postData = '{"gpesale":{"GPE_ Order_Id": "2020","city" : "Ahmedabad","country" : "United States of America","currencyCharged" : "USD","email" : "gpelpanchal115@addonblue.com","fees" : {"order_processing_fee" : "20.0","shipping_fee" : "10.0"},"firstName" : "L1","gpeEventName" : "","gptBookingId" : "LP-3845-55458","lastName" : "Panchal1","lineItems" : [{"GPTEventId" : "4542","Name" : "IPL Motera1","articleid" : "","price" : "115.25","quantity" : 2}],"phone" : "2063911839","state" : "Washington","street" : "17632 157th Ave SE","total" : "239.50","zip" : "98058"}}';
        String JsonMsg = postData;
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        GPEOnlineSales.create();     

        Test.stopTest();
    }
    
    
    @isTest
    static void testHttpPost3() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/gpeonlinesaleV2'; 
        req.httpMethod = 'POST';
        Product2 objProd =TestDataFactory.createProduct();
        objProd.Price__c = 120;
        objProd.CurrencyIsoCode = 'USD';
        objProd.Primary_Price_Book__c = Test.getStandardPricebookId();
        update objProd;
        Pricebook2 pb = new pricebook2(id=Test.getStandardPricebookId());
        pb.GPT_Event_Id__c = '4542';
        pb.GPE_Event__c = true;
        pb.CurrencyIsoCode = 'USD';
        update pb;
        Lead led  = TestDataFactory.createLead();
        led.email = 'gpelpanchal115@addonblue.com';
        update led;
        String postData = '{"gpesale":{"GPE_ Order_Id": "2020","city" : "Ahmedabad","country" : "United States of America","currencyCharged" : "USD","email" : "gpelpanchal115@addonblue.com","fees" : {"order_processing_fee" : "20.0","shipping_fee" : "10.0"},"firstName" : "L1","gpeEventName" : "","gptBookingId" : "LP-3845-55458","lastName" : "Panchal1","lineItems" : [{"GPTEventId" : "4542","Name" : "IPL Motera1","articleid" : "12341","price" : "115.25","quantity" : 2}],"phone" : "2063911839","state" : "Washington","street" : "17632 157th Ave SE","total" : "239.50","zip" : "98058"}}';
        String JsonMsg = postData;
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        GPEOnlineSales.create();
        OnlineSalesHelper.ResponseMessage resmes = new OnlineSalesHelper.ResponseMessage('', new opportunity(), new List<OpportunityLineItem>(), new List<Product2>(), new Set<GPE_ApexToJsonClass.LineItems>());
        OnlineSalesHelper.ResponseMessage resmes1 = new OnlineSalesHelper.ResponseMessage('', new quote(), new List<QuoteLineItem>(), new List<Product2>(), new Set<GPE_ApexToJsonClass.LineItems>());
        Test.stopTest();
    }
    
    @isTest
    static void testHttpPost4() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/gpeonlinesaleV2'; 
        req.httpMethod = 'POST';        
        Pricebook2 pb = new pricebook2(id=Test.getStandardPricebookId());
        pb.GPT_Event_Id__c = '4542';
        pb.GPE_Event__c = true;
        pb.CurrencyIsoCode = 'USD';
        update pb;
        Contact con = TestDataFactory.createContact();
        con.email = 'gpelpanchal115@addonblue.com';
        con.accountid=null;
        update con;
        String postData = '{"gpesale":{"GPE_ Order_Id": "2020","city" : "Ahmedabad","country" : "United States of America","currencyCharged" : "USD","email" : "gpelpanchal115@addonblue.com","fees" : {"order_processing_fee" : "20.0","shipping_fee" : "10.0"},"firstName" : "L1","gpeEventName" : "","gptBookingId" : "LP-3845-55458","lastName" : "Panchal1","lineItems" : [{"GPTEventId" : "4542","Name" : "IPL Motera1","articleid" : "","price" : "115.25","quantity" : 2}],"phone" : "2063911839","state" : "Washington","street" : "17632 157th Ave SE","total" : "239.50","zip" : "98058"}}';
        String JsonMsg = postData;
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        GPEOnlineSales.create();
        Test.stopTest();
    }
}
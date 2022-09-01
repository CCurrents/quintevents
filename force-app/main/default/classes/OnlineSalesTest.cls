/**
 * @File Name          : OnlineSalesTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 6/24/2020, 12:25:32 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    5/8/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
public class OnlineSalesTest {
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        TestDataFactory.createSFDCIntacctMapping();
    } 
    @isTest
    static void testHttpPost() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/OnlineSalesold'; 
        req.httpMethod = 'POST';
        Product2 objProd =TestDataFactory.createProduct();
        objProd.Price__c = 120;
        objProd.CurrencyIsoCode = 'USD';
        objProd.Primary_Price_Book__c = Test.getStandardPricebookId();
        update objProd;
        String postData = '{"sale": {"city": "Bordeaux","country": "France","currencyCharged": "USD","total": 100,"discount": 0,"paymentTerms" : "1/3","email": "benowon@hotmail.com","eventId": "'+Test.getStandardPricebookId()+'","firstName": "Joseph","googleAnalyticsId": "","googleAnalyticsSiteId": "","lastName": "Owona","lineItems": [{"packageId": "01tm0000004jUKgAAM","packagePrice": "4141.00","packageQty": 1,"hotelId": "01t1Y00000ARQqnQAH","hotelPrice": "4601.00","hotelQty": 1,"includeTransportation": false}],"phone": "0033663912608","promoterId": null,"resellerId": null,"site": "nbapremium.com","state": "Gironde","street": "13 rue lagraveyre","totalAfterDiscount": "452.60","totalChargedInCurrency": "452.60","visitorCountry": null,"zip": "963852"}}';
        
        String JsonMsg = postData;
        req.requestBody = Blob.valueof(postData);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        OnlineSales.create();
        OnlineSalesHelper.insertedProductMap = new Map<Id,Product2>();
        Test.stopTest();
    }
    
    @isTest
    static void testHttpPost1() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/OnlineSalesold'; 
        req.httpMethod = 'POST';
        Product2 objProd =TestDataFactory.createProduct();
        
        String postData = '{"sale": {"city": "Bordeaux","country": "France","currencyCharged": "USD","total": 100,"discount": 0,"paymentTerms" : "1/3","email": "benowon@hotmail.com","eventId": "01si0000002KOY1AAO","firstName": "Joseph","googleAnalyticsId": "","googleAnalyticsSiteId": "","lastName": "Owona","lineItems": [{"packageId": "01tm0000004jUKgAAM","packagePrice": "4141.00","packageQty": 1,"hotelId": "01t1Y00000ARQqnQAH","hotelPrice": "4601.00","hotelQty": 1,"includeTransportation": false}],"phone": "0033663912608","promoterId": null,"resellerId": null,"site": "nbapremium.com","state": "Gironde","street": "13 rue lagraveyre","totalAfterDiscount": "452.60","totalChargedInCurrency": "452.60","visitorCountry": null,"zip": "963852"}}';
        
        String JsonMsg = postData;
        req.requestBody = Blob.valueof(postData);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        OnlineSales.create();
        Test.stopTest();
    }
    
     @isTest
    static void testHttpPost2() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/OnlineSalesold'; 
        req.httpMethod = 'POST';
        Product2 objProd =TestDataFactory.createProduct();
        objProd.Price__c = 120;
        objProd.CurrencyIsoCode = 'USD';
        objProd.Primary_Price_Book__c = Test.getStandardPricebookId();
        update objProd;
        Contact objCon = TestDataFactory.createContact();
        String postData = '{"sale": {"city": "Bordeaux","country": "France","currencyCharged": "USD","total": 100,"discount": 0,"paymentTerms" : "1/3","email": "'+objCon.Email+'","eventId": "'+Test.getStandardPricebookId()+'","firstName": "Joseph","googleAnalyticsId": "","googleAnalyticsSiteId": "","lastName": "Owona","lineItems": [{"packageId": "01tm0000004jUKgAAM","packagePrice": "4141.00","packageQty": 1,"hotelId": "01t1Y00000ARQqnQAH","hotelPrice": "4601.00","hotelQty": 1,"includeTransportation": false}],"phone": "0033663912608","promoterId": null,"resellerId": null,"site": "nbapremium.com","state": "Gironde","street": "13 rue lagraveyre","totalAfterDiscount": "452.60","totalChargedInCurrency": "452.60","visitorCountry": null,"zip": "963852"}}';
        
        String JsonMsg = postData;
        req.requestBody = Blob.valueof(postData);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        OnlineSales.create();
        OnlineSalesHelper.insertedProductMap = new Map<Id,Product2>();
        Test.stopTest();
    }
    
    @isTest
    static void testHttpPost3() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/OnlineSalesold'; 
        req.httpMethod = 'POST';
        Product2 objProd =TestDataFactory.createProduct();
        objProd.Price__c = 120;
        objProd.CurrencyIsoCode = 'USD';
        objProd.Primary_Price_Book__c = Test.getStandardPricebookId();
        update objProd;
        Lead objlead = TestDataFactory.createLead();
        String postData = '{"sale": {"city": "Bordeaux","country": "France","currencyCharged": "USD","total": 100,"discount": 0,"paymentTerms" : "1/3","email": "'+objlead.Email+'","eventId": "'+Test.getStandardPricebookId()+'","firstName": "Joseph","googleAnalyticsId": "","googleAnalyticsSiteId": "","lastName": "Owona","lineItems": [{"packageId": "01tm0000004jUKgAAM","packagePrice": "4141.00","packageQty": 1,"hotelId": "01t1Y00000ARQqnQAH","hotelPrice": "4601.00","hotelQty": 1,"includeTransportation": false}],"phone": "0033663912608","promoterId": null,"resellerId": null,"site": "nbapremium.com","state": "Gironde","street": "13 rue lagraveyre","totalAfterDiscount": "452.60","totalChargedInCurrency": "452.60","visitorCountry": null,"zip": "963852"}}';
        
        String JsonMsg = postData;
        req.requestBody = Blob.valueof(postData);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        OnlineSales.create();
        OnlineSalesHelper.insertedProductMap = new Map<Id,Product2>();
        Test.stopTest();
    }
    @isTest
    static void testHttpPost4() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/OnlineSalesold'; 
        req.httpMethod = 'POST';
        Product2 objProd =TestDataFactory.createProduct();
        objProd.Price__c = 120;
        objProd.CurrencyIsoCode = 'USD';
        objProd.GPT_Article_Id__c = '2344';
        System.debug('Test.getStandardPricebookId()@@'+Test.getStandardPricebookId());
        objProd.Primary_Price_Book__c = Test.getStandardPricebookId();
        update objProd;
        System.debug('objProd@@'+objProd.Id);
        Contact objCon = TestDataFactory.createContact();
        String postData = '{"sale": {"city": "Bordeaux","country": "France","currencyCharged": "USD","total": 100,"discount": 0,"paymentTerms" : "1/3","email": "'+objCon.Email+'","eventId": "'+Test.getStandardPricebookId()+'","firstName": "Joseph","googleAnalyticsId": "","googleAnalyticsSiteId": "","lastName": "Owona","lineItems": [{"packageId": "'+objProd.Id+'","packagePrice": "4141.00","packageQty": 1,"hotelId": "01t1Y00000ARQqnQAH","hotelPrice": "4601.00","hotelQty": 1,"includeTransportation": false}],"phone": "0033663912608","promoterId": null,"resellerId": null,"site": "nbapremium.com","state": "Gironde","street": "13 rue lagraveyre","totalAfterDiscount": "452.60","totalChargedInCurrency": "452.60","visitorCountry": null,"zip": "963852"}}';
        
        String JsonMsg = postData;
        req.requestBody = Blob.valueof(postData);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        OnlineSales.create();
        OnlineSalesHelper.insertedProductMap = new Map<Id,Product2>();
        Test.stopTest();
        
        DatedConversionRateHelper obj = new DatedConversionRateHelper();
        obj.convert(14,'USD');
        obj.convertforQuote(15,'USD',System.Today());
        obj.convertCurrencyFromIsoToIso(15,'USD','EUR');
        obj.convertCurrencyToUSD(990, 'EUR', 1);
        //List<CurrencyType> currencyList = OnlineSalesHelper.currencyList;
        //List<DatedConversionRate> DatedConversionRateList = OnlineSalesHelper.DatedConversionRateList;
        OnlineSalesHelper.createPricebookBaseOpportunity(null,null,null,null,null);
        Map<String, Decimal> product2PriceMap = new Map<String, Decimal>();
        product2PriceMap.put('2344', 45);
        OnlineSalesHelper.getPricebookEntries('USD', product2PriceMap, new List<Product2>{objProd},new map<string,string>());
        OnlineSalesHelper.crtQuote(null,null,null,null);
    }
    
    @isTest
    static void testHttpPost5() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/OnlineSalesold'; 
        req.httpMethod = 'POST';
        Product2 objProd =TestDataFactory.createProduct();
        objProd.Price__c = 120;
        objProd.CurrencyIsoCode = 'USD';
        objProd.GPT_Article_Id__c = '2344';
        System.debug('Test.getStandardPricebookId()@@'+Test.getStandardPricebookId());
        objProd.Primary_Price_Book__c = Test.getStandardPricebookId();
        update objProd;
        System.debug('objProd@@'+objProd.Id);
        Contact objCon = TestDataFactory.createContact();
        String postData = '{"sale": {}}';
        
        String JsonMsg = postData;
        req.requestBody = Blob.valueof(postData);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        OnlineSales.create();
        OnlineSalesHelper.insertedProductMap = new Map<Id,Product2>();
        Test.stopTest();
        
        DatedConversionRateHelper obj = new DatedConversionRateHelper();
        obj.convert(14,'USD');
        obj.convertforQuote(15,'USD',System.Today());
        obj.convertCurrencyFromIsoToIso(15,'USD','EUR');
        obj.convertCurrencyToUSD(990, 'EUR', 1);
        //List<CurrencyType> currencyList = OnlineSalesHelper.currencyList;
        //List<DatedConversionRate> DatedConversionRateList = OnlineSalesHelper.DatedConversionRateList;
        OnlineSalesHelper.createPricebookBaseOpportunity(null,null,null,null,null);
        Map<String, Decimal> product2PriceMap = new Map<String, Decimal>();
        product2PriceMap.put('2344', 45);
        OnlineSalesHelper.getPricebookEntries('USD', product2PriceMap, new List<Product2>{objProd},new map<string,string>());
        OnlineSalesHelper.crtQuote(null,null,null,null);
    }
}
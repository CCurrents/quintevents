/**
 * @File Name          : QNGOnlineSaleCtrlTest.cls
 * @Description        : 
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 02-17-2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    20/6/2020   fsuraitawala@addonblue.com    Initial Version
**/
@isTest 
public with sharing class QNGOnlineSaleCtrlTest {
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        
        //******* Pricebook *******//
        Pricebook2 testPricebook = TestDataFactory.createPricebook();
        
        //******* Parent Package *******//
        List<Parent_Package__c> lstParentPackage = TestDataFactory.createParentPackage(1, true, testPricebook.Id);
        
        //******* Product *******//
        List<Product2> lstProduct = new List<Product2>();
        Product2 objProduct = TestDataFactory.createProduct('Test Package Product', 'Package', 'Package', lstParentPackage[0].Id, testPricebook.Id);
        lstProduct.add(objProduct);
        
        Product2 objProduct1 = TestDataFactory.createProduct('Test Product', 'Product', 'Transportation', null, testPricebook.Id);
        lstProduct.add(objProduct1);
        
        Product2 objProduct2 = TestDataFactory.createProduct('Test Hotel', 'Hotel', 'Hospitality', null, testPricebook.Id);
        lstProduct.add(objProduct2);
        
        Product2 objProduct3 = TestDataFactory.createProduct('Test Hotel Stay', 'Hotel Stay', 'Stay', null, testPricebook.Id);
        lstProduct.add(objProduct3);
        
        lstProduct = Utility.processRecords(lstProduct, 'insert');
        
        //******* Products_Bundle__c *******//
        List<Products_Bundle__c> lstBundle = new List<Products_Bundle__c>();
        
        Products_Bundle__c objBundle = TestDataFactory.createProductBundle(lstProduct[1].Id, lstProduct[0].Id, 'Package Product');
        lstBundle.add(objBundle);
        
        Products_Bundle__c objBundle1 = TestDataFactory.createProductBundle(lstProduct[1].Id, lstProduct[2].Id, 'Hotel Transportation');
        lstBundle.add(objBundle1);
        
        Products_Bundle__c objBundle2 = TestDataFactory.createProductBundle(lstProduct[3].Id, lstProduct[2].Id, 'Hotel Stay');
        lstBundle.add(objBundle2);
        
        lstBundle= Utility.processRecords(lstBundle, 'insert');
    }
    @isTest static void test1(){
        
        List<Product2> lstProduct = [Select Id, Primary_Price_Book__c From Product2 where Auto_Generated_Product__c = false order by createddate asc];
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Quote');                
        triggerSetting.Max_Loop_Count__c = 2;
        update triggerSetting;
        Trigger_Settings__c triggerSetting1 = Trigger_Settings__c.getInstance('Product2');                
        triggerSetting1.Deactivate__c = true;
        update triggerSetting1;
        //******* REST API Call *******//
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/qngOnlineSales'; 
        req.httpMethod = 'POST';
        String postData = '{ "sale": { "totalAfterDiscount": 40, "totalChargedInCurrency": 50, "discount": 10, "discountCode": "DISC10", "resellerId": "", "promoterId": "", "eventId": "'+lstProduct[0].Primary_Price_Book__c+'", "city": "Charlotte", "country": "United States of America", "currencyCharged": "USD", "email": "ja56744448@addonblue.com", "firstName": "QNG1 Lovel DEMO 123", "googleAnalyticsId": "", "googleAnalyticsSiteId": "", "lastName": "QNG1 DEMO", "phone": "0124578963", "purchaseOrderNumber": "PO123", "site": "breederscupexperiences.com", "state": "North Carolina", "street": "Street1", "protectGroupAmount":"100.00", "visitorCountry": "United States of America", "protectGroupId":"rp_post_n_633d5ddd-31b1-4554-9f2d-ebfca7f36ab0a", "zip": "12458", "paymentTerms": "100%", "h4hPointsSpent": "", "isRewardApplied": false, "company_name": "TestOnlineSaleName", "h4hRewardPercentage": 5, "api": false, "lineItems": [ { "packageId": "'+lstProduct[0].Id+'", "packageQty": 2, "packagePrice": 150, "includeTransportation": true, "Stays": [ { "stayid": "'+lstProduct[3].Id+'", "stayPrice": 350, "stayQty": 2, "qngRoomingListId": "QNG1245" } ] } ], "retailHotelLineItems": [ { "HotelId": "'+lstProduct[2].Id+'", "HotelName": "Four", "ReservationId": "123413445", "ItineraryId": "BKK1313", "CheckInDate": "08/02/2020", "CheckOutDate": "08/12/2020", "ReservationTotalPrice": 2000, "RoomCode": "123", "RoomQuantity": 2 } ] } }';
        String JsonMsg = postData;
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        QNG_JSON2Apex objSal = (QNG_JSON2Apex) JSON.deserialize(postData, QNG_JSON2Apex.class);
        QNG_JSON2Apex.Sale objSale = objSal.Sale;
        List<Pricebook2> lstPricebook = [Select Id,Name, GPE_Event__c, GPT_Event_Id__c from Pricebook2 where Id =: objSale.eventId];
        Test.startTest();
        //QNGOnlineSaleCtrl.create();
        objSale.email= 'lovelpggggddddancha123@gmail.com';
        QNGOnlineSaleCtrl.createLead(objSale,lstPricebook);
        Test.stopTest();
    }
    
    @isTest static void test2(){
        
        List<Product2> lstProduct = [Select Id, Primary_Price_Book__c From Product2 where Auto_Generated_Product__c = false order by createddate asc];
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Quote');                
        triggerSetting.Max_Loop_Count__c = 2;
        update triggerSetting;
        // create Account
        Account acc = TestDataFactory.createAccount();
        
        // Create Contact
        Contact con = TestDataFactory.createContact(acc.Id);
        
        //******* REST API Call *******//
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/qngOnlineSales'; 
        req.httpMethod = 'POST';
        String postData = '{ "sale": { "totalAfterDiscount": 40, "totalChargedInCurrency": 50, "discount": 10, "discountCode": "DISC10", "resellerId": "", "promoterId": "", "eventId": "'+lstProduct[0].Primary_Price_Book__c+'", "city": "Charlotte", "country": "United States of America", "currencyCharged": "USD", "email": "'+con.Email+'", "firstName": "QNG1 Lovel DEMO 123", "googleAnalyticsId": "", "googleAnalyticsSiteId": "", "lastName": "QNG1 DEMO", "phone": "0124578963", "purchaseOrderNumber": "PO123", "site": "breederscupexperiences.com", "state": "North Carolina", "street": "Street1", "visitorCountry": "United States of America", "protectGroupAmount":"100.00", "protectGroupId":"rp_post_n_633d5ddd-31b1-4554-9f2d-ebfca7f36ab0a", "zip": "12458", "paymentTerms": "100%", "h4hPointsSpent": "", "isRewardApplied": false, "company_name": "TestOnlineSaleName", "h4hRewardPercentage": 5, "api": false, "lineItems": [ { "packageId": "'+lstProduct[0].Id+'", "packageQty": 2, "packagePrice": 150, "includeTransportation": true, "Stays": [ { "stayid": "'+lstProduct[3].Id+'", "stayPrice": 350, "stayQty": 2, "qngRoomingListId": "QNG1245" } ] } ], "retailHotelLineItems": [ { "HotelId": "'+lstProduct[2].Id+'", "HotelName": "Four", "ReservationId": "123413445", "ItineraryId": "BKK1313", "CheckInDate": "08/02/2020", "CheckOutDate": "08/12/2020", "ReservationTotalPrice": 2000, "RoomCode": "123", "RoomQuantity": 2 } ] } }';
        String JsonMsg = postData;
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        QNG_JSON2Apex objSal = (QNG_JSON2Apex) JSON.deserialize(postData, QNG_JSON2Apex.class);
        QNG_JSON2Apex.Sale objSale = objSal.Sale;
        
        Test.startTest();
        QNGOnlineSaleCtrl.create();
        Test.stopTest();
    }
    
    @isTest static void test3(){
        
        List<Product2> lstProduct = [Select Id, Primary_Price_Book__c From Product2 where Auto_Generated_Product__c = false order by createddate asc];
        Lead objLead = TestDataFactory.createLead();
        
        //******* REST API Call *******//
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/qngOnlineSales'; 
        req.httpMethod = 'POST';
        String postData = '{ "sale": { "totalAfterDiscount": 40, "totalChargedInCurrency": 50, "discount": 10, "discountCode": "DISC10", "resellerId": "", "promoterId": "", "eventId": "'+ lstProduct[0].Primary_Price_Book__c +'", "city": "Charlotte", "country": "United States of America", "currencyCharged": "USD", "email": "'+objLead.Email+'", "firstName": "QNG1 Lovel DEMO 123", "googleAnalyticsId": "", "googleAnalyticsSiteId": "", "lastName": "QNG1 DEMO", "phone": "0124578963", "purchaseOrderNumber": "PO123", "site": "breederscupexperiences.com", "state": "North Carolina", "street": "Street1", "visitorCountry": "United States of America", "protectGroupAmount":"100.00", "protectGroupId":"rp_post_n_633d5ddd-31b1-4554-9f2d-ebfca7f36ab0a", "zip": "12458", "paymentTerms": "100%", "h4hPointsSpent": "", "isRewardApplied": false, "company_name": "TestOnlineSaleName", "h4hRewardPercentage": 5, "api": false, "lineItems": [ { "packageId": "'+lstProduct[0].Id+'", "packageQty": 2, "packagePrice": 150, "includeTransportation": true, "Stays": [ { "stayid": "'+lstProduct[3].Id+'", "stayPrice": 350, "stayQty": 2, "qngRoomingListId": "QNG1245" } ] } ], "retailHotelLineItems": [ { "HotelId": "'+lstProduct[2].Id+'", "HotelName": "Four", "ReservationId": "123413445", "ItineraryId": "BKK1313", "CheckInDate": "08/02/2020", "CheckOutDate": "08/12/2020", "ReservationTotalPrice": 2000, "RoomCode": "123", "RoomQuantity": 2 } ] } }';
        String JsonMsg = postData;
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        QNG_JSON2Apex objSal = (QNG_JSON2Apex) JSON.deserialize(postData, QNG_JSON2Apex.class);
        QNG_JSON2Apex.Sale objSale = objSal.Sale;
        
        Test.startTest();
        QNGOnlineSaleCtrl.create();
        Test.stopTest();
    }
    @isTest static void test4(){
        
        List<Product2> lstProduct = [Select Id, Primary_Price_Book__c From Product2 where Auto_Generated_Product__c = false order by createddate asc];
        // create Account
        Account acc = TestDataFactory.createAccount();
        
        // Create Contact
        Contact con = TestDataFactory.createContact(acc.Id);
        
        //******* REST API Call *******//
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/qngOnlineSales'; 
        req.httpMethod = 'POST';
        String postData = '{ "sale": { "totalAfterDiscount": 40, "totalChargedInCurrency": 50, "discount": 10, "discountCode": "DISC10", "resellerId": "", "promoterId": "", "eventId": "'+lstProduct[0].Primary_Price_Book__c+'", "city": "Charlotte", "country": "United States of America", "currencyCharged": "USD", "email": "'+con.Email+'", "firstName": "QNG1 Lovel DEMO 123", "googleAnalyticsId": "", "googleAnalyticsSiteId": "", "lastName": "QNG1 DEMO", "phone": "0124578963", "purchaseOrderNumber": "PO123", "site": "breederscupexperiences.com", "state": "North Carolina", "street": "Street1", "visitorCountry": "United States of America", "protectGroupAmount":"100.00", "protectGroupId":"rp_post_n_633d5ddd-31b1-4554-9f2d-ebfca7f36ab0a", "zip": "12458", "paymentTerms": "100%", "h4hPointsSpent": "", "isRewardApplied": false, "company_name": "TestOnlineSaleName", "h4hRewardPercentage": 5, "api": false, "lineItems": [ { "packageId": "'+lstProduct[0].Id+'", "packageQty": 2, "packagePrice": 150, "includeTransportation": true, "Stays": [ { "stayid": "'+lstProduct[3].Id+'", "stayPrice": 350, "stayQty": 2, "qngRoomingListId": "QNG1245" } ] } ], "retailHotelLineItems": [ { "HotelId": "'+lstProduct[2].Id+'", "HotelName": "Four", "ReservationId": "123413445", "ItineraryId": "BKK1313", "CheckInDate": "08/02/2020", "CheckOutDate": "08/12/2020", "ReservationTotalPrice": 2000, "RoomCode": "123", "RoomQuantity": 2 } ] } }';
        String JsonMsg = postData;
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        QNG_JSON2Apex objSal = (QNG_JSON2Apex) JSON.deserialize(postData, QNG_JSON2Apex.class);
        QNG_JSON2Apex.Sale objSale = objSal.Sale;
        
        Test.startTest();
        QNGOnlineSaleCtrl.create();
        Test.stopTest();
    }
    
    @isTest static void test5(){
        
        List<Product2> lstProduct = [Select Id, Primary_Price_Book__c From Product2 where Auto_Generated_Product__c = false order by createddate asc];
        // create Account
        Account acc = TestDataFactory.createAccount();
        
        // Create Contact
        Contact con = TestDataFactory.createContact(acc.Id);
        
        //Create Quote
        Quote quote = TestDataFactory.createQuote();
        
        //******* REST API Call *******//
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/qngOnlineSales'; 
        req.httpMethod = 'POST';
        String postData = '{ "sale": { "quoteId": "'+quote.Id+'", "totalAfterDiscount": 40, "totalChargedInCurrency": 50, "discount": 10, "discountCode": "DISC10", "resellerId": "", "promoterId": "", "eventId": "'+lstProduct[0].Primary_Price_Book__c+'", "city": "Charlotte", "country": "United States of America", "currencyCharged": "USD", "email": "'+con.Email+'", "firstName": "QNG1 Lovel DEMO 123", "googleAnalyticsId": "", "googleAnalyticsSiteId": "", "lastName": "QNG1 DEMO", "phone": "0124578963", "purchaseOrderNumber": "PO123", "site": "breederscupexperiences.com", "state": "North Carolina", "street": "Street1", "visitorCountry": "United States of America", "protectGroupAmount":"100.00", "protectGroupId":"rp_post_n_633d5ddd-31b1-4554-9f2d-ebfca7f36ab0a", "zip": "12458", "paymentTerms": "100%", "h4hPointsSpent": "", "isRewardApplied": false, "company_name": "TestOnlineSaleName", "h4hRewardPercentage": 5, "api": false, "lineItems": [ { "packageId": "'+lstProduct[0].Id+'", "packageQty": 2, "packagePrice": 150, "includeTransportation": true, "Stays": [ { "stayid": "'+lstProduct[3].Id+'", "stayPrice": 350, "stayQty": 2, "qngRoomingListId": "QNG1245" } ] } ], "retailHotelLineItems": [ { "HotelId": "'+lstProduct[2].Id+'", "HotelName": "Four", "ReservationId": "123413445", "ItineraryId": "BKK1313", "CheckInDate": "08/02/2020", "CheckOutDate": "08/12/2020", "ReservationTotalPrice": 2000, "RoomCode": "123", "RoomQuantity": 2 } ] } }';
        String JsonMsg = postData;
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        QNG_JSON2Apex objSal = (QNG_JSON2Apex) JSON.deserialize(postData, QNG_JSON2Apex.class);
        QNG_JSON2Apex.Sale objSale = objSal.Sale;
        
        Test.startTest();
        QNGOnlineSaleCtrl.create();
        Test.stopTest();
    }
    
}
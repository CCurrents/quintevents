/**
* @File Name          : QNGInfoRequestTest.cls
* @Description        : 
* @Author             : vaibhav.khopade@addonblue.com
* @Created            : 10-Mar-2022 for fix of issue 1176
**/

@isTest 
public with sharing class QNGInfoRequestTest {
    
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();   
    }
    
    
 @IsTest static void test2(){
     
     	Lead leadObj = TestDataFactory.createLead();
     	Database.LeadConvert objLeadConvert = new database.LeadConvert();
     	objLeadConvert.setLeadId(leadObj.id);
     	objLeadConvert.setConvertedStatus('Converted');
     	objLeadConvert.setDoNotCreateOpportunity(true);
     	Database.LeadConvertResult objLeadConvertResult = Database.convertLead(objLeadConvert);
     	
     
        //******* REST API Call *******//
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/qngInfoRequest'; 
        req.httpMethod = 'POST';
        //String postData = '{ "sale": { "quoteId": "'+quote.Id+'", "totalAfterDiscount": 40, "totalChargedInCurrency": 50, "discount": 10, "discountCode": "DISC10", "resellerId": "", "promoterId": "", "eventId": "'+lstProduct[0].Primary_Price_Book__c+'", "city": "Charlotte", "country": "United States of America", "currencyCharged": "USD", "email": "'+con.Email+'", "firstName": "QNG1 Lovel DEMO 123", "googleAnalyticsId": "", "googleAnalyticsSiteId": "", "lastName": "QNG1 DEMO", "phone": "0124578963", "purchaseOrderNumber": "PO123", "site": "breederscupexperiences.com", "state": "North Carolina", "street": "Street1", "visitorCountry": "United States of America", "protectGroupAmount":"100.00", "protectGroupId":"rp_post_n_633d5ddd-31b1-4554-9f2d-ebfca7f36ab0a", "zip": "12458", "paymentTerms": "100%", "h4hPointsSpent": "", "isRewardApplied": false, "company_name": "TestOnlineSaleName", "h4hRewardPercentage": 5, "api": false, "lineItems": [ { "packageId": "'+lstProduct[0].Id+'", "packageQty": 2, "packagePrice": 150, "includeTransportation": true, "Stays": [ { "stayid": "'+lstProduct[3].Id+'", "stayPrice": 350, "stayQty": 2, "qngRoomingListId": "QNG1245" } ] } ], "retailHotelLineItems": [ { "HotelId": "'+lstProduct[2].Id+'", "HotelName": "Four", "ReservationId": "123413445", "ItineraryId": "BKK1313", "CheckInDate": "08/02/2020", "CheckOutDate": "08/12/2020", "ReservationTotalPrice": 2000, "RoomCode": "123", "RoomQuantity": 2 } ] } }';
     	String postData = '{ "id": "649869", "referrer": "https://www.google.com.au/5", "referring_domain": "www.google.com.au", "landing_page":"https://f1experiences.com/2022-australian-grand-prix5", "utm_source": "test source 5", "utm_medium": "test medium 5", "utm_term": null, "utm_content": null, "utm_campaign": "test campaign 5", "email": "'+ leadObj.Email +'", "phone": "0413785244", "url": "f1experiences.com", "site_id": "17" }';
        String JsonMsg = postData;
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        //QNG_JSON2Apex objSal = (QNG_JSON2Apex) JSON.deserialize(postData, QNG_JSON2Apex.class);
        //QNG_JSON2Apex.Sale objSale = objSal.Sale;
        
        Test.startTest();
        QNGInfoRequest.create();
        Test.stopTest();
    } 
    
 @IsTest static void test4(){
     
     	Account acc = TestDataFactory.createAccount();
     	Contact con = TestDataFactory.createContact(acc.Id);
     	Lead Testlead = TestDataFactory.createLead();
        
        //******* REST API Call *******//
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/qngInfoRequest'; 
        req.httpMethod = 'POST';
        //String postData = '{ "sale": { "quoteId": "'+quote.Id+'", "totalAfterDiscount": 40, "totalChargedInCurrency": 50, "discount": 10, "discountCode": "DISC10", "resellerId": "", "promoterId": "", "eventId": "'+lstProduct[0].Primary_Price_Book__c+'", "city": "Charlotte", "country": "United States of America", "currencyCharged": "USD", "email": "'+con.Email+'", "firstName": "QNG1 Lovel DEMO 123", "googleAnalyticsId": "", "googleAnalyticsSiteId": "", "lastName": "QNG1 DEMO", "phone": "0124578963", "purchaseOrderNumber": "PO123", "site": "breederscupexperiences.com", "state": "North Carolina", "street": "Street1", "visitorCountry": "United States of America", "protectGroupAmount":"100.00", "protectGroupId":"rp_post_n_633d5ddd-31b1-4554-9f2d-ebfca7f36ab0a", "zip": "12458", "paymentTerms": "100%", "h4hPointsSpent": "", "isRewardApplied": false, "company_name": "TestOnlineSaleName", "h4hRewardPercentage": 5, "api": false, "lineItems": [ { "packageId": "'+lstProduct[0].Id+'", "packageQty": 2, "packagePrice": 150, "includeTransportation": true, "Stays": [ { "stayid": "'+lstProduct[3].Id+'", "stayPrice": 350, "stayQty": 2, "qngRoomingListId": "QNG1245" } ] } ], "retailHotelLineItems": [ { "HotelId": "'+lstProduct[2].Id+'", "HotelName": "Four", "ReservationId": "123413445", "ItineraryId": "BKK1313", "CheckInDate": "08/02/2020", "CheckOutDate": "08/12/2020", "ReservationTotalPrice": 2000, "RoomCode": "123", "RoomQuantity": 2 } ] } }';
     	String postData = '{ "id": "649869", "referrer": "https://www.google.com.au/5", "referring_domain": "www.google.com.au", "landing_page":"https://f1experiences.com/2022-australian-grand-prix5", "utm_source": "test source 5", "utm_medium": "test medium 5", "utm_term": null, "utm_content": null, "utm_campaign": "test campaign 5", "email": "'+con.Email+'", "phone": "0413785244", "url": "f1experiences.com", "site_id": "17" }';
        String JsonMsg = postData;
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        //QNG_JSON2Apex objSal = (QNG_JSON2Apex) JSON.deserialize(postData, QNG_JSON2Apex.class);
        //QNG_JSON2Apex.Sale objSale = objSal.Sale;
        
        Test.startTest();
        QNGInfoRequest.create();
        Test.stopTest();
    }
    
 @IsTest static void test5(){
        
        Account acc = TestDataFactory.createAccount();
     	Contact con = TestDataFactory.createContact(acc.Id);
     	Lead Testlead = TestDataFactory.createLead();
        
        //******* REST API Call *******//
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/qngInfoRequest'; 
        req.httpMethod = 'POST';
        //String postData = '{ "sale": { "quoteId": "'+quote.Id+'", "totalAfterDiscount": 40, "totalChargedInCurrency": 50, "discount": 10, "discountCode": "DISC10", "resellerId": "", "promoterId": "", "eventId": "'+lstProduct[0].Primary_Price_Book__c+'", "city": "Charlotte", "country": "United States of America", "currencyCharged": "USD", "email": "'+con.Email+'", "firstName": "QNG1 Lovel DEMO 123", "googleAnalyticsId": "", "googleAnalyticsSiteId": "", "lastName": "QNG1 DEMO", "phone": "0124578963", "purchaseOrderNumber": "PO123", "site": "breederscupexperiences.com", "state": "North Carolina", "street": "Street1", "visitorCountry": "United States of America", "protectGroupAmount":"100.00", "protectGroupId":"rp_post_n_633d5ddd-31b1-4554-9f2d-ebfca7f36ab0a", "zip": "12458", "paymentTerms": "100%", "h4hPointsSpent": "", "isRewardApplied": false, "company_name": "TestOnlineSaleName", "h4hRewardPercentage": 5, "api": false, "lineItems": [ { "packageId": "'+lstProduct[0].Id+'", "packageQty": 2, "packagePrice": 150, "includeTransportation": true, "Stays": [ { "stayid": "'+lstProduct[3].Id+'", "stayPrice": 350, "stayQty": 2, "qngRoomingListId": "QNG1245" } ] } ], "retailHotelLineItems": [ { "HotelId": "'+lstProduct[2].Id+'", "HotelName": "Four", "ReservationId": "123413445", "ItineraryId": "BKK1313", "CheckInDate": "08/02/2020", "CheckOutDate": "08/12/2020", "ReservationTotalPrice": 2000, "RoomCode": "123", "RoomQuantity": 2 } ] } }';
     	String postData = '{ "id": "649869", "referrer": "https://www.google.com.au/5", "referring_domain": "www.google.com.au", "landing_page":"https://f1experiences.com/2022-australian-grand-prix5", "utm_source": "test source 5", "utm_medium": "test medium 5", "utm_term": null, "utm_content": null, "utm_campaign": "test campaign 5", "email": "'+Testlead.Email+'", "phone": "0413785244", "url": "f1experiences.com", "site_id": "17" }';
        String JsonMsg = postData;
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        //QNG_JSON2Apex objSal = (QNG_JSON2Apex) JSON.deserialize(postData, QNG_JSON2Apex.class);
        //QNG_JSON2Apex.Sale objSale = objSal.Sale;
        
        Test.startTest();
        QNGInfoRequest.create();
        Test.stopTest();
    }
}
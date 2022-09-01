/*************************************
** Class Name: QE_H4HStayProductInventoryUpdate_Test
** Created Date: 07/07/2019
** Created By: Vishal Agrawal
** Purpose: Test class for QE_H4HHotelProcess
** ** ** ** ** ** ** **
*******Modification Logs************
**Modifier Name ***** Modified Date ***** Description
**
*************************************/
@isTest
public class QE_H4HStayProductInventoryUpdate_Test {

    @testSetup
    public static void createData() {
        
        program__c pro = new program__c();
        pro.Name = 'F1E';
        insert pro;

        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        eventTest.program__c =pro.id;
        eventTest.H4H_Site_Id__c = '123456';
        Insert eventTest;
        
        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = eventTest.Id;
        insert parentPackage;
        
        product2 product =new product2();
        Product.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Stay').getRecordTypeId();
        product.Name = 'Test Product';
        product.Event__c = eventTest.Id;
        product.Type__c = 'Package';
        product.CurrencyIsoCode = 'USD';
        product.Price__c = 120.00;
        product.A_La_Carte__c = true;
        product.isActive = true;
        product.Parent_Package__c = parentPackage.Id;
        product.Check_In_Date__c = System.today();
        product.Check_Out_Date__c = System.today().addDays(2);
        product.Room_Type__c = 'Queen';
        product.Hotel_Id__c = '1234';
        product.H4H_Room_Code__c = '516775';
        insert product;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = product.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 0.00;
        pbe.IsActive = True;
        pbe.CurrencyIsoCode = 'USD';
        insert pbe;
    }
    
    static testMethod void h4HIntegrationMultipleTest() {
        Test.startTest();
        //Multiple Roomcode test
        QE_H4HStayProductInventoryUpdate.testResponseforAvailability = '{ "ArnResponse": { "Info": { "@SiteID": "51745", "@Username": "WBE", "@IpAddress": "", "@TimeReceived": "2019-07-08T17:08:34.298", "@TimeCompleted": "2019-07-08T17:08:34.422", "@Version": "1.0.0.0", "@ServiceUrl": "http://www.tripauthority.com/", "@RequestID": "B95886DC-AAF5-4882-A165-E2E8BCCF654B", "@ElapsedTime": "463", "@TripAggregationTime": "time: 501 | Aggregate << 4% time: 20ms | Before ExecuteMultiplePropertyRequests << 93% time: 464ms" }, "Availability": { "@DisplayCurrency": "USD", "HotelAvailability": { "@InDate": "2021-04-30", "@OutDate": "2021-05-01", "@Rooms": "1", "@Adults": "2", "@Children": "0", "Hotel": { "@HotelID": "1684628", "@HotelInfo": "https://api.travsrv.com/api/content/findpropertyinfo?propertyid=1684628", "@Latitude": "38.20032", "@Longitude": "-85.75186", "@Name": "Home2 Suites by Hilton Louisville Airport/Expo Center, KY", "@Address1": "3000 Crittenden Drive", "@City": "Louisville", "@State": "KY", "@CountryCode": "US", "@Postal": "40209", "@PercentMatch": "0", "@ImageThumbnail": "https://media.travsrv.com/1684628/180096616_70.jpg", "@LocationDescription": "Near Cardinal Stadium", "@TripAdvisorReviewCount": "0", "@TripAdvisorRating": "0", "@RatingImageUrl": "", "@PriceClass": "2 Stars", "@PropertyLink": "https://events.hotelsforhope.com/v6?type=property&rooms=1&adults=2&children=0&checkIn=2021-04-30&checkOut=2021-05-01&siteid=51745&property=1684628", "RatePlan": [{ "@Code": "ARN516775", "@Description": "Special Event Rate", "@BuyerOnly": "false", "@Gateway": "16", "@CommissionStatus": "Commissionable", "@BalanceDueAtHotel": "true", "Room": { "@Code": "516775", "@Name": "Test for offline upload", "@Description": "Double Queen. No breakfast included. Rate based on occupancy of 4 persons per room.", "@CurrencyCode": "USD", "@DisplayCurrencyMultiplier": "1", "@USDMultiplier": "1", "@ExchangeGMT": "2019-07-08T17:00:07.037", "@MaximumBookable": "1", "@Discount": "106.15", "NightlyRate": { "@Date": "2021-04-30", "@Price": "100.00", "@MaximumBookable": "1", "@Discount": "90.23" }, "Tax": { "@Percent": "15.00", "@Amount": "15.00" }, "GatewayFee": { "@Amount": "0.00" }, "Total": { "@Amount": "115.00", "@Discount": "106.15", "@ComparableRetailDiscount": "64.69", "@IncludesBookingFee": "false" }, "BookingFee": { "@Amount": "0.00", "@CurrencyCode": "USD", "@DisplayCurrencyMultiplier": "1", "@RoomCurrencyMultiplier": "1", "@ExchangeGMT": "2019-07-08T17:00:07.037" } } }]} } } } }';
       
        QE_scheduleH4HStayInventoryUpdate sh1 = new QE_scheduleH4HStayInventoryUpdate();

        String sch = '0 0 23 * * ?';
        system.schedule('Test Invventory Check', sch, sh1);
        
        Test.stopTest();
    }
}
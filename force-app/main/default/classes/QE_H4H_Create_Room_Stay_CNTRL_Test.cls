@isTest
public class QE_H4H_Create_Room_Stay_CNTRL_Test{
    
    @isTest static void hotelCreateRoomStayMultipleTest() {
        // Event
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
        Insert eventTest;
        
        Parent_Package__c  pp1 = new Parent_Package__c(Name = 'Legend', Event__c = eventTest.Id);
        Insert pp1;
        
        List<product2> lstProducttoInsert = New List<product2>();
        // Package
        Product2 proPack = new Product2(Name='BXCD111', isActive=true, 
                                        Event__c = eventTest.Id,
                                        Type__c = 'Package',
                                        Parent_Package__c = pp1.Id,
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proPack);
        
        // Product (ARN Hotel)
        Product2 proARNHotel = new Product2(Name='ARN Hotel', isActive=true, 
                                                Event__c = eventTest.Id,
                                                A_La_Carte__c = true, Type__c = 'Hotel',Hotel_Id__c='111222133344',
                                                Check_In_Date__c=System.Today().addDays(2),Check_Out_Date__c=System.Today().addDays(4),
                                                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proARNHotel);

        Test.StartTest();
        insert lstProducttoInsert;
        
        ApexPages.StandardController stdPro = new ApexPages.StandardController(proARNHotel);
        ApexPages.currentPage().getParameters().put('id',proARNHotel.id);
        
        QE_H4H_Create_Room_Stay_CNTRL qeCreateStayProd = new QE_H4H_Create_Room_Stay_CNTRL(stdPro);
        qeCreateStayProd.closePopup();
        QE_H4H_Create_Room_Stay_CNTRL.testResponseforAvailability = '{ "ArnResponse": { "Info": { "@SiteID": "51745", "@Username": "WBE", "@IpAddress": "", "@TimeReceived": "2019-07-08T17:08:34.298", "@TimeCompleted": "2019-07-08T17:08:34.422", "@Version": "1.0.0.0", "@ServiceUrl": "http://www.tripauthority.com/", "@RequestID": "B95886DC-AAF5-4882-A165-E2E8BCCF654B", "@ElapsedTime": "463", "@TripAggregationTime": "time: 501 | Aggregate << 4% time: 20ms | Before ExecuteMultiplePropertyRequests << 93% time: 464ms" }, "Availability": { "@DisplayCurrency": "USD", "HotelAvailability": { "@InDate": "2021-04-30", "@OutDate": "2021-05-01", "@Rooms": "1", "@Adults": "2", "@Children": "0", "Hotel": { "@HotelID": "1684628", "@HotelInfo": "https://api.travsrv.com/api/content/findpropertyinfo?propertyid=1684628", "@Latitude": "38.20032", "@Longitude": "-85.75186", "@Name": "Home2 Suites by Hilton Louisville Airport/Expo Center, KY", "@Address1": "3000 Crittenden Drive", "@City": "Louisville", "@State": "KY", "@CountryCode": "US", "@Postal": "40209", "@PercentMatch": "0", "@ImageThumbnail": "https://media.travsrv.com/1684628/180096616_70.jpg", "@LocationDescription": "Near Cardinal Stadium", "@TripAdvisorReviewCount": "0", "@TripAdvisorRating": "0", "@RatingImageUrl": "", "@PriceClass": "2 Stars", "@PropertyLink": "https://events.hotelsforhope.com/v6?type=property&rooms=1&adults=2&children=0&checkIn=2021-04-30&checkOut=2021-05-01&siteid=51745&property=1684628", "RatePlan": [{ "@Code": "ARN516775", "@Description": "Special Event Rate", "@BuyerOnly": "false", "@Gateway": "16", "@CommissionStatus": "Commissionable", "@BalanceDueAtHotel": "true", "Room": { "@Code": "516775", "@Name": "Test for offline upload", "@Description": "Double Queen. No breakfast included. Rate based on occupancy of 4 persons per room.", "@CurrencyCode": "USD", "@DisplayCurrencyMultiplier": "1", "@USDMultiplier": "1", "@ExchangeGMT": "2019-07-08T17:00:07.037", "@MaximumBookable": "1", "@Discount": "106.15", "NightlyRate": { "@Date": "2021-04-30", "@Price": "100.00", "@MaximumBookable": "1", "@Discount": "90.23" }, "Tax": { "@Percent": "15.00", "@Amount": "15.00" }, "GatewayFee": { "@Amount": "0.00" }, "Total": { "@Amount": "115.00", "@Discount": "106.15", "@ComparableRetailDiscount": "64.69", "@IncludesBookingFee": "false" }, "BookingFee": { "@Amount": "0.00", "@CurrencyCode": "USD", "@DisplayCurrencyMultiplier": "1", "@RoomCurrencyMultiplier": "1", "@ExchangeGMT": "2019-07-08T17:00:07.037" } } }]} } } } }';
        qeCreateStayProd.createRoomStay();
        
        QE_H4H_Create_Room_Stay_CNTRL.h4hRoomType('TestQueen');
        QE_H4H_Create_Room_Stay_CNTRL.h4hRoomType('123Queen/Queen');
        QE_H4H_Create_Room_Stay_CNTRL.h4hRoomType('fdSuite');
        QE_H4H_Create_Room_Stay_CNTRL.h4hRoomType('dvvRun of House');
        QE_H4H_Create_Room_Stay_CNTRL.h4hRoomType('dfdKing');

        Test.StopTest();
    }
    
    @isTest static void hotelCreateRoomStaySingleTest() {
        // Event
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
        Insert eventTest;
        
        Parent_Package__c  pp1 = new Parent_Package__c(Name = 'Legend', Event__c = eventTest.Id);
        Insert pp1;
        
        List<product2> lstProducttoInsert = New List<product2>();
        // Package
        Product2 proPack = new Product2(Name='BXCD111', isActive=true, 
                                        Event__c = eventTest.Id,
                                        Type__c = 'Package',
                                        Parent_Package__c = pp1.Id,
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proPack);
        
        // Product (ARN Hotel)
        Product2 proARNHotel = new Product2(Name='ARN Hotel', isActive=true, 
                                                Event__c = eventTest.Id,
                                                A_La_Carte__c = true, Type__c = 'Hotel',Hotel_Id__c='111222133344',
                                                Check_In_Date__c=System.Today().addDays(2),Check_Out_Date__c=System.Today().addDays(4),
                                                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proARNHotel);

        Test.StartTest();
        insert lstProducttoInsert;
        
        ApexPages.StandardController stdPro = new ApexPages.StandardController(proARNHotel);
        ApexPages.currentPage().getParameters().put('id',proARNHotel.id);
        
        QE_H4H_Create_Room_Stay_CNTRL qeCreateStayProd = new QE_H4H_Create_Room_Stay_CNTRL(stdPro);
        QE_H4H_Create_Room_Stay_CNTRL.testResponseforAvailability = '{ "ArnResponse": { "Info": { "@SiteID": "51745", "@Username": "WBE", "@IpAddress": "", "@TimeReceived": "2019-07-08T17:08:34.298", "@TimeCompleted": "2019-07-08T17:08:34.422", "@Version": "1.0.0.0", "@ServiceUrl": "http://www.tripauthority.com/", "@RequestID": "B95886DC-AAF5-4882-A165-E2E8BCCF654B", "@ElapsedTime": "463", "@TripAggregationTime": "time: 501 | Aggregate << 4% time: 20ms | Before ExecuteMultiplePropertyRequests << 93% time: 464ms" }, "Availability": { "@DisplayCurrency": "USD", "HotelAvailability": { "@InDate": "2021-04-30", "@OutDate": "2021-05-01", "@Rooms": "1", "@Adults": "2", "@Children": "0", "Hotel": { "@HotelID": "1684628", "@HotelInfo": "https://api.travsrv.com/api/content/findpropertyinfo?propertyid=1684628", "@Latitude": "38.20032", "@Longitude": "-85.75186", "@Name": "Home2 Suites by Hilton Louisville Airport/Expo Center, KY", "@Address1": "3000 Crittenden Drive", "@City": "Louisville", "@State": "KY", "@CountryCode": "US", "@Postal": "40209", "@PercentMatch": "0", "@ImageThumbnail": "https://media.travsrv.com/1684628/180096616_70.jpg", "@LocationDescription": "Near Cardinal Stadium", "@TripAdvisorReviewCount": "0", "@TripAdvisorRating": "0", "@RatingImageUrl": "", "@PriceClass": "2 Stars", "@PropertyLink": "https://events.hotelsforhope.com/v6?type=property&rooms=1&adults=2&children=0&checkIn=2021-04-30&checkOut=2021-05-01&siteid=51745&property=1684628", "RatePlan": { "@Code": "ARN516775", "@Description": "Special Event Rate", "@BuyerOnly": "false", "@Gateway": "16", "@CommissionStatus": "Commissionable", "@BalanceDueAtHotel": "true", "Room": { "@Code": "516775", "@Name": "Test for offline upload", "@Description": "Twin. Rate based on occupancy of 4 persons per room.", "@CurrencyCode": "USD", "@DisplayCurrencyMultiplier": "1", "@USDMultiplier": "1", "@ExchangeGMT": "2019-07-08T17:00:07.037", "@MaximumBookable": "1", "@Discount": "106.15", "NightlyRate": { "@Date": "2021-04-30", "@Price": "100.00", "@MaximumBookable": "1", "@Discount": "90.23" }, "Tax": { "@Percent": "15.00", "@Amount": "15.00" }, "GatewayFee": { "@Amount": "0.00" }, "Total": { "@Amount": "115.00", "@Discount": "106.15", "@ComparableRetailDiscount": "64.69", "@IncludesBookingFee": "false" }, "BookingFee": { "@Amount": "0.00", "@CurrencyCode": "USD", "@DisplayCurrencyMultiplier": "1", "@RoomCurrencyMultiplier": "1", "@ExchangeGMT": "2019-07-08T17:00:07.037" } } }} } } } }';
        qeCreateStayProd.createRoomStay();
        
        Test.StopTest();
    }
}
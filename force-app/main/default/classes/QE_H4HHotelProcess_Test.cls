/*************************************
** Class Name: QE_H4HHotelProcess_Test
** Created Date: 07/07/2019
** Created By: Vishal Agrawal
** Purpose: Test class for QE_H4HHotelProcess
** ** ** ** ** ** ** **
*******Modification Logs************
**Modifier Name ***** Modified Date ***** Description
**
*************************************/
@isTest
public class QE_H4HHotelProcess_Test {

    @testSetup
    public static void createData() {
        
        // program__c pro = new program__c();
        // pro.Name = 'F1E';
        // insert pro;

        // QE360_Event__c eventTest = new QE360_Event__c();
        // eventTest.Name = 'test';
        // eventTest.program__c =pro.id;
        // eventTest.H4H_Site_Id__c = '123456';
        // Insert eventTest;
        
        // Parent_Package__c parentPackage= new Parent_Package__c();
        // parentPackage.Event__c = eventTest.Id;
        // insert parentPackage;
        
        // product2 product =new product2();
        // Product.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId();
        // product.Name = 'Test Product';
        // product.Event__c = eventTest.Id;
        // product.Type__c = 'Package';
        // product.CurrencyIsoCode = 'USD';
        // product.Price__c = 120.00;
        // product.A_La_Carte__c = true;
        // product.isActive = true;
        // product.Parent_Package__c = parentPackage.Id;
        // product.Check_In_Date__c = System.today();
        // product.Check_Out_Date__c = System.today().addDays(2);
        // product.Room_Type__c = 'Queen';
        // product.Hotel_Id__c = '1234';
        // insert product;

        // PricebookEntry pbe = new PricebookEntry();
        // pbe.Product2Id = product.Id;
        // pbe.Pricebook2Id = Test.getStandardPricebookId();
        // pbe.UnitPrice = 0.00;
        // pbe.IsActive = True;
        // pbe.CurrencyIsoCode = 'USD';
        // insert pbe;

        // // Insert Test Account
        // Lead lead = new Lead();
        // lead.Google_Analytics_ID__c = 'lgaID';
        // lead.Google_Analytics_Site_Id__c = 'lgaSiteId';
        // lead.FirstName = 'testNamelead';
        // lead.LastName = 'test';
        // lead.Status = 'Qualified';
        // lead.Source__c = 'call cotaexperiences.com';
        // lead.Email = 'testemails@quintevents.com';
        // insert lead;

        // Database.LeadConvert lc = new database.LeadConvert();
        // lc.setLeadId(lead.id);
        // lc.setDoNotCreateOpportunity(true);
        // lc.setConvertedStatus('Converted');
        // Database.LeadConvertResult lcr = Database.convertLead(lc);
        // System.assert(lcr.isSuccess());

        // Lead testLead = [select Id, IsConverted, ConvertedAccountId,ConvertedContactId from Lead where Id = :lead.Id];

        // Account acct = new Account();
        // acct.id = testLead.ConvertedAccountId;
        // acct.personEmail ='testmails@quintevents.com';
        // update acct;

        // Opportunity oppTest = new Opportunity();
        // oppTest.Name = 'oppName';
        // oppTest.AccountId = testLead.ConvertedAccountId;
        // oppTest.Primary_Contact__c = testLead.ConvertedContactId;
        // oppTest.Communications_Contact__c = testLead.ConvertedContactId;
        // oppTest.Event__c = eventTest.Id;
        // oppTest.StageName = 'Closed Won';
        // oppTest.CloseDate = System.today();
        // oppTest.Contact_Site__c = 'quintevents.com';
        // oppTest.ship_to_Name__c = 'Test abc Test1';
        // oppTest.Payment_Method__c = 'Check';
        // oppTest.email__c = 'abcedgft@gmail.com';
        // oppTest.Amount = 1;
        // insert oppTest;
        // System.debug('@@@Test class Opp: ' + oppTest);

        // OpportunityLineItem oppLineItem = new OpportunityLineItem();
        // oppLineItem.OpportunityId = oppTest.Id;
        // oppLineItem.PricebookEntryId = pbe.Id;
        // oppLineItem.Quantity = 100;
        // oppLineItem.UnitPrice = 10;
        // oppLineItem.Product2Id = product.Id;
        // oppLineItem.ApexProductType__c = 'Hotel';
        // oppLineItem.ApexProductName__c = Product.Name;
        // oppLineItem.ApexCost__c = 120;
        // oppLineItem.Opportunity_Product_Package_Hotel__c = true;
        // oppLineItem.Package__c = product.Id;
        // insert oppLineItem;

        // // Opportunity_Payment_Terms__c oppPayTermTest = new Opportunity_Payment_Terms__c(Payment_Term__c = '100%', Amount__c=100,Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id );
        // // insert oppPayTermTest;
        // // System.debug('Oppo @@ Py###Terms%: ' + oppPayTermTest.Id);

        // Quote quot = new Quote();
        // quot.OpportunityId = oppTest.Id;
        // quot.Name = 'Test Quote1';
        // quot.Status = 'Draft';
        // insert quot;

        // QE_H4H_Credit_Card__c h4hcreditCard = new QE_H4H_Credit_Card__c();
        // h4hcreditCard.Card_City__c = 'Detroit';
        // h4hcreditCard.Card_CountryCode__c = 'US';
        // h4hcreditCard.Card_CVV__c = '123';
        // h4hcreditCard.Card_Expiration__c = '12/18';
        // h4hcreditCard.Card_Holder_Name__c = 'Eddie Collins';
        // h4hcreditCard.Card_Number__c = '4242424242424242';
        // h4hcreditCard.Card_PostalCode__c = '48234';
        // h4hcreditCard.Card_Region__c = 'MI';
        // h4hcreditCard.Card_Street_Address__c = 'My Street';
        // h4hcreditCard.Card_Type__c = 'VI';
        // insert h4hcreditCard;
    }

    static testMethod void h4HIntegrationMultipleTest() {
        // Quote quot = [Select Id,OpportunityId from Quote Limit 1];
        // Id ContactId = [Select Id from Contact Limit 1].Id;
        // OpportunityLineItem oppLineItem = [Select Id, opportunityId from OpportunityLineItem Limit 1];
        
        // Rooming_List__c roomList = new Rooming_List__c();
        // roomList.H4H_RatePlan_Code__c = 'ARN540643';
        // roomList.H4H_Room_Code__c = '540643';
        // roomList.Number_of_Adults__c = 2;
        // roomList.Guest_Name__c = 'test guest';
        // roomList.Opportunity__c = oppLineItem.OpportunityId;
        // roomList.OpportunityLineItem_Id__c = oppLineItem.Id;
        // insert roomList;

        // Test.startTest();
        // //Multiple Roomcode test
        // QE_H4HHotelProcess.testResponseforAvailability = '{ "ArnResponse": { "Info": { "@SiteID": "51745", "@Username": "WBE", "@IpAddress": "", "@TimeReceived": "2019-07-08T17:08:34.298", "@TimeCompleted": "2019-07-08T17:08:34.422", "@Version": "1.0.0.0", "@ServiceUrl": "http://www.tripauthority.com/", "@RequestID": "B95886DC-AAF5-4882-A165-E2E8BCCF654B", "@ElapsedTime": "463", "@TripAggregationTime": "time: 501 | Aggregate << 4% time: 20ms | Before ExecuteMultiplePropertyRequests << 93% time: 464ms" }, "Availability": { "@DisplayCurrency": "USD", "HotelAvailability": { "@InDate": "2021-04-30", "@OutDate": "2021-05-01", "@Rooms": "1", "@Adults": "2", "@Children": "0", "Hotel": { "@HotelID": "1684628", "@HotelInfo": "https://api.travsrv.com/api/content/findpropertyinfo?propertyid=1684628", "@Latitude": "38.20032", "@Longitude": "-85.75186", "@Name": "Home2 Suites by Hilton Louisville Airport/Expo Center, KY", "@Address1": "3000 Crittenden Drive", "@City": "Louisville", "@State": "KY", "@CountryCode": "US", "@Postal": "40209", "@PercentMatch": "0", "@ImageThumbnail": "https://media.travsrv.com/1684628/180096616_70.jpg", "@LocationDescription": "Near Cardinal Stadium", "@TripAdvisorReviewCount": "0", "@TripAdvisorRating": "0", "@RatingImageUrl": "", "@PriceClass": "2 Stars", "@PropertyLink": "https://events.hotelsforhope.com/v6?type=property&rooms=1&adults=2&children=0&checkIn=2021-04-30&checkOut=2021-05-01&siteid=51745&property=1684628", "RatePlan": [{ "@Code": "ARN516775", "@Description": "Special Event Rate", "@BuyerOnly": "false", "@Gateway": "16", "@CommissionStatus": "Commissionable", "@BalanceDueAtHotel": "true", "Room": { "@Code": "516775", "@Name": "Test for offline upload", "@Description": "Double Queen. No breakfast included. Rate based on occupancy of 4 persons per room.", "@CurrencyCode": "USD", "@DisplayCurrencyMultiplier": "1", "@USDMultiplier": "1", "@ExchangeGMT": "2019-07-08T17:00:07.037", "@MaximumBookable": "1", "@Discount": "106.15", "NightlyRate": { "@Date": "2021-04-30", "@Price": "100.00", "@MaximumBookable": "1", "@Discount": "90.23" }, "Tax": { "@Percent": "15.00", "@Amount": "15.00" }, "GatewayFee": { "@Amount": "0.00" }, "Total": { "@Amount": "115.00", "@Discount": "106.15", "@ComparableRetailDiscount": "64.69", "@IncludesBookingFee": "false" }, "BookingFee": { "@Amount": "0.00", "@CurrencyCode": "USD", "@DisplayCurrencyMultiplier": "1", "@RoomCurrencyMultiplier": "1", "@ExchangeGMT": "2019-07-08T17:00:07.037" } } }]} } } } }';
        // QE_H4HHotelProcess.h4hAvailbilityHotelSearch(new List<Id>{quot.Id});
        
        // List<Opportunity_Payment_Terms__c> lstOPT = [Select Id,Opportunity__c from Opportunity_Payment_Terms__c where Opportunity__c = :quot.OpportunityId];

        // for(Opportunity_Payment_Terms__c oppPayTerm : lstOPT) {
        //     oppPayTerm.Status__c = 'Passed';
        // }
        // update lstOPT;

        // Opportunity op = new Opportunity(Id=quot.OpportunityId);
        // op.Primary_Contact__c = ContactId;

        // QE_checkRecursiveOpportunity.runOnce();
        // update op;

        // QE_H4HHotelProcess.h4hCreateReservation(new Set<Id>{op.Id});
        // QE_H4HHotelProcess.h4hHoldCancellation(new List<Id>{op.Id});
        
        //Test.stopTest();
    }

    static testMethod void h4HIntegrationMultipleCanceledTest() {
        // Quote quot = [Select Id,OpportunityId from Quote Limit 1];
        // Id ContactId = [Select Id from Contact Limit 1].Id;

        // Test.startTest();
        // //Multiple Roomcode test
        // QE_H4HHotelProcess.testResponseforAvailability = '{ "ArnResponse": { "Info": { "@SiteID": "51745", "@Username": "WBE", "@IpAddress": "", "@TimeReceived": "2019-07-08T17:08:34.298", "@TimeCompleted": "2019-07-08T17:08:34.422", "@Version": "1.0.0.0", "@ServiceUrl": "http://www.tripauthority.com/", "@RequestID": "B95886DC-AAF5-4882-A165-E2E8BCCF654B", "@ElapsedTime": "463", "@TripAggregationTime": "time: 501 | Aggregate << 4% time: 20ms | Before ExecuteMultiplePropertyRequests << 93% time: 464ms" }, "Availability": { "@DisplayCurrency": "USD", "HotelAvailability": { "@InDate": "2021-04-30", "@OutDate": "2021-05-01", "@Rooms": "1", "@Adults": "2", "@Children": "0", "Hotel": { "@HotelID": "1684628", "@HotelInfo": "https://api.travsrv.com/api/content/findpropertyinfo?propertyid=1684628", "@Latitude": "38.20032", "@Longitude": "-85.75186", "@Name": "Home2 Suites by Hilton Louisville Airport/Expo Center, KY", "@Address1": "3000 Crittenden Drive", "@City": "Louisville", "@State": "KY", "@CountryCode": "US", "@Postal": "40209", "@PercentMatch": "0", "@ImageThumbnail": "https://media.travsrv.com/1684628/180096616_70.jpg", "@LocationDescription": "Near Cardinal Stadium", "@TripAdvisorReviewCount": "0", "@TripAdvisorRating": "0", "@RatingImageUrl": "", "@PriceClass": "2 Stars", "@PropertyLink": "https://events.hotelsforhope.com/v6?type=property&rooms=1&adults=2&children=0&checkIn=2021-04-30&checkOut=2021-05-01&siteid=51745&property=1684628", "RatePlan": [{ "@Code": "ARN516775", "@Description": "Special Event Rate", "@BuyerOnly": "false", "@Gateway": "16", "@CommissionStatus": "Commissionable", "@BalanceDueAtHotel": "true", "Room": { "@Code": "516775", "@Name": "Test for offline upload", "@Description": "Double Queen. No breakfast included. Rate based on occupancy of 4 persons per room.", "@CurrencyCode": "USD", "@DisplayCurrencyMultiplier": "1", "@USDMultiplier": "1", "@ExchangeGMT": "2019-07-08T17:00:07.037", "@MaximumBookable": "1", "@Discount": "106.15", "NightlyRate": { "@Date": "2021-04-30", "@Price": "100.00", "@MaximumBookable": "1", "@Discount": "90.23" }, "Tax": { "@Percent": "15.00", "@Amount": "15.00" }, "GatewayFee": { "@Amount": "0.00" }, "Total": { "@Amount": "115.00", "@Discount": "106.15", "@ComparableRetailDiscount": "64.69", "@IncludesBookingFee": "false" }, "BookingFee": { "@Amount": "0.00", "@CurrencyCode": "USD", "@DisplayCurrencyMultiplier": "1", "@RoomCurrencyMultiplier": "1", "@ExchangeGMT": "2019-07-08T17:00:07.037" } } }]} } } } }';
        // QE_H4HHotelProcess.h4hCallProductSelection(new Set<Id>{quot.OpportunityId});
        
        // // List<Opportunity_Payment_Terms__c> lstOPT = [Select Id,Opportunity__c from Opportunity_Payment_Terms__c where Opportunity__c = :quot.OpportunityId];

        // // for(Opportunity_Payment_Terms__c oppPayTerm : lstOPT) {
        // //     oppPayTerm.Status__c = 'Canceled';
        // // }
        // // update lstOPT;

        // Opportunity op = new Opportunity(Id=quot.OpportunityId);
        // op.Primary_Contact__c = ContactId;

        // QE_checkRecursiveOpportunity.runOnce();
        // update op;

        // QE_H4HHotelProcess.h4hCreateReservation(new Set<Id>{op.Id});
        // QE_H4HHotelProcess.h4hHoldCancellation(new List<Id>{op.Id});
        
        // Test.stopTest();
    }

    static testMethod void h4HIntegrationSingleTest() {
        //Quote quot = [Select Id from Quote Limit 1];

        //Single Roomcode test
        //QE_H4HHotelProcess.testResponseforAvailability = '{ "ArnResponse": { "Info": { "@SiteID": "51745", "@Username": "WBE", "@IpAddress": "", "@TimeReceived": "2019-07-08T17:08:34.298", "@TimeCompleted": "2019-07-08T17:08:34.422", "@Version": "1.0.0.0", "@ServiceUrl": "http://www.tripauthority.com/", "@RequestID": "B95886DC-AAF5-4882-A165-E2E8BCCF654B", "@ElapsedTime": "463", "@TripAggregationTime": "time: 501 | Aggregate << 4% time: 20ms | Before ExecuteMultiplePropertyRequests << 93% time: 464ms" }, "Availability": { "@DisplayCurrency": "USD", "HotelAvailability": { "@InDate": "2021-04-30", "@OutDate": "2021-05-01", "@Rooms": "1", "@Adults": "2", "@Children": "0", "Hotel": { "@HotelID": "1684628", "@HotelInfo": "https://api.travsrv.com/api/content/findpropertyinfo?propertyid=1684628", "@Latitude": "38.20032", "@Longitude": "-85.75186", "@Name": "Home2 Suites by Hilton Louisville Airport/Expo Center, KY", "@Address1": "3000 Crittenden Drive", "@City": "Louisville", "@State": "KY", "@CountryCode": "US", "@Postal": "40209", "@PercentMatch": "0", "@ImageThumbnail": "https://media.travsrv.com/1684628/180096616_70.jpg", "@LocationDescription": "Near Cardinal Stadium", "@TripAdvisorReviewCount": "0", "@TripAdvisorRating": "0", "@RatingImageUrl": "", "@PriceClass": "2 Stars", "@PropertyLink": "https://events.hotelsforhope.com/v6?type=property&rooms=1&adults=2&children=0&checkIn=2021-04-30&checkOut=2021-05-01&siteid=51745&property=1684628", "RatePlan": { "@Code": "ARN516775", "@Description": "Special Event Rate", "@BuyerOnly": "false", "@Gateway": "16", "@CommissionStatus": "Commissionable", "@BalanceDueAtHotel": "true", "Room": { "@Code": "516775", "@Name": "Test for offline upload", "@Description": "Double Queen. No breakfast included. Rate based on occupancy of 4 persons per room.", "@CurrencyCode": "USD", "@DisplayCurrencyMultiplier": "1", "@USDMultiplier": "1", "@ExchangeGMT": "2019-07-08T17:00:07.037", "@MaximumBookable": "1", "@Discount": "106.15", "NightlyRate": { "@Date": "2021-04-30", "@Price": "100.00", "@MaximumBookable": "1", "@Discount": "90.23" }, "Tax": { "@Percent": "15.00", "@Amount": "15.00" }, "GatewayFee": { "@Amount": "0.00" }, "Total": { "@Amount": "115.00", "@Discount": "106.15", "@ComparableRetailDiscount": "64.69", "@IncludesBookingFee": "false" }, "BookingFee": { "@Amount": "0.00", "@CurrencyCode": "USD", "@DisplayCurrencyMultiplier": "1", "@RoomCurrencyMultiplier": "1", "@ExchangeGMT": "2019-07-08T17:00:07.037" } } }} } } } }';
        //QE_H4HHotelProcess.h4hAvailbilityHotelSearch(new List<Id>{quot.Id});
    }
}
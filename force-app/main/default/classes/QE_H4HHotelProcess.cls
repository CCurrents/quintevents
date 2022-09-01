/*************************************
** Class Name: QE_H4HHotelProcess
** Created Date: 06/14/2019
** Created By: Vishal Agrawal
** Purpose: H4H Integration, Hotel Availabilty Search, Hotel Hold creation
** Unit Test: QE_H4HHotelProcess_Test
** ** ** ** ** ** ** **********
**
*******Modification Logs************
**Modifier Name ***** Modified Date ***** Description
**
*************************************/

public class QE_H4HHotelProcess {

    //  public static String testResponseforAvailability;

/***********************************************************
** Method Name: h4hAvailbilityHotelSearch
** Param: List of Id of Quotes
** Return: Void
** Purpose: Hotel Availability search and Hold Creation in H4H
****************************************************************/
    //@future(callout=true)
    Public static void h4hAvailbilityHotelSearch(List<Id> lstEnvelopeStatusQuoteIds) {
        h4hCallProductSelection(null);
        // Map<Id,Rooming_List__c> mapOLIRoomingList = new Map<Id,Rooming_List__c>();
        // for(Rooming_List__c rl : [Select Id,Opportunity__c,OpportunityLineItem_Id__c,H4H_Room_Code__c,H4H_RatePlan_Code__c,H4H_Roomtype_Id__c,Number_of_Adults__c from Rooming_List__c
        //                             where Opportunity__c In (Select OpportunityId from Quote where Id In :lstEnvelopeStatusQuoteIds)]) {
        //     mapOLIRoomingList.put(rl.OpportunityLineItem_Id__c,rl);
        // }
        // h4hAvailbilityHotelSearchCall([Select Id, Name, OpportunityId, Hotel_Id__c,Product2Id,Check_In_Date__c,Check_Out_Date__c, Room_Type_Hotel__c, Quantity,H4H_Need_to_Hold__c,H4H_Adult_Quantity__c,
        //                                 H4H_Hold_Created__c, H4H_RatePlan_Code__c, H4H_Reservation_Created__c, H4H_Room_Code__c, Roomtype_Id__c, Opportunity.Event__r.H4H_Site_Id__c,H4H_Client_Name__c
        //                                 from OpportunityLineItem
        //                                 where Check_In_Date__c != Null AND Check_Out_Date__c != Null AND Hotel_Id__c != NUll AND
        //                                 H4H_Hold_Created__c = false AND H4H_Reservation_Created__c = false AND //AND Product2.RecordType.DeveloperName = 'Hotels'
        //                                 OpportunityId In (Select OpportunityId from Quote where Id In :lstEnvelopeStatusQuoteIds) AND
        //                                 Opportunity.StageName = 'Closed Won'],mapOLIRoomingList);
    }

/***********************************************************
** Method Name: h4hCallProductSelection
** Param: List of Id of Opportuynity Line Item Ids
** Return: Void
** Purpose: Hotel Availability search and Hold Creation in H4H Product selection
********************************************************************************/
   // @future(callout=true)
    Public static void h4hCallProductSelection(Set<Id> oppORLineItemId) {
        h4hAvailbilityHotelSearchCall(null, null);
        createRoomingList(null);
        h4hRoomHoldCreation(null, null, null, null);
        h4hHoldCancellation(null);
        h4hCreateReservation(null);
        reservationCreateRequestCommon(null, null);
        h4hRatePlanInfo(null, null, null, null, null, null);
        createReservationAfterHold(null,null, null, null, null);
        updateProductInventory(null, null, null, null);
        // h4hAvailbilityHotelSearch(null);
        // Map<Id,Rooming_List__c> mapOLIRoomingList = new Map<Id,Rooming_List__c>();
        // for(Rooming_List__c rl : [Select Id,Opportunity__c,OpportunityLineItem_Id__c,H4H_Room_Code__c,H4H_RatePlan_Code__c,H4H_Roomtype_Id__c,Number_of_Adults__c from Rooming_List__c
        //                             where Opportunity__c In :oppORLineItemId or OpportunityLineItem_Id__c In :oppORLineItemId]) {
        //     mapOLIRoomingList.put(rl.OpportunityLineItem_Id__c,rl);
        // }
        // h4hAvailbilityHotelSearchCall([Select Id, Name, OpportunityId, Hotel_Id__c,Product2Id,Check_In_Date__c,Check_Out_Date__c, Room_Type_Hotel__c, Quantity,H4H_Need_to_Hold__c,H4H_Adult_Quantity__c,
        //                                 H4H_Hold_Created__c, H4H_RatePlan_Code__c, H4H_Reservation_Created__c, H4H_Room_Code__c, Roomtype_Id__c,Opportunity.Event__r.H4H_Site_Id__c,H4H_Client_Name__c
        //                                 from OpportunityLineItem
        //                                 where Check_In_Date__c != Null AND Check_Out_Date__c != Null AND Hotel_Id__c != NUll AND //H4H_Need_to_Hold__c = false AND
        //                                 H4H_Hold_Created__c = false AND H4H_Reservation_Created__c = false AND //AND Product2.RecordType.DeveloperName = 'Hotels'
        //                                 (Id In :oppORLineItemId OR OpportunityId In :oppORLineItemId)],mapOLIRoomingList);
    }

/***********************************************************
** Method Name: h4hAvailbilityHotelSearchCall
** Param: List of OpportunityLineItem
** Return: Void
** Purpose: Hotel Availability search and Hold Creation in H4H
****************************************************************/
    Public static void h4hAvailbilityHotelSearchCall(List<OpportunityLineItem> lstOppLineItems, Map<Id,Rooming_List__c> mapRoomList) {
        // List<OpportunityLineItem> lstHotelItems = new List<OpportunityLineItem>();
        // List<Rooming_List__c> lstRooming = new List<Rooming_List__c>();
        // H4H_API_Details__c h4hAPISettings = H4H_API_Details__c.getOrgDefaults();
        // Set<Id> setProdIds = new Set<Id>();
        // Set<Id> setOpportunityIds = new Set<Id>();

        // List<RequestResponse_Log__c> reResList = new List<RequestResponse_Log__c>();

        // for(OpportunityLineItem hotelOLI : lstOppLineItems) {

        //     if(String.isNotBlank(hotelOLI.H4H_Room_Code__c) && String.isNotBlank(hotelOLI.H4H_RatePlan_Code__c)) {
        //         Rooming_List__c roomList = mapRoomList.get(hotelOLI.Id);
        //         if(roomList == null) {
        //             roomList = createRoomingList(hotelOLI);
        //         }
        //         h4hRoomHoldCreation(hotelOLI, h4hAPISettings, reResList, roomList);
                
        //         lstRooming.add(roomList);
        //         lstHotelItems.add(hotelOLI);
        //         setProdIds.add(hotelOLI.Product2Id);
        //         setOpportunityIds.add(hotelOLI.OpportunityId);
        //     } else {
        //         //H4H Hotel availability Search
        //         HttpRequest req = new HttpRequest();
        //         req.setEndpoint(h4hAPISettings.Hotel_Availability_End_Point__c +
        //                         'inDate=' + String.valueOf(hotelOLI.Check_In_Date__c) +
        //                         '&outDate=' + String.valueOf(hotelOLI.Check_Out_Date__c) +
        //                         '&username=' + h4hAPISettings.H4H_username__c +
        //                         '&password=' + h4hAPISettings.H4H_password__c +
        //                         '&siteid=' + hotelOLI.Opportunity.Event__r.H4H_Site_Id__c + //h4hAPISettings.H4H_Site_Id__c +
        //                         '&rooms=' + Integer.valueOf(hotelOLI.Quantity) + //1' +
        //                         '&adults=' + hotelOLI.H4H_Adult_Quantity__c + //2' +
        //                         '&children=0' +
        //                         '&ipAddress=' + h4hAPISettings.IP_Address__c +
        //                         '&userAgent=' + h4hAPISettings.User_Agent__c +
        //                         '&userLanguage=en' +
        //                         '&_type=json' +
        //                         '&gateway=16' +
        //                         '&hotelids=' + hotelOLI.Hotel_Id__c);
        //         System.debug(req.getEndpoint());
        //         req.setMethod('GET');
        //         req.setHeader('Content-type','application/x-www-form-urlencoded');
        //         //req.setHeader('Content-Length', '276');
        //         req.setTimeout(120000);
        //         Http http = new Http();
        //         HttpResponse res;
        //         if(!Test.isRunningTest()) {
        //             res =  http.send(req);
        //         }
        //         System.debug('@@ Response check' + res);

        //         String jsonReposne = !Test.isRunningTest() ? res.getBody() :
        //                                 testResponseforAvailability;
        //         System.debug('@@ jsonReposne ' + jsonReposne);

        //         reResList.add(reqResLog('QE_H4HHotelProcess', 'h4hAvailbilityHotelSearchCall', null, jsonReposne, req.getEndpoint(), !Test.isRunningTest() ? res.getStatusCode() : 200, hotelOLI.OpportunityId, hotelOLI.Id,'Availability Search'));
                
        //         if(String.isNotBlank(jsonReposne)) {
        //             QE_AvailbilityResponsParse availabilitySearch = QE_AvailbilityResponsParse.parse(jsonReposne.replace('@', ''));
        //             if(availabilitySearch != null && availabilitySearch.ArnResponse != null
        //                 && availabilitySearch.ArnResponse.Availability != null && availabilitySearch.ArnResponse.Availability.HotelAvailability != null
        //                 && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel != null) {
    
        //                 if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan != null
        //                     && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan.size() > 0) {
        //                     //&& availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan.Room != null)  //&& availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan.Room.Description.containsIgnoreCase(hotelOLI.Room_Type_Hotel__c)
        //                     for(QE_AvailbilityResponsParse.RatePlan rtPlan : availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan) {
        //                         if(rtPlan.Room.Description != null && rtPlan.Room.Description.containsIgnoreCase(hotelOLI.Room_Type_Hotel__c)) {
        //                             hotelOLI.H4H_RatePlan_Code__c = rtPlan.Code;
        //                             hotelOLI.H4H_Room_Code__c = rtPlan.Room.Code;

        //                             setProdIds.add(hotelOLI.Product2Id);
                                    
        //                             Rooming_List__c roomList = mapRoomList.get(hotelOLI.Id);
        //                             if(roomList == null) {
        //                                 roomList = createRoomingList(hotelOLI);
        //                             } else {
        //                                 roomList.H4H_RatePlan_Code__c = hotelOLI.H4H_RatePlan_Code__c;
        //                                 roomList.H4H_Room_Code__c = hotelOLI.H4H_Room_Code__c;
        //                             }
        //                             //H4H Hotel Room Hold creation
        //                             h4hRoomHoldCreation(hotelOLI, h4hAPISettings, reResList, roomList);
        //                             lstHotelItems.add(hotelOLI);
        //                             setOpportunityIds.add(hotelOLI.OpportunityId);

        //                             lstRooming.add(roomList);
        //                             break;
        //                         }
        //                     }
        //                 } else if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan != null
        //                             //&& availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Description != null
        //                             && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Description != null
        //                             && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Description.containsIgnoreCase(hotelOLI.Room_Type_Hotel__c)) {

        //                     hotelOLI.H4H_RatePlan_Code__c = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Code;
        //                     hotelOLI.H4H_Room_Code__c = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Code;

        //                     setProdIds.add(hotelOLI.Product2Id);

        //                     Rooming_List__c roomList = mapRoomList.get(hotelOLI.Id);
        //                     if(roomList == null) {
        //                         roomList = createRoomingList(hotelOLI);
        //                     } else {
        //                         roomList.H4H_RatePlan_Code__c = hotelOLI.H4H_RatePlan_Code__c;
        //                         roomList.H4H_Room_Code__c = hotelOLI.H4H_Room_Code__c;
        //                     }
        //                     //H4H Hotel Room Hold creation
        //                     h4hRoomHoldCreation(hotelOLI, h4hAPISettings, reResList, roomList);
        //                     lstHotelItems.add(hotelOLI);
        //                     setOpportunityIds.add(hotelOLI.OpportunityId);
                            
        //                     lstRooming.add(roomList);
        //                 }
        //             }
        //         }
        //     }
        // }
        // if(lstHotelItems.size() > 0) {
        //     Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>([Select Id, CurrencyIsoCode, Primary_Contact__c, Primary_Contact__r.FirstName, Primary_Contact__r.LastName,
        //                                                                     Primary_Contact__r.Email, Primary_Contact__r.Phone, Primary_Contact__r.Country_Code__c,Event__c,Event__r.H4H_Site_Id__c,
        //                                                                     Primary_Contact__r.MailingStreet, Primary_Contact__r.MailingCity, Primary_Contact__r.MailingPostalCode, Primary_Contact__r.MailingCountryCode, Primary_Contact__r.MailingStateCode
        //                                                                     from Opportunity where Id In :setOpportunityIds and ID In (Select Opportunity__c from Opportunity_Payment_Terms__c where Opportunity__c In :setOpportunityIds and Status__c = 'Passed')]);
        //     if(mapOpportunity.size() > 0) {
        //         createReservationAfterHold(mapOpportunity, h4hAPISettings, lstHotelItems, reResList, mapRoomList);
        //     }
            
        //     updateProductInventory(setProdIds, h4hAPISettings, lstHotelItems[0].OpportunityId, reResList);
        //     update lstHotelItems;
        //     if(lstRooming.size() > 0) {
        //         upsert lstRooming;
        //     }
        // }
        // if(reResList.size() > 0) {
        //     insert reResList;
        // }
    }

/***********************************************************
** Method Name: createRoomingList
** Param: OpportunityLineItem hotelOLI
** Return: Rooming_List__c
** Purpose: Built Romming list object
****************************************************************/
    Public static Rooming_List__c createRoomingList(OpportunityLineItem hotelOLI) {
        Rooming_List__c roomList = new Rooming_List__c();
        // roomList.H4H_RatePlan_Code__c = hotelOLI.H4H_RatePlan_Code__c;
        // roomList.H4H_Room_Code__c = hotelOLI.H4H_Room_Code__c;
        // roomList.Number_of_Adults__c = hotelOLI.H4H_Adult_Quantity__c;
        // roomList.Guest_Name__c = hotelOLI.H4H_Client_Name__c;
        // roomList.Opportunity__c = hotelOLI.OpportunityId;
        // roomList.OpportunityLineItem_Id__c = hotelOLI.Id;
        // roomList.H4H_Roomtype_Id__c = hotelOLI.Roomtype_Id__c;
        return roomList;
    }

/***********************************************************
** Method Name: h4hRoomHoldCreation
** Param: OpportunityLineItem hotelOLI, Custom setting h4hAPISettings, Room code from search
** Return: Void
** Purpose: Hotel Hold Creation in H4H
****************************************************************/
    Public static void h4hRoomHoldCreation(OpportunityLineItem hotelOLI, H4H_API_Details__c h4hAPISettings, List<RequestResponse_Log__c> reResList, Rooming_List__c roomList) {
        // if(String.isNotBlank(roomList.H4H_Room_Code__c)) {
        //     HttpRequest req = new HttpRequest();
        //     req.setEndpoint(h4hAPISettings.Hotel_Hold_Creation_End_Point__c +
        //                     'roomTypeId=' + roomList.H4H_Room_Code__c + '&createHold');
        //     System.debug('2222 ' + req.getEndpoint());
        //     req.setMethod('POST');
        //     req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(h4hAPISettings.H4H_Hold_Username__c + ':' + h4hAPISettings.H4H_Hold_Password__c)));

        //     String roomCountPerNight = '1';
            
        //     Date checkOutDate = hotelOLI.Check_Out_Date__c.addDays(-1);
        //     checkOutDate = checkOutDate > hotelOLI.Check_In_Date__c ? checkOutDate : hotelOLI.Check_Out_Date__c;
        //     Integer dayDiffcount = hotelOLI.Check_In_Date__c.daysBetween(checkOutDate);

        //     for(Integer i=0;i<dayDiffcount;i++) {
        //         roomCountPerNight += ',1';
        //     }

        //     String strBody = 'blockDescription=' + hotelOLI.Name + '&roomCountPerNight=' + roomCountPerNight + '&blockStartDate=' + hotelOLI.Check_In_Date__c.format() +
        //                         '&blockEndDate=' + checkOutDate.format() + '&blockReleaseDate=' + hotelOLI.Check_In_Date__c.addDays(-15).format();

        //     req.setBody(strBody);
        //     System.debug('22222@@@Body ' + req.getBody());
           
        //     Http http = new Http();
        //     HttpResponse res;
        //     if(!Test.isRunningTest()) {
        //         res =  http.send(req);
        //     }
        //     System.debug('2222222@@@res ' + res);
        //     String jsonReposne = !Test.isRunningTest() ? res.getBody() :
        //                                 '{ "SiteId": 51745, "EventId": 35064, "EventName": "Test for offline upload", "EventStartDate": "2021-04-30T00:00:00", "RoomTypeId": 522673, "PropertyInfoLink": "https://groups.alliancereservations.com/services/external/property?id=1684628", "Description": "Double Queen. No breakfast included. Rate based on occupancy of 4 persons per room.", "GroupName": "TestNew14042019Opprotunity Test H4H Hotel1", "MaxOccupancy": 4, "BaseOccupancy": 4, "AdultExtraCharge": null, "ChildExtraCharge": 0, "ExtraAdultAge": null, "ReleaseDate": "2021-04-15T00:00:00", "PaymentPolicy": "", "CancellationPolicy": "Cancellation must be received 2 day(s) prior to day of arrival or will result in a penalty of 1 nights room plus tax.", "Contacts": [ { "FullName": "Kalli Sexton", "Email": "kalli.sexton@hotelsforhope.com", "DaytimePhone": "512-691-9555", "EveningPhone": null, "IsPrimary": true } ], "BlockDates": [ { "BlockDate": "2021-04-30T00:00:00", "Rate": 100, "MinimumNights": 1, "QuantityAvailable": 1 }, { "BlockDate": "2021-05-01T00:00:00", "Rate": 100, "MinimumNights": 1, "QuantityAvailable": 1 } ] }';
            
        //     reResList.add(reqResLog('QE_H4HHotelProcess', 'h4hRoomHoldCreation', strBody, jsonReposne, req.getEndpoint(), !Test.isRunningTest() ? res.getStatusCode() : 200, hotelOLI.OpportunityId, hotelOLI.Id,'Hold Creation'));
            
        //     H4HHoldCreationResponse holdCreationRes = new H4HHoldCreationResponse(jsonReposne);
        //     System.debug('@@jsonReposne:: ' + jsonReposne);
        //     System.debug('@@holdCreationRes:: ' + holdCreationRes);

        //     hotelOLI.Roomtype_Id__c = holdCreationRes.RoomTypeId;
        //     roomList.H4H_Roomtype_Id__c = holdCreationRes.RoomTypeId;
        //     hotelOLI.H4H_Hold_Created__c = true;
        // }
    }

/***********************************************************
** Method Name: h4hHoldCancellation
** Param: List of Id of Opportunity
** Return: Void
** Purpose: Hotel Cancellation in H4H
****************************************************************/
    // @future(callout=true)
    Public static void h4hHoldCancellation(List<Id> lstOpportunityIds) {
        // Map<Id, OpportunityLineItem> oppLineItems = new Map<Id, OpportunityLineItem>([Select Roomtype_Id__c,Product2Id,OpportunityId from OpportunityLineItem where OpportunityId In :lstOpportunityIds AND
        //                                                                                 Check_In_Date__c != Null AND Check_Out_Date__c != Null AND Roomtype_Id__c != NUll AND H4H_Hold_Created__c = true]); //AND Product2.RecordType.DeveloperName = 'Hotels'

        // List<Rooming_List__c> roomLists = new List<Rooming_List__c>([Select H4H_Roomtype_Id__c,OpportunityLineItem_Id__c ,Opportunity__c from Rooming_List__c where Opportunity__c In :lstOpportunityIds AND
        //                                                                 H4H_Roomtype_Id__c != Null AND OpportunityLineItem_Id__c != Null]);
        
        // H4H_API_Details__c h4hAPISettings = H4H_API_Details__c.getOrgDefaults();
        // Set<Id> setProdIds = new Set<Id>();
        // List<RequestResponse_Log__c> reResList = new List<RequestResponse_Log__c>();

        // for(Rooming_List__c roomList : roomLists) {
        //     if(oppLineItems.containsKey(roomList.OpportunityLineItem_Id__c)) {
        //         HttpRequest req = new HttpRequest();
        //         req.setEndpoint(h4hAPISettings.Hotel_Hold_Creation_End_Point__c + 'roomTypeId=' + roomList.H4H_Roomtype_Id__c + '&cancelHold');
                
        //         System.debug('@@ cancel Request:: ' + (h4hAPISettings.Hotel_Hold_Creation_End_Point__c + 'roomTypeId=' + roomList.H4H_Roomtype_Id__c + '&cancelHold'));
        //         req.setMethod('GET');
        //         req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(h4hAPISettings.H4H_Hold_Username__c + ':' + h4hAPISettings.H4H_Hold_Password__c)));
                
        //         Http http = new Http();
        //         HttpResponse res;
        //         if(!Test.isRunningTest()) {
        //             res =  http.send(req);
        //         }
        //         System.debug('2222222@@@res ' + res);
        //         String strHead = 'Authorization Basic ' + EncodingUtil.base64Encode(Blob.valueOf(h4hAPISettings.H4H_Hold_Username__c + ':' + h4hAPISettings.H4H_Hold_Password__c));
        //         reResList.add(reqResLog('QE_H4HHotelProcess', 'h4hHoldCancellation', strHead, res == null ? '' : res.getBody(), req.getEndpoint(), !Test.isRunningTest() ? res.getStatusCode() : 200, roomList.Opportunity__c, roomList.OpportunityLineItem_Id__c , 'Hold Cancellation'));
                
        //         if(Test.isRunningTest() || (res != null && res.getStatusCode() == 200)) {
        //             oppLineItems.get(roomList.OpportunityLineItem_Id__c).H4H_Hold_Created__c = false;
        //             setProdIds.add(oppLineItems.get(roomList.OpportunityLineItem_Id__c).Product2Id);
        //         }
        //     }
        // }
        // if(setProdIds.size() > 0) {
        //     updateProductInventory(setProdIds, h4hAPISettings, roomLists[0].Opportunity__c, reResList);
        // }
        // update oppLineItems.values();
        // if(reResList.size() > 0) {
        //     insert reResList;
        // }
    }

/***********************************************************
** Method Name: h4hCreateReservation
** Param: List of Id of Opportunity
** Return: Void
** Purpose: Hotel Reservation Creation in H4H
****************************************************************/
  //  @future(callout=true)
    Public static void h4hCreateReservation(Set<Id> setOpportunityIds) {
        // List<Opportunity> lstOpportunity = new List<Opportunity>([Select Id, CurrencyIsoCode, Primary_Contact__c, Primary_Contact__r.FirstName, Primary_Contact__r.LastName,
        //                                                             Primary_Contact__r.Email, Primary_Contact__r.Phone, Primary_Contact__r.Country_Code__c,Event__c,Event__r.H4H_Site_Id__c,
        //                                                             Primary_Contact__r.MailingStreet, Primary_Contact__r.MailingCity, Primary_Contact__r.MailingPostalCode, Primary_Contact__r.MailingCountryCode, Primary_Contact__r.MailingStateCode,
        //                                                             // (Select Id, Status__c from Opportunity_Payment_Terms__r Order by LastModifiedDate desc),
        //                                                             (Select Id, Name, Hotel_Id__c,Check_In_Date__c,Check_Out_Date__c, Room_Type_Hotel__c, Quantity, H4H_Adult_Quantity__c,H4H_Need_to_Hold__c,
        //                                                             H4H_Itinerary_Id__c, H4H_Reservation_Id__c,H4H_Hold_Created__c, H4H_RatePlan_Code__c, H4H_Reservation_Created__c, H4H_Room_Code__c, Roomtype_Id__c from OpportunityLineItems
        //                                                             where Check_In_Date__c != Null AND Check_Out_Date__c != Null AND Hotel_Id__c != NUll AND H4H_Hold_Created__c = true) //AND H4H_Need_to_Hold__c = false AND Product2.RecordType.DeveloperName = 'Hotels'
        //                                                             from Opportunity where Id In :setOpportunityIds and Id In
        //                                                             (Select OpportunityId from OpportunityLineItem where Check_In_Date__c != Null AND Check_Out_Date__c != Null AND Hotel_Id__c != NUll AND H4H_Hold_Created__c = true)]); //AND Product2.RecordType.DeveloperName = 'Hotels'

        // if(lstOpportunity.size () > 0) {
        //     reservationCreateRequestCommon(lstOpportunity, false);
        // }
    }

/***********************************************************
** Method Name: reservationCreateRequestCommon
** Param: List<Opportunity> to process
** Return: void
** Purpose: Common call process for reservation adn cancellation
****************************************************************/
    Public static void reservationCreateRequestCommon(List<Opportunity> lstOpportunity, Boolean blnNeedToHold) {
        // List<QE_H4H_Credit_Card__c> lstCCards = new List<QE_H4H_Credit_Card__c>([SELECT Id, Card_Number__c, Card_Type__c, Card_Expiration__c, Card_CVV__c, Card_Street_Address__c,
        //                                                                         Card_Holder_Name__c, Card_City__c, Card_Region__c, Card_PostalCode__c, Card_CountryCode__c
        //                                                                         FROM QE_H4H_Credit_Card__c Limit 1]);
        // if(lstCCards.size () > 0) {
        //     H4H_API_Details__c h4hAPISettings = H4H_API_Details__c.getOrgDefaults();
        //     QE_H4H_Credit_Card__c ccInfo = lstCCards[0];
        //     List<OpportunityLineItem> lstOLIsToUpdate = new List<OpportunityLineItem>();
        //     List<RequestResponse_Log__c> reResList = new List<RequestResponse_Log__c>();
            
        //     Map<Id,Rooming_List__c> mapOLIRoomingList = new Map<Id,Rooming_List__c>();
        //     for(Rooming_List__c rl : [Select Id,Opportunity__c,OpportunityLineItem_Id__c,H4H_Room_Code__c,H4H_RatePlan_Code__c,
        //                                 H4H_Itinerary_Id__c,H4H_Roomtype_Id__c,Number_of_Adults__c,Guest_Name__c,H4H_Reservation_Id__c
        //                                 from Rooming_List__c
        //                                 where Opportunity__c In :lstOpportunity]) {
        //         mapOLIRoomingList.put(rl.OpportunityLineItem_Id__c,rl);
        //     }
        //     for(Opportunity opp : lstOpportunity) {
        //         if(opp.Primary_Contact__c != null && opp.Opportunity_Payment_Terms__r != null && opp.Opportunity_Payment_Terms__r.size() > 0) {
        //             Opportunity_Payment_Terms__c oppPayTerm = opp.Opportunity_Payment_Terms__r[0];
        //             for(OpportunityLineItem oppLineItem : opp.OpportunityLineItems) {
        //                 if(oppPayTerm.Status__c == 'Passed' && oppLineItem.H4H_Need_to_Hold__c == blnNeedToHold) {
        //                     String requestEndpoint = reservationCreateRequest(opp, oppLineItem, h4hAPISettings, ccInfo, reResList, mapOLIRoomingList.get(oppLineItem.Id));
        //                     System.debug('@@ Reques body check:: ' + requestEndpoint);
        //                     HttpRequest req = new HttpRequest();
        //                     req.setEndpoint(requestEndpoint);
        //                     System.debug(req.getEndpoint());
        //                     req.setMethod('GET');
        //                     req.setHeader('Content-Type', 'application/json');
        //                     req.setTimeout(100000);
        //                     Http http = new Http();
        //                     HttpResponse res;
        //                     if(!Test.isRunningTest()){
        //                         res =  http.send(req);
        //                     }
        //                     System.debug('@@ Response check:: ' + res);

        //                     String jsonReposne = !Test.isRunningTest() ? res.getBody() : '{"@ReservationID":"reserve123","@ItineraryID":"iter1234"}';
        //                     System.debug('@@ Reservation Responsebody : ' + jsonReposne);
                            
        //                     reResList.add(reqResLog('QE_H4HHotelProcess', 'reservationCreateRequestCommon', null, jsonReposne, req.getEndpoint(), !Test.isRunningTest() ? res.getStatusCode() : 200, opp.Id, oppLineItem.Id,'Reservation Creation'));
                            
        //                     if(String.isNotBlank(jsonReposne) && jsonReposne.containsIgnoreCase('@ItineraryID') && jsonReposne.containsIgnoreCase('@ReservationID')) {
        //                         OpportunityLineItem oli = new OpportunityLineItem(Id=oppLineItem.Id);
        //                         oli.H4H_Reservation_Id__c = jsonReposne.substringBetween('"@ReservationID":"', '"');
        //                         oli.H4H_Itinerary_Id__c = jsonReposne.substringBetween('"@ItineraryID":"', '"');
        //                         oli.H4H_Reservation_Created__c = true;
        //                         lstOLIsToUpdate.add(oli);
        //                         if(mapOLIRoomingList.containsKey(oli.Id)) {
        //                             mapOLIRoomingList.get(oli.Id).H4H_Itinerary_Id__c = oli.H4H_Itinerary_Id__c;
        //                             mapOLIRoomingList.get(oli.Id).H4H_Reservation_Id__c = oli.H4H_Reservation_Id__c;
        //                         }
        //                     }
        //                 } else if((oppPayTerm.Status__c == 'Failed' || oppPayTerm.Status__c == 'Canceled')
        //                             && String.isNotBlank(mapOLIRoomingList.get(oppLineItem.Id).H4H_Itinerary_Id__c) && String.isNotBlank(mapOLIRoomingList.get(oppLineItem.Id).H4H_Reservation_Id__c)) {
        //                     String requestEndpoint = h4hAPISettings.Hotel_Availability_End_Point__c;
        //                     requestEndpoint += 'type=Cancellation&_type=json&username=';

        //                     //Custom setting H4H details API
        //                     requestEndpoint += h4hAPISettings.H4H_username__c;
        //                     requestEndpoint += '&password=' + h4hAPISettings.H4H_password__c;
        //                     requestEndpoint += '&siteid=' + opp.Event__r.H4H_Site_Id__c; //h4hAPISettings.H4H_Site_Id__c;
        //                     requestEndpoint += '&ipAddress=' + h4hAPISettings.IP_Address__c;
        //                     requestEndpoint += '&userAgent=' + h4hAPISettings.User_Agent__c;

        //                     //Reservation details from Opp Line Item
        //                     requestEndpoint += '&itineraryId=' + mapOLIRoomingList.get(oppLineItem.Id).H4H_Itinerary_Id__c;
        //                     requestEndpoint += '&reservationId=' + mapOLIRoomingList.get(oppLineItem.Id).H4H_Reservation_Id__c;

        //                     HttpRequest req = new HttpRequest();
        //                     req.setEndpoint(requestEndpoint);
        //                     req.setTimeout(100000);
        //                     req.setMethod('GET');
        //                     Http http = new Http();
        //                     HttpResponse res;
        //                     if(!Test.isRunningTest()) {
        //                         res =  http.send(req);
        //                     }
        //                     System.debug('@@ Cancellation check' + res);

        //                     String jsonReposne = !Test.isRunningTest() ? res.getBody() : 'Cancled';
        //                     System.debug('@@ Cancellation Responsebody : ' + jsonReposne);
        //                     reResList.add(reqResLog('QE_H4HHotelProcess', 'reservationCreateRequestCommon', null, jsonReposne, req.getEndpoint(), !Test.isRunningTest() ? res.getStatusCode() : 200, opp.Id, oppLineItem.Id,'Reservation Cancellation'));
                            
        //                     if(String.isNotBlank(jsonReposne)) { // && jsonReposne.containsIgnoreCase('"@Success": "true"')
        //                         OpportunityLineItem oli = new OpportunityLineItem(Id=oppLineItem.Id);
        //                         oli.H4H_Canceled__c = true;
        //                         lstOLIsToUpdate.add(oli);
        //                     }
        //                 }
        //             }
        //         }
        //     }
        //     if(lstOLIsToUpdate.size() > 0) {
        //         update lstOLIsToUpdate;
        //         update mapOLIRoomingList.values();
        //     }
        //     if(reResList.size() > 0) {
        //         insert reResList;
        //     }
        // }
    }

/***********************************************************
** Method Name: reservationCreateRequest
** Param: Opportunity, Opportunity Line Item, H4H API Setting,
            QE_H4H_Credit_Card__c Credit Card info for Hotel block
** Return: String of requestr body
** Purpose: Hotel Reservation Creation in request body H4H
****************************************************************/
    Public static String reservationCreateRequest(Opportunity opp, OpportunityLineItem hotelOLI, H4H_API_Details__c h4hAPISettings, QE_H4H_Credit_Card__c ccInfo, List<RequestResponse_Log__c> reResList, Rooming_List__c roomList) {
        //Static hardcode values
        //String requestEndpoint = h4hAPISettings.Hotel_Availability_End_Point__c;
        String requestEndpoint = 'type=Reservation&_type=json&userLanguage=en&gateway=20&username=';

        // //Custom setting H4H details API
        // requestEndpoint += h4hAPISettings.H4H_username__c;
        // requestEndpoint += '&password=' + h4hAPISettings.H4H_password__c;
        // requestEndpoint += '&siteid=' + opp.Event__r.H4H_Site_Id__c; //h4hAPISettings.H4H_Site_Id__c;
        // requestEndpoint += '&ipAddress=' + h4hAPISettings.IP_Address__c;
        // requestEndpoint += '&userAgent=' + h4hAPISettings.User_Agent__c;

        // //Opportunity Line Item
        // requestEndpoint += '&hotelIds=' + hotelOLI.Hotel_Id__c;
        // requestEndpoint += '&inDate=' + String.valueOf(hotelOLI.Check_In_Date__c);
        // requestEndpoint += '&outDate=' + String.valueOf(hotelOLI.Check_Out_Date__c);
        // requestEndpoint += '&ratePlanCode=ARN' + roomList.H4H_Roomtype_Id__c;
        // requestEndpoint += '&roomCode=' + roomList.H4H_Roomtype_Id__c;
        // requestEndpoint += '&adults=' + Integer.valueOf(roomList.Number_of_Adults__c);
        // requestEndpoint += '&rooms=' + Integer.valueOf(hotelOLI.Quantity);
        // requestEndpoint += '&children=0';

        // //Opportunity Primary Contact details
        // requestEndpoint += '&guestFirstName=' + (opp.Primary_Contact__r.FirstName == null ? '' : EncodingUtil.urlEncode(opp.Primary_Contact__r.FirstName, 'UTF-8'));
        // requestEndpoint += '&guestLastName=' + EncodingUtil.urlEncode(opp.Primary_Contact__r.LastName, 'UTF-8');
        // requestEndpoint += '&guestEmail=' + (opp.Primary_Contact__r.Email == null ? '' : EncodingUtil.urlEncode(opp.Primary_Contact__r.Email, 'UTF-8'));
        // requestEndpoint += '&guestPhoneCountry=' + (opp.Primary_Contact__r.Country_Code__c == null ? '' : EncodingUtil.urlEncode(opp.Primary_Contact__r.Country_Code__c, 'UTF-8'));
        // requestEndpoint += '&guestPhoneNumber=' + (opp.Primary_Contact__r.Phone == null ? '' : EncodingUtil.urlEncode(opp.Primary_Contact__r.Phone, 'UTF-8'));
        // requestEndpoint += '&guestPhoneArea=512';
        // //Address
        // requestEndpoint += '&addressAddress=' + (opp.Primary_Contact__r.MailingStreet == null ? '' : EncodingUtil.urlEncode(opp.Primary_Contact__r.MailingStreet, 'UTF-8'));
        // requestEndpoint += '&addressCity=' + (opp.Primary_Contact__r.MailingCity == null ? '' : EncodingUtil.urlEncode(opp.Primary_Contact__r.MailingCity, 'UTF-8'));
        // requestEndpoint += '&addressPostalCode=' + (opp.Primary_Contact__r.MailingPostalCode == null ? '' : EncodingUtil.urlEncode(opp.Primary_Contact__r.MailingPostalCode, 'UTF-8'));
        // requestEndpoint += '&addressCountryCode=' + (opp.Primary_Contact__r.MailingCountryCode == null ? '' : EncodingUtil.urlEncode(opp.Primary_Contact__r.MailingCountryCode, 'UTF-8'));
        // requestEndpoint += '&addressRegion=' + (opp.Primary_Contact__r.MailingStateCode == null ? '' : EncodingUtil.urlEncode(opp.Primary_Contact__r.MailingStateCode, 'UTF-8'));

        // //Price details
        // requestEndpoint += h4hRatePlanInfo(opp.Id, hotelOLI.Id, requestEndpoint, opp.CurrencyIsoCode, h4hAPISettings, reResList);

        // //Credit Card details
        // requestEndpoint += '&creditCardType=' + ccInfo.Card_Type__c;
        // requestEndpoint += '&creditCardNumber=' + ccInfo.Card_Number__c;
        // requestEndpoint += '&creditCardExpiration=' + ccInfo.Card_Expiration__c;
        // requestEndpoint += '&creditCardCVV2=' + ccInfo.Card_CVV__c;
        // requestEndpoint += '&creditCardHolder=' + EncodingUtil.urlEncode(ccInfo.Card_Holder_Name__c, 'UTF-8');
        // requestEndpoint += '&creditCardAddress=' + EncodingUtil.urlEncode(ccInfo.Card_Street_Address__c, 'UTF-8');
        // requestEndpoint += '&creditCardCity=' + EncodingUtil.urlEncode(ccInfo.Card_City__c, 'UTF-8');
        // requestEndpoint += '&creditCardRegion=' + EncodingUtil.urlEncode(ccInfo.Card_Region__c, 'UTF-8');
        // requestEndpoint += '&creditCardPostalCode=' + EncodingUtil.urlEncode(ccInfo.Card_PostalCode__c, 'UTF-8');
        // requestEndpoint += '&creditCardCountryCode=' + EncodingUtil.urlEncode(ccInfo.Card_CountryCode__c, 'UTF-8');

        // requestEndpoint = h4hAPISettings.Hotel_Availability_End_Point__c + requestEndpoint;

        return requestEndpoint;
    }

/***********************************************************
** Method Name: h4hRatePlanInfo
** Param: String request built, String currecycode
** Return: String of Rate details
** Purpose: Get rate details for reservation creation
****************************************************************/
    Public static String h4hRatePlanInfo(Id oppId, Id oliId, String strResponse, String currencyCode, H4H_API_Details__c h4hAPISettings, List<RequestResponse_Log__c> reResList) {
        // strResponse = strResponse.replace('type=Reservation&','');
        // strResponse += '&currency=' + currencyCode;
        // //strResponse = EncodingUtil.urlEncode(strResponse, 'UTF-8');
        
        // strResponse = h4hAPISettings.Hotel_Availability_End_Point__c + strResponse;
        // System.debug('@@ rateplan request: ' + strResponse);

        // HttpRequest req = new HttpRequest();
        // req.setEndpoint(strResponse);
        // req.setMethod('GET');
        // req.setHeader('Content-type','application/json; charset=utf-8');
        // req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(h4hAPISettings.H4H_username__c + ':' + h4hAPISettings.H4H_password__c)));
        // Http http = new Http();
        // System.debug(req);
        // HttpResponse res;
        // if(!Test.isRunningTest()){
        //     res =  http.send(req);
        // }
        
        // String strHead = 'Authorization Basic ' + EncodingUtil.base64Encode(Blob.valueOf(h4hAPISettings.H4H_username__c + ':' + h4hAPISettings.H4H_password__c));

        // String jsonReposne = !Test.isRunningTest() ? res.getBody() : '{"ArnResponse":{"Info":{"@SiteID":"55900","@Username":"aodom@quintevents.com","@IpAddress":"13.108.254.8","@TimeReceived":"2020-01-08T18:48:43.506","@TimeCompleted":"2020-01-08T18:48:43.661","@Version":"1.0.0.0","@ServiceUrl":"¤cy=USD&gateway=20&guestEmail=mgagnon@quintevents.com&guestFirstName=Aaron&guestLastName=Odom&guestPhoneArea=512&guestPhoneCountry=&guestPhoneNumber=704.926.2706&hotelIds=201426&inDate=2020-03-12&ipAddress=12.250.230.226&outDate=2020-03-16&ratePlanCode=ARN605444&roomCode=605444&rooms=1&siteid=55900&userAgent=chrome&userLanguage=en&username=aodom@quintevents.com","@RequestID":"C03B339B-2A1B-4805-8496-621FC86B38D9"},"RateDetails":{"@DisplayCurrency":"USD","HotelRateDetails":{"@InDate":"2020-03-12","@OutDate":"2020-03-16","@Rooms":"1","@Adults":"2","@Children":"0","Hotel":{"@HotelID":"201426","@HotelInfo":"","@Latitude":"-37.82232","@Longitude":"144.95573","@Name":"Crowne Plaza Melbourne","@Address1":"1-5 Spencer Street","@City":"Southbank","@State":"VC","@CountryCode":"AU","@Postal":"3008","@PercentMatch":"0","@ImageThumbnail":"","@LocationDescription":"Near SEA LIFE Melbourne","@TripAdvisorReviewCount":"1839","@TripAdvisorRating":"4.0","@RatingImageUrl":"","@PriceClass":"4 Stars","@PropertyLink":"","RatePlan":{"@Code":"ARN605444","@Description":"","@Gateway":"20","@CommissionStatus":"Commissionable","@BalanceDueAtHotel":"true","Room":{"@Code":"605444","@Name":"2020 F1 Australian Grand Prix","@Description":"","@CurrencyCode":"AUD","@DisplayCurrencyMultiplier":"0.6876018510","@USDMultiplier":"0.6876018510","@ExchangeGMT":"2020-01-08T18:00:03.100","@MaximumBookable":"1","@Refundable":"true","NightlyRate":[{"@Date":"2020-03-12","@Price":"410.00"},{"@Date":"2020-03-13","@Price":"410.00"},{"@Date":"2020-03-14","@Price":"410.00"},{"@Date":"2020-03-15","@Price":"360.00"}],"Tax":{"@Percent":"0.00","@Amount":"0.00"},"GatewayFee":{"@Amount":"0.00"},"Total":{"@Amount":"1590.00","@IncludesBookingFee":"false"},"BookingFee":{"@Amount":"0.00","@CurrencyCode":"USD","@DisplayCurrencyMultiplier":"1","@RoomCurrencyMultiplier":"1.4543300000","@ExchangeGMT":"2020-01-08T18:00:03.100"}},"Policy":{"ExtraPersonPrice":{"@Adult":"0.00","@Child":"0.00","@CurrencyCode":"AUD","@DisplayCurrencyMultiplier":"0.6876018510","@USDMultiplier":"0.6876018510","@ExchangeGMT":"2020-01-08T18:00:03.100"},"Guarantee":{"@Description":"N/A"},"Cancel":{"@Description":" ","@LatestCancelTime":"2020-03-12T13:59:00.000","@GMTOffSet":"0","Fee":{"@Amount":"0.00","@CurrencyCode":"USD","@DisplayCurrencyMultiplier":"1","@RoomCurrencyMultiplier":"1.4543300000","@ExchangeGMT":"2020-01-08T18:00:08.367"},"Penalty":{"@Amount":"0.00","@CurrencyCode":"AUD","@DisplayCurrencyMultiplier":"0.6876018510","@USDMultiplier":"0.6876018510","@ExchangeGMT":"2020-01-08T18:00:03.100"}},"Deposit":{"@Description":"Deposit required. See Payment Policy."},"ExtraFees":{"@Description":""},"Payment":{"@Description":""},"Property":[{"@Description":"Ch","@Value":"2 PM"},{"@Description":"C","@Value":"11 AM"}]}}}}}}}';
        // System.debug('@@ Room Rate get request body : ' + jsonReposne);

        // reResList.add(reqResLog('QE_H4HHotelProcess', 'h4hRatePlanInfo', strHead, jsonReposne, req.getEndpoint(), !Test.isRunningTest() ? res.getStatusCode() : 200, oppId, oliId,'Rate Plan info Request'));

        // /*jsonReposne = jsonReposne.replace('"NightlyRate":[{"@Date":"','"NightlyRate":{"@Date":"');
        // String dt = jsonReposne.substringBetween('"NightlyRate":{"@Date":"', '",');
        
        // String nightRate = jsonReposne.substringBetween('"NightlyRate":{"@Date":"' + dt + '","@Price":"', '"}');

        // String perc = jsonReposne.substringBetween('"Tax":{"@Percent":"', '",');
        // String taxAmount = jsonReposne.substringBetween('"Tax":{"@Percent":"' + perc + '","@Amount":"', '"}');

        // String gatewayFee = jsonReposne.substringBetween('"GatewayFee":{"@Amount":"', '"}');

        // String bookingFees = jsonReposne.substringBetween('"BookingFee":{"@Amount":"', '"');

        // String totalAmount = jsonReposne.substringBetween('"Total":{"@Amount":"', '"');*/
        
        // QE_H4HRatePlanResponse objH4HRatePlanInfo = QE_H4HRatePlanResponse.parse(jsonReposne);
        // QE_H4HRatePlanResponse.Room room = objH4HRatePlanInfo.ArnResponse.RateDetails.HotelRateDetails.Hotel.RatePlan.Room;
        
        // String nightRate = room.objNightlyRate != null ? room.objNightlyRate.Price : room.NightlyRate[0].Price;
        // String taxAmount = room.Tax.Amount;
        // String gatewayFee = room.GatewayFee.Amount;
        // String roomcurrencyCode = room.CurrencyCode;
        // String bookingFees = room.BookingFee.Amount;
        // String totalAmount = room.Total.Amount;
        // String bookingFeeCurrencyCode = room.BookingFee.CurrencyCode;

        // String requestEndpoint = '&roomCostPrice=' + nightRate;
        // requestEndpoint += '&roomCostTaxAmount=' + taxAmount;
        // requestEndpoint += '&roomCostGatewayFee=' + gatewayFee;
        // requestEndpoint += '&roomCostTotalAmount=' + totalAmount;
        // requestEndpoint += '&roomCostCurrencyCode=' + roomcurrencyCode;
        // requestEndpoint += '&bookingFeeAmount=' + bookingFees;
        // requestEndpoint += '&bookingFeeCurrencyCode=' + bookingFeeCurrencyCode;
        // return requestEndpoint;
        return '';
    }
    
/***********************************************************
** Method Name: createReservationAfterHold
** Param: Map Opp passed, H4H setting, Holded OppLineItem, Req Res Log, Roomming List Map
** Return: void
** Purpose: Create Reservation for Hold Immediate
****************************************************************/
    Public static void createReservationAfterHold(Map<Id,Opportunity> mapOppPassed, H4H_API_Details__c h4hAPISettings, List<OpportunityLineItem> lstOPLIs, List<RequestResponse_Log__c> reResList, Map<Id,Rooming_List__c> mapOLIRoomingList) {

        // List<QE_H4H_Credit_Card__c> lstCCards = new List<QE_H4H_Credit_Card__c>([SELECT Id, Card_Number__c, Card_Type__c, Card_Expiration__c, Card_CVV__c, Card_Street_Address__c,
        //                                                                         Card_Holder_Name__c, Card_City__c, Card_Region__c, Card_PostalCode__c, Card_CountryCode__c
        //                                                                         FROM QE_H4H_Credit_Card__c Limit 1]);
        // if(lstCCards.size () > 0) {
        //     QE_H4H_Credit_Card__c ccInfo = lstCCards[0];
        //     for(OpportunityLineItem oppLineItem : lstOPLIs) {
        //         Opportunity opp = mapOppPassed.get(oppLineItem.OpportunityId);
        //         if(opp != null && opp.Primary_Contact__c != null && oppLineItem.H4H_Need_to_Hold__c == false) {
        //             String requestEndpoint = reservationCreateRequest(opp, oppLineItem, h4hAPISettings, ccInfo, reResList, mapOLIRoomingList.get(oppLineItem.Id));
        //             System.debug('@@ Reques body check:: ' + requestEndpoint);
        //             HttpRequest req = new HttpRequest();
        //             req.setEndpoint(requestEndpoint);
        //             System.debug(req.getEndpoint());
        //             req.setMethod('GET');
        //             req.setHeader('Content-Type', 'application/json');
        //             req.setTimeout(100000);
        //             Http http = new Http();
        //             HttpResponse res;
        //             if(!Test.isRunningTest()){
        //                 res = http.send(req);
        //             }
        //             System.debug('@@ Response check holdreserve:: ' + res);

        //             String jsonReposne = !Test.isRunningTest() ? res.getBody() : '{"@ReservationID":"reserve123","@ItineraryID":"iter1234"}';
        //             System.debug('@@ Hold Reservation Responsebody : ' + jsonReposne);
                    
        //             reResList.add(reqResLog('QE_H4HHotelProcess', 'createReservationAfterHold', null, jsonReposne, req.getEndpoint(), !Test.isRunningTest() ? res.getStatusCode() : 200, opp.Id, oppLineItem.Id, 'Reservation Creation'));
                    
        //             if(String.isNotBlank(jsonReposne) && jsonReposne.containsIgnoreCase('@ItineraryID') && jsonReposne.containsIgnoreCase('@ReservationID')) {
        //                 oppLineItem.H4H_Reservation_Id__c = jsonReposne.substringBetween('"@ReservationID":"', '"');
        //                 oppLineItem.H4H_Itinerary_Id__c = jsonReposne.substringBetween('"@ItineraryID":"', '"');
        //                 oppLineItem.H4H_Reservation_Created__c = true;
        //                 if(mapOLIRoomingList.containsKey(oppLineItem.Id)) {
        //                     mapOLIRoomingList.get(oppLineItem.Id).H4H_Itinerary_Id__c = oppLineItem.H4H_Itinerary_Id__c;
        //                     mapOLIRoomingList.get(oppLineItem.Id).H4H_Reservation_Id__c = oppLineItem.H4H_Reservation_Id__c;
        //                 }
        //             }
        //         }
        //     }
        // }
    }

/***********************************************************
** Method Name: updateProductInventory
** Param: Set prod Ids, H4H setting
** Return: void
** Purpose: update product inventory
****************************************************************/
    Public static void updateProductInventory(Set<Id> prodIds, H4H_API_Details__c h4hAPISettings, Id oppId, List<RequestResponse_Log__c> reResList) {
        reqResLog(null,null,null,null,null,null,null,null,null);
        // List<Product2> products = new List<Product2>([Select Id,Name,CurrencyIsoCode,Event__c,Event__r.H4H_Site_Id__c,Type__c,
        //                                                 Hotel_Id__c,Check_In_Date__c,Check_Out_Date__c,H4H_RatePlan_Code__c,H4H_Room_Code__c
        //                                                 from Product2
        //                                                 where Id In :prodIds AND Check_Out_Date__c != null AND Check_In_Date__c != null AND Hotel_Id__c != null]);

        // List<Product2> productsToUpdate = new List<Product2>();

        // for(Product2 prod : products) {
        //     HttpRequest req = new HttpRequest();
        //     req.setEndpoint(h4hAPISettings.Hotel_Availability_End_Point__c +
        //                     'inDate=' + String.valueOf(prod.Check_In_Date__c) +
        //                     '&outDate=' + String.valueOf(prod.Check_Out_Date__c) +
        //                     '&username=' + h4hAPISettings.H4H_username__c +
        //                     '&password=' + h4hAPISettings.H4H_password__c +
        //                     '&siteid=' + prod.Event__r.H4H_Site_Id__c + //h4hAPISettings.H4H_Site_Id__c +
        //                     '&rooms=1' + //prod.Quantity + //1' +
        //                     '&adults=2' + //hotelOLI.H4H_Adult_Quantity__c + //2' +
        //                     '&children=0' +
        //                     '&ipAddress=' + h4hAPISettings.IP_Address__c +
        //                     '&userAgent=' + h4hAPISettings.User_Agent__c +
        //                     '&userLanguage=en' +
        //                     '&_type=json' +
        //                     '&gateway=16' +
        //                     '&hotelids=' + prod.Hotel_Id__c);
        //     System.debug(req.getEndpoint());
        //     req.setMethod('GET');
        //     req.setHeader('Content-type','application/x-www-form-urlencoded');
        //     req.setTimeout(60000);
        //     Http http = new Http();
        //     HttpResponse res;
        //     if(!Test.isRunningTest()) {
        //         res =  http.send(req);
        //     }
        //     System.debug('@@ Response check' + res);

        //     String jsonReposne = !Test.isRunningTest() ? res.getBody() :
        //                             testResponseforAvailability;
        //     System.debug('@@ jsonReposne ' + jsonReposne);
            
        //     reResList.add(reqResLog('QE_H4HHotelProcess', 'updateProductInventory', null, jsonReposne, req.getEndpoint(), !Test.isRunningTest() ? res.getStatusCode() : 200, oppId, prod.Id,'Product Inventory Updates'));

        //     if(String.isNotBlank(jsonReposne)) {
        //         QE_AvailbilityResponsParse availabilitySearch = QE_AvailbilityResponsParse.parse(jsonReposne.replace('@', ''));
        //         if(availabilitySearch != null && availabilitySearch.ArnResponse != null
        //             && availabilitySearch.ArnResponse.Availability != null && availabilitySearch.ArnResponse.Availability.HotelAvailability != null
        //             && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel != null) {
                    
        //             Id stayRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Stay').getRecordTypeId();
        //             Product2 stayProd;

        //             if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan != null
        //                 && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan.size() > 0) {

        //                 for(QE_AvailbilityResponsParse.RatePlan rtPlan : availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan) {
        //                     if(rtPlan.Room != null && (prod.H4H_RatePlan_Code__c == rtPlan.Code || prod.H4H_Room_Code__c == rtPlan.Room.Code)) {
        //                         stayProd = new Product2(Id=prod.Id);
        //                         stayProd.Inventory__c = Integer.valueOf(rtPlan.Room.MaximumBookable);
        //                         productsToUpdate.add(stayProd);
        //                     }
        //                 }
        //             } else if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan != null
        //                         //&& availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Description != null
        //                         && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Description != null
        //                         && 
        //                         (prod.H4H_RatePlan_Code__c == availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Code
        //                         || prod.H4H_Room_Code__c == availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Code)) {

        //                 stayProd = new Product2(Id=prod.Id);
        //                 stayProd.Inventory__c = Integer.valueOf(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.MaximumBookable);

        //                 productsToUpdate.add(stayProd);
        //             }
        //         }
        //     }
        // }
        // if(productsToUpdate.size() > 0) {
        //     update productsToUpdate;
        // }
    }

    public static RequestResponse_Log__c reqResLog(String clsName,String mthName, String req, String res, String url,Integer code,Id OppId,Id relatedId,String msgType){
        RequestResponse_Log__c ReqResObj = new RequestResponse_Log__c();
        H4HHoldCreationResponse objTest = new H4HHoldCreationResponse(null);
        // ReqResObj.Class_Name__c = clsName;
        // ReqResObj.Method_Name__c = mthName;
        // ReqResObj.Opportunity__c = OppId;
        // ReqResObj.H4H_End_Point__c = url;
        // ReqResObj.Status_Code__c = String.valueOf(code);
        // ReqResObj.Request__c = req;
        // ReqResObj.Response__c = res;
        // ReqResObj.Message_Type__c = msgType;
        
        // if(relatedId != null) {
        //     String sObjName = relatedId.getSObjectType().getDescribe().getName();
        //     if(sObjName == 'Product2') {
        //         ReqResObj.Product__c = relatedId;
        //     } else if(sObjName == 'OpportunityLineItem') {
        //         ReqResObj.Opportunity_Product_Id__c = relatedId;
        //     }
        // }
        return ReqResObj;
    }

    public class H4HHoldCreationResponse {

        // public String RoomTypeId {get;set;}

        public H4HHoldCreationResponse(String json) {
            consumeObject(null);
            // System.JSONParser parser = System.JSON.createParser(json);
            // while(parser.nextToken() != System.JSONToken.END_OBJECT) {
            //     if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
            //         String text = parser.getText();
            //         if(parser.nextToken() != System.JSONToken.VALUE_NULL) {
            //             if(text == 'RoomTypeId') {
            //                 RoomTypeId = String.valueOf(parser.getIntegerValue());
            //             } else {
            //                 consumeObject(parser);
            //             }
            //         }
            //     }
            // }
        }

        public void consumeObject(System.JSONParser parser) {
            // Integer depth = 0;
            // do {
            //     System.JSONToken curr = parser.getCurrentToken();
            //     if (curr == System.JSONToken.START_OBJECT ||
            //         curr == System.JSONToken.START_ARRAY) {
            //         depth++;
            //     } else if (curr == System.JSONToken.END_OBJECT ||
            //         curr == System.JSONToken.END_ARRAY) {
            //         depth--;
            //     }
            // } while (depth > 0 && parser.nextToken() != null);
        }
    }
}
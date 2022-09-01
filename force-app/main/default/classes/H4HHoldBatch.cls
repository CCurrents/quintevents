/**
 * @File Name          : H4HHoldBatch.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/1/2020, 3:09:19 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/21/2020   jagrawal@addonblue.com     Initial Version
**/
public class H4HHoldBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	Set<Id> roomingListIds;
    List<Rooming_List__c> lstRoomList;
    List<RequestResponse_Log__c> reResList;
    public Boolean isReservationCreate;

    /**
    * @description constructor
    * @author jagrawal@addonblue.com | 2/28/2020 
    **/
    public H4HHoldBatch(Set<Id> roomingListIds,Boolean isReservationCreate){ 
        this.roomingListIds = roomingListIds;
        lstRoomList = new List<Rooming_List__c>();
        reResList = new List<RequestResponse_Log__c>();
        this.isReservationCreate = isReservationCreate;
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 2/28/2020 
    * @param Database.BatchableContext BC 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id,Quote__c,QuoteLineItem_Id__c,Product__c,Check_In_Date__c,Check_Out_Date__c,H4H_RoomCode__c,H4H_Hold_Created__c,Guest_Name__c,H4H_Roomtype_Id__c,H4H_Reservation_Created__c, H4H_Reservation_Id__c,H4H_Itinerary_Id__c from Rooming_List__c where Id In: roomingListIds AND H4H_Hold_Created__c = false');
    }


    /**
    * @description 
    * @author jagrawal@addonblue.com | 2/28/2020 
    * @param Database.BatchableContext BC 
    * @param List<QuoteLineItem> scope 
    * @return void 
    **/
    public void execute(Database.BatchableContext BC, List<Rooming_List__c> scope){
        System.debug('Create Hold');
        H4H_API_Details__c h4hAPISettings = H4H_API_Details__c.getOrgDefaults();
        for(Rooming_List__c roomList: scope){
            System.debug('roomList-->'+roomList);
            if(String.isNotBlank(roomList.H4H_RoomCode__c)) { 
                HttpRequest req = new HttpRequest();
                req.setEndpoint(h4hAPISettings.Hotel_Hold_Creation_End_Point__c + 'roomTypeId=' + roomList.H4H_RoomCode__c + '&createHold');
                System.debug('h4hRoomHoldCreation_request_endpoint:- ' + req.getEndpoint());
                req.setMethod('POST');
                req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(h4hAPISettings.H4H_Hold_Username__c + ':' + h4hAPISettings.H4H_Hold_Password__c)));
                
                String roomCountPerNight = '1';
                Integer dayDiffcount = roomList.Check_In_Date__c.daysBetween(roomList.Check_Out_Date__c);
                
                for(Integer i=0;i<dayDiffcount;i++) {
                    roomCountPerNight += ',1';
                }
                
                String strBody = 'blockDescription=' + roomList.Guest_Name__c + '&roomCountPerNight=' + roomCountPerNight + '&blockStartDate=' + roomList.Check_In_Date__c.format() +
                    '&blockEndDate=' + roomList.Check_Out_Date__c.format() + '&blockReleaseDate=' + roomList.Check_In_Date__c.addDays(-15).format();// + '&groupName=' + roomList.Guest_Name__c;
                
                req.setBody(strBody);
                System.debug('h4hRoomHoldCreation_request_body:- ' + req.getBody());
                
                Http http = new Http();
                HttpResponse res;
                if(!Test.isRunningTest()) {
                    res =  http.send(req);
                }
                System.debug('h4hRoomHoldCreation_response:- ' + res);
                
                String jsonReposne = !Test.isRunningTest() ? res.getBody() :
                '{ "SiteId": 51745, "EventId": 35064, "EventName": "Test for offline upload", "EventStartDate": "2021-04-30T00:00:00", "RoomTypeId": 522673,'+
                    ' "PropertyInfoLink": "https://groups.alliancereservations.com/services/external/property?id=1684628",'+
                    ' "Description": "Double Queen. No breakfast included. Rate based on occupancy of 4 persons per room.", "GroupName": "TestNew14042019Opprotunity Test H4H Hotel1",'+
                    ' "MaxOccupancy": 4, "BaseOccupancy": 4, "AdultExtraCharge": null, "ChildExtraCharge": 0, "ExtraAdultAge": null, "ReleaseDate": "2021-04-15T00:00:00",'+
                    ' "PaymentPolicy": "", "CancellationPolicy": "Cancellation must be received 2 day(s) prior to day of arrival or will result in a penalty of 1 nights room plus tax.",'+
                    ' "Contacts": [ { "FullName": "Kalli Sexton", "Email": "kalli.sexton@hotelsforhope.com", "DaytimePhone": "512-691-9555", "EveningPhone": null,'+
                    ' "IsPrimary": true } ], "BlockDates": [ { "BlockDate": "2021-04-30T00:00:00", "Rate": 100, "MinimumNights": 1, "QuantityAvailable": 1 },'+
                    ' { "BlockDate": "2021-05-01T00:00:00", "Rate": 100, "MinimumNights": 1, "QuantityAvailable": 1 } ] }';
                
                reResList.add(Utility.reqResLog('H4HHoldBatch', 'Execute', strBody, jsonReposne, req.getEndpoint(), !Test.isRunningTest() ? res.getStatusCode() : 200, roomList.Id, roomList.Product__c,'Hold Creation'));
                
                H4HUtility.H4HHoldCreationResponse holdCreationRes = new H4HUtility.H4HHoldCreationResponse(jsonReposne);
                System.debug('@@jsonReposne:: ' + jsonReposne);
                System.debug('@@holdCreationRes:: ' + holdCreationRes);
                if(holdCreationRes.RoomTypeId != null && holdCreationRes.RoomTypeId != ''){
                    roomList.H4H_Roomtype_Id__c = holdCreationRes.RoomTypeId;
                    roomList.H4H_Hold_Created__c = true;
                    lstRoomList.add(roomList);
                }
            }
        }
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 2/28/2020 
    * @param Database.BatchableContext BC 
    * @return void 
    **/
    public void finish(Database.BatchableContext BC){
        if(reResList.size()>0){
            Utility.processRecords(reResList, 'insert');
        }
        
        if(lstRoomList.size()>0){
            Utility.processRecords(lstRoomList, 'update');
        } 

        if(isReservationCreate == true){
            H4HReservationBatch objH4Hbatch = new H4HReservationBatch();
            Database.executeBatch(objH4Hbatch, 100);
        }
    }
}
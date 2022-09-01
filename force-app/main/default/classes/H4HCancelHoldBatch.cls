/**
 * @File Name          : H4HCancelHoldBatch.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/4/2020, 6:32:03 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/24/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class H4HCancelHoldBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    Set<Id> roomingListIds;
    List<Rooming_List__c> lstRoomList;
    List<RequestResponse_Log__c> reResList;

    public H4HCancelHoldBatch(Set<Id> roomingListIds){
        this.roomingListIds = roomingListIds;
        lstRoomList = new List<Rooming_List__c>();
        reResList = new List<RequestResponse_Log__c>();
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id, H4H_Roomtype_Id__c, Quote__c from Rooming_List__c where Id In: roomingListIds AND H4H_Roomtype_Id__c != null AND H4H_Reservation_Id__c = null');
    }

    public void execute(Database.BatchableContext BC, List<Rooming_List__c> scope){
        H4H_API_Details__c h4hAPISettings = H4H_API_Details__c.getOrgDefaults();
        for(Rooming_List__c roomList: scope){
            HttpRequest req = new HttpRequest();
            req.setEndpoint(h4hAPISettings.Hotel_Hold_Creation_End_Point__c + 'roomTypeId=' + roomList.H4H_Roomtype_Id__c + '&cancelHold');
            System.debug('h4hRoomHoldCancellation_request_endpoint:- ' + req.getEndpoint());
            req.setMethod('POST');
            req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(h4hAPISettings.H4H_Hold_Username__c + ':' + h4hAPISettings.H4H_Hold_Password__c)));

            String strBody = 'cancellationReason=\'It was a testing record.\'';
            
            req.setBody(strBody);
            System.debug('h4hRoomHoldCancellation_request_body:- ' + req.getBody());

            Http http = new Http();
            HttpResponse res;
            if(!Test.isRunningTest()) {
                res =  http.send(req);
            }
            System.debug('h4hRoomHoldCreation_response:- ' + res);
            
            String jsonReposne = !Test.isRunningTest() ? res.getBody(): 'https://groups.alliancereservations.com/services/external/roomtypesonhold?&roomTypeId=111111';
            reResList.add(Utility.reqResLog('H4HCancelHoldBatch', 'execute', strBody, jsonReposne, req.getEndpoint(), !Test.isRunningTest() ? res.getStatusCode() : 200, roomList.Quote__c, null,'Hold Cancellation'));
            System.debug('@@jsonReposne:: ' + jsonReposne);
                roomList.H4H_Roomtype_Id__c = null;
                roomList.H4H_Hold_Created__c = false;
                lstRoomList.add(roomList);
            
        }
    }


    public void finish(Database.BatchableContext BC){
        if(reResList.size()>0){
            Utility.processRecords(reResList, 'insert');
        }
        
        if(lstRoomList.size()>0){
            Utility.processRecords(lstRoomList, 'update');
        }
    }

}
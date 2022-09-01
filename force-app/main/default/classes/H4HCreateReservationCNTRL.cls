/**
 * @File Name          : H4HCreateReservationCNTRL.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/10/2020, 12:07:16 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/21/2020   jagrawal@addonblue.com     Initial Version
**/
public class H4HCreateReservationCNTRL {
     
    /**
    * @description: method for fetching rooming list.
    * @author jagrawal@addonblue.com | 2/28/2020 
    * @param String currentRecordId 
    * @return QuoteLineItem 
    **/
    @AuraEnabled
    public static Rooming_List__c featchRoomList(String currentRecordId){
        Rooming_List__c roomdata = new Rooming_List__c();
        Rooming_List__c roomitm = new Rooming_List__c();
        List<Rooming_List__c> roomlist = [Select Id,Quote__c,QuoteLineItem_Id__c,H4H_RoomCode__c,H4H_RatePlan_Code__c,H4H_Hold_Created__c,
                                        H4H_Itinerary_Id__c,H4H_Roomtype_Id__c,Number_of_Adults__c,Guest_Name__c,H4H_Reservation_Id__c
                                          from Rooming_List__c where Id =:currentRecordId AND H4H_Reservation_Created__c = false AND Check_In_Date__c != Null AND Check_Out_Date__c != Null];
        if(roomlist.size()>0){
            roomdata = roomlist[0];
            if(roomdata.H4H_Hold_Created__c == true){
                List<Rooming_List__c> lstRoomlist = new List<Rooming_List__c>([Select Id,Quote__c,QuoteLineItem_Id__c,H4H_RoomCode__c,H4H_RatePlan_Code__c,H4H_Hold_Created__c,
                                                                            H4H_Itinerary_Id__c,H4H_Roomtype_Id__c,Number_of_Adults__c,Guest_Name__c,H4H_Reservation_Id__c
                                                                            from Rooming_List__c where Id =: roomlist[0].Id AND Check_In_Date__c != Null AND Check_Out_Date__c != Null]);
                if(lstRoomlist.size() > 0){
                    roomitm = lstRoomlist[0];
                    return roomitm;
                }
                else if(lstRoomlist.size() == 0){ throw new AuraHandledException('Check In Date, Check Out Date and Hotel Id in Rooming List are required.'); } return null; } else{ throw new AuraHandledException('Please Create a Hold before creating Reservation'); }
        }
        else{
            return null;
        }
        
    }
    
    /**
    * @description: method for create reservation
    * @author jagrawal@addonblue.com | 2/28/2020 
    * @param String currentRecordId 
    * @param QuoteLineItem quotelist 
    * @return String 
    **/
    @AuraEnabled
    public static String createReservationAndRedirect(String currentRecordId,Rooming_List__c roominglist) {
        try{

        Map<Id,Rooming_List__c> mapQLIRoomingList = new Map<Id,Rooming_List__c>();
        List<RequestResponse_Log__c> reResList = new List<RequestResponse_Log__c>();
        List<Rooming_List__c> lstRoomList = new List<Rooming_List__c>();
        List<QE_H4H_Credit_Card__c> lstCCards = new List<QE_H4H_Credit_Card__c>([SELECT Id, Card_Number__c, Card_Type__c, Card_Expiration__c, Card_CVV__c, Card_Street_Address__c,
                                                                                 Card_Holder_Name__c, Card_City__c, Card_Region__c, Card_PostalCode__c, Card_CountryCode__c
                                                                                 FROM QE_H4H_Credit_Card__c Limit 1]);
        system.debug('lstCCards--->'+lstCCards);
        if(lstCCards.size () > 0) {
            H4H_API_Details__c h4hAPISettings = H4H_API_Details__c.getOrgDefaults();
            QE_H4H_Credit_Card__c ccInfo = lstCCards[0];
            for(Rooming_List__c roomlst : [Select Id,Quote__c,QuoteLineItem_Id__c,CurrencyIsoCode,Product__c, H4H_RoomCode__c,H4H_RatePlan_Code__c,
                                           Quote__r.Opportunity.Pricebook2.H4H_Site_Id__c, Quote__r.CurrencyIsoCode, 
                                           H4H_Itinerary_Id__c,H4H_Roomtype_Id__c,Number_of_Adults__c,Guest_Name__c,H4H_Reservation_Id__c, H4H_Reservation_Created__c, H4H_Hotel_Id__c, 
                                           Check_In_Date__c, Check_Out_Date__c, Quantity__c, Product__r.Primary_Price_Book__r.H4H_Site_Id__c 
                                               from Rooming_List__c where Id =: roominglist.Id AND H4H_Reservation_Created__c = false AND H4H_Hold_Created__c = true ]) {
                                               mapQLIRoomingList.put(roomlst.Quote__c,roomlst);
                                           }
            system.debug('mapQLIRoomingList-->'+mapQLIRoomingList);
            Map<Id,Order> mapOrder = new Map<Id,Order>();
            List<Order> lstOrders = [Select Id,QuoteId,BillingAddress,Billing_City__c,Billing_Zip_Postal_Code__c,Billing_Street__c,Billing_Country__c,Billing_State_Province__c from Order where QuoteId IN: mapQLIRoomingList.keySet()];
            System.debug('lstOrders-->'+lstOrders);
            for(Order orderobj : lstOrders){
                mapOrder.put(orderobj.QuoteId,orderobj);
            }
            for(Rooming_List__c objroomlist : mapQLIRoomingList.values()){
                system.debug('reservation');
                    QuoteLineItem qli = new QuoteLineItem();
                        if(mapOrder.get(objroomlist.Quote__c) != null){
                            String requestEndpoint = H4HUtility.reservationCreateRequest(h4hAPISettings, ccInfo, reResList, objroomlist, mapOrder.get(objroomlist.Quote__c));
                            System.debug('@@ Reques body check:: ' + requestEndpoint);
                            HttpRequest req = new HttpRequest();
                            req.setEndpoint(requestEndpoint);
                            System.debug(req.getEndpoint());
                            req.setMethod('GET');
                            req.setHeader('Content-Type', 'application/json');
                            req.setTimeout(100000);
                            system.debug('req-->'+req);
                            Http http = new Http();
                            HttpResponse res;
                            if(!Test.isRunningTest()){ res =  http.send(req); }
                            System.debug('@@ Response check:: ' + res);
                            
                            String jsonReposne = !Test.isRunningTest() ? res.getBody() : '{"@ReservationID":"reserve123","@ItineraryID":"iter1234"}';
                            System.debug('@@ Reservation Responsebody : ' + jsonReposne);
                            
                            reResList.add(Utility.reqResLog('H4HCreateReservationCNTRL', 'createReservationAndRedirect', null, jsonReposne, req.getEndpoint(), !Test.isRunningTest() ? res.getStatusCode() : 200, objroomlist.Quote__c, objroomlist.QuoteLineItem_Id__c,'Reservation Creation'));
                            
                            if(String.isNotBlank(jsonReposne) && jsonReposne.containsIgnoreCase('@ItineraryID') && jsonReposne.containsIgnoreCase('@ReservationID')) {
                               
                                   Rooming_List__c roomlist = new Rooming_List__c(Id=objroomlist.Id);
                                   roomlist.H4H_Itinerary_Id__c = jsonReposne.substringBetween('"@ReservationID":"', '"');
                                   roomlist.H4H_Reservation_Id__c = jsonReposne.substringBetween('"@ItineraryID":"', '"');
                                   //when Reservation Id is generated H4H_Reservation_Created__c is true
                                   roomlist.H4H_Reservation_Created__c = true;
                                   lstRoomList.add(roomlist);
                                   System.debug('lstRoomList-->'+lstRoomList);
                               
                            }
                        } 
            }
        }
            if(reResList.size() > 0) {
                Utility.processRecords(reResList, 'insert');
            }
            System.debug('lstRoomList-->'+lstRoomList);
            if(lstRoomList.size() > 0) {
                Utility.processRecords(lstRoomList, 'update');
            }
            String retValue = 'Done';
            return retValue;
        }
        catch(Exception e){ throw new AuraHandledException('Please Create a new Hold'); }
    }
}
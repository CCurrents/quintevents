/**
 * @File Name          : H4HReservationBatch.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/1/2020, 4:06:34 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/23/2020   jagrawal@addonblue.com     Initial Version
**/
public class H4HReservationBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    public Map<Id,Rooming_List__c> mapQLIRoomingList;
    public Map<Id,Quote> mapQuote;
    public Set<Id> setProduct;
    public Date objdate;
    public List<RequestResponse_Log__c> reResList;
    public List<QuoteLineItem> lstOLIsToUpdate; 
    public List<Rooming_List__c> lstRoomList;
    private String query;
    
    public H4HReservationBatch(Set<Id> setProduct){
        this.setProduct = setProduct;
        objdate= Date.today().addDays(+2);
        mapQLIRoomingList = new Map<Id,Rooming_List__c>();
        mapQuote = new Map<Id,Quote>();
        reResList = new List<RequestResponse_Log__c>();
        lstOLIsToUpdate = new List<QuoteLineItem>();
        lstRoomList = new List<Rooming_List__c>();
        this.query = 'Select Id,Block_Release_Date__c,Current_Inventory__c from Product2 where RecordType.Name = \'Hotel Stay\' AND Block_Release_Date__c =: objdate AND Id IN: setProduct';
    }

    public H4HReservationBatch(){
        objdate= Date.today().addDays(+2);
        mapQLIRoomingList = new Map<Id,Rooming_List__c>();
        mapQuote = new Map<Id,Quote>();
        reResList = new List<RequestResponse_Log__c>();
        lstOLIsToUpdate = new List<QuoteLineItem>();
        lstRoomList = new List<Rooming_List__c>();
        this.query = 'Select Id,Block_Release_Date__c,Current_Inventory__c from Product2 where RecordType.Name = \'Hotel Stay\' AND Block_Release_Date__c =: objdate';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Product2> scope){
          
        List<QE_H4H_Credit_Card__c> lstCCards = new List<QE_H4H_Credit_Card__c>([SELECT Id, Card_Number__c, Card_Type__c, Card_Expiration__c, Card_CVV__c, Card_Street_Address__c,
                                                                                 Card_Holder_Name__c, Card_City__c, Card_Region__c, Card_PostalCode__c, Card_CountryCode__c
                                                                                 FROM QE_H4H_Credit_Card__c Limit 1]);
        system.debug('lstCCards--->'+lstCCards);
        if(lstCCards.size () > 0) {
            H4H_API_Details__c h4hAPISettings = H4H_API_Details__c.getOrgDefaults();
            QE_H4H_Credit_Card__c ccInfo = lstCCards[0];
            System.debug('scope-->'+scope);
            for(Rooming_List__c roomlst : [Select Id,Quote__c,QuoteLineItem_Id__c,CurrencyIsoCode,Product__c, H4H_RoomCode__c,H4H_RatePlan_Code__c,
                                           Quote__r.Opportunity.Pricebook2.H4H_Site_Id__c, Quote__r.CurrencyIsoCode, 
                                           H4H_Itinerary_Id__c,H4H_Roomtype_Id__c,Number_of_Adults__c,Guest_Name__c,H4H_Reservation_Id__c, H4H_Reservation_Created__c, H4H_Hotel_Id__c, 
                                           Check_In_Date__c, Check_Out_Date__c, Quantity__c, Product__r.Primary_Price_Book__r.H4H_Site_Id__c 
                                               from Rooming_List__c where Product__c IN : scope AND H4H_Reservation_Created__c = false AND H4H_Hold_Created__c = true ]) {
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
                            if(!Test.isRunningTest()){
                                res =  http.send(req);
                            }
                            System.debug('@@ Response check:: ' + res);
                            
                            String jsonReposne = !Test.isRunningTest() ? res.getBody() : '{"@ReservationID":"reserve123","@ItineraryID":"iter1234"}';
                            System.debug('@@ Reservation Responsebody : ' + jsonReposne);
                            
                            reResList.add(Utility.reqResLog('H4HReservationBatch', 'Execute', null, jsonReposne, req.getEndpoint(), !Test.isRunningTest() ? res.getStatusCode() : 200, objroomlist.Quote__c, objroomlist.QuoteLineItem_Id__c,'Reservation Creation'));
                            
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
    }
    public void finish(Database.BatchableContext BC){
        if(reResList.size() > 0) {
            Utility.processRecords(reResList, 'insert');
        }
        System.debug('lstRoomList-->'+lstRoomList);
        if(lstRoomList.size() > 0) {
            Utility.processRecords(lstRoomList, 'update');
        }
        
    }
}
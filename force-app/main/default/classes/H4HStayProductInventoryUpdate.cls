/**
 * @File Name          : H4HStayProductInventoryUpdate.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 6/3/2020, 10:40:48 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/23/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class H4HStayProductInventoryUpdate implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    public static String testResponseforAvailability;
    public List<RequestResponse_Log__c> reResList;
    public List<Product2> productsToUpdate;
    public List<Rooming_List__c> lstRoomList;
    public Boolean createRoom;
    private String query;
    private Date objdate;

    public H4HStayProductInventoryUpdate(Boolean createRoom){
        reResList = new List<RequestResponse_Log__c>();
        productsToUpdate = new List<Product2>();
        objdate = System.today().addDays(+2);
        lstRoomList = new List<Rooming_List__c>();
        this.createRoom = createRoom;
        this.query = 'Select Id,Name,CurrencyIsoCode,Primary_Price_Book__c,Primary_Price_Book__r.H4H_Site_Id__c,Type__c,' +
                                                        'Hotel_Id__c,Check_In_Date__c,Check_Out_Date__c,H4H_RatePlan_Code__c,H4H_Room_Code__c' +
                                                        ' from Product2' +
                                                        ' where Check_Out_Date__c != null AND Check_In_Date__c != null AND Hotel_Id__c != null'+
                                                        ' AND Primary_Price_Book__r.H4H_Site_Id__c != null AND Block_Release_Date__c =: objdate AND ' + Label.H4H_Inventory_Update_Criteria;
    }

    public H4HStayProductInventoryUpdate(){
        reResList = new List<RequestResponse_Log__c>();
        productsToUpdate = new List<Product2>();
        lstRoomList = new List<Rooming_List__c>();
        this.createRoom = false;
        this.query = 'Select Id,Name,CurrencyIsoCode,Primary_Price_Book__c,Primary_Price_Book__r.H4H_Site_Id__c,Type__c,' +
                                                        'Hotel_Id__c,Check_In_Date__c,Check_Out_Date__c,H4H_RatePlan_Code__c,H4H_Room_Code__c' +
                                                        ' from Product2' +
                                                        ' where Check_Out_Date__c != null AND Check_In_Date__c != null AND Hotel_Id__c != null AND Primary_Price_Book__r.H4H_Site_Id__c != null AND ' + Label.H4H_Inventory_Update_Criteria;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
 
    public void execute(Database.BatchableContext BC, List<Product2> products){
        system.debug('products-->'+products);
        H4H_API_Details__c h4hAPISettings = H4H_API_Details__c.getOrgDefaults();

        for(Product2 prod : products) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(h4hAPISettings.Hotel_Availability_End_Point__c +
                            'inDate=' + String.valueOf(prod.Check_In_Date__c) +
                            '&outDate=' + String.valueOf(prod.Check_Out_Date__c) +
                            '&username=' + h4hAPISettings.H4H_username__c +
                            '&password=' + h4hAPISettings.H4H_password__c +
                            '&siteid=' + prod.Primary_Price_Book__r.H4H_Site_Id__c +
                            '&rooms=1' + 
                            '&adults=2' + 
                            '&children=0' +
                            '&ipAddress=' + h4hAPISettings.IP_Address__c +
                            '&userAgent=' + h4hAPISettings.User_Agent__c +
                            '&userLanguage=en' +
                            '&_type=json' +
                            '&gateway=16' +
                            '&hotelids=' + prod.Hotel_Id__c);
            System.debug(req.getEndpoint());
            req.setMethod('GET');
            req.setHeader('Content-type','application/x-www-form-urlencoded');
            req.setTimeout(60000);
            Http http = new Http();
            HttpResponse res;
            if(!Test.isRunningTest()) {
                res =  http.send(req);
            }
            System.debug('@@ Response check' + res);

            String jsonReposne = !Test.isRunningTest() ? res.getBody() : '{"ArnResponse": {"Info": {"@SiteID": "{SITEID}","@Username": "{API-USERNAME}","@IpAddress": "24.113.225.28","@TimeReceived": "2018-04-17T00:41:27.367","@TimeCompleted": "2018-04-17T00:41:27.804","@Version": "1.0.0.0","@ServiceUrl": "http://api.travsrv.com/hotel.aspx?_type=json&adults=2&children=0&gateway=51&hotelIds=272393&inDate=2018-10-20&ipAddress=127.0.0.1&maxResults=1&outDate=2018-10-22&&ratePlanCode=&roomCode=HRLM--_eJwFwcuaczAAANAHmgVRCRaziPRvxkyJadx3biWUfkFH9On_fc5BTlaYBzSSx4m6Iwz3cS_pRnKxCtkQzjqPQZm8Lh771NInUK3ri_pDYTzZL6lQtgl0H0_fOj_f5dRd1kT_pX8dtg_pq0LMTJYHFXNuPqi0PxdLuTjEAeTtKNfYZ3Gd3suIjMbm3_prdXk03gvS_pfpUJnL_poCL9kNoyIlpA2DURM1_fqAtELSKYuKh6e248vaSGk9hE9Dns4MYIncb5jC_fcZG_p_fOeSN3Z0N_fib2UqSpSLCPFgqPX2sQTP9rmXEv_ptXOMVOlVLoC_fujzlUz6tJvvFwUEonyP6njavHdzsVVF2EesNGSmILz3twKMBKm_fp7PK2XCcgV8ghjMc93ZaXrLkm622zmAYaTaPSItlgfYOcO2TSZ6hvwXlxw_fSAVdl9fv4Hwe6AJQ&rooms=1&siteid={SITEID}&userAgent=shell&userLanguage=en","@RequestID": "2999AB6A-6DB9-4FFF-9586-BBED51BB6108"},"Availability": {"@DisplayCurrency": "USD","HotelAvailability": {"@InDate": "2018-10-20","@OutDate": "2018-10-22","@Rooms": "1","@Adults": "2","@Children": "0","Hotel": {"@HotelID": "272393","@HotelInfo": "https://api.travsrv.com/api/content/findpropertyinfo?propertyid=272393&locale={{locale}}","@Latitude": "30.2334","@Longitude": "-97.74027","@Name": "La Quinta Inn Austin Oltorf","@Address1": "1603 East Oltorf Blvd","@City": "Austin","@CountryCode": "US","@ImageThumbnail": "https://media.travsrv.com/272393/124017095_70.jpg","@LocationDescription": "Near South Congress Avenue","@TripAdvisorReviewCount": "377","@TripAdvisorRating": "2.5","@PriceClass": "2 Stars","RatePlan": [{"@Code": "ARN987654321","@Description": "Best Available","@BuyerOnly": "false","@Gateway": "41","@CommissionStatus": "Commissionable","@BalanceDueAtHotel": "false","Room": {"@Code": "987654321","@Name": "Standard room","@Description": "- 1 King Bed - Nonsmoking Room - Free Breakfast, Free Wifi, Fridge, Microwave","@CurrencyCode": "USD","@DisplayCurrencyMultiplier": "1","@USDMultiplier": "1","@ExchangeGMT": "2018-04-17T00:00:06.027","@MaximumBookable": "99","NightlyRate": [{"@Date": "2018-10-20","@Price": "114.44"},{"@Date": "2018-10-21","@Price": "114.43"}],"Tax": {"@Percent": "11.51","@Amount": "29.77"},"GatewayFee": {"@Amount": "0.00"},"Total": {"@Amount": "258.64","@IncludesBookingFee": "false"},"BookingFee": {"@Amount": "0.00","@CurrencyCode": "USD","@DisplayCurrencyMultiplier": "1","@RoomCurrencyMultiplier": "1","@ExchangeGMT": "2018-04-17T00:00:06.027"}}}]}}}}}';
            System.debug('@@ jsonReposne ' + jsonReposne);
            
            reResList.add(Utility.reqResLog('H4HStayProductInventoryUpdate', 'Execute', null, jsonReposne, req.getEndpoint(), !Test.isRunningTest() ? res.getStatusCode() : 200, null, prod.Id,'Product Inventory Updates'));

            if(String.isNotBlank(jsonReposne)) {
                System.debug('jsonReposne--->'+ jsonReposne);
                H4HResponseWrapper availabilitySearch = H4HResponseWrapper.parse(jsonReposne.replace('@', ''));
                System.debug('availabilitySearch--->'+availabilitySearch);
                if(availabilitySearch != null && availabilitySearch.ArnResponse != null
                    && availabilitySearch.ArnResponse.Availability != null && availabilitySearch.ArnResponse.Availability.HotelAvailability != null
                    && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel != null) {
                    System.debug('Response Get');
                    Id stayRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotel Stay').getRecordTypeId();
                    Product2 stayProd;
                    if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan != null
                        && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan.size() > 0) {

                        for(H4HResponseWrapper.RatePlan rtPlan : availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan) {
                            
                            if(rtPlan.Room != null && (prod.H4H_RatePlan_Code__c == rtPlan.Code || prod.H4H_Room_Code__c == rtPlan.Room.Code)) {
                                System.debug('MaximumBookable-->'+rtPlan.Room.MaximumBookable); 
                                stayProd = new Product2(Id=prod.Id);
                                stayProd.Total_Inventory__c = Integer.valueOf(rtPlan.Room.MaximumBookable);
                                productsToUpdate.add(stayProd);
                                If(createRoom == true){
                                    for(Integer i=0; i<stayProd.Total_Inventory__c; i++){
                                        Rooming_List__c objRoomingList = new Rooming_List__c();
                                        objRoomingList.Guest_Name__c = 'Quint Events'; //Create a Label to use that value dynamically
                                        objRoomingList.Product__c = prod.Id;
                                        lstRoomList.add(objRoomingList);
                                    }
                                }
                            }
                        }
                    } else if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan != null
                                && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Description != null
                                && (prod.H4H_RatePlan_Code__c == availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Code
                                || prod.H4H_Room_Code__c == availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Code)) {
                        stayProd = new Product2(Id=prod.Id);
                        stayProd.Total_Inventory__c = Integer.valueOf(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.MaximumBookable);
                        productsToUpdate.add(stayProd);
                        If(createRoom == true){
                            for(Integer i=0; i<stayProd.Total_Inventory__c; i++){
                                Rooming_List__c objRoomingList = new Rooming_List__c();
                                objRoomingList.Guest_Name__c = 'Quint Events'; //Create a Label to use that value dynamically
                                objRoomingList.Product__c = prod.Id;
                                lstRoomList.add(objRoomingList);
                            }
                        }
                    }
                }
            }
        } 
    }

    public void finish(Database.BatchableContext BC){ 
        System.debug('reResList-->'+reResList);
        if(reResList.size() > 0) {
            Utility.processRecords(reResList, 'insert');
        }
        System.debug('productsToUpdate--->'+productsToUpdate);
        if(lstRoomList.size() > 0){
            List<Rooming_List__c> lstRoom =  Utility.processRecords(lstRoomList, 'insert');
            Map<Id,Rooming_List__c> maproomlst = new Map<Id,Rooming_List__c>();
            for(Rooming_List__c objroom : lstRoom){
                maproomlst.put(objroom.Id, objroom);
            }
            System.debug('maproomlst--->'+maproomlst.KeySet());
            H4HHoldBatch objholdbatch = new H4HHoldBatch(maproomlst.KeySet(),createRoom);
            Database.executeBatch(objholdbatch,100);
        }else{
            if(createRoom == true){
                H4HReservationBatch objH4Hbatch = new H4HReservationBatch();
                Database.executeBatch(objH4Hbatch, 100);
            }
        }
        if(productsToUpdate.size() > 0) {
            Utility.processRecords(productsToUpdate, 'update');
        }
    }
}
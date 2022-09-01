/*************************************
** Class Name: QE_H4HStayProductInventoryUpdate
** Created Date: 01/30/2020
** Created By: Vishal Agrawal
** Purpose: Batch Job class for update Inventory at specific duration
** Unit Test: QE_H4HStayProductInventoryUpdate_Test
** ** ** ** ** ** ** **
*******Modification Logs************
**Modifier Name ***** Modified Date ***** Description
**
*************************************/
global class QE_H4HStayProductInventoryUpdate implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public static String testResponseforAvailability;
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id,Name,CurrencyIsoCode,Event__c,Event__r.H4H_Site_Id__c,Type__c,' +
                                                        'Hotel_Id__c,Check_In_Date__c,Check_Out_Date__c,H4H_RatePlan_Code__c,H4H_Room_Code__c' +
                                                        ' from Product2' +
                                                        ' where Check_Out_Date__c != null AND Check_In_Date__c != null AND Hotel_Id__c != null AND Event__r.H4H_Site_Id__c != null AND ' + Label.H4H_Inventory_Update_Criteria;
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Product2> products){
        H4H_API_Details__c h4hAPISettings = H4H_API_Details__c.getOrgDefaults();
        List<RequestResponse_Log__c> reResList = new List<RequestResponse_Log__c>();
        List<Product2> productsToUpdate = new List<Product2>();

        for(Product2 prod : products) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(h4hAPISettings.Hotel_Availability_End_Point__c +
                            'inDate=' + String.valueOf(prod.Check_In_Date__c) +
                            '&outDate=' + String.valueOf(prod.Check_Out_Date__c) +
                            '&username=' + h4hAPISettings.H4H_username__c +
                            '&password=' + h4hAPISettings.H4H_password__c +
                            '&siteid=' + prod.Event__r.H4H_Site_Id__c + //h4hAPISettings.H4H_Site_Id__c +
                            '&rooms=1' + //prod.Quantity + //1' +
                            '&adults=2' + //hotelOLI.H4H_Adult_Quantity__c + //2' +
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

            String jsonReposne = !Test.isRunningTest() ? res.getBody() :
                                    testResponseforAvailability;
            System.debug('@@ jsonReposne ' + jsonReposne);
            
            reResList.add(QE_H4HHotelProcess.reqResLog('QE_H4HHotelProcess', 'updateProductInventory', null, jsonReposne, req.getEndpoint(), !Test.isRunningTest() ? res.getStatusCode() : 200, null, prod.Id,'Product Inventory Updates'));

            if(String.isNotBlank(jsonReposne)) {
                QE_AvailbilityResponsParse availabilitySearch = QE_AvailbilityResponsParse.parse(jsonReposne.replace('@', ''));
                if(availabilitySearch != null && availabilitySearch.ArnResponse != null
                    && availabilitySearch.ArnResponse.Availability != null && availabilitySearch.ArnResponse.Availability.HotelAvailability != null
                    && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel != null) {
                    
                    Id stayRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Stay').getRecordTypeId();
                    Product2 stayProd;

                    if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan != null
                        && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan.size() > 0) {

                        for(QE_AvailbilityResponsParse.RatePlan rtPlan : availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan) {
                            if(rtPlan.Room != null && (prod.H4H_RatePlan_Code__c == rtPlan.Code || prod.H4H_Room_Code__c == rtPlan.Room.Code)) {
                                stayProd = new Product2(Id=prod.Id);
                                stayProd.Inventory__c = Integer.valueOf(rtPlan.Room.MaximumBookable);
                                productsToUpdate.add(stayProd);
                            }
                        }
                    } else if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan != null
                                //&& availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Description != null
                                && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Description != null
                                && 
                                (prod.H4H_RatePlan_Code__c == availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Code
                                || prod.H4H_Room_Code__c == availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Code)) {

                        stayProd = new Product2(Id=prod.Id);
                        stayProd.Inventory__c = Integer.valueOf(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.MaximumBookable);

                        productsToUpdate.add(stayProd);
                    }
                }
            }
        }
        if(productsToUpdate.size() > 0) {
            update productsToUpdate;
        }
        if(reResList.size() > 0) {
            insert reResList;
        }
    }

    global void finish(Database.BatchableContext BC){ }
}
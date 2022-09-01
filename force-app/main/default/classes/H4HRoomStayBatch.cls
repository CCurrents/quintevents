/**
 * @File Name          : H4HRoomStayBatch.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 6/3/2020, 10:39:25 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/25/2020   jagrawal@addonblue.com     Initial Version
**/
public class H4HRoomStayBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
	integer newDateDiff;
    integer i;
    Set<Id> currentRecordId;
    @TestVisible
    String testClassResponseString;
    public H4HRoomStayBatch(Integer newDateDiff,integer i,Set<Id> currentRecordId){
        this.currentRecordId = currentRecordId;
        this.newDateDiff = newDateDiff;
        this.i = i; 
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id, Name, CurrencyIsoCode, Primary_Price_Book__c, Primary_Price_Book__r.H4H_Site_Id__c, Type__c, Hotel_Id__c, Check_In_Date__c, Check_Out_Date__c,Hotel_Stay_Created__c from Product2 '+
                                        'where Id IN:currentRecordId AND Check_Out_Date__c != null AND Check_In_Date__c != null AND Hotel_Id__c != null AND Check_In_Date__c > TODAY');
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<RequestResponse_Log__c> lstReqResLog = new List<RequestResponse_Log__c>();
        Product2 stayProd;
        List<Product2> lstProd2 = new List<Product2>();
        Id stayRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotel Stay').getRecordTypeId();
        H4H_API_Details__c ha4APISettings = H4H_API_Details__c.getOrgDefaults();
        Product2 prod = (Product2) scope[0];
        Date dtCheckIn = prod.Check_In_Date__c.addDays(i);
        system.debug('dtCheckIn'+dtCheckIn);
        /*integer newDateDiff = dtCheckIn.daysBetween(prod.Check_Out_Date__c);
        system.debug('newDateDiff'+newDateDiff);*/
        for(Integer j=0; j<=newDateDiff; j++) {
            Date dtCheckOut = dtCheckIn.addDays(j);
            system.debug('dtCheckOut'+dtCheckOut);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(ha4APISettings.Hotel_Availability_End_Point__c +
                            'inDate=' + String.valueOf(dtCheckIn) +
                            '&outDate=' + String.valueOf(dtCheckOut) +
                            '&username=' + ha4APISettings.H4H_username__c +
                            '&password=' + ha4APISettings.H4H_password__c +
                            '&siteid=' + prod.Primary_Price_Book__r.H4H_Site_Id__c + //ha4APISettings.H4H_Site_Id__c +
                            '&rooms=1' + //prod.Quantity + //1' +
                            '&adults=2' + //hotelOLI.H4H_Adult_Quantity__c + //2' +
                            '&children=0' +
                            '&ipAddress=' + ha4APISettings.IP_Address__c +
                            '&userAgent=' + ha4APISettings.User_Agent__c +
                            '&userLanguage=en' +
                            '&_type=json' +
                            '&gateway=16' +
                            '&hotelids=' + prod.Hotel_Id__c 
                           );
            System.debug(req.getEndpoint());
            req.setMethod('GET');
            req.setHeader('Content-type','application/x-www-form-urlencoded');
            req.setTimeout(60000);
            Http http = new Http();
            HttpResponse res;
            if(!Test.isRunningTest()) { res =  http.send(req); }
            System.debug('@@ Response check' + res);
            
            String jsonReposne = !Test.isRunningTest() ? res.getBody() : testClassResponseString;
            System.debug('@@ jsonReposne ' + jsonReposne);
            
            RequestResponse_Log__c objRequestResponseLog = Utility.reqResLog('QE_H4H_Create_Room_Stay_CNTRL', 'h4hHotelSearchAPICall', null, jsonReposne, req.getEndpoint(), !Test.isRunningTest() ? res.getStatusCode() : 200, Null, prod.Id,'Product Room Stay Search');
            lstReqResLog.add(objRequestResponseLog);
            
            if(String.isNotBlank(jsonReposne) && (jsonReposne.contains(',"RatePlan":') || jsonReposne.contains(',"Room":'))) {
                AvailbilityResponsParse availabilitySearch = AvailbilityResponsParse.parse(jsonReposne.replace('@', ''));
                
                if(availabilitySearch != null && availabilitySearch.ArnResponse != null
                   && availabilitySearch.ArnResponse.Availability != null && availabilitySearch.ArnResponse.Availability.HotelAvailability != null
                   && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel != null) {
                       
                       if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan != null
                          && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan.size() > 0) {
                              System.debug('@RatePlan:-'+availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan);
                              for(AvailbilityResponsParse.RatePlan rtPlan : availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan) {
                                  if(rtPlan.Room != null) {
                                      system.debug('prod.Id'+prod.Id);
                                      stayProd = new Product2();
                                      stayProd.RecordTypeId = stayRecordTypeId;
                                      stayProd.CurrencyIsoCode = prod.CurrencyIsoCode;
                                      stayProd.Primary_Price_Book__c = prod.Primary_Price_Book__c;
                                      stayProd.Type__c = 'Stay';//prod.Type__c;
                                      stayProd.Hotel_Id__c = prod.Hotel_Id__c;
                                      stayProd.Check_Out_Date__c = dtCheckOut;
                                      stayProd.Check_In_Date__c = dtCheckIn;
                                      stayProd.H4H_RatePlan_Code__c = rtPlan.Code;
                                      stayProd.H4H_Room_Code__c = rtPlan.Room.Code;
                                      stayProd.Total_Inventory__c = Integer.valueOf(rtPlan.Room.MaximumBookable);
                                      stayProd.Name = rtPlan.Room.Name + ' ' + dtCheckIn.format() + ' - ' + dtCheckOut.format();
                                      stayProd.Description = rtPlan.Room.Description;
                                      stayProd.Room_Type__c = H4HRoomStayActionClass.h4hRoomType(stayProd.Description);
                                      stayProd.IsActive = true;
                                      
                                      
                                      stayProd.Hotel_Address__c = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.Address1 == null ? '' : (availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.Address1 + ', ');
                                          stayProd.Hotel_Address__c += availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.City == null ? '' : (availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.City + ', ');
                                              stayProd.Hotel_Address__c += availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.State == null ? '' : (availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.State + ', ');
                                                  stayProd.Hotel_Address__c += availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.Postal == null ? '' : (availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.Postal + ', ');
                                                      stayProd.Hotel_Address__c += availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.CountryCode == null ? '' : availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.CountryCode;
                                      stayProd.Hotel_Address__c = stayProd.Hotel_Address__c.removeEnd(', ');
                                      stayProd.Hotel_Address__c = stayProd.Hotel_Address__c.left(255);
                                      lstProd2.add(stayProd);
                                      system.debug('lstProd2'+lstProd2);
                                  }
                              }
                          } else if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan != null
                                    //&& availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Description != null
                                    && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Description != null) {
                                        
                                        stayProd = new Product2();
                                        stayProd.RecordTypeId = stayRecordTypeId;
                                        stayProd.CurrencyIsoCode = prod.CurrencyIsoCode;
                                        stayProd.Primary_Price_Book__c = prod.Primary_Price_Book__c;
                                        stayProd.Type__c = 'Stay';//prod.Type__c;
                                        stayProd.Hotel_Id__c = prod.Hotel_Id__c;
                                        stayProd.Check_Out_Date__c = dtCheckOut;
                                        stayProd.Check_In_Date__c = dtCheckIn;
                                        stayProd.H4H_RatePlan_Code__c = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Code;
                                        stayProd.H4H_Room_Code__c = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Code;
                                        stayProd.Name = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Name + ' ' + dtCheckIn.format() + ' - ' + dtCheckOut.format();
                                        stayProd.Description = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Description;
                                        stayProd.Room_Type__c = H4HRoomStayActionClass.h4hRoomType(stayProd.Description);
                                        stayProd.Total_Inventory__c = Integer.valueOf(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.MaximumBookable);
                                        stayProd.IsActive = true;
                                        
                                        stayProd.Hotel_Address__c = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.Address1 == null ? '' : (availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.Address1 + ', ');
                                            stayProd.Hotel_Address__c += availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.City == null ? '' : (availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.City + ', ');
                                                stayProd.Hotel_Address__c += availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.State == null ? '' : (availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.State + ', ');
                                                    stayProd.Hotel_Address__c += availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.Postal == null ? '' : (availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.Postal + ', ');
                                                        stayProd.Hotel_Address__c += availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.CountryCode == null ? '' : availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.CountryCode;
                                        stayProd.Hotel_Address__c = stayProd.Hotel_Address__c.removeEnd(', ');
                                        stayProd.Hotel_Address__c = stayProd.Hotel_Address__c.left(255);
                                        
                                        lstProd2.add(stayProd);
                                    }
                   }
            }
        }
    }
    public void finish(Database.BatchableContext BC){
    }
}
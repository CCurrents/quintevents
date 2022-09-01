public class QE_H4H_Create_Room_Stay_CNTRL{
    public Id hotelProductId;
    public Product2 prod;
    public boolean displayPopup {get;set;}
    public static String testResponseforAvailability;
    public String[] to_20;

    public QE_H4H_Create_Room_Stay_CNTRL(ApexPages.StandardController stdController) {
        hotelProductId = stdController.getId();
        displayPopup = true;
        List<Product2> products = new List<Product2>([Select Id,Name,CurrencyIsoCode,Event__c,Event__r.H4H_Site_Id__c,Type__c,Hotel_Id__c,Check_In_Date__c,Check_Out_Date__c from Product2
                                                        where Id = :hotelProductId AND Check_Out_Date__c != null AND Check_In_Date__c != null AND Hotel_Id__c != null]);
        if(products.size() > 0) {
            displayPopup = false;
            prod = products[0];
        }
    }

    public pageReference closePopup() {
        displayPopup = false;
        pageReference ref = new pageReference('/' + hotelProductId);
        ref.setRedirect(true);
        return ref;
    }

    public pageReference createRoomStay() {
        pageReference pr = null;

        if(!displayPopup) {
            h4hHotelSearchAPICall();
            pr = closePopup();
        }
        return pr;
    }

    public void h4hHotelSearchAPICall() {
        if(prod.Check_In_Date__c != null && prod.Check_Out_Date__c != null) {
            Integer daydiffCount = prod.Check_In_Date__c.daysBetween(prod.Check_Out_Date__c);
            H4H_API_Details__c ha4APISettings = H4H_API_Details__c.getOrgDefaults();
            List<Product2> lstProd2 = new List<Product2>();
            Id stayRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Stay').getRecordTypeId();
            Product2 stayProd;
            List<RequestResponse_Log__c> lstReqResLog = new List<RequestResponse_Log__c>();

            for(Integer i=0; i<=daydiffCount; i++) {
                Date dtCheckIn = prod.Check_In_Date__c.addDays(i);
                integer newDateDiff = dtCheckIn.daysBetween(prod.Check_Out_Date__c);
                for(Integer j=0; j<=newDateDiff; j++) {
                    Date dtCheckOut = dtCheckIn.addDays(j);

                    HttpRequest req = new HttpRequest();
                    req.setEndpoint(ha4APISettings.Hotel_Availability_End_Point__c +
                                    'inDate=' + String.valueOf(dtCheckIn) +
                                    '&outDate=' + String.valueOf(dtCheckOut) +
                                    '&username=' + ha4APISettings.H4H_username__c +
                                    '&password=' + ha4APISettings.H4H_password__c +
                                    '&siteid=' + prod.Event__r.H4H_Site_Id__c + //ha4APISettings.H4H_Site_Id__c +
                                    '&rooms=1' + //prod.Quantity + //1' +
                                    '&adults=2' + //hotelOLI.H4H_Adult_Quantity__c + //2' +
                                    '&children=0' +
                                    '&ipAddress=' + ha4APISettings.IP_Address__c +
                                    '&userAgent=' + ha4APISettings.User_Agent__c +
                                    '&userLanguage=en' +
                                    '&_type=json' +
                                    '&gateway=16' +
                                    '&hotelids=' + prod.Hotel_Id__c);
                    req.setMethod('GET');
                    req.setHeader('Content-type','application/x-www-form-urlencoded');
                    req.setTimeout(60000);
                    Http http = new Http();
                    HttpResponse res;
                    if(!Test.isRunningTest()) {
                        res =  http.send(req);
                    }

                    String jsonReposne = !Test.isRunningTest() ? res.getBody() :
                                            testResponseforAvailability;

                    RequestResponse_Log__c objRequestResponseLog = QE_H4HHotelProcess.reqResLog('QE_H4H_Create_Room_Stay_CNTRL', 'h4hHotelSearchAPICall', null, jsonReposne, req.getEndpoint(), !Test.isRunningTest() ? res.getStatusCode() : 200, Null, prod.Id,'Product Room Stay Search');
                    lstReqResLog.add(objRequestResponseLog);

                    if(String.isNotBlank(jsonReposne) && (jsonReposne.contains('"RatePlan"') || jsonReposne.contains('"Room"'))) {
                        QE_AvailbilityResponsParse availabilitySearch = QE_AvailbilityResponsParse.parse(jsonReposne.replace('@', ''));
                        if(availabilitySearch != null && availabilitySearch.ArnResponse != null
                            && availabilitySearch.ArnResponse.Availability != null && availabilitySearch.ArnResponse.Availability.HotelAvailability != null
                            && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel != null) {
        
                            if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan != null
                                && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan.size() > 0) {
        
                                for(QE_AvailbilityResponsParse.RatePlan rtPlan : availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan) {
                                    if(rtPlan.Room != null) {
                                        stayProd = new Product2();
                                        stayProd.RecordTypeId = stayRecordTypeId;
                                        stayProd.CurrencyIsoCode = prod.CurrencyIsoCode;
                                        stayProd.Event__c = prod.Event__c;
                                        stayProd.Type__c = prod.Type__c;
                                        stayProd.Hotel_Id__c = prod.Hotel_Id__c;
                                        stayProd.Check_Out_Date__c = dtCheckOut;
                                        stayProd.Check_In_Date__c = dtCheckIn;
                                        stayProd.H4H_RatePlan_Code__c = rtPlan.Code;
                                        stayProd.H4H_Room_Code__c = rtPlan.Room.Code;
                                        stayProd.Inventory__c = Integer.valueOf(rtPlan.Room.MaximumBookable);
                                        //stayProd.Name = rtPlan.Room.Name + ' ' + (dtCheckIn.format().substring(0,dtCheckIn.format().length()-5)) + ' - ' + dtCheckOut.format();
                                        stayProd.Name = buildNameField(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.Name, dtCheckIn, dtCheckOut);
                                        stayProd.Description = rtPlan.Room.Description;
                                        stayProd.Room_Type__c = QE_H4H_Create_Room_Stay_CNTRL.h4hRoomType(stayProd.Description);
                                        stayProd.IsActive = true;
                                        
                                        System.debug(rtPlan.Room);
                                        system.debug(jsonReposne);
                                        System.debug(rtPlan.Room.Total);
                                        if(rtPlan.Room.Total != null) {
                                            //stayProd.Price__c = rtPlan.Room.Total.Amount == null ? 0 : Decimal.valueOf(rtPlan.Room.Total.Amount);
                                            stayProd.Price__c = 0;
                                        }
                                        
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
                            } else if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan != null
                                        //&& availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Description != null
                                        && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Description != null) {

                                stayProd = new Product2();
                                stayProd.RecordTypeId = stayRecordTypeId;
                                stayProd.CurrencyIsoCode = prod.CurrencyIsoCode;
                                stayProd.Event__c = prod.Event__c;
                                stayProd.Type__c = prod.Type__c;
                                stayProd.Hotel_Id__c = prod.Hotel_Id__c;
                                stayProd.Check_Out_Date__c = dtCheckOut;
                                stayProd.Check_In_Date__c = dtCheckIn;
                                stayProd.H4H_RatePlan_Code__c = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Code;
                                stayProd.H4H_Room_Code__c = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Code;
                                //stayProd.Name = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Name + ' ' + (dtCheckIn.format().substring(0,dtCheckIn.format().length()-5)) + ' - ' + dtCheckOut.format();
                                stayProd.Name = buildNameField(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.Name, dtCheckIn, dtCheckOut);
                                stayProd.Description = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Description;
                                stayProd.Room_Type__c = QE_H4H_Create_Room_Stay_CNTRL.h4hRoomType(stayProd.Description);
                                stayProd.Inventory__c = Integer.valueOf(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.MaximumBookable);
                                stayProd.IsActive = true;
                                
                                if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Total != null) {
                                    //stayProd.Price__c = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Total.Amount == null 
                                                        //? 0 : Decimal.valueOf(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Total.Amount);
                                    
                                    stayProd.Price__c = 0;
                                }
                                
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
            if(lstReqResLog.size() > 0) {
                insert lstReqResLog;
            }

            if(lstProd2.size() > 0) {
                insert lstProd2;
                List<Hotel_Room_Package__c> lstHotelRoomsJun = new List<Hotel_Room_Package__c>();

                for(Product2 p : lstProd2) {
                    Hotel_Room_Package__c objProducts = new Hotel_Room_Package__c();
                    objProducts.Hotel_Package_Product__c = hotelProductId;
                    objProducts.ARN_Room_Product__c = p.id;
                    lstHotelRoomsJun.add(objProducts);
                }
                insert lstHotelRoomsJun;
            }
        }
    }
    
    public string buildNameField(String hotelName, Date inDate, Date outDate) {
        if(to_20 == null) {
            to_20 = new string[]{'Zero', 'One', 'Two', 'Three', 'Four', 'Five',  'Six', 'Seven', 'Eight', 'Nine', 'Ten',  'Eleven', 'Twelve', 'Thirteen',  
                                    'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen', 'Twenty'};
        }
        integer daysBetween = inDate.daysBetween(outDate);
        String stayProdName = '';
        if(daysBetween < 21) {
            stayProdName = to_20[daysBetween];
        }
        stayProdName += '-Night Accommodations at ';
        if(hotelName.startsWithIgnoreCase('the')) {
            stayProdName += hotelName;
        } else {
            stayProdName += 'the ' + hotelName;
        }
        stayProdName += ' | ';
        stayProdName += inDate.format() + ' - ' + outDate.format();
        
        return stayProdName;
    }

    public static string h4hRoomType(String des) {
        String strRoomType;

        if(String.isNotBlank(des)) {
            if(des.containsIgnoreCase('Twin')) {
                strRoomType = 'Twin';
            } else if(des.containsIgnoreCase('King')) {
                strRoomType = 'King';
            }else if(des.containsIgnoreCase('Double')) {
                strRoomType = 'Double/Double';
            } else if(des.containsIgnoreCase('Run of House')) {
                strRoomType = 'Run of House';
            } else if(des.containsIgnoreCase('Suite')) {
                strRoomType = 'Suite';
            } else if(des.containsIgnoreCase('Queen/Queen')) {
                strRoomType = 'Queen/Queen';
            } else if(des.containsIgnoreCase('Queen')) {
                strRoomType = 'Queen';
            }
        }
        return strRoomType;
    }
}
/**
 * @File Name          : H4HRoomStayActionClass.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 6/3/2020, 10:38:07 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/24/2020   jagrawal@addonblue.com     Initial Version
**/
public class H4HRoomStayActionClass {
    public static String strResponse;
	/**
    * @description: get product records
    * @author jagrawal@addonblue.com | 2/28/2020 
    * @param String currentRecordId 
    * @return Product2 
    **/
    @AuraEnabled 
    public static Product2 getProductRecords(String currentRecordId) { 
        system.debug(currentRecordId);
        try{
            Product2 product = new Product2();
            List<Product2> products = new List<Product2>([Select Id, Name, CurrencyIsoCode, Primary_Price_Book__c, Primary_Price_Book__r.H4H_Site_Id__c, Type__c, Hotel_Id__c, Check_In_Date__c, Check_Out_Date__c,Hotel_Stay_Created__c, Block_Release_Date__c from Product2
                                                            where Id = :currentRecordId AND Check_Out_Date__c != null AND Check_In_Date__c != null AND Hotel_Id__c != null AND Check_In_Date__c > TODAY]);
            if(products.size() > 0) {
                product = products[0];
                
                if(product.Primary_Price_Book__r.H4H_Site_Id__c == null) {
                    throw new AuraHandledException('H4H Site Id is required to create Room Stay.');
                }
            } else{
                throw new AuraHandledException('Check In Date, Check Out Date and Hotel Id are required to create Room Stay.');
            }
            //Changed by Jheel
            system.debug('Hotel_Stay_Created__c'+product.Hotel_Stay_Created__c);
            if(product.Hotel_Stay_Created__c == true){
                return null;
            }
            else{
                return product;
            }
        }
        catch(Exception ex){
            System.debug('Error:-'+ex.getMessage()+'--'+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage()+'--'+ex.getLineNumber());
        }
    }
    
   
    /**
    * @description: Insert Product and productbundel by callout
    * @author jagrawal@addonblue.com | 2/28/2020 
    * @param String currentRecordId 
    * @param Product2 prod 
    * @return String 
    **/
    @AuraEnabled 
    public static String h4hHotelSearchAPICall(String currentRecordId, Product2 prod) {
        Decimal price;
        Decimal costPerQua;
        String sizeofbdls;
        Boolean errorFlag = false;
        if(prod.Check_In_Date__c != null && prod.Check_Out_Date__c != null && prod.Hotel_Stay_Created__c == false) {
            Integer daydiffCount = prod.Check_In_Date__c.daysBetween(prod.Check_Out_Date__c);
            H4H_API_Details__c ha4APISettings = H4H_API_Details__c.getOrgDefaults();
            List<Product2> lstProd2 = new List<Product2>();
            Id stayRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotel Stay').getRecordTypeId();
            Product2 stayProd;
            List<RequestResponse_Log__c> lstReqResLog = new List<RequestResponse_Log__c>();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(ha4APISettings.Hotel_Availability_End_Point__c +
                                'inDate=' + String.valueOf(prod.Check_In_Date__c) +
                                '&outDate=' + String.valueOf(prod.Check_Out_Date__c) +
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
                if(!Test.isRunningTest()) {
                    res =  http.send(req);
                }
                System.debug('@@ Response check' + res);

                String jsonReposne = !Test.isRunningTest() ? res.getBody() : strResponse;
                System.debug('@@ jsonReposne ' + jsonReposne);
                
                RequestResponse_Log__c objRequestResponseLog = Utility.reqResLog('H4HRoomStayActionClass', 'h4hHotelSearchAPICall', null, jsonReposne, req.getEndpoint(), !Test.isRunningTest() ? res.getStatusCode() : 200, Null, prod.Id,'Product Room Stay Search');
                lstReqResLog.add(objRequestResponseLog);
                
                if(String.isNotBlank(jsonReposne) && (jsonReposne.contains(',"RatePlan":') || jsonReposne.contains(',"Room":'))) {
                    AvailbilityResponsParse availabilitySearch = AvailbilityResponsParse.parse(jsonReposne.replace('@', ''));
                    System.debug('availabilitySearch-->'+availabilitySearch);
                    if(availabilitySearch != null && availabilitySearch.ArnResponse != null
                    && availabilitySearch.ArnResponse.Availability != null && availabilitySearch.ArnResponse.Availability.HotelAvailability != null
                    && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel != null) {

                    if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan != null
                        && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan.size() > 0) {
                        System.debug('@RatePlan:-'+availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan);
                        for(AvailbilityResponsParse.RatePlan rtPlan : availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.RatePlan) {
                            System.debug('rtPlan-->'+rtPlan);
                            if(rtPlan.Room != null) {
                                stayProd = new Product2();
                                stayProd.RecordTypeId = stayRecordTypeId;
                                stayProd.CurrencyIsoCode = prod.CurrencyIsoCode;
                                stayProd.Event__c = prod.Event__c;
                                stayProd.Type__c = 'Hotel Stay';//prod.Type__c;
                                stayProd.Hotel_Id__c = prod.Hotel_Id__c;
                                stayProd.Check_Out_Date__c = prod.Check_Out_Date__c;
                                stayProd.Check_In_Date__c = prod.Check_In_Date__c;
                                stayProd.H4H_RatePlan_Code__c = rtPlan.Code;
                                stayProd.H4H_Room_Code__c = rtPlan.Room.Code;
                                stayProd.Total_Inventory__c = Integer.valueOf(rtPlan.Room.MaximumBookable);
                                stayProd.Name = rtPlan.Room.Name + ' ' + prod.Check_In_Date__c.format() + ' - ' + prod.Check_Out_Date__c.format();
                                stayProd.Description = rtPlan.Room.Description;
                                stayProd.Room_Type__c = h4hRoomType(stayProd.Description);
                                stayProd.IsActive = true;
                                stayProd.Block_Release_Date__c = prod.Block_Release_Date__c;
                                stayProd.Primary_Price_Book__c = prod.Primary_Price_Book__c;
                                
                                stayProd.Hotel_Address__c = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.Address1 == null ? '' : (availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.Address1 + ', ');
                                stayProd.Hotel_Address__c += availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.City == null ? '' : (availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.City + ', ');
                                stayProd.Hotel_Address__c += availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.State == null ? '' : (availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.State + ', ');
                                stayProd.Hotel_Address__c += availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.Postal == null ? '' : (availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.Postal + ', ');
                                stayProd.Hotel_Address__c += availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.CountryCode == null ? '' : availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.CountryCode;
                                stayProd.Hotel_Address__c = stayProd.Hotel_Address__c.removeEnd(', ');
                                stayProd.Hotel_Address__c = stayProd.Hotel_Address__c.left(255);
                                lstProd2.add(stayProd);

                                if(rtPlan.Room.Total != null){
                                    if(rtPlan.Room.Total.IncludesBookingFee == 'true'){
                                        price = Integer.valueOf(rtPlan.Room.Total.Amount);
                                    }
                                    else if(rtPlan.Room.Total.IncludesBookingFee == 'false'){
                                        if(rtPlan.Room.BookingFee != null){
                                            price = Integer.valueOf(rtPlan.Room.Total.Amount) + Integer.valueOf(rtPlan.Room.BookingFee.Amount);
                                        }
                                        
                                    }
                                }
                                System.debug('price-->'+price);
                                if(rtPlan.Room.BookingFee != null){
                                    if(prod.CurrencyIsoCode == rtPlan.Room.BookingFee.CurrencyCode){
                                        costPerQua = price;
                                    }
                                    else if(prod.CurrencyIsoCode != rtPlan.Room.BookingFee.CurrencyCode){
                                        costPerQua = Utility.convertCurrencyFromIsoToIso(price,rtPlan.Room.BookingFee.CurrencyCode,prod.CurrencyIsoCode);
                                    }
                                }
                                System.debug('costPerQua-->'+costPerQua);
                            }
                        }
                    } else if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan != null
                                //&& availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Description != null
                                && availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Description != null) {

                        stayProd = new Product2();
                        stayProd.RecordTypeId = stayRecordTypeId;
                        stayProd.CurrencyIsoCode = prod.CurrencyIsoCode;
                        stayProd.Event__c = prod.Event__c;
                        stayProd.Type__c = 'Hotel Stay';//prod.Type__c;
                        stayProd.Hotel_Id__c = prod.Hotel_Id__c;
                        stayProd.Check_Out_Date__c = prod.Check_Out_Date__c;
                        stayProd.Check_In_Date__c = prod.Check_In_Date__c;
                        stayProd.H4H_RatePlan_Code__c = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Code;
                        stayProd.H4H_Room_Code__c = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Code;
                        stayProd.Name = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Name + ' ' + prod.Check_In_Date__c.format() + ' - ' + prod.Check_Out_Date__c.format();
                        stayProd.Description = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Description;
                        stayProd.Room_Type__c = h4hRoomType(stayProd.Description);
                        stayProd.Total_Inventory__c = Integer.valueOf(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.MaximumBookable);
                        stayProd.IsActive = true;
                        stayProd.Block_Release_Date__c = prod.Block_Release_Date__c;
                        stayProd.Primary_Price_Book__c = prod.Primary_Price_Book__c;
                        
                        stayProd.Hotel_Address__c = availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.Address1 == null ? '' : (availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.Address1 + ', ');
                        stayProd.Hotel_Address__c += availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.City == null ? '' : (availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.City + ', ');
                        stayProd.Hotel_Address__c += availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.State == null ? '' : (availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.State + ', ');
                        stayProd.Hotel_Address__c += availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.Postal == null ? '' : (availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.Postal + ', ');
                        stayProd.Hotel_Address__c += availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.CountryCode == null ? '' : availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.CountryCode;
                        stayProd.Hotel_Address__c = stayProd.Hotel_Address__c.removeEnd(', ');
                        stayProd.Hotel_Address__c = stayProd.Hotel_Address__c.left(255);

                        lstProd2.add(stayProd);


                        if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Total != null){
                            if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Total.IncludesBookingFee == 'true'){
                                price = Integer.valueOf(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Total.Amount);
                            }
                            else if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Total.IncludesBookingFee == 'false'){
                                if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.BookingFee != null){
                                    price = Integer.valueOf(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.Total.Amount) + Integer.valueOf(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.BookingFee.Amount);
                                }
                                
                            }
                        }
                        System.debug('price-->'+price);
                        if(availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.BookingFee != null){
                            if(prod.CurrencyIsoCode == availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.BookingFee.CurrencyCode){
                                costPerQua = price;
                            }
                            else if(prod.CurrencyIsoCode != availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.BookingFee.CurrencyCode){
                                costPerQua = Utility.convertCurrencyFromIsoToIso(price,availabilitySearch.ArnResponse.Availability.HotelAvailability.Hotel.objRatePlan.Room.BookingFee.CurrencyCode,prod.CurrencyIsoCode);
                            }
                        }
                        System.debug('costPerQua-->'+costPerQua);
                    }
                
                }
            }
            else{
                errorFlag = true;
            }
                //}
            //}
            if(lstReqResLog.size() > 0) {
                System.debug(lstReqResLog);
                insert lstReqResLog;
                Product2 pro = [select Id from Product2 where Id=:currentRecordId];
                pro.Hotel_Stay_Created__c = true;
                update pro;
            }

            if(lstProd2.size() > 0) {
                system.debug('lstProd2'+lstProd2.size());
                insert lstProd2;
                
                List<Products_Bundle__c> insertPBs = new List<Products_Bundle__c>();
                List<Inventory_Transaction__c> lstInventoryTans =  new List<Inventory_Transaction__c>();
                for(Product2 p : lstProd2) {
                    
                    Products_Bundle__c newPB = new Products_Bundle__c();
                    newPB.Child_product__c = p.Id;
                    newPB.Parent_Product__c = currentRecordId;
                    newPB.Type__c = 'Hotel Stay';
                    insertPBs.add(newPB);


                    Inventory_Transaction__c newIT = new Inventory_Transaction__c();
                    newIT.RecordTypeId = Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByName().get('Inventory Load').getRecordTypeId();
                    newIT.Quantity__c = p.Total_Inventory__c;
                    newIT.Product__c = p.Id;
                    newIT.Cost_Per_Quantity__c = costPerQua;
                    lstInventoryTans.add(newIT);
                    system.debug('lstInventoryTans-->'+lstInventoryTans);
                }
                if(insertPBs.size() > 0) {
                    //Changed by Jheel
                    sizeofbdls = String.valueOf(insertPBs.size());
                    Utility.processRecords(insertPBs, 'insert');
                }
                if(lstInventoryTans.size() > 0){
                    Utility.processRecords(lstInventoryTans, 'insert');
                }
            }
            if(errorFlag){
                throw new AuraHandledException('Check In and Check Out Dates are not avilable please Update.');
            }
        }
        
        return sizeofbdls;
    }
    
    
    /**
    * @description 
    * @author jagrawal@addonblue.com | 2/28/2020 
    * @param String des 
    * @return string 
    **/
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
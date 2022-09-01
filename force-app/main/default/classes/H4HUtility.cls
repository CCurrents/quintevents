/**
 * @File Name          : H4HUtility.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 07-26-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/21/2020   jagrawal@addonblue.com     Initial Version
 * 1.1    7/26/2020   jagrawal@addonblue.com     Added New fields for Guest H4H Reservation Request Body
**/
public class H4HUtility {
	public static String testResponseforAvailability;
    
    /**
    * @description  : Built Romming list object
    * @author       : jagrawal@addonblue.com | 28/1/2020 
    * @param        : hotelQLI (QuoteLineItem hotelQLI)
    * @return       : Rooming_List__c 
    **/
    public static Rooming_List__c createRoomingList(QuoteLineItem hotelQLI) {
        Rooming_List__c roomList = new Rooming_List__c();
        roomList.Number_of_Adults__c = 2;
        roomList.Quote__c = hotelQLI.QuoteId;
        roomList.QuoteLineItem_Id__c = hotelQLI.Id;
        roomList.H4H_Roomtype_Id__c = hotelQLI.Roomtype_Id__c;
        return roomList;
    }

    /**
    * @description  : create a reservation by callout
    * @author       : jagrawal@addonblue.com | 28/1/2020 
    * @param        : quoteid
    * @return       : void 
    **/
    public static void futureh4hRoomHoldCreation(Set<Id> quoteid){
        List<Rooming_List__c> lstRoomList = [Select Id,Quote__c From Rooming_List__c where Quote__c IN: quoteid];
        Map<Id,Rooming_List__c> maproomlst = new Map<Id,Rooming_List__c>();
           for(Rooming_List__c objroom : lstRoomList){
               maproomlst.put(objroom.Id, objroom);
           }
        H4HHoldBatch batch = new H4HHoldBatch(maproomlst.keySet(),false);
        Database.executeBatch(batch);
   }

   /**
    * @description  : Hotel Reservation Creation in H4H
    * @author       : jagrawal@addonblue.com | 28/1/2020 
    * @param        : setQuoteIds (List of Ids of Quotes)
    * @return       : void 
    **/
    public static void h4hCreateReservation(Set<Id> setQuoteIds) {
        
        H4HReservationBatch batch = new H4HReservationBatch(setQuoteIds);
        Database.executeBatch(batch);
    }
	
    /**
    * @description  : Get rate details for reservation creation
    * @author       : jagrawal@addonblue.com | 28/1/2020 
    * @param-1      : qteId (Quote Id)
    * @param-2      : qliId (Quote Line Item Id)
    * @param-3      : strResponse (String Response)
    * @param-4      : currencyCode (String Currency Code)
    * @param-5      : h4hAPISettings (Custom Setting H4H API Details)
    * @param-6      : reResList (List of Request Response Logs)
    * @return       : String 
    **/
    public static String h4hRatePlanInfo(Id qteId, Id qliId, String strResponse, String currencyCode, H4H_API_Details__c h4hAPISettings, List<RequestResponse_Log__c> reResList) {
        strResponse = strResponse.replace('type=Reservation&','');
        strResponse += '&currency=' + currencyCode;
        
        strResponse = h4hAPISettings.Hotel_Availability_End_Point__c + strResponse;
        System.debug('@@ rateplan request: ' + strResponse);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(strResponse);
        req.setMethod('GET');
        req.setHeader('Content-type','application/json; charset=utf-8');
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(h4hAPISettings.H4H_username__c + ':' + h4hAPISettings.H4H_password__c)));
        Http http = new Http();
        System.debug(req);
        HttpResponse res;
        if(!Test.isRunningTest()){
            res =  http.send(req);
        }
        String strHead = 'Authorization Basic ' + EncodingUtil.base64Encode(Blob.valueOf(h4hAPISettings.H4H_username__c + ':' + h4hAPISettings.H4H_password__c));
        
        String jsonReposne = !Test.isRunningTest() ? res.getBody() : '{"ArnResponse":{"Info":{"@SiteID":"55900","@Username":"aodom@quintevents.com","@IpAddress":"13.108.254.8","@TimeReceived":"2020-01-08T18:48:43.506","@TimeCompleted":"2020-01-08T18:48:43.661","@Version":"1.0.0.0","@ServiceUrl":"¤cy=USD&gateway=20&guestEmail=mgagnon@quintevents.com&guestFirstName=Aaron&guestLastName=Odom&guestPhoneArea=512&guestPhoneCountry=&guestPhoneNumber=704.926.2706&hotelIds=201426&inDate=2020-03-12&ipAddress=12.250.230.226&outDate=2020-03-16&ratePlanCode=ARN605444&roomCode=605444&rooms=1&siteid=55900&userAgent=chrome&userLanguage=en&username=aodom@quintevents.com","@RequestID":"C03B339B-2A1B-4805-8496-621FC86B38D9"},"RateDetails":{"@DisplayCurrency":"USD","HotelRateDetails":{"@InDate":"2020-03-12","@OutDate":"2020-03-16","@Rooms":"1","@Adults":"2","@Children":"0","Hotel":{"@HotelID":"201426","@HotelInfo":"","@Latitude":"-37.82232","@Longitude":"144.95573","@Name":"Crowne Plaza Melbourne","@Address1":"1-5 Spencer Street","@City":"Southbank","@State":"VC","@CountryCode":"AU","@Postal":"3008","@PercentMatch":"0","@ImageThumbnail":"","@LocationDescription":"Near SEA LIFE Melbourne","@TripAdvisorReviewCount":"1839","@TripAdvisorRating":"4.0","@RatingImageUrl":"","@PriceClass":"4 Stars","@PropertyLink":"","RatePlan":{"@Code":"ARN605444","@Description":"","@Gateway":"20","@CommissionStatus":"Commissionable","@BalanceDueAtHotel":"true","Room":{"@Code":"605444","@Name":"2020 F1 Australian Grand Prix","@Description":"","@CurrencyCode":"AUD","@DisplayCurrencyMultiplier":"0.6876018510","@USDMultiplier":"0.6876018510","@ExchangeGMT":"2020-01-08T18:00:03.100","@MaximumBookable":"1","@Refundable":"true","NightlyRate":[{"@Date":"2020-03-12","@Price":"410.00"},{"@Date":"2020-03-13","@Price":"410.00"},{"@Date":"2020-03-14","@Price":"410.00"},{"@Date":"2020-03-15","@Price":"360.00"}],"Tax":{"@Percent":"0.00","@Amount":"0.00"},"GatewayFee":{"@Amount":"0.00"},"Total":{"@Amount":"1590.00","@IncludesBookingFee":"false"},"BookingFee":{"@Amount":"0.00","@CurrencyCode":"USD","@DisplayCurrencyMultiplier":"1","@RoomCurrencyMultiplier":"1.4543300000","@ExchangeGMT":"2020-01-08T18:00:03.100"}},"Policy":{"ExtraPersonPrice":{"@Adult":"0.00","@Child":"0.00","@CurrencyCode":"AUD","@DisplayCurrencyMultiplier":"0.6876018510","@USDMultiplier":"0.6876018510","@ExchangeGMT":"2020-01-08T18:00:03.100"},"Guarantee":{"@Description":"N/A"},"Cancel":{"@Description":" ","@LatestCancelTime":"2020-03-12T13:59:00.000","@GMTOffSet":"0","Fee":{"@Amount":"0.00","@CurrencyCode":"USD","@DisplayCurrencyMultiplier":"1","@RoomCurrencyMultiplier":"1.4543300000","@ExchangeGMT":"2020-01-08T18:00:08.367"},"Penalty":{"@Amount":"0.00","@CurrencyCode":"AUD","@DisplayCurrencyMultiplier":"0.6876018510","@USDMultiplier":"0.6876018510","@ExchangeGMT":"2020-01-08T18:00:03.100"}},"Deposit":{"@Description":"Deposit required. See Payment Policy."},"ExtraFees":{"@Description":""},"Payment":{"@Description":""},"Property":[{"@Description":"Ch","@Value":"2 PM"},{"@Description":"C","@Value":"11 AM"}]}}}}}}}';
        System.debug('@@ Room Rate get request body : ' + jsonReposne);
        reResList.add(Utility.reqResLog('H4HUtility', 'h4hRatePlanInfo', strHead, jsonReposne, req.getEndpoint(), !Test.isRunningTest() ? res.getStatusCode() : 200, qteId, qliId,'Rate Plan info Request'));
        
        H4HRatePlanResponse objH4HRatePlanInfo = H4HRatePlanResponse.parse(jsonReposne);
        System.debug('@@objH4HRatePlanInfo=>'+objH4HRatePlanInfo);
        H4HRatePlanResponse.Room room = objH4HRatePlanInfo.ArnResponse.RateDetails.HotelRateDetails.Hotel.RatePlan.Room;
        
        String nightRate = room.objNightlyRate != null ? room.objNightlyRate.Price : room.NightlyRate[0].Price;
        String taxAmount = room.Tax.Amount;
        String gatewayFee = room.GatewayFee.Amount;
        String roomcurrencyCode = room.CurrencyCode;
        String bookingFees = room.BookingFee.Amount;
        String totalAmount = room.Total.Amount;
        String bookingFeeCurrencyCode = room.BookingFee.CurrencyCode;
        
        String requestEndpoint = '&roomCostPrice=' + nightRate;
        requestEndpoint += '&roomCostTaxAmount=' + taxAmount;
        requestEndpoint += '&roomCostGatewayFee=' + gatewayFee;
        requestEndpoint += '&roomCostTotalAmount=' + totalAmount;
        requestEndpoint += '&roomCostCurrencyCode=' + roomcurrencyCode;
        requestEndpoint += '&bookingFeeAmount=' + bookingFees;
        requestEndpoint += '&bookingFeeCurrencyCode=' + bookingFeeCurrencyCode;
        return requestEndpoint;
    }

    /**
    * @description  : Hotel Reservation Creation in request body H4H
    * @author       : jagrawal@addonblue.com | 28/1/2020 
    * @param-1      : qteObj (Quote Object)
    * @param-2      : hotelQLI (Quote Line Item Object)
    * @param-3      : h4hAPISettings (Custom Setting H4H API Details)
    * @param-4      : ccInfo (QE_H4H_Credit_Card__c)
    * @param-5      : reResList (List of Request Response Logs)
    * @param-6      : roomList (Rooming_List__c)
    * @return       : String 
    **/
    public static String reservationCreateRequest(H4H_API_Details__c h4hAPISettings, QE_H4H_Credit_Card__c ccInfo, List<RequestResponse_Log__c> reResList, Rooming_List__c roomList, Order objOrder) {
       
        String requestEndpoint = 'type=Reservation&_type=json&userLanguage=en&gateway=20&username=';
        
        //Custom setting H4H details API
        requestEndpoint += h4hAPISettings.H4H_username__c;
        requestEndpoint += '&password=' + h4hAPISettings.H4H_password__c;
        requestEndpoint += '&siteid=' + roomList.Product__r.Primary_Price_Book__r.H4H_Site_Id__c;//qteObj.Opportunity.Pricebook2.H4H_Site_Id__c; //h4hAPISettings.H4H_Site_Id__c;
        requestEndpoint += '&ipAddress=' + h4hAPISettings.IP_Address__c;
        requestEndpoint += '&userAgent=' + h4hAPISettings.User_Agent__c;
        
        //Quote Line Item
        requestEndpoint += '&hotelIds=' + roomList.H4H_Hotel_Id__c;
        requestEndpoint += '&inDate=' + String.valueOf(roomList.Check_In_Date__c);
        requestEndpoint += '&outDate=' + String.valueOf(roomList.Check_Out_Date__c);
        requestEndpoint += '&ratePlanCode=ARN' + roomList.H4H_Roomtype_Id__c;
        requestEndpoint += '&roomCode=' + roomList.H4H_Roomtype_Id__c;
        requestEndpoint += '&adults=' + String.valueOf(roomList.Number_of_Adults__c);
        requestEndpoint += '&rooms=' + String.valueOf(roomList.Quantity__c);
        requestEndpoint += '&children=0';
        
        //Quote Primary Contact details
        // #458 Added New fields for Guest H4H Reservation Request Body -- START
        String GFirstName;
        String GLastName;
        if(String.isNotBlank(roomList.Guest_Name__c)){
            GFirstName = String.isNotBlank(roomList.Guest_Name__c.substringBeforeLast(' ')) ? roomList.Guest_Name__c.substringBeforeLast(' ') : h4hAPISettings.Guest_Default_FirstName__c;
            GLastName = String.isNotBlank(roomList.Guest_Name__c.substringAfterLast(' ')) ? roomList.Guest_Name__c.substringAfterLast(' ') : h4hAPISettings.Guest_Default_LastName__c;
        }
        else{
            GFirstName = h4hAPISettings.Guest_Default_FirstName__c;
            GLastName = h4hAPISettings.Guest_Default_LastName__c;
        }
        System.debug('GuestName:- '+GFirstName+' '+GLastName);
        requestEndpoint += '&guestFirstName=' + EncodingUtil.urlEncode(GFirstName, 'UTF-8');
        requestEndpoint += '&guestLastName=' + EncodingUtil.urlEncode(GLastName, 'UTF-8');
        requestEndpoint += '&guestEmail='+h4hAPISettings.Guest_Email__c ;
        requestEndpoint += '&guestPhoneCountry=1' ;
        requestEndpoint += '&guestPhoneNumber='+h4hAPISettings.Guest_PhoneNumber__c;
        requestEndpoint += '&guestPhoneArea='+h4hAPISettings.Guest_PhoneArea__c;
        // #458 Added New fields for Guest H4H Reservation Request Body -- END
        //Address
        requestEndpoint += '&addressAddress=' + objOrder.Billing_Street__c ;
        requestEndpoint += '&addressCity=' + objOrder.Billing_City__c;
        requestEndpoint += '&addressPostalCode=' + objOrder.Billing_Zip_Postal_Code__c;
        requestEndpoint += '&addressCountryCode=US'; 
        requestEndpoint += '&addressRegion=' + objOrder.Billing_State_Province__c;
        
        //Price details
        requestEndpoint += h4hRatePlanInfo(roomList.Product__c, roomList.Id, requestEndpoint, roomList.CurrencyIsoCode, h4hAPISettings, reResList);
        
        //Credit Card details
        requestEndpoint += '&creditCardType=' + ccInfo.Card_Type__c;
        requestEndpoint += '&creditCardNumber=' + ccInfo.Card_Number__c;
        requestEndpoint += '&creditCardExpiration=' + ccInfo.Card_Expiration__c;
        requestEndpoint += '&creditCardCVV2=' + ccInfo.Card_CVV__c;
        requestEndpoint += '&creditCardHolder=' + EncodingUtil.urlEncode(ccInfo.Card_Holder_Name__c, 'UTF-8');
        requestEndpoint += '&creditCardAddress=' + EncodingUtil.urlEncode(ccInfo.Card_Street_Address__c, 'UTF-8');
        requestEndpoint += '&creditCardCity=' + EncodingUtil.urlEncode(ccInfo.Card_City__c, 'UTF-8');
        requestEndpoint += '&creditCardRegion=' + EncodingUtil.urlEncode(ccInfo.Card_Region__c, 'UTF-8');
        requestEndpoint += '&creditCardPostalCode=' + EncodingUtil.urlEncode(ccInfo.Card_PostalCode__c, 'UTF-8');
        requestEndpoint += '&creditCardCountryCode=' + EncodingUtil.urlEncode(ccInfo.Card_CountryCode__c, 'UTF-8');
        
        requestEndpoint = h4hAPISettings.Hotel_Availability_End_Point__c + requestEndpoint;
        
        return requestEndpoint;
    }
    
    /**
    * @description  : Wrapper Clas for Hold Creation API Response
    * @author       : jagrawal@addonblue.com | 28/1/2020
    **/
    public class H4HHoldCreationResponse {
        
        public String RoomTypeId {get;set;}
        
        public H4HHoldCreationResponse(String json) {
            System.JSONParser parser = System.JSON.createParser(json);
            while(parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if(parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if(text == 'RoomTypeId') {
                            RoomTypeId = String.valueOf(parser.getIntegerValue());
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
        
        
        /**
        * @description  : 
        * @author       : jagrawal@addonblue.com | 28/1/2020 
        * @param        : parser 
        * @return       : void 
        **/
        public void consumeObject(System.JSONParser parser) {
            Integer depth = 0;
            do {
                System.JSONToken curr = parser.getCurrentToken();
                if (curr == System.JSONToken.START_OBJECT ||
                    curr == System.JSONToken.START_ARRAY) {
                        depth++;
                    } else if (curr == System.JSONToken.END_OBJECT ||
                               curr == System.JSONToken.END_ARRAY) {
                                   depth--;
                               }
            } while (depth > 0 && parser.nextToken() != null);
        }
    }

    public static Decimal getRewardPointsOfContacts(Contact objContact) {
        
        Decimal memberPointsFromRes = 0.0;
        Integer totalH4HPoints = 0;
        
        if(objContact != null && String.isNotBlank(objContact.Email)) {
            H4H_API_Details__c ha4APISettings = H4H_API_Details__c.getOrgDefaults();
            
            String firstNameNew ='';
            String lastNameNew ='';
            String usernames = ha4APISettings.H4H_username__c;
            String passwords = ha4APISettings.H4H_password__c;
            string siteIds = '40598'; //ha4APISettings.H4H_Site_Id__c;
            String TokenId =  H4HCalloutClass.getH4HTokenId();
           
            
            if(String.isNotBlank(objContact.Firstname)){
                firstNameNew = objContact.Firstname;
            } else {
                firstNameNew = objContact.lastname;
            }
            lastNameNew = objContact.lastname;
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('Names');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('ReferralId', objContact.Email);
            gen.writeStringField('FirstName', firstNameNew);
            gen.writeStringField('LastName', lastNameNew);
            gen.writeStringField('Email', objContact.Email);
            gen.writeEndObject();
            String jsonS = gen.getAsString();
            System.debug('jsonMaterials'+jsonS);
            
            HttpRequest req1 = new HttpRequest();
            req1.setMethod('POST');
            System.debug('ha4APISettings--'+ha4APISettings.H4H_GetMemberPoints_EndPoint__c);
            if(ha4APISettings.H4H_GetMemberPoints_EndPoint__c != null){
                req1.setEndpoint(ha4APISettings.H4H_GetMemberPoints_EndPoint__c);
            }
            req1.setHeader('Cache-Control','no-cache');
            req1.setHeader('Content-type','application/x-www-form-urlencoded');
            req1.setBody('siteid='+siteIds+'&token='+TokenId +'&memberData='+jsonS);
            System.debug('***req body**'+req1.getbody());
            
            Http h = new Http(); 
            HTTPResponse resp;
            if(!Test.isRunningTest()){
                resp = h.send(req1);
            }
            System.debug('***response debug***'+resp);
            //QE_H4HRecursive4Callout.inFutureContext = true;
            String jsonReposne = !Test.isRunningTest() ? resp.getBody() : '{"MemberId":4999811,"Rewards":0,"Points":1000,"RedemptionMultiplier":1.0,"EarnMultiplier":1.0,"Names":[{"FirstName":"H4H","LastName":"Open Demo","BirthDate":null,"Email":"testingemail@gmail.com","Address1":null,"Address2":null,"City":null,"State":null,"Country":null,"Postal":null,"Longitude":null,"Latitude":null,"HomePhone":null,"Referral":null,"ReferralId":"testingemail@gmail.com","RegistrationCode":null,"Password":null,"IsActive":true,"DeleteMember":false,"ReactivateMember":false,"UpdateMemberUsername":false,"CreditCards":null,"FullName":"H4H Open Demo"}],"DebugData":" Successful Existing Member RT-40598-testingemail@gmail.com","Error":null,"CurrentToken":"hGiCXVnDCZYJivQ3WNyYDClfLRFGDBV8G9HG5ETSMwRJHk4le52Hz7%2fmDA6B1QFPfcNBo7Sh5h%2brhP67CWZS%2foG9%2bOIZqPgvhBpXuUVH4hGlvVa4W3WUEDN1o3HBDdUeCOQITN754PN42vZnyJhOIKgj4ajOS%2bv0%2bqe4Z8jcaxJ84oRdBWZUKRtB7v06vKWrQvLC8bvkhpCzH0X%2bX%2bS7iXFxG4Iyt%2b2FpL4GCoSZC9GEV0Zfz%2fYcw8LtP3scwR2QbUGRtwN98ufJj1in5a%2bgUo6nyZUzUM4xOaQegCIj%2bxaXITuVeKct60RtAEQKXsyME2ik6aLHGqsRFhqoNWuCuPfyWL%2fGPIh6qOR5RfNfEpELPJNiDh412yYGtXBEmAkndkrqLjfGi0ND4K%2f3nKC1tosgvDXuS55XEjYJS9j1Qcr222JTqEoNVrzA8sNZ9NmGyJbryZ%2fFxJ0hp5PRJfhPXeLS5PdBEYsPcKgOr%2bMLacv9hl8VwJSak%2fn7fviebmlqzoFdts2EI11YW19UM4MRz4FtyM8vKA4%2fBaynWOOSk%2fVJtJXkZmh9IH2KgpVN0Dplzkhyp43C%2fZykpewzyEs05JQmFJeA2Iqv3LghnIU2wz2cQp8Uhp%2bGbUxWFx3aqK3MtAM3i0TWHS04iOQuW09ePmMGN8I7y86RPXRHgTL5OdGVZ6u3TkgKT2N4VLrCQyFs1iCDJ3f9uLw6tqTMNFz8n6oCP4YXv0iOreOE9CkF6SS8U4STzzUe1Plni3o7AJnMoqQHTu44vA1dBZahi6zIuQ%3d%3d","TransactionResponse":"true","MetaTag":null,"MemberUsername":"RT-40598-testingemail@gmail.com","MemberProvider":null,"IsArnProvider":true,"AdditionalInfo":null,"MemberType":"Wholesale"}';
            JSONParser parser1 = JSON.createParser(jsonReposne);
            
            String memberStatus;
                while (parser1.nextToken() != null) {
                    if ((parser1.getCurrentToken() == JSONToken.FIELD_NAME) && (parser1.getText() == 'DebugData')) {
                        parser1.nextToken();
                        memberStatus = parser1.getText();
                        System.debug('***memberStatus*'+memberStatus);
                        break;
                    }
                }
                
                JSONParser parser2 = JSON.createParser(jsonReposne);
                
                if(memberStatus != null && memberStatus.contains('Successful Existing Member')) {
                    while (parser2.nextToken() != null) {
                        if (parser2.getCurrentToken() == JSONToken.FIELD_NAME && parser2.getText() == 'Points') {
                            parser2.nextToken();
                            if(parser2.getCurrentToken() == JSONToken.VALUE_NUMBER_INT) {
                                memberPointsFromRes += parser2.getIntegerValue();
                                break;
                            }
                        }
                    }
                }
        }
        return memberPointsFromRes;
    }
    
    
}
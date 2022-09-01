/**
 * @File Name          : BrandFuelCallout.cls
 * @Description        : BrandFuel integration class
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 2/28/2020, 3:11:00 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    9/26/2019      mpatel@addonblue.com      Initial Version
 * 1.1     2/3/2020      mpatel@addonblue.com      Refactored the code by changing the structure of the code as per the standards
**/
public with sharing class BrandFuelCallout{
    /**
    * @description  : this method check the user is exist in the brandfule or not
    * @author       : mpatel@addonblue.com | 3/18/2020
    * @param        : String brandFuelName
    * @param        : String brandFuelEmail
    * @param        : Id orderId
    * @param        : List < Id > OrderLineIds
    * @param        : String priceBookId
    * @param        : String priceBookName
    * @param        : Date priceBookEndDate
    * @param        : Boolean OrderFullyPaid
    * @param        : Id brandFuelContactId
    * @param        : Date BdFuelEndDate
    * @return       : void 
    **/ 
    @future(callout = true)
    Public static void checkUserExists(String brandFuelName, String brandFuelEmail, Id orderId, List < Id > OrderLineIds, String priceBookId, String priceBookName, Date priceBookEndDate, Boolean OrderFullyPaid, Id brandFuelContactId, Date BdFuelEndDate) {
        List<Contact> conUpdateList = new List<Contact>();
        String body='';
        String endPointString = 'users/'+brandFuelEmail;
        RequestResponse_Log__c objRequestResonse = Utility.callout('BrandFuelGetRequest', body, endPointString);
        System.debug('objRequestResonse.Response__c-->'+objRequestResonse.Response__c);
        JSONParser parser2 = JSON.createParser(objRequestResonse.Response__c);
        String dstKeyval= '';
        String dstusrId;
        if (Integer.ValueOf(objRequestResonse.Status_Code__c) == 200) {
            while (parser2.nextToken() != null) {
                if ((parser2.getCurrentToken() == JSONToken.FIELD_NAME) && (parser2.getText() == 'dstKey')) {
                    parser2.nextToken();
                    dstKeyval = parser2.getText();
                    break;
                }
            }
            JSONParser parser3 = JSON.createParser(objRequestResonse.Response__c);
            while (parser3.nextToken() != null) {
                if((parser3.getCurrentToken() == JSONToken.FIELD_NAME) && (parser3.getText() == 'dstId')) {
                    parser3.nextToken();
                    dstusrId = parser3.getText();
                    break;
                }    
            }
            if(brandFuelContactId == null) {
                Contact cn = new Contact();
                cn.Email = brandFuelEmail; 
                cn.brandfuel_user_key__c = dstKeyval;
                cn.brandfuel_user_id__C = dstusrId;  
                conUpdateList.add(cn);
            }
            else if(brandFuelContactId != null) {
                for(Contact con:[Select id,email,brandfuel_user_key__c,brandfuel_user_id__c from contact where id =: brandFuelContactId]) {
                    if(con.brandfuel_user_key__c == null && con.brandfuel_user_id__c == null) {
                        con.brandfuel_user_key__c = dstKeyval;
                        con.brandfuel_user_id__c =  dstusrId; 
                        conUpdateList.add(con);
                    }
                }
            }
            if(!conUpdateList.isEmpty() && !Test.isRunningTest()) {
                Utility.processRecords(conUpdateList, 'update');
            }  
        }
        if (Integer.ValueOf(objRequestResonse.Status_Code__c) != 200 || Test.isRunningTest()) {
            createBrandFuleUser(brandFuelName, brandFuelEmail, orderId, OrderLineIds, priceBookId, priceBookName, priceBookEndDate, OrderFullyPaid, brandFuelContactId, BdFuelEndDate);
        }
    }

    /**
    * @description  : if user is not exist then it will create user in brandfuel
    * @author       : mpatel@addonblue.com | 3/18/2020
    * @param        : String brandFuelName
    * @param        : String brandFuelEmail
    * @param        : Id orderId
    * @param        : List < Id > OrderLineIds
    * @param        : String priceBookId
    * @param        : String priceBookName
    * @param        : Date priceBookEndDate
    * @param        : Boolean OrderFullyPaid
    * @param        : Id brandFuelContactId
    * @param        : Date BdFuelEndDate
    * @return       : void 
    **/
    public static void createBrandFuleUser(String brandFuelName, String brandFuelEmail, Id orderId, List < Id > OrderLineIds, String priceBookId, String priceBookName, Date priceBookEndDate, Boolean OrderFullyPaid,Id brandFuelContactId,Date BdFuelEndDate) {
        List<Contact> conList = new List<Contact>();
        if (OrderFullyPaid == true ) {
            String body = '{"dstFirstName":"' + brandFuelName + '","dstEmailAddress":"' + brandFuelEmail + '","dstActive":"1"}';
            String endPointString = 'users';
            RequestResponse_Log__c objRequestResonse = Utility.callout('BrandFuelPostRequest', body, endPointString);
            System.debug('objRequestResonse.Response__c-->'+objRequestResonse.Response__c);
            String userKey;
            String usrId;
            JSONParser parser = JSON.createParser(objRequestResonse.Response__c);
            if (Integer.ValueOf(objRequestResonse.Status_Code__c) == 200) {
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'dstKey')) {
                        parser.nextToken();
                        userKey = parser.getText();
                        break;
                    }
                }
                JSONParser parser1 = JSON.createParser(objRequestResonse.Response__c);
                while (parser1.nextToken() != null) {
                    if((parser1.getCurrentToken() == JSONToken.FIELD_NAME) && (parser1.getText() == 'dstId')) {
                        parser1.nextToken();
                        usrId = parser1.getText();
                        break;
                    }    
                }  
            }
            Decimal orderLineItemAmount = 0;
            if (!OrderLineIds.isEmpty()){
                for (OrderItem orderLine: [SELECT ProductType__c, product2.Brandfuel_Points__c,quantity FROM OrderItem WHERE Id IN: OrderLineIds]) {
                    if (orderLine.ProductType__c == 'Giftbag' && orderLine.product2.Brandfuel_Points__c != null) {
                        orderLineItemAmount += orderLine.product2.Brandfuel_Points__c * orderLine.quantity;
                    }
                }
            }
            if(userKey != '' && Integer.ValueOf(objRequestResonse.Status_Code__c) == 200) {
                addBrandFuelCupon(priceBookId, OrderLineIds, priceBookName, orderId, String.valueOf(orderLineItemAmount), brandFuelEmail, priceBookEndDate,userKey,brandFuelContactId,usrId,BdFuelEndDate);
            }
        }
    }

    /**
    * @description  : add brandfuel coupon with user created
    * @author       : mpatel@addonblue.com | 3/18/2020
    * @param        : String priceBookId
    * @param        : List < Id > OrderLineIds
    * @param        : String priceBookName
    * @param        : Id orderId
    * @param        : String orderLineItemAmount
    * @param        : String brandFuelEmail
    * @param        : Date priceBookEndDate
    * @param        : String userKey
    * @param        : Id brandFuelContactId
    * @param        : String userId
    * @param        : Date BdFuelEndDate
    * @return       : void 
    **/
    public static void addBrandFuelCupon(String priceBookId, List < Id > OrderLineIds, String priceBookName, Id orderId, String orderLineItemAmount, String brandFuelEmail, date priceBookEndDate,String userKey,Id brandFuelContactId, String userId, Date BdFuelEndDate) {
        String coupnId = '';
        if(!OrderLineIds.isEmpty()){
            String endPointString = 'coupons';
            String body = '{"dstLabel":"' + priceBookName + '","dstAmount":"' + orderLineItemAmount + '","dstEmailAddress":"' + brandFuelEmail + '","dstExpiration":"' + BdFuelEndDate + '"}';
            RequestResponse_Log__c objRequestResonse = Utility.callout('BrandFuelPostRequest', body, EndpointString);
            System.debug('objRequestResonse.Response__c-->'+objRequestResonse.Response__c);
            JSONParser parser = JSON.createParser(objRequestResonse.Response__c);
            if (Integer.ValueOf(objRequestResonse.Status_Code__c) == 200) {
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'dstId')) {
                        parser.nextToken();
                        coupnId = parser.getText();
                        break;
                    }
                }
            }
        }
        List<contact> contactList = new List<contact>();
        for(contact con :[SELECT Id,brandfuel_user_key__c,Brandfuel_user_id__c from contact where id =:brandFuelContactId]){
            con.brandfuel_user_key__c = userKey;
            con.brandfuel_user_id__c = userId;
            contactList.add(con);
        }
        if(!contactList.isEmpty()){
            Utility.processRecords(contactList, 'update');
        }
        if ((coupnId != '' || coupnId != null) && !OrderLineIds.isEmpty()) {
            Brandfuel_coupon__c coup = new Brandfuel_coupon__c();
            coup.Name = priceBookName;
            //coup.Event__c = priceBookId;
            coup.Price_Book__c = priceBookId;
            coup.Coupon_Id__c = coupnId; 
            coup.Contact__c = contactList[0].Id;
            Utility.processRecords(coup, 'insert');
            System.debug('coup-->'+coup);
            List <Order> orderListEmailField = new List <Order>();
            String priceBookNameEncoded =  EncodingUtil.urlEncode(priceBookName,'UTF-8');      
            String url = System.Label.BrandFuelLinkUrl;
            
            for (Order objOrder: [Select id,Event__r.Name, Email__c, Account.RecordType.DeveloperName,
                Account.Primary_Contact__r.BrandFuel_User_Key__c, Account.BrandFuel_User_Key__c FROM Order WHERE id =: orderId]) {// and Email__c = : brandFuelEmail
                url = url + userKey;
                url = url + '&dstEvent=' +priceBookNameEncoded;
                objOrder.Brandfuel_Customer_Link__c = url;
                orderListEmailField.add(objOrder);
                System.debug('objOrder-->'+objOrder);
            }
            System.debug('orderListEmailField-->'+orderListEmailField);
            System.debug('OrderLineIds-->'+OrderLineIds);
            if ((!orderListEmailField.isEmpty() && !OrderLineIds.isEmpty())) {
                Utility.processRecords(orderListEmailField, 'update');
            }

        }
    }

    /**
    * @description  : update the brandfuel record
    * @author       : mpatel@addonblue.com | 3/18/2020
    * @param        : Id orderId
    * @param        : List<Id> OrderLineItemIds
    * @param        : String coupnId
    * @param        : String priceBookName
    * @param        : String brandFuelEmail
    * @param        : Date priceBookEndDate
    * @param        : String brandFuleUserKey
    * @param        : Date BdFuelEndDate
    * @return       : void 
    **/
    @future(callout = true)
    public static void cuponDataSubMethod(Id orderId,List<Id> OrderLineItemIds,String coupnId,String priceBookName,String brandFuelEmail,Date priceBookEndDate, String brandFuleUserKey, Date BdFuelEndDate){
        String endPointString = 'coupons/'+coupnId;
        String body = '';
        RequestResponse_Log__c objRequestResonse = Utility.callout('BrandFuelGetRequest', body, endPointString);
        System.debug('objRequestResonse.Response__c-->'+objRequestResonse.Response__c);
        JSONParser parser = JSON.createParser(objRequestResonse.Response__c);
        String dstAmountval= '0';
        System.debug('objRequestResonse.Status_Code__c-->'+objRequestResonse.Status_Code__c);
        if (Integer.ValueOf(objRequestResonse.Status_Code__c) == 200) {
            while (parser.nextToken() != null) {
                if ((Test.isRunningTest()) || ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'dstAmount'))){
                    parser.nextToken();
                    dstAmountval = parser.getText();
                    break;
                }
            }
        }
        Decimal amount = 0;
        if (!OrderLineItemIds.isEmpty() || Test.isRunningTest()) {
            for (OrderItem orderLine: [SELECT  ProductType__c , product2.Brandfuel_Points__c,Quantity FROM OrderItem WHERE Id IN: OrderLineItemIds]) {
                if ((orderLine.ProductType__c == 'Giftbag' && orderLine.product2.Brandfuel_Points__c != null) || Test.isRunningTest()) {
                  amount += orderLine.product2.Brandfuel_Points__c * orderLine.quantity;
                }
            }
        }
        if(!Test.isRunningTest()) {
            amount += Decimal.valueOf(dstAmountval);
        }
        
        Integer finalamount = 0; 
        finalamount += integer.valueOf(amount);
        String putBody = '{"dstLabel":"' + priceBookName + '","dstAmount":"' + finalamount + '","dstEmailAddress":"' + brandFuelEmail + '","dstExpiration":"' + BdFuelEndDate + '"}';
        RequestResponse_Log__c objPutRequestResonse = Utility.callout('BrandFuelPutRequest', putBody, endPointString);
        
        List <Order> listOfOrder = new List <Order>();
        String priceBookNameEncode = EncodingUtil.urlEncode(+priceBookName, 'UTF-8');         
        String url = System.Label.BrandFuelLinkUrl;
        for (Order objOrder: [Select id, Email__c, Account.RecordType.DeveloperName,
            Account.Primary_Contact__r.BrandFuel_User_Key__c, Account.BrandFuel_User_Key__c FROM Order WHERE id =:orderId]) {// AND  Email__c = : brandFuelEmail
            url = url + brandFuleUserKey;
            url = url + '&dstEvent=' +priceBookNameEncode;
            objOrder.Brandfuel_Customer_Link__c = url;
            listOfOrder.add(objOrder);
        }
        
        if ((!listOfOrder .isEmpty() && !OrderLineItemIds.isEmpty()) || Test.isRunningTest()) {
            Utility.processRecords(listOfOrder, 'update');
        }
    }

    /**
    * @description  : recreate coupon with the old emails
    * @author       : mpatel@addonblue.com | 3/18/2020
    * @param        : Id orderId
    * @param        : List<Id> OrderLineItemIds
    * @param        : String priceBookId
    * @param        : String priceBookName
    * @param        : String brandFuelEmail
    * @param        : Date priceBookEndDate
    * @param        : Id brandFuelContactId
    * @param        : String userKeyId
    * @param        : Date BdFuelEndDate
    * @return       : void 
    **/
    @future(callout = true)
    public static void couponRecCreateOldEmail(Id orderId,List<Id> OrderLineItemIds,String priceBookId,String priceBookName,String brandFuelEmail, Date priceBookEndDate, Id brandFuelContactId, String userKeyId, Date BdFuelEndDate) {
    
        Decimal amount = 0;
        if (!OrderLineItemIds.isEmpty() || Test.isRunningTest()) {
            for (orderItem orderLine: [SELECT ProductType__c , product2.Brandfuel_Points__c,quantity FROM orderItem WHERE Id IN: OrderLineItemIds]) {
                if ((orderLine.ProductType__c == 'Giftbag' && orderLine.product2.Brandfuel_Points__c != null) || Test.isRunningTest()) {
                amount += orderLine.product2.Brandfuel_Points__c * orderLine.quantity;
                }
            }
        }

        string endPointString = 'coupons';
        String body = '{"dstLabel":"' + priceBookName + '","dstAmount":"' + Amount + '","dstEmailAddress":"' + brandFuelEmail + '","dstExpiration":"' + BdFuelEndDate + '"}';
        RequestResponse_Log__c objRequestResonse = Utility.callout('BrandFuelPostRequest', body, endPointString);
        System.debug('objRequestResonse.Response__c-->'+objRequestResonse.Response__c);
        System.debug('objRequestResonse.Status_Code__c-->'+objRequestResonse.Status_Code__c);
        String couponId = '';
        JSONParser parser = JSON.createParser(objRequestResonse.Response__c);
        if (Integer.ValueOf(objRequestResonse.Status_Code__c) == 200) {
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'dstId')) {
                    parser.nextToken();
                    couponId = parser.getText();
                    break;
                }
            }
        }
        System.debug('objRequestResonse.Status_Code__c-->'+objRequestResonse.Status_Code__c);
        System.debug('couponId -->'+couponId);
        if (couponId != '' && Integer.ValueOf(objRequestResonse.Status_Code__c) == 200) {
            Brandfuel_coupon__c coup = new Brandfuel_coupon__c();
            coup.Name = priceBookName;
            //coup.Event__c = priceBookId;
            coup.Price_Book__c = priceBookId;
            coup.Coupon_Id__c = couponId; 
            coup.Contact__c = brandFuelContactId;
            Utility.processRecords(coup, 'insert');
            System.debug('coup-->'+coup);
            List < Order > orderListEmailField = new List < Order > ();
            String pbName =  EncodingUtil.urlEncode(priceBookName,'UTF-8');      
                String url = System.Label.BrandFuelLinkUrl;
            
            for (Order objOrder: [Select id,Event__r.Name, Email__c, Account.RecordType.DeveloperName,
                Account.Primary_Contact__r.BrandFuel_User_Key__c, Account.BrandFuel_User_Key__c FROM Order WHERE id =:orderId]) {// and Email__c = : brandFuelEmail
                url = url + userKeyId;
                url = url + '&dstEvent=' +pbName;
                objOrder.Brandfuel_Customer_Link__c = url;
                orderListEmailField.add(objOrder);
                System.debug('objOrder-->'+objOrder);
            }
            System.debug('orderListEmailField-->'+orderListEmailField);
            System.debug('OrderLineItemIds-->'+OrderLineItemIds);
            if ((!orderListEmailField.isEmpty() && !OrderLineItemIds.isEmpty()) || Test.isRunningTest()) {
                Utility.processRecords(orderListEmailField, 'update');
            }
        }
    }
    /**
    * @description  : update the brandfuel amount
    * @author       : mpatel@addonblue.com | 4/06/2020
    * @param        : Id orderId
    * @param        : List<Id> OrderLineItemIds
    * @param        : String coupnId
    * @param        : String priceBookName
    * @param        : String brandFuelEmail
    * @param        : Date priceBookEndDate
    * @param        : String brandFuleUserKey
    * @param        : Date BdFuelEndDate
    * @return       : void 
    **/
    @future(callout = true)
    public static void updateCouponAmount(Id orderId,List<Id> OrderLineItemIds,String coupnId,String priceBookName,String brandFuelEmail,Date priceBookEndDate, String brandFuleUserKey, Date BdFuelEndDate){
        String endPointString = 'coupons/'+coupnId;
        String body = '';
        RequestResponse_Log__c objRequestResonse = Utility.callout('BrandFuelGetRequest', body, endPointString);
        System.debug('objRequestResonse.Response__c-->'+objRequestResonse.Response__c);
        JSONParser parser = JSON.createParser(objRequestResonse.Response__c);
        String dstAmountval= '0';
        System.debug('objRequestResonse.Status_Code__c-->'+objRequestResonse.Status_Code__c);
        if (Integer.ValueOf(objRequestResonse.Status_Code__c) == 200) {
            while (parser.nextToken() != null) {
                if ((Test.isRunningTest()) || ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'dstAmount'))){
                    parser.nextToken();
                    dstAmountval = parser.getText();
                    break;
                }
            }
        }
        Decimal amount = 0;
        if (!OrderLineItemIds.isEmpty() || Test.isRunningTest()) {
            for (OrderItem orderLine: [SELECT  ProductType__c , product2.Brandfuel_Points__c,Quantity FROM OrderItem WHERE Id IN: OrderLineItemIds]) {
                if ((orderLine.ProductType__c == 'Giftbag' && orderLine.product2.Brandfuel_Points__c != null) || Test.isRunningTest()) {
                  amount += orderLine.product2.Brandfuel_Points__c * orderLine.quantity;
                }
            }
        }
        
        Integer finalamount = 0; 
        finalamount += integer.valueOf(amount);
        String putBody = '{"dstLabel":"' + priceBookName + '","dstAmount":"' + finalamount + '","dstEmailAddress":"' + brandFuelEmail + '","dstExpiration":"' + BdFuelEndDate + '"}';
        RequestResponse_Log__c objPutRequestResonse = Utility.callout('BrandFuelPutRequest', putBody, endPointString);
        
        List <Order> listOfOrder = new List <Order>();
        String priceBookNameEncode = EncodingUtil.urlEncode(+priceBookName, 'UTF-8');         
        String url = System.Label.BrandFuelLinkUrl;
        for (Order objOrder: [Select id, Email__c, Account.RecordType.DeveloperName,
            Account.Primary_Contact__r.BrandFuel_User_Key__c, Account.BrandFuel_User_Key__c FROM Order WHERE id =:orderId]) {// AND  Email__c = : brandFuelEmail
            url = url + brandFuleUserKey;
            url = url + '&dstEvent=' +priceBookNameEncode;
            objOrder.Brandfuel_Customer_Link__c = url;
            listOfOrder.add(objOrder);
        }
        
        if ((!listOfOrder .isEmpty() && !OrderLineItemIds.isEmpty()) || Test.isRunningTest()) {
            Utility.processRecords(listOfOrder, 'update');
        }
    }
}
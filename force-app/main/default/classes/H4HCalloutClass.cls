/**
 * @File Name          : H4HCalloutClass.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/9/2020, 1:18:09 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/27/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class H4HCalloutClass {
	@TestVisible
    private static String testResponse;
    
    @future(callout = true)
    public static void getTokenSiteAdmin(Id orderIds, boolean isClosedWonalone){
        Decimal memberPoints = 0.0;
        String TokenId = '';
        TokenId = getH4HTokenId();

        if(!isClosedWonalone){
            List<Order> orderList =new List<Order>();
            for(Order objOrder : [Select Id,Email__c,Phone__c,Reward_Points_Pending__c,Billing_Street__c,Ship_To_Name__c,StageName__c,Paid_in_Full__c from Order where id =:orderIds]) {
                createRequestToH4H(objOrder,false,0.0, TokenId);
            }
        }else{
            List<Order> orderList =new List<Order>();
            Decimal H4HasRes = 0.0;
            List<Order> orderToUpdate = [Select Id,Email__c,Phone__c,Reward_Points_Pending__c,Billing_Street__c,Ship_To_Name__c,StageName__c,Paid_in_Full__c,(select Id, UnitPrice FROM OrderItems Where ProductType__c = 'Reward Discount' AND Package__c = null)from Order where id =:orderIds];
            List<OrderItem> OrderLineList = new List<OrderItem>();
            Decimal curOppPoints = 0.0;
            for(Order objOrder : orderToUpdate){
                H4HasRes = createRequestToH4HForClosedWon(objOrder, tokenId);
                Decimal discountAmount = 0.0;

                for(OrderItem orderItm: objOrder.OrderItems){
                    System.debug('*** disc unit price***' +orderItm.UnitPrice);
                    discountAmount = discountAmount - orderItm.UnitPrice;
                }
                if(H4HasRes >= discountAmount ){
                    for(OrderItem orderItm: objOrder.OrderItems){
                        orderItm.Reward_Points_Earned__c  = 0 - discountAmount;
                        OrderLineList.add(orderItm);
                        if(orderItm.Order.Online_Order__c == false) {
                            curOppPoints = objOrder.Reward_Points_Pending__c + (0 - discountAmount);
                        } else if(orderItm.Order.Online_Order__c == false) {
                            curOppPoints = objOrder.Reward_Points_Pending__c;
                        }
                    }
                }else{
                    for(OrderItem orderItm: objOrder.OrderItems){
                        orderItm.UnitPrice  = 0.0;
                        OrderLineList.add(orderItm);
                        curOppPoints = 0.0;
                    }
                }
            }
            /*if(!orderToUpdate.isEmpty()){
                update orderToUpdate;
            }*/

            if(orderToUpdate[0].Paid_in_Full__c == true || Test.isRunningTest()){
                createRequestToH4HFORClosedWonAndPaidFull(orderToUpdate[0],H4HasRes,curOppPoints,TokenId);
            }
            if(!OrderLineList.isEmpty()){
                update OrderLineList;
            }
        }
    }

    public static string getH4HTokenId(){
        H4H_API_Details__c ha4APISettings = H4H_API_Details__c.getOrgDefaults();
        String tokenId = '';
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String usernames = ha4APISettings.H4H_username__c;//label.H4H_username;
        String passwords = ha4APISettings.H4H_password__c;//label.H4H_password;
        string siteIds = label.H4H_Site_Id;
        string tokens = 'ARNUSER-aodom@quintevents.com';
        req.setEndpoint(ha4APISettings.H4H_GetMemberPoints_EndPoint__c+'username='+ usernames +'&password=' + passwords +'&siteid='+siteIds +'&token='+tokens);
        System.debug('***re body1**'+req.getendpoint());
        Http http = new Http();
        HTTPResponse res;
        if(!Test.isRunningTest()){
          res = http.send(req);  
        }
        String jsonReposne = !Test.isRunningTest() ? res.getBody() : testResponse;
        System.debug('**response**' +res);
        //System.debug('****response body*****'+res.getBody());
        if(!Test.isRunningTest()){
            JSONParser parser = JSON.createParser(res.getBody());
        
        if (res.getStatusCode() == 200 ) {
            
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'CurrentToken')) {
                    parser.nextToken();
                    tokenId = parser.getText();
                    System.debug('***tokenvalue**'+TokenId);
                    break;
                }
            }
        }
        }
       
        return tokenId;
    }

    Public static void createRequestToH4H(Order objOrder, Boolean isWritePoints, decimal memberpoints,String TokenId){
        H4H_API_Details__c ha4APISettings = H4H_API_Details__c.getOrgDefaults();
        String firstNameNew ='';
        String lastNameNew ='';
        String usernames = ha4APISettings.H4H_username__c;//label.H4H_username;
        String passwords = ha4APISettings.H4H_password__c;//label.H4H_password;
        string siteIds =label.H4H_Site_Id;
        Decimal memberPointsFromRes = 0.0;
        try{
            String shipToName = objOrder.Ship_To_Name__c;
            System.debug('***ship to name***'+shipToName);
            Integer shipToNamelength = shipToName.length();
            System.debug('***name length***'+shipToNamelength);
            Integer lastValue = shipToName.lastIndexOf(' ');
            System.debug('**last index***' +lastValue);
            Integer firstValue = shipToName.indexOf(' ');
            System.debug('***index first value**'+firstValue);
            lastNameNew = shipToName.substring(lastValue+1,shipToNamelength);
            firstNameNew = shipToName.substring(0,firstValue);
        }catch(Exception e){
            firstNameNew = objOrder.Ship_To_Name__c;
            lastNameNew = objOrder.Ship_To_Name__c;
        }
        Integer totalH4HPoints = 0;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        if(isWritePoints && objOrder.Reward_Points_Pending__c != null){
            List<Order> orderList = [Select Id,Reward_Points_Pending__c from Order where id=:objOrder.id];
            decimal points = memberpoints + orderList[0].Reward_Points_Pending__c;
            if(points > 0) {
                gen.writeNumberField('points', Integer.valueOf(points));
                System.debug('**** final points***'+points);
            } else {
                gen.writeNumberField('points', Integer.valueOf(memberpoints));
                System.debug('**** tot points***' +memberpoints);
                List<OrderItem> listOrder = [select Id, UnitPrice  FROM OrderItem Where OrderId =: objOrder.Id AND ProductType__c = 'Reward Discount' AND Package__c = null];
                for(OrderItem oli : listOrder){
                    oli.UnitPrice = 0.0;
                }
                Database.Update(listOrder, false);
            }
        }

        gen.writeFieldName('Names');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('ReferralId', objOrder.Email__c);
        gen.writeStringField('FirstName',firstNameNew);
        gen.writeStringField('LastName',lastNameNew);
        gen.writeStringField('Email',objOrder.Email__c);
        gen.writeEndObject();
        String jsonS = gen.getAsString();
        System.debug('jsonMaterials'+jsonS);
        HttpRequest req1 = new HttpRequest();
        req1.setMethod('POST');
        req1.setEndpoint(ha4APISettings.H4H_GetMemberPoints_EndPoint__c);
        req1.setHeader('Cache-Control','no-cache');
        req1.setHeader('Content-type','application/x-www-form-urlencoded');
        req1.setBody('siteid='+siteIds+'&token='+TokenId +'&memberData='+jsonS);
        System.debug('***req body**'+req1.getbody());
        Http http = new Http();
        HTTPResponse res;
        if(!Test.isRunningTest()){
          res = http.send(req1);  
        }
        String jsonReposne = !Test.isRunningTest() ? res.getBody() : testResponse;
        //HTTPResponse resp = h.send(req1);
        System.debug('***response debug***'+jsonReposne);
        QE_H4HRecursive4Callout.inFutureContext = true;
        JSONParser parser1 = JSON.createParser(jsonReposne);

        String memberStatus;
        if (Test.isRunningTest() || res.getStatusCode() == 200) {
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
        if(!isWritePoints){
            createRequestToH4H(objOrder, true, memberPointsFromRes,TokenId);
        }
    }

    public static void createRequestToH4HFORClosedWonAndPaidFull(Order objOrder, decimal memberpoints, decimal currentOppPoints, String TokenId){
        H4H_API_Details__c ha4APISettings = H4H_API_Details__c.getOrgDefaults();
        String firstNameNew ='';
        String lastNameNew ='';
        String usernames = ha4APISettings.H4H_username__c;//label.H4H_username;
        String passwords = ha4APISettings.H4H_password__c;//label.H4H_password;
        string siteIds =label.H4H_Site_Id;
        Decimal memberPointsFromRes = 0.0;
        try{
            String shipToName = objOrder.Ship_To_Name__c;
            System.debug('***ship to name***'+shipToName);
            Integer shipToNamelength = shipToName.length();
            System.debug('***name length***'+shipToNamelength);
            Integer lastValue = shipToName.lastIndexOf(' ');
            System.debug('**last index***' +lastValue);
            Integer firstValue = shipToName.indexOf(' ');
            System.debug('***index first value**'+firstValue);

            lastNameNew = shipToName.substring(lastValue+1,shipToNamelength);
            firstNameNew = shipToName.substring(0,firstValue);
        }catch(Exception e){
            firstNameNew = objOrder.Ship_To_Name__c;
            lastNameNew = objOrder.Ship_To_Name__c;
        }
        Integer totalH4HPoints = 0;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();

        decimal points = memberpoints + currentOppPoints;
        if(points > 0) {
            gen.writeNumberField('points', Integer.valueOf(points));
            System.debug('**** final points***'+points);
        } else {
            gen.writeNumberField('points', Integer.valueOf(memberpoints));
            System.debug('**** tot points***' +memberpoints);
            List<OrderItem> listOrder = [select Id, UnitPrice FROM OrderItem Where OrderId =: objOrder.Id AND ProductType__c = 'Reward Discount' AND Package__c = null];
            for(OrderItem oli:listOrder){
                oli.UnitPrice = 0.0;
            }
            Database.Update(listOrder, false);
        }

        gen.writeFieldName('Names');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('ReferralId', objOrder.Email__c);
        gen.writeStringField('FirstName',firstNameNew);
        gen.writeStringField('LastName',lastNameNew);
        gen.writeStringField('Email',objOrder.Email__c);
        gen.writeEndObject();
        String jsonS = gen.getAsString();
        System.debug('jsonMaterials'+jsonS);
        HttpRequest req1 = new HttpRequest();
        req1.setMethod('POST');
        req1.setEndpoint(ha4APISettings.H4H_GetMemberPoints_EndPoint__c);
        req1.setHeader('Cache-Control','no-cache');
        req1.setHeader('Content-type','application/x-www-form-urlencoded');
        req1.setBody('siteid='+siteIds+'&token='+TokenId +'&memberData='+jsonS);
        System.debug('***req body**'+req1.getbody());
        Http http = new Http();
        HTTPResponse res;
        if(!Test.isRunningTest()){
          res = http.send(req1);  
        }
        String jsonReposne = !Test.isRunningTest() ? res.getBody() : testResponse;
        System.debug('***response debug***'+jsonReposne);
        QE_H4HRecursive4Callout.inFutureContext = true;
        JSONParser parser1 = JSON.createParser(jsonReposne);

        String memberStatus;
        if (Test.isRunningTest() || res.getStatusCode() == 200) {
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
    }

    public static Decimal createRequestToH4HForClosedWon(Order objOrder,String TokenId){
        H4H_API_Details__c ha4APISettings = H4H_API_Details__c.getOrgDefaults();
        String firstNameNew ='';
        String lastNameNew ='';
        String usernames = ha4APISettings.H4H_username__c;//label.H4H_username;
        String passwords = ha4APISettings.H4H_password__c;//label.H4H_password;
        string siteIds =label.H4H_Site_Id;
        Decimal memberPointsFromRes = 0.0;
        try{
            String shipToName = objOrder.Ship_To_Name__c;
            System.debug('***ship to name***'+shipToName);
            Integer shipToNamelength = shipToName.length();
            System.debug('***name length***'+shipToNamelength);
            Integer lastValue = shipToName.lastIndexOf(' ');
            System.debug('**last index***' +lastValue);
            Integer firstValue = shipToName.indexOf(' ');
            System.debug('***index first value**'+firstValue);

            lastNameNew = shipToName.substring(lastValue+1,shipToNamelength);
            firstNameNew = shipToName.substring(0,firstValue);
        }catch(Exception e){
            firstNameNew = objOrder.Ship_To_Name__c;
            lastNameNew = objOrder.Ship_To_Name__c;
        }
        Integer totalH4HPoints = 0;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('Names');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('ReferralId', objOrder.Email__c);
        gen.writeStringField('FirstName',firstNameNew);
        gen.writeStringField('LastName',lastNameNew);
        gen.writeStringField('Email',objOrder.Email__c);
        gen.writeEndObject();
        String jsonS = gen.getAsString();
        System.debug('jsonMaterials'+jsonS);
        HttpRequest req1 = new HttpRequest();
        req1.setMethod('POST');
        req1.setEndpoint(ha4APISettings.H4H_GetMemberPoints_EndPoint__c);
        req1.setHeader('Cache-Control','no-cache');
        req1.setHeader('Content-type','application/x-www-form-urlencoded');
        req1.setBody('siteid='+siteIds+'&token='+TokenId +'&memberData='+jsonS);
        System.debug('***req body**'+req1.getbody());
        Http http = new Http();
        HTTPResponse res;
        if(!Test.isRunningTest()){
          res = http.send(req1);  
        }
        String jsonReposne = !Test.isRunningTest() ? res.getBody() : testResponse;
        System.debug('***response debug***'+jsonReposne);
        QE_H4HRecursive4Callout.inFutureContext = true;
        JSONParser parser1 = JSON.createParser(jsonReposne);

        String memberStatus;
        if (Test.isRunningTest() || res.getStatusCode() == 200) {
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
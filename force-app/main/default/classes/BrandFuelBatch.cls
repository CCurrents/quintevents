/**
 * @description       : 
 * @author            : jagrawal@addonblue.com
 * @group             : 
 * @last modified on  : 04-20-2022
 * @last modified by  : fsuraitawala@addonblue.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   07-27-2020   Jheel Agrawal            Initial Version
 * 1.1  03-02-2021  kchavda@addonblue.com      #836 Brandfuel URL not generated correctly
 * 1.2  04-20-2022  fsuraitawala@addonblue.com #1191 Brandfuel code fix for same contact in multiple Order
**/
public class BrandFuelBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    
    String query;
    Set<Id> setOrderIdsBF;
    Set<Id> setOrderItemIdsBF;
    Map<Id, List<OrderItem>> mapOrderNBFOrderItems = new Map<Id, List<OrderItem>>();
    
    public BrandFuelBatch(String query, Set<Id> setOrderIdsBF, Set<Id> setOrderItemIdsBF){
        System.debug('@@@In Constructor of BrandFuelBatch@@@');
        this.query = query;
        this.setOrderIdsBF = setOrderIdsBF;
        this.setOrderItemIdsBF = setOrderItemIdsBF;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('@@@In Start Method of BrandFuelBatch@@@');
        List<OrderItem> lstOLI = [Select Id, OrderId, Product2Id, Product2.Name, Product2.Brandfuel_Points__c, Quantity from OrderItem where Id IN :setOrderItemIdsBF];
        for(OrderItem objOLI: lstOLI){            
            // #836 Brandfuel URL not generated correctly -- Start
            if(!mapOrderNBFOrderItems.containsKey(objOLI.OrderId)) {mapOrderNBFOrderItems.put(objOLI.OrderId, new List<OrderItem>{objOLI});}
            else{
                List<OrderItem> lstBFOLI = new List<OrderItem>(mapOrderNBFOrderItems.get(objOLI.OrderId));                
                lstBFOLI.add(objOLI);
                mapOrderNBFOrderItems.put(objOLI.OrderId, lstBFOLI);
             }
            // #836 Brandfuel URL not generated correctly -- End
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Order> scope){
        System.debug('@@@In Execute Method of BrandFuelBatch@@@');
        List<RequestResponse_Log__c> lstRequestResponseLogs = new List<RequestResponse_Log__c>();
        List<Brandfuel_coupon__c> lstBrandFuelCoupons = new List<Brandfuel_coupon__c>();
        List<Contact> lstContactsToUpdate = new List<Contact>();
        List<Order> lstOrdersToUpdate = new List<Order>();
        List<RequestResponse_Log__c> lstDeleteRRLogs = new List<RequestResponse_Log__c>();
        lstDeleteRRLogs = [Select Id FROM RequestResponse_Log__c WHERE Order__c IN :scope AND Class_Name__c = 'BrandFuelBatch'];
        Set<Id> setOppIds = new Set<Id>();
        for(Order objOrder: scope){
            System.debug('ObjOrder:- '+objOrder);
            setOppIds.add(objOrder.OpportunityId);
        }
        List<OpportunityContactRole> lstOppConRole = [Select Id, Role, ContactId, Contact.Id, Contact.Email, Contact.Name, Contact.BrandFuel_User_Key__c, Contact.Brandfuel_User_Id__c, OpportunityId from OpportunityContactRole where OpportunityId in :setOppIds AND Role = 'Brandfuel Contact'];
        Map<Id, Contact> mapOCRContact = new Map<Id, Contact>();
        for(OpportunityContactRole objOCR: lstOppConRole){
            mapOCRContact.put(objOCR.OpportunityId, objOCR.Contact);
        }
        System.debug('@@mapOCRContact:-'+mapOCRContact);
        for(Order objOrder: scope){
            if(mapOCRContact.containsKey(objOrder.OpportunityId)){
                
                BFUserResponse objBFUserRes = checkBFUserNCreate(mapOCRContact.get(objOrder.OpportunityId).Email, mapOCRContact.get(objOrder.OpportunityId).Name, objOrder.Id);
                
                if((objBFUserRes != null && !objBFUserRes.users.isEmpty() && String.isNotBlank(objBFUserRes.users[0].dstKey)) || Test.isRunningTest()){
                    if(String.isBlank(mapOCRContact.get(objOrder.OpportunityId).BrandFuel_User_Key__c)){
                        Contact objContact = new Contact();
                        objContact.Id = mapOCRContact.get(objOrder.OpportunityId).Id;
                        objContact.BrandFuel_User_Key__c = objBFUserRes.users[0].dstKey;
                        objContact.Brandfuel_User_Id__c = objBFUserRes.users[0].dstId;
                        lstContactsToUpdate.add(objContact);
                    }
                    lstRequestResponseLogs.addAll(objBFUserRes.lstRR);
    
                    BFCouponResponse objBFCouponRes = checkBFCouponNCreateUpdate(mapOCRContact.get(objOrder.OpportunityId).Email, objOrder, mapOrderNBFOrderItems.get(objOrder.Id), mapOCRContact.get(objOrder.OpportunityId).Id);
                    if(objBFCouponRes.objNewBFCouponSF != null){
                        lstBrandFuelCoupons.add(objBFCouponRes.objNewBFCouponSF);
                    }
                    if(String.isBlank(objOrder.Brandfuel_Customer_Link__c)){
                        Order objNewOrder = new Order();
                        objNewOrder.Id = objOrder.Id;
                        if(!Test.isRunningTest()){ objNewOrder.Brandfuel_Customer_Link__c = System.Label.BrandFuelLinkUrl + objBFUserRes.users[0].dstKey + '&dstEvent=' + EncodingUtil.urlEncode(objOrder.PriceBook2.Name, 'UTF-8'); }
                        lstOrdersToUpdate.add(objNewOrder);
                    }
                    lstRequestResponseLogs.addAll(objBFCouponRes.lstRR);
                }
            }
        }
        
        System.debug('@@lstDeleteRRLogs:- '+lstDeleteRRLogs.size()+'\n'+lstDeleteRRLogs);
        if(lstDeleteRRLogs.size() > 0){
            delete lstDeleteRRLogs;
        }
        System.debug('@@lstRequestResponseLogs:- '+lstRequestResponseLogs.size()+'\n'+lstRequestResponseLogs);
        if(lstRequestResponseLogs.size() > 0){
            insert lstRequestResponseLogs;
        }
        System.debug('@@lstBrandFuelCoupons:- '+lstBrandFuelCoupons.size()+'\n'+lstBrandFuelCoupons);
        if(lstBrandFuelCoupons.size() > 0){
            insert lstBrandFuelCoupons;
        }
        System.debug('@@lstContactsToUpdate:- '+lstContactsToUpdate.size()+'\n'+lstContactsToUpdate);
        if(lstContactsToUpdate.size() > 0){
            update lstContactsToUpdate;
        }
        System.debug('@@lstOrdersToUpdate:- '+lstOrdersToUpdate.size()+'\n'+lstOrdersToUpdate);
        if(lstOrdersToUpdate.size() > 0){
            update lstOrdersToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('@@@In Finish Method of BrandFuelBatch@@@');
    }
    
    private BFUserResponse checkBFUserNCreate(String userEmail, String userName, Id orderId) {
        System.debug('@@userEmail:- '+userEmail);
        System.debug('@@userName:- '+userName);
        System.debug('@@orderId:- '+orderId);
        BFUserResponse objRes = new BFUserResponse();
        List<RequestResponse_Log__c> lstRR = new List<RequestResponse_Log__c>();
        Integration_Setting__mdt objIntegrationSetting = new Integration_Setting__mdt();
        objIntegrationSetting =  [Select Content_Type__c,Endpoint__c,Type__c,UserId__c,Password__c from Integration_Setting__mdt where DeveloperName ='BrandFuelGetRequest' and Is_Active__c = true LIMIT 1];
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(objIntegrationSetting.Endpoint__c+'users/'+userEmail);
        req.setMethod(objIntegrationSetting.Type__c);
        req.setHeader('User-Agent', 'Fulcrum');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-type', 'application/json');
        Blob headerValue = Blob.valueOf(objIntegrationSetting.UserId__c + ':' + objIntegrationSetting.Password__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        Http http = new Http();
        System.debug('@@BrandFuel User request:- '+req.getBody());
        HTTPResponse res;
        if(!Test.isRunningTest()){ res = http.send(req); }
        else{ 
            HttpResponse res1 = new HttpResponse();
            res1.setBody('');
            res1.setStatusCode(201);
            res = res1;
        }
        System.debug('@@Brandfuel User response:- '+res.getBody());

        RequestResponse_Log__c objRR = new RequestResponse_Log__c();
        objRR.Response__c = String.valueof(res.getBody());
        objRR.Request__c = String.valueOf(req.getBody());
        objRR.Status_Code__c = res.getStatusCode()+'';
        objRR.Message_Type__c = res.getStatus();
        objRR.API_URL__c = req.getEndpoint();
        objRR.Class_Name__c = 'BrandFuelBatch';
        objRR.Method_Name__c = 'checkBFUserNCreate';
        objRR.Order__c = orderId;
        lstRR.add(objRR);

        // -------------------------------------------- IF USER DOESN'T EXISTS -------------------------------------------- //
        if(res.getStatusCode() != 200){
            String body = '{'
                            + '"dstFirstName":"'+userName+'",'
                            + '"dstEmailAddress":"'+userEmail+'",'
                            + '"dstActive":1'
                        + '}';
            System.debug('@@body:- '+body);
            req.setEndpoint(objIntegrationSetting.Endpoint__c+'users');
            req.setMethod('POST');
            req.setBody(body);
            System.debug('@@BrandFuel User request:- '+req.getBody());
            if(!Test.isRunningTest()){ res = http.send(req); }
            else{ 
                HttpResponse res1 = new HttpResponse();
                res1.setBody('{"users":[{"dstId":"123"}]}');
                res1.setStatusCode(200);
                res = res1;
            }
            System.debug('@@Brandfuel User response:- '+res.getBody());

            objRR = new RequestResponse_Log__c();
            objRR.Response__c = String.valueof(res.getBody());
            objRR.Request__c = String.valueOf(req.getBody());
            objRR.Status_Code__c = res.getStatusCode()+'';
            objRR.Message_Type__c = res.getStatus();
            objRR.API_URL__c = req.getEndpoint();
            objRR.Class_Name__c = 'BrandFuelBatch';
            objRR.Method_Name__c = 'checkBFUserNCreate';
            objRR.Order__c = orderId;
            lstRR.add(objRR);
        }

        if(res.getStatusCode() == 200){
            objRes = (BFUserResponse)JSON.deserialize(String.valueOf(res.getBody()), BFUserResponse.class);
        }
        objRes.lstRR = lstRR;
        return objRes;
    }

    private BFCouponResponse checkBFCouponNCreateUpdate(String userEmail, Order objOrder, List<OrderItem> lstBFOrderItems, Id contactId) {
        System.debug('@@userEmail:- '+userEmail);
        System.debug('@@objOrder:- '+objOrder);
        System.debug('@@lstBFOrderItems:- '+lstBFOrderItems);
        System.debug('@@contactId:- '+contactId);
        BFCouponResponse objRes = new BFCouponResponse();
        List<RequestResponse_Log__c> lstRR = new List<RequestResponse_Log__c>();
        BFCoupon objBFCoupon; 
        Integration_Setting__mdt objIntegrationSetting = new Integration_Setting__mdt();
        objIntegrationSetting =  [Select Content_Type__c,Endpoint__c,Type__c,UserId__c,Password__c from Integration_Setting__mdt where DeveloperName ='BrandFuelPostRequest' and Is_Active__c = true LIMIT 1];
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(objIntegrationSetting.Endpoint__c+'coupons/'+userEmail);
        req.setMethod('GET');
        req.setHeader('User-Agent', 'Fulcrum');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-type', 'application/json');
        Blob headerValue = Blob.valueOf(objIntegrationSetting.UserId__c + ':' + objIntegrationSetting.Password__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        Http http = new Http();
        System.debug('@@BrandFuel User request:- '+req.getBody());
        HTTPResponse res;
        if(!Test.isRunningTest()){ res = http.send(req); }
        else{ 
            HttpResponse res1 = new HttpResponse();
            res1.setBody('{"coupons":[{"dstId":"123","dstLabel":"Test","dstAmount":"15"}]}');
            res1.setStatusCode(200);
            res = res1;
        }
        System.debug('@@Brandfuel User response:- '+res.getBody());

        RequestResponse_Log__c objRR = new RequestResponse_Log__c();
        objRR.Response__c = String.valueof(res.getBody());
        objRR.Request__c = String.valueOf(req.getBody());
        objRR.Status_Code__c = res.getStatusCode()+'';
        objRR.Message_Type__c = res.getStatus();
        objRR.API_URL__c = req.getEndpoint();
        objRR.Class_Name__c = 'BrandFuelBatch';
        objRR.Method_Name__c = 'checkBFCouponNCreateUpdate';
        objRR.Order__c = objOrder.Id;
        lstRR.add(objRR);

        Decimal CouponAmount = 0.0;
        for(OrderItem objOrderItem: lstBFOrderItems){ CouponAmount += objOrderItem.Product2.Brandfuel_Points__c * objOrderItem.Quantity; }

        // If User is old user and have any coupons associated.
        if(res.getStatusCode() == 200){
            objRes = (BFCouponResponse)JSON.deserialize(String.valueOf(res.getBody()), BFCouponResponse.class);
            Integer i = 0;
            for(BFCoupon objCoupon: objRes.coupons){
                if(objCoupon.dstLabel == objOrder.PriceBook2.Name){ objBFCoupon = objCoupon; break; }
            }
            
            // If Coupon Exists in Brandfuel then update the amount 
            if(objBFCoupon != null){
                CouponAmount += Integer.valueOf(objBFCoupon.dstAmount);
                String body = '{' + '"dstLabel":"'+objOrder.PriceBook2.Name+'",' + '"dstAmount":"'+CouponAmount+'",' + '"dstEmailAddress":"'+userEmail+'",' + '"dstExpiration":"'+objOrder.PriceBook2.End_Date__c+'"' + '}';
                System.debug('@@body:- '+body);
                req.setEndpoint(objIntegrationSetting.Endpoint__c+'coupons/'+objBFCoupon.dstId); req.setMethod('PUT'); req.setBody(body); http = new Http();
                System.debug('@@BrandFuel User request:- '+req.getBody());
                if(!Test.isRunningTest()){ res = http.send(req); }
                else{ 
                    HttpResponse res1 = new HttpResponse(); res1.setBody('{"coupons":[{"dstId":"123","dstLabel":"Test","dstAmount":"15"}]}'); res1.setStatusCode(200); res = res1;
                }
                System.debug('@@Brandfuel User response:- '+res.getBody());

                objRR = new RequestResponse_Log__c(); objRR.Response__c = String.valueof(res.getBody()); objRR.Request__c = String.valueOf(req.getBody()); objRR.Status_Code__c = res.getStatusCode()+''; objRR.Message_Type__c = res.getStatus(); 
                objRR.API_URL__c = req.getEndpoint(); objRR.Class_Name__c = 'BrandFuelBatch'; objRR.Method_Name__c = 'checkBFCouponNCreateUpdate'; objRR.Order__c = objOrder.Id; lstRR.add(objRR);

                if(res.getStatusCode() == 200){ BFCouponResponse objRes1 = (BFCouponResponse)JSON.deserialize(String.valueOf(res.getBody()), BFCouponResponse.class); }

                // If the coupon doesn't exists in Salesforce then create a new one.
                List<Brandfuel_coupon__c> lstBFCouponsSF = [Select Id, Coupon_Id__c from Brandfuel_coupon__c where Coupon_Id__c = :objBFCoupon.dstId];
                if(lstBFCouponsSF.size() == 0){ Brandfuel_coupon__c objBFCouponSF = new Brandfuel_coupon__c(); objBFCouponSF.Contact__c = contactId; objBFCouponSF.Price_Book__c = objOrder.PriceBook2Id; 
                    objBFCouponSF.Coupon_Id__c = objBFCoupon.dstId; objRes.objNewBFCouponSF = objBFCouponSF;
                }

            }// If Coupon Doesn't Exists in Brandfuel then create new one.
            else {
                List<Brandfuel_coupon__c> lstBFCouponsSF = [Select Id, Coupon_Id__c from Brandfuel_coupon__c where Price_Book__c = :objOrder.PriceBook2Id AND Contact__c = :contactId];
                if(lstBFCouponsSF.size() > 0){
                    req.setEndpoint(objIntegrationSetting.Endpoint__c+'coupons/'+lstBFCouponsSF[0].Coupon_Id__c); req.setMethod('GET'); http = new Http();
                    System.debug('@@BrandFuel User request:- '+req.getBody());
                    res = http.send(req);
                    System.debug('@@Brandfuel User response:- '+res.getBody());

                    objRR = new RequestResponse_Log__c(); objRR.Response__c = String.valueof(res.getBody()); objRR.Request__c = String.valueOf(req.getBody()); objRR.Status_Code__c = res.getStatusCode()+''; objRR.Message_Type__c = res.getStatus(); 
                    objRR.API_URL__c = req.getEndpoint(); objRR.Class_Name__c = 'BrandFuelBatch'; objRR.Method_Name__c = 'checkBFCouponNCreateUpdate'; objRR.Order__c = objOrder.Id; lstRR.add(objRR);

                    if(res.getStatusCode() == 200){
                        BFCouponResponse objRes2 = (BFCouponResponse)JSON.deserialize(String.valueOf(res.getBody()), BFCouponResponse.class); CouponAmount += Integer.valueOf(objRes2.coupons[0].dstAmount);

                        String body = '{' + '"dstLabel":"'+objOrder.PriceBook2.Name+'",' + '"dstAmount":"'+CouponAmount+'",' + '"dstEmailAddress":"'+userEmail+'",' + '"dstExpiration":"'+objOrder.PriceBook2.End_Date__c+'"' + '}';
                        System.debug('@@body:- '+body);
                        req.setEndpoint(objIntegrationSetting.Endpoint__c+'coupons/'+lstBFCouponsSF[0].Coupon_Id__c); req.setMethod('PUT'); req.setBody(body); http = new Http();
                        System.debug('@@BrandFuel User request:- '+req.getBody()); 
                        res = http.send(req);
                        System.debug('@@Brandfuel User response:- '+res.getBody());

                        objRR = new RequestResponse_Log__c(); objRR.Response__c = String.valueof(res.getBody()); objRR.Request__c = String.valueOf(req.getBody()); objRR.Status_Code__c = res.getStatusCode()+''; objRR.Message_Type__c = res.getStatus();
                        objRR.API_URL__c = req.getEndpoint(); objRR.Class_Name__c = 'BrandFuelBatch'; objRR.Method_Name__c = 'checkBFCouponNCreateUpdate'; objRR.Order__c = objOrder.Id; lstRR.add(objRR);
                            
                        if(res.getStatusCode() == 200){ BFCouponResponse objRes3 = (BFCouponResponse)JSON.deserialize(String.valueOf(res.getBody()), BFCouponResponse.class); }
                    }
                }
                else{

                    String body = '{'
                            + '"dstLabel":"'+objOrder.PriceBook2.Name+'",'
                            + '"dstAmount":"'+CouponAmount+'",'
                            + '"dstEmailAddress":"'+userEmail+'",'
                            + '"dstExpiration":"'+objOrder.PriceBook2.End_Date__c+'"'
                        + '}';
                    System.debug('@@body:- '+body);
                    req.setEndpoint(objIntegrationSetting.Endpoint__c+'coupons/');
                    req.setMethod('POST');
                    req.setBody(body);
                    http = new Http();
                    System.debug('@@BrandFuel User request:- '+req.getBody());
                    if(!Test.isRunningTest()){ res = http.send(req); }
                    else{ 
                        HttpResponse res1 = new HttpResponse();
                        res1.setBody('{"coupons":[{"dstId":"123","dstLabel":"Test","dstAmount":"15"}]}');
                        res1.setStatusCode(200);
                        res = res1;
                    }
                    System.debug('@@Brandfuel User response:- '+res.getBody());

                    objRR = new RequestResponse_Log__c();
                    objRR.Response__c = String.valueof(res.getBody());
                    objRR.Request__c = String.valueOf(req.getBody());
                    objRR.Status_Code__c = res.getStatusCode()+'';
                    objRR.Message_Type__c = res.getStatus();
                    objRR.API_URL__c = req.getEndpoint();
                    objRR.Class_Name__c = 'BrandFuelBatch';
                    objRR.Method_Name__c = 'checkBFCouponNCreateUpdate';
                    objRR.Order__c = objOrder.Id;
                    lstRR.add(objRR);

                    if(res.getStatusCode() == 200){
                        BFCouponResponse objRes4 = (BFCouponResponse)JSON.deserialize(String.valueOf(res.getBody()), BFCouponResponse.class);

                        Brandfuel_coupon__c objBFCouponSF = new Brandfuel_coupon__c();
                        objBFCouponSF.Name = objOrder.PriceBook2.Name;
                        objBFCouponSF.Contact__c = contactId;
                        objBFCouponSF.Price_Book__c = objOrder.PriceBook2Id;
                        objBFCouponSF.Coupon_Id__c = objRes4.coupons[0].dstId;
                        objRes.objNewBFCouponSF = objBFCouponSF;
                    }
                }
            }

        }// If User is new and doesn't have any coupons associated.
        else{

            String body = '{' + '"dstLabel":"'+objOrder.PriceBook2.Name+'",' + '"dstAmount":"'+CouponAmount+'",' + '"dstEmailAddress":"'+userEmail+'",' + '"dstExpiration":"'+objOrder.PriceBook2.End_Date__c+'"' + '}';
            System.debug('@@body:- '+body);
            req.setEndpoint(objIntegrationSetting.Endpoint__c+'coupons/'); req.setMethod('POST'); req.setBody(body); http = new Http();
            System.debug('@@BrandFuel User request:- '+req.getBody());
            res = http.send(req);
            System.debug('@@Brandfuel User response:- '+res.getBody());

            objRR = new RequestResponse_Log__c(); objRR.Response__c = String.valueof(res.getBody()); objRR.Request__c = String.valueOf(req.getBody()); objRR.Status_Code__c = res.getStatusCode()+''; objRR.Message_Type__c = res.getStatus();
            objRR.API_URL__c = req.getEndpoint(); objRR.Class_Name__c = 'BrandFuelBatch'; objRR.Method_Name__c = 'checkBFCouponNCreateUpdate'; objRR.Order__c = objOrder.Id; lstRR.add(objRR);

            if(res.getStatusCode() == 200){ BFCouponResponse objRes4 = (BFCouponResponse)JSON.deserialize(String.valueOf(res.getBody()), BFCouponResponse.class); Brandfuel_coupon__c objBFCouponSF = new Brandfuel_coupon__c(); 
                objBFCouponSF.Name = objOrder.PriceBook2.Name; objBFCouponSF.Contact__c = contactId; objBFCouponSF.Price_Book__c = objOrder.PriceBook2Id; objBFCouponSF.Coupon_Id__c = objRes4.coupons[0].dstId; objRes.objNewBFCouponSF = objBFCouponSF;
            }
        }
        objRes.lstRR = lstRR;
        return objRes;
    }

    public class BFUserResponse {
        List<BFUser> users;
        List<RequestResponse_Log__c> lstRR;
    }

    public class BFUser {
        String dstId;
        String dstFirstName;
        String dstEmailAddress;
        String dstActive;
        String dstKey;
    }

    public class BFCouponResponse {
        List<BFCoupon> coupons;
        List<RequestResponse_Log__c> lstRR;
        Brandfuel_coupon__c objNewBFCouponSF;
    }

    public class BFCoupon {
        String dstId;
        String dstLabel;
        String dstExpiration;
        String dstEmailAddress;
        String dstAmount;
    }
}
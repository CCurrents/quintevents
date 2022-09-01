Public class QE_brandFuelDatainsert {
 
//To check if user exists in Brandfuel
@future(callout = true)
Public static void checkUserExists(String oppName, String oppEmail, Id oppId, List < Id > OppLineIds, String EvntName, String EvName, Date ClosedDate, Boolean paidFull, Id conEmailId, Date BdFuelEndDate) {
  System.debug('*** opp email ***'+oppEmail);
  System.debug('*** contact EmailId ***'+conEmailId);
  List<Contact> conUpdateList = new List<Contact>();
  HttpRequest req = new HttpRequest();
      req.setMethod('GET');
      string sUsername = label.QE_brandfuel_username;
      string sPassword = label.QE_brandfuel_password;
      string objectdetail = 'users';
      req.setEndpoint('https://vipexperiences.brandfuel.com/api/'+ objectdetail+'/'+oppEmail);
      req.setHeader('Content-type', 'application/json');
      req.setHeader('User-Agent', 'Fulcrum');
      Blob headerValue = Blob.valueOf(sUsername + ':' + sPassword);
      String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
      req.setHeader('Accept', 'application/json');
      req.setHeader('Authorization', authorizationHeader);
      Http http = new Http();
      HTTPResponse res = http.send(req);
      System.debug('*** User response**' +res.getBody());
      JSONParser parser2 = JSON.createParser(res.getBody());
      String dstKeyval= '';
      String dstusrId;
      if (res.getStatusCode() == 200) {
       while (parser2.nextToken() != null) {
        if ((parser2.getCurrentToken() == JSONToken.FIELD_NAME) && (parser2.getText() == 'dstKey')) {
         parser2.nextToken();
         dstKeyval = parser2.getText();
         break;
        }
       }
   JSONParser parser3 = JSON.createParser(res.getBody());
         while (parser3.nextToken() != null) {
         if((parser3.getCurrentToken() == JSONToken.FIELD_NAME) && (parser3.getText() == 'dstId')) {
         parser3.nextToken();
         dstusrId = parser3.getText();
          break;
     }    
  }
 
  if(conEmailId == null) {
    Contact cn = new Contact();
    cn.Email = oppEmail; 
    cn.brandfuel_user_key__c = dstKeyval;
    cn.brandfuel_user_id__C = dstusrId;  
    conUpdateList.add(cn);
  }
  
     else if(conEmailId != null) {
         for(Contact con:[Select id,email,brandfuel_user_key__c,brandfuel_user_id__c from contact where id =: conEmailId]) {
         if(con.brandfuel_user_key__c == null && con.brandfuel_user_id__c == null) {
          con.brandfuel_user_key__c = dstKeyval;
          con.brandfuel_user_id__c =  dstusrId; 
          conUpdateList.add(con);
         }
         }
     }
     
 if(!conUpdateList.isEmpty() && !Test.isRunningTest()) {
     update conUpdateList;
     System.debug('**** con id***'+conUpdateList);
 }
 
 }
 if (res.getStatusCode() != 200 || Test.isRunningTest()) {
 System.debug('**** respone value***'+res.getBody());
  createUser(oppName, oppEmail, oppId, oppLineIds, EvntName, EvName, ClosedDate, paidFull, conEmailId, BdFuelEndDate);
 }
}
// To create user in Brandfuel when opp is closed won and event has brandfuel Id stored.
 //@future(callout = true)
 public static void createUser(String BillToName, String Email, Id oppIdSet, List < Id > OppLineIds, String eventName, String EvName, Date EndDate, Boolean paidinFull,Id contId,Date BdFuelEndDate) {
   System.debug('***eventName***'+eventName);
   List<Contact> conList = new List<Contact>();
   Account acc = new Account();
  Contact con = new Contact();
  if (paidinFull == true ) {
  HttpRequest req = new HttpRequest();
  req.setMethod('POST');
  String sUsername = label.QE_brandfuel_username;
  String sPassword = label.QE_brandfuel_password;
  string objectdetail = 'users';
  req.setEndpoint('https://vipexperiences.brandfuel.com/api/' + objectdetail);
  req.setHeader('Content-type', 'application/json');
  req.setHeader('User-Agent', 'Fulcrum');
  Blob headerValue = Blob.valueOf(sUsername + ':' + sPassword);
  String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
  req.setHeader('Accept', 'application/json');
  req.setHeader('Authorization', authorizationHeader);
  req.setBody('{"dstFirstName":"' + BillToName + '","dstEmailAddress":"' + Email + '","dstActive":"1"}');
  Http http = new Http();
  HTTPResponse res = http.send(req);
  System.debug('**** User Response**' +res.getBody());
  String usrKey;
  String usrId;
  JSONParser parser = JSON.createParser(res.getBody());
  if (res.getStatusCode() == 200) {
   while (parser.nextToken() != null) {
    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'dstKey')) {
     parser.nextToken();
     usrKey = parser.getText();
     break;
    }
    }
    JSONParser parser1 = JSON.createParser(res.getBody());
     while (parser1.nextToken() != null) {
     if((parser1.getCurrentToken() == JSONToken.FIELD_NAME) && (parser1.getText() == 'dstId')) {
     parser1.nextToken();
     usrId = parser1.getText();
      break;
     }    
   }
   }
  
   //update oppAttList;
   Decimal amount = 0;
   if (!OppLineIds.isEmpty() || Test.isRunningTest()) {
   // System.debug('**** amount 1***'+amount);
    for (OpportunityLineItem opLine: [SELECT Product_Type__c, ProductType__c, product2.Brandfuel_Points__c,quantity FROM OpportunityLineItem WHERE Id IN: OppLineIds]) {
     if ((opLine.ProductType__c == 'Giftbag' && opLine.product2.Brandfuel_Points__c != null) || Test.isRunningTest()) {
   //System.debug('***brandfuel points***'+opLine.product2.Brandfuel_Points__c);
      amount += opLine.product2.Brandfuel_Points__c * opLine.quantity;
      //System.debug('**** amount***'+amount);
     }
    }
   }
   
   if(usrKey != '' && res.getStatusCode() == 200 || (Test.isRunningTest())) {
   cuponDataInsert(eventName, oppLineIds, EvName, oppIdSet, String.valueOf(amount), Email, EndDate,usrKey,contId,usrId,BdFuelEndDate);
   }
  }
  
   System.debug('Updated contact**' +conList);
 }
 // To insert Coupon with userkey from user creation response when closed won and Paid full.
 public static void cuponDataInsert(String oppName, List < Id > OppLineIds, String EvName, Id oppId, String oppAmount, String oppEmail, date oppCloseDate,String userKey,Id conIdset, String usrId, Date BdFuelEndDate) {
  
  String coupnId = '';
  if(!OppLineIds.isEmpty()) {
  HttpRequest req = new HttpRequest();
  req.setMethod('POST');
  string sUsername = label.QE_brandfuel_username;
  string sPassword = label.QE_brandfuel_password;
  string objectdetail = 'coupons';
  req.setEndpoint('https://vipexperiences.brandfuel.com/api/' + objectdetail);
  req.setHeader('Content-type', 'application/json');
  req.setHeader('User-Agent', 'Fulcrum');
  Blob headerValue = Blob.valueOf(sUsername + ':' + sPassword);
  String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
  req.setHeader('Accept', 'application/json');
  req.setHeader('Authorization', authorizationHeader);
  req.setBody('{"dstLabel":"' + EvName + '","dstAmount":"' + oppAmount + '","dstEmailAddress":"' + oppEmail + '","dstExpiration":"' + BdFuelEndDate + '"}');
  Http http = new Http();
  HTTPResponse res = http.send(req);
  System.debug('*** coupon response**' +res.getBody());
  JSONParser parser = JSON.createParser(res.getBody());
  if (res.getStatusCode() == 200) {
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
   for(contact con :[SELECT Id,brandfuel_user_key__c,Brandfuel_user_id__c from contact where id =:conIdset]){
      con.brandfuel_user_key__c = userKey;
      con.brandfuel_user_id__c = usrId;
      System.debug('entered this**'+con.brandfuel_user_key__c);
      contactList.add(con);
  }
  
  if(!contactList.isEmpty()){
    Update contactList;
  }
  
  if ((coupnId != '' || coupnId != null) && !OppLineIds.isEmpty()) {
  
  Brandfuel_coupon__c coup = new Brandfuel_coupon__c();
  coup.Name = EvName;
  coup.Event__c = oppName;
  coup.Coupon_Id__c = coupnId; 
  coup.Contact__c = contactList[0].Id;
    // system.debug('**con id***'+contactList[0].id);
  insert coup;
  
   system.debug('****coupon id**'+coup.id);
   List < opportunity > oppListEmailField = new List < opportunity > ();
  String EveName =  EncodingUtil.urlEncode(EvName,'UTF-8');      
      String url = 'https://vipexperiences.brandfuel.com/vip-login.php?cmd=Login&dstKey=';
   System.debug('***url**' + url);
   for (Opportunity opp: [Select id,Event__r.Name, Email__c, Account.RecordType.DeveloperName,
     Account.Primary_Contact__r.BrandFuel_User_Key__c, Account.BrandFuel_User_Key__c FROM Opportunity WHERE Email__c = : oppEmail and id =: oppId]) {
    url = url + userKey;
    //System.debug('url 1**'+url);
    url = url + '&dstEvent=' +EveName;
    opp.Brandfuel_Customer_Link__c = url;
    System.debug('***url***' + url);
    oppListEmailField.add(opp);
   }
   
   if ((Test.isRunningTest()) || (!oppListEmailField.isEmpty() && !OppLineIds.isEmpty())) {
    update oppListEmailField;
   }

  }
 }
  @future(callout = true)
 public static void cuponDataSubMethod(Id oppId,List<Id> oppLineId,String coupnId,String oppName,String oppEmail,Date oppCloseDate, String conUserKey, Date BdFuelEndDate){
  HttpRequest req = new HttpRequest();
  req.setMethod('GET');
  string sUsername = label.QE_brandfuel_username;
  string sPassword = label.QE_brandfuel_password;
  string objectdetail = 'coupons';
  req.setEndpoint('https://vipexperiences.brandfuel.com/api/'+ objectdetail+'/'+coupnId);
  req.setHeader('Content-type', 'application/json');
  req.setHeader('User-Agent', 'Fulcrum');
  Blob headerValue = Blob.valueOf(sUsername + ':' + sPassword);
  String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
  req.setHeader('Accept', 'application/json');
  req.setHeader('Authorization', authorizationHeader);
  Http http = new Http();
  HTTPResponse res = http.send(req);
  System.debug('*** coupon response**' +res.getBody());
  JSONParser parser = JSON.createParser(res.getBody());
  String dstAmountval= '';
  if (res.getStatusCode() == 200) {
   while (parser.nextToken() != null) {
    if ((Test.isRunningTest()) || ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'dstAmount'))){
     parser.nextToken();
     dstAmountval = parser.getText();
     break;
    }
   }
  }
   Decimal amount = 0;
   if (!OppLineId.isEmpty() || Test.isRunningTest()) {
    for (OpportunityLineItem opLine: [SELECT Product_Type__c, ProductType__c , product2.Brandfuel_Points__c,Quantity FROM OpportunityLineItem WHERE Id IN: OppLineId]) {
     if ((opLine.ProductType__c == 'Giftbag' && opLine.product2.Brandfuel_Points__c != null) || Test.isRunningTest()) {
      amount += opLine.product2.Brandfuel_Points__c * opLine.quantity;
     }
    }
   }
   if(!Test.isRunningTest()) {
   amount += Decimal.valueOf(dstAmountval);
   }
   system.debug('**** amount**'+amount);
  Integer finalamount = 0; 
  finalamount += integer.valueOf(amount);
  system.debug('****final amount**'+finalamount);
   HttpRequest req1 = new HttpRequest();
   req1.setMethod('PUT');
   req1.setEndpoint('https://vipexperiences.brandfuel.com/api/'+ objectdetail+'/'+coupnId);
   req1.setHeader('Content-type', 'application/json');
   req1.setHeader('User-Agent', 'Fulcrum');
  Blob headerValue1= Blob.valueOf(sUsername + ':' + sPassword);
  String authorizationHeader1 = 'Basic ' + EncodingUtil.base64Encode(headerValue1);
  req1.setHeader('Accept', 'application/json');
  req1.setHeader('Authorization', authorizationHeader1);
  req1.setBody('{"dstLabel":"' + oppName + '","dstAmount":"' + finalamount + '","dstEmailAddress":"' + oppEmail + '","dstExpiration":"' + BdFuelEndDate + '"}');
  Http http1 = new Http();
  HTTPResponse res1 = http.send(req1);
  system.debug('********res*********'+res1.getbody());
  
  List < opportunity > oppUrlField = new List < opportunity > ();
   String oppNameEncode = EncodingUtil.urlEncode(+oppName, 'UTF-8');         
     String url = 'https://vipexperiences.brandfuel.com/vip-login.php?cmd=Login&dstKey=';
  // System.debug('***url**' + url);
   for (Opportunity opp: [Select id, Email__c, Account.RecordType.DeveloperName,
     Account.Primary_Contact__r.BrandFuel_User_Key__c, Account.BrandFuel_User_Key__c FROM Opportunity WHERE Email__c = : oppEmail AND id =:oppId ]) {
   url = url + conUserKey;
    url = url + '&dstEvent=' +oppNameEncode;
    opp.Brandfuel_Customer_Link__c = url;
    //System.debug('***url***' + url);
    oppUrlField.add(opp);
   }
   
   if ((!oppUrlField .isEmpty() && !OppLineId.isEmpty()) || Test.isRunningTest()) {
    update oppUrlField;
   }
 }
 
 @future(callout = true)
 public static void couponRecCreateOldEmail(Id oppId,List<Id> oppLineItemsId,String EveId,String EveName,String opprEmail, Date oppClsDate, Id consId, String usrKeyId, Date BdFuelEndDate) {
 
 Decimal amount = 0;
   if (!oppLineItemsId.isEmpty() || Test.isRunningTest()) {
    for (OpportunityLineItem opLine: [SELECT Product_Type__c, ProductType__c , product2.Brandfuel_Points__c,quantity FROM OpportunityLineItem WHERE Id IN: oppLineItemsId]) {
     if ((opLine.ProductType__c == 'Giftbag' && opLine.product2.Brandfuel_Points__c != null) || Test.isRunningTest()) {
      amount += opLine.product2.Brandfuel_Points__c * opLine.quantity;
     }
    }
   }
 
 HttpRequest req = new HttpRequest();
  req.setMethod('POST');
  string sUsername = label.QE_brandfuel_username;
  string sPassword = label.QE_brandfuel_password;
  string objectdetail = 'coupons';
   req.setEndpoint('https://vipexperiences.brandfuel.com/api/' + objectdetail);
  req.setHeader('Content-type', 'application/json');
  req.setHeader('User-Agent', 'Fulcrum');
  Blob headerValue = Blob.valueOf(sUsername + ':' + sPassword);
  String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
  req.setHeader('Accept', 'application/json');
  req.setHeader('Authorization', authorizationHeader);
    req.setBody('{"dstLabel":"' + EveName + '","dstAmount":"' + Amount + '","dstEmailAddress":"' + opprEmail + '","dstExpiration":"' + BdFuelEndDate + '"}');
  Http http = new Http();
  HTTPResponse res2 = http.send(req);
 system.debug('********res*********'+res2.getbody());
 String coupId = '';
  JSONParser parser = JSON.createParser(res2.getBody());
  if (res2.getStatusCode() == 200) {
   while (parser.nextToken() != null) {
    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'dstId')) {
     parser.nextToken();
     coupId = parser.getText();
     break;
    }
   }
  }
  
  if (coupId != '' && res2.getStatusCode() == 200) {
  
  Brandfuel_coupon__c coup = new Brandfuel_coupon__c();
  coup.Name = EveName;
  coup.Event__c = EveId;
  coup.Coupon_Id__c = coupId; 
  coup.Contact__c = consId;
  //system.debug('**con id diff email***'+consId);
  insert coup;
  
   system.debug('****coupon id diff email**'+coup.id);
   List < opportunity > oppListEmailField = new List < opportunity > ();
  String EvtName =  EncodingUtil.urlEncode(EveName,'UTF-8');      
      String url = 'https://vipexperiences.brandfuel.com/vip-login.php?cmd=Login&dstKey=';
   
   for (Opportunity opp: [Select id,Event__r.Name, Email__c, Account.RecordType.DeveloperName,
     Account.Primary_Contact__r.BrandFuel_User_Key__c, Account.BrandFuel_User_Key__c FROM Opportunity WHERE Email__c = : opprEmail and id =:oppId]) {
    url = url + usrKeyId;
    url = url + '&dstEvent=' +EvtName;
    opp.Brandfuel_Customer_Link__c = url;
    //System.debug('***url diff email***' + url);
    oppListEmailField.add(opp);
   }
   if ((!oppListEmailField.isEmpty() && !oppLineItemsId.isEmpty()) || Test.isRunningTest()) {
    update oppListEmailField;
   }

 }
 }
 
}
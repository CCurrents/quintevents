/**
 * @File Name          : H4HCreateMemberWithPointsBatch.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/8/2020, 3:53:27 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/26/2020   jagrawal@addonblue.com     Initial Version
**/
global class H4HCreateMemberWithPointsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
   public string stringIgnoreEmails = '';
   global Database.QueryLocator start(Database.BatchableContext BC){
        stringIgnoreEmails = '('+ Label.IgnoreOppInH4H + Label.IgnoreOppInH4H1 + ')';
        String query = 'SELECT Id,Account.Name,Amount,Email__c,Event__c,ship_to_name__c FROM Opportunity ';
        if(!Test.isRunningTest()) {
            query += 'where Ship_To_Name__c = null and Email__c != null and Event__r.name like \'%formula%\' and stagename = \'Closed Won\' and Email__c not in'+ stringIgnoreEmails;
        } else {
            query += 'limit 1';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        Decimal memberPoints = 0.0;
        String TokenId = '';
        if(String.isblank(TokenId)) {
            TokenId = getH4HTokenId();
        }
        Set<String> emailOpps = new Set<String>();
        for(Opportunity objOpp: scope) {
            emailOpps.add(objOpp.Email__c);
        }
        stringIgnoreEmails = Label.IgnoreOppInH4H + Label.IgnoreOppInH4H1;
        list<string> allEmailIgnore = stringIgnoreEmails.split(',');
        Map<String,List<Opportunity>> mapOppWithEmail = new Map<String,List<Opportunity>>();
        Map<String,Decimal> mapOppPoints = new Map<String,Decimal>();
        for(Opportunity objOp: [Select Account.Name,id,Event__r.name,CreatedDate,Amount,Grand_Total__c,Email__c,Event__c,ship_to_name__c FROM Opportunity where Ship_To_Name__c = null and Email__c in: emailOpps
                         and Event__r.name like '%formula%' and stagename = 'Closed Won' and Email__c not in: allEmailIgnore]) {
            
            if(objOp.Event__r.name != null && !objOp.Event__r.name.toLowerCase().contains('cotae')) { 
                Decimal amountFinal = 0;
                Date createDateOpp = date.newinstance(objOp.CreatedDate.year(), objOp.CreatedDate.month(), objOp.CreatedDate.day());
                date meandate = Date.valueOf('2018-02-07');
                if(createDateOpp > meandate) {
                    amountFinal = objOp.Amount;
                } else {
                    amountFinal = objOp.Grand_Total__c;
                }                      
                if(amountFinal > 0) {
                    if(!mapOppWithEmail.containsKey(objOp.Email__c)) {
                        mapOppWithEmail.put(objOp.Email__c, new List<Opportunity> {objOp});
                        mapOppPoints.put(objOp.Email__c,((amountFinal * 10)/100));
                    }
                    else {
                        mapOppWithEmail.get(objOp.Email__c).add(objOp);
                        mapOppPoints.put(objOp.Email__c,(mapOppPoints.get(objOp.Email__c) + ((amountFinal * 10)/100)));
                    }
                }
            }
        }
        if(!mapOppWithEmail.isEmpty()) {
            for(String emailOpp: mapOppWithEmail.keySet()) {
                createRequestToH4H(mapOppWithEmail.get(emailOpp)[0], mapOppPoints.get(emailOpp),TokenId);
            }
        }
        
    }   
    
    global void finish(Database.BatchableContext BC){ }
    public static String strResponse;
    public static string getH4HTokenId(){
        String tokenId = '';
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String usernames = label.H4H_username;
        String passwords = label.H4H_password;
        string siteIds = label.H4H_Site_Id;
        string tokens = 'ARNUSER-aodom@quintevents.com';
        //Use Named Credentials for storing the username and password
        req.setEndpoint('https://api.travsrv.com/MemberAPI.aspx?username='+ usernames +'&password=' + passwords +'&siteid='+siteIds +'&token='+tokens);     
        System.debug('***re body1**'+req.getendpoint());
        Http http = new Http();
        HTTPResponse res = new HttpResponse();
        if(!Test.isRunningTest()) {
            res = http.send(req);
        } else {
            res.setStatusCode(200);
            res.setBody(strResponse);
            tokenId = 'abc';
        }
        
        System.debug('**response**' +res);
        System.debug('****response body*****'+res.getBody());
          JSONParser parser = JSON.createParser(res.getBody());
              if (res.getStatusCode() == 200) {
               while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'CurrentToken')) {
                     parser.nextToken();
                     tokenId = parser.getText();
                     System.debug('***tokenvalue**'+TokenId);
                     break;
                }
            }
        }
        return tokenId;
    }
    
    public static void createRequestToH4H(Opportunity oppt, decimal memberpoints,String TokenId){
        string siteIds = label.H4H_Site_Id;
        String shipToName;
        if(oppt.ship_to_name__c == null) {
            shipToName = oppt.Account.Name;
        } else {
            shipToName = oppt.ship_to_name__c;
        }
        
        String lastNameNew;
        String firstNameNew;
        if(shipToName.contains(' ')) {
            System.debug('***ship to name***'+shipToName);
            Integer shipToNamelength = shipToName.length();
            System.debug('***name length***'+shipToNamelength);
            Integer lastValue = shipToName.lastIndexOf(' ');
            System.debug('**last index***' +lastValue);
            Integer firstValue = shipToName.indexOf(' ');
            System.debug('***index first value**'+firstValue);
            
            lastNameNew = shipToName.substring(lastValue+1,shipToNamelength);
            firstNameNew = shipToName.substring(0,firstValue);
        } else {
            firstNameNew = shipToName;
            lastNameNew = shipToName;
        }
        JSONGenerator gen = JSON.createGenerator(true);    
        gen.writeStartObject(); 
        if(memberpoints > 0){
            decimal points = memberpoints;     
            gen.writeNumberField('points',points);
        }
        
        gen.writeFieldName('Names');
        gen.writeStartArray(); 
        gen.writeStartObject();   
        gen.writeStringField('ReferralId', oppt.email__c);
        gen.writeStringField('FirstName',firstNameNew);
        gen.writeStringField('LastName',lastNameNew);
        gen.writeStringField('Email',oppt.email__c);
        gen.writeEndObject();    
        String jsonS = gen.getAsString();
        System.debug('jsonMaterials'+jsonS);
        HttpRequest req1 = new HttpRequest();
        req1.setMethod('POST');
        req1.setEndpoint('https://api.travsrv.com/MemberAPI.aspx');
        req1.setHeader('Cache-Control','no-cache');           
        req1.setHeader('Content-type','application/x-www-form-urlencoded');
        req1.setBody('siteid='+siteIds+'&token='+TokenId +'&memberData='+jsonS);
        System.debug('***req body**'+req1.getbody());
        Http h = new Http();
        HTTPResponse resp = new HttpResponse();
        if(!Test.isRunningTest()) {
            resp = h.send(req1);
        } else {
            resp.setStatusCode(200);
            resp.setBody(strResponse);
        }
        System.debug('***response debug***'+resp.getBody());
        JSONParser parser1 = JSON.createParser(resp.getBody());
    
        String memberStatus;
        if (resp.getStatusCode() == 200) {
            while (parser1.nextToken() != null) {
                if ((parser1.getCurrentToken() == JSONToken.FIELD_NAME) && (parser1.getText() == 'DebugData')) {
                     parser1.nextToken();
                     memberStatus = parser1.getText();
                     System.debug('***memberStatus*'+memberStatus);
                     break;
                }
                
                 
            }
    
            JSONParser parser2 = JSON.createParser(resp.getBody());
            Decimal memberPointsFromRes = 0;
            if(memberStatus != null && resp.getStatusCode() == 200) { 
                Boolean result= memberStatus.contains('Successful Existing Member');
                while (parser2.nextToken() != null) {
                   if (result && (parser2.getCurrentToken() == JSONToken.FIELD_NAME) && parser2.getText() == 'Points') {
                       parser2.nextToken();
                       memberPointsFromRes += parser2.getIntegerValue();
                       break;
                   }
                }
                system.debug('memberPointsFromRes=='+memberPointsFromRes);
            }
        }
    }
}
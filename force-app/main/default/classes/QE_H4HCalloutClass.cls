public class QE_H4HCalloutClass{

    @future(callout = true)
    public static void getTokenSiteAdmin(Id oppIds, boolean isClosedWonalone){
        Decimal memberPoints = 0.0;
        String TokenId = '';
        TokenId = getH4HTokenId();

        if(!isClosedWonalone){
            List<Opportunity> oppList =new List<Opportunity>();
            for(opportunity oppt : [Select id,email__c,phone__c,Reward_Points_Pending__c,billing_street__c,ship_to_name__c,StageName,paid_in_full__c from opportunity where id =:oppIds]) {
                createRequestToH4H(oppt,false,0.0, TokenId);
            }
        }else{
            List<Opportunity> oppList =new List<Opportunity>();
            Decimal H4HasRes = 0.0;
            List<Opportunity> oppToUpdate = [Select id,email__c,phone__c,billing_street__c,Reward_Points_Pending__c,ship_to_name__c,StageName,paid_in_full__c, (select Id, unitPrice FROM OpportunityLineItems Where producttype__c = 'Reward Discount' AND package__c = null)from opportunity where id =:oppIds];
            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
            Decimal curOppPoints = 0.0;
            for(opportunity oppt : oppToUpdate){
                H4HasRes = createRequestToH4HForClosedWon(oppt, tokenId);
                Decimal discountAmount = 0.0;

                for(OpportunityLineItem oli: oppt.OpportunityLineItems){
                    System.debug('*** disc unit price***' +oli.unitPrice);
                    discountAmount = discountAmount - oli.UnitPrice;
                }
                if(H4HasRes >= discountAmount ){
                    for(OpportunityLineItem oli: oppt.OpportunityLineItems){
                        oli.Reward_Points_Earned__c  = 0 - discountAmount;
                        oliList.add(oli);
                        if(oli.opportunity.online_order__C == false) {
                            curOppPoints = oppt.Reward_Points_Pending__c + (0 - discountAmount);
                        } else if(oli.opportunity.online_order__C == false) {
                            curOppPoints = oppt.Reward_Points_Pending__c;
                        }
                    }
                }else{
                    for(OpportunityLineItem oli: oppt.OpportunityLineItems){
                        oli.UnitPrice  = 0.0;
                        oliList.add(oli);
                        curOppPoints = 0.0;
                    }
                }
            }
            /*if(!oppToUpdate.isEmpty()){
                update oppToUpdate;
            }*/

            if(oppToUpdate[0].paid_in_full__c == true || Test.isRunningTest()){
                createRequestToH4HFORClosedWonAndPaidFull(oppToUpdate[0],H4HasRes,curOppPoints,TokenId);
            }
            if(!oliList.isEmpty()){
                update oliList;
            }
        }
    }

    public static string getH4HTokenId(){
        String tokenId = '';
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String usernames = label.H4H_username;
        String passwords = label.H4H_password;
        string siteIds = label.H4H_Site_Id;
        string tokens = 'ARNUSER-aodom@quintevents.com';
        req.setEndpoint('https://api.travsrv.com/MemberAPI.aspx?username='+ usernames +'&password=' + passwords +'&siteid='+siteIds +'&token='+tokens);
        System.debug('***re body1**'+req.getendpoint());
        Http http = new Http();
        HTTPResponse res = http.send(req);
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

    Public static void createRequestToH4H(Opportunity oppt, Boolean isWritePoints, decimal memberpoints,String TokenId){
        String firstNameNew ='';
        String lastNameNew ='';
        String usernames = label.H4H_username;
        String passwords = label.H4H_password;
        string siteIds =label.H4H_Site_Id;
        Decimal memberPointsFromRes = 0.0;
        try{
            String shipToName = oppt.ship_to_name__c;
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
            firstNameNew = oppt.ship_to_name__c;
            lastNameNew = oppt.ship_to_name__c;
        }
        Integer totalH4HPoints = 0;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        if(isWritePoints && oppt.Reward_Points_Pending__c != null){
            List<opportunity> lstoppt = [Select id,Reward_Points_Pending__c from opportunity where id=:oppt.id];
            decimal points = memberpoints + lstoppt[0].Reward_Points_Pending__c;
            if(points > 0) {
                gen.writeNumberField('points', Integer.valueOf(points));
                System.debug('**** final points***'+points);
            } else {
                gen.writeNumberField('points', Integer.valueOf(memberpoints));
                System.debug('**** tot points***' +memberpoints);
                List<OpportunityLineItem> oliLst = [select Id, unitPrice FROM OpportunityLineItem Where opportunityId =: oppt.Id AND producttype__c = 'Reward Discount' AND package__c = null];
                for(OpportunityLineItem oli : oliLst){
                    oli.unitPrice = 0.0;
                }
                Database.Update(oliLst, false);
            }
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
        HTTPResponse resp = h.send(req1);
        System.debug('***response debug***'+resp.getBody());
        QE_H4HRecursive4Callout.inFutureContext = true;
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
            createRequestToH4H(oppt, true, memberPointsFromRes,TokenId);
        }
    }

    public static void createRequestToH4HFORClosedWonAndPaidFull(Opportunity oppt, decimal memberpoints, decimal currentOppPoints, String TokenId){
        String firstNameNew ='';
        String lastNameNew ='';
        String usernames = label.H4H_username;
        String passwords = label.H4H_password;
        string siteIds =label.H4H_Site_Id;
        Decimal memberPointsFromRes = 0.0;
        try{
            String shipToName = oppt.ship_to_name__c;
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
            firstNameNew = oppt.ship_to_name__c;
            lastNameNew = oppt.ship_to_name__c;
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
            List<OpportunityLineItem> oliLst = [select Id, unitPrice FROM OpportunityLineItem Where opportunityId =: oppt.Id AND producttype__c = 'Reward Discount' AND package__c = null];
            for(OpportunityLineItem oli:oliLst){
                oli.unitPrice = 0.0;
            }
            Database.Update(oliLst, false);
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
        HTTPResponse resp = h.send(req1);
        System.debug('***response debug***'+resp.getBody());
        QE_H4HRecursive4Callout.inFutureContext = true;
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

    public static Decimal createRequestToH4HForClosedWon(Opportunity oppt,String TokenId){
        String firstNameNew ='';
        String lastNameNew ='';
        String usernames = label.H4H_username;
        String passwords = label.H4H_password;
        string siteIds =label.H4H_Site_Id;
        Decimal memberPointsFromRes = 0.0;
        try{
            String shipToName = oppt.ship_to_name__c;
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
            firstNameNew = oppt.ship_to_name__c;
            lastNameNew = oppt.ship_to_name__c;
        }
        Integer totalH4HPoints = 0;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
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
        HTTPResponse resp = h.send(req1);
        System.debug('***response debug***'+resp.getBody());
        QE_H4HRecursive4Callout.inFutureContext = true;
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
global class QE_H4HCreateRewardPointCall implements Database.Batchable<sObject>, Database.AllowsCallouts{
    Public String queryStr;
    
    Public QE_H4HCreateRewardPointCall(String qry) {
        queryStr = qry;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //queryStr = 'SELECT Id,Account.Name,Amount,Email__c,Event__c,ship_to_name__c FROM Opportunity';
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        String tokenId =  Test.isRunningTest() ? 'test' : QE_H4HCalloutClass.getH4HTokenId();
        List<H4H_Member_Reward__c> lstH4HMemberReward = new List<H4H_Member_Reward__c>();
        for(Opportunity oppt : scope) {
            
            String firstNameNew = '';
            String lastNameNew = '';       
            String usernames = label.H4H_username;
            String passwords = label.H4H_password;
            string siteIds = label.H4H_Site_Id;
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
            req1.setBody('siteid=' + siteIds + '&token=' + TokenId +'&memberData='+jsonS);
            System.debug('***req body**'+req1.getbody());
            Http h = new Http();
            
            String respBody;
            Integer stCode;
            if(!Test.isRunningTest()) {
                HTTPResponse resp = h.send(req1);
                respBody = resp.getBody();
                stCode = resp.getStatusCode();
            } else {
                respBody = '{"MemberId":1004186,"Rewards":0,"Points":480,"RedemptionMultiplier":1.0,"EarnMultiplier":1.0,"Names":[{"FirstName":"sc","LastName":"test005","BirthDate":null,"Email":"sdrt@test.com","Address1":null,"Address2":null,"City":null,"State":null,"Country":null,"Postal":null,"Longitude":null,"Latitude":null,"HomePhone":null,"Referral":null,"ReferralId":"sdrt@test.com","Password":null,"IsActive":true,"DeleteMember":false,"UpdateMemberUsername":false,"CreditCards":null,"FullName":"sc test005"}],"DebugData":" Successful Existing Member RT-40598-sdrt@test.com","Error":null,"CurrentToken":"X%2fSsVJs3U73FYiQ3pn4%2frrmC5INmun4wAJS8PIgydUoGKgi9H6nxtShP7txRHniFHRn007bSQPd0PH5M8p36uv6XHmaTQ%2fiYaOKTosFRug8p0dvGv4lPTA25SWmY6HWAZyW2rmzgYx8fDkG4nQ%2bNk%2b0bIsy9MbSkKYNhCU7yOlYqvofrZSVFr3o1Mr%2bTm3Zh%2fLE5fougAW8ceX00KnD8%2bFj83TWAKzCJEKO7Ol31MkiqXP1%2bqlcRf8GkTy1BRC9N6VtQN4OuHLwR5yirsuTRABjKw4YyL9%2fGvbbZfAPUt0Y8tTAAlbHFMvStfVflGfRW7t%2f9BcvnkSyWTpherbefBi8Boxf0UpfSf1aA0k3UH8wUUWjCYdWEkPnPgY6Uy3VyLCJIRx%2bZfvcHVrmUtr%2fOYxm23m5rg2IeonDwo8JHdMuzE2XqNYJWd5JvtdOY98T9cS3%2bsXtJtKM01KSYV6MO3%2fuBS11%2b5TuinHJKN%2fnHs3gNTHgRJDcMnCsVjJsciy1jtQ2ITmr8%2bpWhkHH4Y34mkXjMUXDRekfh%2fVMzYtP9c%2fanzIzFelN3JnN3ENeWuz8vCzZUdKXsmw6GxzjQzjQv9AIWUkruSDtFOCDpJWhVjb735Zo8zhFewMAckegN0CGo9K7oo3Vhzwpgcznyrf5Ym8ZzZTI5YapoznkJdqZmvM2xcHbreuWNCX%2bUKriwyVStkxGxKutz1fyDB12noJVn9cnc1yHQyJZmBFxGiEg8KJ5WiU8igqymZWpwWtPEKz7r","TransactionResponse":"true","MetaTag":null,"MemberUsername":"RT-40598-sdrt@test.com","MemberProvider":null,"IsArnProvider":true,"AdditionalInfo":null,"MemberType":"Wholesale"}';
                stCode = 200;
            }
            System.debug('***response debug***'+respBody);
            QE_H4HRecursive4Callout.inFutureContext = true;
            JSONParser parser1 = JSON.createParser(respBody);
            
            String memberStatus;
            String currentToken;
            if (stCode == 200) {
                while (parser1.nextToken() != null) {
                    if ((parser1.getCurrentToken() == JSONToken.FIELD_NAME) && (parser1.getText() == 'DebugData')) {
                        parser1.nextToken();
                        memberStatus = parser1.getText();
                        System.debug('***memberStatus*'+memberStatus);
                    }
                    if ((parser1.getCurrentToken() == JSONToken.FIELD_NAME) && (parser1.getText() == 'CurrentToken')) {
                        parser1.nextToken();
                        currentToken = parser1.getText();
                        System.debug('***memberStatus*'+memberStatus);
                        break;
                    }
                }
                
                JSONParser parser2 = JSON.createParser(respBody);
                
                if(memberStatus != null) { 
                    Boolean result= memberStatus.contains('Successful Existing Member');
                    while (parser2.nextToken() != null) {
                        if (result && (parser2.getCurrentToken() == JSONToken.FIELD_NAME) && parser2.getText() == 'Points') {
                            parser2.nextToken();
                            memberPointsFromRes += parser2.getIntegerValue();
                            
                            H4H_Member_Reward__c h4hReward = new H4H_Member_Reward__c(Opportunity__c = oppt.Id);
                            h4hReward.H4H_Member_Status__c = memberStatus;
                            h4hReward.Current_H4H_Member_Token__c = currentToken;
                            h4hReward.Reward_Points_in_H4H__c = memberPointsFromRes;
                            lstH4HMemberReward.add(h4hReward);
                            break;
                        }
                    }
                }
            }
        }
        if(lstH4HMemberReward.size() > 0) {
            insert lstH4HMemberReward;
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
}
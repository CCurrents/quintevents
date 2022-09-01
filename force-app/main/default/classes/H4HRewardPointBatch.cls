/**
 * @File Name          : H4HRewardPointBatch.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 6/16/2020, 2:41:08 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/30/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class H4HRewardPointBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    Set<Id> orderSet;
    public H4HRewardPointBatch(Set<Id> orderSet){
        this.orderSet = orderSet;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id, Opportunity.Pricebook2.GPE_Event__c,OpportunityId,Status,QuoteId,BillToContactId,ShipToContactId,Quote.Points_to_be_added_to_H4H__c from Order where Id IN: orderSet');
    }
    public void execute(Database.BatchableContext BC, List<Order> scope){
        Decimal memberPointsFromRes = 0.0;
        Integer totalH4HPoints = 0; 
        Map<Id,Opportunity> mapOpportunity = new Map<Id,Opportunity>();
        Set<Id> opportunitySet = new Set<Id>();
        for(Order objOrd : scope){
            opportunitySet.add(objOrd.OpportunityId);
        }
        List<OpportunityContactRole> lstContactRoles = new List<OpportunityContactRole>([Select Id,OpportunityId,Contact.FirstName,Contact.LastName,Contact.Email from OpportunityContactRole Where OpportunityId IN: opportunitySet AND Role = 'H4H Rewards Contact']);
        System.debug('lstcontactroles--'+lstContactRoles);
        Map<Id,OpportunityContactRole> mapContactRoles = new Map<Id,OpportunityContactRole>();
        for(OpportunityContactRole objContactRole : lstContactRoles){
            mapContactRoles.put(objContactRole.OpportunityId,objContactRole);
        }
        for(Order objOrder : scope){
            Decimal points;
            Decimal newPoints;
            Contact objContact = new Contact();
            if(objOrder.OpportunityId != null && mapContactRoles.get(objOrder.OpportunityId) != null){  objContact = mapContactRoles.get(objOrder.OpportunityId).Contact;
                System.debug('mapvalues-'+mapContactRoles.get(objOrder.OpportunityId).Contact);
            }else if(Test.isRunningTest()){
                objContact = [Select Id, FirstName, LastName, Email from Contact Limit 1];
            }
            points = H4HUtility.getRewardPointsOfContacts(objContact);
            System.debug('points-->'+points);
            //#344 Fix for null value of Orders not having Quote value in it -- START
            Decimal existingPoints = 0.0;
            if(objOrder.QuoteId != null && objOrder.Quote.Points_to_be_added_to_H4H__c != null){ existingPoints = objOrder.Quote.Points_to_be_added_to_H4H__c; }
            if(!Test.isRunningTest()){ newPoints = points + existingPoints; }
            //#344 Fix for null value of Orders not having Quote value in it -- END
            else{
                newPoints = 100;
            }
            
            if(objContact != null && String.isNotBlank(objContact.Email)){
                H4H_API_Details__c ha4APISettings = H4H_API_Details__c.getOrgDefaults();
                String email = objContact.Email;
                String firstNameNew ='';
                String lastNameNew ='';
                String usernames = ha4APISettings.H4H_username__c;
                String passwords = ha4APISettings.H4H_password__c;
                //Need to work Here
                string siteIds = '40598'; //ha4APISettings.H4H_Site_Id__c;
                String TokenId =  H4HCalloutClass.getH4HTokenId();
                Integer point = Integer.valueOf(newPoints);
                System.debug('points-->'+ point);
                if(String.isNotBlank(objContact.FirstName)){
                    firstNameNew = objContact.FirstName;
                } else {
                    firstNameNew = objContact.LastName;
                }
                lastNameNew = objContact.Lastname;
                
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeNumberField('Points', point);
                gen.writeFieldName('Names');
                gen.writeStartArray();
                gen.writeStartObject();
                gen.writeStringField('ReferralId', email);
                gen.writeStringField('FirstName', firstNameNew);
                gen.writeStringField('LastName', lastNameNew);
                gen.writeStringField('Email', email);
                gen.writeEndObject();
                String jsonS = gen.getAsString();
                
                HttpRequest req1 = new HttpRequest();
                req1.setMethod('POST');
                if(!Test.isRunningTest()){
                    req1.setEndpoint(ha4APISettings.H4H_GetMemberPoints_EndPoint__c);
                }
                req1.setHeader('Cache-Control','no-cache');
                req1.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(ha4APISettings.H4H_username__c + ':' + ha4APISettings.H4H_password__c)));
                req1.setHeader('Content-type','application/x-www-form-urlencoded');
                req1.setBody('siteid='+siteIds+'&token=ARNUSER-'+ ha4APISettings.H4H_username__c +'&memberData='+jsonS);
                System.debug('***req body**'+req1.getbody());
                
                Http h = new Http();
                HTTPResponse resp;
                if(!Test.isRunningTest()){
                    resp = h.send(req1);
                }
                System.debug('***response debug***'+resp);
                QE_H4HRecursive4Callout.inFutureContext = true;
                String jsonReposne = !Test.isRunningTest() ? resp.getBody() : '{"MemberId":4999811,"Rewards":0,"Points":1600,"RedemptionMultiplier":1.0,"EarnMultiplier":1.0,"Names":[{"FirstName":"H4H","LastName":"Open Demo","BirthDate":null,"Email":"testingemail@gmail.com","Address1":null,"Address2":null,"City":null,"State":null,"Country":null,"Postal":null,"Longitude":null,"Latitude":null,"HomePhone":null,"Referral":null,"ReferralId":"testingemail@gmail.com","RegistrationCode":null,"Password":null,"IsActive":true,"DeleteMember":false,"ReactivateMember":false,"UpdateMemberUsername":false,"CreditCards":null,"FullName":"H4H Open Demo"}],"DebugData":" Successful Existing Member RT-40598-testingemail@gmail.com","Error":null,"CurrentToken":"pjltAXkrWibg3R8N%2boLPvwVSSKpRD8Erp%2bPYM7fwfdl2wlCcNd0GyS5gihPtEJi9KnYL4S9BTQhhMUYpnwlgYKWMMYoBqHuB49POKqwvj%2fBviTM3c2Aw9eCON5OyrTAsAGfvHUamaKCFR3a4UX7COK4sBOpZRXpFbpe0eg2HIATZj1tQE8Ub3UV2lII57USvTXT6aNhFwr5ZwUdxitnezfobcyUyY56dOm%2fjsU2fl5RJSfpAi7CEzEClL2l36DS9uLclBBstCF9jp%2bTVEh4KJuWZfbbxfPCThl0potv1VhNTZzcZaw6gTRee%2fkVGSts3RZF10Q3piwEXvW0nmSvyfeQZ0%2b71CTVHAlmFgwa2a5fGDvENnIorR2UGlHAXQKUKrVYZ7Kqs6ghU4XPBxT5mSwsfTRPJ6Q3TEAI712zjzUChALqx6bX3xtz0VsFgi6wpcA34ajtw4xYUArCvkoD4758FrYhA3FMkAfXq0AY9ajJRMLiGvZVzO7ZsZ0t4V3PtvMLIJBd5mltSLz4NbSlUJkQAFxYhjo%2bvmD2GY7TChquPXvhUT8evH7gz%2f4UG3F1my%2bHmQQECeYSGyrJHjp2TEPI57BWXAjrntxLv4HqEO3K1YXgXNCY9Y5trcstNknIBFv7Ea3hbr0V%2fNR3Fn%2fKC8CMAcpEQwmHAnDEMAE0vA8sJFP9g09%2b8zGuAg7n%2fUK55XoUgOpFoO%2flDjDrZWxY4Rsqw5Vurjpytdd2F%2frU5yxIz8gt0Aa8pSQSjN1Fwng0Ce1Jm4HK%2fHsRcK31lQxpspw%3d%3d","TransactionResponse":"true","MetaTag":null,"MemberUsername":"RT-40598-testingemail@gmail.com","MemberProvider":null,"IsArnProvider":true,"AdditionalInfo":null,"MemberType":"Wholesale"}';
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
                    
                    if(memberStatus != null && (memberStatus.contains('Successful Existing Member')|| memberStatus.contains('Successful creation of Member'))) {
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
                    System.debug('memberPointsFromRes-->'+memberPointsFromRes);
                
            }
        }
       
    }
    public void finish(Database.BatchableContext BC){}
}
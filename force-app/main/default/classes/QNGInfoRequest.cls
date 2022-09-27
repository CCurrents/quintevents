/**
* @File Name          : QNGInfoRequest.cls
* @Description        : Creates Info Request record based on JSON sent from QNG side, and associates that InfoRequest record with Lead/Account. Also updates Info Request fields on Lead & Account
* @Author             : vaibhav.khopade@addonblue.com
* @Created            : 10-Mar-2022 for fix of issue 1176
**/

@RestResource(urlMapping='/qngInfoRequest/*')
global with sharing class QNGInfoRequest {
    public static Boolean isQNGStay = true;
    public static QNG_Info_Request__c infoRequest;
    public static string infoReqId = '';

    @HttpPost
    global static void create() {

        RequestResponse_Log__c objRequestResponse_Log = new RequestResponse_Log__c();
        try {
            RestRequest request = RestContext.request;
            RestContext.response.addHeader('Content-Type', 'application/json');

            String jsonString = request.requestBody.toString();
            //system.debug('jsonString received = ' + jsonString);
            objRequestResponse_Log.Request__c = jsonString;
            objRequestResponse_Log.Class_Name__c = 'QNGInfoRequest';

            /* InfoReq_JSON2APex objInfoReq = (InfoReq_JSON2APex) JSON.deserialize(jsonString, InfoReq_JSON2APex.class);
             system.debug('objInfoReq deserialized = ' + objInfoReq);
             InfoReq_JSON2APex.Request requestData = objInfoReq.request; */

            //system.debug('request data = ' + requestData);

            Map<String, Object> jsonParsed = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            //system.debug('JSON string parsed = ' + jsonParsed);
            QNG_Info_Request__c infoReq = new QNG_Info_Request__c();
            infoReq.Requestor_Email__c = (string) jsonParsed.get('email');
            infoReq.Site__c = string.valueOf(jsonParsed.get('site_id'));
            infoReq.Referrer__c = (string) jsonParsed.get('referrer');
            infoReq.Landing_Page__c = (string) jsonParsed.get('landing_page');
            infoReq.Submission_Date__c = (Date) system.today();

            infoReq.UTM_Source__c = (string) jsonParsed.get('utm_source');
            infoReq.UTM_Medium__c = (string) jsonParsed.get('utm_medium');
            infoReq.UTM_Campaign__c = (string) jsonParsed.get('utm_campaign');

            infoReq.SF_Agent_Id__c = (string) jsonParsed.get('sf_agent_id');
            infoReq.Contact_Site__c = (string) jsonParsed.get('domain_name');

            // add processing marketing_email_consent KVP
            infoReq.MarketingEmailConsent__c = (boolean) jsonParsed.get('marketing_email_consent');

            if (infoReq.SF_Agent_Id__c != '' && infoReq.SF_Agent_Id__c != null) {
                if (verifyIfUSerId(infoReq.SF_Agent_Id__c) == true) {
                    infoReq.OwnerId = infoReq.SF_Agent_Id__c;
                }
            }

            //system.debug('infoReq = ' + infoReq);
            //system.debug('requestor email = ' + infoReq.Requestor_Email__c);
            // JOSH LEQUIRE 9/20/22 - REMOVE, Can get Account in Contact Query
            Account requestorAcc = getAccByEmail(infoReq.Requestor_Email__c);
            if (requestorAcc != null)
                infoReq.Account__c = requestorAcc.Id;

            Contact requestorCon = getContactByEmail(infoReq.Requestor_Email__c);
            if (requestorCon != null) {
                infoReq.Contact__c = requestorCon.Id;
                objRequestResponse_Log.Contact__c = requestorCon.Id;
            }

            Lead requestorLead = getLeadByEmail(infoReq.Requestor_Email__c);
            if (requestorLead != null)
                infoReq.Lead__c = requestorLead.Id;

            if(infoReq.Contact__c == null && infoReq.Lead__c == null){
                Lead newLead = new Lead();
                newLead.RecordTypeId = CONSTANTS.LEAD_RECORDTYPE_STANDARD;
                newLead.FirstName = (string) jsonParsed.get('first_name');
                newLead.LastName = (string) jsonParsed.get('last_name');
                newLead.Email = infoReq.Requestor_Email__c;
                if(infoReq.MarketingEmailConsent__c == true){
                    newLead.Marketing_Email_Consent__c = 'Yes';
                }

                insert newLead;
                infoReq.Lead__c = newLead.Id;

            }

            insert infoReq;
            infoReqId = infoReq.id;
            if (infoReq.MarketingEmailConsent__c == true) {
                ConsentTransactionService.createConsentTransactionFromInfoRequest(infoReq, CONSTANTS.CONSENT_TRANSACTION_TYPE_OPTIN);
            }


            // savepoint sp1 = Database.setSavepoint();
            if (requestorAcc != null) {
                //infoReq.Account__c = requestorAcc.Id;
                objRequestResponse_Log.Account__c = requestorAcc.Id;
                updateAccUTMDetails(requestorAcc, infoReq);
            }

            if (requestorLead != null) {
                //infoReq.Lead__c = requestorLead.Id;
                updateLeadUTMDetails(requestorLead, infoReq);
            }

            String strResponseBody = '';
            strResponseBody = '{"status" : "Success", "Info-Request created successfully" : "' + infoReqId + '"}';
            RestContext.response.responseBody = Blob.valueOf(strResponseBody);
            objRequestResponse_Log.Status_Code__c = 'Success';
            objRequestResponse_Log.Info_Request__c = infoReqId;
            objRequestResponse_Log.Response__c = strResponseBody;

        } catch (Exception e) {
            system.debug('Exception ex: ' + e.getMessage() + '---' + e.getLineNumber());
            if (infoReqId != null && infoReqId != '') {
                objRequestResponse_Log.Info_Request__c = infoReqId;
            }
            objRequestResponse_Log.Response__c = 'Exception- (InfoRequest : ' + infoReqId + ') :- ' + e.getMessage() + '=\nLineNumber=>' + e.getLinenumber() + '\nStackTrace:-' + e.getStackTraceString();
            objRequestResponse_Log.Status_Code__c = 'Failed';
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{"status" : "failed", "Message" : "' + 'Exception- (InfoRequest : ' + infoReqId + ') :- ' + e.getMessage() + '"}');
            //Database.rollback(sp1);
        } finally {
            insert objRequestResponse_Log;
        }

    }

    private static Account getAccByEmail(string email) {
        List<Account> accounts = new List<Account>([select Id, name, PersonEmail, First_UTM_Source__c, Last_UTM_Source__c, First_UTM_Medium__c, Last_UTM_Medium__c, First_UTM_Campaign__c, Last_UTM_Campaign__c, First_Referrer__c, Last_Referrer__c, First_Landing_Page__c, Last_Landing_Page__c, First_Info_Request_Site__c, Last_Info_Request_Site__c from Account where PersonEmail = :email]);
        if (accounts.size() > 0) {
            return accounts[0];
        } else {
            return null;
        }
    }


    private static Contact getContactByEmail(string email) {
        List<Contact> contacts = new List<Contact> ([select Id, name, Email from Contact where Email = :email OR Secondary_Email__c = :email LIMIT 1]);
        //system.debug('contact email input = ' + email);
        //system.debug('contact size = ' + contacts.size());
        if (contacts.size() > 0) {
            return contacts[0];
        } else {
            return null;
        }
    }


    private static Lead getLeadByEmail(string email) {
        List<Lead> leads = new List<Lead>([select Id, name, Email, First_UTM_Source__c, Last_UTM_Source__c, First_UTM_Medium__c, Last_UTM_Medium__c, First_UTM_Campaign__c, Last_UTM_Campaign__c, First_Referrer__c, Last_Referrer__c, First_Landing_Page__c, Last_Landing_Page__c, First_Info_Request_Site__c, Last_Info_Request_Site__c from Lead where Email = :email OR Secondary_Email__c = :email LIMIT 1]);
        system.debug('lead email input = ' + email);
        //system.debug('lead size = ' + leads.size());
        //system.debug('*** lead queried = ' + leads[0]);
        if (leads.size() > 0) {
            return leads[0];
        } else {
            return null;
        }
    }

    private static boolean verifyIfUSerId(string SFAgentId) {
        List<User> SFUsers = new List<User> ([select Id, name from User where Id = :SFAgentId]);
        if (SFUsers.size() > 0) {
            return true;
        } else
                return false;
    }

    private static void updateAccUTMDetails(Account acc, QNG_Info_Request__c infoReq) {
        Account accToUpdate = new Account(Id = acc.Id);

        if (acc.First_UTM_Source__c == null || acc.First_UTM_Source__c == '')
            accToUpdate.First_UTM_Source__c = infoReq.UTM_Source__c;
        accToUpdate.Last_UTM_Source__c = infoReq.UTM_Source__c;


        if (acc.First_UTM_Medium__c == null || acc.First_UTM_Medium__c == '')
            accToUpdate.First_UTM_Medium__c = infoReq.UTM_Medium__c;
        accToUpdate.Last_UTM_Medium__c = infoReq.UTM_Medium__c;


        if (acc.First_UTM_Campaign__c == null || acc.First_UTM_Campaign__c == '')
            accToUpdate.First_UTM_Campaign__c = infoReq.UTM_Campaign__c;
        accToUpdate.Last_UTM_Campaign__c = infoReq.UTM_Campaign__c;


        if (acc.First_Referrer__c == null || acc.First_Referrer__c == '')
            accToUpdate.First_Referrer__c = infoReq.Referrer__c;
        accToUpdate.Last_Referrer__c = infoReq.Referrer__c;


        if (acc.First_Landing_Page__c == null || acc.First_Landing_Page__c == '')
            accToUpdate.First_Landing_Page__c = infoReq.Landing_Page__c;
        accToUpdate.Last_Landing_Page__c = infoReq.Landing_Page__c;


        if (acc.First_Info_Request_Site__c == null || acc.First_Info_Request_Site__c == '')
            accToUpdate.First_Info_Request_Site__c = infoReq.Contact_Site__c;
        accToUpdate.Last_Info_Request_Site__c = infoReq.Contact_Site__c;

        //system.debug('Account to update2 = ' + accToUpdate);
        TriggerHandler.bypass('AccountTriggerHandler');
        update accToUpdate;
        TriggerHandler.clearBypass('AccountTriggerHandler');
    }
    private static void updateLeadUTMDetails(Lead lead, QNG_Info_Request__c infoReq) {
        Lead leadToUpdate = new Lead (Id = lead.Id);

        if (lead.First_UTM_Source__c == null || lead.First_UTM_Source__c == '')
            leadToUpdate.First_UTM_Source__c = infoReq.UTM_Source__c;
        leadToUpdate.Last_UTM_Source__c = infoReq.UTM_Source__c;


        if (lead.First_UTM_Medium__c == null || lead.First_UTM_Medium__c == '')
            leadToUpdate.First_UTM_Medium__c = infoReq.UTM_Medium__c;
        leadToUpdate.Last_UTM_Medium__c = infoReq.UTM_Medium__c;


        if (lead.First_UTM_Campaign__c == null || lead.First_UTM_Campaign__c == '')
            leadToUpdate.First_UTM_Campaign__c = infoReq.UTM_Campaign__c;
        leadToUpdate.Last_UTM_Campaign__c = infoReq.UTM_Campaign__c;


        if (lead.First_Referrer__c == null || lead.First_Referrer__c == '')
            leadToUpdate.First_Referrer__c = infoReq.Referrer__c;
        leadToUpdate.Last_Referrer__c = infoReq.Referrer__c;


        if (lead.First_Landing_Page__c == null || lead.First_Landing_Page__c == '')
            leadToUpdate.First_Landing_Page__c = infoReq.Landing_Page__c;
        leadToUpdate.Last_Landing_Page__c = infoReq.Landing_Page__c;


        if (lead.First_Info_Request_Site__c == null || lead.First_Info_Request_Site__c == '')
            leadToUpdate.First_Info_Request_Site__c = infoReq.Contact_Site__c;
        leadToUpdate.Last_Info_Request_Site__c = infoReq.Contact_Site__c;

        TriggerHandler.bypass('LeadTriggerHandler');
        update leadToUpdate;
        TriggerHandler.clearBypass('LeadTriggerHandler');
    }
}
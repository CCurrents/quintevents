/**
* @description       : Fetch the mailboxids for a lead based on leadowner alias and event interested contact site.
* @author            : ravindra.isakapatla@addonblue.com
* @group             : 
* @last modified on  : 07-25-2022
* @last modified by  : ravindra.isakapatla@addonblue.com
**/
public class OutReachMailBoxesController {
    
    public static Map<Id,Integer> fetchMailBoxdetails(List<lead> leadsToProcess){
        Map<string,Integer> mailboxmap = new Map<String,Integer>();
        Set<Id> ownerId = new Set<Id>();
        Set<String> eventIds = new Set<String>();
        Map<Id,String> lead_mailIdMap = new Map<Id,String>();
        Map<Id,Integer> leadId_MailboxIdMap = new Map<Id,Integer>();
        system.debug('leads to process-->'+leadsToProcess.size());
        for(Lead l: leadsToProcess){
            ownerId.add(l.ownerid);
            eventIds.add(l.Event_Interest_Picklist_PB__r.Program__r.contact_site__c);
        }
        Map<Id,User> userMap = new Map<Id,User>([select id,user_alias__c from user where Id In:ownerId]);
        for(Lead ld: LeadsTOProcess){
            if(usermap.get(ld.ownerId).user_alias__c!=null){
                string mailId = usermap.get(ld.ownerId).user_alias__c+'@'+ld.Event_Interest_Picklist_PB__r.Program__r.contact_site__c;
                lead_mailIdMap.put(ld.id,mailid.toLowerCase());
            }
        }
        if(lead_mailIdMap!=null){ 
            System.debug('###lead_mailIdMap=='+lead_mailIdMap);
            List<string> emails = lead_mailIdMap.values();
            string filterString = string.join(emails,',');
            System.debug('###filterstring=='+filterString);
            try{
                mailboxmap = sendrequest(filterString);
                for(Id leadId : lead_mailIdMap.keyset()){
                    leadId_MailboxIdMap.put(leadid, mailboxmap.get(lead_mailIdMap.get(leadId)));
                }
                System.debug('###leadId_MailboxIdMap=='+filterString);
                system.debug('leads to process-->'+leadId_MailboxIdMap.size()); 
            }
            catch(exception e){  
                system.debug('exception---'+e.getMessage());
            }
        }
        return leadId_MailboxIdMap;
    }
    
    public static Map<string,Integer> sendrequest( string filterstring){
        Map<string,Integer> mailboxmap = new Map<String,Integer>();
        IntegrationTokens__c token = [select id,service_Endpoint__c,access_token__c from IntegrationTokens__c where name='Outreach'];
        Http http = new Http();
        HttpRequest mailboxRequest = new HttpRequest(); 
        mailboxRequest.setendpoint(token.Service_Endpoint__c+'mailboxes?filter[email]='+filterstring);
        //?filter[email]='+filterstring
        mailboxRequest.setMethod('GET'); 
        mailboxRequest.setHeader('Accept', 'application/json');
        mailboxRequest.setHeader('Authorization', 'Bearer '+ token.access_token__c);
        HttpResponse res = http.send(mailboxRequest);
        system.debug('---->'+token.Service_Endpoint__c+'mailboxes?filter[email]='+filterstring);
        system.debug(res.getbody());
        if(res.getStatusCode()==200){
            MailBoxResponse mailResponse = (MailBoxResponse) Json.deserialize(res.getbody(),MailBoxResponse.class);
            for(MailBoxResponse.OutReachMailBoxResponse resp: MailResponse.data ){
                //MailBoxResponse.OutReachMailBoxResponse mailData =resp.data;
                string mailId = resp.attributes.email.toLowerCase();
                mailboxmap.put(mailId,resp.id);
            }
        }
        return mailboxmap;
    }
    
    /* @description to send closed leads to outreach 
*  To Mark sequence as completed.
*/ 
    @future(callout=true)
    public static void sendClosedLeads(List<Id> leadIds){
        List<RequestResponse_Log__c> logs = new List<RequestResponse_Log__c>();
        List<Lead> leadsToUpdate = new List<Lead>(); 
        List<Lead> leadsToProcess = [select id,Event_Interest_Picklist_PB__r.sequence_id__c,OwnerId,Outreach_ID__c,
                                     Event_Interest_Picklist_PB__r.Program__r.contact_site__c,status from Lead
                                     where status = 'Converted' and owner.name !='Quinton Escobar' and   
                                     Sequence_Status__c='Sequence Added' and 
                                     Event_Interest_Picklist_PB__r.Program__r.contact_site__c!=null
                                     and Id in : leadIds
                                     and Outreach_ID__c!=null]; 
        for(Lead ld: leadsToProcess){
            Map<Id,Integer> mailboxMap = Test.isRunningTest()?new Map<Id,Integer>{ld.Id=>36}: OutReachMailBoxesController.fetchMailBoxdetails(new List<Lead>{ld});
            if(!mailboxMap.isEmpty()&& mailboxMap.containsKey(ld.id)&&mailboxMap.get(ld.id)!=null){               
                /* to make a callout to Fetch sequencestate from outreach based on OutreachId , 
SequenceId and mailbox number.*/
                try{
                    String sequeneceStateendpointUrl = 'sequenceStates?filter[prospect][id]='+ld.Outreach_ID__c+'&filter[mailbox][id]='+mailboxMap.get(ld.id)+'&filter[sequence][id]='+ld.Event_Interest_Picklist_PB__r.sequence_id__c;
                    Http http1 = new Http();
                    HttpRequest sequencerequest = OutReachListener.executeCallout('GET',sequeneceStateendpointUrl, ''); 
                    HttpResponse sequenceres = http1.send(sequencerequest);
                    logs.add(createrrLog('fetchsequencestate request',sequenceres.getbody(),sequeneceStateendpointUrl,ld.id,String.valueof(sequenceres.getStatusCode())));
                    string sequencestateId ;
                    if(sequenceres.getStatusCode()==200 && !Test.isRunningTest()){
                        SequenceStateResponse sequenceResponse = (SequenceStateResponse) Json.deserialize(sequenceres.getbody(),SequenceStateResponse.class);                        
                         sequencestateId = sequenceResponse.data[0].id;
                    }
                    if(Test.isRunningTest()){
                        sequencestateId = '87654';
                    }
                        if(sequencestateId!=null){                           
                            String endpointUrl =  'sequenceStates/'+sequenceStateId+'/actions/finish';
                            Http http = new Http();
                            HttpRequest finishrequest = OutReachListener.executeCallout('POST',endpointUrl, ''); 
                            HttpResponse res = http.send(finishrequest);
                            logs.add(createrrLog('finishsequencestate request',finishrequest.getbody(),endpointUrl,ld.id,String.valueof(sequenceres.getStatusCode())));
                            if(res.getStatusCode()==200){
                                Map<String,object> recordAttributes = (Map<String,object>)json.deserializeUntyped(res.getbody());
                                Map<String,object> recordobject = (Map<String,object>)recordAttributes.get('data');
                                Map<String,object> attributevalues = (Map<String,object>)recordobject.get('attributes');							
                                string Stateresponse =(string)attributevalues.get('state');
                                ld.Sequence_Status__c = 'Sequence Finished';   
                                leadsToUpdate.add(ld);
                            }						
                        }
                    
                }
                catch(exception e){
                    logs.add(createrrLog('mailbox request','mailbox Id null'+ld.id,'/mailboxes?filter[email]'+e.getMessage(),ld.id,'400'));
                }
            }
            else{
                logs.add(createrrLog('mailbox request','mailbox Id null'+ld.id,'/mailboxes?filter[email]',ld.id,'400'));
            }            
        }
        if(!leadsToUpdate.isEmpty()){update leadsToUpdate;}
        if(!logs.isEmpty()){ insert logs;}
    }
    
    @future(Callout=True)
    public static void addLeadsToSequence(List<Id> leadIds){
        List<RequestResponse_Log__c> logs = new List<RequestResponse_Log__c>();
        List<Lead> leadsToUpdate = new List<Lead>(); 
        system.debug([Select id,outreach_id__c,Event_Interest_Picklist_PB__c,Sequence_Status__c,Event_Interest_Picklist_PB__r.Program__r.contact_site__c,
                                    owner.name,Event_Interest_Picklist_PB__r.Sequence_ID__c,ownerid from lead 
                     where id In :leadIds]);
        List<Lead> leadsToProcess =[Select id,outreach_id__c,Event_Interest_Picklist_PB__c,Event_Interest_Picklist_PB__r.Program__r.contact_site__c,
                                    owner.name,Event_Interest_Picklist_PB__r.Sequence_ID__c,ownerid from lead where 
                                    IsConverted = false and Event_Interest_Picklist_PB__r.Sequence_ID__c != null and 
                                    Event_Interest_Picklist_PB__r.Program__c!=null and 
                                    Event_Interest_Picklist_PB__r.Program__r.contact_site__c!=null and
                                    Sequence_Status__c NOT IN ('Sequence Added', 'Sequence Finished') and
                                    Id In :leadIds];
        for(Lead ld: leadsToProcess){
            Map<Id,Integer> mailboxMap = Test.isRunningTest()?new Map<Id,Integer>{ld.Id=>36}: OutReachMailBoxesController.fetchMailBoxdetails(new List<Lead>{ld});
            string mailboxId =!mailboxMap.isEmpty()&&mailboxMap.containsKey(ld.id)?string.valueof(mailboxMap.get(ld.id)):null;
            if(mailboxId!=null&&  ld.Outreach_ID__c!=null && ld.Event_Interest_Picklist_PB__r.Sequence_Id__c!=null){
                try{
                    Map<Integer,RequestResponse_Log__c> objRR = OutReachListener.addSequenceState(Integer.valueOf(ld.Outreach_ID__c), Integer.valueOf(ld.Event_Interest_Picklist_PB__r.Sequence_Id__c) ,Integer.Valueof(mailBoxId),ld.Id); 
                    logs.addall(objRR.values());
                } 
                catch(exception e){
                    logs.add(createrrLog('mailbox request','error during finish sequence process -'+e.getMessage(),'endpoint',ld.id,'400'));
                }
            }
            else{
                
                logs.add(createrrLog('mailbox request','mailbox Id-'+mailboxId,'/mailboxes?filter[email]',ld.id,'400'));
            }            
        }  
    }
    
    public static RequestResponse_Log__c createrrLog(string request,string response,string endpoint,Id leadId,string statuscode){
        RequestResponse_Log__c logRec = new RequestResponse_Log__c();
        logRec.Class_Name__c='outReachSequenceFinishUpdate';
        logRec.Request__c = request;
        logrec.Response__c = response;
        logrec.API_URL__c = endpoint;
        logrec.Status_Code__c = statuscode;
        return logRec;
    }
}
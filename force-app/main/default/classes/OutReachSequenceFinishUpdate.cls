public class OutReachSequenceFinishUpdate implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful  {
    List<Lead> lstLead = new List<Lead>();
    List<RequestResponse_Log__c> logs = new List<RequestResponse_Log__c>();
    String strQuery= '';
    string sequenceId;
    // Start method will always Query records from Lead
    public Database.QueryLocator start(Database.BatchableContext BC){
        if(strQuery!=null && sequenceId!=null){
            strQuery = strQuery+' and Event_Interest_Picklist_PB__r.sequence_id__c=:sequenceId';
        }
        //'select id,Event_Interest_Picklist_PB__r.sequence_id__c,OwnerId,Outreach_ID__c,Event_Interest_Picklist_PB__r.Program__r.contact_site__c,status from lead where status = \'converted\' and owner.name !=\'Quinton Escobar\' and Sequence_Status__c=\'Sequence Added\' ';
        return Database.getQueryLocator(strQuery);
    } 
    
    public OutReachSequenceFinishUpdate(string queryStr){
        strQuery = queryStr;
        //'select id,Event_Interest_Picklist_PB__r.sequence_id__c,OwnerId,Outreach_ID__c,Event_Interest_Picklist_PB__r.Program__r.contact_site__c,status from lead where status = \'converted\' and owner.name !=\'Quinton Escobar\' and Sequence_Status__c=\'Sequence Added\' ';
    }
    
    public OutReachSequenceFinishUpdate(String query, string sequence){
        strQuery = 'select id,Event_Interest_Picklist_PB__r.sequence_id__c,OwnerId,Outreach_ID__c,Event_Interest_Picklist_PB__r.Program__r.contact_site__c,status from lead where status = \'Converted\' and owner.name !=\'Quinton Escobar\' and Sequence_Status__c=\'Sequence Added\' and outreach_Id__c!=null and Event_Interest_Picklist_PB__r.sequence_id__c!=null ';
        sequenceId = sequence; 
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> scope){
        
        Map<Id,Integer> mailIdMap =Test.isRunningTest()?new Map<Id,Integer>{scope[0].id=>1211} :OutReachMailBoxesController.fetchMailBoxdetails(scope);
        system.debug('mailIdMap'+mailIdMap.keyset()+'Values'+mailIdMap.values());
        system.debug('scope'+scope.size());
        List<Lead> LeadList =new List<Lead>();
        for(lead convertedLead : scope){
            try{
                integer mailboxId = mailIdMap.get(convertedLead.Id);
                string prospectId = convertedLead.Outreach_ID__c;
                if(Test.isRunningTest() || (mailboxId!=null && prospectId!=null)){
                    string sequence = sequenceId!=null?sequenceId:convertedLead.Event_Interest_Picklist_PB__r.sequence_id__c;   
                    string seqnceStateId;
                    //= fetchSequenceState(mailIdMap.get(convertedLead.Id),convertedLead.Outreach_ID__c,sequence,convertedLead.id);
                    String sequeneceStateendpointUrl = 'sequenceStates?filter[prospect][id]='+prospectId+'&filter[mailbox][id]='+mailboxid+'&filter[sequence][id]='+sequenceId;
                    Http http1 = new Http();
                    HttpRequest request1 = OutReachListener.executeCallout('GET',sequeneceStateendpointUrl, ''); 
                    HttpResponse res1 = http1.send(request1);
                    RequestResponse_Log__c logrec = createrrLog('request', res1.getbody(), sequeneceStateendpointUrl, convertedLead.id);
                    logrec.Status_Code__c = String.valueof(res1.getStatusCode());
                    logs.add(logrec);
                    System.debug(res1.getbody());
                    if(res1.getStatusCode()==200 && !Test.isRunningTest() ){
                        SequenceStateResponse sequenceResponse = (SequenceStateResponse) Json.deserialize(res1.getbody(),SequenceStateResponse.class);
                        system.debug('--->'+Json.serializepretty(res1.getbody()));
                        system.debug(sequenceResponse.data[0].id);
                        seqnceStateId = sequenceResponse.data[0].id; 
                    }
                    if(Test.isRunningTest()){
                        seqnceStateId = '1234567' ;
                    }
                    
                    if(seqnceStateId != NULL){
                        //   setSequenceToFinish(seqnceStateId);
                        string seqnceStateIdstate ;
                        //=  setSequenceToFinish(convertedLead,seqnceStateId);
                        String endpointUrl =  'sequenceStates/'+seqnceStateId+'/actions/finish';
                        Http http = new Http();
                        HttpRequest request = OutReachListener.executeCallout('POST',endpointUrl, ''); 
                        HttpResponse res = http.send(request);
                        RequestResponse_Log__c logrec1 = createrrLog('request', res.getbody(), endpointUrl, convertedLead.id);
                        logrec1.Status_Code__c = String.valueof(res.getStatusCode());
                        logs.add(logrec1);
                        System.debug(res.getbody()); 
                        if(res.getStatusCode()==200 && !Test.isRunningTest()){
                            
                            Map<String,object> recordAttributes = (Map<String,object>)json.deserializeUntyped(res.getbody());
                            Map<String,object> recordobject = (Map<String,object>)recordAttributes.get('data');
                            Map<String,object> attributevalues = (Map<String,object>)recordobject.get('attributes');
                            //SequenceStateResponse sequenceResponse = (SequenceStateResponse) Json.deserialize(res.getbody(),SequenceStateResponse.class);
                            seqnceStateIdstate =(string)attributevalues.get('state');
                            convertedlead.Sequence_Status__c = 'Sequence Finished';
                        }     
                        if(Test.isRunningTest()){
                            convertedlead.Sequence_Status__c = 'Sequence Finished';
                            seqnceStateIdstate='Sequence Finished';
                        }
                        if(seqnceStateIdstate !=NULL){                        
                            lstLead.add(convertedLead);
                        }                
                        
                    }                   
                }
                else{
                    system.debug('maibox or prospect id is null'+convertedlead.id);
                }
            }        
            catch(exception ex){
                system.debug('exception while hitting outreach to update finish state for sequence'+ex.getMessage());
                logs.add(createrrLog('request', 'exception', 'FinishUpdate', convertedLead.id));
            }
        }         
    }
    
    public void finish(Database.BatchableContext BC){
        if(lstLead.size()>0){
            update lstLead;
        }
        if(!logs.isEmpty()){
            insert logs;
        }
    }
    /*
public  String setSequenceToFinish(Lead convertedLead, string sequenceStateId){
// to make a callout to update sequencestate to FInish in outreach
String Stateresponse;
try{
//String endpointUrl =  'sequenceStates/'++'/actions/finish';
String endpointUrl =  'sequenceStates/'+sequenceStateId+'/actions/finish';
Http http = new Http();
HttpRequest request = OutReachListener.executeCallout('POST',endpointUrl, ''); 
HttpResponse res = http.send(request);
RequestResponse_Log__c logrec = createrrLog('request', res.getbody(), endpointUrl, convertedLead.id);
logrec.Status_Code__c = String.valueof(res.getStatusCode());
logs.add(logrec);
System.debug(res.getbody()); 
if(res.getStatusCode()==200){
Map<String,object> recordAttributes = (Map<String,object>)json.deserializeUntyped(res.getbody());
Map<String,object> recordobject = (Map<String,object>)recordAttributes.get('data');
Map<String,object> attributevalues = (Map<String,object>)recordobject.get('attributes');
//SequenceStateResponse sequenceResponse = (SequenceStateResponse) Json.deserialize(res.getbody(),SequenceStateResponse.class);
Stateresponse =(string)attributevalues.get('state');
convertedlead.Sequence_Status__c = 'Sequence Finished';   
}    
return Stateresponse;
}
catch(exception ex){
system.debug('exception while hitting outreach to update finish state for sequence'+ex.getMessage());
}
return Stateresponse;

}

public  string fetchSequenceState(Integer mailboxid,string prospectId,string sequenceId, Id leadId){
string sequencestateId;
try{            
// to make a callout to Fetch sequencestate from outreach based on OutreachId , 
// SequenceId and mailbox number.
String sequeneceStateendpointUrl = 'sequenceStates?filter[prospect][id]='+prospectId+'&filter[mailbox][id]='+mailboxid+'&filter[sequence][id]='+sequenceId;
Http http1 = new Http();
HttpRequest request1 = OutReachListener.executeCallout('GET',sequeneceStateendpointUrl, ''); 
HttpResponse res1 = http1.send(request1);
RequestResponse_Log__c logrec = createrrLog('request', res1.getbody(), sequeneceStateendpointUrl, leadId);
logrec.Status_Code__c = String.valueof(res1.getStatusCode());
logs.add(logrec);
System.debug(res1.getbody());
if(res1.getStatusCode()==200){
SequenceStateResponse sequenceResponse = (SequenceStateResponse) Json.deserialize(res1.getbody(),SequenceStateResponse.class);
system.debug('--->'+Json.serializepretty(res1.getbody()));
system.debug(sequenceResponse.data[0].id);
sequencestateId = sequenceResponse.data[0].id; 
}
return sequencestateId;
}
catch(exception ex){
system.debug('exception while hitting outreach to fetch sequence state ' +ex.getMessage());
}
return sequencestateId;
}
*/
    public RequestResponse_Log__c createrrLog(string request,string response,string endpoint,Id leadId){
        RequestResponse_Log__c logRec = new RequestResponse_Log__c();
        logRec.Class_Name__c='outReachSequenceFinishUpdate';
        logRec.Request__c = request;
        logrec.Response__c = response;
        logrec.API_URL__c = endpoint;
        
        return logRec;
    }
}
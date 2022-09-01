/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 08-09-2022
 * @last modified by  : ratiksinghal@addonblue.com
**/
public class OutReachLeadProcessBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	List<RequestResponse_Log__c> lstRequestResponse = new List<RequestResponse_Log__c>();
    List<Lead> lstLead = new List<Lead>();
    Integer skipCount=0;
    String strQuery ;
    String sequenceId ;
    List<id> lstleads = new list<id>();

     public OutReachLeadProcessBatch(List<Id> leadIds){
        lstLeads = leadIds;
        strQuery = 'Select id,outreach_id__c,Event_Interest_Picklist_PB__c,Event_Interest_Picklist_PB__r.Program__r.contact_site__c,owner.name,Event_Interest_Picklist_PB__r.Sequence_ID__c,ownerid from lead where IsConverted = false and Event_Interest_Picklist_PB__r.Sequence_ID__c != null and Event_Interest_Picklist_PB__r.Program__c!=null and Sequence_Status__c NOT IN (\'Sequence Added\', \'Sequence Finished\') and Id in:lstleads';
       //'Select Id, OutReach_Id__c, ownerId, Event_Interest_Picklist_PB__r.Program__r.contact_site__c,Event_Interest_Picklist_PB__r.Sequence_ID__c from lead where Sequence_Status__c NOT IN (\'Sequence Added\', \'Sequence Finished\') and Status = \'delivered\'';
    }
    
    public OutReachLeadProcessBatch(String querystr){
        strQuery = querystr;
            //'Select Id, OutReach_Id__c, ownerId, Event_Interest_Picklist_PB__r.Program__r.contact_site__c,Event_Interest_Picklist_PB__r.Sequence_ID__c from lead where Sequence_Status__c NOT IN (\'Sequence Added\', \'Sequence Finished\') and Status = \'delivered\'';
       // sequenceId = sqId;
    }
    
    public OutReachLeadProcessBatch(string stquery, String sqId){
        strQuery ='Select id,outreach_id__c,Event_Interest_Picklist_PB__c,Event_Interest_Picklist_PB__r.Program__r.contact_site__c,owner.name,Event_Interest_Picklist_PB__r.Sequence_ID__c,ownerid from lead where IsConverted = false and Event_Interest_Picklist_PB__r.Sequence_ID__c != null and Event_Interest_Picklist_PB__r.Program__c!=null and Sequence_Status__c NOT IN (\'Sequence Added\', \'Sequence Finished\') and Status!=\'In Sequence\' and owner.name!=\'Quinton Escobar\'and Actively_being_Sequenced__c=false and outreach_id__c!=null and Current_Sequence_Name__c=null and Name_of_Currently_Active_Sequence__c=null';
        sequenceId = sqId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('OutReachLeadProcessBatch--sequenceId--'+sequenceId);
        if(sequenceId!=null && strQuery!=null){
            strQuery = strQuery+' and Event_Interest_Picklist_PB__r.Sequence_ID__c=:sequenceId';
        }
        system.debug('---'+strQuery);
        return Database.getQueryLocator(strQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<Id,String> idAndOutReachMap = new Map<Id,String>();
        Map<String,Id> leadMap = new Map<String,Id>();
        Map<Id,String> sequenceIdMap = new Map<Id,String>();
        
        try{
            System.debug('###leadsToProcess=='+scope);
            List<lead> leadsToProcess =(List<lead>)  scope;
             Map<Id,Lead> leadsMap = new Map<Id,Lead>(leadsToProcess);
            for(Lead objLead: leadsToProcess){
                idAndOutReachMap.put(objLead.Id, objLead.OutReach_Id__c);
                leadMap.put(objLead.OutReach_Id__c,objLead.Id);
                sequenceIdMap.put(objLead.Id,objLead.Event_Interest_Picklist_PB__r.Sequence_ID__c);
            }
            System.debug('###leadMap=='+leadMap);
            Map<Id,Integer> mailBoxAndEmailMap =  new Map<Id,Integer>();
            if(!Test.isRunningTest()){
                mailBoxAndEmailMap =  OutReachMailBoxesController.fetchMailBoxdetails(leadsToProcess);
            }
            else{
                mailBoxAndEmailMap.put(leadsToProcess[0].Id,36);
            }
            for(Id id: mailBoxAndEmailMap.keyset()){
                String prospectId = idAndOutReachMap.get(id);
                Integer mailBoxId = mailBoxAndEmailMap.get(id);
                //String  strSequenceId = sequenceIdMap.get(id);
                String lSequenceId = !String.isBlank(sequenceId) ? sequenceId : sequenceIdMap.get(id);
                RequestResponse_Log__c rr = null;
                if(!String.isBlank(prospectId) && mailBoxId!=null && !String.isBlank(lSequenceId) ){
                    System.debug('@prospectId: '+ prospectId +', @mailBoxId: '+ mailBoxId+', @sequenceId: '+ lSequenceId);
                    Map<Integer,RequestResponse_Log__c> objRR = OutReachListener.addSequenceState(Integer.valueOf(prospectId), Integer.valueOf(lSequenceId) , mailBoxId,id);
                    rr = objRR.get(Integer.valueOf(prospectId));
                    Lead leadObj = null;
                    if(rr.Status_Code__c == '201'){
                        leadObj = new Lead();
                        leadObj.Id = leadMap.get(prospectId);
                        leadObj.Sequence_Status__c = 'Sequence Added';
                        lstLead.add(leadObj);
                    }
                }
                else{
                    rr = new RequestResponse_Log__c();
                    rr.Status_Code__c = '404';
                    rr.Lead__c = id;
                    rr.Request__c = 'prospectId/mailBoxId/sequenceId may have null values';
                    rr.Response__c = 'Values: prospectId: '+ prospectId +', mailBoxId: '+ mailBoxId+', sequenceId: '+ lSequenceId;
                    skipCount++;
                }                                
                lstRequestResponse.add(rr);
            }
        }
        catch(exception ex){
            System.debug('Exception :OutReachLeadProcessBatch-'+ex.getlinenumber()+'--'+ex.getmessage());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
    
    public void finish(Database.BatchableContext BC){ 
    	insert lstRequestResponse;
        upsert lstLead;
        system.debug('Total Records Skipped '+skipCount);
    }
}
/**
 * @description       : 
 * @author            : jagrawal@addonblue.com
 * @group             : 
 * @last modified on  : 01-26-2021
 * @last modified by  : Jheel Agrawal
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   01-26-2021   jagrawal@addonblue.com    Initial Version
**/
public with sharing class LeadTriggerHelper {
    
    private Map<Id, Lead> newLeadMap; 
    private Map<Id, Lead> oldLeadMap;
    private List<Lead> newLeadList;
    private List<Lead> oldLeadList;
     
    
    public LeadTriggerHelper() {

        this.newLeadMap = (Map<Id, Lead>) Trigger.newMap;
        this.oldLeadMap = (Map<Id, Lead>) Trigger.oldMap;
        this.newLeadList = (List<Lead>) Trigger.new;
        this.oldLeadList = (List<Lead>) Trigger.old;

        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
                System.debug('In Before Lead Insert!');
                updateEmailOptOut();
            }
            
            when BEFORE_UPDATE {
                System.debug('In Before Lead Update!');
                updateEmailOptOut();
            }
            
            when BEFORE_DELETE {
                System.debug('In Before Lead Delete!');
            }
            
           when AFTER_INSERT {
                System.debug('In After Lead Insert!');              
            }
            
            when AFTER_UPDATE {
                System.debug('In After Lead Update!');
                sendLeadUpdateToOutreach();
            }
            
            when AFTER_DELETE {
                System.debug('In After Lead Delete!');
            }
            
            when AFTER_UNDELETE {
                System.debug('In After Lead Undelete!');
            }
            
            when else {
                System.debug('Undefined Trigger Operation!');
            }
        }
    }
    
    /**
    * @description 
    * @author jagrawal@addonblue.com | 01-26-2021 
    **/
    public void updateEmailOptOut(){
        System.debug('lstLead method call@@'+newLeadList);
        for(Lead objLead : newLeadList){
            if(objLead.Marketing_Email_Consent__c != null && objLead.Marketing_Email_Consent__c == 'Yes'){
                objLead.HasOptedOutOfEmail = false;
            }
            else if(objLead.Marketing_Email_Consent__c == null || objLead.Marketing_Email_Consent__c == 'No'){
                objLead.HasOptedOutOfEmail = true;            
            }
        }
    }

   
    
    public void sendLeadUpdateToOutreach(){
       User u =[Select id from user where name='Quinton Escobar']; 
       List<Id> leadsToProcess = new List<Id>();
       List<Id> leadsToSequence = new List<Id>(); 
        for(Lead ld: newLeadList){
            if( ld.Sequence_Status__c=='Sequence Added' && ld.Status=='Converted' && ld.Outreach_ID__c!=null
               && ld.status!= oldLeadMap.get(ld.Id).status){
                leadsToProcess.add(ld.Id);
            }
            
            if(ld.Outreach_ID__c!=null&&ld.Outreach_ID__c!=oldLeadMap.get(ld.Id).OutReach_Id__c
              && ld.Status!='In Sequence' && ld.Event_Interest_Picklist_PB__c!=null &&
              ld.Current_Sequence_Name__c==null && !ld.Actively_being_Sequenced__c &&
              ld.Name_of_Currently_Active_Sequence__c==null && ld.OwnerId!=u.Id){
                leadsToSequence.add(ld.Id);
                  system.debug(leadsToSequence);
            }
        }
        if(!leadsToProcess.isEmpty()){
             OutReachMailBoxesController.SendClosedLeads(leadsToProcess); 
            //Database.executeBatch(new OutReachLeadProcessBatch(leadsToProcess),5);
        }
        
        if(!leadsToSequence.isEmpty()){
            OutReachMailBoxesController.addLeadsToSequence(leadsToSequence);
        }
    }

}
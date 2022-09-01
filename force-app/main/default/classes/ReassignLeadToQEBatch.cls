/**
 * @description       : #1180 Reassign Leads to QE if Communication Confirmed is false
 * @author            : fsuraitawala@addonblue.com
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : fsuraitawala@addonblue.com
**/
global class ReassignLeadToQEBatch implements Database.AllowsCallouts, Database.Batchable<sObject>, Schedulable, Database.Stateful {
    String query = null;

    public ReassignLeadToQEBatch(){
        this.query = 'Select Id, Owner.Name, Communication_Confirmed__c, Created_Days__c FROM Lead WHERE Communication_Confirmed__c = false AND IsConverted = false AND Created_Days__c >= 32';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Lead> LeadList){
        String QEOwnerId = [Select Id FROM User WHERE Name = 'Quinton Escobar' LIMIT 1].Id;
        List<Lead> lstUpdateLead = new List<Lead>();
        for(Lead objLead: LeadList){
            if(objLead.Owner.Name != 'Quinton Escobar'){
                objLead.OwnerId = QEOwnerId;
                lstUpdateLead.add(objLead);
            }
        }
        if(lstUpdateLead.size() > 0){
            update lstUpdateLead;
        }
        
    }
    
    public void finish(Database.BatchableContext BC){}

    public void execute(SchedulableContext sc){
        Database.executeBatch(new ReassignLeadToQEBatch(), 50);
    }
}
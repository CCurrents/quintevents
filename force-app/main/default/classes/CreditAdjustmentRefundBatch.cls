/**
 * @File Name          : CreditAdjustmentRefundBatch.cls
 * @Description        : To create Credit Adjustment Refund PDF
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 05/25/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    05/25/2020  kchavda@addonblue.com     Initial Version
**/
global class CreditAdjustmentRefundBatch implements Database.Batchable<sObject>, Database.Stateful {
     //Variable Section
    global FINAL String strQuery;    
    global List<Attachment> attachments = new List<Attachment>();   
    global set<string> EventIds = new set<string>();  
    global Set<Id> setparentOppId = new set<Id>();
    
    global CreditAdjustmentRefundBatch(string query, set<string> entIds,Set<Id> oppIds) { 
        this.strQuery = query; 
        this.EventIds = entIds;
        this.setparentOppId = oppIds;             
    }        
        
    //Batch Start method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(strQuery);
    }

    //Batch Execute method 
    global void execute(Database.BatchableContext BC, List<sObject> scopeList) {           
        if(!scopeList.isEmpty()) {  
            List<opportunity> opps =  (List<opportunity>) scopeList;   
            map<Id,string> mapoppIds = new map<Id,string>();
            for(attachment att: [Select id,parentId,Name from attachment where parentid in:opps]){
                mapoppIds.put(att.parentId,att.Name);
            }             
            for(opportunity opp: (List<opportunity>) scopeList){
                pageReference pdf = Page.CreditAdjustmentRefundPDF;
                pdf.getParameters().put('id',opp.id);
                Blob body;
                if(!test.isRunningTest()){
                    body = pdf.getContent();
                }else{
                    body = blob.valueOf('TestString');
                }
                if(opp.Refund_Response__c != null &&  opp.Refund_Response__c.contains('*'))  
                    opp.Refund_Response__c = opp.Refund_Response__c.replace('*','');
                if(mapoppIds.size() == 0 || (mapoppIds.size()>0 && (!mapoppIds.containskey(opp.Id) || (mapoppIds.containskey(opp.Id) && mapoppIds.get(opp.Id) != opp.Refund_Response__c+'.pdf')))){
                    attachments.add (new Attachment(
                        ParentId = opp.id,
                        Body = body,
                        Name = opp.Refund_Response__c+'.pdf'));    
                }                                           
            }
            
            if(attachments.size() > 0){
                Utility.ProcessRecords(attachments,'insert');
            } 
        }
    } 
    
    //Batch Finish method for after execution of batch work
    global void finish(Database.BatchableContext BC) {              
        
    }
    
    
    
}
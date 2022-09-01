global class SendCreditAddendumOpportunityBatch implements Database.Batchable<sObject>, Database.Stateful {
     //Variable Section
    global FINAL String strQuery;
    //global FINAL String EventId;
    //global FINAL String AttachmentName;
    
    global SendCreditAddendumOpportunityBatch(string query) { 
        this.strQuery = query;
        //this.EventId = evtId;
        //this.AttachmentName = attName;
    }        
        
    //Batch Start method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(strQuery);
    }

    //Batch Execute method calls findCostForWoD method
    global void execute(Database.BatchableContext BC, List<sObject> scopeList) {           
        if(!scopeList.isEmpty()) { 
            List<Attachment> attachments = new List<Attachment>();           
            for(opportunity opp: (List<opportunity>) scopeList){
                pageReference pdf = Page.OpportunityCreditAddendumPDF;
                pdf.getParameters().put('id',opp.id);
                Blob body;
                if(!test.isRunningTest()){
                    body = pdf.getContent();
                }else{
                    body = blob.valueOf('TestString');
                }
                 if(opp.Refund_Response__c != null &&  opp.Refund_Response__c.contains('*'))  
                    opp.Refund_Response__c = opp.Refund_Response__c.replace('*','');  
                attachments.add (new Attachment(
                    ParentId = opp.id,
                    Body = body,
                    Name = opp.Refund_Response__c+'.pdf'));  
            }
            
            if(attachments.size() > 0){
                Insert attachments;
            }
        }
    } 
    
    //Batch Finish method for after execution of batch work
    global void finish(Database.BatchableContext BC) {        
        
    }
    
    
    
}
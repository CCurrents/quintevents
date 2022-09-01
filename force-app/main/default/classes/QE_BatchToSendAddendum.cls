global class QE_BatchToSendAddendum implements Database.Batchable<sObject>, Database.Stateful {
     //Variable Section
    global FINAL String strQuery;
    global FINAL String EventId;
    
    global QE_BatchToSendAddendum(string query, string evtId) { 
        this.strQuery = query;
        this.EventId = evtId;
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
                pageReference pdf = Page.OpportunityAddendumPDF;
                pdf.getParameters().put('id',opp.id);
                Blob body;
                if(!test.isRunningTest()){
                    body = pdf.getContent();
                }else{
                    body = blob.valueOf('TestString');
                }
                  
                attachments.add (new Attachment(
                    ParentId = opp.id,
                    Body = body,
                    Name = 'Addendum.pdf'));  
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
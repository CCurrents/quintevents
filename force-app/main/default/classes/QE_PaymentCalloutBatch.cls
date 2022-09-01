global class QE_PaymentCalloutBatch  implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
    /**
        *  Software.
        * @category  
        * @author    
        * @copyright Copyright (c) 2017-2018 
    */
    global String query;
    public Date  DateVal;
    global QE_PaymentCalloutBatch(){
        Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();   
        DateVal = cs.Payment_Batch_Start_From__c;
        String intacctStatus = cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c';
        String intacctRecordId = cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c';
        query = Label.ARPayment_Query.replace('intacctStatus_x',intacctStatus).replace('intacctRecordId_x',intacctRecordId);
        query = 'SELECT Intacct_Failure_Reason__c,Intacct_Line_Number__c,Intacct_Id__c,Record_Id__c,Intacct_Status__c,Opportunity__c,Opportunity__r.StageName,Status__c FROM Payment_Term__c'+
                ' WHERE Status__c = \'Passed\' AND ' + intacctStatus + ' != \'Success\' AND ' + intacctStatus + ' != \'Failed\' AND ' + (cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c') + ' != null AND (Opportunity__r.StageName = \'Closed Won\' OR Opportunity__r.StageName = \'Canceled\')';
        if( DateVal != null ){
            query += ' AND CreatedDate >= : DateVal';
        }
        if(Label.ARPayment_Query_Filters != 'false') {
            query += ' ' + Label.ARPayment_Query_Filters;
        }
        System.debug('query ==>' + query);
    }   
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Payment_Term__c> sOLList) {
        System.debug('InBatch==>'+sOLList.size());
        
        try{
            for(Payment_Term__c opt: sOLList){
                QE_Intacct_FutureCallout.paymentUpdateIntacctBatch(opt.Id);
            }
        }catch(exception e){
            system.debug('Error:- '+e +' Number:- '+e.getLineNumber());
        }
    }   
     
    global void finish(Database.BatchableContext BC) {
        
    }
    
}
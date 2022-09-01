global class QE_BatchTocheckOrderPaymentStatus implements Database.Batchable<sObject>, Database.Stateful {

    //Variable Section
    global FINAL String strQuery;
    global FINAL Set<Id> setOpportunityId = new Set<Id>();
    
    global QE_BatchTocheckOrderPaymentStatus() { 
        this.strQuery = getBatchQuery();
    }
    
    //Returns the Query String to Batch constructor to fetch right records.
    private String getBatchQuery() {
        String strQuery = 'Select Id from opportunity where Order_Payment_Status__c = \'Not Paid\' and id in (select opportunity__c from Opportunity_Payment_Terms__c where status__c = \'Passed\')'; 
        return strQuery;
    }
        
    //Batch Start method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(strQuery);
    }

    //Batch Execute method calls findCostForWoD method
    global void execute(Database.BatchableContext BC, List<sObject> scopeList) {        
        
        if(!scopeList.isEmpty()) { 
            for(opportunity opp: (List<opportunity>) scopeList){
                setOpportunityId.add(opp.Id);
            }
            
        }
    } 
    //Batch Finish method for after execution of batch work
    global void finish(Database.BatchableContext BC) {
        System.debug('setOpportunityId###' + setOpportunityId);
        sendingEmail();
        
    }
    //Send Email Method
    public PageReference sendingEmail(){
        String collegeString = '';
        if((setOpportunityId != null && setOpportunityId.size() > 0) || Test.isrunningtest()){
            for(Id sitId : setOpportunityId) {
               collegeString += (collegeString ==''?'': '\r\n') + URL.getSalesforceBaseUrl().toExternalForm()+'/'+sitId ;
            }
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            String[] sendingTo = new String[]{}; 
            sendingTo.addall(system.label.Mismatch_Email_Notification.split(','));
            semail.setToAddresses(sendingTo); 
            semail.setSubject('Order Payment Status not Updated.');
            semail.setPlainTextBody('Hello,'+ '\r\n' + '\r\n' + collegeString + '\r\n' + '\r\n'+ 'Thanks'); 
            if(!Test.isrunningTest()){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
            } 
        }
        
        return null; 
    } 
    
}
/**
 * @File Name          : QE360_BatchTocheckPaymnetMismatch.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 6:29:58 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
global class QE360_BatchTocheckPaymnetMismatch {

    //Variable Section
    // global FINAL String strQuery;
    // global FINAL Set<Id> setOfOpprotunityId = new Set<Id>();
    
    global QE360_BatchTocheckPaymnetMismatch() { 
        // this.strQuery = getBatchQuery();
    }
    
    //Returns the Query String to Batch constructor to fetch right records.
    // private String getBatchQuery() {
    //     String strQuery = 'select id,amount from Opportunity where Amount != null and Amount!= 0 and stagename = \'Closed Won\' and Event__r.Active__c = true'; 
    //     return strQuery;
    // }
        
    //Batch Start method
    // global Database.QueryLocator start(Database.BatchableContext BC) {
    //     return Database.getQueryLocator(strQuery);
    // }

    //Batch Execute method calls findCostForWoD method
    // global void execute(Database.BatchableContext BC, List<sObject> scopeList) {
        // System.debug(LoggingLevel.INFO, '== scopeList size ==' + scopeList.size());
        // List<Opportunity> oppsList = (List<Opportunity>) scopeList;
        // Map<id,Double> mapopp = new map<id,Double>();
        // if(!oppsList.isEmpty()) { 
        //     for(Opportunity opp: oppsList){
        //         mapopp.put(opp.id,opp.amount);                                  
        //     }            
        // }
        // List<Opportunity_Payment_Terms__c> lst=[select id,amount__c, Opportunity__c from Opportunity_Payment_Terms__c where Opportunity__c in: mapopp.keyset()];
        // Map<id,Double> mappaymentterm = new map<id,Double>();
        // for(Opportunity_Payment_Terms__c opt: lst){
        //    if(!mappaymentterm.containskey(opt.Opportunity__c)){
        //        mappaymentterm.put(opt.Opportunity__c,opt.amount__c);
        //    }else{
        //        mappaymentterm.put(opt.Opportunity__c,mappaymentterm.get(opt.Opportunity__c)+opt.amount__c);
        //    }
        // }
        
        // for(id oppId: mapopp.keyset()){
        //    if(mappaymentterm.containskey(oppId) && (mappaymentterm.get(oppId) == null || mappaymentterm.get(oppId) == 0)){
        //        setOfOpprotunityId.add(oppId);
        //    }
        // }
    // } 
    //Batch Finish method for after execution of batch work
    // global void finish(Database.BatchableContext BC) {
    //     System.debug('setOfOpprotunityId  ###' + setOfOpprotunityId);
    //     sendingEmail();
        
    // }
    //Send Email Method
    // public PageReference sendingEmail(){
        // String collegeString = '';
        // if(setOfOpprotunityId.size() > 0 && setOfOpprotunityId != null){
        //     for(Id sitId : setOfOpprotunityId  ) {
        //        collegeString += (collegeString ==''?'': '\r\n') + URL.getSalesforceBaseUrl().toExternalForm()+'/'+sitId ;
        //     }
        //     Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        //     String[] sendingTo = new String[]{'jpatel@quintevents.com','kchavda@addonblue.com'}; 
        //     semail.setToAddresses(sendingTo); 
        //     semail.setSubject('Opportunity Payment Term Amount Mismatched.');
        //     semail.setPlainTextBody('Hello,'+ '\r\n' + '\r\n' + collegeString + '\r\n' + '\r\n'+ 'Thanks'); 
        //     Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
        // }
        
    //     return null; 
    // } 
}
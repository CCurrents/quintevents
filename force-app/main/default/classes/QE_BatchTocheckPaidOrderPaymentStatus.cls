/**
 * @File Name          : QE_BatchTocheckPaidOrderPaymentStatus.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 3:29:31 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
global class QE_BatchTocheckPaidOrderPaymentStatus implements Database.Batchable<sObject>, Database.Stateful {

    //Variable Section
    global FINAL String strQuery;
    global FINAL Set<Id> setOpportunityId = new Set<Id>();
    
    global QE_BatchTocheckPaidOrderPaymentStatus() { 
        this.strQuery = getBatchQuery();
    }
    
    //Returns the Query String to Batch constructor to fetch right records.
    private String getBatchQuery() {
        String strQuery = 'Select Id from Account Limit 1';// 'Select Id, Paid_In_Full__c, Order_Payment_Status__c, (Select Id, Status__c From Opportunity_Payment_Terms__r) From Opportunity Where StageName = \'Closed Won\' and Event__r.Active__c = True '; 
        return strQuery;
    }
        
    //Batch Start method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(strQuery);
    }

    //Batch Execute method calls findCostForWoD method
    global void execute(Database.BatchableContext BC, List<sObject> scopeList) {        
        
        // if(!scopeList.isEmpty()) { 
        //    for(Opportunity oppt: (List<opportunity>) scopeList) {
        //         Integer numOfPT = oppt.Opportunity_Payment_Terms__r.size();
        //         Integer numOfPtCounted = 0;
        //         for(Opportunity_Payment_Terms__c pt : oppt.Opportunity_Payment_Terms__r){
        //             if(pt.Status__c == 'Passed') {
        //                 numOfPtCounted++;
        //             }
        //         }
        //         if(numOfPT == numOfPtCounted && (oppt.Paid_In_Full__c = false || oppt.Order_Payment_Status__c != 'Fully Paid')){
        //             setOpportunityId.add(oppt.id);
        //             System.debug(oppt.id+': '+numOfPT+' '+numOfPtCounted+' '+oppt.Paid_In_Full__c+' '+oppt.Order_Payment_Status__c);
        //         }
        //     }
            
        // }
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
            semail.setSubject('Order Payment Status not Updated as Fully Paid.');
            semail.setPlainTextBody('Hello,'+ '\r\n' + '\r\n' + collegeString + '\r\n' + '\r\n'+ 'Thanks'); 
            if(!Test.isrunningTest()){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
            } 
        }
        
        return null; 
    } 
    
}
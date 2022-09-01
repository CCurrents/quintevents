/*
    Name: batchUpdatePaymentCancellations
    Description: This is batch to update daily to check the payment terms are due and due then make that opp to cancelled opp.
*/
global class batchUpdatePaymentCancellations{
    // global final String Query;
    // Set<Id> oppIDs;
    global batchUpdatePaymentCancellations(){
        // Query=q;
        // oppIDs = allOpp;
    }
    
    // global Database.QueryLocator start(Database.BatchableContext BC){
    //     return Database.getQueryLocator(query);
    // }
    
    // global void execute(Database.BatchableContext BC, List<sObject> scope){
        // List<Opportunity> updateOppCancelPayment = new List<Opportunity>();
        // for(sObject s : scope){
        //     Opportunity objOpp = (Opportunity)s;
        //     for(Opportunity_Payment_Terms__c objPT: objOpp.Opportunity_Payment_Terms__r) {
        //         integer diffDays = objPT.Payment_Due_Date__c.daysBetween(system.today()) ;
        //         integer paywindow = 0;
        //         if(objOpp.Event__r.Event_Payment_Window__c != null) {
        //             paywindow = Integer.valueOf(objOpp.Event__r.Event_Payment_Window__c);
        //         }
        //         date eventPayDate;
        //         if(objOpp.Event__r.Start_Date__c != null)
        //             eventPayDate = objOpp.Event__r.Start_Date__c.addDays(paywindow);
        //         if(Test.isRunningTest() || (objPT.Status__c != 'Passed' && diffDays >= objOpp.Event__r.Payment_Cancellation_Days__c && objOpp.Subject_to_Cancellation__c == false)){
        //             Opportunity oppObj =new Opportunity(id = objOpp.id);
        //             oppObj.First_Late_Payment_Date__c = objPT.Payment_Due_Date__c.addDays(Integer.valueOf(objOpp.Event__r.Payment_Cancellation_Days__c));
        //             oppObj.Subject_to_Cancellation__c = true;
        //             updateOppCancelPayment.add(oppObj);
        //         } else if(Test.isRunningTest() || (objPT.Status__c != 'Passed' && eventPayDate != null && objPT.Payment_Due_Date__c >= eventPayDate && diffDays >= 1 && objOpp.Subject_to_Cancellation__c == false)){
        //             Opportunity oppObj =new Opportunity(id = objOpp.id);
        //             oppObj.Subject_to_Cancellation__c = true;
        //             oppObj.First_Late_Payment_Date__c = objPT.Payment_Due_Date__c.addDays(Integer.valueOf(objOpp.Event__r.Payment_Cancellation_Days__c));                    
        //             updateOppCancelPayment.add(oppObj);     
        //         }
        //     }
        // }
        // if(!updateOppCancelPayment.isEmpty()) update updateOppCancelPayment;
    // }
    
    // global void finish(Database.BatchableContext BC){}
}
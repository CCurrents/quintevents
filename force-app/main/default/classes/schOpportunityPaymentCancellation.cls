/*
    Name: schOpportunityPaymentCancellation
    Description: This is scheduled daily to check the payment terms are due and pass the due make that opp to cancelled opp.
*/
global class schOpportunityPaymentCancellation {
    // global void execute(SchedulableContext sc) {
    //     updateOppPaymentCancellations();
    // }
    public schOpportunityPaymentCancellation() {
        // List<Opportunity_Payment_Terms__c> allPayTerms = new List<Opportunity_Payment_Terms__c>([Select id,
        //                  Payment_Due_Date__c, Opportunity__c, Opportunity__r.Event__r.Event_Payment_Window__c,
        //                  Opportunity__r.Event__r.Start_Date__c,
        //                  Opportunity__r.Event__r.Payment_Cancellation_Days__c, Opportunity__r.Subject_to_Cancellation__c 
        //                  from Opportunity_Payment_Terms__c where Payment_Due_Date__c <= TODAY
        //                  and Opportunity__r.StageName = 'Closed Won'
        //                  and Opportunity__r.Event__r.Payment_Cancellation_Days__c != null order by Payment_Due_Date__c]);
        // Set<Id> oppIDs = new Set<Id>();
        // List<Opportunity> updateOppCancelPayment = new List<Opportunity>();
        
        // for(Opportunity_Payment_Terms__c objPT: allPayTerms){
        //     if(Test.isRunningTest() || !oppIDs.contains(objPT.Opportunity__c)) {
        //         oppIDs.add(objPT.Opportunity__c);
        //     }
        // }
        
        // String query = 'Select id,Event__r.Event_Payment_Window__c,Event__r.Start_Date__c,Event__r.Payment_Cancellation_Days__c,Subject_to_Cancellation__c,(Select Id,Status__c,Payment_Due_Date__c from Opportunity_Payment_Terms__r where Payment_Due_Date__c != null order by Payment_Due_Date__c limit 1) from Opportunity where id in: oppIDs';
        // batchUpdatePaymentCancellations objBatchUpdate = new batchUpdatePaymentCancellations(query,oppIDs);
        // ID batchprocessid = Database.executeBatch(objBatchUpdate,20);
        
    }
}
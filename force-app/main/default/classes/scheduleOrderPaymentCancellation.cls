/**
 * @File Name          : ScheduleOrderPaymentCancellation.cls
 * @Description        : schedule class to payment cancellation
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : Lovel Panchal
 * @Last Modified On   : 5/11/2020, 5:29:13 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0     4/20/2020    mpatel@addonblue.com    Initial Version
**/
global class scheduleOrderPaymentCancellation Implements Schedulable{
    global void execute(SchedulableContext sc) {
        updateOrderPaymentCancellations();
    }
    /**
    * @description  : this method use to get payment term record and pass to batch class for updating all cancel order payments
    * @author       : mpatel@addonblue.com | 4/20/2020 
    * @return       : void 
    **/
    global static void updateOrderPaymentCancellations() {
        try{
            List<Payment_Term__c> allPayTerms = new List<Payment_Term__c>([Select id,
                            Payment_Due_Date__c, Order__c, Order__r.Opportunity.PriceBook2.Event_Payment_Window__c, Order__r.Opportunity.PriceBook2.Start_Date__c,
                            Order__r.Opportunity.PriceBook2.Payment_Cancellation_Days__c, Order__r.Subject_to_Cancellation__c 
                            from Payment_Term__c
                            where Payment_Due_Date__c <= TODAY
                            and Order__r.Opportunity.StageName = 'Closed Won'
                            and Order__r.Opportunity.PriceBook2.Payment_Cancellation_Days__c != null order by Payment_Due_Date__c]);
            Set<Id> orderIDs = new Set<Id>();
            List<Opportunity> updateOppCancelPayment = new List<Opportunity>();
            
            for(Payment_Term__c objPT: allPayTerms){
                if(Test.isRunningTest() || !orderIDs.contains(objPT.Order__c)) {
                    orderIDs.add(objPT.Order__c);
                }
            }
            String query = 'Select id,Opportunity.PriceBook2.Event_Payment_Window__c,Opportunity.PriceBook2.Start_Date__c,Opportunity.PriceBook2.Payment_Cancellation_Days__c,Subject_to_Cancellation__c,(Select Id,Status__c,Payment_Due_Date__c from Payment_Terms__r where Payment_Due_Date__c != null order by Payment_Due_Date__c limit 1) from Order where id in: orderIDs';
            UpdatePaymentCancellationsBatch objBatchUpdate = new UpdatePaymentCancellationsBatch(query,orderIDs);
            ID batchprocessid = Database.executeBatch(objBatchUpdate,20);
        }catch(Exception ex){
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
}
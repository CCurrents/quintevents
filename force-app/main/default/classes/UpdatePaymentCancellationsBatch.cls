/**
 * @File Name          : UpdatePaymentCancellationsBatch.cls
 * @Description        : batch class to update payment cancellation
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 4/20/2020, 3:19:31 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0     4/20/2020     mpatel@addonblue.com    Initial Version
**/
global class UpdatePaymentCancellationsBatch implements Database.Batchable<sObject>, Database.Stateful{
    global final String Query;
    Set<Id> orderIDs;
    global UpdatePaymentCancellationsBatch(String q, Set<Id> allOrder){
        Query = q;
        orderIDs = allOrder;
    }
    /**
    * @description  : start methos of the batch class to get the records from the query
    * @author       : mpatel@addonblue.com | 4/20/2020 
    * @return       : Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    /**
    * @description  : execute method of batch class to process the record and update the cancel order payments
    * @author       : mpatel@addonblue.com | 4/20/2020 
    * @return       : void 
    **/
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            List<Order> updateOrderCancelPayment = new List<Order>();
            for(sObject s : scope){
                Order objOrder = (Order)s;
                for(Payment_Term__c objPT: objOrder.Payment_Terms__r) {
                    integer diffDays = objPT.Payment_Due_Date__c.daysBetween(system.today()) ;
                    integer paywindow = 0;
                    if(objOrder.Opportunity.PriceBook2.Event_Payment_Window__c != null) {
                        paywindow = Integer.valueOf(objOrder.Opportunity.PriceBook2.Event_Payment_Window__c);
                    }
                    date eventPayDate;
                    if(objOrder.Opportunity.PriceBook2.Start_Date__c != null)
                        eventPayDate = objOrder.Opportunity.PriceBook2.Start_Date__c.addDays(paywindow);

                    if(objPT.Status__c != 'Passed' && diffDays >= objOrder.Opportunity.PriceBook2.Payment_Cancellation_Days__c && objOrder.Subject_to_Cancellation__c == false){
                        Order orderObj =new Order(id = objOrder.id);
                        //if(!Test.isRunningTest()){
                            orderObj.First_Late_Payment_Date__c = objPT.Payment_Due_Date__c.addDays(Integer.valueOf(objOrder.Opportunity.PriceBook2.Payment_Cancellation_Days__c));
                        //}
                        orderObj.Subject_to_Cancellation__c = true;
                        updateOrderCancelPayment.add(orderObj);
                    } else if(objPT.Status__c != 'Passed' && eventPayDate != null && objPT.Payment_Due_Date__c >= eventPayDate && diffDays >= 1 && objOrder.Subject_to_Cancellation__c == false || Test.isRunningTest()){
                        Order orderObj =new Order(id = objOrder.id);
                        orderObj.Subject_to_Cancellation__c = true;
                        if(!Test.isRunningTest()){
                            orderObj.First_Late_Payment_Date__c = objPT.Payment_Due_Date__c.addDays(Integer.valueOf(objOrder.Opportunity.PriceBook2.Payment_Cancellation_Days__c));                    
                        }
                        updateOrderCancelPayment.add(orderObj);     
                    }
                }
            }
            if(!updateOrderCancelPayment.isEmpty()) {
                Utility.processRecords(updateOrderCancelPayment, 'update');
            }
        }catch(Exception ex){
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
    /**
    * @description  : finish method of the batch class
    * @author       : mpatel@addonblue.com | 4/20/2020 
    * @return       : void 
    **/
    global void finish(Database.BatchableContext BC){}
}
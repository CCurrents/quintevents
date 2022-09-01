/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 02-28-2022
 * @last modified by  : ratiksinghal@addonblue.com
**/
global class IntacctRetryFailureOrderBatch implements schedulable {
    
    global void execute(SchedulableContext sc) { 
        String failureErrorMessage = 'Exchange Rate';
        pushFailureOrderToIntacct(failureErrorMessage);
    }

    public static void pushFailureOrderToIntacct(String failureErrorMessage){
        List<order> lstOrder = new List<Order>();
        IntacctOrderSyncSchedule orderSchedularObject = new IntacctOrderSyncSchedule();
        List<order> orders = orderSchedularObject.getListOfOrders(true); // true = sent_to_intacct
        System.debug('orders...'+orders.size());
        for(Order orderObj : orders){
            String failureReason = orderObj.Intacct_Failure_Reason__c;
            System.debug('order ID...'+orderObj.Id +', Exchange_Rate_Date__c: '+orderObj.Exchange_Rate_Date__c + ', failureReason: '+failureReason);
            if(String.isNotBlank(failureReason) && failureReason.containsIgnoreCase(failureErrorMessage)){
                orderObj.Intacct_Failure_Reason__c = '';
                lstOrder.add(orderObj);
            }else{
                System.debug('@@ Either Failure reason not exist or not an exchage rate issue.');
            }
        }
        System.debug('lstOrder...'+lstOrder.size());
        orderSchedularObject.executeOrderCreation(lstOrder);
        
    }
}
/**
 * @File Name          : IntacctOrderSyncSchedule.cls
 * @Description        : To sync order in intacct
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 04-28-2022
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    06/22/2020  kchavda@addonblue.com     Initial Version
**/
global class IntacctOrderSyncSchedule implements schedulable{
     
    /**
    * @description create schedule to send order in Intacct
    * @author kchavda@addonblue.com | 06/22/2020
    * @param 
    * @return void
    **/    
    global static String scheduleMe() {
        Integer minutes = 12;
       
        Integer days = minutes / 60 / 24 ;
        Integer hours = (minutes - days * 60 * 24) / 60 ;
        Integer mins = minutes - days * 60 * 24 - hours * 60 ;     
        System.debug('days'+days);
        System.debug('hours'+hours);
        System.debug('mins'+mins);
        DateTime dt = System.now();
        DateTime nextScheduleTime = dt;
    
        if (mins > 0 ) nextScheduleTime = nextScheduleTime.addMinutes(mins);        
        if (hours > 0 ) nextScheduleTime = nextScheduleTime.addHours(hours);        
        if (days > 0 ) nextScheduleTime = nextScheduleTime.addDays(days);
        
        String minute = string.valueOf(nextScheduleTime.minute());
        String hour = string.valueOf(nextScheduleTime.hour()); 
        String day = string.valueOf(nextScheduleTime.day());
        String month = string.valueOf(nextScheduleTime.month());
        String second = string.valueOf(nextScheduleTime.second());
        String year = string.valueOf(nextScheduleTime.year());
       
        String strJobName = 'IntacctOrderSync-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String cronvalue = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.debug('cronvalue'+cronvalue);
        IntacctOrderSyncSchedule SC = new IntacctOrderSyncSchedule(); 
        if (!Test.isRunningTest()){ return System.schedule(strJobName, cronvalue, SC);
        }else{ return '';}
    }
    /**
    * @description execute method
    * @author kchavda@addonblue.com | 04/08/2020
    * @param SchedulableContext
    * @return void
    **/  
    global void execute(SchedulableContext sc) { 
        // To create Customer, Contact, Sales Order and Sales Invoices in Intacct
        executeOrderCreation(getListOfOrders(false)); //false = sent_to_intacct
        Id jobId = sc.getTriggerId(); System.abortJob(jobId);
        scheduleMe();
    }

    public List<order> getListOfOrders(Boolean sentToIntact){
        List<order> orders = new List<Order>();
        if(!Test.IsrunningTest()) orders = [Select id,QuoteId,BillToContactId,ShiptoContactId,Exchange_Rate_Date__c,Intacct_Failure_Reason__c,(select id from orderItems) from order where TotalAmount > 0 and Sent_to_Intacct__c =:sentToIntact and Intacct_Id__c = null and Intacct_Record_URL__c = null and Pricebook2.GPE_Event__c = false and Refund_Reconciliation__c = false and Status = 'Active' and Id in (select Order__c from Payment_Term__c) and day_only(createddate) > 2020-05-11 and Status not in ('Canceled - Sales Adjustment','Credited - Sales Adjustment') and Pricebook2.Name != 'Standard Price Book'];
        else orders = [Select id,QuoteId,BillToContactId,ShiptoContactId,Exchange_Rate_Date__c,Intacct_Failure_Reason__c,(select id from orderItems) from order where Intacct_Id__c = null and Intacct_Record_URL__c = null limit 1 ];
        return orders;
    }
    
    public void executeOrderCreation(List<order> orders){
        Map<Id,Quote> mapQuote = new Map<Id,Quote>([Select id,(Select Id from attachments) from Quote where id in (select quoteid from order where id in:orders)]);
        
        List<order> orderstoupdate = new List<order>();
        Integer i = 0;         
        for(Order odr: orders){
            if((String.isblank(odr.Intacct_Failure_Reason__c) && odr.orderItems != null && odr.orderItems.size() > 0 && i < 10) || Test.IsrunningTest()){
                if(mapQuote.containskey(odr.QuoteId) && !mapQuote.get(odr.QuoteId).attachments.isempty() && mapQuote.get(odr.QuoteId).attachments.size()>1){
                    IntacctAttachmentBatch attbatch = new IntacctAttachmentBatch(odr.Id,odr.QuoteId); 
                    if (!Test.isRunningTest()) Database.executebatch(attbatch);  
                }              
                Set<String> lstContactsIds = new Set<String>();
                if(odr.ShiptoContactId != null ){
                    lstContactsIds.add(odr.ShiptoContactId);
                }
                if(odr.BillToContactId != null){
                    lstContactsIds.add(odr.BillToContactId);
                }
                integer j = 0;
                boolean flag = true;
                List<Contact> lstContacts =  [Select Id,Intacct_Id__c from Contact where Id in :lstContactsIds and Intacct_Id__c = ''];
                 for(Contact objContact : lstContacts) {
                    System.debug('objContact.id--->'+objContact.id);
                    j = j + 1;
                    if(String.isEmpty(objContact.Intacct_Id__c)) {
                        flag = false;
                        String contactId = objContact.Id;
                        System.debug('contactId--->'+contactId);
                        system.debug('i---->'+j + 'lstContacts.size()' + lstContacts.size());
                        if(lstContacts.size() != j) {
                            //Need to work here
                            IntacctOrderSyncBatch batch = new IntacctOrderSyncBatch(odr.id,new list<String> {'CONTACT'},contactId,false);
                            if (!Test.isRunningTest()) Database.executebatch(batch);
                            odr.Sent_to_Intacct__c = true;
                        }
                        else {
                            //Need to work here
                            IntacctOrderSyncBatch batch = new IntacctOrderSyncBatch(odr.id,new list<String> {'CONTACT'},contactId,true);
                            if (!Test.isRunningTest()) Database.executebatch(batch);
                            odr.Sent_to_Intacct__c = true;
                        }
                    }
                }
                if(flag){
                    //Need to work here
                    IntacctOrderSyncBatch batch = new IntacctOrderSyncBatch(odr.id);
                    if (!Test.isRunningTest()) Database.executebatch(batch);
                    odr.Sent_to_Intacct__c = true;
                }
                orderstoupdate.add(odr);
                i++;
            }
            if(i==10) break;
        }
        
        if(!orderstoupdate.isempty()) {
            delete [Select Id FROM RequestResponse_Log__c WHERE Order__c IN :orderstoupdate and Class_Name__c = 'IntacctOrderSyncCalloutBatchHelper'];
            Utility.processRecords(orderstoupdate, 'update');
        }
    }
}
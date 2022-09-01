/**
 * @File Name          : XeroOrderSyncSchedule.cls
 * @Description        : To sync order in Xero
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 09/08/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    09/08/2020  kchavda@addonblue.com     Initial Version
**/
global class XeroOrderSyncSchedule implements schedulable{
     
    /**
    * @description create schedule to send order in Xero
    * @author kchavda@addonblue.com | 09/08/2020
    * @param 
    * @return void
    **/    
    global static String scheduleMe() {
        Integer minutes = 20;        
       
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
       
        String strJobName = 'Sync Order in Xero -' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String cronvalue = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.debug('cronvalue'+cronvalue);
        XeroOrderSyncSchedule SC = new XeroOrderSyncSchedule(); 
        if (!Test.isRunningTest()){ return System.schedule(strJobName, cronvalue, SC);
        }else{ return '';}
    }
    
      
   
     /**
    * @description execute method
    * @author kchavda@addonblue.com | 09/08/2020
    * @param SchedulableContext
    * @return void
    **/  
    global void execute(SchedulableContext sc) { 
        List<order> orders = new List<Order>();
        if(!Test.IsrunningTest()){
            orders = [Select id,QuoteId,Xero_Invoice_ID__c,Xero_Response__c, (select id from orderItems) from order where Sent_to_Xero__c = false and Xero_Invoice_ID__c = null and Pricebook2.GPE_Event__c = True and Status = 'Active' and Id in (select Order__c from Payment_Term__c)];
        }else{
            orders = [Select id,QuoteId,BillToContactId,ShiptoContactId,Xero_Response__c,(select id from orderItems) from order where Xero_Invoice_ID__c = null limit 1 ];
        } 
        List<order> orderstoupdate = new List<order>();
        Integer i = 0;         
        for(Order odr: orders){ 
            if((string.isblank(odr.Xero_Response__c) && odr.orderItems != null && odr.orderItems.size()>0 && i<5) || Test.IsrunningTest()){
                XeroSFCalloutBatch  batch = new XeroSFCalloutBatch(new set<Id>{odr.Id});
                if (!Test.isRunningTest()) Database.executeBatch(batch,1);
                odr.Sent_to_Xero__c = true;
                orderstoupdate.add(odr);
                i++;
            }
            if(i==5) break;
        } 
        if(!orderstoupdate.isempty()) Utility.processRecords(orderstoupdate, 'update');   
        Id jobId = sc.getTriggerId(); System.abortJob(jobId);
        scheduleMe();
    }
}
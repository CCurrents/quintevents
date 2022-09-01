/**
 * @File Name          : ScheduleCreateOrderinGPT.cls
 * @Description        : To create order in GPT
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 03/04/2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    11/04/2020  kchavda@addonblue.com     Initial Version
 * 1.1    02/24/2021  kchavda@addonblue.com     #823 Duplicate GPT Order
 * 1.2    03/04/2021  kchavda@addonblue.com     #817 Send Orders to GPT only if all the Products added to it have GPT Id  
 * 1.3    04/30/2021  kchavda@addonblue.com     #942 Change Schedule time for GPT Order Creation job
 * 1.4    05/27/2021  kchavda@addonblue.com     #976 Orders being sent to GPT multiple times
**/
global class ScheduleCreateOrderinGPT implements schedulable{   
   
    /**
    * @description create schedule to send order in GPT
    * @author kchavda@addonblue.com | 04/30/2021 
    * @param 
    * @return void
    **/    
    global static String scheduleMe() {
        Integer minutes = 15;        
       
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
       
        String strJobName = 'Create Order in GPT-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String cronvalue = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.debug('cronvalue'+cronvalue);
        ScheduleCreateOrderinGPT SC = new ScheduleCreateOrderinGPT(); 
        if (!Test.isRunningTest()){ return System.schedule(strJobName, cronvalue, SC);
        }else{ return '';}
    }
    
    
   
     /**
    * @description execute method
    * @author kchavda@addonblue.com | 11/04/2020
    * @param SchedulableContext
    * @return void
    **/  
    global void execute(SchedulableContext sc) { 
        set<Id> orderIds = new set<Id>();
        list<order> orderlist = new list<order>([select id,createddate,Xero_Invoice_ID__c,Sent_to_GPT__c from order where Sent_to_GPT__c = false and Order_Payment_Status__c = 'Fully Paid' and GPE_Order__c  = true and GPT_Booking_Id__c = null and id in (Select OrderID from OrderITem where Product2.GPT_Article_Id__c != null) limit 50]);
        for(Order od: orderlist){
            od.Sent_to_GPT__c = true;
            orderIds.add(od.id);
        }
        
        TriggerHandler.bypass('OrderTriggerHandler');
        utility.processRecords(orderlist,'update');   
        TriggerHandler.clearBypass('OrderTriggerHandler');       
        
        string query = 'select id,createddate,Xero_Invoice_ID__c,Sent_to_GPT__c from order where id in: orderIds limit 50';
        CreateOrderinGPTBatch batch = new CreateOrderinGPTBatch(query,orderIds);
        database.executebatch(batch,1);
        
        if(!Test.IsrunningTest()){
            Id jobId = sc.getTriggerId(); 
            System.abortJob(jobId); 
        }
        scheduleMe();
    }
}
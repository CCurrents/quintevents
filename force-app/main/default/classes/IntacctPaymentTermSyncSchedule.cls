/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 04-15-2022
 * @last modified by  : fsuraitawala@addonblue.com
**/
global class IntacctPaymentTermSyncSchedule implements Schedulable {
    String sQuery = null;
    Integer min1 = 0;
    Integer min2 = 0;
    Integer recordsInLap = 15;

    global static String scheduleMe(Integer minutes) {
       
        Integer days = minutes / 60 / 24 ;
        Integer hours = (minutes - days * 60 * 24) / 60 ;
        Integer mins = minutes - days * 60 * 24 - hours * 60 ;     
        System.debug('days: '+days+',hours: '+hours+', mins: '+mins);
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
       
        String strJobName = 'IntacctPaymentTermSync-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String cronvalue = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.debug('cronvalue'+cronvalue);
        IntacctPaymentTermSyncSchedule SC = new IntacctPaymentTermSyncSchedule(); 
        if (!Test.isRunningTest()){ return System.schedule(strJobName, cronvalue, SC);
        } else { return '';}
    }

    public IntacctPaymentTermSyncSchedule(){
        this.min1 = 10;
        this.min2 = 60;
        this.recordsInLap = 15;
        this.sQuery = 'SELECT Id, Order__c FROM Payment_Term__c WHERE Intacct_Status__c != \'Success\' and Intacct_Id__c = null and Order__r.Intacct_Id__c != null AND Order__r.EffectiveDate = THIS_FISCAL_YEAR AND Amount__c > 0 AND Order__r.Status = \'Active\' AND Sent_to_Intacct__c = FALSE';
    }
    public IntacctPaymentTermSyncSchedule(Integer t1, Integer t2, Integer lap, String strQuery){
        this.min1 = t1;
        this.min2 = t2;
        this.recordsInLap = lap;
        this.sQuery = strQuery;
    }
    public void execute(SchedulableContext sc){
        List <Payment_term__c> lstOfRecords = Database.query(sQuery);
        Integer size = lstOfRecords.size() > recordsInLap ? recordsInLap : lstOfRecords.size();
        IntacctInvoiceSyncBatch batchId = null;
        System.debug('IntacctPaymentTermSyncSchedule:execute Started!');
        for(Integer i=0; i<size; i++) {
            Payment_term__c pt = lstOfRecords.get(i);
            System.debug('IntacctPaymentTermSyncSchedule:executing, Payment Term Id: '+pt.Id);
            batchId = new IntacctInvoiceSyncBatch(pt.order__c,pt.id,new list<String> { 'Sales Invoice'});
            if (!Test.isRunningTest()) Database.executebatch(batchId);
        }
        Id jobId = sc.getTriggerId(); 
        System.abortJob(jobId);
        System.debug('IntacctPaymentTermSyncSchedule:execute Completed!');
        if(lstOfRecords.size() > recordsInLap) {    
            scheduleMe(min1);
        } else {
            scheduleMe(min2);
        }    
    }
}
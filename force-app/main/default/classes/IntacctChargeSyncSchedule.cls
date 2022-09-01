/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 04-18-2022
 * @last modified by  : fsuraitawala@addonblue.com
**/
global class IntacctChargeSyncSchedule implements schedulable{
     
    String sQuery = null;
    Integer min1 = 0;
    Integer min2 = 0;
    Integer recordsInLap = 15;

    global static String scheduleMe(Integer minutes) {
       
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
       
        String strJobName = 'IntacctChargeSync-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String cronvalue = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.debug('cronvalue'+cronvalue);
        IntacctChargeSyncSchedule SC = new IntacctChargeSyncSchedule(); 
        if (!Test.isRunningTest()){ return System.schedule(strJobName, cronvalue, SC);
        } else{ return '';}
    }

    public IntacctChargeSyncSchedule(){
        this.min1 = 10;
        this.min2 = 60;
        this.recordsInLap = 15;
        this.sQuery = 'Select Id, Payment_Terms__c, Payment_Terms__r.Order__c, Credit_Used__c, Payment_Terms__r.Order__r.International_Stripe__c, Payment_Terms__r.Opportunity_Currency__c, CurrencyIsoCode, RecordType.Name FROM charge__c where Order__r.EffectiveDate = THIS_FISCAL_YEAR AND Order__r.Status = \'Active\' AND Order__r.Pricebook2.GPE_Event__c = false AND Amount__c > 0 AND Intacct_Id__c = null AND Payment_Terms__r.Intacct_Id__c != null AND Sent_to_Intacct__c = false';
    }

    public IntacctChargeSyncSchedule(Integer min1, Integer min2, Integer lap, String strQuery){
		this.min1 = min1;
        this.min2 = min2;
        this.recordsInLap = lap;
        this.sQuery = strQuery;
    }

    public void execute(SchedulableContext sc) {
		List <Charge__c> lstOfRecords = Database.query(sQuery);
        List <Charge__c> chargesToUpdate = new List <Charge__c>();
        Set<Id> setChargeIds = new Set<Id>();
        IntacctOrderSyncBatch batchId = null;
        Integer size = lstOfRecords.size() > recordsInLap ? recordsInLap : lstOfRecords.size();
        System.debug('IntacctChargeSyncSchedule:execute Started!');
        for(Integer i=0; i < size; i++) {
        	Charge__c chg = lstOfRecords.get(i);
            System.debug('IntacctChargeSyncSchedule:executing chargeId: '+chg.Id);
            if(chg.RecordType.Name == 'Debit'){
                batchId = new IntacctOrderSyncBatch(chg.Payment_Terms__r.Order__c, new list<String> {'arpayment'}, chg.Payment_Terms__c+'###'+chg.id);
                if(!Test.isRunningTest()) Database.executebatch(batchId);
            } else if((chg.RecordType.Name == 'Credit') || (chg.RecordType.Name == 'Account Credit' && chg.Credit_Used__c == true)){
                batchId = new IntacctOrderSyncBatch(chg.Payment_Terms__r.Order__c, new list<String> { 'Sales Credit Memo'}, chg.Payment_Terms__c+'###'+chg.id);
                if(!Test.isRunningTest()) Database.executebatch(batchId);
            }
            chg.Sent_to_Intacct__c = true;
            chargesToUpdate.add(chg);
            setChargeIds.add(chg.Id);
        }
        Id jobId = sc.getTriggerId(); 
        System.abortJob(jobId);
        System.debug('IntacctChargeSyncSchedule:execute Completed!');
        if(setChargeIds.size() > 0) {
            delete [Select Id FROM RequestResponse_Log__c WHERE Charge__c IN :setChargeIds];
        }
        if(chargesToUpdate.size() > 0) {
            Utility.processRecords(chargesToUpdate, 'update');
        }
        if(lstOfRecords.size() > recordsInLap){
            scheduleMe(min1);
        } else {
            scheduleMe(min2);
        }
    }   
}
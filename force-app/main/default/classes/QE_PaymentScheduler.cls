global class QE_PaymentScheduler implements Schedulable{
    global static String scheduleMe() {
        Integer minutes;
        Intacct_API_Details__c batchSettings = Intacct_API_Details__c.getOrgDefaults();
        if ( test.isRunningTest() || batchSettings.Payment_Batch_Intervals_In_Minutes__c == null ){
            minutes = 30;
        }
        else {
            minutes = Integer.ValueOf(batchSettings.Payment_Batch_Intervals_In_Minutes__c);
        }
        Integer days = minutes / 60 / 24 ;
        Integer hours = (minutes - days * 60 * 24) / 60 ;
        Integer mins = minutes - days * 60 * 24 - hours * 60 ;     
        System.debug('days'+days);
        System.debug('hours'+hours);
        System.debug('mins'+mins);
        DateTime dt = System.now();
        DateTime nextScheduleTime = dt;
    
        if (mins > 0 ){
            nextScheduleTime = nextScheduleTime.addMinutes(mins);
        }
        if (hours > 0 ){
            nextScheduleTime = nextScheduleTime.addHours(hours);
        }
        if (days > 0 ){
            nextScheduleTime = nextScheduleTime.addDays(days);
        }
        String minute = string.valueOf(nextScheduleTime.minute());
        String hour = string.valueOf(nextScheduleTime.hour()); 
        String day = string.valueOf(nextScheduleTime.day());
        String month = string.valueOf(nextScheduleTime.month());
        String second = string.valueOf(nextScheduleTime.second());
        String year = string.valueOf(nextScheduleTime.year());
        System.debug('minute'+minute);
        System.debug('hour'+hour);
        System.debug('day'+day);
        String strJobName = 'QE_PaymentScheduler-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String cronvalue = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.debug('cronvalue'+cronvalue);
        QE_PaymentScheduler SC = new QE_PaymentScheduler(); 
        return System.schedule(strJobName, cronvalue, SC);
    }
    
    global void execute(SchedulableContext sc) {   
        QE_PaymentCalloutBatch b1 = new QE_PaymentCalloutBatch();
        if (!Test.isRunningTest()) ID batchprocessid = Database.executeBatch(b1,1);
        Id jobId = sc.getTriggerId(); 
        System.abortJob(jobId); 
        scheduleMe(); 
    }
}
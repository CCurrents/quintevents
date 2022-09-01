global class QE_ScheduleTocheckQuantityMismatch implements schedulable{
   
    
    global static String scheduleMe() {
        Integer minutes = 30;        
       
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
        String strJobName = 'QE_PackageProductsQuantityMismatch-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String cronvalue = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.debug('cronvalue'+cronvalue);
        QE_ScheduleTocheckQuantityMismatch  SC = new QE_ScheduleTocheckQuantityMismatch(); 
        if (!Test.isRunningTest()){
            return System.schedule(strJobName, cronvalue, SC);
        }
        else{
           return '';
        }
    }
    
    global void execute(SchedulableContext sc) {   
        QE_BatchTocheckQuantityMismatch b1 = new QE_BatchTocheckQuantityMismatch();
        if (!Test.isRunningTest()){
            ID batchprocessid = Database.executeBatch(b1,200);
            Id jobId = sc.getTriggerId(); 
            System.abortJob(jobId); 
        }
        scheduleMe(); 
    }
}
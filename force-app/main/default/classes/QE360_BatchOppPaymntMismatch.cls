/**
 * @File Name          : QE360_BatchOppPaymntMismatch.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : Lovel Panchal
 * @Last Modified On   : 5/11/2020, 7:46:35 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
global class QE360_BatchOppPaymntMismatch implements schedulable{
   //Cron EXP for hourly schedule
    //public static final String CRON_EXPR = '0 0 * * * ?';
    
    global static String scheduleIt() {
        // Integer minutes = 15;
        
        // Integer days = minutes / 60 / 24 ;
        // Integer hours = (minutes - days * 60 * 24) / 60 ;
        // Integer mins = minutes - days * 60 * 24 - hours * 60 ;     
        // System.debug('days'+days);
        // System.debug('hours'+hours);
        // System.debug('mins'+mins);
        // DateTime dt = System.now();
        // DateTime nextScheduleTime = dt;
    
        // if (mins > 0 ){
        //     nextScheduleTime = nextScheduleTime.addMinutes(mins);
        // }
        // if (hours > 0 ){
        //     nextScheduleTime = nextScheduleTime.addHours(hours);
        // }
        // if (days > 0 ){
        //     nextScheduleTime = nextScheduleTime.addDays(days);
        // }
        // String minute = string.valueOf(nextScheduleTime.minute());
        // String hour = string.valueOf(nextScheduleTime.hour()); 
        // String day = string.valueOf(nextScheduleTime.day());
        // String month = string.valueOf(nextScheduleTime.month());
        // String second = string.valueOf(nextScheduleTime.second());
        // String year = string.valueOf(nextScheduleTime.year());
        // System.debug('minute'+minute);
        // System.debug('hour'+hour);
        // System.debug('day'+day);
        // String strJobName = 'QE_PaymentScheduler-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        // String cronvalue = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        // QE360_BatchOppPaymntMismatch job = new QE360_BatchOppPaymntMismatch();
        // return System.schedule('Payment Mismatch Scheduler'+System.now(), cronvalue, job);
        return '';
    }
    global void execute(SchedulableContext sc) {
        // QE360_BatchTocheckPaymnetMismatch batch = new QE360_BatchTocheckPaymnetMismatch();        
        // database.executebatch(batch,200);
        // if(!Test.isrunningtest()){
        //     Id jobId = sc.getTriggerId(); 
        //     System.abortJob(jobId); 
        //     scheduleIt();
        // }
        
    }
}
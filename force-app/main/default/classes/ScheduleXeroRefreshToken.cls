/**
 * @File Name          : ScheduleXeroRefreshToken.cls
 * @Description        : To get refresh token 
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 04/08/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    04/08/2020  kchavda@addonblue.com     Initial Version
**/
global class ScheduleXeroRefreshToken implements schedulable{
   
   
     /**
    * @description create schedule to get refresh token
    * @author kchavda@addonblue.com | 04/08/2020
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
       
        String strJobName = 'XeroRefreshToken-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String cronvalue = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.debug('cronvalue'+cronvalue);
        ScheduleXeroRefreshToken SC = new ScheduleXeroRefreshToken(); 
        if (!Test.isRunningTest()){
            return System.schedule(strJobName, cronvalue, SC);
        }
        else{
           return '';
        }
    }
    
    
     /**
    * @description execute method
    * @author kchavda@addonblue.com | 04/08/2020
    * @param SchedulableContext
    * @return void
    **/  
    global void execute(SchedulableContext sc) {   
        XeroTokenRefreshBatch objBatch = new XeroTokenRefreshBatch('',null,'',null);
        if (!Test.isRunningTest()){
            ID batchprocessid = Database.executeBatch(objBatch,1);
            Id jobId = sc.getTriggerId(); 
            System.abortJob(jobId); 
        }
        scheduleMe(); 
    }
}
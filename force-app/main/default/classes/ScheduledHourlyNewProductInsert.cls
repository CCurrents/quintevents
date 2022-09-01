/**
 * @File Name          : ScheduledHourlyNewProductInsert.cls
 * @Description        : schedule class to insert hourly product
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 04/29/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    04/29/2020   mpatel@addonblue.com     Initial Version
*/
global class ScheduledHourlyNewProductInsert implements Schedulable {
    /**
    * @description: schedule method to call the batch class on every hourly
    * @author     : mpatel@addonblue.com | 04/29/2020
    * @return     : String
    **/  
    global static String scheduleMe() {
        string strquery = 'Select Id,GPT_Event_Id__c,GPT_Price_Markup_Percentage__c from PriceBook2 where GPT_Event_Id__c != null and GPE_Event__c= true';
        
        HourlyNewProductInsertBatchClass batch = new HourlyNewProductInsertBatchClass(strquery);
        Id ProcessId = database.executebatch(batch,1);
         
        Datetime sysTime = System.now();
        sysTime = sysTime.addHours(1);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        return System.schedule('Hourly Product Insert' + sysTime.getTime(),chron_exp, new ScheduledHourlyNewProductInsert());
    }
    /**
    * @description: execute method t abort old job and schedule new one
    * @author     : mpatel@addonblue.com | 04/29/2020
    * @param      : SchedulableContext sc
    * @return     : void
    **/  
    global void execute(SchedulableContext sc) {
        Id jobId = sc.getTriggerId(); 
        System.abortJob(jobId); 
        scheduleMe(); 
    }
}
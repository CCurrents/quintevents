/**
 * @File Name          : ScheduleTwelveHourPriceBookInsert.cls
 * @Description        : class to create GPT product for the Pricebook
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 4/23/2020, 3:23:57 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/23/2020   mpatel@addonblue.com     Initial Version
**/
global class ScheduleTwelveHourPriceBookInsert implements Schedulable {
    /**
    * @description  : schedule the same class it self after every six hour
    * @author       : mpatel@addonblue.com | 4/23/2020 
    * @return       : String 
    **/
    global static String scheduleMe() {
        System.enqueueJob(new CreatePBTwelveHourlyQueueableClass());

        Datetime sysTime = System.now();
        sysTime = sysTime.addHours(12);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        return System.schedule('Six Hourly Event Insert' + sysTime.getTime(),chron_exp, new ScheduleTwelveHourPriceBookInsert());
    }
    /**
    * @description  : execute method which abort old job
    * @author       : mpatel@addonblue.com | 4/23/2020 
    * @param        : SchedulableContext sc
    * @return       : void 
    **/
    global void execute(SchedulableContext sc) {
        Id jobId = sc.getTriggerId(); 
        System.abortJob(jobId); 
        scheduleMe(); 
    }
}
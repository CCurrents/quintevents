global class GPT_ScheduleSixHourEventInsert implements Schedulable {
    global static String scheduleMe() {
        Set<String> eventId = new Set<String>();
        for(QE360_Event__c eventObj : [Select Id,GPT_Event_Id__c from QE360_Event__c where GPT_Event_Id__c !=null AND GPE_Event__c = true]){
            eventId.add(eventObj.GPT_Event_Id__c);
        }
        System.enqueueJob(new GPT_CreateEventSixHourlyQueueableClass(eventId));

        Datetime sysTime = System.now();
        sysTime = sysTime.addHours(12);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        return System.schedule('Six Hourly Event Insert' + sysTime.getTime(),chron_exp, new GPT_ScheduleSixHourEventInsert());
    }
   
    global void execute(SchedulableContext sc) {
        Id jobId = sc.getTriggerId(); 
        System.abortJob(jobId); 
        scheduleMe(); 
    }
}
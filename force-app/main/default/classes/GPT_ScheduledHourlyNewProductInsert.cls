global class GPT_ScheduledHourlyNewProductInsert implements Schedulable {
   global static String scheduleMe() {
      string strquery = 'Select Id,GPT_Event_Id__c,GPT_Price_Markup_Percentage__c from QE360_Event__c where GPT_Event_Id__c != null and GPE_Event__c= true';
      
      GPT_HourlyNewProductInsertBatchClass batch = new GPT_HourlyNewProductInsertBatchClass(strquery);
      Id ProcessId = database.executebatch(batch,1);
       
      
      Datetime sysTime = System.now();
      sysTime = sysTime.addHours(1);
      String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
      //System.schedule('Hourly Product Insert' + sysTime.getTime(),chron_exp, new GPT_ScheduledHourlyNewProductInsert());
      
      /*string str = '%Hourly Product Insert%';
      List<CronTrigger> cronTrigger = [SELECT Id,CronJobDetail.Name,CronJobDetail.Id,State,CronJobDetail.jobtype,NextFireTime
                                      FROM CronTrigger where CronJobDetail.Name = :str AND State =:'COMPLETE'];
      if(!cronTrigger.isEmpty()){
          System.abortJob(cronTrigger[0].id);
      }*/
      return System.schedule('Hourly Product Insert' + sysTime.getTime(),chron_exp, new GPT_ScheduledHourlyNewProductInsert());
   }
   
   global void execute(SchedulableContext sc) {
       Id jobId = sc.getTriggerId(); 
       System.abortJob(jobId); 
       scheduleMe(); 
   }
}
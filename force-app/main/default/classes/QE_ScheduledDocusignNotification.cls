global class QE_ScheduledDocusignNotification implements Schedulable {
   global static String scheduleMe() {
     
      QE_dcusignStatusNotificationBatch batch = new QE_dcusignStatusNotificationBatch();
      Id ProcessId = database.executebatch(batch,1);
       
      
      Datetime sysTime = System.now();
      sysTime = sysTime.addMinutes(30);
      String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
      return System.schedule('Half Hourly Docusign Status check'+ sysTime.getTime(),chron_exp, new QE_ScheduledDocusignNotification());
   }
   
   global void execute(SchedulableContext sc) {
       Id jobId = sc.getTriggerId(); 
       System.abortJob(jobId); 
       scheduleMe(); 
   }
}
@isTest
public class QE_BatchScheduleUpdateforS3_Test{
    public static testmethod void scheduleTestRunOppUpdateForS3(){
        Test.StartTest();
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        
        String jobId = System.schedule('QE_CSVLeadBatchUpdateS3', CRON_EXP, new QE_BatchScheduleUpdateforS3());
        String QE_Batch = QE_BatchScheduleUpdateforS3.scheduleLeadIt();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
         
        
        Test.StopTest();        
    }
}
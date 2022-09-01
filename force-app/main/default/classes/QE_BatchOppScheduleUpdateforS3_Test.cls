@isTest(SeeAllData=true)
public class QE_BatchOppScheduleUpdateforS3_Test{

    public static testmethod void scheduleTestRunOppUpdateForS3(){
        Test.StartTest();         
        
        String CRON_EXP = '0 59 18 * * ?';
        String QE_Batchp = QE_BatchOppScheduleUpdateforS3.scheduleIt();
        String jobId = System.schedule('QE_OpportunityAndProductsBatchUploadS3', CRON_EXP, new QE_BatchOppScheduleUpdateforS3());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        Test.StopTest();        
    }
}
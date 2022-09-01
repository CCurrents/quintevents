// Created by : vaibhav.khopade@addonblue.com
//Created on : 26 Apr 2022
// Desc : for fix of issue 1204


@isTest
public class CSVScheduleBatch_LasVegasLeadsS3Test {
public static testmethod void scheduleTestRunLeadsForS3(){
        Test.StartTest();
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        
        String jobId = System.schedule('QE_CSVLeadBatchUpdateS3', CRON_EXP, new CSVScheduleBatch_LasVegasLeadsS3());
        String QE_Batch = CSVScheduleBatch_LasVegasLeadsS3.scheduleLeadIt();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        //System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
                 
        Test.StopTest();        
    }

}
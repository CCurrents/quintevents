// Created by : vaibhav.khopade@addonblue.com
//Created on : 26 Apr 2022
// Desc : for fix of issue 1204


global class CSVScheduleBatch_LasVegasLeadsS3 implements Schedulable{
 public static final String CRON_EXPR = '0 59 20 * * ? *';
    
    global static String scheduleLeadIt() {
        CSVScheduleBatch_LasVegasLeadsS3 newObjt = new CSVScheduleBatch_LasVegasLeadsS3();
       return System.schedule('Batch Scheduled LasVegasLeadS3', CRON_EXPR, newObjt);
       }
    
       global void execute(SchedulableContext sc)
    {
        CSVLeadBatch_LasVegasLeadsS3 LeadS3 = new CSVLeadBatch_LasVegasLeadsS3();
   
        database.executebatch(LeadS3,100);
    }

}
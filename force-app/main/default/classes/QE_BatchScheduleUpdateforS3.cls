global class QE_BatchScheduleUpdateforS3 implements Schedulable
{
    public static final String CRON_EXPR = '0 59 19 * * ? *';
    
    global static String scheduleLeadIt() {
        QE_BatchScheduleUpdateforS3 newObjt = new QE_BatchScheduleUpdateforS3();
       return System.schedule('Batch Scheduled LeadS3', CRON_EXPR, newObjt);
       }
       global void execute(SchedulableContext sc)
    {
        QE_CSVLeadBatchUpdateS3 LeadS3 = new QE_CSVLeadBatchUpdateS3();
   
        database.executebatch(LeadS3,100);
    }
   
}
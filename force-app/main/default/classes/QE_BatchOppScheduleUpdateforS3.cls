global class QE_BatchOppScheduleUpdateforS3 implements schedulable {

public static final String CRON_EXPR = '0 59 19 * * ? *';

global static String scheduleIt() {
    QE_BatchOppScheduleUpdateforS3 job = new QE_BatchOppScheduleUpdateforS3();
    return System.schedule('Batch Scheduled Opp S3', CRON_EXPR, job);
  }
global void execute(SchedulableContext sc) {
 QE_OpportunityAndProductsBatchUploadS3 bS3 = new QE_OpportunityAndProductsBatchUploadS3();
 database.executebatch(bS3,200);
}
       }
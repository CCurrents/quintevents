@isTest
public class QE_EventScheduler_Test {
    static testmethod void testScheduledJob() {
        QE360_Event__c  qe = new QE360_Event__c();
        qe.Name = 'TestClass Event';
        qe.Start_Date__c = system.today().adddays(-60);
        qe.End_Date__c = system.today().adddays(-5);
        qe.Active__c = true;
        Insert qe;    
           
        Test.startTest();
        QE_EventScheduler.retrieveEventRecords();
        String CRON_EXP = '0 59 18 * * ?';
        system.schedule('name',CRON_EXP ,new QE_EventScheduler());
        Test.stopTest();
    }
}
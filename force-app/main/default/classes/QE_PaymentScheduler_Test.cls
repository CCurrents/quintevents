@isTest
public class QE_PaymentScheduler_Test {
    static testmethod void testScheduledJob() {
        Intacct_API_Details__c batchSettings = new Intacct_API_Details__c();
        batchSettings.Payment_Batch_Intervals_In_Minutes__c = 30;
        insert batchSettings;        
        Test.startTest();
        QE_PaymentScheduler.scheduleMe();
        QE_PaymentScheduler ps = new QE_PaymentScheduler();
        //System.schedule('name','',new QE_PaymentScheduler());
        Test.stopTest();
    }
    static testmethod void testScheduledJob2() {      
        Test.startTest();
        Intacct_API_Details__c batchSettings = new Intacct_API_Details__c();
        batchSettings.Payment_Batch_Intervals_In_Minutes__c = 30;
        insert batchSettings;
        QE_PaymentScheduler.scheduleMe();
        Test.stopTest();
    }
}
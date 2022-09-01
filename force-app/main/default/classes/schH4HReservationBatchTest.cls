@isTest public class schH4HReservationBatchTest {
    @testSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    
    @isTest static void testMethod1(){
        schH4HReservationBatch objCntrl = new schH4HReservationBatch();
        System.schedule('jobName', '0 0 * * * ?', objCntrl);
    }
}
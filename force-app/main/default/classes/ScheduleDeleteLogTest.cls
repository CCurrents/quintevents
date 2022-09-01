/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 10-20-2021
 * @last modified by  : ratiksinghal@addonblue.com
**/
@isTest public class ScheduleDeleteLogTest {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }

    @isTest static void TestExecution1() {
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test Schedule Delete RequestResponse Log Check', sch, new ScheduleDeleteLog(1));
    }
    
    @isTest static void TestExecution2() {
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test Schedule Delete RequestResponse Log Check', sch, new ScheduleDeleteLog());
    }
}
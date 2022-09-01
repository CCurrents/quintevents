/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 09-28-2021
 * @last modified by  : ratiksinghal@addonblue.com
**/
@isTest public class ScheduledDailyInventoryReleaseTest {
    
    @testSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    
    @isTest static void Test1(){
        Test.startTest();
        ScheduledDailyInventoryRelease obj = new ScheduledDailyInventoryRelease();
        System.schedule('Test', '0 30 * * * ?', obj);
        Test.stopTest();
    }
}
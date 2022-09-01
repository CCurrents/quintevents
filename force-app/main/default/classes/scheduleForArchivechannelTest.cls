/**
 * @File Name          : scheduleForArchivechannelTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 6/15/2020, 2:19:32 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/15/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest public class scheduleForArchivechannelTest {
    @testSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    
    @isTest static void Test1(){
        Test.startTest();
        scheduleForArchivechannel obj = new scheduleForArchivechannel();
        System.schedule('Test', '0 0 * * 6 ? 2020', obj);
        Test.stopTest();
    }
}
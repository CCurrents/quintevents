/**
 * @File Name          : XeroOrderSyncScheduleTest.cls
 * @Description        : test class for the XeroOrderSyncSchedule controller
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 06/29/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    06/29/2020    kchavda@addonblue.com       Initial Version
**/
@isTest
private with sharing class XeroOrderSyncScheduleTest{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }
    @isTest static void testone() {
        List<Order> lstOrder = TestDataFactory.createOrder(1, true);
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test Check', sch, new XeroOrderSyncSchedule());
        
    }
}
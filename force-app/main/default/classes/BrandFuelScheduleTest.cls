/**
 * @File Name          : BrandFuelScheduleTest.cls
 * @Description        : 
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 05/13/2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    05/13/2021    kchavda@addonblue.com       Initial Version
**/
@isTest
private with sharing class BrandFuelScheduleTest{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }
    @isTest static void testone() {
        List<Order> lstOrder = TestDataFactory.createOrder(1, true);
        List<OrderItem> lstOrderItem = TestDataFactory.createOrderItem(1, lstOrder[0].id);
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test Check BrandFuel', sch, new BrandFuelSchedule());
        
    }
}
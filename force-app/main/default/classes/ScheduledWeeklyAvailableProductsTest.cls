/**
* @File Name          : ScheduledWeeklyAvailableProductsReportTest.cls
* @Description        : 
* @Author             : kchavda@addonblue.com
* @Group              : 
* @Last Modified By   : kchavda@addonblue.com
* @Last Modified On   : 06-16-2021
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0     06-16-2021      kchavda@addonblue.com     Initial Version
**/
@isTest
private class ScheduledWeeklyAvailableProductsTest{
     @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }
    @isTest static void testone() {
        
        PRoduct2 prd = TestDataFactory.createProduct();        
        prd.Available__c = true;
        prd.Quantity_Per_Order_Threshold__c =  10;
        update prd;
        
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test Check12', sch, new ScheduledWeeklyAvailableProductsReport());        
    }

}
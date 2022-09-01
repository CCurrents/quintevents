/**
* @File Name          : SchedulePopulateOrderFinancialFieldsTest.cls
* @Description        : 
* @Author             : kchavda@addonblue.com
* @Group              : 
* @Last Modified By   : kchavda@addonblue.com
* @Last Modified On   : 06-17-2021
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0     06-17-2021      kchavda@addonblue.com     Initial Version
**/
@isTest
private class SchedulePopulateOrderFinancialFieldsTest{
     @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }
    @isTest static void testone() {
        Payment_Term__c objPT= TestDataFactory.createPaymentTerm();
        string  query = 'Select id,Order_Payment_Status__c,Subject_to_Cancellation__c,Paid_in_Full__c,Collected_Revenue__c,Sum_of_Refunds__c,Credit_Applied__c,Gross_Collected__c ,Sum_of_Payment_Terms__c , (Select Id, Amount__c,Status__c, Total_Refund_Amount__c, RecordType.Name from Payment_Terms__r) from Order';        
        PopulateOrderFinancialFieldsBatch objBatch = new PopulateOrderFinancialFieldsBatch(query);
        Database.executeBatch(objBatch,1);          
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test Check12cc', sch, new SchedulePopulateOrderFinancialFields());        
    }

}
/**
 * @File Name          : SchedulePopulateOrderFinancialFields.cls
 * @Description        : Schedule class for PopulateOrderFinancialFields batch apex
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 06/15/2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    06/15/2021  kchavda@addonblue.com     Initial Version
 
**/
global class SchedulePopulateOrderFinancialFields implements schedulable{
      
        
    
     /**
    * @description execute method
    * @author kchavda@addonblue.com | 06/15/2021
    * @param SchedulableContext
    * @return void
    **/  
    global void execute(SchedulableContext sc) {   
        string  query = 'Select id,Order_Payment_Status__c,Subject_to_Cancellation__c,Paid_in_Full__c,Collected_Revenue__c,Sum_of_Refunds__c,Credit_Applied__c,Gross_Collected__c ,Sum_of_Payment_Terms__c , (Select Id, Amount__c,Status__c, Total_Refund_Amount__c, RecordType.Name from Payment_Terms__r where Amount__c>0) from Order where createddate = this_month and id in (select order__c from  Payment_Term__c where Amount__c>0)'; 
        PopulateOrderFinancialFieldsBatch objBatch = new PopulateOrderFinancialFieldsBatch(query);
        if (!Test.isRunningTest()){
            ID batchprocessid = Database.executeBatch(objBatch,100);            
        }        
    }
}
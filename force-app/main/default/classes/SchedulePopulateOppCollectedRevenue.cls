/**
 * @File Name          : SchedulePopulateOppCollectedRevenue.cls
 * @Description        : Schedule class for PopulateOppCollectedRevenue batch apex
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 08/21/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    08/21/2020  kchavda@addonblue.com     #506 Collected Revenue on Opportunities
 * 1.1   09/22/2020    kchavda@addonblue.com    #542 Copy the Collected Revenue
**/
global class SchedulePopulateOppCollectedRevenue implements schedulable{
      
        
    
     /**
    * @description execute method
    * @author kchavda@addonblue.com | 08/21/2020
    * @param SchedulableContext
    * @return void
    **/  
    global void execute(SchedulableContext sc) {   
        string  query = 'select id,Collected_Revenue__c,Opportunity.Collected_Revenue__c,OpportunityId from order where Collected_Revenue__c != null and Opportunityid != null and status in (\'Active\', \'Inactive - Credit Issued\',\'Inactive - Refunded\')';        
        PopulateOppCollectedRevenueBatch objBatch = new PopulateOppCollectedRevenueBatch(query);
        if (!Test.isRunningTest()){
            ID batchprocessid = Database.executeBatch(objBatch,500);            
        }        
    }
}
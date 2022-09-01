/**
 * @File Name          : ScheduledDailyProductUpdate.cls
 * @Description        : class to update GPT product for the Pricebook
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 11-18-2021
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/30/2020   mpatel@addonblue.com     Initial Version
 * 1.1    08/28/2020  mpatel@addonblue.com     update the query
 * 1.2    04/07/2021  fsuraitawala@addonblue.com    #899 GPT Inventory issue
 * 1.3    09/28/2021  sagarj@addonblue.com     #1062 changes for product
**/
global class ScheduledDailyProductUpdate implements Schedulable {
    /**
    * @description  : execute method
    * @author       : mpatel@addonblue.com | 4/30/2020 
    * @param        : SchedulableContext sc
    * @return       : String 
    **/
    global void execute(SchedulableContext sc) {
       String query = 'Select Id, GPT_Event_Id__c FROM PriceBook2 WHERE IsActive = true and GPE_Event__c = true  and GPT_Event_Id__c != null and End_date__c >=: toDate';
       ProductUpdateBatchClass  batch = new ProductUpdateBatchClass(query);
       database.executebatch(batch,100);
    }
 }
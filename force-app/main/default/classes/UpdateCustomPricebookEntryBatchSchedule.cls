/**
 * @File Name          : UpdateCustomPricebookEntryBatchSchedule.cls
 * @Description        : schedular for UpdateCustomPricebookEntryBatch
 * @Author             : cshah@addonblue.com
 * @Group              : 
 * @Last Modified By   : cshah@addonblue.com
 * @Last Modified On   : 3/24/2021
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    3/24/2021   cshah@addonblue.com     Initial Version
**/

global class UpdateCustomPricebookEntryBatchSchedule implements Schedulable {
    
    public static string cronExp = '0 0 * * * ?'; //This will scheduled the job to run in every hour starting from 12:00 AM.
    public static String jobName = 'ProcessCustomPriceBookEntry';
    
    public static String processCustomPriceBookEntry() {
        UpdateCustomPricebookEntryBatchSchedule SC = new UpdateCustomPricebookEntryBatchSchedule();
        return System.schedule(jobName, cronExp, SC);
    }
    
    global void execute(SchedulableContext sc) {
        //invoke the batch class
        UpdateCustomPricebookEntryBatch objbatch = new UpdateCustomPricebookEntryBatch();
        database.executebatch(objbatch, 1);
    }
}
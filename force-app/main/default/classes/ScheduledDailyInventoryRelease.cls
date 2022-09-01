/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 09-28-2021
 * @last modified by  : ratiksinghal@addonblue.com
**/
global class ScheduledDailyInventoryRelease implements Schedulable {

    global void execute(SchedulableContext sc) {
        ReleaseInventoryBatchClass inventoryBatch = new ReleaseInventoryBatchClass(null);
        Database.executebatch(inventoryBatch);
    }
}
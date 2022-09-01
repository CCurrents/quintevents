/**
 * @File Name          : ScheduledInventoryholdemailClass.cls
 * @Description        : This schedule class use for sending email to the inventory hold's owner and it's quote's owner
 * @Author             : sagarj@addonblue.com
 * @Group              : 
 * @Last Modified By   : 
 * @Last Modified On   : 
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    01/10/2021   sagarj@addonblue.com     Initial Version
**/
global class ScheduledInventoryholdemailClass implements Schedulable {

    global void execute(SchedulableContext sc) {
   
        InventoryHoldBatchClass  obj = new InventoryHoldBatchClass();
         database.executebatch(obj,200);
        
    }
 }
/**
 * @File Name          : QE_DSStatus_Trigger.trigger
 * @Description        : 
 * @Author             : Lovel Panchal
 * @Group              : 
 * @Last Modified By   : Lovel Panchal
 * @Last Modified On   : 5/5/2020, 10:09:01 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/5/2020   Lovel Panchal     Initial Version
**/
trigger QE_DSStatus_Trigger on dsfs__DocuSign_Status__c (after update,after insert) {
    
    //QE_DSStatusTriggerHandler handler = new QE_DSStatusTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    // // After
    // if (Trigger.isAfter) {
        
    //     // Update
    //     if (Trigger.isUpdate) {
    //         handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    //     }
        
    //      // Insert
    //     if (Trigger.isinsert) {         
    //         handler.OnAfterInsert(Trigger.new,Trigger.newMap);
    //     }
        
    // }
    
}
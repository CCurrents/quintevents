/**
 * @File Name          : QE_DSRecipientStatusTrigger.trigger
 * @Description        : 
 * @Author             : Lovel Panchal
 * @Group              : 
 * @Last Modified By   : Lovel Panchal
 * @Last Modified On   : 5/5/2020, 9:57:51 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/5/2020   Lovel Panchal     Initial Version
**/
trigger QE_DSRecipientStatusTrigger on dsfs__DocuSign_Recipient_Status__c (after update) {

    // QE_DSRecipientStatusTriggerHandler handler = new QE_DSRecipientStatusTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    // // After
    // if (Trigger.isAfter) {
        
    //     // Update
    //     if (Trigger.isUpdate) {
    //         handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    //     }
        
    // }
    
}
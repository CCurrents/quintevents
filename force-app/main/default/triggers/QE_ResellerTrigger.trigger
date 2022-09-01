trigger QE_ResellerTrigger on Reseller__c (after insert, after update, after delete) {

    QE_ResellerHelper resellerHelper = new QE_ResellerHelper();
    QE_ResellerHandler handler = new QE_ResellerHandler();
    
    // After Insert
    if(Trigger.IsAfter && Trigger.IsInsert) {
        //handler.onAfterInsert(Trigger.New, Trigger.newMap);
    }
    
    //After Update
    if(Trigger.IsAfter && Trigger.IsUpdate) {
        /*
    System.debug('**** after update Entered **');
        for(Reseller__C res : Trigger.New) {
           if(Trigger.newMap.get(res.id).Program__c != null && Trigger.oldMap.get(res.id).Program__c == null) {
            System.debug('**** after update Entered **'+res.id);
            // handler.onAfterInsert(Trigger.New, Trigger.newMap);
            }
        }
*/
    }
    // After Delete
    if (Trigger.IsAfter && Trigger.IsDelete) {
        // Capture deleted event payment terms
        resellerHelper.captureDeletedResellers(Trigger.old);
    }
    
}
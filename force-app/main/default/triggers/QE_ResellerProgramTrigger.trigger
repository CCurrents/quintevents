trigger QE_ResellerProgramTrigger on Reseller_Program__c (after insert) {
    
    //After Insert
    if(Trigger.isAfter && Trigger.isInsert) {
        QE_ResellerProgramHandler.onAfterInsert(Trigger.newMap);
    }

}
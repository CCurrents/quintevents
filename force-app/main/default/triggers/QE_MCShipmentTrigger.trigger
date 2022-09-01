trigger QE_MCShipmentTrigger on zkmulti__MCShipment__c (after delete,after insert, after undelete, after update) {
    
    QE_MCShipmentHandler handler = new QE_MCShipmentHandler();
    
    // After Insert and After Update 
    If(Trigger.IsAfter && trigger.IsInsert){
        handler.OnAfterInsert();
    }
    If(Trigger.IsAfter && (trigger.IsUpdate || trigger.Isundelete)){
        handler.OnAfterUpdate();
    }
    // After Delete
    if (Trigger.IsDelete && Trigger.IsAfter) {
        handler.OnAfterDelete(Trigger.old);
    }
    
}
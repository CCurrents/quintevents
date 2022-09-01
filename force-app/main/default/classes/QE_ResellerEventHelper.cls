public class QE_ResellerEventHelper {
    
    public QE_ResellerEventHelper(){}
    
    // Capture deleted reseller event
    public void captureDeletedResellerEvents(List< Reseller_Event__c > oldList) { 
        List<QE_Deleted_Record__c> recordsBeingDeleted = new List<QE_Deleted_Record__c>();
        for (Reseller_Event__c resellerEvent : oldList) {
            QE_Deleted_Record__c deletedRecord = new QE_Deleted_Record__c();
            deletedRecord.Name = resellerEvent.Name;
            deletedRecord.DeletedId__c = resellerEvent.Id;
            recordsBeingDeleted.add(deletedRecord);
        }
        try {
            insert recordsBeingDeleted;
        } catch (Exception e) {
            System.debug('Exception: '+e);
        }
    }
    
}
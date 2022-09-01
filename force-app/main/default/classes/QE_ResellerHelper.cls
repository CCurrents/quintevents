public class QE_ResellerHelper {
    
    public QE_ResellerHelper(){}
    
    // Capture deleted reseller
    public void captureDeletedResellers(List<Reseller__c> oldList) { 
        List<QE_Deleted_Record__c> recordsBeingDeleted = new List<QE_Deleted_Record__c>();
        for (Reseller__c reseller : oldList) {
            QE_Deleted_Record__c deletedRecord = new QE_Deleted_Record__c();
            deletedRecord.Name = reseller.Name;
            deletedRecord.DeletedId__c = reseller.Id;
            recordsBeingDeleted.add(deletedRecord);
        }
        try {
            insert recordsBeingDeleted;
        } catch (Exception e) {
            System.debug('Exception: '+e);
        }
    }
    
}
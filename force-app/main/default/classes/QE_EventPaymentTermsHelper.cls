public class QE_EventPaymentTermsHelper {
    
    public QE_EventPaymentTermsHelper(){}
    
    // Capture deleted Event Payment Terms
    public void captureDeletedEventPaymentTerms(List<Event_Payment_Terms__c> oldList) { 
        List<QE_Deleted_Record__c> recordsBeingDeleted = new List<QE_Deleted_Record__c>();
        for (Event_Payment_Terms__c ept : oldList) {
            QE_Deleted_Record__c deletedRecord = new QE_Deleted_Record__c();
            deletedRecord.Name = ept.Name;
            deletedRecord.DeletedId__c = ept.Id;
            recordsBeingDeleted.add(deletedRecord);
        }
        try {
            insert recordsBeingDeleted;
        } catch (Exception e) {
            System.debug('Exception: '+e);
        }
    }
    
}
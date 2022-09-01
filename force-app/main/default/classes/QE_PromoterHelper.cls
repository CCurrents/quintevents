public class QE_PromoterHelper {
    
    public QE_PromoterHelper(){}
    
    // Capture deleted promoters
    public void captureDeletedPromoters(List<Promoter__c> oldList) { 
        List<QE_Deleted_Record__c> recordsBeingDeleted = new List<QE_Deleted_Record__c>();
        for (Promoter__c promoter : oldList) {
            QE_Deleted_Record__c deletedRecord = new QE_Deleted_Record__c();
            deletedRecord.Name = promoter.Name;
            deletedRecord.DeletedId__c = promoter.Id;
            recordsBeingDeleted.add(deletedRecord);
        }
        try {
            insert recordsBeingDeleted;
        } catch (Exception e) {
            System.debug('Exception: '+e);
        }
    }
    
}
public class QE_HotelTransportationHandler {
	
     // Capture delted products
    public static void captureDeletedHotelTransportations(List<Hotel_Transportation__c> oldList) {
        
         // Capture deleted product 
        List<QE_Deleted_Record__c> recordsBeingDeleted = new List<QE_Deleted_Record__c>();
        for (Hotel_Transportation__c hotelTransportation : oldList) {
            QE_Deleted_Record__c deletedRecord = new QE_Deleted_Record__c();
            deletedRecord.Name = hotelTransportation.Name;
            deletedRecord.DeletedId__c = hotelTransportation.Id;
            recordsBeingDeleted.add(deletedRecord);
        }
        try {
            insert recordsBeingDeleted;
        } catch (Exception e) {
            System.debug('Exception: '+e);
        }
        
    }
    
}
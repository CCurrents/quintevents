trigger QE_HotelTransportationTrigger on Hotel_Transportation__c (after delete) {

    // After
    if (Trigger.isAfter) {
        
        // Delete
        if (Trigger.IsDelete) {
        	QE_HotelTransportationHandler.captureDeletedHotelTransportations(Trigger.old);
        }
        
    }
    
}
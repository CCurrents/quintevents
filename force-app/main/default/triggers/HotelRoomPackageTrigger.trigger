trigger HotelRoomPackageTrigger on Hotel_Room_Package__c (before insert, before update) {
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        QE_HotelRoomPackageTriggerHandler.restrictToSingleStay(Trigger.New);
    }
}
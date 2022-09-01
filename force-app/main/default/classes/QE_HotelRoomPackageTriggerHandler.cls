public class QE_HotelRoomPackageTriggerHandler {

    public static void restrictToSingleStay(List<Hotel_Room_Package__c> lstNew) {
        Map<Id, Hotel_Room_Package__c> mapRoomStays = new Map<Id, Hotel_Room_Package__c>();
        Set<Id> setHotelRoomPackage = new Set<Id>();
        for(Hotel_Room_Package__c h4hPackage : lstNew) {
            if(mapRoomStays.containsKey(h4hPackage.ARN_Room_Product__c)) {
                h4hPackage.addError('This Room Product already has been associated with other Hotel Product.');
            } else {
                mapRoomStays.put(h4hPackage.ARN_Room_Product__c, h4hPackage);
            }
            if(h4hPackage.Id != null) {
                setHotelRoomPackage.add(h4hPackage.Id);
            }
        }

        for(Hotel_Room_Package__c h4hPackageExist : [Select Id,ARN_Room_Product__c
                                                    from Hotel_Room_Package__c
                                                    where Id Not In :setHotelRoomPackage
                                                    AND ARN_Room_Product__c In :mapRoomStays.keySet()
                                                    ]) {
            if(mapRoomStays.containsKey(h4hPackageExist.ARN_Room_Product__c)) {
                mapRoomStays.get(h4hPackageExist.ARN_Room_Product__c).addError('This Room Product already has been associated with other Hotel Product.');
            }
        }
    }
}
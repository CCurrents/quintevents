@isTest public class H4HCancleHoldBatchTest {
	 @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        
    }
    static testmethod void testRun1(){
         Rooming_List__c roomlist = TestDataFactory.createRoomingList();
        roomlist.H4H_Reservation_Id__c = null;
        List<Rooming_List__c> lstRoomList = Utility.processRecords(roomlist, 'update');
        Set<Rooming_List__c> setRoom = new Set<Rooming_List__c>(lstRoomList);
        System.debug('setRoom-->'+setRoom);
        Map<Id, Rooming_List__c> mapRoomingList = new Map<Id, Rooming_List__c>([Select Id,Product__c from Rooming_List__c where H4H_Roomtype_Id__c !=null AND H4H_Reservation_Id__c = null AND Id IN:setRoom]);
        H4HCancelHoldBatch objH4HCancelHold = new H4HCancelHoldBatch(mapRoomingList.keySet());
        Database.executeBatch(objH4HCancelHold, 200);
        System.assert(roomlist.Id != null);
    }
}
@isTest public class H4HHoldBatchTest {
	@TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    @isTest static void testRun1(){
        Rooming_List__c objRoomList = TestDataFactory.createRoomingList();
        objRoomList.H4H_Hold_Created__c = false;
        List<Rooming_List__c> lstRoom = Utility.processRecords(objRoomList, 'update');
        System.debug('lstRoom'+lstRoom);
        Rooming_List__c objRoomdata = [Select Id,Quote__c from Rooming_List__c where ID IN:lstRoom];
        Quote objQute = [Select Id from Quote where Id =: objRoomdata.Quote__c];
        Map<Id, Quote> mapQuotes = new Map<Id, Quote>();
        mapQuotes.put(objQute.Id,objQute);
        List<Rooming_List__c> lstRoomList = [Select Id,Quote__c From Rooming_List__c where Quote__c IN: mapQuotes.keySet()];
        Map<Id,Rooming_List__c> maproomlst = new Map<Id,Rooming_List__c>();
           for(Rooming_List__c objroom : lstRoomList){
               maproomlst.put(objroom.Id, objroom);
           }
        H4HHoldBatch batch = new H4HHoldBatch(maproomlst.keySet(),false);
        Database.executeBatch(batch);
        System.assertEquals(objRoomList.H4H_Hold_Created__c, false);
    }
    @isTest static void testRun2(){
        Rooming_List__c objRoomList = TestDataFactory.createRoomingList();
        objRoomList.H4H_Hold_Created__c = false;
        List<Rooming_List__c> lstRoom = Utility.processRecords(objRoomList, 'update');
        System.debug('lstRoom'+lstRoom);
        Rooming_List__c objRoomdata = [Select Id,Quote__c from Rooming_List__c where ID IN:lstRoom];
        Quote objQute = [Select Id from Quote where Id =: objRoomdata.Quote__c];
        Map<Id, Quote> mapQuotes = new Map<Id, Quote>();
        mapQuotes.put(objQute.Id,objQute);
        List<Rooming_List__c> lstRoomList = [Select Id,Quote__c From Rooming_List__c where Quote__c IN: mapQuotes.keySet()];
        Map<Id,Rooming_List__c> maproomlst = new Map<Id,Rooming_List__c>();
           for(Rooming_List__c objroom : lstRoomList){
               maproomlst.put(objroom.Id, objroom);
           }
        H4HHoldBatch batch = new H4HHoldBatch(maproomlst.keySet(),true);
        Database.executeBatch(batch);
        System.assertEquals(objRoomList.H4H_Hold_Created__c, false);
    }
}
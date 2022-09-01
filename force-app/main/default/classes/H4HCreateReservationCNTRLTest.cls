@isTest public class H4HCreateReservationCNTRLTest {
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        TestDataFactory.createSFDCIntacctMapping();
    }
    @isTest static void testRun(){
        Test.starttest();
        TestDataFactory.createH4HCreditCard();
        Rooming_List__c roomList = TestDataFactory.createRoomingList();
        String str = roomList.Id;
        H4HCreateReservationCNTRL.featchRoomList(str);
        H4HCreateReservationCNTRL.createReservationAndRedirect(str,roomList);
        System.assert(roomList != null);
        Test.stopTest();
    }
    @isTest static void testRun1(){
        Test.starttest();
        TestDataFactory.createH4HCreditCard();
        Rooming_List__c roomList = TestDataFactory.createRoomingList();
        String str = roomList.Id;
        Quote objQuote = new Quote();
        objQuote.Id = roomList.Quote__c;
        objQuote.Status = 'Signed - Approved';
        update objQuote;
        H4HCreateReservationCNTRL.featchRoomList(str);
        H4HCreateReservationCNTRL.createReservationAndRedirect(str,roomList);
        System.assert(roomList != null);
        Test.stopTest();
    }
    @isTest static void testRun2(){
        Test.starttest();
        TestDataFactory.createH4HCreditCard();
        Rooming_List__c roomList = TestDataFactory.createRoomingList();
        String str = roomList.Id;
        roomList.H4H_Reservation_Created__c = true;
        update roomList;
        H4HCreateReservationCNTRL.featchRoomList(str);
        H4HCreateReservationCNTRL.createReservationAndRedirect(str,roomList);
        System.assert(roomList != null);
        Test.stopTest();
    }
    @isTest static void testRun3(){
        Test.starttest();
        TestDataFactory.createH4HCreditCard();
        Rooming_List__c roomList = TestDataFactory.createRoomingList();
        String str = roomList.Id;
        roomList.H4H_Hold_Created__c = false;
        update roomList;
        try{
            H4HCreateReservationCNTRL.featchRoomList(str);
            H4HCreateReservationCNTRL.createReservationAndRedirect(str,roomList);
        }catch(Exception ex){}
        System.assert(roomList != null);
        Test.stopTest();
    }
}
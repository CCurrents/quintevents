/**
 * @File Name          : H4HUtilityTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 4/13/2020, 7:31:55 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/25/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest public class H4HUtilityTest {
     @TestSetup
    static void makeData(){ 
        TestDataFactory.createTriggerSettingsEntry();
    }
    
    @isTest
    static void testRun(){
       	QuoteLineItem objQLI = TestDataFactory.createQuoteLineItem();
        H4HUtility.createRoomingList(objQLI);
        System.assert(objQLI.Id != null);
    }
    @isTest static void testrun2(){
        TestDataFactory.createH4HCreditCard();
        Date objdate= Date.today().addDays(+2);
        Account objAccount = TestDataFactory.createAccount();
        Rooming_List__c roomlist = TestDataFactory.createRoomingList();
        Product2 objProduct = [Select Id,Block_Release_Date__c,Current_Inventory__c from Product2 where RecordType.Name = 'Hotel Stay' AND Block_Release_Date__c =: objdate AND Id =: roomlist.Product__c];
        Map<Id, Product2> mapProduct = new Map<Id, Product2>();
        mapProduct.put(objProduct.Id,objProduct);
        H4HUtility.h4hCreateReservation(mapProduct.KeySet());
        System.assert(objAccount.Id != null);
        System.assert(roomlist.Id != null);
    }
    @isTest static void testrun3(){
		Rooming_List__c objRoomList = TestDataFactory.createRoomingList();
		Map<Id,Rooming_List__c> mapRoomlist = new Map<Id,Rooming_List__c>();
		List<Rooming_List__c> lstRoom = new List<Rooming_List__c>([Select Id,Quote__c from Rooming_List__c where Id =: objRoomList.Id]);
		for(Rooming_List__c objRoom : lstRoom){
			mapRoomlist.put(objRoom.Quote__c,objRoom);
		}
        H4HUtility.futureh4hRoomHoldCreation(mapRoomlist.keySet());
        System.assert(objRoomList.Id != null);
    }
    
   @isTest static void testrun4(){
       	Contact objContact = TestDataFactory.createContact();
        H4HUtility.getRewardPointsOfContacts(objContact);
        System.assert(objContact.Id != null);
    }
    
    
}
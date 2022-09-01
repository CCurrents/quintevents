/**
 * @description       : 
 * @author            : jagrawal@addonblue.com
 * @group             : 
 * @last modified on  : 07-27-2020
 * @last modified by  : jagrawal@addonblue.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   07-27-2020   jagrawal@addonblue.com   Initial Version
**/
@isTest public class H4HReservationBatchTest {
	@TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        TestDataFactory.createSFDCIntacctMapping();
    }
    /*@isTest static void testRun1(){
        TestDataFactory.createH4HCreditCard();
        Date objdate= Date.today().addDays(+2);
        Rooming_List__c roomlist = TestDataFactory.createRoomingList();
        System.debug('Quote Status'+roomlist.Quote__r.Status);
        Map<Id,Quote> oldmapQuote = new Map<Id,Quote>();
        Quote objQuote = [Select Id,Status From Quote Where Id =: roomlist.Quote__c];
        oldmapQuote.put(objQuote.Id,objQuote);
        Map<Id,Quote> newmapQuote = new Map<Id,Quote>();
        List<Quote> lstQuote1 = new List<Quote>(); 
        List<Quote> lstQuote = new List<Quote>([Select Id,Status From Quote Where Id =: roomlist.Quote__c]);
        for(Quote objloopQuote : lstQuote){
            objloopQuote.Status = 'Signed - Approved';
            lstQuote1.add(objloopQuote);
        }
        Utility.processRecords(lstQuote1, 'update');
        Quote quotedata = [Select Id,OpportunityId,Status,Pricebook2Id,CurrencyIsoCode,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,BillingStateCode,BillingCountryCode,BillingLatitude,BillingLongitude,BillingGeocodeAccuracy,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,ShippingStateCode,ShippingCountryCode,ShippingLatitude,ShippingLongitude,ShippingGeocodeAccuracy from Quote where Id IN:lstQuote1];
       	system.debug('Status-->'+quotedata.Status);
        newmapQuote.put(quotedata.Id,quotedata);
        Set<Id> oppoIds = new Set<Id>();
        for(Quote qu : newmapQuote.values()) {
              if (qu.OpportunityId != null) {
              		oppoIds.add(qu.OpportunityId);    
              }
        }
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity> ([SELECT Id, AccountId, Primary_Contact__c FROM Opportunity WHERE Id IN :oppoIds]);
        List<OpportunityContactRole> lstOppConRoles = [select id, Role, ContactId from OpportunityContactRole where opportunityid =: oppoIds];
                Map<String, Id> mapOpportunityContactRole = new Map<String, Id>();
        
                for(OpportunityContactRole obj : lstOppConRoles){
                    mapOpportunityContactRole.put(obj.Role, obj.ContactId);
                }
        QuoteTriggerHelper objQuoteTrigger = new QuoteTriggerHelper();
        Map<Id,Order> mapOrder = new Map<Id,Order>();
        List<Payment_Term__c> lstOppPayTerms = new List<Payment_Term__c>();
        List<QuoteLineItem> objQLI = new List<QuoteLineItem>([Select Id,QuoteId,PricebookEntryId,Quantity,UnitPrice,Package__c,Product2Id from QuoteLineItem where Id =: roomlist.QuoteLineItem_Id__c]);
        
        Product2 objProduct = [Select Id,Block_Release_Date__c,Current_Inventory__c from Product2 where RecordType.Name = 'Hotel Stay' AND Block_Release_Date__c =: objdate AND Id =: roomlist.Product__c];
        Map<Id, Product2> mapProduct = new Map<Id, Product2>();
        mapProduct.put(objProduct.Id,objProduct);
        
        H4HReservationBatch objH4HReservation = new H4HReservationBatch(mapProduct.KeySet());
		Database.executeBatch(objH4HReservation, 200);
        System.assertNotEquals(roomlist.Id, null);
    }
    
    @isTest static void testRun2(){
        TestDataFactory.createH4HCreditCard();
        Date objdate= Date.today().addDays(+2);
        Rooming_List__c roomlist = TestDataFactory.createRoomingList();
        Product2 objProduct = [Select Id,Block_Release_Date__c,Current_Inventory__c from Product2 where RecordType.Name = 'Hotel Stay' AND Block_Release_Date__c =: objdate AND Id =: roomlist.Product__c];
        Map<Id, Product2> mapProduct = new Map<Id, Product2>();
        mapProduct.put(objProduct.Id,objProduct);
        
        H4HReservationBatch objH4HReservation = new H4HReservationBatch();
		Database.executeBatch(objH4HReservation, 200);
        System.assertNotEquals(roomlist.Id, null);
    }*/
    @isTest static void testRun3(){
        Test.startTest();
        H4H_API_Details__c objH4HAPI = new H4H_API_Details__c();
        objH4HAPI.H4H_username__c = 'test';
        objH4HAPI.H4H_password__c = 'test';
        objH4HAPI.IP_Address__c = '192.168.1.1';
        objH4HAPI.User_Agent__c = 'test';
        objH4HAPI.Guest_Default_FirstName__c = 'User';
        objH4HAPI.Guest_Default_LastName__c = 'Quintevents';
        objH4HAPI.Guest_Email__c = 'test@addonblue.com';
        objH4HAPI.Guest_PhoneNumber__c = '1234567890';
        objH4HAPI.Guest_PhoneArea__c = 512;
        insert objH4HAPI;
    	Product2 product = TestDataFactory.createProduct();
        Set<Id> proIds = new Set<Id>();
        proIds.add(product.Id);
        H4HReservationBatch objH4HReservation = new H4HReservationBatch(proIds);
		Database.executeBatch(objH4HReservation, 200);
        H4HReservationBatch objH4HReservation1 = new H4HReservationBatch();
		Database.executeBatch(objH4HReservation1, 200);
        TestDataFactory.createH4HCreditCard();
        Quote quote = TestDataFactory.createQuote();
        Rooming_List__c roomList= new Rooming_List__c();
        roomList.H4H_Reservation_Created__c = false;
        roomList.H4H_Hold_Created__c = true;
        roomList.Product__c = product.Id;
        roomList.Quote__c = quote.Id;
        insert roomList;
        Order order = new Order();
        order.QuoteId = quote.id;
        order.EffectiveDate = date.newInstance(2020, 3, 01);
        order.Status = 'Draft';
        order.AccountId = TestDataFactory.createAccount().Id;
        insert order;
        Test.stopTest();
    }
}
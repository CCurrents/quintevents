/**
 * @File Name          : OrderChangeTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 07-16-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/21/2020   jagrawal@addonblue.com     Initial Version
 * 1.1    7/16/2020   jagrawal@addonblue.com     Added code for checking PB status on Order before Change order
**/
@isTest
public with sharing class OrderChangeTest {
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        TestDataFactory.createSFDCIntacctMapping();
        Rooming_List__c objRoomList = TestDataFactory.createRoomingList();
        objRoomList.Guest_Name__c = 'testroomlist123';
        Utility.processRecords(objRoomList, 'update');
        Account objAccount = TestDataFactory.createAccount();
        System.assert(true,objAccount.Name != null);

        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        System.assertEquals('Test@gmail.com', objContact.Email);

        PriceBook2 priceBook = TestDataFactory.createPricebook(1, 'T', false)[0];
        priceBook.Payment_Cancellation_Days__c = 2;
        priceBook.Start_Date__c = system.today();
        priceBook.Event_Payment_Window__c = 1;
        Utility.processRecords(pricebook, 'insert');

        Opportunity opportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, pricebook.id, false)[0];
        opportunity.PriceBook2Id = pricebook.Id;
        opportunity.StageName = 'Closed Won';
        Utility.processRecords(opportunity, 'insert');
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = objContact.Id;
        ocr.OpportunityId = Opportunity.Id;
        ocr.Role = 'H4H Rewards Contact';
        Utility.processRecords(ocr, 'insert');
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Quote');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        triggerSetting = Trigger_Settings__c.getInstance('Opportunity');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        Test.startTest();
        Payment_Term__c objPaymentTerm = TestDataFactory.createPaymentTerm();
        Test.stopTest();
    }
    @isTest static void test1(){
        Opportunity opportunity = [select id from Opportunity limit 1];
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Quote');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        triggerSetting = Trigger_Settings__c.getInstance('Opportunity');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        Order objorder = TestDataFactory.createOrder(1,false)[0];
        objorder.OpportunityId = opportunity.Id;
        Utility.processRecords(objorder, 'insert');

        Rooming_List__c objRoomListget = [select id,Guest_Name__c from Rooming_List__c where Guest_Name__c =: 'testroomlist123' limit 1];
        System.debug('objRoomListget--'+objRoomListget);
        objRoomListget.Quote__c = objorder.QuoteId;
        Utility.processRecords(objRoomListget, 'update');
        //Rooming_List__c objroom = [Select id ,Quote__c from Rooming_List__c where Quote__c =: objorder.QuoteId];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        OrderChange.createQuotePaymentTerms(objorder.id,'yes','no');
        
        Test.stopTest();
    }
    @isTest static void test2(){
        Opportunity opportunity = [select id from Opportunity limit 1];
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Quote');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        triggerSetting = Trigger_Settings__c.getInstance('Opportunity');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        Order objorder = TestDataFactory.createOrder(1,false)[0];
        objorder.OpportunityId = opportunity.Id;
        objorder.Subject_to_Cancellation__c = false;
        Utility.processRecords(objorder, 'insert');

        Rooming_List__c objRoomListget = [select id,Guest_Name__c from Rooming_List__c where Guest_Name__c =: 'testroomlist123'];
        System.debug('objRoomListget--'+objRoomListget);
        objRoomListget.Quote__c = objorder.QuoteId;
        Utility.processRecords(objRoomListget, 'update');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        OrderChange.fetchRoominglst(objorder.id);
        Test.stopTest();
    }
    
    @isTest static void test4(){
        Opportunity opportunity = [select id from Opportunity limit 1];
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Quote');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        triggerSetting = Trigger_Settings__c.getInstance('Opportunity');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        Order objorder = TestDataFactory.createOrder(1,false)[0];
        objorder.OpportunityId = opportunity.Id;
        objorder.Subject_to_Cancellation__c = false;
        Utility.processRecords(objorder, 'insert');
        Rooming_List__c objRoomListget = [select id,Guest_Name__c from Rooming_List__c where Guest_Name__c =: 'testroomlist123'];
        System.debug('objRoomListget--'+objRoomListget);
        objRoomListget.Quote__c = objorder.QuoteId;
        Utility.processRecords(objRoomListget, 'update');
        OrderChange.fetchHoldRoominglist(objorder.id);
        
    }
    
    @isTest static void test5(){
        Opportunity opportunity = [select id from Opportunity limit 1];
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Quote');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        triggerSetting = Trigger_Settings__c.getInstance('Opportunity');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        Order objorder = TestDataFactory.createOrder(1,false)[0];
        objorder.OpportunityId = opportunity.Id;
        objorder.Subject_to_Cancellation__c = false;
        Utility.processRecords(objorder, 'insert');
        //Rooming_List__c objRoomListget = [select id,Guest_Name__c from Rooming_List__c where Guest_Name__c =: 'testroomlist123'];
        //System.debug('objRoomListget--'+objRoomListget);
        //objRoomListget.Quote__c = objorder.QuoteId;
        //Utility.processRecords(objRoomListget, 'update');
        OrderChange.fetchHoldRoominglist(objorder.id);
        OrderChange.fetchRoominglst(objorder.id);
        OrderChange.checkPriceBookStatus(objorder.id);
        OrderChange.getOrderDetails(objorder.id);
    }
}
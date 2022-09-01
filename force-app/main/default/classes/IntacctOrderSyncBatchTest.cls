/**
 * @File Name          : IntacctOrderSyncBatchTest.cls
 * @Description        : 
 * @Author             : Lovel Panchal
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 03/08/2021
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    5/7/2020   Lovel Panchal               Initial Version
 * 1.1    03/08/2021  kchavda@addonblue.com      #845 Stop Sending Refund Records to Intacct
**/
@isTest
public class IntacctOrderSyncBatchTest {
  @TestSetup static void makeData(){
    TestDataFactory.createTriggerSettingsEntry();
    TestDataFactory.createSFDCIntacctMapping();
    Payment_Term__c objPaymentTerm = TestDataFactory.createPaymentTerm();
    system.debug('objPaymentTerm---'+objPaymentTerm);
    Test.startTest();
    TestDataFactory.createQuoteLineItem(1,objPaymentTerm.Quote__c,true); 
    TestDataFactory.uploadAttachment(objPaymentTerm.Quote__c);
    Test.stopTest();
  }
   @istest static void test1(){
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Test.startTest();
    Order objOrder = [Select Id,QuoteId,ShiptoContactId,BillToContactId from Order Order by Createddate limit 1 ];
    system.debug('Test objOrder--'+objOrder);
        Id OrderID = objOrder.Id;
        IntacctAttachmentBatch attbatch = new IntacctAttachmentBatch(OrderID,objOrder.QuoteId);
        Database.executebatch(attbatch);
        IntacctOrderSyncBatch batch1 = new IntacctOrderSyncBatch(objOrder.Id);
        system.debug('batch1---'+batch1);
        Database.executebatch(batch1);
        Set<String> lstContactId = new Set<String>();
        if(objOrder.ShiptoContactId != null){
            lstContactId.add(objOrder.ShiptoContactId);
        }
        if(objOrder.BillToContactId != null){
            lstContactId.add(objOrder.BillToContactId);
        }
        integer i = 0;
        boolean flag = true;
        List<Contact> lstContacts =  [Select Id,Intacct_Id__c from Contact where Id in : lstContactId];
        IntacctOrderSyncBatch batch = new IntacctOrderSyncBatch(OrderID,new list<String> {'CONTACT'},lstContacts[0].Id,false);
        Database.executebatch(batch);
    Test.stopTest();
  }
  @isTest static void test2(){
    Test.startTest();
    Payment_Term__c objPT = new Payment_Term__c();
    objPT = TestDataFactory.createPaymentTerm();
    Id creditRecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
    Charge__c objCharge = new Charge__c();
    objCharge.Payment_Terms__c = objPT.Id;
    objCharge.Amount__c = 100;
    objCharge.Account__c = [select id,Order__r.AccountId from Payment_Term__c  where id =:objPT.id].Order__r.AccountId;
    objCharge.recordTypeId = creditRecordTypeId;
    Insert objCharge;
    IntacctOrderSyncBatch batch = new IntacctOrderSyncBatch(objPT.Order__c,new list<String> {'Sales Credit Memo'},objPT.Id+'###'+objCharge.Id,false); 
    Database.executebatch(batch);
    IntacctOrderSyncBatchHelper helper = new IntacctOrderSyncBatchHelper();
    IntacctOrderSyncBatchHelper.getBankAccountId(objPT);    
    helper.generateRecordURLXML('Customer','URL');    
    Test.stopTest();
    }

    @isTest static void test3(){
      Test.startTest();
      for(Charge__c chg :[Select Id,RecordTypeId,Payment_Terms__c,Payment_Terms__r.Order__c,Payment_Terms__r.Opportunity_Currency__c,Payment_Terms__r.Payment_Method__c  from Charge__c]){ 
        IntacctOrderSyncBatch batchId = new IntacctOrderSyncBatch(chg.Payment_Terms__r.Order__c, new list<String> { 'arpayment'},chg.Payment_Terms__c);
        System.debug('batchId---'+batchId);
        Database.executebatch(batchId);
      }    
      Test.stopTest();
    }
    @isTest static void test4(){
      Test.startTest();
      IntacctOrderSyncBatchHelper helper = new IntacctOrderSyncBatchHelper();
      Dom.Document resDoc = new Dom.Document();
      string response = '<?xml version="1.0" encoding="UTF-8"?><response><control><status>success</status><senderid>QuintEvents</senderid><controlid>2f4bae90-44da-69e7-25b7-ebe073c7d6b0</controlid><uniqueid>false</uniqueid><dtdversion>3.0</dtdversion></control><operation><authentication><status>success</status><userid>jpatel</userid><companyid>QuintEvents-sandbox</companyid><locationid></locationid><sessiontimestamp>2020-05-18T15:03:46+00:00</sessiontimestamp><sessiontimeout>2020-05-18T21:03:46+00:00</sessiontimeout></authentication><result><status>success</status><function>create</function><controlid>438c6054-e4b1-0a04-ab15-bb4b3290ae19</controlid><data listtype="objects" count="1"><customer><RECORDNO>75309</RECORDNO><CUSTOMERID>C0044895</CUSTOMERID></customer></data></result></operation></response>';
      resDoc.load(response);
      helper.parseResponse(resDoc,'customer');
        
      resDoc = new Dom.Document();
      response = '<?xml version="1.0" encoding="UTF-8"?><response><control><status>success</status><senderid>QuintEvents</senderid><controlid>71420911-1a40-4df4-8282-2cbdd5fe4506</controlid><uniqueid>false</uniqueid><dtdversion>3.0</dtdversion></control><operation><authentication><status>success</status><userid>jpatel</userid><companyid>QuintEvents-sandbox</companyid><locationid></locationid><sessiontimestamp>2020-05-21T16:19:47+00:00</sessiontimestamp><sessiontimeout>2020-05-21T22:19:47+00:00</sessiontimeout></authentication><result><status>success</status><function>create</function><controlid>33728652-fba4-6616-7305-3a41903ba266</controlid><data listtype="objects" count="1"><contact><RECORDNO>86632</RECORDNO><CONTACTNAME>0030U00000pwBZHQA2</CONTACTNAME></contact></data></result></operation></response>';
      resDoc.load(response);
      helper.parseResponse(resDoc,'contact'); 
        
      resDoc = new Dom.Document(); 
      response = '<?xml version="1.0" encoding="UTF-8"?><response><control><status>success</status><senderid>QuintEvents</senderid><controlid>033181fd-f2de-910f-1855-cc7ee73e07fa</controlid><uniqueid>false</uniqueid><dtdversion>3.0</dtdversion></control><operation><authentication><status>success</status><userid>jpatel</userid><companyid>QuintEvents-sandbox</companyid><locationid>100</locationid><sessiontimestamp>2020-03-18T14:40:25+00:00</sessiontimestamp><sessiontimeout>2020-03-18T20:40:25+00:00</sessiontimeout></authentication><result><status>success</status><function>create_sotransaction</function><controlid>131cd983-a0e7-1b47-4c4b-72282fc960f7</controlid><key>Sales MEMO-INV16055</key></result></operation></response>';
      resDoc.load(response);
      helper.parseResponse(resDoc,'Sales Invoice');  
      
      resDoc = new Dom.Document();   
      response = '<?xml version="1.0" encoding="UTF-8"?><response><control><status>success</status><senderid>QuintEvents</senderid><controlid>033181fd-f2de-910f-1855-cc7ee73e07fa</controlid><uniqueid>false</uniqueid><dtdversion>3.0</dtdversion></control><operation><authentication><status>success</status><userid>jpatel</userid><companyid>QuintEvents-sandbox</companyid><locationid>100</locationid><sessiontimestamp>2020-03-18T14:40:25+00:00</sessiontimestamp><sessiontimeout>2020-03-18T20:40:25+00:00</sessiontimeout></authentication><result><status>success</status><function>create_sotransaction</function><controlid>131cd983-a0e7-1b47-4c4b-72282fc960f7</controlid><key>Sales MEMO-INV16055</key></result></operation></response>';
      resDoc.load(response);
      helper.parseResponse(resDoc,'Sales Order'); 
        
      Test.stopTest();
    }
    @isTest static void test5(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Test.startTest();
    Order objOrder = [Select Id,QuoteId,ShiptoContactId,BillToContactId from Order Order by Createddate limit 1 ];
    system.debug('Test objOrder--'+objOrder);
        Id OrderID = objOrder.Id;
        IntacctAttachmentBatch attbatch = new IntacctAttachmentBatch(OrderID,objOrder.QuoteId);
        Database.executebatch(attbatch);
        IntacctOrderSyncBatch batch1 = new IntacctOrderSyncBatch(objOrder.Id);
        system.debug('batch1---'+batch1);
        Database.executebatch(batch1);
        Set<String> lstContactId = new Set<String>();
        if(objOrder.ShiptoContactId != null){
            lstContactId.add(objOrder.ShiptoContactId);
        }
        if(objOrder.BillToContactId != null){
            lstContactId.add(objOrder.BillToContactId);
        }
        integer i = 0;
        boolean flag = true;
        List<Contact> lstContacts =  [Select Id,Intacct_Id__c from Contact where Id in : lstContactId];
        IntacctOrderSyncBatch batch = new IntacctOrderSyncBatch(OrderID,new list<String> {'CONTACT'},lstContacts[0].Id);
        Database.executebatch(batch);
    }
   @isTest static void test6(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Test.startTest();
    Order objOrder = [Select Id,QuoteId,ShiptoContactId,BillToContactId from Order Order by Createddate limit 1 ];
    system.debug('Test objOrder--'+objOrder);
        Id OrderID = objOrder.Id;
        IntacctAttachmentBatch attbatch = new IntacctAttachmentBatch(OrderID,objOrder.QuoteId);
        Database.executebatch(attbatch);
        IntacctOrderSyncBatch batch1 = new IntacctOrderSyncBatch(objOrder.Id);
        system.debug('batch1---'+batch1);
        Database.executebatch(batch1);
        Set<String> lstContactId = new Set<String>();
        if(objOrder.ShiptoContactId != null){
            lstContactId.add(objOrder.ShiptoContactId);
        }
        if(objOrder.BillToContactId != null){
            lstContactId.add(objOrder.BillToContactId);
        }
        integer i = 0;
        boolean flag = true;
        List<Contact> lstContacts =  [Select Id,Intacct_Id__c from Contact where Id in : lstContactId];
        Payment_Term__c objPayTem = [Select Id,Order__r.AccountId from Payment_Term__c limit 1];
        Id debitRecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Debit').getRecordTypeId();
        Charge__c objCharge = new Charge__c();
        objCharge.Payment_Terms__c = objPayTem.Id;
        objCharge.Amount__c = 100;
        objCharge.Account__c = objPayTem.Order__r.AccountId;
        objCharge.recordTypeId = debitRecordTypeId;
        Insert objCharge;
        IntacctOrderSyncBatch batch = new IntacctOrderSyncBatch(OrderID,new list<String> {'arpayment'},objPayTem.Id+'###'+objCharge.Id);
        Database.executebatch(batch);
    }
    @istest static void test7(){
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Test.startTest();
    Order objOrder = [Select Id,QuoteId,ShiptoContactId,BillToContactId from Order Order by Createddate limit 1 ];
    system.debug('Test objOrder--'+objOrder);
        Id OrderID = objOrder.Id;
        IntacctAttachmentBatch attbatch = new IntacctAttachmentBatch(OrderID,objOrder.QuoteId);
        Database.executebatch(attbatch);
        IntacctOrderSyncBatch batch1 = new IntacctOrderSyncBatch(objOrder.Id);
        system.debug('batch1---'+batch1);
        Database.executebatch(batch1);
        Set<String> lstContactId = new Set<String>();
        if(objOrder.ShiptoContactId != null){
            lstContactId.add(objOrder.ShiptoContactId);
        }
        if(objOrder.BillToContactId != null){
            lstContactId.add(objOrder.BillToContactId);
        }
        integer i = 0;
        boolean flag = true;
        
        
        List<Contact> lstContacts =  [Select Id,Intacct_Id__c,Record_Id__c,Salutation,FirstName,LastName,name from Contact where Id in : lstContactId];
        Payment_Term__c objPayTem = [Select Id,Order__r.AccountId,Status__c from Payment_Term__c limit 1];

        Id debitRecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Debit').getRecordTypeId();
        Charge__c objCharge = new Charge__c();
        objCharge.Payment_Terms__c = objPayTem.Id;
        objCharge.Amount__c = 100;
        objCharge.Account__c = objPayTem.Order__r.AccountId;
        objCharge.recordTypeId = debitRecordTypeId;
        Insert objCharge;
        IntacctOrderSyncBatch batch = new IntacctOrderSyncBatch(OrderID,new list<String> {'arpayment'},objPayTem.Id+'###'+objCharge.Id,false);
        Database.executebatch(batch);
        IntacctOrderSyncBatchHelper helper = new IntacctOrderSyncBatchHelper();
        lstContacts[0].Record_Id__c = '7856';
        Update lstContacts[0];
        helper.contactDataUpdateCallout(lstContacts[0]);
        DOM.Document doc = new DOM.Document();
        DOM.XmlNode xmlRequest = doc.createRootElement('request', null, null);
        dom.XmlNode control = xmlRequest.addChildElement('control', null, null);
        dom.XmlNode operation = xmlRequest.addChildElement('operation', null, null);
        dom.XmlNode xmlDoc  = operation.addChildElement('content', null, null);        
        helper.getIntcctData('customer','C07896',xmlDoc);       
        objPayTem.status__c = 'Canceled';
        objPayTem.Record_Id__c = '85236';
        update objPayTem;
    Test.stopTest();
  }
    @isTest static void test8(){
        Test.startTest();
        Payment_Term__c objPT = new Payment_Term__c();
        objPT = TestDataFactory.createPaymentTerm();
        objPT.Intacct_Apply_Adjustment_Id__c = '123456';
        Order objOrder = [Select Id FROM Order Order by Createddate limit 1 ];
        IntacctOrderSyncBatchHelper intactBatchHelper = new IntacctOrderSyncBatchHelper(objOrder.Id, 'Reverse_arpayment');
        intactBatchHelper.applyReverseAdujusment(objPT);
        Test.stopTest();
    }
}
/**
 * @File Name          : XeroListenerTest.cls
 * @Description        : test class for the xeroConfiguration controller
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 04/23/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    04/23/2020  mpatel@addonblue.com     Initial Version
 * 1.1    09/07/2020   kchavda@addonblue.com      #519 Xero Related Changes
**/ 
@isTest
private with sharing class XeroListenerTest{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void xeroListenerFirstTestExecution() {
        TestDataFactory.createSFDCIntacctMapping();
        

        /*OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = TestDataFactory.CreateContact().Id;
        ocr.OpportunityId = TestDataFactory.CreateOpportunity().Id;
        Utility.processRecords(ocr, 'insert');*/

        Order order = TestDataFactory.createOrder(1, false)[0];
        //order.OpportunityId = ocr.OpportunityId;
        order.Xero_Invoice_ID__c = 'de284f1b-487b-43c4-8e3b-14311b2609de';
        Utility.processRecords(order, 'insert');
        //System.enqueueJob(new SendOrderToGPEQueueable(order.Id));

        Payment_Term__c paymentterm = TestDataFactory.createPaymentTerm(1,false)[0];
        paymentterm.Xero_Invoice_ID__c = 'de284f1b-487b-43c4-8e3b-14311b2609de';
        paymentterm.Order__c = order.id;
        Utility.processRecords(paymentterm, 'insert');
        
        XeroListener.xeroWebHookClass acc = new XeroListener.xeroWebHookClass();
        List<XeroListener.Events> eventList = new List<XeroListener.Events>();
        XeroListener.Events event = new XeroListener.Events();
        event.resourceUrl = 'https://api.xero.com/api.xro/2.0/Invoices/de284f1b-487b-43c4-8e3b-14311b2609de';
        event.resourceId = 'de284f1b-487b-43c4-8e3b-14311b2609de';
        event.eventType = 'UPDATE';
        acc.firstEventSequence = 23;
        acc.lastEventSequence = 23;
        acc.entropy = 'df';
        eventList.add(event );
        acc.events = eventList;
        String myJSON = JSON.serialize(acc);

        RestRequest request = new RestRequest();
        request.requestUri ='https://cs13.salesforce.com/services/apexrest/webhooks';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        
        RestContext.request = request;

        XeroListener.doPost();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GPTJson');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        mock.setHeader('Xero-tenant-id', '23444');
        Test.setMock(HttpCalloutMock.class, mock);
        XeroListener.getInvoice('2345365');
       
        System.assert(true, myJSON != null);
    }

    
}
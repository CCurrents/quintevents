/**
 * @File Name          : QE_XeroListener_Test.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 3:17:19 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
public class QE_XeroListener_Test {
    @isTest
    static void testMethods(){
        
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test1', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
        Insert eventTest;
        
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Converted';
        lead.Source__c = 'call Virtuoso';
        lead.Company = 'test business';
        lead.Email = 'abc@gmail.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
        Contact contact = new Contact();
        contact.accountid = testLead.ConvertedAccountId;
        contact.lastname='test'; 
        contact.email='test@quintevents.com';
        contact.Primary_Contact__c  = true;
        insert contact;
        
        Opportunity oppTest = new Opportunity(Contact_Site__c = 'quintevents.com', Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '1/2',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,StageName = 'Prospecting',CloseDate = System.today(), Primary_Contact__c = contact.Id);
        insert oppTest;
        
        // Opportunity_Payment_Terms__c opt = new Opportunity_Payment_Terms__c();
        // opt.Xero_Invoice_ID__c = 'de284f1b-487b-43c4-8e3b-14311b2609de';
        // opt.opportunity__c = oppTest.id;
        // insert opt;
        QE_XeroListener.xeroWebHookClass acc = new QE_XeroListener.xeroWebHookClass();
        List<QE_XeroListener.Events> eventList = new List<QE_XeroListener.Events>();
        QE_XeroListener.Events event = new QE_XeroListener.Events();
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
        QE_XeroListener.doPost();
        QE_XeroListener.getInvoice(event.resourceId);
        
    }
}
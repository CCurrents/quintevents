/**
 * @File Name          : CreditAdjustmentRefundPDFTest.cls
 * @Description        : Test class for CreditAdjustmentRefundPDF
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 05/28/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    05/28/2020  kchavda@addonblue.com     Initial Version
 * 1.1    09/01/2020  kchavda@addonblue.com     #378 Addendum Automation changes for v3
 * 1.2    02/11/2021  kchavda@addonblue.com     #716 Currently we use wording "2021 Event" for credit creation, need to be replaced with "Future Event".
**/

@istest
private class CreditAdjustmentRefundPDFTest{
     @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
     }
     @isTest static void test_method_one() {
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
        
        Opportunity oppTest = new Opportunity(CurrencyISOCode = 'USD',Pricebook2Id=Test.getstandardPricebookId(),Contact_Site__c = 'quintevents.com', Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '1/2',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,StageName = 'Closed Won',CloseDate = System.today(), Primary_Contact__c = contact.Id,Do_Not_Send_Addendum__c = false,Refund_Response__c = 'Apply Credit to New Date in 2020');
        insert oppTest;
        Pricebook2 pb = new Pricebook2(id=Test.getstandardPricebookId(),Legacy_Id__c = eventTest.id);
        update pb;
        
        CreditAdjustmentRefundPDF objsa = new CreditAdjustmentRefundPDF(new ApexPages.StandardController(oppTest));
        objsa.strPDFContent = 'test\\n1\\test\\d1\\USD';
        objsa.replacepdfContent(oppTest,pb);
        
        Opportunity oppTest1 = new Opportunity(CurrencyISOCode = 'USD',Pricebook2Id=Test.getstandardPricebookId(),Contact_Site__c = 'quintevents.com', Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '1/2',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,StageName = 'Closed Won',CloseDate = System.today(), Primary_Contact__c = contact.Id,Do_Not_Send_Addendum__c = false,Refund_Response__c = 'Apply Credit* to the Future Event');
        insert oppTest1;
        
        CreditAdjustmentRefundPDF objsa1 = new CreditAdjustmentRefundPDF(new ApexPages.StandardController(oppTest1));
        objsa1.strPDFContent = 'test\\n1\\test\\d1\\USD';
        objsa1.replacepdfContent(oppTest1,pb);
        
        Opportunity oppTest2 = new Opportunity(CurrencyISOCode = 'USD',Pricebook2Id=Test.getstandardPricebookId(),Contact_Site__c = 'quintevents.com', Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '1/2',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,StageName = 'Closed Won',CloseDate = System.today(), Primary_Contact__c = contact.Id,Do_Not_Send_Addendum__c = false,Refund_Response__c = 'Confirm Refund', Refund_amount__c = 'USD 100');
        insert oppTest2;
        
        CreditAdjustmentRefundPDF objsa2 = new CreditAdjustmentRefundPDF(new ApexPages.StandardController(oppTest2));
        objsa1.strPDFContent = 'test\\n1\\test\\d1\\USD';
        objsa1.replacepdfContent(oppTest2,pb);
        
    }
}
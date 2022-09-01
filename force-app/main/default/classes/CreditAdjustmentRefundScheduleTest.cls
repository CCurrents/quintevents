/**
 * @File Name          : CreditAdjustmentRefundScheduleTest.cls
 * @Description        : Test class for Credit Adjustment Refund Schedule
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 05/28/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    05/28/2020  kchavda@addonblue.com     Initial Version
 * 1.1    09/01/2020  kchavda@addonblue.com     #378 Addendum Automation changes for v3
**/
@istest
private class CreditAdjustmentRefundScheduleTest{
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
        
        Opportunity oppTest = new Opportunity(Refund_Response__c = 'Apply Credit to New Date in 2020',Pricebook2Id = Test.getStandardPricebookId(),Contact_Site__c = 'quintevents.com', Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '1/2',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,StageName = 'Closed Won',CloseDate = System.today(), Primary_Contact__c = contact.Id,Do_Not_Send_Addendum__c = false);
        insert oppTest;
        
        Opportunity oppTest1 = new Opportunity(Refund_Response__c = 'Apply Credit to New Date in 2020',Pricebook2Id = Test.getStandardPricebookId(),Contact_Site__c = 'quintevents.com', Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '1/2',AccountId = testLead.ConvertedAccountId,StageName = 'Closed Won',CloseDate = System.today(), Primary_Contact__c = contact.Id,Do_Not_Send_Addendum__c = false);
        insert oppTest1;
         
        Pricebook2 pb = new Pricebook2(id=Test.getStandardPricebookId());
        pb.legacy_Id__c = eventTest.id;
        pb.Move_to_2020_Addendum__c = 'testasssss';
        pb.Move_to_2020_Addendum_Envelope_Message__c = 'Move to 20020dd';
        update pb;
        string EventId = Test.getStandardPricebookId();
        set<string> EventIds = new set<string>();
        EventIds.add(EventId); 
        Set<Id> setparentOppId = new set<Id>();
        setparentOppId.add(EventId);
        string query = 'Select id,primary_contact__c,Email__c,Name,Refund_Response__c from opportunity';
        CreditAdjustmentRefundBatch objsa = new CreditAdjustmentRefundBatch(query,EventIds,setparentOppId);
        database.executebatch(objsa);
        
        CreditAdjustmentRefundSchedule sch = new CreditAdjustmentRefundSchedule();
        sch.execute(null);          
        
          
    }
    
    @isTest static void test_method_two() {
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
        
        Opportunity oppTest = new Opportunity(Refund_Response__c = 'Confirm Refund',Refund_Amount__c = '100',Pricebook2Id = Test.getStandardPricebookId(),Contact_Site__c = 'quintevents.com', Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '1/2',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,StageName = 'Closed Won',CloseDate = System.today(), Primary_Contact__c = contact.Id,Do_Not_Send_Addendum__c = false);
        insert oppTest;
        
        Opportunity oppTest1 = new Opportunity(Refund_Response__c = 'Confirm Refund',Refund_Amount__c = '100',Pricebook2Id = Test.getStandardPricebookId(),Contact_Site__c = 'quintevents.com', Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '1/2',AccountId = testLead.ConvertedAccountId,StageName = 'Closed Won',CloseDate = System.today(), Primary_Contact__c = contact.Id,Do_Not_Send_Addendum__c = false);
        insert oppTest1;
         
        Pricebook2 pb = new Pricebook2(id=Test.getStandardPricebookId());
        pb.legacy_Id__c = eventTest.id;
        pb.Refund_Addendum__c = 'testasssss';
        pb.Refund_Addendum_Envelope_Message__c = 'refundeddd';
        update pb;
        
        string EventId = Test.getStandardPricebookId();
        set<string> EventIds = new set<string>();
        EventIds.add(EventId); 
        Set<Id> setparentOppId = new set<Id>();
        setparentOppId.add(EventId);
        string query = 'Select id,primary_contact__c,Email__c,Name,Refund_Response__c from opportunity';
        CreditAdjustmentRefundBatch objsa = new CreditAdjustmentRefundBatch(query,EventIds,setparentOppId);
        database.executebatch(objsa);
        
        CreditAdjustmentRefundSchedule sch = new CreditAdjustmentRefundSchedule();
        sch.execute(null);          
        
          
    }
}
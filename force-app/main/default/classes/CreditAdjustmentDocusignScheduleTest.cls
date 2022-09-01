/**
 * @File Name          : CreditAdjustmentDocusignScheduleTest.cls
 * @Description        : Test class for CreditAdjustmentDocusignSchedule
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 05/29/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    05/29/2020  kchavda@addonblue.com     Initial Version
 * 1.1    09/01/2020  kchavda@addonblue.com     #378 Addendum Automation changes for v3
 * 1.2    02/11/2021  kchavda@addonblue.com     #716 Currently we use wording "2021 Event" for credit creation, need to be replaced with "Future Event".
**/
@istest
private class CreditAdjustmentDocusignScheduleTest{
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
        
        Opportunity oppTest = new Opportunity(Collected_Revenue__c= 100,Move_to_2021_Credit_Percentage__c = 20,Refund_Response__c = 'Apply Credit* to the Future Event',Pricebook2Id = Test.getStandardPricebookId(),Contact_Site__c = 'quintevents.com', Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '1/2',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,StageName = 'Closed Won',CloseDate = System.today(), Primary_Contact__c = contact.Id,Do_Not_Send_Addendum__c = false);
        insert oppTest;        
       
        Quote quote = TestDataFactory.createQuote(1,oppTest.id,Test.getStandardPricebookId())[0]; 
       
        product2 objProd = TestDataFactory.createProduct(1,'Product',Test.getStandardPricebookId(),false)[0];
        objProd.Commodity_Harmonized_Code__c = '35675dsfdg';
        objProd.Commodity_Unit_Price__c = 50;
        objProd.Commodity_Weight__c = 2.0;
        objProd.Commodity_Description__c = 'testcomdesc';
        insert objProd;
        
        Product2 prod = [select id,Price__c,CurrencyIsoCode from product2 where id =: objProd.id];  
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod,Test.getStandardPricebookId());
        insert pbe;
        
        QuoteLineItem QLI = TestDataFactory.createQuoteLineItem(quote.id,pbe.id,'Product','','',true);
        
        quote objquote = [select id,opportunityId,Opportunity.Primary_Contact__c from quote where id =: quote.id];
        Order odr = TestDataFactory.createOrder(1,objquote.opportunityId,objquote.id,objquote.Opportunity.Primary_Contact__c,Test.getStandardPricebookId())[0];
        OrderItem odi = TestDataFactory.createOrderItem(1,odr.id,QLI)[0];
        
        odr.status = 'Active';
        update odr;
        dsfs__DocuSign_Status__c testDSStatus = TestDataFactory.createDocuSignStatus(quote)[0];
        testDSStatus.dsfs__Opportunity__c=oppTest.id;
        insert testDSStatus;        
        
        Opportunity opp = new opportunity(id=[select id,dsfs__Opportunity__r.stagename from dsfs__DocuSign_Status__c where id=:testDSStatus.id].dsfs__Opportunity__c);
        opp.stagename = 'Closed Won';
        update opp;
        
        set<string> EventIds = new set<string>();
        EventIds.add(eventTest.id); 
        string EventId = Test.getStandardPricebookId();
        string query = 'Select id,dsfs__Opportunity__c from dsfs__DocuSign_Status__c where dsfs__Opportunity__r.Refund_Response__c != null';
       
        CreditAdjustmentDocusignBatch objsa = new CreditAdjustmentDocusignBatch(query,EventIds);
        database.executebatch(objsa);
        
        CreditAdjustmentDocusignSchedule sch = new CreditAdjustmentDocusignSchedule();
        sch.execute(null);
        CreditAdjustmentDocusignSchedule.scheduleMe();
    }
}
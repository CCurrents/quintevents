@istest
private class OpportunityCreditAddendumPDFTest{
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
        account acc = new account();
        acc.name = 'testacc234';
        insert acc;
        
        Contact contact = new Contact();
        contact.accountid = acc.id;
        contact.lastname='test'; 
        contact.email='test@quintevents.com';
        contact.Primary_Contact__c  = true;
        insert contact;
        
        Pricebook2 pb = new Pricebook2(id=Test.getstandardPricebookId());
        pb.Legacy_id__c = eventTest.id;
        update pb;
        
        Opportunity oppTest = new Opportunity(CurrencyISOCode = 'USD',Pricebook2Id=Test.getstandardPricebookId(),Contact_Site__c = 'quintevents.com', Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '1/2',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,StageName = 'Closed Won',CloseDate = System.today(), Primary_Contact__c = contact.Id,Refund_Amount__c='100',Do_Not_Send_Addendum__c = false,Refund_Response__c='Confirm Refund');
        insert oppTest;        
       
        OpportunityCreditAddendumPDF objsa = new OpportunityCreditAddendumPDF(new ApexPages.StandardController(oppTest));
        objsa.strPDFContent = 'test\\n1\\test\\d1\\ EVENT NAME USD $XXXX.XX';
        objsa.replacepdfContent(oppTest);
        
        Opportunity oppTest1 = new Opportunity(CurrencyISOCode = 'USD',Pricebook2Id=Test.getstandardPricebookId(),Contact_Site__c = 'quintevents.com', Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '1/2',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,StageName = 'Closed Won',CloseDate = System.today(), Primary_Contact__c = contact.Id,Credit_Amount__c='100',Do_Not_Send_Addendum__c = false,Refund_Response__c='Apply Credit* to the 2021 Event');
        insert oppTest1;        
       
        OpportunityCreditAddendumPDF objsa1 = new OpportunityCreditAddendumPDF(new ApexPages.StandardController(oppTest1));
        objsa1.strPDFContent = 'test\\n1\\test\\d1\\ EVENT NAME USD $XXXX.XX';
        objsa1.replacepdfContent(oppTest1);
        
    }
}
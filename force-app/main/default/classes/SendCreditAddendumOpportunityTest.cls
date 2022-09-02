@istest
private class SendCreditAddendumOpportunityTest{
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
        
        Opportunity oppTest = new Opportunity(pricebook2Id = Test.getstandardpricebookId(),Contact_Site__c = 'quintevents.com', Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '1/2',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,StageName = 'Closed Won',CloseDate = System.today(), Primary_Contact__c = contact.Id,Do_Not_Send_Addendum__c = false);
        insert oppTest;
        
        Quote quot = new Quote(Name='Test Quote',Status='Draft - Needs Review', Draft_Reasons_For_Review_Operations__c='test', Draft_Reasons_For_Review_Sales__c='test', OpportunityId=oppTest.Id,Payment_Method__c='Credit Card',Email='test@test435.com');
        insert quot;
        
        ApexPages.currentPage().getParameters().put('oppId',oppTest.id);
        SendCreditAddendumOpportunity objsa = new SendCreditAddendumOpportunity();
        objsa.streventId = Test.getstandardpricebookId();
        objsa.strOppIds = oppTest.id;
        objsa.fillOpportunityList();
        objsa.displayoppList();
        objsa.filloppList();
        objsa.next();
        objsa.previous();
        objsa.createandSendWithDocuSign();
    }
}
@isTest(SeeAllData = false)
public class QE_QuoteHandler_Test {

    static testMethod void testMethodOne() {
        Id prodRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Package'].Id;

        Profile p = [SELECT Id FROM Profile WHERE Name='QE360 - Sales']; 
        
        User testUser = new User(Alias = 'standt', Email='test@quintevents.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = p.Id, 
                                 TimeZoneSidKey='America/New_York', UserName='test@quintevents.com');
        insert testUser;
        
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Source__c = 'call Virtuoso';
        lead.Company = 'test business';
        lead.email = 'test@quintevents.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
        Program__c testProgram = new Program__c();
        testProgram.Name = 'test';
        insert testProgram;
        
        Schedule__c testSchedule = new Schedule__c();
        testSchedule.User__c = testUser.Id;
        //testSchedule.Program__c = testProgram.Id;
        testSchedule.Days__c = 'Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday';
        insert testSchedule;
        
        Schedule__c testSchedule2 = new Schedule__c();
        testSchedule2.User__c = testUser.Id;
        testSchedule2.Program__c = testProgram.Id;
        testSchedule2.Days__c = 'Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday';
        insert testSchedule2;
        
        Schedule__c testSchedule3 = new Schedule__c();
        testSchedule3.User__c = testUser.Id;
        testSchedule3.Program__c = testProgram.Id;
        testSchedule3.Days__c = 'Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday';
        insert testSchedule3;
        
        QE360_Event__c even = new QE360_Event__c(Name='mexico', Program__c = testProgram.Id);
        insert even;
        
        Contact primaryContact =new Contact(LastName='Test',Primary_Contact__c=true,AccountId=testLead.ConvertedAccountId);
        insert primaryContact;

        Opportunity o = new Opportunity();
        o.Accountid = testLead.ConvertedAccountId;
        o.Name = 'test';
        o.Event__c=even.Id;
        o.Payment_Method__c='Credit Card';
        o.Send_Payment_Email__c=true;
        o.StageName = 'Prospecting';
        o.CloseDate = date.today();  
        o.Contact_Site__c = 'quintevents.com';
        o.OwnerId = testUser.Id;
        o.Primary_Contact__c = primaryContact.Id;
        insert o;
        Contact con =new Contact(LastName='Test',Primary_Contact__c=true,AccountId=testLead.ConvertedAccountId,Opportunity__c=o.Id);
        insert con;
        QE360_Opportunity_Additional_Signee__c oppAddsign = new QE360_Opportunity_Additional_Signee__c();
        oppAddsign.Name='Test';
        oppAddsign.Amount__c=10;        
        oppAddsign.City__c='Test';        
        oppAddsign.Country__c='Test';        
        oppAddsign.Email__c='Test@test87.com';        
        oppAddsign.State__c='Test';
        oppAddsign.OpportunityS__c=o.Id;    
        insert oppAddsign;

        Quote quot = new Quote(OwnerId=testUser.id,Name='Test Quote',Payment_Terms__c = '1/2',OpportunityId=o.Id,Status='Signed - Approved',Payment_Method__c='Credit Card',Email='test@test435.com',Pricebook2Id = Test.getStandardPricebookId());
        insert quot;
        
        quot.Draft_Approval_Request_Date_Time__c = system.today();
        update quot;
        
        Test.startTest();
        Map<Id, Id> oppAndQuoteIds = new Map<Id, Id>();
        oppAndQuoteIds.put(o.Id, quot.Id);
        List<Id> quoteIds = new List<Id>();
        quoteIds.add(quot.Id);
        try{
            QE_Quote_Helper quoteHelperObj = new QE_Quote_Helper();
            QE_Quote_Helper.getQuotePackageProducts(quoteIds);
            QE_Quote_Helper.getQuoteALaCartes(quoteIds);
            quoteHelperObj.copyProductDataToOpportunityField(oppAndQuoteIds);
            QE_Quote_Helper.updateQuoteStatusDocuSign(quoteIds,'Quoete After insert');
            QE_Quote_Helper.updateQuoteStatus(quoteIds, 'Quote-Trigger-AfterInsert');
        } catch(DMLexception e){}
        Test.stopTest();
    }

}
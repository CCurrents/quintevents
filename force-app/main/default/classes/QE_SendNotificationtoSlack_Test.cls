@isTest
public class QE_SendNotificationtoSlack_Test {
    
    static testMethod void testMethod1() {
        Test.StartTest();
        
        // Insert Test Account
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Source__c = 'call Virtuoso';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
        QE360_Event__c testEvent = new QE360_Event__c(Name='Test Event');
        insert testEvent;
        
        Account testLeadConvertedAccount = new Account();
        
        testLeadConvertedAccount.Id = testLead.ConvertedAccountId;
        testLeadConvertedAccount.PersonEmail = 'test@tets.com';
        
        update testLeadConvertedAccount;
        
        //INSERT OPPORTUNITY RECORD
        Opportunity opp = new Opportunity();
        opp.AccountId = testLead.ConvertedAccountId;
        opp.Name = 'test record'; 
        opp.StageName = 'Prospecting';
        opp.CloseDate = date.today();
        opp.Event__c = testEvent.Id;
        opp.Contact_Site__c = 'barrettjacksonvip.com';
        insert opp;
        
        //INSERT QUOTE RECORD
        
        Quote quot = new Quote();
        quot.OpportunityId = opp.Id;
        quot.Name='Test Quote1';
        quot.Status='Draft';
        quot.Awaiting_Approval_From__c = 'Sales';
        quot.Draft_Reasons_For_Review_H4H__c = 'Test';
        quot.Draft_Reasons_For_Review_Sales__c = 'Test';
        quot.Draft_Reasons_For_Review_Operations__c = 'Test';
        quot.Draft_Reasons_For_Review_Corporate_Sales__c = 'Test';
        insert quot;
        
        QE_SendNotificationtoSlack.SendNotificationToSlackChannel(new List<Id>{quot.Id});
        Test.stopTest();
    }
}
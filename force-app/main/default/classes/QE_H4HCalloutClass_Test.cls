@isTest(seeAllData=false)
public class QE_H4HCalloutClass_Test {
    static testMethod void test_method_one() {

        Program__c pro = new Program__c();
        pro.Name = 'F1E test';
        insert pro;
        
        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        eventTest.program__c =pro.id;
        Insert eventTest;
        
        // Insert Test Account
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'lgaID';
        lead.Google_Analytics_Site_Id__c = 'lgaSiteId';
        lead.FirstName = 'testNamelead';
        lead.LastName = 'test';
        lead.Status = 'Qualified';
        lead.Source__c = 'call cotaexperiences.com';
        lead.Email = 'testemails@quintevents.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        Lead testLead = [select Id, IsConverted, ConvertedAccountId, ConvertedContactId from Lead where Id = :lead.Id];
        
        Reseller__c testReseller = new Reseller__c(Default_Commission__c =1.00);
        Insert testReseller;
        
        Promoter__c testPromoter = new Promoter__c(Online_Sales_Commission__c=1.00, A_La_Carte_Commission__c=2.00, 
            Package_with_Hotel_Commission__c=3.00, Package_without_Hotel_Commission__c=4.00);
        Insert testPromoter;
        
        Account acct = new Account();
        acct.Id = testLead.ConvertedAccountId;
        acct.personEmail ='testmails@quintevents.com';        
        update acct;
       
        Opportunity oppTest = new Opportunity();
        oppTest.Name = 'oppName';
        oppTest.AccountId = testLead.ConvertedAccountId;
        oppTest.Event__c = eventTest.Id;
        oppTest.StageName = 'Value Proposition';
        oppTest.CloseDate = System.today();
        oppTest.Contact_Site__c = 'quintevents.com';
        oppTest.ship_to_Name__c = 'Test abc Test1';
        oppTest.Payment_Method__c = 'Check';
        oppTest.email__c = 'abcedgft@gmail.com';
        oppTest.Primary_Contact__c = testLead.ConvertedContactId;
        oppTest.Amount = 1;
        insert oppTest;
        Test.startTest();

        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new QE_restH4HCalloutTest());
        QE_H4HCalloutClass.getTokenSiteAdmin(oppTest.Id, true); 
        QE_H4HCalloutClass.getTokenSiteAdmin(oppTest.Id, false);        
        Test.stopTest();
    }
}
@isTest
public class ChangeAccountRecordTypeCtrlTest {
    
    /* Test method to cover the code account recordtype method*/
    public testmethod static void testChangeAccountRecordType(){
        
        // Due to validation we can not create account we need to create 
        // lead and then conver that lead
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Interested';
        lead.Source__c = 'call Virtuoso';
        lead.Company = 'test business';
        lead.Company_Name__c = 'Test company';
        lead.Email = 'testemail@quintevents.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Interested');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId, ConvertedContactId from Lead where Id = :lead.Id];
        //Account objAccount = [select id, Company_Name__pc, recordTypeId from account where id=: testLead.ConvertedAccountId];
        Apexpages.currentPage().getParameters().put('id', testLead.ConvertedAccountId);
        ChangeAccountRecordTypeController changeAccRecordTypeCtlr = new ChangeAccountRecordTypeController(new ApexPages.StandardController(new Account(Id = testLead.ConvertedAccountId)));
        changeAccRecordTypeCtlr.upadateAccountRecordType();
        changeAccRecordTypeCtlr.redirectAccountDetailPage();
    }
    
    /* Test method to cover the code account recordtype method*/
    public testmethod static void changeAccountRecordType2(){
        
        // Due to validation we can not create account we need to create 
        // lead and then conver that lead
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Interested';
        lead.Source__c = 'call Virtuoso';
        //lead.Company = 'test business';
        //lead.Company_Name__c = 'Test company';
        lead.Email = 'testemail@quintevents.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Interested');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId, ConvertedContactId from Lead where Id = :lead.Id];
        //Account objAccount = [select id, Company_Name__pc, recordTypeId from account where id=: testLead.ConvertedAccountId];
        Apexpages.currentPage().getParameters().put('id', testLead.ConvertedAccountId);
        ChangeAccountRecordTypeController changeAccRecordTypeCtlr = new ChangeAccountRecordTypeController(new ApexPages.StandardController(new Account(Id = testLead.ConvertedAccountId)));
        Contact con = new Contact(Id = testLead.ConvertedContactId);
        con.Company_Name__c = 'Test BA';
        update con;
        Contact c = [Select Id,Name,Company_Name__c,Account.Company_Name__pc,Account.RecordType.Name from Contact where Id =: con.Id];
        changeAccRecordTypeCtlr.upadateAccountRecordType();
        changeAccRecordTypeCtlr.redirectAccountDetailPage();
    }
}
@isTest
public class QE_splitAgreementClass_Test{

    @isTest static void test_method_one() {
        Test.startTest();        
        Id prodRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Package'].Id;
        //Account a = new Account(Name='Test Account');
        //insert a;
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Source__c = 'call Virtuoso';
        lead.Company = 'test business';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
                
        QE360_Event__c even = new QE360_Event__c(Name='US',Active__c = true);
        insert even;
        Opportunity o = new Opportunity();
        o.Accountid = testLead.ConvertedAccountId;
        o.Name = 'test';
        o.Event__c=even.Id;
        o.Payment_Method__c='Credit Card';
        o.Send_Payment_Email__c=true;
        o.StageName = 'Prospecting';
        o.CloseDate = date.today();                
        insert o;
        Contact con =new Contact(LastName='Test',Primary_Contact__c=true,AccountId=testLead.ConvertedAccountId,Opportunity__c=o.Id);
        insert con;
        QE360_Opportunity_Additional_Signee__c oppAddsign = new QE360_Opportunity_Additional_Signee__c();
        oppAddsign.Name='Test';
        oppAddsign.Amount__c=10;        
        oppAddsign.City__c='Test';  
        oppAddsign.Contact__c=con.Id;      
        oppAddsign.Country__c='Test';        
        oppAddsign.Email__c='Test@test87.com';        
        oppAddsign.State__c='Test';
        oppAddsign.OpportunityS__c=o.Id;    
        insert oppAddsign;        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(o);        
        Test.setCurrentPageReference(new PageReference('Page.QE_splitAgreement')); 
        System.currentPageReference().getParameters().put('id', o.id);
        QE_splitAgreementClass obj = new QE_splitAgreementClass(sc);        
        obj.displayContactList[0].selectBit =true;
        obj.newSignee=oppAddsign ;
        obj.processSelected();
        obj.addSigneeItem();
        obj.Cancel();
        obj.addNewSigee();
        obj.closePopup();   
        obj.showPopup();     
        
        Test.stopTest();
    }
    
    @isTest static void test_method_two() {
        Test.startTest();        
        Id oppRecType = [Select Id,Name From RecordType Where sObjectType='Opportunity' and Name='Business Opportunity'].Id;
        //Account a = new Account(Name='Test Account');
        //insert a;   
        
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Source__c = 'call Virtuoso';
        lead.Company = 'test business';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
             
        QE360_Event__c even = new QE360_Event__c(Name='US',Active__c = true);
        insert even;
        Opportunity o = new Opportunity();
        o.Accountid = testLead.ConvertedAccountId;
        o.Name = 'test';
        o.Event__c=even.Id;
        o.Payment_Method__c='Credit Card';
        o.Send_Payment_Email__c=true;
        o.StageName = 'Prospecting';
        o.RecordTypeId=oppRecType;
        o.CloseDate = date.today();                
        insert o;
        Contact con =new Contact(LastName='Test',Primary_Contact__c=true,AccountId=testLead.ConvertedAccountId,Opportunity__c=o.Id);
        insert con;
        QE360_Opportunity_Additional_Signee__c oppAddsign = new QE360_Opportunity_Additional_Signee__c();
        oppAddsign.Name='Test';
        oppAddsign.Amount__c=10;        
        oppAddsign.City__c='Test';  
        oppAddsign.Contact__c=con.Id;      
        oppAddsign.Country__c='Test';        
        oppAddsign.Email__c='Test@test87.com';        
        oppAddsign.State__c='Test';
        oppAddsign.OpportunityS__c=o.Id;    
        insert oppAddsign;        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(o);        
        Test.setCurrentPageReference(new PageReference('Page.QE_splitAgreement')); 
        System.currentPageReference().getParameters().put('id', o.id);
        QE_splitAgreementClass obj = new QE_splitAgreementClass(sc);        
        obj.displayContactList[0].selectBit =true;
        obj.newSignee=oppAddsign ;
        obj.processSelected();
        obj.addSigneeItem();
        obj.Cancel();
        obj.addNewSigee();
        obj.closePopup();   
        obj.showPopup();     
        
        Test.stopTest();
    }

    
}
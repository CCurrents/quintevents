@isTest
public class QE_ProcessInstanceController_Test{
    static testMethod void testMethod1()
    {
        Test.startTest();
        // Insert Test Account
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Source__c = 'call Virtuoso';
        lead.Email = 'test@test.com';
        lead.Lead_Type__c = 'Person';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId,ConvertedContactId from Lead where Id = :lead.Id]; 
        Account testAccount = [SELECT Id, Name,PersonContact.Email FROM Account WHERE Id =: testLead.ConvertedAccountId LIMIT 1];
        testAccount.PersonContact.Email = 'test@test.com';
        //update testAccount;
        QE360_Event__c even = new QE360_Event__c(Name='US');
        insert even;
        Opportunity o = new Opportunity();
        o.Accountid = testLead.ConvertedAccountId;
        o.Name = 'test';
        o.Event__c=even.Id;
        o.Payment_Method__c='Credit Card';
        o.Send_Payment_Email__c=true;
        o.StageName = 'Prospecting';
        o.CloseDate = date.today();
        o.Contact_Site__c = 'barrettjacksonvip.com';                
        o.Primary_contact__c = testLead.ConvertedContactId;
        insert o;
        Quote quot = new Quote(Name='Test Quote',Draft_Reasons_For_Review_H4H__c='test',Status='Draft - Needs Review',OpportunityId=o.Id,Payment_Method__c='Credit Card',Email='test@test435.com',Online_Order__c =false);
        insert quot;
        QuoteDocument quotDoc = new QuoteDocument(QuoteId=quot.Id);
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=quot.id;
        insert attach;
       // ProcessInstance proc = new ProcessInstance(ProcessDefinitionId='', TargetObjectId, Status, CompletedDate, LastActorId )
        ApexPages.currentPage().getParameters().put('id',quot.id);
        
        if([select count() from ProcessInstance where targetobjectid=:quot.id limit 1] < 1)
        {       
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(quot.Id);
            //Submit the approval request
            Approval.ProcessResult result = Approval.process(req);
            System.debug('result-->'+result );
        }
        
         ApexPages.StandardController stdPro = new ApexPages.StandardController(quot);
         QE_ProcessInstanceController QEClass = new QE_ProcessInstanceController(stdPro);
         QEClass.imageURL = '/servlet/servlet.FileDownload?file='+attach.Id;
         QEClass.quoteDoc = quotDoc;
         QEClass.quoteAtt = attach;
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
         User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
         LocaleSidKey='en_US', ProfileId = p.Id,
         TimeZoneSidKey='America/Los_Angeles',
         UserName='testusers@testorg.com');

         // reject without comments
         QEClass.comments = '';
         System.runAs(u){
             QEClass.Approve();
             QEClass.Reject();
         }
         QEClass.Cancel();
         QEClass.showPopup();
         QEClass.closePopup();

         // reject with comments         
         QEClass.comments = 'comment';
         QEClass.Reject();
         
        Test.stopTest();
    }
    
    static testMethod void testMethod2()
    {
        Test.startTest();
        // Insert Test Account
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Source__c = 'call Virtuoso';
        lead.Email = 'test@test.com';
        lead.Lead_Type__c = 'Person';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId,ConvertedContactId from Lead where Id = :lead.Id]; 
        Account testAccount = [SELECT Id, Name,PersonContact.Email FROM Account WHERE Id =: testLead.ConvertedAccountId LIMIT 1];
        testAccount.PersonContact.Email = 'test@test.com';
        //update testAccount;
        QE360_Event__c even = new QE360_Event__c(Name='US');
        insert even;
        Opportunity o = new Opportunity();
        o.Accountid = testLead.ConvertedAccountId;
        o.Name = 'test';
        o.Event__c=even.Id;
        o.Payment_Method__c='Credit Card';
        o.Send_Payment_Email__c=true;
        o.StageName = 'Prospecting';
        o.CloseDate = date.today(); 
        o.Contact_Site__c = 'barrettjacksonvip.com';       
        o.Primary_contact__c = testLead.ConvertedContactId;
        insert o;
        Quote quot = new Quote(Name='Test Quote',Status='Signed - Needs Review',OpportunityId=o.Id,Payment_Method__c='Credit Card',Email='test@test435.com',Online_Order__c =false);
        insert quot;
        QuoteDocument quotDoc = new QuoteDocument(QuoteId=quot.Id);
        Attachment attach=new Attachment();     
      attach.Name='Unit Test Attachment';
      Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
      attach.body=bodyBlob;
        attach.parentId=quot.id;
        insert attach;
       // ProcessInstance proc = new ProcessInstance(ProcessDefinitionId='', TargetObjectId, Status, CompletedDate, LastActorId )
        ApexPages.currentPage().getParameters().put('id',quot.id);
        
        if([select count() from ProcessInstance where targetobjectid=:quot.id limit 1] < 1)
        {       
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(quot.Id);
            //Submit the approval request
            Approval.ProcessResult result = Approval.process(req);
        }
        
         ApexPages.StandardController stdPro = new ApexPages.StandardController(quot);
         QE_ProcessInstanceController QEClass = new QE_ProcessInstanceController(stdPro);
         QEClass.imageURL = '/servlet/servlet.FileDownload?file='+attach.Id;
         QEClass.quoteDoc = quotDoc;
         QEClass.quoteAtt = attach;
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
         User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
         LocaleSidKey='en_US', ProfileId = p.Id,
         TimeZoneSidKey='America/Los_Angeles',
         UserName='testusers@testorg.com');
         // reject without comments
         QEClass.comments = 'vhg';
         System.runAs(u){
             QEClass.Approve();
             QEClass.Reject();
         }
         QEClass.Cancel();
         QEClass.showPopup();
         QEClass.closePopup();

         // reject with comments         
         QEClass.comments = 'comment';
         QEClass.Approve();
         QEClass.Reject();
         
        Test.stopTest();
    }
    
}
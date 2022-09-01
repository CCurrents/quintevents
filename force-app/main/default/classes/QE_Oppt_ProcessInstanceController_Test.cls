@isTest
public class QE_Oppt_ProcessInstanceController_Test{
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
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id]; 
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
        insert o;
        //Quote quot = new Quote(Name='Test Quote',Status='Signed - Needs Review',OpportunityId=o.Id,Payment_Method__c='Credit Card',Email='test@test435.com');
        //insert quot;
        //QuoteDocument quotDoc = new QuoteDocument(QuoteId=quot.Id);
       // ProcessInstance proc = new ProcessInstance(ProcessDefinitionId='', TargetObjectId, Status, CompletedDate, LastActorId )
        ApexPages.currentPage().getParameters().put('id',o.id);
        
        if([select count() from ProcessInstance where targetobjectid=:o.id limit 1] < 1)
        {       
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(o.Id);
            //Submit the approval request
            Approval.ProcessResult result = Approval.process(req);
        }
        
         ApexPages.StandardController stdPro = new ApexPages.StandardController(o);
         QE_OpportunitY_ProcessInstanceController QEClass = new QE_Opportunity_ProcessInstanceController(stdPro);
         //QEClass.imageURL = '/servlet/servlet.FileDownload?file='+quotDoc.Id;
         //QEClass.quoteDoc = quotDoc;
        
         // reject without comments
         QEClass.comments = '';
         QEClass.Approve();
         QEClass.Reject();
         QEClass.Cancel();
         //QEClass.showPopup();
         //QEClass.closePopup();

         // reject with comments         
         QEClass.comments = 'comment';
         QEClass.Reject();
         
        Test.stopTest();
    }
}
@isTest
public class QE_Quote_Approval_Class_Test{
    
    static testMethod void method1() { 
        // Draft Quote
        Test.startTest();
        // Insert Test Account
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Email = 'test@quintevents.com.test';
        lead.Source__c = 'call Virtuoso';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId,ConvertedContactId from Lead where Id = :lead.Id]; 
        //Account a = new Account(Name='Test Account');
        //insert a;   
        QE360_Event__c even = new QE360_Event__c(Name='US');
        insert even;
        Opportunity o = new Opportunity();
        o.Accountid = testLead.ConvertedAccountId;
        o.Primary_Contact__c = testLead.ConvertedContactId; 
        o.Name = 'test';
        o.Event__c=even.Id;
        o.Payment_Method__c='Credit Card';
        o.Send_Payment_Email__c=true;
        o.StageName = 'Prospecting';
        o.CloseDate = date.today();
        o.Contact_Site__c = 'quintevents.com';
        insert o;
        Quote quot = new Quote(Name='Test Quote',Status='Draft - Needs Review', Draft_Reasons_For_Review_Operations__c='test', Draft_Reasons_For_Review_Sales__c='test', OpportunityId=o.Id,Payment_Method__c='Credit Card',Email='test@test435.com');
        insert quot;
        // Approval Process 
        ProcessInstance pinst = new ProcessInstance(Status='Pending',TargetObjectId=quot.Id);
        //insert pinst;
        ProcessInstanceWorkitem p = new ProcessInstanceWorkitem(ProcessInstanceId=pinst.Id);
        //insert p;
        if([select count() from ProcessInstance where targetobjectid=:quot.id] < 1)
        {       
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(quot.Id);

            //Submit the approval request
            Approval.ProcessResult result = Approval.process(req);

        }
        QE_Quote_Approval_Class obj = new QE_Quote_Approval_Class();
        Decimal timeSinceRequestDays = 01.00;
        Decimal timeSinceRequestHrs = 01.00;
        Decimal timeSinceRequestMins = 01.00;
        QE_Quote_Approval_Class.wrapperClassSignedReview obj1 = new QE_Quote_Approval_Class.wrapperClassSignedReview('Approved',quot,quot.Id,timeSinceRequestDays,timeSinceRequestHrs,timeSinceRequestMins);      
        Test.stopTest();
    }
    
    static testMethod void method2() { 
        // Signed Quote
        Test.startTest();
        // Insert Test Account
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Email = 'test@quintevents.com.test';
        lead.Source__c = 'call Virtuoso';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId,ConvertedContactId from Lead where Id = :lead.Id]; 
        //Account a = new Account(Name='Test Account');
        //insert a;   
        QE360_Event__c even = new QE360_Event__c(Name='US');
        insert even;
        Opportunity o = new Opportunity();
        o.Accountid = testLead.ConvertedAccountId;
        o.Primary_Contact__c = testLead.ConvertedContactId;
        o.Name = 'test';
        o.Event__c=even.Id;
        o.Payment_Method__c='Credit Card';
        o.Send_Payment_Email__c=true;
        o.StageName = 'Prospecting';
        o.CloseDate = date.today();
        o.Contact_Site__c = 'quintevents.com';
        insert o;
        Quote quot = new Quote(Name='Test Quote',Status='Signed - Needs Review', Draft_Reasons_For_Review_Operations__c='test', Draft_Reasons_For_Review_Sales__c='test', OpportunityId=o.Id,Payment_Method__c='Credit Card',Email='test@test435.com');
        insert quot;
        // Approval Process 
        ProcessInstance pinst = new ProcessInstance(Status='Pending',TargetObjectId=quot.Id);
        //insert pinst;
        ProcessInstanceWorkitem p = new ProcessInstanceWorkitem(ProcessInstanceId=pinst.Id);
        //insert p;
        if([select count() from ProcessInstance where targetobjectid=:quot.id] < 1)
        {       
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(quot.Id);

            //Submit the approval request
            Approval.ProcessResult result = Approval.process(req);

        }
        QE_Quote_Approval_Class obj = new QE_Quote_Approval_Class();
        Decimal timeSinceRequestDays = 01.00;
        Decimal timeSinceRequestHrs = 01.00;
        Decimal timeSinceRequestMins = 01.00;
        QE_Quote_Approval_Class.wrapperClassSignedReview obj1 = new QE_Quote_Approval_Class.wrapperClassSignedReview('Approved',quot,quot.Id,timeSinceRequestDays,timeSinceRequestHrs,timeSinceRequestMins);      
        Test.stopTest();
    }
    
    static testMethod void method3() { 
        // Canceled Opportunities
        Test.startTest();
        // Insert Test Account
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Email = 'test@quintevents.com.test';
        lead.Source__c = 'call Virtuoso';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId,ConvertedContactId from Lead where Id = :lead.Id]; 
        //Account a = new Account(Name='Test Account');
        //insert a;   
        QE360_Event__c even = new QE360_Event__c(Name='US');
        insert even;
        Opportunity o = new Opportunity();
        o.Accountid = testLead.ConvertedAccountId;
        o.Primary_Contact__c = testLead.ConvertedContactId;
        o.Name = 'test';
        o.Event__c=even.Id;
        o.Payment_Method__c='Credit Card';
        o.Send_Payment_Email__c=true;
        o.StageName = 'Prospecting';
        o.CloseDate = date.today();
        o.Contact_Site__c = 'quintevents.com';
        insert o;
        Quote quot = new Quote(Name='Test Quote',Status='Draft', Draft_Reasons_For_Review_Operations__c='test', Draft_Reasons_For_Review_Sales__c='test', OpportunityId=o.Id,Payment_Method__c='Credit Card',Email='test@test435.com');
        insert quot;
        quot.Status = 'Signed - Approved';
        //update quot;
        o.StageName = 'Under Review';
        o.Change_Request_Detail__c = 'testing';
        o.Reason_For_Cancellation__c = 'Training';
        update o;
        
        ProcessInstance pinst = new ProcessInstance(Status='Pending',TargetObjectId=quot.Id);
        //insert pinst;
        ProcessInstanceWorkitem p = new ProcessInstanceWorkitem(ProcessInstanceId=pinst.Id);
        //insert p;
        if([select count() from ProcessInstance where targetobjectid=:quot.id] < 1)
        {       
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setProcessDefinitionNameOrId('Opportunity_Canceled_From_Closed_Won');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(o.Id);

            //Submit the approval request
          //  Approval.ProcessResult result = Approval.process(req);

        }
        QE_Quote_Approval_Class obj = new QE_Quote_Approval_Class();
        Decimal timeSinceRequestDays = 01.00;
        Decimal timeSinceRequestHrs = 01.00;
        Decimal timeSinceRequestMins = 01.00;
        QE_Quote_Approval_Class.opportunityWrapperClass obj1 = new QE_Quote_Approval_Class.opportunityWrapperClass('Approved',o,o.Id,timeSinceRequestDays,timeSinceRequestHrs,timeSinceRequestMins);      
        Test.stopTest();
    }
    
}
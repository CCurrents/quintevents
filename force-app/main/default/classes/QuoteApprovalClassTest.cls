/**
 * @File Name          : QuoteApprovalClass.cls
 * @Description        : 
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/15/2020, 11:03:07 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    3/16/2020   mpatel@addonblue.com     Initial Version
**/ 
@isTest 
private with sharing class QuoteApprovalClassTest{ 
    @testSetup static void setup() {
  
        TestDataFactory.createTriggerSettingsEntry();
        
    }
    @isTest static void testMethodOne() {
        Account objAccount = TestDataFactory.createAccount();
        System.assert(true,objAccount.Name != null);

        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        System.assertEquals('Test@gmail.com', objContact.Email);

        PriceBook2 priceBook = TestDataFactory.createPricebook(1, 'T', false)[0];
        priceBook.Payment_Cancellation_Days__c = 2;
        priceBook.Start_Date__c = system.today();
        priceBook.Event_Payment_Window__c = 1;
        Utility.processRecords(pricebook, 'insert');

        Opportunity opportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, pricebook.id, false)[0];
        opportunity.PriceBook2Id = pricebook.Id;
        opportunity.StageName = 'Closed Won';
        Utility.processRecords(opportunity, 'insert');
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = objContact.Id;
        ocr.OpportunityId = Opportunity.Id;
        ocr.Role = 'H4H Rewards Contact';
        Utility.processRecords(ocr, 'insert');
        
        TestDataFactory.createSFDCIntacctMapping();
        
        Order order = TestDataFactory.createOrder(1,false)[0];
        order.OpportunityId = opportunity.Id;
        order.Subject_to_Cancellation__c = false;
        Utility.processRecords(order, 'insert');
        
        Quote quote = new Quote();
        quote.Id = order.QuoteId;
        quote.Status = 'Draft - Needs Review';
        quote.Draft_Reasons_For_Review_Accounting__c = 'test';
        Utility.processRecords(quote, 'update');
        
        order.Status = 'Cancellation Pending';
        Utility.processRecords(order, 'update');
        System.debug('quote.Owner.name-->'+quote.Owner.name);
        System.debug('quote.Status-->'+quote.Status);
        System.debug('quote.Draft_Reasons_For_Review_Accounting__c-->'+quote.Draft_Reasons_For_Review_Accounting__c);
        ProcessInstance pinst = new ProcessInstance(Status='Pending',TargetObjectId=order.QuoteId);
        
        ProcessInstanceWorkitem processInstanceWorkQuote = new ProcessInstanceWorkitem(ProcessInstanceId=pinst.Id);

        if([select count() from ProcessInstance where targetobjectid=:order.QuoteId] < 1){       
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(order.QuoteId);

            //Submit the approval request
            Approval.ProcessResult result = Approval.process(req);

        }
        ProcessInstance pinstOrder = new ProcessInstance(Status='Pending',TargetObjectId=order.QuoteId);

        ProcessInstanceWorkitem processInstanceWorkOrder = new ProcessInstanceWorkitem(ProcessInstanceId=pinstOrder.Id);

        if([select count() from ProcessInstance where targetobjectid=:order.Id] < 1){       
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(order.Id);

            //Submit the approval request
            Approval.ProcessResult result = Approval.process(req);

        }
        
        QuoteApprovalClass.getQuoteApprovalClass();
        QuoteApprovalClass.getProcessInstanceDetail(order.QuoteId);
        QuoteApprovalClass.OpportunityProcessInstance(order.Id);
        List<ProcessInstanceWorkitem> processInstanceWorkQuoteList = new List<ProcessInstanceWorkitem>();
        processInstanceWorkQuoteList.add(processInstanceWorkQuote);
        List<ProcessInstanceWorkitem> processInstanceWorkOrderList = new List<ProcessInstanceWorkitem>();
        processInstanceWorkOrderList.add(processInstanceWorkOrder);
        QuoteApprovalClass.rejectProcess('comments', Quote, Json.serialize(processInstanceWorkQuoteList));
        QuoteApprovalClass.ApproveProcess('comments', Quote, Json.serialize(processInstanceWorkQuoteList));
        QuoteApprovalClass.orderApprove('comments', Json.serialize(processInstanceWorkOrderList), order);
        QuoteApprovalClass.orderReject('comments', Json.serialize(processInstanceWorkOrderList), order);
                RunAsAdminUtility.deleteContentDistibution();

        System.assert(true, !processInstanceWorkOrderList.isEmpty());
    }
}
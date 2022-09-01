@isTest
public class QE_DocusignCounterSign_Test {
    
    public static testmethod void testDocusignStatusChange(){
        test.startTest();
        
        Test.setMock(WebServiceMock.class, new QE_DocusignCounterSignMock_Test());
        
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
        
        QE360_Event__c testEvent = new QE360_Event__c(Name='mexico');
        insert testEvent;
        
        Opportunity o = new Opportunity();
        o.Accountid = testLead.ConvertedAccountId;
        o.Name = 'test';
        o.Event__c=testEvent.Id;
        o.Payment_Method__c='Credit Card';
        o.Send_Payment_Email__c=true;
        o.StageName = 'Prospecting';
        o.CloseDate = date.today();
        o.Contact_Site__c = 'quintevents.com';                
        insert o;
        
        Quote quot = new Quote(Name='Test Quote',OpportunityId=o.Id,Status='Draft - Approved',Payment_Method__c='Credit Card',Email='test@test435.com',Pricebook2Id = Test.getStandardPricebookId());      
        insert quot;
        
        //quot.Status = 'Signed - Approved';
        //update quot;
        
        dsfs__DocuSign_Status__c status = new dsfs__DocuSign_Status__c();
        status.Standard_Quote__c = quot.Id;
        status.Has_Counter_Signer__c = true;
        insert status;
        
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=status.id;
        insert attach;
        
        try{
            status.dsfs__Envelope_Status__c='Completed';
            update status;
        }catch(exception e){
        }    
        
        
        quot.Status = 'Signed - Approved';
        update quot;
        
        Map<Id,Id> CompletedDocusignStatusToSourceIdMap = new Map<Id,Id>();
        Map<Id,String> QuoteIdToSigningGroupId = new Map<Id,String>();
        Map<Id,String> quoteIdsToQuoteEmails = new Map<Id,String>();
        Map<Id,String> quoteIdsToBillingName = new Map<Id,String>();
        
        CompletedDocusignStatusToSourceIdMap.put(status.Id, quot.Id);
        QuoteIdToSigningGroupId.put(quot.Id, '13142');
        quoteIdsToQuoteEmails.put(quot.Id,'testjpatel@quintevents.com');
        quoteIdsToBillingName.put(quot.Id,'Testing Test');
        
        QE_DocusignCounterSign.createAndSendEnvelope(CompletedDocusignStatusToSourceIdMap,QuoteIdToSigningGroupId,quoteIdsToQuoteEmails,quoteIdsToBillingName);
        
        test.stopTest();
    }
    
}
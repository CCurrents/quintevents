@isTest(SeeAllData = false)
public class QE_Quote_Submit_For_Approval_Class_Test {

    public static testMethod void startTestMethod1() {
        // Test Data
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
        Insert eventTest;
        // Insert Test Account
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Source__c = 'call Virtuoso';
        lead.email = 'test12@testmail.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Interested');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        // Insert Test Oppt
        Opportunity oppTest = new Opportunity(Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '100%',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,Contact_Site__c='barrettjacksonvip.com',StageName = 'Prospecting',CloseDate = System.today(), Send_Payment_Email__c=true);
        insert oppTest;
        // Insert Test Quote
        Quote quoteTest = new Quote(
            Name = 'test',
            Status='Draft', 
            Payment_Method__c = 'Credit Card',
            OpportunityId = oppTest.Id,
            Email = 'jeetpatel24@quintevents.com',
            Payment_Terms__c = '100%',
            Payment_Page_Access_Token__c = 'adfsdg3ewfbv2eswsdfeefer',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        try{
        insert quoteTest;
        }catch(exception e){
        
              }
        
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=quoteTest.id;
        insert attach;
               
        // Approval button
        PageReference QE_Quote_Submit_For_Approval_Btn = Page.QE_Quote_Submit_For_Approval_Btn;
        Test.setCurrentPage(QE_Quote_Submit_For_Approval_Btn);
        QE_Quote_Submit_For_Approval_Btn.getParameters().put('quoteid',quoteTest.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteTest);
        QE_Quote_Submit_For_Approval_Btn_Class QE_Quote_Submit_For_Approval_Btn_Class = new QE_Quote_Submit_For_Approval_Btn_Class(sc);
        // Call controller methods
        QE_Quote_Submit_For_Approval_Btn_Class.onClick();
        QE_Quote_Submit_For_Approval_Btn_Class.closePopup();
        QE_Quote_Submit_For_Approval_Btn_Class.updateQuoteStatus();
        
        // to cover popup display code
        quoteTest.Status = 'Draft - Approved';
        update quoteTest;
        
        QE_Quote_Submit_For_Approval_Btn_Class.onClick();
    }
    
     public static testMethod void startTestMetho21() {
        // Test Data
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
        Insert eventTest;
        // Insert Test Account
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Source__c = 'call Virtuoso';
        lead.email = 'test12@testmail.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Interested');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        // Insert Test Oppt
        Opportunity oppTest = new Opportunity(Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '100%',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,Contact_Site__c='barrettjacksonvip.com',StageName = 'Prospecting',CloseDate = System.today(), Send_Payment_Email__c=true);
        insert oppTest;
        // Insert Test Quote
        Quote quoteTest = new Quote(
            Name = 'test',
            Status='Draft - Approved', 
            Payment_Method__c = 'Credit Card',
            OpportunityId = oppTest.Id,
            Email = 'jeetpatel24@quintevents.com',
            Payment_Terms__c = '100%',
            Payment_Page_Access_Token__c = 'adfsdg3ewfbv2eswsdfeefer',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        try{
        insert quoteTest;
        }catch(exception e){
        
              }
        
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=quoteTest.id;
        insert attach;
               
        // Approval button
        PageReference QE_Quote_Submit_For_Approval_Btn = Page.QE_Quote_Submit_For_Approval_Btn;
        Test.setCurrentPage(QE_Quote_Submit_For_Approval_Btn);
        QE_Quote_Submit_For_Approval_Btn.getParameters().put('quoteid',quoteTest.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteTest);
        QE_Quote_Submit_For_Approval_Btn_Class QE_Quote_Submit_For_Approval_Btn_Class = new QE_Quote_Submit_For_Approval_Btn_Class(sc);
        // Call controller methods
        QE_Quote_Submit_For_Approval_Btn_Class.onClick();
        QE_Quote_Submit_For_Approval_Btn_Class.closePopup();
        QE_Quote_Submit_For_Approval_Btn_Class.updateQuoteStatus();
        
        // to cover popup display code
        quoteTest.Status = 'Draft - Approved';
        update quoteTest;
        
        QE_Quote_Submit_For_Approval_Btn_Class.onClick();
    }

}
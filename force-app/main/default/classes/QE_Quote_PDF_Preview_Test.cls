@isTest(seeAllData=false)
public class QE_Quote_PDF_Preview_Test {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }
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
        lead.Email = 'test@test.com';
        lead.Lead_Type__c = 'Person';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        // Insert Test Oppt
        Opportunity oppTest = new Opportunity(Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '100%',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,StageName = 'Prospecting',CloseDate = System.today(), Send_Payment_Email__c=true);
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
        insert quoteTest;
        // Update Test Quote
        quoteTest.Status = 'Draft - Approved';
        Test.startTest();
        update quoteTest;
        // Attachment for Quote
        QuoteDocument quotedoc = New QuoteDocument();
        quotedoc.QuoteId = quoteTest.Id;
        quotedoc.Document = Blob.toPdf('Test Document');
        insert quoteDoc;
         Attachment attach1=new Attachment();   	
    	attach1.Name='Unit Test Attachment';
    	Blob bodyBlob1=Blob.valueOf('Unit Test Attachment Body');
    	attach1.body=bodyBlob1;
        attach1.parentId=quoteTest.id;
        insert attach1;
        Attachment attach = new Attachment();     
        // Attachment for docusign
        dsfs__DocuSign_Status__c docuSignStatus = new dsfs__DocuSign_Status__c();
        docuSignStatus.Standard_Quote__c = quoteTest.Id;
        insert docuSignStatus;
        attach.Name = 'Test Attachment';
        Blob bodyBlob = Blob.valueOf('Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = docuSignStatus.Id;
        insert attach;
        // Call controller
        // DRAFT
        PageReference QE_Quote_PDF_Preview = Page.QE_Quote_PDF_Preview;
        Test.setCurrentPage(QE_Quote_PDF_Preview);
        QE_Quote_PDF_Preview.getParameters().put('qid',quoteTest.Id);
        QE_Quote_PDF_Preview.getParameters().put('pdftype','draft');
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteTest);
        QE_Quote_PDF_Preview qeQuotePDFPreview = new QE_Quote_PDF_Preview(sc);
        // SIGNED
        PageReference QE_Quote_PDF_Preview2 = Page.QE_Quote_PDF_Preview;
        Test.setCurrentPage(QE_Quote_PDF_Preview2);
        QE_Quote_PDF_Preview2.getParameters().put('qid',quoteTest.Id);
        QE_Quote_PDF_Preview2.getParameters().put('pdftype','signed');
        ApexPages.StandardController sc2 = new ApexPages.StandardController(quoteTest);
        QE_Quote_PDF_Preview qeQuotePDFPreview2 = new QE_Quote_PDF_Preview(sc2);
        // Call controller methods
        qeQuotePDFPreview2.closePopup();
    }
}
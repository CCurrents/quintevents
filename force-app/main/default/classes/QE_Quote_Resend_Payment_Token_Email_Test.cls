@isTest(seeAllData=false)
public class QE_Quote_Resend_Payment_Token_Email_Test {
    public static testMethod void startTestMethod1() {
        // Test Data
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
        Insert eventTest;
        // Insert Test Account
        Account accTest = new Account(Name = 'testAccount');
        insert accTest;
        // Insert Test Oppt
        Opportunity oppTest = new Opportunity(Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '100%',AccountId = accTest.Id,Event__c = eventTest.Id,StageName = 'Prospecting',CloseDate = System.today(), Send_Payment_Email__c=true);
        insert oppTest;
        // Insert Test Quote
        Quote quoteTest = new Quote(
            Name = 'test',
            Status='Signed - Approved', 
            Payment_Method__c = 'Credit Card',
            OpportunityId = oppTest.Id,
            Email = 'jeetpatel24@quintevents.com',
            Payment_Terms__c = '100%',
            Payment_Page_Access_Token__c = 'adfsdg3ewfbv2eswsdfeefer',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert quoteTest;
        // Update Test Quote
        quoteTest.Status = 'Signed - Approved';
        update quoteTest;
        // Call controller
        PageReference QE_Quote_Resend_Payment_Token_Email_Page = Page.QE_Quote_Resend_Payment_Token_Email;
        Test.setCurrentPage(QE_Quote_Resend_Payment_Token_Email_Page);
        QE_Quote_Resend_Payment_Token_Email_Page.getParameters().put('qid',quoteTest.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteTest);
        QE_Quote_Resend_Payment_Token_Email qeQuoteResendTokenEmail = new QE_Quote_Resend_Payment_Token_Email(sc);
        // Call controller methods
        qeQuoteResendTokenEmail.resendPaymentTokenEmail();
        qeQuoteResendTokenEmail.closePopup();
    }
}
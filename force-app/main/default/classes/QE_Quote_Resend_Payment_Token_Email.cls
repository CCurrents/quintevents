public class QE_Quote_Resend_Payment_Token_Email {

    public Id qId;
    public Quote quote {get; set;}
    public Boolean displayPopup {get; set;}
    public String displayMsg {get; set;}
    public Boolean emailSent {get; set;}

    // Standard Constructor
    public QE_Quote_Resend_Payment_Token_Email(ApexPages.StandardController controller) {
        qId = ApexPages.currentPage().getParameters().get('qid');
        displayPopup = true;
        displayMsg = 'Click "Send" to resend payment token email, or click "Back to Quote" to go back.';
    }
    
    // Resend payment token email, This is called upon visiting QE_Resend_Payment_Token_Email
    public PageReference resendPaymentTokenEmail() {
        try {
            // Get quote data
            quote = [select Id, Email, Status, Payment_Method__c, Payment_Page_Access_Token__c, Opportunity.Owner.Id from Quote where Id = :qId];
            List<Quote> quotes = new List<Quote>();
            quotes.add(quote);
            Map<Id,Quote> oldMap = new Map<Id,Quote>();
            Quote tempOldQuote = new Quote();
            tempOldQuote.Id = quote.Id;
            tempOldQuote.Status = 'Not Needed';
            oldMap.put(quote.Id, tempOldQuote);
            // Compose email
            QE_EmailHelper emailHelper = new QE_EmailHelper();
            emailHelper.sendPaymentTokenEmails(quotes,oldMap);
            emailSent = true;
        } catch (Exception e) {
            System.debug('Exception: '+e);
        }
        displayMsg = 'Email sent.';
        // Redirect to quote page
        /*
        displayPopup = false;
        PageReference quotePage = new PageReference('/'+qId);
        quotePage.setRedirect(true);
        return quotePage;
        */
        return null;
    }
    
    // Close Popup
    public PageReference closePopup() {
        displayPopup = false;
        // Redirect to quote page
        PageReference quotePage = new PageReference('/'+qId);
        quotePage.setRedirect(true);
        return quotePage;
    }
    
}
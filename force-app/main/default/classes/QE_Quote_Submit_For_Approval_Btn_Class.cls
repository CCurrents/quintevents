public class QE_Quote_Submit_For_Approval_Btn_Class {

    public Id quoteId;
    public Quote quote;
    public Boolean displayPopup {get; set;}
    public Boolean displaycheckSubmit{get; set;}
    public String displayMsg {get; set;}
    public String pdfId {get; set;}

    public QE_Quote_Submit_For_Approval_Btn_Class(ApexPages.StandardController controller) {
        displayPopup = false;
        displaycheckSubmit = false;
        // Get quote id from url
        quoteId = ApexPages.currentPage().getParameters().get('quoteid');
        quote = [select Id, Status,Opportunity.AP_Contact_Email__c,Opportunity.AP_Contact_Name__c,Opportunity.RecordType.DeveloperName from Quote where Id = :quoteId];
    }
    
    public PageReference onClick() {
        if(quote.Opportunity.RecordType.DeveloperName == 'Business_Opportunity' && (string.isblank(quote.Opportunity.AP_Contact_Name__c) || string.isblank(quote.Opportunity.AP_Contact_Email__c))){
            displayPopup = true;
            displaycheckSubmit = false; 
            displayMsg = 'All AP(Accounts Payable) fields on Opportunity are required before submitting a Quote.';
            return null;
        }
        if (quote.Status.equals('Draft')) {
            List<Attachment> quoteAttch = new List<Attachment>([select id from Attachment where ParentId = :quoteId]);
            if(!quoteAttch.Isempty()){
                pdfId = quoteAttch[0].Id;
                displayPopup = false;
                displaycheckSubmit = true;                
            }else{
                displayPopup = true;
                displaycheckSubmit = false; 
                displayMsg = 'Quote PDF is still being generated, please reload this page.';
            }
            return null;
       } else {
            displayPopup = true;
            displaycheckSubmit = false;
            displayMsg = 'Quote status must be "Draft" before it can be submitted for approval.';
            return null;
        }
        
    }
    
    public PageReference updateQuoteStatus() {
        displayPopup = false;
        displaycheckSubmit = false;
        // Update quote status (This used to happen in QE_Quote_Trigger, after insert.)
        List<Id> quoteIds = new List<Id>();
        quoteIds.add(quoteId);
        QE_Quote_Helper.updateQuoteStatus(quoteIds, 'Quote-Trigger-AfterInsert');
        // Redirect back to quote page
        PageReference quotePage = new pageReference('/'+quoteId);
        quotePage.setRedirect(true);
        return quotePage;
    }
    
    public PageReference closePopup() {
        displayPopup = false;
        displaycheckSubmit = false;
        PageReference quotePage = new pageReference('/'+quoteId);
        quotePage.setRedirect(true);
        return quotePage;
    }

}
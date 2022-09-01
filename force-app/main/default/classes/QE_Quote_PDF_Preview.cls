public class QE_Quote_PDF_Preview {

    public Id qId;
    public String pdfType;
    public Quote quote {get; set;}
    public String pdfId {get; set;}
    
    // Standard Constructor
    public QE_Quote_PDF_Preview(ApexPages.StandardController controller) {
        qId = ApexPages.currentPage().getParameters().get('qid');
        pdfType = ApexPages.currentPage().getParameters().get('pdftype');
        quote = [select id, Status from Quote where Id = :qId];
        // Draft
        if (pdfType.equals('draft')) {
            //QuoteDocument quoteDoc = [select id from QuoteDocument where QuoteId = :qId];
            Attachment quoteAttch = [select id from Attachment where ParentId = :qId];
            pdfId = quoteAttch.Id;
        }
        // Signed
        if (pdfType.equals('signed')) {
            List<dsfs__DocuSign_Status__c> docuSignStatuses = [
                select Id, Name, dsfs__Envelope_Status__c, (select Id from Attachments)
                from dsfs__DocuSign_Status__c
                where Standard_Quote__c = :qId and dsfs__Envelope_Status__c = 'Completed'
                order by CreatedDate desc
            ];
            if (docuSignStatuses.size() > 0) {
                if(docuSignStatuses[0].attachments.size() > 0) {
                    pdfId = docuSignStatuses[0].attachments[0].Id;
                }
            }
        }
    }
    
    // Close Popup
    public PageReference closePopup() {
        // Redirect to quote page
        PageReference quotePage = new PageReference('/'+qId);
        quotePage.setRedirect(true);
        return quotePage;
    }
    
}
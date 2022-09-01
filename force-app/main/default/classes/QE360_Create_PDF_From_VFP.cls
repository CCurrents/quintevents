public class QE360_Create_PDF_From_VFP {
    
    public QE360_Create_PDF_From_VFP() {
    }

    public void createAndAttachPDF(String vfpName,  Id recordId, String outPutFileName) {
        PageReference pdfQuotePage = new PageReference('/apex/'+vfpName);
        pdfQuotePage.getParameters().put('id', recordId);
        Blob pdfBlob;
        if(Test.isRunningTest()) {
       		pdfBlob = Blob.valueOf('Unit Test Attachment Body');
        } else {
            pdfBlob = pdfQuotePage.getContent();
        }
        Attachment currentAttachment = new Attachment(parentId = recordId, name = outPutFileName+'.pdf', body = pdfBlob);
        insert currentAttachment;
    }
    
}
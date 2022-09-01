@isTest
global class QE_DocusignCounterSignMock_Test implements WebServiceMock {

    global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
         Map<String, DocusignSOAPApi2.RequestDocumentPDFsRecipientsViewResponse_element> response_map_x = new Map<String, DocusignSOAPApi2.RequestDocumentPDFsRecipientsViewResponse_element>();

        response.put('response_x', response_map_x);
               
   }
    
       global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           List<String> strings) {
        
                Map<String, DocusignSOAPApi2.RequestDocumentPDFsRecipientsViewResponse_element> response_map_x = new Map<String, DocusignSOAPApi2.RequestDocumentPDFsRecipientsViewResponse_element>();

        response.put('response_x', response_map_x);
               
   }
    
}
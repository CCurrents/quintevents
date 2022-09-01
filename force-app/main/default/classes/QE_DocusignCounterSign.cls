public class QE_DocusignCounterSign {
    
    // Sandbox
    /*
    public static String accountId = 'a293bb61-d323-4bbc-85ed-2c2942cee24e';
    public static String userId = 'support@quintevents.com'; // Same for Production and Sandbox
    public static String password = 'Quint.123'; // Sandbox: 
    public static String integratorsKey = 'a3d1dbe6-e114-4dcf-bf55-64156ee6b310'; // Same for Production and Sandbox
    public static String webServiceUrl = 'https://demo.docusign.net/api/3.0/dsapi.asmx'; 
    */
    
    // Production
    
    public static String accountId = 'd3b120f3-ec23-4b99-a3b3-b21cc682e3e1';
    public static String userId = 'docusign@quintevents.com'; // Same for Production and Sandbox
    public static String password = 'Quint@123'; 
    public static String integratorsKey = 'a3d1dbe6-e114-4dcf-bf55-64156ee6b310'; // Same for Production and Sandbox
    public static String webServiceUrl = 'https://na2.docusign.net/api/3.0/dsapi.asmx';
    
    
    @InvocableMethod(label='Send for Counter Signing' description='Sends docusign envelopes for counter signing.')
    public static void sendForCounterSigning(List<Quote> newList) {
        System.debug('sendForCounterSigning called'+newList);
        // Get Quote ids for Signed - Approved
        Set<Id> signedQuoteIds = new Set<Id>();
        Map<Id,String> quoteIdsToQuoteEmails = new Map<Id,String>();
        Map<Id,String> quoteIdsToBillingName = new Map<Id,String>();
        for(Quote quote : newList) {
            if((quote.Status).equals('Signed - Approved')) {
                signedQuoteIds.add(quote.Id);
                quoteIdsToQuoteEmails.put(quote.Id,quote.Email);
                quoteIdsToBillingName.put(quote.Id,quote.BillingName);
            }
        }
        System.debug('quoteIdsToQuoteEmails:'+quoteIdsToQuoteEmails);
        // Get Docusign Status
        Map<Id, dsfs__DocuSign_Status__c> docusignStatusMap = new Map<Id, dsfs__DocuSign_Status__c>([
            Select Id, Has_Counter_Signer__c, Standard_Quote__c, Standard_Quote__r.Event__r.Event_Manager__r.DS_Signing_Group_Id__c
            From dsfs__DocuSign_Status__c
            Where Standard_Quote__c in :signedQuoteIds And dsfs__Envelope_Status__c =: 'Completed' And Has_Counter_Signer__c =: true
        ]);
        // Create Map of docusint status ids and quote ids.
        Map<Id, Id> CompletedDocusignStatusAndQuoteIdMap = new Map<Id, Id>();
        Map<Id, String> QuoteIdToSigningGroupId = new Map<Id, String>();
        for (dsfs__DocuSign_Status__c dsStatus : docusignStatusMap.values()) {
            CompletedDocusignStatusAndQuoteIdMap.put(dsStatus.Id,dsStatus.Standard_Quote__c);
            QuoteIdToSigningGroupId.put(dsStatus.Standard_Quote__c, dsStatus.Standard_Quote__r.Event__r.Event_Manager__r.DS_Signing_Group_Id__c);
        }
        System.debug('CompletedDocusignStatusAndQuoteIdMap:'+CompletedDocusignStatusAndQuoteIdMap);
        // Create and Send
        if(CompletedDocusignStatusAndQuoteIdMap.size() > 0) {
            createAndSendEnvelope(CompletedDocusignStatusAndQuoteIdMap,QuoteIdToSigningGroupId,quoteIdsToQuoteEmails,quoteIdsToBillingName);
        }
    }
    
    @future(callout=true)
    public static void createAndSendEnvelope(Map<Id,Id> CompletedDocusignStatusToSourceIdMap, Map<Id,String> QuoteIdToSigningGroupId, Map<Id,String> quoteIdsToQuoteEmails, Map<Id,String> quoteIdsToBillingName){
        Map<string, Attachment> statusToAttachmentMap=new Map<string, Attachment>();
        if(CompletedDocusignStatusToSourceIdMap!=null && CompletedDocusignStatusToSourceIdMap.size()>0){
            for( Attachment att: [select id, Body, ParentId, Name from Attachment where parentid in :CompletedDocusignStatusToSourceIdMap.keySet()]){
                statusToAttachmentMap.put(att.ParentId, att);
            }
            system.debug('statusToAttachmentMap::'+statusToAttachmentMap);
            for(Id statusId: CompletedDocusignStatusToSourceIdMap.keySet()){
                if(statusToAttachmentMap.get(statusId)!=null){
                    Attachment att=statusToAttachmentMap.get(statusId);
                    DocusignSOAPApi2.APIServiceSoap dsApiSend 
                        = new DocusignSOAPApi2.APIServiceSoap();
                    dsApiSend.endpoint_x = webServiceUrl;
                    String auth = '<DocuSignCredentials><Username>'+ userId 
                        +'</Username><Password>' + password 
                        + '</Password><IntegratorKey>' + integratorsKey 
                        + '</IntegratorKey></DocuSignCredentials>';
                    System.debug('Setting authentication to: ' + auth);
                    dsApiSend.inputHttpHeaders_x = new Map<String, String>();
                    dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', 
                                                     auth);
                    
                    // Envelope and Document
                    DocusignSOAPApi2.Envelope envelope=createEnvelope();
                    DocusignSOAPApi2.Document document=createDocument(att);
                    envelope.Documents = new DocusignSOAPApi2.ArrayOfDocument();
                    envelope.Documents.Document = new DocusignSOAPApi2.Document[1];
                    envelope.Documents.Document[0] = document;
                    
                    // Custom Fields - Mapping Envelope Fields and sObject Fields
                    DocusignSOAPApi2.CustomField fieldQuoteId = new DocusignSOAPApi2.CustomField(); 
                    fieldQuoteId.Name = 'DSFSSourceObjectId'; 
                    fieldQuoteId.Value = CompletedDocusignStatusToSourceIdMap.get(statusId); // Setting Standard_Quote__c
                    fieldQuoteId.Show = 'false';
                    DocusignSOAPApi2.CustomField fieldCounterSignerEnvelope = new DocusignSOAPApi2.CustomField (); 
                    fieldCounterSignerEnvelope.Name = 'CounterSignerEnvelope'; 
                    fieldCounterSignerEnvelope.Value = 'true';    // Setting Counter_Signer_Envelope__c
                    fieldCounterSignerEnvelope.Show = 'false';
                    DocusignSOAPApi2.ArrayOfCustomField arrayOfCustomField = new DocusignSOAPApi2.ArrayOfCustomField();
                    arrayOfCustomField.CustomField  = new DocusignSOAPApi2.CustomField[2];
                    arrayOfCustomField.CustomField[0] = fieldQuoteId;
                    arrayOfCustomField.CustomField[1] = fieldCounterSignerEnvelope;
                    envelope.CustomFields = arrayOfCustomField;
                    
                    // Recipient
                    envelope.Recipients = new DocusignSOAPApi2.ArrayOfRecipient();
                    envelope.Recipients.Recipient = new DocusignSOAPApi2.Recipient[2];
                    DocusignSOAPApi2.Recipient recipient = createRecipient(statusId,QuoteIdToSigningGroupId.get(CompletedDocusignStatusToSourceIdMap.get(statusId)), 'Signer', '', ''); // DS Status Id, Signing Group Id, Copy Counter Signer, BillingName        
                    envelope.Recipients.Recipient[0] = recipient;
                    System.debug('recipientCustomer:'+recipient);
                    // Carbon Copy
                    DocusignSOAPApi2.Recipient recipientCustomer = createRecipient(statusId,QuoteIdToSigningGroupId.get(CompletedDocusignStatusToSourceIdMap.get(statusId)), 'CarbonCopy', quoteIdsToQuoteEmails.get(CompletedDocusignStatusToSourceIdMap.get(statusId)), quoteIdsToBillingName.get(CompletedDocusignStatusToSourceIdMap.get(statusId))); // DS Status Id, Signing Group Id, Type (Carbon Copy), Billing Name        
                    envelope.Recipients.Recipient[1] = recipientCustomer;
                    System.debug('recipientCustomer:'+recipientCustomer);
                
                    string envelopeId ='';
                        
                    try {
                        DocusignSOAPApi2.EnvelopeStatus es = dsApiSend.CreateAndSendEnvelope(envelope);
                        envelopeId = es.EnvelopeID;
                    } catch ( CalloutException e) {
                        System.debug('Exception - ' + e);
                        envelopeId = 'Exception - ' + e;
                    }
                    
                }
                                
            }
        }
    }
    
    public static DocusignSOAPApi2.Envelope createEnvelope() {
        DocusignSOAPApi2.Envelope envelope = new DocusignSOAPApi2.Envelope();
        envelope.Subject = 'Executed Agreement';
        envelope.EmailBlurb = '';
        envelope.AccountId  = accountId; 
        return envelope;
    }
    
    public static DocusignSOAPApi2.Document createDocument(Attachment att){
        DocusignSOAPApi2.Document document = new DocusignSOAPApi2.Document();
        document.ID = 1;
        document.pdfBytes = EncodingUtil.base64Encode(att.Body);
        document.Name = 'Contract';
        document.FileExtension = 'pdf';
        return document;
        
    }
    
    public static DocusignSOAPApi2.Recipient createRecipient(Id statusId, String signingGroupId, String type, String customerEmail, String billingName){
        DocusignSOAPApi2.Recipient recipient = new DocusignSOAPApi2.Recipient();
        if(type.equals('Signer')) {
            recipient.ID = 1;
            recipient.Type_x = 'Signer';
            recipient.RoutingOrder = 1;
            recipient.Email = '';
            recipient.UserName = '';
            recipient.SigningGroupId = integer.valueof(signingGroupId); // Assign Event Manager's DS Signing Group Id
        }
        if(type.equals('CarbonCopy')) {
            recipient.ID = 2;
            recipient.Type_x = 'CarbonCopy';
            recipient.RoutingOrder = 2;
            recipient.Email = customerEmail; // Customer's email
            recipient.UserName = billingName;
        }
        return recipient;
    }
}
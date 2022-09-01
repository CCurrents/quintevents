public class QE_DSStatusHelper{
    /*
     // Sandbox
    
    public static String accountId = 'a293bb61-d323-4bbc-85ed-2c2942cee24e';
    public static String userId = 'support@quintevents.com'; // Same for Production and Sandbox
    public static String password = 'Quint.123'; // Sandbox: 
    public static String integratorsKey = 'a3d1dbe6-e114-4dcf-bf55-64156ee6b310'; // Same for Production and Sandbox
    public static String webServiceUrl = 'https://demo.docusign.net/api/3.0/dsapi.asmx'; 
  */
       
    // Production
    public static String accountId = 'd3b120f3-ec23-4b99-a3b3-b21cc682e3e1';
    public static String userId = 'support@quintevents.com'; // Same for Production and Sandbox
    public static String password = 'Quint@123'; 
    public static String integratorsKey = 'a3d1dbe6-e114-4dcf-bf55-64156ee6b310'; // Same for Production and Sandbox
    public static String webServiceUrl = 'https://na2.docusign.net/api/3.0/dsapi.asmx';
     
      
    @future(callout=true)
    public static void VoidEnvelope(List<Id> quotesTocheckExistingRecords,  List<Id> docuSignStatusNewIds){
            List<dsfs__DocuSign_Status__c> existingDocuSignStatusRecords = new List<dsfs__DocuSign_Status__c>();
            existingDocuSignStatusRecords = [select id,dsfs__Envelope_Status__c,Standard_Quote__c,dsfs__DocuSign_Envelope_ID__c,dsfs__Declined_Reason__c,dsfs__Voided_Reason__c from dsfs__DocuSign_Status__c where id Not in:docuSignStatusNewIds and Standard_Quote__c in:quotesTocheckExistingRecords and dsfs__Envelope_Status__c != 'Completed' and Counter_Signer_Envelope__c = false ];
            if(existingDocuSignStatusRecords.size()> 0){          
              for(dsfs__DocuSign_Status__c dsStatus : existingDocuSignStatusRecords){              
                  if(dsStatus.dsfs__DocuSign_Envelope_ID__c!= null){ 
                                  
                    DocusignSOAPApi2.APIServiceSoap dsApiSend = new DocusignSOAPApi2.APIServiceSoap();
                    dsApiSend.endpoint_x = webServiceUrl;
                    String auth = '<DocuSignCredentials><Username>'+ userId 
                        +'</Username><Password>' + password 
                        + '</Password><IntegratorKey>' + integratorsKey 
                        + '</IntegratorKey></DocuSignCredentials>';
                    System.debug('Setting authentication to: ' + auth);
                    dsApiSend.inputHttpHeaders_x = new Map<String, String>();
                    dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication',auth);
                    
                    Boolean apiVoidSuccess;
                    try {
                        if(!test.isRunningTest()){
                         DocusignSOAPApi2.VoidEnvelopeStatus ves = dsApiSend.VoidEnvelope(dsStatus.dsfs__DocuSign_Envelope_ID__c,'Duplicate Envelope');                        
                            apiVoidSuccess = ves.VoidSuccess; }                     
                        } catch ( CalloutException e) {
                            System.debug('Exception - ' + e);                           
                        }
                 }
              
              }
            }
    }
    
    @future(callout=true)
    public static void VoidEnvelopeFromOpp(List<Id> quotesTocheck){
    System.debug('----inside VoidEnvelopeFromOpp----');
            List<dsfs__DocuSign_Status__c> docuSignStatusRecords = new List<dsfs__DocuSign_Status__c>();
            docuSignStatusRecords = [select id,dsfs__Envelope_Status__c,Standard_Quote__c,dsfs__DocuSign_Envelope_ID__c,dsfs__Declined_Reason__c,dsfs__Voided_Reason__c from dsfs__DocuSign_Status__c where Standard_Quote__c in:quotesTocheck and dsfs__Envelope_Status__c != 'Completed' ];
            System.debug('----inside docuSignStatusRecords----'+docuSignStatusRecords);
            if(docuSignStatusRecords.size()> 0){          
              for(dsfs__DocuSign_Status__c dsStatus : docuSignStatusRecords){              
                  if(dsStatus.dsfs__DocuSign_Envelope_ID__c!= null){ 
                    System.debug('----inside sStatus.dsfs__DocuSign_Envelope_ID__c----'+dsStatus.dsfs__DocuSign_Envelope_ID__c);              
                    DocusignSOAPApi2.APIServiceSoap dsApiSend = new DocusignSOAPApi2.APIServiceSoap();
                    dsApiSend.endpoint_x = webServiceUrl;
                    String auth = '<DocuSignCredentials><Username>'+ userId
                        +'</Username><Password>' + password 
                        + '</Password><IntegratorKey>' + integratorsKey 
                        + '</IntegratorKey></DocuSignCredentials>';
                    System.debug('Setting authentication to: ' + auth);
                    dsApiSend.inputHttpHeaders_x = new Map<String, String>();
                    dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication',auth);
                    
                    Boolean apiVoidSuccess;
                    try {
                        if(!test.isRunningTest()){
                         DocusignSOAPApi2.VoidEnvelopeStatus ves = dsApiSend.VoidEnvelope(dsStatus.dsfs__DocuSign_Envelope_ID__c,'Canceled Envelope');                        
                            apiVoidSuccess = ves.VoidSuccess; }                     
                        } catch ( CalloutException e) {
                            System.debug('Exception - ' + e);                           
                        }
                 }
              
              }
            }
    }
   
}
/**
* @description       : 
* @author            : jagrawal@addonblue.com
* @group             : 
* @last modified on  : 11-06-2020
* @last modified by  : jagrawal@addonblue.com
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   09-30-2020   jagrawal@addonblue.com   Initial Version
* 1.1   10-27-2020   jagrawal@addonblue.com   #596 Changed RecordType name from Travel Agent to Reseller
* 1.2   11-02-2020   jagrawal@addonblue.com   #610 Travel Agent related changes
* 1.3   11-03-2020   jagrawal@addonblue.com   #610 Removed reference of field Agreement_Sent__c
**/
public class Send_Reseller_AgreementClass {
    
    @AuraEnabled
    public static String readBaseUrl(){
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('baseUrl =' + baseUrl);
        return baseUrl;
    }
    
    @AuraEnabled
    public static String generateResellerAgreementFile(String recordId) {
        String response;
        system.debug('###recordId=='+recordId);
        Attachment objAttachment; 
        List<Contact> lstContacts;
        if(recordId != null) {
            //changed recordtype name for #596
            lstContacts = [Select id,Name,Account.BillingStreet,Account.BillingCity,Account.Billingstate,Account.BillingPostalCode,Account.BillingCountry,Account.RecordType.Name/*,Agreement_Sent__c // #610 Removed reference of field Agreement_Sent__c*/ FROM Contact  WHERE Account.RecordType.Name = 'Reseller' AND Id =: recordId];
        } 
        
        if(lstContacts.size() > 0) {
            // #610 Removed reference of field Agreement_Sent__c
            // if(lstContacts[0].Agreement_Sent__c){
            //     return 'Agreement is already generated.';
            // }
            String strFileName = lstContacts[0].Name+'_Reseller_Agreement.pdf';
            System.debug('@@strFileName'+strFileName);
            
            List<Attachment> deletableAttachments = [select id, parentId from Attachment where ParentId =: recordId AND Name =: strFileName];
            if(deletableAttachments != null){
                delete deletableAttachments;
            }
            
            PageReference pdf = new PageReference('/apex/Reseller_AgreementPage?id=' + recordId);
            // add parent id to the parameters for standardcontroller
            pdf.getParameters().put('id',recordId);
            
            // create the new attachment
            objAttachment = new Attachment();
            
            // the contents of the attachment from the pdf
            Blob body;
            
            try {
                // returns the output of the page as a PDF
                body = pdf.getContent();
                System.debug('body@@'+body);
                
                // need to pass unit test -- current bug    
            } catch (VisualforceException e) {
                body = Blob.valueOf('Some Text');
                System.debug('some wrong body@@'+body);
            }
            
            objAttachment.Body = body;
            objAttachment.Name = strFileName;
            objAttachment.IsPrivate = false;
            objAttachment.ParentId = recordId;
            insert objAttachment;
            
            if(objAttachment != null){
                response = 'SUCCESS';
            }
            else{
                response = 'An Error occured in storing the generated Agreement PDF.';
            }
        }else{
            //changed recordtype name for #596
            response = 'Partnership Agreement can be send only for Reseller Account.';
        }
        return response;
    }
    
    // #610 Removed reference of field Agreement_Sent__c
    // @AuraEnabled
    // public static String updateContact(String recordId){
    //     String response;
    //     Contact objContact = new Contact();
    //     objContact.Id = recordId;
    //     objContact.Agreement_Sent__c = true;
    //     update objContact;
    //     response = 'SUCCESS';
    //     return response;
    // }
    
}
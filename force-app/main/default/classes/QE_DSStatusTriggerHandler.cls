public class QE_DSStatusTriggerHandler {

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public QE_DSStatusTriggerHandler(boolean isExecuting, integer size) {
       m_isExecuting = isExecuting;
       BatchSize = size;
    }

    // Handle After Update
    public void OnAfterUpdate(dsfs__DocuSign_Status__c[] oldList, dsfs__DocuSign_Status__c[] newList, Map<Id, dsfs__DocuSign_Status__c> oldMap, Map<Id, dsfs__DocuSign_Status__c> newMap) {
    //Quotes from envelopes which needs to be submitted for approval check.
        List<Id> quotesToSubmitForApprovalCheck = new List<Id>();
        List<Id> h4hQuoteIds = new List<Id>();
        // Check if envelope don't have counter singee if so submit quote for approval check.
        for(dsfs__DocuSign_Status__c dsStatus : newList) {
            if((dsStatus.dsfs__Envelope_Status__c).equals('Completed') && 
                !(oldMap.get(dsStatus.Id).dsfs__Envelope_Status__c).equals('Completed') &&
                !(dsStatus.Counter_Signer_Envelope__c)) {
                    // Submit for approval check
                    quotesToSubmitForApprovalCheck.add(dsStatus.Standard_Quote__c);
            }
            
            // 6/19/2019 Vishal Agrawal for H4h implementation
            if((dsStatus.dsfs__Envelope_Status__c).equals('Sent') && 
                !(oldMap.get(dsStatus.Id).dsfs__Envelope_Status__c).equals('Sent') && dsStatus.Standard_Quote__c != null) {
                // H4H Hotel Search Quotes
                h4hQuoteIds.add(dsStatus.Standard_Quote__c);
            }
        }
        // Submit for approval check
        if (quotesToSubmitForApprovalCheck.size() > 0) {
            // Convert set to list, because updateQuoteStatusDocuSign takes list as a parameter.
            List<Id> quoteIdsList = new List<Id>();
            quoteIdsList.addAll(quotesToSubmitForApprovalCheck);
            // Update Quote
            QE_Quote_Helper quoteHelper = new QE_Quote_Helper();
            QE_Quote_Helper.updateQuoteStatusDocuSign(quoteIdsList, 'DocuSign-Trigger-AfterUpdate');
        }
        
        if(h4hQuoteIds.size() > 0) {
            QE_H4HHotelProcess.h4hAvailbilityHotelSearch(h4hQuoteIds);
        }
        
    }

    // Handle After Insert
    public void OnAfterInsert(dsfs__DocuSign_Status__c[] newList,Map<Id, dsfs__DocuSign_Status__c> newMap) {

     //Quotes from envelopes which needs to be checked for existing docusign status records
        List<Id> quotesTocheckExistingRecords = new List<Id>();
        List<Id> docuSignStatusNewIds = new List<Id>();
        List<Id> h4hQuoteIds = new List<Id>();
        // Loop through Docusign and collect quote ids
        for (dsfs__DocuSign_Status__c dsStatus : newList) {
            if(dsStatus.Standard_Quote__c!= null){
              quotesTocheckExistingRecords.add(dsStatus.Standard_Quote__c);
              docuSignStatusNewIds.add(dsStatus.id);
            }
            
            // 6/19/2019 Vishal Agrawal for H4h implementation
            if((dsStatus.dsfs__Envelope_Status__c).equals('Sent') && dsStatus.Standard_Quote__c != null) {
                // H4H Hotel Search Quotes
                h4hQuoteIds.add(dsStatus.Standard_Quote__c);
            }
        }
       
        if(quotesTocheckExistingRecords.size()> 0){      
           QE_DSStatusHelper.VoidEnvelope(quotesTocheckExistingRecords,docuSignStatusNewIds);
        }
        
        if(h4hQuoteIds.size() > 0) {
            QE_H4HHotelProcess.h4hAvailbilityHotelSearch(h4hQuoteIds);
        }
    }
}
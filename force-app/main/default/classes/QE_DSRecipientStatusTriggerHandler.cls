public class QE_DSRecipientStatusTriggerHandler {

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public QE_DSRecipientStatusTriggerHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    // Handle After Update
    public void OnAfterUpdate(dsfs__DocuSign_Recipient_Status__c[] oldList, dsfs__DocuSign_Recipient_Status__c[] newList, Map<Id, dsfs__DocuSign_Recipient_Status__c> oldMap, Map<Id, dsfs__DocuSign_Recipient_Status__c> newMap) {
        /* Docusign envelope counter signing and approval check. */
        // Quotes from envelopes which needs to be submitted for approval check.
        Set<Id> quotesToSubmitForApprovalCheck = new Set<Id>();
        // Get extra data for docusign recipient status
        List<dsfs__DocuSign_Recipient_Status__c> dsRecipientStatusData = [
            Select id, dsfs__Recipient_Status__c, dsfs__DocuSign_Recipient_Email__c,
            	dsfs__Parent_Status_Record__r.Standard_Quote__r.Event__r.Event_Manager__r.Email,
            	dsfs__Parent_Status_Record__r.Standard_Quote__c
            From dsfs__DocuSign_Recipient_Status__c
            Where Id in : newList
        ];
		for (dsfs__DocuSign_Recipient_Status__c dsRecipientStatus : dsRecipientStatusData) {
        	// Check if the Recipient is Counter Signer AND Recipient Status is "Sent".
        	if ((dsRecipientStatus.dsfs__Recipient_Status__c == 'Sent' && oldMap.get(dsRecipientStatus.Id).dsfs__Recipient_Status__c != 'Sent') && // Checking previous value was not same as new value to prevent it from executing everytime its updated.
                (dsRecipientStatus.dsfs__DocuSign_Recipient_Email__c == dsRecipientStatus.dsfs__Parent_Status_Record__r.Standard_Quote__r.Event__r.Event_Manager__r.Email)
               )
            {
               	// Add quote id of envelope for approval check
            	quotesToSubmitForApprovalCheck.add(dsRecipientStatus.dsfs__Parent_Status_Record__r.Standard_Quote__c);
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
    }
    
}
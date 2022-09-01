trigger QE_EventPaymentTermTrigger on Event_Payment_Terms__c (after delete) {
	
    QE_EventPaymentTermsHelper eptHelper = new QE_EventPaymentTermsHelper();

    // After Delete
    if (Trigger.IsAfter && Trigger.IsDelete) {
        // Capture deleted event payment terms
        eptHelper.captureDeletedEventPaymentTerms(Trigger.old);
    }
    
}
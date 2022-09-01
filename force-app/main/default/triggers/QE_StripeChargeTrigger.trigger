trigger QE_StripeChargeTrigger on QE360_Stripe_Charge__c (after insert) {
    
    // After
    if (Trigger.isAfter) {
        // Insert
        if (Trigger.isInsert) {
            // Send Payment Confirmation Emails
            QE_EmailHelper emailHelper = new QE_EmailHelper();
            emailHelper.sendPaymentConfirmationEmails(Trigger.new);
        }
    }
    
}
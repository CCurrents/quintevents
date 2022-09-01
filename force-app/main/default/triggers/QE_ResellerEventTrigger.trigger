trigger QE_ResellerEventTrigger on Reseller_Event__c (after delete) {

    QE_ResellerEventHelper resellerEventHelper = new QE_ResellerEventHelper();

    // After Delete
    if (Trigger.IsAfter && Trigger.IsDelete) {
        // Capture deleted event payment terms
        resellerEventHelper.captureDeletedResellerEvents(Trigger.old);
    }

}
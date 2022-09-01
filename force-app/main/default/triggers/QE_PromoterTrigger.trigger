trigger QE_PromoterTrigger on Promoter__c (after delete) {

    QE_PromoterHelper promoterHelper = new QE_PromoterHelper();

    // After Delete
    if (Trigger.IsAfter && Trigger.IsDelete) {
        // Capture deleted event payment terms
        promoterHelper.captureDeletedPromoters(Trigger.old);
    }
    
}
trigger QE_opportunityProductPackageHotelTrigger on Opportunity_Product_Package_Hotel__c (after update, after delete) {
    
    // After
    if (Trigger.IsAfter) {
        QE_opportunityProductPackageHotelHelper opptProdPackHotelHelper = new QE_opportunityProductPackageHotelHelper();
        // Update
        if (Trigger.IsUpdate) {
            // Update Opportunity Total Here
            opptProdPackHotelHelper.afterUpdate(Trigger.oldMap, Trigger.newMap);
        }
        // Delete
        if (Trigger.IsDelete) {
            // Update Opportunity Total Here
            opptProdPackHotelHelper.afterDelete(Trigger.old);
        }
    }
    
}
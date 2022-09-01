public class QE_packageProductsHandler {

    // Update package products before insert
    public static void updatePackageProducts(List<Package_Products__c> newList) {
        Set<Id> product2Ids = new Set<Id>();
        for (Package_Products__c packageProduct : newList) {
            product2Ids.add(packageProduct.Products_and_Hotels__c);
        }
        Map<Id,Product2> product2Data = new Map<Id,Product2>([select Id, IsActive from Product2 where Id in :product2Ids]);
        for (Package_Products__c packageProduct : newList) {
            if (packageProduct.Products_and_Hotels__c != null) {
                packageProduct.Active__c = product2Data.get(packageProduct.Products_and_Hotels__c).IsActive;
            }
        }
    }
    
    // Update package cost, called in QE_Package_Products_trigger
    public static void updatePackageCost(Map<Id,Package_Products__c> oldMap, Map<Id,Package_Products__c> newMap) {
        // Get all package ids of which cost should be updated.
        Set<Id> packageIds = new Set<Id>();
        // Insert
        if (oldMap == null) {
            for (Package_Products__c packageProduct : newMap.values()) {
                packageIds.add(packageProduct.Package__c);
            }
        }
        // Update
        if (oldMap != null && newMap != null) {
            for (Package_Products__c packageProduct : newMap.values()) {
                // Check if Cost__c field changed
                //if (oldMap.get(packageProduct.Id).Cost__c != packageProduct.Cost__c) { // Commented because its not working if product2 Cost__c is changed.
                    packageIds.add(packageProduct.Package__c);
                //}
            }
        }
        // Delete
        if (newMap == null) {
            for (Package_Products__c packageProduct : oldMap.values()) {
                packageIds.add(packageProduct.Package__c);
            }
        }
        // If has packages to update
        if (packageIds.size() > 0) {
            // Get all related packages and their products
            List<Product2> packagesWithPackageProducts = [select id, (select id, Name, Cost__c from Package_Products__r where Product_Type__c != 'Hotels' and Active__c = true) from Product2 where Id in :packageIds];
            // For each package reset cost
            List<Product2> packagesToUpdate = new List<Product2>();
            for (Product2 pack : packagesWithPackageProducts) {
                // Reset Package Cost to 0
                pack.Cost__c = 0;
                for (Package_Products__c packkageProduct : pack.Package_Products__r) {
                    pack.Cost__c += packkageProduct.Cost__c;
                }
                packagesToUpdate.add(pack);
            }
            try {
                update packagesToUpdate;
            } catch (Exception e) {
                System.debug('Exception at line => '+e.getLineNumber()+' Message => '+e.getMessage());
            }
        }
    }
    
    // Capture deleted package product
    public static void captureDeletedPackageProduct(List<Package_Products__c> oldList) {
        List<QE_Deleted_Record__c> recordsBeingDeleted = new List<QE_Deleted_Record__c>();
        for (Package_Products__c packageProduct : oldList) {
            QE_Deleted_Record__c deletedRecord = new QE_Deleted_Record__c();
            deletedRecord.Name = packageProduct.Name;
            deletedRecord.DeletedId__c = packageProduct.Id;
            recordsBeingDeleted.add(deletedRecord);
        }
        try {
            insert recordsBeingDeleted;
        } catch (Exception e) {
            System.debug('Exception: '+e);
        }
    }
    
}
trigger QE_Package_Products_trigger on Package_Products__c (before insert, after insert, after update, after delete) {

    // Before
    if (Trigger.isBefore) {
        // Insert
        if (Trigger.isInsert) {
            QE_packageProductsHandler.updatePackageProducts(Trigger.New);
        }
    }
    
    // After
    if (Trigger.isAfter) {
        // Insert
        if (Trigger.isInsert) {
            // Update package cost (Trigger.oldMap not available here)
            QE_packageProductsHandler.updatePackageCost(Trigger.oldMap, Trigger.newMap);
            // Update package inventory when product is added to the package
            // get products from package products, create map and pass on data to updatePackageInventory method
            Set<Id> product2Ids = new Set<Id>();
            for (Package_Products__c packProd : Trigger.newMap.Values()) {
                product2Ids.add(packProd.Products_and_Hotels__c);
            }
            Map<Id, Product2> productIdsAndProducts = new Map<Id, Product2>([Select Id, Product_Type__c From Product2 Where Id in :product2Ids]);
            QE_productHandler.updatePackageInventory(null, productIdsAndProducts);
        }
        // Update
        if (Trigger.isUpdate) {
            // Update package cost
            QE_packageProductsHandler.updatePackageCost(Trigger.oldMap, Trigger.newMap);
        }
        // Delete
        if (Trigger.isDelete) {
            // Update package cost
            QE_packageProductsHandler.updatePackageCost(Trigger.oldMap, Trigger.newMap);
            QE_packageProductsHandler.captureDeletedPackageProduct(Trigger.old);
            // Update package inventory when product is added to the package
            // get products from package products, create map and pass on data to updatePackageInventory method
            System.debug('QE_Package_Products_trigger => Trigger.oldMap.Values(): '+Trigger.oldMap.Values());
            Set<Id> product2Ids = new Set<Id>();
            for (Package_Products__c packProd : Trigger.oldMap.Values()) {
                product2Ids.add(packProd.Products_and_Hotels__c);
            }
            Map<Id, Product2> productIdsAndProducts = new Map<Id, Product2>([Select Id, Product_Type__c From Product2 Where Id in :product2Ids]);
            System.debug('QE_Package_Products_trigger => productIdsAndProducts: '+productIdsAndProducts);
            QE_productHandler.updatePackageInventory(null, productIdsAndProducts);
        }
    }
    
    /*
    Set<Id> package_products = new Set<Id>();
    Set<Id> package_hotels = new Set<Id>();    
    for(Package_Products__c p : [Select Id,Name,Products_and_Hotels__c,Products_and_Hotels__r.Product_Type__c From Package_Products__c where Id IN:Trigger.new]){
        if(p.Products_and_Hotels__r.Product_Type__c == 'Products')
        {
            package_products.add(p.Products_and_Hotels__c);
        }
        else if(p.Products_and_Hotels__r.Product_Type__c == 'Hotels'){
            package_hotels.add(p.Products_and_Hotels__c);
        }
        
    }

    if(Trigger.IsInsert){     
        DataBase.executeBatch(new QE_sendRecordsToQuintEvents(package_products,'Product2','Packages_Products__c-Products','Insert'), 100);
        DataBase.executeBatch(new QE_sendRecordsToQuintEvents(package_hotels,'Product2','Packages_Products__c-Hotels','Insert'), 100);
    }
    if(Trigger.IsUpdate){
        DataBase.executeBatch(new QE_sendRecordsToQuintEvents(package_products,'Product2','Packages_Products__c-Products','Update'), 100);
        DataBase.executeBatch(new QE_sendRecordsToQuintEvents(package_hotels,'Product2','Packages_Products__c-Hotels','Update'), 100);        
    }
    */
}
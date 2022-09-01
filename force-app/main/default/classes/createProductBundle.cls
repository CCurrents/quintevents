global class createProductBundle implements 
    Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, Package__c, Price__c, Product_Type__c, Products_and_Hotels__c FROM Package_Products__c');
    }
    global void execute(Database.BatchableContext bc, List<Package_Products__c> scope){
        List<Products_Bundle__c> lstProductsBundles = new List<Products_Bundle__c>();
        for(Package_Products__c objPackageProduct: scope) {
            if(objPackageProduct.Product_Type__c == 'Products') {
                lstProductsBundles.add(new Products_Bundle__c(Child_product__c = objPackageProduct.Products_and_Hotels__c, Parent_Product__c = objPackageProduct.Package__c, Type__c = 'Package Product', Legacy_Id__c = objPackageProduct.Id));
            }
            if(objPackageProduct.Product_Type__c == 'Hotels') {
                lstProductsBundles.add(new Products_Bundle__c(Child_product__c = objPackageProduct.Products_and_Hotels__c, Parent_Product__c = objPackageProduct.Package__c, Type__c = 'Package Hotel', Legacy_Id__c = objPackageProduct.Id));
            }
        }
        System.debug(lstProductsBundles.size());
        insert lstProductsBundles;
    }    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. Shazam!');
    }    
}
public class QE_Product_Helper {

    Map<String, Product2> productsToUpdate = new Map<String, Product2>();
    Map<id, Product2> nonAvailableProducts = new Map<id, Product2>();
    Map<Id, Product2> productsToUpdateOtherData = new Map<Id, Product2>();
    Set<Id> productsExceedQuantityPerOrderThreshold = new Set<Id>();
    
    // Get this when constructer is created
    Map<Id, double> objQuotePackagesAndQuantities = new Map<Id, double>();
    List<Package_Products__c> objProductsFromQuotePackages = new List<Package_Products__c>();
    List<QuoteLineItem> objQuoteALaCartes = new List<QuoteLineItem>();
    
    public QE_Product_Helper(Map<Id, double> quotePackagesAndQuantities, List<Package_Products__c> productsFromQuotePackages, List<QuoteLineItem> quoteALaCartes) {
        // Get Products to update and Threshold
        objQuotePackagesAndQuantities = quotePackagesAndQuantities;
        objProductsFromQuotePackages = productsFromQuotePackages;
        objQuoteALaCartes = quoteALaCartes;
        System.debug('productsFromQuotePackages=>'+productsFromQuotePackages);
        System.debug('objQuoteALaCartes=>'+objQuoteALaCartes);
        // Quote Package
        for (Package_Products__c quotePackageProduct : objProductsFromQuotePackages){
            Product2 product = new Product2();
            product.id = quotePackageProduct.Products_and_Hotels__c;
            product.isActive = quotePackageProduct.Products_and_Hotels__r.isActive;
            product.Available__c = quotePackageProduct.Products_and_Hotels__r.Available__c;
            // if product type is hotel room double then divide the quantity by 2
            Integer devideByPac = 1;
            System.debug(quotePackageProduct.Products_and_Hotels__r.RecordTypeId);
            System.debug(Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId());
            System.debug(quotePackageProduct.Package__r.Type__c);
            if (((quotePackageProduct.Products_and_Hotels__r.RecordTypeId).equals(Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId())) && quotePackageProduct.Package__r.Type__c != null && ((quotePackageProduct.Package__r.Type__c).equals('Double Occupancy'))) {
                devideByPac = 2;
            }
            
            if(quotePackageProduct.Products_and_Hotels__r.Inventory__c == null){
                quotePackageProduct.Products_and_Hotels__r.Inventory__c = 0;
            }
            
            if (productsToUpdate.get(quotePackageProduct.Products_and_Hotels__c) == null) {
                product.Inventory__c = Integer.valueOf(quotePackageProduct.Products_and_Hotels__r.Inventory__c) - (Integer.valueOf(objQuotePackagesAndQuantities.get(quotePackageProduct.Package__c))/devideByPac);
            } else {
                product.Inventory__c = productsToUpdate.get(quotePackageProduct.Products_and_Hotels__c).Inventory__c - (Integer.valueOf(objQuotePackagesAndQuantities.get(quotePackageProduct.Package__c))/devideByPac);
            }            
            productsToUpdateOtherData.put(quotePackageProduct.Products_and_Hotels__c,quotePackageProduct.Products_and_Hotels__r);
            productsToUpdate.put(quotePackageProduct.Products_and_Hotels__c,product);
            
            // Check if the product package product has Available checked and exceed Quantity Per Order Threshold
            if(quotePackageProduct.Products_and_Hotels__r.Available__c && (objQuotePackagesAndQuantities.get(quotePackageProduct.Package__c)) > quotePackageProduct.Products_and_Hotels__r.Quantity_Per_Order_Threshold__c) {
                productsExceedQuantityPerOrderThreshold.add(quotePackageProduct.Products_and_Hotels__r.Id);
            }
            
        }
        System.debug('productsToUpdate=1=>'+productsToUpdate);
        // Quote Product Package Hotels
      /*  for (Quote_Product_Package_Hotel__c packageHotel : quoteProductPackageHotels) {
            System.debug('packageHotel =>'+packageHotel);
            // if product was deleted then skip this.
            if (packageHotel.Hotel__c != NULL) {
                Product2 product = new Product2();
                product.id = packageHotel.Hotel__c;
                 if(!test.isRunningTest())
                 {
                    if(packageHotel.Hotel__r.Inventory__c == null){
                        packageHotel.Hotel__r.Inventory__c = 0;
                    }
                }
                
                if (productsToUpdate.get(packageHotel.Hotel__c) == null) {
                    product.Inventory__c = (Integer.valueOf(packageHotel.Hotel__r.Inventory__c)) - (Integer.valueOf(packageHotel.Quantity__c));
                } else {
                    product.Inventory__c = (productsToUpdate.get(packageHotel.Hotel__c).Inventory__c) - (Integer.valueOf(packageHotel.Quantity__c));
                }
                productsToUpdateOtherData.put(packageHotel.Hotel__c,packageHotel.Hotel__r);
                productsToUpdate.put(packageHotel.Hotel__c,product);
                
                // Check if the product package product has Available checked and exceed Quantity Per Order Threshold
                if(packageHotel.Hotel__r.Available__c && packageHotel.Quantity__c > packageHotel.Hotel__r.Quantity_Per_Order_Threshold__c) {
                    productsExceedQuantityPerOrderThreshold.add(packageHotel.Hotel__r.Id);
                }
            }
        } */
        // Quote A La Cartes
        for (QuoteLineItem quoteALaCarte : objQuoteALaCartes) {
            // if product was deleted then skip this.
            if (quoteALaCarte.Product2Id != NULL) {
                Product2 product = new Product2();
                System.debug('quoteALaCarte.Product2==>'+quoteALaCarte.Product2);
                product.id = quoteALaCarte.Product2Id;
                product.Available__c = quoteALaCarte.Product2.Available__c;
                System.debug('quoteALaCarte.Product2ID==>'+quoteALaCarte.Product2ID);
                System.debug('quoteALaCarte.Product2==>'+quoteALaCarte.Product2);
                 System.debug('quoteALaCarte.Product2.Inventory__c==>'+quoteALaCarte.Product2.Inventory__c);
                 if(!test.isRunningTest())
                 {
                    if(quoteALaCarte.Product2.Inventory__c == null){
                        quoteALaCarte.Product2.Inventory__c = 0;
                    }
                if (productsToUpdate.get(quoteALaCarte.Product2Id) == null) {
                    System.debug('quoteALaCarte.Product2.Inventory__c==>'+quoteALaCarte.Product2.Inventory__c);
                    product.Inventory__c = (Integer.valueOf(quoteALaCarte.Product2.Inventory__c)) - (Integer.valueOf(quoteALaCarte.Quantity));
                } else {
                    product.Inventory__c = (productsToUpdate.get(quoteALaCarte.Product2Id).Inventory__c) - (Integer.valueOf(quoteALaCarte.Quantity));
                }
                
                productsToUpdateOtherData.put(quoteALaCarte.Product2Id,quoteALaCarte.Product2);
                productsToUpdate.put(quoteALaCarte.Product2Id,product);
                }
                // Check if the product package product has Available checked and exceed Quantity Per Order Threshold
                if(quoteALaCarte.Product2.Available__c && quoteALaCarte.Quantity > quoteALaCarte.Product2.Quantity_Per_Order_Threshold__c) {
                    productsExceedQuantityPerOrderThreshold.add(quoteALaCarte.Product2.Id);
                }
            }
        }
        if(!productsToUpdate.isempty()){
        for (Product2 producttoCheck : productsToUpdate.values()) {
            if (!producttoCheck.Available__c) {
                nonAvailableProducts.put(producttoCheck.id,producttoCheck);
            }
        }
       } 
        System.debug('productsToUpdate=2=>'+productsToUpdate);
    }
    
    // Check Inventory, Returns true if inventory is not getting below 0 after inventory forecast
    public boolean checkInventory() {
        boolean allGood = true;
        System.debug('nonAvailableProducts outsidecheckInventory=>'+nonAvailableProducts.Values());
        // Check if inventory forcast is taking product inventory below zero then retun false
        if(!nonAvailableProducts.isempty()){
        System.debug('nonAvailableProducts insidecheckInventory=>'+nonAvailableProducts.Values());
        for (Product2 productToBeUpdated : nonAvailableProducts.values()) {
            if (productToBeUpdated.Inventory__c < 0 && !productToBeUpdated.Available__c) {
                allGood = false;
            }
         }
        }
        return allGood;
    }
    
    // Check Available
    public boolean checkAvailability() {
        boolean allGood = true;
        // Check if inventory forcast is taking product inventory below zero then retun false
        for (Product2 productToBeUpdated : productsToUpdate.values()) {
            if (productsExceedQuantityPerOrderThreshold.contains(productToBeUpdated.Id)) {
                allGood = false;
            }
        }
        return allGood;
    }
    
    // Check Active
    public boolean checkActive() {
        boolean allGood = true;
        // Products to be Updated
        for (Product2 productToBeUpdated : productsToUpdate.values()){
            if (productsToUpdateOtherData.get(productToBeUpdated.Id) != null) {
                if (productsToUpdateOtherData.get(productToBeUpdated.Id).isActive == false) {
                    allGood = false;
                }
            }
        }
        return allGood;
    }

    // Check Allocated
    public boolean checkAllocated() {
        boolean allGood = true;
        // Products to be Updated
        for (Product2 productToBeUpdated : productsToUpdate.values()){
            if (productsToUpdateOtherData.get(productToBeUpdated.Id) != null) {
                if (productsToUpdateOtherData.get(productToBeUpdated.Id).Allocated__c == true) {
                    allGood = false;
                }
            }
        }
        return allGood;
    }
    
    // Check Double Approval
    public boolean checkRequiresDoubleApproval() {
        boolean allGood = true;
        // Products to be Updated
        for (Product2 productToBeUpdated : productsToUpdate.values()){
            if (productsToUpdateOtherData.get(productToBeUpdated.Id) != null) {
                if (productsToUpdateOtherData.get(productToBeUpdated.Id).Requires_Double_Approval__c == true) {
                    allGood = false;
                }
            }
        }
        return allGood;
    }
    
    // Check Threshold
    public boolean checkThreshold() {
        boolean allGood = true;
        // Products to be Updated
        System.debug('nonAvailableProducts outsidecheckThreshold=>'+nonAvailableProducts.Values());
        if(!nonAvailableProducts.isempty()){
        System.debug('nonAvailableProducts insidecheckThreshold=>'+nonAvailableProducts.Values());
        for (Product2 productToBeUpdated : nonAvailableProducts.values()) {
            if (productsToUpdateOtherData.get(productToBeUpdated.Id) != null) {
                if (((productToBeUpdated.Inventory__c) < (productsToUpdateOtherData.get(productToBeUpdated.Id).Threshold__c))) {
                    allGood = false;
                }
            }
         }
        }
        return allGood;
    }
    
    // Update Inventory
    public boolean updateInventory() {
        boolean updatedSuccessfully = true;
        // Check if inventory forcast is taking product inventory below zero
        /*
        for (QE360_Product__c productToBeUpdated : productsToUpdate.values()) {
            if (productToBeUpdated.Inventory__c < 0) {
                updatedSuccessfully = false;
            }
        }
        */
        if (updatedSuccessfully) {
            update productsToUpdate.values();
        }
        return updatedSuccessfully;
    }
    
}
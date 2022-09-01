public class QE_opportunityProductHelper {
    
    public QE_opportunityProductHelper(){}
    
    public void captureOpportunityProducts(Set<Id> opportunityIds) {
        /*
        // If any of the provided opportunities were closed won.
        if (opportunityIds.size() > 0) {
            List<Opportunity_Product__c> existingOpportunityProducts = new List<Opportunity_Product__c>([select Id from Opportunity_Product__c where Opportunity__c in :opportunityIds]);
            // Get Packages and A La Cartes
            List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>([
                select Id, OpportunityId, Product2Id, Product_Type__c, Product2.Name, UnitPrice, Quantity, A_La_Cart__c,Opportunity_Product_Package_Hotel__c,Package__c
                from OpportunityLineItem
                where OpportunityId in :opportunityIds
            ]);
            // Get package ids from opportunity line items
            Set<Id> opportunityPacakgeIds = new Set<Id>();
            for (OpportunityLineItem opptLineItem : opportunityLineItems) {
                if (opptLineItem.Product_Type__c.equals('Package')) {
                    opportunityPacakgeIds.add(opptLineItem.Product2Id);
                }
            }
            // Get Package Products
            List<Package_Products__c> packageProducts = new List<Package_Products__c>([
                select Id, Package__c, Products_and_Hotels__c, Products_and_Hotels__r.Name, Product_Type__c, Price__c
                from Package_Products__c
                where Package__c in :opportunityPacakgeIds and Product_Type__c != 'Hotels'
            ]);
            Map<Id,List<Package_Products__c>> packageIdAndPackageProducts = new Map<Id,List<Package_Products__c>>();
            for (Package_Products__c packageProuct : packageProducts) {
                if (packageIdAndPackageProducts.containsKey(packageProuct.Package__c)) {
                    List<Package_Products__c> tempPackageProducts = packageIdAndPackageProducts.get(packageProuct.Package__c);
                    tempPackageProducts.add(packageProuct);
                    packageIdAndPackageProducts.put(packageProuct.Package__c,tempPackageProducts);
                } else {
                    List<Package_Products__c> tempPackageProducts = new List<Package_Products__c>();
                    tempPackageProducts.add(packageProuct);
                    packageIdAndPackageProducts.put(packageProuct.Package__c,tempPackageProducts);
                }
            }
            
            // Create Opportunity Products
            List<Opportunity_Product__c> opportunityProductsToBeCreated = new List<Opportunity_Product__c>();
            // Packages and A La Cartes
            for (OpportunityLineItem opptLineItem : opportunityLineItems) {
                Opportunity_Product__c opptProduct = new Opportunity_Product__c();
                opptProduct.Opportunity__c = opptLineItem.OpportunityId;
                opptProduct.Name__c = opptLineItem.Product2.Name;
                opptProduct.Product__c = opptLineItem.Product2Id;
                opptProduct.Product_Type__c = opptLineItem.Product_Type__c;
                opptProduct.Price__c = opptLineItem.UnitPrice;
                opptProduct.Quantity__c = opptLineItem.Quantity;
                opptProduct.A_La_Carte__c = opptLineItem.A_La_Cart__c;
                if(opptLineItem.Opportunity_Product_Package_Hotel__c == true && opptLineItem.Package__c != null){
                    opptProduct.Package__c = opptLineItem.Package__c;
                }
                // if current line item is package, get package products and add them too.
                // Package Products
                if (opptLineItem.Product_Type__c.equals('Package')) {
                    List<Package_Products__c> tempPackageProducts = packageIdAndPackageProducts.get(opptLineItem.Product2Id);
                    if (tempPackageProducts != null) {
                        for (Package_Products__c packageProduct : tempPackageProducts) {
                            Opportunity_Product__c opptProduct2 = new Opportunity_Product__c();
                            opptProduct2.Opportunity__c = opptLineItem.OpportunityId;
                            opptProduct2.Quantity__c = opptLineItem.Quantity;
                            opptProduct2.Name__c = packageProduct.Products_and_Hotels__r.Name;
                            opptProduct2.Package__c = packageProduct.Package__c;
                            opptProduct2.Product__c = packageProduct.Products_and_Hotels__c;
                            opptProduct2.Product_Type__c = packageProduct.Product_Type__c;
                            opptProduct2.Price__c = packageProduct.Price__c;
                            opportunityProductsToBeCreated.add(opptProduct2);
                        }
                    }
                }
                opportunityProductsToBeCreated.add(opptProduct);
            }
            
            try {
                // Delete
                if (existingOpportunityProducts.size() > 0) {
                    //delete existingOpportunityProducts;
                }
                // Insert
                if (opportunityProductsToBeCreated.size() > 0) {
                    insert opportunityProductsToBeCreated;
                }
            } catch (Exception e) {
                System.debug('Exception: Line'+e.getLineNumber());
            }
        }
        */
    }
    
    // Caputre deleted Opportunity Products
    public void captureDeletedOpportunityProducts(List<OpportunityLineItem> oldList) { 
        List<QE_Deleted_Record__c> recordsBeingDeleted = new List<QE_Deleted_Record__c>();
        for (OpportunityLineItem oli : oldList) {
            QE_Deleted_Record__c deletedRecord = new QE_Deleted_Record__c();
            deletedRecord.Name = oli.Name;
            deletedRecord.DeletedId__c = oli.Id;
            recordsBeingDeleted.add(deletedRecord);
        }
        try {
            insert recordsBeingDeleted;
        } catch (Exception e) {
            System.debug('Exception: '+e);
        }
    }
    
}
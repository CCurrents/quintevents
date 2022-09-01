public class QE_opportunityProductPackageHotelHelper {
    
    public QE_opportunityProductPackageHotelHelper(){}
    
    // After Update
    public void afterUpdate(Map<Id,Opportunity_Product_Package_Hotel__c> opportunityProductPackageHotelsOld, Map<Id,Opportunity_Product_Package_Hotel__c> opportunityProductPackageHotelsNew) {
        Map<Id,List<Opportunity_Product_Package_Hotel__c>> opptIdsAndPackIdWithOpptProdPackHotels = getOpptIdsAndOpptProductPackageHotels(opportunityProductPackageHotelsNew.values());
        List<OpportunityLineItem> opportunityPackages = getOpportunityPackages(opportunityProductPackageHotelsNew.values());
        // Update Opportunity Packages
        List<OpportunityLineItem> opportunityPackagesToUpdate = new List<OpportunityLineItem>();
        for (OpportunityLineItem opportunityPackage : opportunityPackages) {
            // For each Opportunity get Opportunity Product Package Hotels
            for (Opportunity_Product_Package_Hotel__c hotel : opptIdsAndPackIdWithOpptProdPackHotels.get(opportunityPackage.Opportunity.Id)) {
                opportunityPackage.ApexHotelTotalPrice__c = opportunityPackage.ApexHotelTotalPrice__c - (hotel.Price__c * opportunityProductPackageHotelsOld.get(hotel.Id).Quantity__c);
                opportunityPackage.ApexHotelTotalPrice__c = opportunityPackage.ApexHotelTotalPrice__c + (hotel.Price__c * opportunityProductPackageHotelsNew.get(hotel.Id).Quantity__c);
            }
            if (opportunityPackage.ApexHotelTotalPrice__c < 0) {
                // Going to Negative number, set to 0
                opportunityPackage.ApexHotelTotalPrice__c = 0.00;
            }
            opportunityPackagesToUpdate.add(opportunityPackage);
        }
        try {
            update opportunityPackagesToUpdate;
        } catch (Exception e) {
            System.debug('Exception Line:'+e.getLineNumber()+' Message:'+e.getMessage());
        }
    }
    
    // After Delete
    public void afterDelete(List<Opportunity_Product_Package_Hotel__c> opportunityProductPackageHotels) {
        Map<Id,List<Opportunity_Product_Package_Hotel__c>> opptIdsAndPackIdWithOpptProdPackHotels = getOpptIdsAndOpptProductPackageHotels(opportunityProductPackageHotels);
        List<OpportunityLineItem> opportunityPackages = getOpportunityPackages(opportunityProductPackageHotels);
        // Update Opportunity Packages
        List<OpportunityLineItem> opportunityPackagesToUpdate = new List<OpportunityLineItem>();
        for (OpportunityLineItem opportunityPackage : opportunityPackages) {
            // For each Opportunity get Opportunity Product Package Hotels
            for (Opportunity_Product_Package_Hotel__c hotel : opptIdsAndPackIdWithOpptProdPackHotels.get(opportunityPackage.Opportunity.Id)) {
                opportunityPackage.ApexHotelTotalPrice__c = opportunityPackage.ApexHotelTotalPrice__c - (hotel.Price__c * hotel.Quantity__c);
            }
            if (opportunityPackage.ApexHotelTotalPrice__c < 0) {
                // Going to Negative number, set to 0
                opportunityPackage.ApexHotelTotalPrice__c = 0.00;
            }
            opportunityPackagesToUpdate.add(opportunityPackage);
        }
        try {
            update opportunityPackagesToUpdate;
        } catch (Exception e) {
            System.debug('Exception Line:'+e.getLineNumber()+' Message:'+e.getMessage());
        }
    }
    
    // Opportunity Ids and Opportunity Product Package Hotels
    public Map<Id,List<Opportunity_Product_Package_Hotel__c>> getOpptIdsAndOpptProductPackageHotels(List<Opportunity_Product_Package_Hotel__c> opportunityProductPackageHotels) {
        Map<Id,List<Opportunity_Product_Package_Hotel__c>> opptIdsAndPackIdWithOpptProdPackHotels = new Map<Id,List<Opportunity_Product_Package_Hotel__c>>();
        for (Opportunity_Product_Package_Hotel__c opptProdPackHotel : opportunityProductPackageHotels) {
            // If oppt already added to map
            List<Opportunity_Product_Package_Hotel__c> opptProdPackHotels;
            if (opptIdsAndPackIdWithOpptProdPackHotels.containsKey(opptProdPackHotel.Opportunity__c)) {
                // Get exisitng innder list
                opptProdPackHotels = opptIdsAndPackIdWithOpptProdPackHotels.get(opptProdPackHotel.Opportunity__c);
            } else {
                // Create new inner list
                opptProdPackHotels = new List<Opportunity_Product_Package_Hotel__c>();
            }
            // Add to inner map
            opptProdPackHotels.add(opptProdPackHotel);
            // Add to outer map
            opptIdsAndPackIdWithOpptProdPackHotels.put(opptProdPackHotel.Opportunity__c,opptProdPackHotels);
        }
        return opptIdsAndPackIdWithOpptProdPackHotels;
    }

    // Opportunity Packages related to Opportunity Product Package Hotels
    public List<OpportunityLineItem> getOpportunityPackages(List<Opportunity_Product_Package_Hotel__c> opportunityProductPackageHotels) {
        Set<Id> packageIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        for (Opportunity_Product_Package_Hotel__c opptProdPackHotel : opportunityProductPackageHotels) {
            packageIds.add(opptProdPackHotel.Package__c);
            opportunityIds.add(opptProdPackHotel.Opportunity__c);
        }
        // Get Opportunity Packages related to the Opportunity Package Hotels
        List<OpportunityLineItem> opportunityPackages = new List<OpportunityLineItem>();
        System.debug('packageIds => '+packageIds);
        System.debug('opportunityIds => '+opportunityIds);
        if (opportunityIds.size() > 0) {
            opportunityPackages = [
                select Id, Opportunity.Id, ApexHotelTotalPrice__c
                from OpportunityLineItem
                where Product2.Id in :packageIds
                and Opportunity.Id in :opportunityIds
                and Product_Type__c = 'Package'
            ];
        }
        return opportunityPackages;
    }
}
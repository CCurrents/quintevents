public class QE360_Opportunity_Package_Helper {

    // Constructor 
    public QE360_Opportunity_Package_Helper() {
    }
    
    // Create
    public void createOpportunityPackages() {
    }
    
    // Update
    public void updateOpportunityPackages(List<QE360_Opportunity_Package__c> opportunityPackages, Map<Id, QE360_Opportunity_Package__c> opportunityPackagesRelatedData) {
        for (QE360_Opportunity_Package__c currentOpportunityPackage : opportunityPackages) {
            double totalQuantityPrice = (currentOpportunityPackage.Quantity__c ) * (currentOpportunityPackage.Price__c);
            double totalShippingAndHandling;
            if (opportunityPackagesRelatedData.get(currentOpportunityPackage.Id).Package__r.Apply_SAndH_Per_Quantity__c) {
                totalShippingAndHandling = (currentOpportunityPackage.Quantity__c) * (currentOpportunityPackage.Shipping_And_Handling__c);
            } else {
                totalShippingAndHandling = currentOpportunityPackage.Shipping_And_Handling__c;
            }
            double totalQuantityPricePlusSAndH = Double.valueOf((totalQuantityPrice)) + (totalShippingAndHandling);
            double totalTax = ((totalQuantityPricePlusSAndH) * (currentOpportunityPackage.Tax_Percentage__c)) / 100;
            currentOpportunityPackage.Total_Shipping_and_Handling__c = totalShippingAndHandling;
            currentOpportunityPackage.Total_Tax__c = totalTax;
            currentOpportunityPackage.Sub_Total__c = Double.valueOf((totalQuantityPricePlusSAndH)) + (totalTax);
        }
    }

}
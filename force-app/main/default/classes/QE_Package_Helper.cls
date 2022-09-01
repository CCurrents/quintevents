public class QE_Package_Helper {

    public List<QuoteLineItem> quoteAndQuotePackages = new List<QuoteLineItem>();
        
    public QE_Package_Helper(List<QuoteLineItem> tempAndQuotePackages) {
        for(QuoteLineItem item:tempAndQuotePackages)
        {            
            if(item.Product_Type__c=='Package')
            quoteAndQuotePackages.add(item);
        }
    }
    
    // Check if all packages in quote are active
    public boolean checkActive() {
        boolean allGood = true;
        // Packages to be Updated
        for (QuoteLineItem quotePackage : quoteAndQuotePackages){
            if (quotePackage.Product2.isActive == false) {
                allGood = false;
            }
        }
        return allGood;
    }
    
    // Check if any of the package in quote requires double approval
    public boolean checkRequiresApprovalUponSignature() {
        boolean allGood = true;
        // Packages to be Updated
        for (QuoteLineItem quotePackage : quoteAndQuotePackages){
            if (quotePackage.Product2.Requires_Approval_Upon_Signature__c == true) {
                allGood = false;
            }
        }
        return allGood;
    }
    
}
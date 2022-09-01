public class QE360_Extra_Customer {
    
    public QE360_Extra_Customer__c extraCustomer { get; private set; }
    private ApexPages.StandardController stdController;
    
    // Get/New Event
    public QE360_Extra_Customer(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        this.extraCustomer = (QE360_Extra_Customer__c)stdController.getRecord();
        // If New product
        if (extraCustomer.Id == null) {
            extraCustomer.Opportunity__c = ApexPages.currentPage().getParameters().get('Opportunity__c');
            Integer totalExtraCustomers = Integer.valueof(ApexPages.currentPage().getParameters().get('totalExtraCustomer')) + 2; // 1 for original customer, 1 for the customer being added.
            extraCustomer.Amount__c = Double.valueOf(ApexPages.currentPage().getParameters().get('Grand_Total__c'))/(totalExtraCustomers);
        }
    }

    // Save: Opportunuty
    public PageReference addToOpportunity() {
        // Save
        upsert extraCustomer;
        
        // Redirect
        PageReference page = new PageReference('/'+extraCustomer.Opportunity__c);
        page.setRedirect(true); 
        return page;
    }
    
}
public class QE360_Opportunity_Signee {
    
    public QE360_Opportunity_Additional_Signee__c opptAdditionalSignee { get; private set; }
    private ApexPages.StandardController stdController;
    QE360_Stripe_Customer_Helper qescHelper = new QE360_Stripe_Customer_Helper();
    
    // Get/New Event
    public QE360_Opportunity_Signee(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        this.opptAdditionalSignee = (QE360_Opportunity_Additional_Signee__c)stdController.getRecord();
        // If New record
        if (opptAdditionalSignee.Id == null) {
            opptAdditionalSignee.Opportunity__c = ApexPages.currentPage().getParameters().get('Opportunity__c');
            Integer totalAdditionalSignees = Integer.valueof(ApexPages.currentPage().getParameters().get('totalAdditionalSignees')) + 2; // 1 for original customer, 1 for the customer being added.
            opptAdditionalSignee.Amount__c = Double.valueOf(ApexPages.currentPage().getParameters().get('Grand_Total__c'))/(totalAdditionalSignees);
        }
    }

    // Save: Opportunuty
    public PageReference addToOpportunity() {
        
        // If qe stripe customer exist
		QE360_Stripe_Customer__c qeStripeCustomer = qescHelper.getQEStripeCustomer(opptAdditionalSignee.Email__c);
        if (qeStripeCustomer == null) {
            // create new qe stripe customer with current signee's email
            QE360_Stripe_Customer__c newQEStripeCustomer = new QE360_Stripe_Customer__c();
            newQEStripeCustomer.Name = opptAdditionalSignee.Name;
            newQEStripeCustomer.Email__c = opptAdditionalSignee.Email__c;
			insert newQEStripeCustomer;
            // assign new qe stripe customer to additional signee
            opptAdditionalSignee.Stripe_Customer__c = newQEStripeCustomer.Id;
        } else {
            // assgin existing qe stripe customer to additional signee
            opptAdditionalSignee.Stripe_Customer__c = qeStripeCustomer.Id;
        }
        
        // Save
        upsert opptAdditionalSignee;
        
        // Redirect
        PageReference page = new PageReference('/'+opptAdditionalSignee.Opportunity__c);
        page.setRedirect(true); 
        return page;
    }
    
}
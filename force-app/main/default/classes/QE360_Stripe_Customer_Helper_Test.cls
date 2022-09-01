@isTest
public class QE360_Stripe_Customer_Helper_Test {

    private static testMethod void testMethod1() {
    
        String testEmail = 'testemail@quintevents.com';
        String testEmailDontExist = 'test@quintevents.com';
    
        QE360_Stripe_Customer__c qeStripeCustomer = new QE360_Stripe_Customer__c();
        qeStripeCustomer.Email__c = testEmail;
        insert qeStripeCustomer;
        
        QE360_Stripe_Customer_Helper qeSCHelper = new QE360_Stripe_Customer_Helper();
        qeSCHelper.getQEStripeCustomer(testEmail);
        qeSCHelper.searchCustomerRaw(testEmail);
        qeSCHelper.getStripeCustomer(testEmail,'Name');
        qeSCHelper.getStripeCustomer(testEmail,'Name',true);
        qeSCHelper.searchStripeCustomer(testEmail);
        qeSCHelper.searchStripeCustomer(testEmail,true);
        qeSCHelper.searchStripeCustomer(testEmail,false);
        
        qeSCHelper.getStripeCustomer(testEmailDontExist,'Name');
        qeSCHelper.getStripeCustomer(testEmailDontExist,'Name',true);
    }

}
@isTest
public class QE_TestStripe {

    // StripeCard
    private static testMethod void testStripeCard() { 
        new QE_StripeCard(); 
    }

    private static testMethod void testStripeError() {
        new QE_StripeError();
    }
        
    private static testMethod void testStripeException() {
        new QE_StripeException();
        QE_StripeError err = new QE_StripeError();
        err.message = 'abc';
        QE_StripeException ex = new QE_StripeException(err);
        System.assertEquals(err.message, ex.getMessage());
        ex.getError();
    }
    
    private static testmethod void testQE_StripeAPI() {
        Test.startTest();
        System.assertEquals(null, QE_StripeAPI.ApiKey);
        System.assertEquals(null, QE_StripeAPI.PublishableKey);
        System.assertEquals(true, QE_StripeAPI.isTest);
        System.assertEquals(null, QE_StripeAPI.ApiKeyByAccount(true));
        System.assertEquals(null, QE_StripeAPI.ApiKeyByAccount(false));
        
        QE_TestStripe.StripeDataSetup();
        System.assertEquals(false, QE_StripeAPI.isTest);
        System.assertEquals('xyz', QE_StripeAPI.ApiKey);
        System.assertEquals('456', QE_StripeAPI.PublishableKey);
        
        Stripe_Settings__c s = Stripe_Settings__c.getOrgDefaults();
        s.Is_Live_Environment__c = false;
        update s;
        
        System.assertEquals(true, QE_StripeAPI.isTest);
        System.assertEquals('123', QE_StripeAPI.ApiKey);
        System.assertEquals('def', QE_StripeAPI.PublishableKey);
        Test.stopTest();
    }
        
    public static void StripeDataSetup() {
        Stripe_Settings__c s = new Stripe_Settings__c();
        s.Is_Live_Environment__c = true;
        s.Stripe_Secret_Live_Key__c = 'xyz';
        s.Stripe_Secret_Test_Key__c = '123';
        s.Stripe_Publishable_Test_Key__c = 'def';
        s.Stripe_Publishable_Live_Key__c = '456';
        insert s;       
    }
  
}
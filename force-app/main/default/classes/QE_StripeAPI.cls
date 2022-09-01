global class QE_StripeAPI {
    
    global static String ApiKey {
        get {
            Stripe_Settings__c s = Stripe_Settings__c.getInstance();
            if (s != null) {
                if (QE_StripeAPI.isTest) {
                    return s.Stripe_Secret_Test_Key__c;
                } else {
                    return s.Stripe_Secret_Live_Key__c;
                }
            }
            return null;
        }
    }
    
    global Static String apiKeyByAccount(Boolean internationalStripe) {
        Stripe_Settings__c s = Stripe_Settings__c.getInstance();
        if (s != null) {
            // Test
            if (QE_StripeAPI.isTest) {
                if(internationalStripe) {
                    // International Stripe Account
                    return s.International_Stripe_Secret_Test_Key__c;
                } else {
                    // Regular Stripe Account
                    return s.Stripe_Secret_Test_Key__c;
                }
            // Live
            } else {
                if(internationalStripe) {
                    // International Stripe Account
                    return s.International_Stripe_Secret_Live_Key__c;
                } else {
                    // Regular Stripe Account
                    return s.Stripe_Secret_Live_Key__c;
                }
            }
        }
        return null; 
    }
    
    global static String PublishableKey {
        get {
            Stripe_Settings__c s = Stripe_Settings__c.getInstance();
            if (s != null) {
                if (QE_StripeAPI.isTest) {
                    return s.Stripe_Publishable_Test_Key__c;
                } else {
                    return s.Stripe_Publishable_Live_Key__c;
                }
            }
            return null;
        }
    }
    
    global static Boolean isTest {
        get {
            Stripe_Settings__c s = Stripe_Settings__c.getInstance();
            if (s != null) {
                return !s.Is_Live_Environment__c;
            }
            return true;
        }
    }
    
}
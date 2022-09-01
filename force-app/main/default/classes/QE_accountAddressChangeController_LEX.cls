public class QE_accountAddressChangeController_LEX {
    @AuraEnabled
    public static void findOpportunity(Id accountId){
        Account account = [Select Id,BillingStreet,BillingState,BillingPostalCode,BillingCountry,BillingCity,ShippingStreet,ShippingState,
                           ShippingPostalCode,ShippingCountry,ShippingCity,
                           (Select Id,Billing_Street__c,Billing_State_Province__c,Billing_Zip_Postal_Code__c,Billing_Country__c,Billing_City__c,
                            Shipping_Street__c,Shipping_Zip_Postal_Code__c,Shipping_State_Province__c,Shipping_Country__c,Shipping_City__c,
                            StageName from Opportunities) from Account where Id =: accountId];
        
        List<Opportunity> OppList = new List<Opportunity>();
        for(Opportunity oppObj : account.Opportunities){
            if(oppObj.StageName != 'Closed Won' && oppObj.StageName != 'Canceled'){
                if(oppObj.Billing_Street__c == null && oppObj.Billing_State_Province__c == null && oppObj.Billing_Zip_Postal_Code__c == null &&
                  oppObj.Billing_Country__c == null && oppObj.Billing_City__c == null){
                    oppObj.Billing_Street__c = account.BillingStreet;
                    oppObj.Billing_State_Province__c = account.BillingState;
                    oppObj.Billing_Zip_Postal_Code__c = account.BillingPostalCode;
                    oppObj.Billing_Country__c = account.BillingCountry;
                    oppObj.Billing_City__c = account.BillingCity;
                }
                if(oppObj.Shipping_Street__c == null && oppObj.Shipping_State_Province__c == null && oppObj.Shipping_Zip_Postal_Code__c == null &&
                  oppObj.Shipping_Country__c == null && oppObj.Shipping_City__c == null){
                    oppObj.Shipping_Street__c = account.ShippingStreet;
                    oppObj.Shipping_State_Province__c = account.ShippingState;
                    oppObj.Shipping_Zip_Postal_Code__c = account.ShippingPostalCode;
                    oppObj.Shipping_Country__c = account.ShippingCountry;
                    oppObj.Shipping_City__c = account.ShippingCity;
                }
                OppList.add(oppObj);
            }
        }
        update OppList;
    }
}
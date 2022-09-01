/**
 * @description       : 
 * @author            : ratik.singhal@addonblue.com
 * @group             : 
 * @last modified on  : 07-30-2021
 * @last modified by  : ratik.singhal@addonblue.com
**/
public class ContactAddressCopytoQuotesCntrl {
	@AuraEnabled
    public static void updateAddressOnQuotes(Id quoteId){
        System.debug('@@quoteId: '+quoteId);
        Quote quote =  [Select Id, Name, OpportunityId, AccountId, BillingCity, BillingCountry, BillingCountryCode, BillingPostalCode, BillingState, 
                        BillingStateCode, BillingStreet from Quote where Id =:quoteId];
		
        Contact billingContact = [Select Id, LastName, OtherStreet, OtherCity, OtherState, OtherCountryCode, OtherPostalCode, OtherCountry, 
                                  OtherStateCode, Accountid from Contact where id in (Select ContactId From OpportunityContactRole 
                                   where Role = 'Billing Contact'and OpportunityId = :quote.OpportunityId) limit 1];        
    
        if(null != billingContact){
            System.debug('@OtherCity: ' + billingContact.OtherCity);
            quote.BillingCity = billingContact.OtherCity;
            quote.BillingCountry = billingContact.OtherCountry;
            quote.BillingCountryCode = billingContact.OtherCountryCode;
            quote.BillingPostalCode = billingContact.OtherPostalCode;
            quote.BillingState = billingContact.OtherState;
            quote.BillingStateCode = billingContact.OtherStateCode;
            quote.BillingStreet = billingContact.OtherStreet;
            upsert quote;
            System.debug('@@quoteId: '+quoteId+' updated successfully');
        }
        
    }
}
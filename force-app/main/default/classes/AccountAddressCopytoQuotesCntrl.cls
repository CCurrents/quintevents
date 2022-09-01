/**
 * @description       : 
 * @author            : Jheel Agrawal
 * @group             : 
 * @last modified on  : 11-04-2020
 * @last modified by  : Jheel Agrawal
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   11-04-2020   Jheel Agrawal   Initial Version
**/
public class AccountAddressCopytoQuotesCntrl {
    @AuraEnabled
    public static void findQuotes(Id accountId){
        
        List<Quote> lstQuote = [Select Id,BillingStreet,BillingState,BillingCity,BillingCountry,BillingPostalCode,
                                ShippingStreet,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState, 
                                Account.BillingStreet,Account.BillingState,Account.BillingPostalCode,Account.BillingCountry,Account.BillingCity,Account.ShippingStreet,Account.ShippingState,Account.ShippingPostalCode,Account.ShippingCountry,Account.ShippingCity from Quote where AccountId =:accountId];
        System.debug('lstQuote@@'+lstQuote);
        List<Quote> lstUpdateQuotes = new List<Quote>();
        if(lstQuote.size() > 0){
            for(Quote objquote : lstQuote){
                if(objquote.BillingStreet == null && objquote.BillingState == null && objquote.BillingPostalCode == null &&
                   objquote.BillingCountry == null && objquote.BillingCity == null){
                       objquote.BillingStreet = objquote.Account.BillingStreet;
                       objquote.BillingState = objquote.Account.BillingState;
                       objquote.BillingPostalCode = objquote.Account.BillingPostalCode;
                       objquote.BillingCountry = objquote.Account.BillingCountry;
                       objquote.BillingCity = objquote.Account.BillingCity;
                   }
                if(objquote.ShippingStreet == null && objquote.ShippingState == null && objquote.ShippingPostalCode == null &&
                   objquote.ShippingCountry == null && objquote.ShippingCity == null){
                       objquote.ShippingStreet = objquote.Account.ShippingStreet;
                       objquote.ShippingState = objquote.Account.ShippingState;
                       objquote.ShippingPostalCode = objquote.Account.ShippingPostalCode;
                       objquote.ShippingCountry = objquote.Account.ShippingCountry;
                       objquote.ShippingCity = objquote.Account.ShippingCity;
                   }
                lstUpdateQuotes.add(objquote);
            }
            update lstUpdateQuotes;
        }
        else{
            System.debug('!!!Error!!!');
            throw new AuraHandledException('This Account does not have any Quote.');
        }
        
    }
}
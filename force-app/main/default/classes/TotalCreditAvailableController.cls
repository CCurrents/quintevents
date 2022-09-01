public class TotalCreditAvailableController {
    @AuraEnabled
    public static Quote getTotalCreditFromAccount(string recordId)
    {
        try{
        System.debug('recordID@@@'+recordId);
        Quote qu = [Select Id,CurrencyIsoCode,Account.USD_Total_Credit_Available__c, Account.CAD_Total_Credit_Available__c, Account.EUR_Total_Credit_Available__c,Account.GBP_Total_Credit_Available__c, Account.AUD_Total_Credit_Available__c from Quote where id =: recordId];
        System.debug('qu@@@' +qu);
        /*if(qu!= null && qu.CurrencyIsoCode == 'USD' ){
            return qu.Account.USD_Total_Credit_Available__c;
        }else if(qu!= null && qu.CurrencyIsoCode == 'CAD' ){
            return qu.Account.CAD_Total_Credit_Available__c;
        }else if(qu!= null && qu.CurrencyIsoCode == 'EUR' ){
            return qu.Account.EUR_Total_Credit_Available__c;
        }else if(qu!= null && qu.CurrencyIsoCode == 'GBP' ){
            return qu.Account.GBP_Total_Credit_Available__c;
        }else if(qu!= null && qu.CurrencyIsoCode == 'AUD' ){
            return qu.Account.AUD_Total_Credit_Available__c;
        }*/
        if(qu != null){
            return qu; } else{ throw new AuraHandledException('Something went wrong. Please try again.');
        }
        }catch(Exception e){
            System.debug('Error:'+e.getMessage() +'' +e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
}
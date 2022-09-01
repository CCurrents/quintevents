/**
 * @File Name          : CustomAddendumWaiver.cls
 * @Description        : 
 * @Author             : lpanchal@addonblue.com
 * @Group              : 
 * @Last Modified By   : lpanchal@addonblue.com
 * @Last Modified On   : 4/13/2020, 7:29:47 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/3/2020   lpanchal@addonblue.com     Initial Version
**/
public class CustomAddendumWaiver {
	@AuraEnabled
    public static string processCustomAddendumWaiver(String QuoteId){
        Quote objQuote = [Select Id,Addendum_A_Waiver__c,Language__c,Terms_And_Conditions__c,
        Pricebook2.Addendum_A_Waiver__c,
        Pricebook2.Addendum_A_Waiver_AR__c,
        Pricebook2.Addendum_A_Waiver_ZH__c,
        Pricebook2.Addendum_A_Waiver_ES__c,
        Pricebook2.Addendum_A_Waiver_IT__c,
        Pricebook2.Addendum_A_Waiver_FR__c,
        Pricebook2.Addendum_A_Waiver_JA__c,
        Pricebook2.Addendum_A_Waiver_DE__c 
        from Quote where Id =: QuoteId];
        switch on objQuote.Language__c {
            when 'French' {	
                objQuote.Addendum_A_Waiver__c = objQuote.Pricebook2.Addendum_A_Waiver_FR__c;
            }
            when 'Spanish' {
                objQuote.Addendum_A_Waiver__c = objQuote.Pricebook2.Addendum_A_Waiver_ES__c;
            }
            when 'Chinese' {		
                objQuote.Addendum_A_Waiver__c = objQuote.Pricebook2.Addendum_A_Waiver_ZH__c;
            }
            when 'Japanese' {	
                objQuote.Addendum_A_Waiver__c = objQuote.Pricebook2.Addendum_A_Waiver_JA__c;
            }
            when 'German' {		
                objQuote.Addendum_A_Waiver__c = objQuote.Pricebook2.Addendum_A_Waiver_DE__c;
            }
            when 'Italian' {		
                objQuote.Addendum_A_Waiver__c = objQuote.Pricebook2.Addendum_A_Waiver_IT__c;
            }
            when 'Arabic' {
                objQuote.Addendum_A_Waiver__c = objQuote.Pricebook2.Addendum_A_Waiver_AR__c;
            }
            when else {		
                objQuote.Addendum_A_Waiver__c = objQuote.Pricebook2.Addendum_A_Waiver__c;
            }
        }
        if(String.isEmpty(objQuote.Addendum_A_Waiver__c)){
            return 'Addendum Waiver not defined at Event';
        }
        update objQuote;
        return 'Addendum Waiver successfully copied from Event';
    }
}
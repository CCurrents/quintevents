/**
 * @File Name          : CustomTnC.cls
 * @Description        : 
 * @Author             : lpanchal@addonblue.com
 * @Group              : 
 * @Last Modified By   : lpanchal@addonblue.com
 * @Last Modified On   : 4/13/2020, 7:26:11 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/3/2020   lpanchal@addonblue.com     Initial Version
**/
public class CustomTnC {
    @AuraEnabled
    public static String processCustomTnC(String QuoteId){
        Quote objQuote = [Select Id,Terms_And_Conditions__c,Language__c,
        Pricebook2.Terms_And_Conditions__c,
        Pricebook2.Terms_And_Conditions_AR__c,
        Pricebook2.Terms_And_Conditions_ZH__c,
        Pricebook2.Terms_And_Conditions_ES__c,
        Pricebook2.Terms_And_Conditions_IT__c,
        Pricebook2.Terms_And_Conditions_FR__c,
        Pricebook2.Terms_And_Conditions_JA__c,
        Pricebook2.Terms_And_Conditions_DE__c 
        from Quote where Id =: QuoteId];
        switch on objQuote.Language__c {
            when 'French' {	
                objQuote.Terms_And_Conditions__c = objQuote.Pricebook2.Terms_And_Conditions_FR__c;
            }
            when 'Spanish' {
                objQuote.Terms_And_Conditions__c = objQuote.Pricebook2.Terms_And_Conditions_ES__c;
            }
            when 'Chinese' {		
                objQuote.Terms_And_Conditions__c = objQuote.Pricebook2.Terms_And_Conditions_ZH__c;
            }
            when 'Japanese' {	
                objQuote.Terms_And_Conditions__c = objQuote.Pricebook2.Terms_And_Conditions_JA__c;
            }
            when 'German' {		
                objQuote.Terms_And_Conditions__c = objQuote.Pricebook2.Terms_And_Conditions_DE__c;
            }
            when 'Italian' {		
                objQuote.Terms_And_Conditions__c = objQuote.Pricebook2.Terms_And_Conditions_IT__c;
            }
            when 'Arabic' {
                objQuote.Terms_And_Conditions__c = objQuote.Pricebook2.Terms_And_Conditions_AR__c;
            }
            when else {		
                objQuote.Terms_And_Conditions__c = objQuote.Pricebook2.Terms_And_Conditions__c;
            }
        }
        system.debug('objQuote---'+objQuote);
        if(String.isEmpty(objQuote.Terms_And_Conditions__c)){
            return 'Terms & Conditions not defined at Event';
        }
        update objQuote;
        return 'Terms & Conditions successfully copied from Event';
    }

}
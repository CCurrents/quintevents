/**
 * @File Name          : ProgramTriggerTest.cls
 * @Description        : This is Test class for Trigger on Program object.
 * @Author             : vaibhav.khopade@addonblue.com
 * @Group              : 
 * @Last Modified By   : vaibhav.khopadea@addonblue.com
 * @Last Modified On   : 05-23-2022
 * @Modification Log   : 
 * Ver       Date            Author                  		Modification
 * 1.0    05/23/2022   vaibhav.khopade@addonblue.com     	Initial Version, created for issue 1194

**/

@isTest
public class ProgramTriggerTest {

    @isTest static void testMethod_one() {
        TestDataFactory.createTriggerSettingsEntry();
        Program__c programRec = new Program__c(
            Name = 'Test Program'
        );
        insert programRec;
        
        List<PriceBook2> lstPriceBook = TestDataFactory.createPricebook(1, 'Test Pricebook');
        lstPriceBook[0].End_Date__c = System.today()+3;
        lstPriceBook[0].TOPOS__c = System.today();
        lstPriceBook[0].Program__c = programRec.Id; 
        Utility.processRecords(lstPriceBook, 'update');
        
        programRec.Terms_Conditions__c = 'Test Terms & Conditions';
        programRec.Terms_And_Conditions_AR__c = 'Test Terms & Conditions';
        programRec.Terms_And_Conditions_DE__c = 'Test Terms & Conditions';
        programRec.Terms_And_Conditions_ES__c = 'Test Terms & Conditions';
        programRec.Terms_And_Conditions_FR__c = 'Test Terms & Conditions';
        programRec.Terms_And_Conditions_IT__c = 'Test Terms & Conditions';
        programRec.Terms_And_Conditions_JA__c = 'Test Terms & Conditions';
        programRec.Terms_And_Conditions_ZH__c = 'Test Terms & Conditions';
        
        programRec.Addendum_A_Waiver__c = 'Addendum Waiver';
        programRec.Addendum_A_Waiver_AR__c = 'Addendum Waiver';
        programRec.Addendum_A_Waiver_DE__c = 'Addendum Waiver';
        programRec.Addendum_A_Waiver_ES__c = 'Addendum Waiver';
        programRec.Addendum_A_Waiver_FR__c = 'Addendum Waiver';
        programRec.Addendum_A_Waiver_IT__c = 'Addendum Waiver';
        programRec.Addendum_A_Waiver_JA__c = 'Addendum Waiver';
        programRec.Addendum_A_Waiver_ZH__c = 'Addendum Waiver';
        
        update programRec;
    }
    
}
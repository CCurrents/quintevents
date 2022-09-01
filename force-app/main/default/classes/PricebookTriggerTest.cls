/**
 * @File Name          : PricebookTriggerTest.cls
 * @Description        : Test class for code coverage of PricebookTrigger classes
 * @Author             : fsuraitawalal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawalal@addonblue.com
 * @Last Modified On   : 17/3/2020
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    17/3/2020   fsuraitawalal@addonblue.com     Initial Version
**/
@isTest
private class PricebookTriggerTest {
    
    /**
    * @description  : Method for after Insert Event of trigger
    * @author       : fsuraitawala@addonblue.com
    * @return       : void
    **/
    @isTest static void testMethod_one() {
        TestDataFactory.createTriggerSettingsEntry();
        List<PriceBook2> lstPriceBook = TestDataFactory.createPricebook(1, 'Test Pricebook');
        lstPriceBook[0].End_Date__c = System.today()+3;
        lstPriceBook[0].TOPOS__c = System.today();
        
        //VKHOPADE- issue 1194 - start
        Program__c programRec = new Program__c(
            Name = 'Test Program'
        );
        insert programRec;
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
        
        lstPriceBook[0].GPE_Event__c = True;
        lstPriceBook[0].Program__c = programRec.Id; 
        Utility.processRecords(lstPriceBook, 'update');
        
        Pricebook2 pricebookWithProgram = new Pricebook2(
                //Name = PricbookName+'-'+ Utility.getRandomNumber() +i,
                Name = 'Test Pricebook 3',
                IsActive = true,
                GPE_Event__c = false,
                Shipping_and_Handling_Fee__c = 200,
                Shipping_and_Handling_Fee_Outside_US__c = 100,
                H4H_Site_Id__c = '51745',
                Slack_Channel_Name__c = 'UFC 243',
                Post_to_Slack_Channel__c = true,
                Slack_Channel_Id__c = 'CLZM020EL',
            	Program__c = programRec.Id,
                End_Date__c = System.today()+2
            );
        insert pricebookWithProgram;
        //VKHOPADE- issue 1194 - end
    }
}
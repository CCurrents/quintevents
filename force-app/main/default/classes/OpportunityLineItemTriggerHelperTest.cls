/**
 * @File Name          : OpportunityLineItemTriggerHelperTest.cls
 * @Description        : 
 * @Author             : jthakkar@addonblue.com
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 09-04-2021
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    3/16/2020   jthakkar@addonblue.com     Initial Version
**/
@isTest
private with sharing class OpportunityLineItemTriggerHelperTest{
    @testSetup static void setup() { 
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void testMethod1(){
        QuoteLineItem objQLI = TestDataFactory.createQuoteLineItem();
        Quote quote = [select Id, OpportunityId FROM Quote WHERE Id =: objQLI.quoteId];        
        List<OpportunityLineItem> lstOLI = TestDataFactory.createOpportunityLineItem(1, quote.OpportunityId);
        update lstOLI;
        Set<Id> setOpportunityId = OpportunityLineItemTriggerHelper.getOppID(lstOLI);
        OpportunityLineItemTriggerHelper.updateOpportunities(setOpportunityId);
    }
}
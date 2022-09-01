/**
 * @File Name          : LeadConvertClass_LEXTest.cls
 * @Description        : 
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 3/19/2020, 3:23:57 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    3/19/2020   mpatel@addonblue.com     Initial Version
 * 1.1    4/5/2021    cshah@addonblue.com     #866 - Reseller lead convert and agreement changes

**/ 
@isTest
private with sharing class LeadConvertClass_LEXTest{
    @testSetup static void setup() {
        TestDataFactory.createTestRecords();
    }
    @isTest static void testMethodOne() {
        TestDataFactory.createSFDCIntacctMapping();
        Lead lead = TestDataFactory.createLead();
        Opportunity opportunity = TestDataFactory.createOpportunity(1, TestDataFactory.createAccount().Id, TestDataFactory.createContact().Id, TestDataFactory.createPricebook().Id, false)[0];
        opportunity.CurrencyIsoCode = 'USD';
        opportunity.Projected_Revenue__c = 12;
        Utility.processRecords(opportunity, 'insert');
        System.assertEquals('USD', opportunity.CurrencyIsoCode);
        LeadConvertClass_LEX.convertLead(lead.Id,opportunity,TestDataFactory.createAccount(),lead);
        LeadConvertClass_LEX.getPricebookCurrencyDetails(TestDataFactory.createpriceBook().Id);
        //Lead objLead = LeadConvertClass_LEX.retrieveLeadInfo(lead.Id);
        //System.assertEquals(objLead.Id, lead.Id);
    }
    
    @isTest static void testResellerLead() {
        TestDataFactory.createSFDCIntacctMapping();
        Lead lead = TestDataFactory.createLead();
        lead.Lead_Type__c = 'Reseller';
        lead.Company_Name__c = 'Test Company';
        update lead;
        
        Opportunity opportunity = TestDataFactory.createOpportunity(1, TestDataFactory.createAccount().Id, TestDataFactory.createContact().Id, TestDataFactory.createPricebook().Id, false)[0];
        opportunity.CurrencyIsoCode = 'USD';
        opportunity.Projected_Revenue__c = 12;
        Utility.processRecords(opportunity, 'insert');
        System.assertEquals('USD', opportunity.CurrencyIsoCode);
        LeadConvertClass_LEX.convertLead(lead.Id,opportunity,TestDataFactory.createAccount(),lead);
        LeadConvertClass_LEX.getPricebookCurrencyDetails(TestDataFactory.createpriceBook().Id);
        //Lead objLead = LeadConvertClass_LEX.retrieveLeadInfo(lead.Id);
        //System.assertEquals(objLead.Id, lead.Id);
    }
}
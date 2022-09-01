/**
 * @File Name          : OpportunityTriggerHelperTest.cls
 * @Description        : 
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 01-18-2021
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    3/16/2020   mpatel@addonblue.com     Initial Version
**/
@isTest
private with sharing class OpportunityTriggerHelperTest{
    @testSetup static void setup() { 
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void opportunityTestFistExecution() {
        Account objAccount = TestDataFactory.createAccount();
        Sales_Agent__c salesAgent = new Sales_Agent__c();
        salesAgent.Name = 'Test';
        salesAgent.Default_Commission__c = 12;
        insert salesAgent;
        objAccount.Sales_Agent__c = salesAgent.Id;
        
        Promoter__c promoter = new Promoter__c();
        promoter.Online_Sales_Commission__c = 2;
        insert promoter;
        objAccount.Promoters_Name__c = promoter.Id;
        update objAccount;
        System.assert(true,objAccount.Name != null);

        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        System.assertEquals('Test@gmail.com', objContact.Email);
        
        Payment_Term__c objPT = TestDataFactory.createPaymentTerm();
        //Order objOrder = [Select Id from Order where Id =: objPT.Order__c];
        //Quote objQuote = [select Id, TotalPrice, Pricebook2Id, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode from Quote where Id=: objPT.Quote__c];
        //QuoteLineItem QLI = TestDataFactory.createQuoteLineItem(1, objQuote.Id, true)[0];
        //Orderitem odi = TestDataFactory.createOrderItem(4, objOrder.Id, QLI)[0];
         
        PriceBook2 pricebook = TestDataFactory.createPricebook(1, 'Test PB', false)[0];
        pricebook.GPE_Event__c = true;
        Utility.processRecords(pricebook, 'insert');
        System.assertEquals(true, pricebook.GPE_Event__c);
        
        Opportunity objOpportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, pricebook.id, false)[0];
        objOpportunity.StageName = 'Closed Won';
        objOpportunity.Refund_Response__c = 'Confirm Refund';
        objOpportunity.Refunded__c = true;
        Utility.processRecords(objOpportunity, 'insert');
        System.assertEquals('Closed Won', objOpportunity.StageName);
        
        //objOpportunity.StageName = 'Request Cancelation';
        objOpportunity.StageName = 'Under Review';       
        Utility.processRecords(objOpportunity, 'update');
        //System.assertEquals('Request Cancelation', objOpportunity.StageName);
        
        objOpportunity.StageName = 'Closed Won';
        objOpportunity.Online_Order__c = true;       
        Utility.processRecords(objOpportunity, 'update');
        OpportunityTriggerHelper ott = new OpportunityTriggerHelper();
        ott.CopyDatatoOpportunity(new set<id>{objOpportunity.id});
        Allow_Delete_Record__c objAllowDeleteRecord = Allow_Delete_Record__c.getInstance(UserInfo.getProfileId());
        objAllowDeleteRecord.Opp_Statuses_to_Consider__c = 'Closed Won';
        objAllowDeleteRecord.Opportunity__c = true;
        insert objAllowDeleteRecord;
        objAllowDeleteRecord.Opportunity__c = false;
        update objAllowDeleteRecord;
        List<opportunity> lstnewOpps = [select id from opportunity];
        lstnewOpps.add(objOpportunity);
        List<OpportunityContactRole> lstOCRs = new List<OpportunityContactRole>();
        ott.CopyCommissionAddresstoOpportunity(lstnewOpps, lstOCRs);
        Utility.processRecords(objOpportunity, 'delete');        
        ott.sendEmailtoAccounting(null);
        ott.createContactRoles(null,null);
        
    }
    
    @isTest static void opportunityTestFistExecution1() {
        Account objAccount = TestDataFactory.createAccount();
        Sales_Agent__c salesAgent = new Sales_Agent__c();
        salesAgent.Name = 'Test';
        salesAgent.Default_Commission__c = 12;
        insert salesAgent;
        objAccount.Sales_Agent__c = salesAgent.Id;
        
        Promoter__c promoter = new Promoter__c();
        promoter.Online_Sales_Commission__c = 2;
        insert promoter;
        objAccount.Promoters_Name__c = promoter.Id;
        update objAccount;
        System.assert(true,objAccount.Name != null);

        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        System.assertEquals('Test@gmail.com', objContact.Email);
        
        Payment_Term__c objPT = TestDataFactory.createPaymentTerm();
         
        PriceBook2 pricebook = TestDataFactory.createPricebook(1, 'Test PB', false)[0];
        pricebook.GPE_Event__c = true;
        Utility.processRecords(pricebook, 'insert');
        System.assertEquals(true, pricebook.GPE_Event__c);
        
        Opportunity objOpportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, pricebook.id, false)[0];
        objOpportunity.StageName = 'Closed Won';
        objOpportunity.Refund_Response__c = 'Confirm Refund';
        objOpportunity.Refunded__c = true;
        Utility.processRecords(objOpportunity, 'insert');
        System.assertEquals('Closed Won', objOpportunity.StageName);
        
        //objOpportunity.StageName = 'Request Cancelation';
        objOpportunity.StageName = 'Under Review';       
        Utility.processRecords(objOpportunity, 'update');
        //System.assertEquals('Request Cancelation', objOpportunity.StageName);
        
        objOpportunity.StageName = 'Closed Won';
        objOpportunity.Online_Order__c = true;       
        Utility.processRecords(objOpportunity, 'update');
        OpportunityTriggerHelper ott = new OpportunityTriggerHelper();
        ott.CopyDatatoOpportunity(new set<id>{objOpportunity.id});
        Allow_Delete_Record__c objAllowDeleteRecord = new Allow_Delete_Record__c();
        objAllowDeleteRecord.Opp_Statuses_to_Consider__c = '';
        objAllowDeleteRecord.Opportunity__c = true;
        insert objAllowDeleteRecord;
        List<opportunity> lstnewOpps = [select id from opportunity];
        lstnewOpps.add(objOpportunity);
        List<OpportunityContactRole> lstOCRs = new List<OpportunityContactRole>();
        ott.CopyCommissionAddresstoOpportunity(lstnewOpps, lstOCRs);
        Utility.processRecords(objOpportunity, 'delete');
    }
}
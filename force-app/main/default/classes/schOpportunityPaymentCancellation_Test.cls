/**
 * @File Name          : schOpportunityPaymentCancellation_Test.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : Lovel Panchal
 * @Last Modified On   : 5/11/2020, 9:33:06 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
private class schOpportunityPaymentCancellation_Test {
    static testMethod void validateHelloWorld() {
        // QE360_Event__c eventTest = new QE360_Event__c();
        // eventTest.Name = 'Sample Event';
        // eventTest.Start_Date__c = system.today().addDays(-3);
        // eventTest.Payment_Cancellation_Days__c = 2;
        // eventTest.Event_Payment_Window__c = 10;
        // Insert eventTest;

        // Lead lead = new Lead();
        // lead.Google_Analytics_ID__c = 'gaID';
        // lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        // lead.IsConverted = false;
        // lead.FirstName = 'testName';
        // lead.LastName = 'testName';
        // lead.Source__c = 'call Virtuoso';
        // lead.Status = 'Interested';
        // insert lead;

        // Database.LeadConvert lc = new database.LeadConvert();
        // lc.setLeadId(lead.id);
        // lc.setDoNotCreateOpportunity(true);
        // lc.setConvertedStatus('Converted');
        // Database.LeadConvertResult lcr = Database.convertLead(lc);
        // System.assert(lcr.isSuccess());

        // Lead convertedLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];

        // Product2 proPack = new Product2(Name='BXCD1', isActive=true,
        //                                 Event__c = eventTest.Id,
        //                                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId());
        // insert proPack;

        // PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=proPack.Id,Pricebook2Id=Test.getStandardPricebookId(),
        //                                         isActive=true,UseStandardPrice = false);
        // insert pbe2;
        
        // Opportunity oppTest = new Opportunity();
        // oppTest.Name = 'oppName';
        // oppTest.AccountId = convertedLead.ConvertedAccountId;
        // oppTest.Event__c = eventTest.Id;
        // oppTest.StageName = 'Closed Won';
        // oppTest.CloseDate = System.today();
        // insert oppTest;
        
        // OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id, ApexProductName__c=proPack.Name);
        // insert OPplineitem2;

        // Test.startTest();
        //     schOpportunityPaymentCancellation objsc = new schOpportunityPaymentCancellation();
        //     //objsc.updateOppPaymentCancellations();
        // Test.stopTest();
    }
}
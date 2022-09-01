/**
 * @File Name          : QE_GaCallout_Test.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 11:18:37 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
private class QE_GaCallout_Test {
    static testMethod void validateHelloWorld() {
    
        TestDataFactory.createTriggerSettingsEntry();
        Account account = new account();//TestDataFactory.createAccount();
        account.name = 'test';
        account.Google_Analytics_ID__c = '7458998';
        account.Google_Analytics_Site_Id__c ='34545';
        insert account;
        /*Pricebook2 pricebook = new Pricebook2(
                //Name = PricbookName+'-'+ Utility.getRandomNumber() +i,
                Name = 'PB',
                IsActive = true,
                GPE_Event__c = false,
                Shipping_and_Handling_Fee__c = 200,
                Shipping_and_Handling_Fee_Outside_US__c = 100,
                H4H_Site_Id__c = '51745',
                Slack_Channel_Name__c = 'UFC 243',
                Post_to_Slack_Channel__c = true,
                Slack_Channel_Id__c = 'CLZM020EL',
                End_Date__c = System.today()+2
            );
        insert pricebook;       
          */  
        PricebookEntry pricebookentry = new PricebookEntry(
                unitprice = 0.01,
                Product2Id = TestDataFactory.createProduct().Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                isActive = true,
                UseStandardPrice = false
            );
        insert pricebookentry;
        Opportunity objOpportunity = TestDataFactory.createOpportunity(1, account.Id, TestDataFactory.createContact().id, pricebookentry.pricebook2Id , false)[0];
        Utility.processRecords(objOpportunity, 'insert');
        
        OpportunityLineItem opli = new OpportunityLineItem (OpportunityId = objOpportunity.Id,
                TotalPrice = 100,
                Quantity = 3,
                ListPrice_Used__c = 10,
                PricebookEntryId = pricebookentry.Id);
        insert  opli;
        System.debug('objOpportunity-->'+objOpportunity );
        /*QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        Insert eventTest;

        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.IsConverted = false;
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Source__c = 'call Virtuoso';
        insert lead;

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead convertedLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];

        Opportunity oppTest = new Opportunity();
        oppTest.Name = 'oppName';
        oppTest.AccountId = convertedLead.ConvertedAccountId;
        oppTest.Event__c = eventTest.Id;
        oppTest.StageName = 'Closed Won';
        oppTest.CloseDate = System.today();
        insert oppTest;

        Product2 proPack = new Product2(Name='BXCD1', isActive=true,
                                        Event__c = eventTest.Id,
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId());
        insert proPack;

        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=proPack.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;


        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id, ApexProductName__c=proPack.Name);
        insert OPplineitem2;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GaMockHttpResponseGenerator());
*/
        Test.setMock(HttpCalloutMock.class, new GaMockHttpResponseGenerator());
        QE_GaCallout.sendTransaction(objOpportunity.id, false);
  //      QE_GaCallout.sendTransaction(oppTest.id, true);
    //    Test.stopTest();
    }
}
/**
 * @File Name          : XeroTokenRefreshBatchTest.cls
 * @Description        : test class for the XeroTokenRefreshBatch controller
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 04/27/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    04/27/2020    mpatel@addonblue.com       Initial Version
**/
@isTest
private with sharing class XeroTokenRefreshBatchTest {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void xeroTokenFistTestExecution() {
        Account objAccount = TestDataFactory.createAccount();
        System.assert(true,objAccount.Name != null);

        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        System.assertEquals('Test@gmail.com', objContact.Email);

        PriceBook2 priceBook = TestDataFactory.createPricebook(1, 'T', false)[0];
        priceBook.Payment_Cancellation_Days__c = 2;
        priceBook.Start_Date__c = system.today();
        priceBook.Event_Payment_Window__c = 1;
        Utility.processRecords(pricebook, 'insert');

        Opportunity opportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, pricebook.id, false)[0];
        opportunity.PriceBook2Id = pricebook.Id;
        opportunity.StageName = 'Closed Won';
        Utility.processRecords(opportunity, 'insert');
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = objContact.Id;
        ocr.OpportunityId = Opportunity.Id;
        ocr.Role = 'H4H Rewards Contact';
        Utility.processRecords(ocr, 'insert');
        
        TestDataFactory.createSFDCIntacctMapping();
        
        Order order = TestDataFactory.createOrder(1,false)[0];
        order.OpportunityId = opportunity.Id;
        Utility.processRecords(order, 'insert');

        Xero_Configuration__c xeroConfiguration = new Xero_Configuration__c();
        xeroConfiguration.Active__c = true;
        xeroConfiguration.Access_Token__c = 'fserfwr';
        xeroConfiguration.Authentication_Endpoint__c='ewferf';
        xeroConfiguration.Branding_ThemeID__c = 'erf';
        xeroConfiguration.Category_Name__c = 'efr';
        xeroConfiguration.Consumer_Key__c = 'erferf';
        xeroConfiguration.Consumer_Secret__c = 'ererf';
        xeroConfiguration.Endpoint__c = 'erferf';
        xeroConfiguration.Tenant_Id__c = 'ghfgtrd';
        Utility.processRecords(xeroConfiguration, 'insert');
        XeroTokenRefreshBatch obj = new XeroTokenRefreshBatch('Contact', order, '123',null);
        ID batchprocessid1 = Database.executeBatch(obj);   
        XeroTokenRefreshBatch obj1 = new XeroTokenRefreshBatch('EmailInvoice', order, '123',null);
        ID batchprocessid2 = Database.executeBatch(obj1);   
        XeroTokenRefreshBatch obj2 = new XeroTokenRefreshBatch('Payment', order, '123',null);
        ID batchprocessid3 = Database.executeBatch(obj2);       
        ScheduleXeroRefreshToken.scheduleMe();
        ScheduleXeroRefreshToken sch = new ScheduleXeroRefreshToken();
        sch.execute(null);
    }
}
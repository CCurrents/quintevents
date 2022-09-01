/**
 * @File Name          : QE_DSRecipientStatusTriggerHandler_Test.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 2:31:07 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest(seeAllData=false)
public class QE_DSRecipientStatusTriggerHandler_Test {
    
    @isTest static void test_method_one() {
        Test.startTest();
        
        Id prodRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Package'].Id;
        
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Source__c = 'call Virtuoso';
        lead.Company = 'test business';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
        User testEventManagerUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'QE360 - Operations'].Id,
            LastName = 'last',
            Email = 'testEventManagerUser@quintevents.com',
            Username = 'testEventManagerUser@quintevents.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert testEventManagerUser;
        
        QE360_Event__c even = new QE360_Event__c(Name='mexico',Event_Manager__c=testEventManagerUser.Id);
        insert even;
        
        Opportunity o = new Opportunity();
        o.Accountid = testLead.ConvertedAccountId;
        o.Name = 'test';
        o.Event__c=even.Id;
        o.Payment_Method__c='Credit Card';
        o.Send_Payment_Email__c=true;
        o.StageName = 'Prospecting';
        o.CloseDate = date.today();  
        o.Contact_Site__c = 'quintevents.com';                   
        insert o;
        
        Contact con =new Contact(LastName='Test',Primary_Contact__c=true,AccountId=testLead.ConvertedAccountId,Opportunity__c=o.Id);
        insert con;
        
        QE360_Opportunity_Additional_Signee__c oppAddsign = new QE360_Opportunity_Additional_Signee__c();
        oppAddsign.Name='Test';
        oppAddsign.Amount__c=10;        
        oppAddsign.City__c='Test';        
        oppAddsign.Country__c='Test';        
        oppAddsign.Email__c='Test@test87.com';        
        oppAddsign.State__c='Test';
        oppAddsign.OpportunityS__c=o.Id;    
        insert oppAddsign;
        
        //Quote quot = new Quote(Name='Test Quote',Payment_Terms__c = '100%', OpportunityId=o.Id,Status='Signed - Approved',Payment_Method__c='Credit Card',Email='test@test435.com',Pricebook2Id = Test.getStandardPricebookId());      
        //insert quot;
        
        Quote quot1 = new Quote(Name='Test Quote',Payment_Terms__c = '100%', OpportunityId=o.Id,Status='Draft - Approved',Payment_Method__c='Credit Card',Email='test@test435.com',Pricebook2Id = Test.getStandardPricebookId());      
        insert quot1;
        
        Product2 prod = new Product2(Name='Test Prod',Event__c=even.Id,RecordTypeId=prodRecType,isActive=true);
        insert prod; 
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=prod.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        QuoteLineItem Quolineitem2 = new QuoteLineItem (Quantity=2, QuoteId=quot1.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert Quolineitem2;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quot1);
        QE_EmailQuoteCtrl obj = new QE_EmailQuoteCtrl(sc);
        obj.sendWithDocuSign();
        
        dsfs__DocuSign_Status__c testDSStatus = new dsfs__DocuSign_Status__c();
        testDSStatus.Standard_Quote__c = quot1.id;
        testDSStatus.dsfs__Envelope_Status__c = 'Sent';
        insert testDSStatus;
        
        testDSStatus.dsfs__Envelope_Status__c = 'Completed';
        testDSStatus.Has_Counter_Signer__c = false;
        update testDSStatus;
        
        dsfs__DocuSign_Recipient_Status__c testDSRecipient_1 = new dsfs__DocuSign_Recipient_Status__c();
        testDSRecipient_1.dsfs__DocuSign_Recipient_Email__c = 'testEventManagerUser@quintevents.com';
        testDSRecipient_1.dsfs__DocuSign_Recipient_Id__c = 'testid';
        testDSRecipient_1.dsfs__Parent_Status_Record__c = testDSStatus.Id;
        insert testDSRecipient_1;
        
        testDSRecipient_1.dsfs__Recipient_Status__c = 'Sent';
        update testDSRecipient_1;
        
        Test.stopTest();
    }
}
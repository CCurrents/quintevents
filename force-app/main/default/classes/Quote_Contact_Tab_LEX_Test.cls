/**
 * @File Name          : Quote_Contact_Tab_LEX_Test.cls
 * @Description        : 
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/8/2020, 4:04:22 AM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/27/2020   mpatel@addonblue.com       Initial Version
**/
@isTest
private with sharing class Quote_Contact_Tab_LEX_Test{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void contactFirstTestExecution() {
        Account objAccount = TestDataFactory.createAccount();
        System.assert(true,objAccount.Name != null);

        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        
        Contact objContact1 = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact1.Email = 'Test123@gmail.com';
        Utility.processRecords(objContact1, 'insert');
        
        PriceBook2 pricebook = TestDataFactory.createPricebook(1, 'Test PB', false)[0];
        pricebook.GPE_Event__c = true;
        Utility.processRecords(pricebook, 'insert');
        System.assertEquals(true, pricebook.GPE_Event__c);
        
        Opportunity objOpportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, pricebook.id, false)[0];
        objOpportunity.StageName = 'Closed Won';
        Utility.processRecords(objOpportunity, 'insert');
        System.assertEquals('Closed Won', objOpportunity.StageName);
        
        List<OpportunityContactRole> corList = new List<OpportunityContactRole>();
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = objContact.Id;
        ocr.OpportunityId = objOpportunity.Id;
        ocr.Role = 'Billing Contact';
        corList.add(ocr);
        OpportunityContactRole ocr1 = new OpportunityContactRole();
        ocr1.ContactId = objContact1.Id;
        ocr1.OpportunityId = objOpportunity.Id;
        ocr1.Role = 'Shipping Contact';
        corList.add(ocr1);
        Utility.processRecords(corList, 'insert');
        
        List<OpportunityContactRole> updateList = corList;
        updateList[0].ContactId = objContact1.Id;
        updateList[1].ContactId = objContact.Id;
        
        Quote quote = TestDataFactory.createQuote(1, false)[0];
        quote.OpportunityId = objOpportunity.Id;
        Utility.processRecords(quote, 'insert');
        
        Quote_Contact_Tab_LEX.fetchContactRole(quote.Id);
        Quote_Contact_Tab_LEX.fetchContactOfAccount(quote.Id);
        List<OpportunityContactRole> corList1 = Quote_Contact_Tab_LEX.addContactRoleListing(String.valueOf(quote.Id), corList, updateList);
    }
}
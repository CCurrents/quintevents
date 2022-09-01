/**
 * @File Name          : SW_Contact_LEXTest.cls
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
private with sharing class SW_Contact_LEX_Test{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void contactFirstTestExecution() {
        Account objAccount = TestDataFactory.createAccount();
        System.assert(true,objAccount.Name != null);

        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        System.assertEquals('Test@gmail.com', objContact.Email);

        PriceBook2 pricebook = TestDataFactory.createPricebook(1, 'Test PB', false)[0];
        pricebook.GPE_Event__c = true;
        Utility.processRecords(pricebook, 'insert');
        System.assertEquals(true, pricebook.GPE_Event__c);
        
        Opportunity objOpportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, pricebook.id, false)[0];
        objOpportunity.StageName = 'Closed Won';
        Utility.processRecords(objOpportunity, 'insert');
        System.assertEquals('Closed Won', objOpportunity.StageName);
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = objContact.Id;
        ocr.OpportunityId = objOpportunity.Id;
        Utility.processRecords(ocr, 'insert');
        List<OpportunityContactRole> corList = new List<OpportunityContactRole>();
        corList.add(ocr);
        Quote quote = TestDataFactory.createQuote(1, false)[0];
        quote.OpportunityId = objOpportunity.Id;
        Utility.processRecords(quote, 'insert');
        SW_Contact_LEX.fetchContactRole(quote.Id);
        SW_Contact_LEX.fetchContactOfAccount(quote.Id);
        SW_Contact_LEX.filtterContactRole('test', objAccount.Id);
        SW_Contact_LEX.getPickListValuesIntoList(Json.serialize(corList));
        SW_Contact_LEX.addinputFieldMethod(Json.serialize(corList));
        SW_Contact_LEX.addContactRoleListing(Json.serialize(corList), Json.serialize(corList), Json.serialize(corList));
        Contact newContactInsert = objContact.clone(false,false,false,false);
        newContactInsert.Email = 'Test123@gmail.com';
        SW_Contact_LEX.saveNewContact(newContactInsert , quote.id);
    }
}
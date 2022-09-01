/**
 * @description       : 
 * @author            : ratik.singhal@addonblue.com
 * @group             : 
 * @last modified on  : 07-30-2021
 * @last modified by  : ratik.singhal@addonblue.com
**/
@isTest
public class ContactAddressCopytoQuotesCntrlTest {
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        TestDataFactory.createSFDCIntacctMapping();
    }
    
    static testMethod void getAccountId()  {
        Test.startTest();
        
        Account objAccount = TestDataFactory.createAccount();
        System.assert(true,objAccount.Name != null);
       	Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        PriceBook2 pricebook = TestDataFactory.createPricebook(1, 'Test PB', false)[0];
        pricebook.GPE_Event__c = true;
        Utility.processRecords(pricebook, 'insert');
        System.assertEquals(true, pricebook.GPE_Event__c);
        
        Opportunity objOpportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, pricebook.id, false)[0];
        objOpportunity.StageName = 'Closed Won';
        Utility.processRecords(objOpportunity, 'insert');
        System.assertEquals('Closed Won', objOpportunity.StageName);
        
        Quote quote = TestDataFactory.createQuote(1, objOpportunity.Id, pricebook.Id)[0];
        quote.OpportunityId = objOpportunity.Id;
        Utility.processRecords(quote, 'insert');
        
        ContactAddressCopytoQuotesCntrl.updateAddressOnQuotes(quote.Id);
        Test.stopTest();  
    }
}
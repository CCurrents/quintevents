/**
 * @File Name          : OpportunityContactRoleTriggerHelperTest.cls
 * @Description        : 
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 11/13/2020
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    11/13/2020   kchavda@addonblue.com     Initial Version
**/
@isTest
private with sharing class OpportunityContactRoleTriggerHelperTest{
    @testSetup static void setup() { 
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void testOne() {
        Test.startTest();
        Account objAccount = TestDataFactory.createAccount();        
        objAccount.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Reseller').getRecordTypeId();
        update objAccount;
        
        
        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        objContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Reseller Client').getRecordTypeId();
        Utility.processRecords(objContact, 'insert');
        System.assertEquals('Test@gmail.com', objContact.Email);
        
       
        Opportunity objOpportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, Test.getStandardPricebookId(), false)[0]; 
        Utility.processRecords(objOpportunity, 'insert');
        System.assertEquals('Qualified', objOpportunity.StageName);
        
        OpportunityContactRole objContactRole = new OpportunityContactRole();
        objContactRole.OpportunityId = objOpportunity.Id;
        objContactRole.ContactId = objOpportunity.Primary_Contact__c;
        objContactRole.Role = 'Commission Contact';          
        insert objContactRole;
        
        Test.getEventBus().deliver();
        Test.stopTest();
       system.debug('@@@objContactRole=='+objContactRole);
        
    }
}
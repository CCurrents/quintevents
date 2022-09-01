/**
 * @File Name          : CustomLookup_LEX_Test.cls
 * @Description        : 
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 5/8/2020, 4:04:22 AM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    7/03/2020   fsuraitawala@addonblue.com       Initial Version
**/
@isTest
private with sharing class CustomLookup_LEX_Test {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    
    @isTest static void contactFirstTestExecution() {
        Account objAccount = TestDataFactory.createAccount();
        System.assert(true,objAccount.Name != null);

        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        
        CustomLookup_LEX.GetRecentRecords('Account', null, 1);
        CustomLookup_LEX.GetRecentRecords('Contact', new List<String> {'Name'}, 1);
        CustomLookup_LEX.createACRelationShip(objAccount.Id, objContact);
    }
}
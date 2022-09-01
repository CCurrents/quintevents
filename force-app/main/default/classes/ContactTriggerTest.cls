/**
 * @File Name          : ContactTriggerTest.cls
 * @Description        : Test class for code coverage of PricebookTrigger classes
 * @Author             : fsuraitawalal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawalal@addonblue.com
 * @Last Modified On   : 17/3/2020
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    17/3/2020   fsuraitawalal@addonblue.com     Initial Version
**/
@isTest
private class ContactTriggerTest {
    
    /**
    * @description  : 
    * @author       : fsuraitawala@addonblue.com
    * @return       : void
    **/
    @isTest static void testMethod_one() {
        TestDataFactory.createTriggerSettingsEntry();
        List<Account> lstAccount = TestDataFactory.createAccount(2);
        
        List<Contact> lstContact = TestDataFactory.createContact(2, lstAccount, false);
        lstContact[0].Primary_Contact__c = true;
        Utility.processRecords(lstContact, 'insert');
        
        List<Contact> lstUpdateContact = new List<Contact>();
        for(Contact objCon: lstContact) {
            objCon.LastName = 'Test LastName';
            lstUpdateContact.add(objCon);
        }
        
        Utility.processRecords(lstUpdateContact, 'update');
    }
}
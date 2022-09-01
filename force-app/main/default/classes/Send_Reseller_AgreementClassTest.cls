/**
 * @description       : 
 * @author            : jagrawal@addonblue.com
 * @group             : 
 * @last modified on  : 11-03-2020
 * @last modified by  : jagrawal@addonblue.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   10-27-2020   jagrawal@addonblue.com   Initial Version
 * 1.1   10-27-2020   jagrawal@addonblue.com   #596 Changed RecordType name from Travel Agent to Reseller
 * 1.2   11-03-2020   jagrawal@addonblue.com   #610 Removed reference of field Agreement_Sent__c
**/
@isTest
public class Send_Reseller_AgreementClassTest {
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        TestDataFactory.createSFDCIntacctMapping();
    }
    static testMethod void getClientId()  {
        Account objAccount = TestDataFactory.createAccount();
        // #596 Changed RecordType name from Travel Agent to Reseller
        objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Reseller').getRecordTypeId();
        update objAccount;
        Contact objContact = TestDataFactory.createContact(objAccount);
        Send_Reseller_AgreementClass.readBaseUrl();
        Send_Reseller_AgreementClass.generateResellerAgreementFile(objContact.Id);
        // #610 Removed reference of field Agreement_Sent__c 
        // objContact.Agreement_Sent__c = true;
        // update objContact;
        // Send_Reseller_AgreementClass.updateContact(objContact.Id);
    }
    
}
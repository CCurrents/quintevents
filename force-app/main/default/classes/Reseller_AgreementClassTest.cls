/**
 * @description       : 
 * @author            : jagrawal@addonblue.com
 * @group             : 
 * @last modified on  : 10-27-2020
 * @last modified by  : jagrawal@addonblue.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   10-27-2020   jagrawal@addonblue.com   Initial Version
 * 1.1   10-27-2020   jagrawal@addonblue.com   #596 Changed RecordType name from Travel Agent to Reseller
**/
@isTest
public class Reseller_AgreementClassTest {
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
        Test.setCurrentPageReference(new PageReference('Page.Reseller_AgreementPage')); 
        System.currentPageReference().getParameters().put('id', objContact.Id);
        Reseller_AgreementClass resellercontroller = new Reseller_AgreementClass();
    }
    
}
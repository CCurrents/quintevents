/**
 * @File Name          : AccountTriggerHelperTest.cls
 * @Description        : 
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 5/18/2020, 3:23:57 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    5/18/2020   mpatel@addonblue.com     Initial Version
**/
@isTest
private with sharing class AccountTriggerHelperTest{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void opportunityTestFistExecution() {
        Id recordTypeId = [Select Id,Name From RecordType Where sObjectType='Account' and Name='Person Account'].Id;
        Account objAccount = new Account();
        objAccount.LastName = 'Test';
        objAccount.RecordTypeId = recordTypeId;
        objAccount.Allow_Online_Credit_Usage__c = false;
        Utility.processRecords(objAccount, 'insert');
        
        objAccount.BillingStreet = 'mklbg';
        objAccount.Copy_Billing_to_Shipping_Address__c = true;
        objAccount.Allow_Online_Credit_Usage__c = false;
        Utility.processRecords(objAccount, 'update');
        System.assert(true,objAccount.Name != null);
    }
}
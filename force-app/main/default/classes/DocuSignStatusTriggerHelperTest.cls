/**
 * @File Name          : DocuSignStatusTriggerHelperTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 08-12-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/8/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
public class DocuSignStatusTriggerHelperTest {
	@isTest static void testMethod_one() {        
        TestDataFactory.createTriggerSettingsEntry();
        Quote quote = TestDataFactory.createQuote(); 
        
        dsfs__DocuSign_Status__c testDSStatus = TestDataFactory.createDocuSignStatus(quote)[0];
        testDSStatus.dsfs__Subject__c = 'Reimbursement Addendum';
        insert testDSStatus;

        List<Id> lstQuotes = new List<Id>();
        lstQuotes.add(quote.Id);
        DocuSignStatusTriggerHelper.VoidEnvelopeFromOpp(lstQuotes);
        
        testDSStatus.dsfs__Envelope_Status__c = 'Sent';
        testDSStatus.Has_Counter_Signer__c = false;
        update testDSStatus;

        System.assertEquals('Sent', testDSStatus.dsfs__Envelope_Status__c);
    }
    @isTest static void testMethod_two() {        
        TestDataFactory.createTriggerSettingsEntry();
        Quote quote = TestDataFactory.createQuote(); 
        
        dsfs__DocuSign_Status__c testDSStatus = TestDataFactory.createDocuSignStatus(quote)[0];
        testDSStatus.dsfs__Subject__c = 'Reimbursement Addendum';
        insert testDSStatus;

        List<Id> lstQuotes = new List<Id>();
        lstQuotes.add(quote.Id);
        DocuSignStatusTriggerHelper.VoidEnvelopeFromOpp(lstQuotes);
        
        testDSStatus.dsfs__Envelope_Status__c = 'Completed';
        testDSStatus.Has_Counter_Signer__c = false;
        update testDSStatus;

        System.assertEquals('Completed', testDSStatus.dsfs__Envelope_Status__c);
    }
}
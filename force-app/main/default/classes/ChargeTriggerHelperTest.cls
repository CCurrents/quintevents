/**
 * @File Name          : ChargeTriggerHelperTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : Lovel Panchal
 * @Last Modified On   : 5/28/2020, 2:04:59 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/8/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
public class ChargeTriggerHelperTest {
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        TestDataFactory.createSFDCIntacctMapping();
    }
    @isTest static void test1(){
        Test.startTest();
        Account acc = TestDataFactory.createAccount();
        Test.stoptest();
        Charge__c objcharge = new Charge__c();
        System.debug('acc.Id@@'+acc.Id);
        objcharge.Account__c = acc.Id;
        objcharge.CurrencyIsoCode = 'USD';
        objcharge.Amount__c = 1000;
        objcharge.RecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
        insert objcharge;
        update objcharge;
    }
    
    @isTest static void test2(){
        Test.startTest();
        Account objAccount = TestDataFactory.createAccount();
        System.assert(true,objAccount.Name != null);

        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        System.assertEquals('Test@gmail.com', objContact.Email);

        PriceBook2 priceBook = TestDataFactory.createPricebook(1, 'T', false)[0];
        priceBook.Payment_Cancellation_Days__c = 2;
        priceBook.Start_Date__c = system.today();
        priceBook.Event_Payment_Window__c = 1;
        Utility.processRecords(pricebook, 'insert');

        Opportunity opportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, pricebook.id, false)[0];
        opportunity.PriceBook2Id = pricebook.Id;
        opportunity.StageName = 'Closed Won';
        Utility.processRecords(opportunity, 'insert');
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = objContact.Id;
        ocr.OpportunityId = Opportunity.Id;
        ocr.Role = 'H4H Rewards Contact';
        Utility.processRecords(ocr, 'insert');
        
        TestDataFactory.createSFDCIntacctMapping();
        
        Order objorder = TestDataFactory.createOrder(1,false)[0];
        objorder.OpportunityId = opportunity.Id;
        objorder.Subject_to_Cancellation__c = false;
        Utility.processRecords(objorder, 'insert');
        Test.stoptest();
        //Order objorder = TestDataFactory.createOrder();
        objorder.Status = 'Credited - Sales Adjustment';
        update objorder;
        Charge__c objcharge = new Charge__c();
        objcharge.Account__c = objorder.AccountId;
        objcharge.Order__c = objorder.Id;
        objcharge.CurrencyIsoCode = 'USD';
        objcharge.Amount__c = 1000;
        objcharge.RecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
        insert objcharge;
    }
    
    @isTest static void test3(){
        Test.startTest();
        Payment_Term__c objPT = TestDataFactory.createPaymentTerm();
        Account acc = [Select Id from Account limit 1];
        Test.stoptest();
        Charge__c objcharge = new Charge__c();
        objcharge.Account__c = acc.Id;
        objcharge.Payment_Terms__c = objPT.Id;
        objcharge.Order__c = null;
        objcharge.CurrencyIsoCode = 'USD';
        objcharge.Amount__c = 1000;
        objcharge.RecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
        insert objcharge;
    }
    
    @isTest static void test4(){
        Test.startTest();
        Payment_Term__c objPT = TestDataFactory.createPaymentTerm();
        objPT.CurrencyIsoCode = 'AUD';
        update objPT;
        Account acc = [Select Id from Account limit 1];
        Test.stoptest();
        Charge__c objcharge = new Charge__c();
        objcharge.Account__c = acc.Id;
        objcharge.Payment_Terms__c = objPT.Id;        
        objcharge.Credit_Used__c = true;
        objcharge.Amount__c = 2000;
        objcharge.RecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Debit').getRecordTypeId();
        try{
            insert objcharge;
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    
    @isTest static void test5(){
        Test.startTest();
        Payment_Term__c objPT = TestDataFactory.createPaymentTerm();
        objPT.CurrencyIsoCode = 'CAD';
        update objPT;
        Account acc = [Select Id from Account limit 1];
        Test.stoptest();
        Charge__c objcharge = new Charge__c();
        objcharge.Account__c = acc.Id;
        objcharge.Payment_Terms__c = objPT.Id;        
        objcharge.Credit_Used__c = true;
        objcharge.Amount__c = 2000;
        objcharge.RecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Debit').getRecordTypeId();
        try{
            insert objcharge;
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    
    @isTest static void test6(){
        Test.startTest();
        Payment_Term__c objPT = TestDataFactory.createPaymentTerm();
        objPT.CurrencyIsoCode = 'EUR';
        update objPT;
        Account acc = [Select Id from Account limit 1];
        Test.stoptest();
        Charge__c objcharge = new Charge__c();
        objcharge.Account__c = acc.Id;
        objcharge.Payment_Terms__c = objPT.Id;        
        objcharge.Credit_Used__c = true;
        objcharge.Amount__c = 2000;
        objcharge.RecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Debit').getRecordTypeId();
        try{
            insert objcharge;
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    
    @isTest static void test7(){
        Test.startTest();
        Payment_Term__c objPT = TestDataFactory.createPaymentTerm();
        objPT.CurrencyIsoCode = 'GBP';
        update objPT;
        Account acc = [Select Id from Account limit 1];
        Test.stoptest();
        Charge__c objcharge = new Charge__c();
        objcharge.Account__c = acc.Id;
        objcharge.Payment_Terms__c = objPT.Id;        
        objcharge.Credit_Used__c = true;
        objcharge.Amount__c = 2000;
        objcharge.RecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Debit').getRecordTypeId();
        try{
            insert objcharge;
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    
    @isTest static void test8(){
        test.startTest();
        Payment_Term__c objPT = TestDataFactory.createPaymentTerm();
        objPT.CurrencyIsoCode = 'USD';
        update objPT;
        Account acc = [Select Id from Account limit 1];
        Test.stoptest();
        Charge__c objcharge = new Charge__c();
        objcharge.Account__c = acc.Id;
        objcharge.Payment_Terms__c = objPT.Id;        
        objcharge.Credit_Used__c = true;
        objcharge.Amount__c = 2000;
        objcharge.RecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Debit').getRecordTypeId();
        try{
            insert objcharge;
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    
    @isTest static void test9(){
        Test.startTest();
        Payment_Term__c objPT = TestDataFactory.createPaymentTerm();
        objPT.CurrencyIsoCode = 'USD';
        objPT.Amount__c = 1000;
        update objPT;
        Account acc = [Select Id from Account limit 1];
        Test.stoptest();
        Charge__c objcharge = new Charge__c();
        objcharge.Account__c = acc.Id;
        objcharge.Payment_Terms__c = objPT.Id;        
        objcharge.Credit_Used__c = true;
        objcharge.Amount__c = 2000;
        objcharge.RecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Debit').getRecordTypeId();
        try{
            insert objcharge;
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    @isTest static void test10(){
        Test.startTest();
        Payment_Term__c objPT = TestDataFactory.createPaymentTerm();
        objPT.CurrencyIsoCode = 'SAR';
        objPT.Amount__c = 1000;
        update objPT;
        Account acc = [Select Id from Account limit 1];
        Test.stoptest();
        Charge__c objcharge = new Charge__c();
        objcharge.Account__c = acc.Id;
        objcharge.Payment_Terms__c = objPT.Id;        
        objcharge.Credit_Used__c = true;
        objcharge.Amount__c = 2000;
        objcharge.RecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Debit').getRecordTypeId();
        try{
            insert objcharge;
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    @isTest static void test11(){
        Test.startTest();
        Payment_Term__c objPT = TestDataFactory.createPaymentTerm();
        objPT.CurrencyIsoCode = 'THB';
        objPT.Amount__c = 1000;
        update objPT;
        Account acc = [Select Id from Account limit 1];
        Test.stoptest();
        Charge__c objcharge = new Charge__c();
        objcharge.Account__c = acc.Id;
        objcharge.Payment_Terms__c = objPT.Id;        
        objcharge.Credit_Used__c = true;
        objcharge.Amount__c = 2000;
        objcharge.RecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Debit').getRecordTypeId();
        try{
            insert objcharge;
        }
        catch(Exception e){
            System.debug(e);
        }
    }
}
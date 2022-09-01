/**
 * @File Name          : PricebookCloneCtrlTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 15/6/2020, 11:57:01 am
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    15/6/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class PricebookCloneCtrlTest {
    @isTest static void testMethod_one() {
        TestDataFactory.createTriggerSettingsEntry();
        
        //******* Pricebook *******//
        Pricebook2 testPricebook = TestDataFactory.createPricebook();
        
        List<Event_Payment_Terms__c> lstEventPaymentTerm = TestDataFactory.createEventPaymentTerm(1);
        lstEventPaymentTerm[0].Price_Book__c = testPricebook.Id;
        update lstEventPaymentTerm;
        
        //******* Product2 *******//
        List<Product2> lstProduct = new List<Product2>();
        Product2 objProduct1 = TestDataFactory.createProduct('Test Product', 'Product', 'Transportation', null, testPricebook.Id);
        lstProduct.add(objProduct1);
        
        Product2 objProduct2 = TestDataFactory.createProduct('Test Hotel', 'Hotel', 'Hospitality', null, testPricebook.Id);
        lstProduct.add(objProduct2);
        
        Product2 objProduct3 = TestDataFactory.createProduct('Test Hotel Stay', 'Hotel Stay', 'Stay', null, testPricebook.Id);
        lstProduct.add(objProduct3);
        
        lstProduct = Utility.processRecords(lstProduct, 'insert');
        
        //******* Products_Bundle__c *******//
        List<Products_Bundle__c> lstBundle = new List<Products_Bundle__c>();
        
        Products_Bundle__c objBundle1 = TestDataFactory.createProductBundle(objProduct2.Id, objProduct1.Id, 'Hotel Stay');
        lstBundle.add(objBundle1);
        
        Products_Bundle__c objBundle2 = TestDataFactory.createProductBundle(objProduct3.Id, objProduct2.Id, 'Hotel Transportation');
        lstBundle.add(objBundle2);
        
        lstBundle= Utility.processRecords(lstBundle, 'insert');
        
        PricebookCloneCtrl.fetchBaseUrl();
        PricebookCloneCtrl.fetchPricebookValues(testPricebook.Id);
        System.assertEquals(lstEventPaymentTerm[0].Price_Book__c, testPricebook.Id);
    }
}
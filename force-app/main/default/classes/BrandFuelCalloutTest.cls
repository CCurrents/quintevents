/**
 * @File Name          : BrandFuelCalloutTest.cls
 * @Description        : test class coverage for the BrandFuelCallout controller
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/8/2020, 3:50:58 AM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    3/16/2020   mpatel@addonblue.com     Initial Version
**/ 
@isTest
public class BrandFuelCalloutTest{
    @testSetup public static void setup() {
        TestDataFactory.createTriggerSettingsEntry();
    }
    @isTest static void testMethodOne() {
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
        
        Order order = TestDataFactory.createOrder(1,false)[0];
        order.OpportunityId = opportunity.Id;
        order.Subject_to_Cancellation__c = false;
        Utility.processRecords(order, 'insert');
        
        Test.startTest();
        List<Id> ids = new List<Id>();
        ids.add(order.id);
        Integration_Setting__mdt integraitionSetting = new Integration_Setting__mdt();
        integraitionSetting.DeveloperName = 'BrandFuelGetRequest';
        integraitionSetting.Is_Active__c = true;
        Utility.processRecords(integraitionSetting, 'insert'); 
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('BrandFuel');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
               
        BrandFuelCallout.checkUserExists('BF', 'BF@addonbluee.com', [Select Id from Order][0].Id, ids, [Select Id from Opportunity][0].Id, [Select Id,Name from Opportunity][0].Name, system.today(), true, [Select Id,Primary_Contact__c from Opportunity][0].Primary_Contact__c, system.today());
        BrandFuelCallout.cuponDataSubMethod([Select Id from Order][0].Id,ids,'23455','test pb','test@addonblue',System.Today(), 'vfbhvbdhfvbh', system.today());
        BrandFuelCallout.couponRecCreateOldEmail([Select Id from Order][0].Id,ids,TestDataFactory.createPriceBook().Id,'test pb','test@addonblue',System.Today(), [Select Id,Primary_Contact__c from Opportunity][0].Primary_Contact__c, 'vfbhvbdhfvbh', system.today());
        BrandFuelCallout.updateCouponAmount([Select Id from Order][0].Id,ids,'23455','test pb','test@addonblue',System.Today(), 'vfbhvbdhfvbh', system.today());
        Test.stopTest();
    }
}
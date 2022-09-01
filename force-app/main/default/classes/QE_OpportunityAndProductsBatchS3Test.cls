/**
 * @File Name          : QE_OpportunityAndProductsBatchS3Test.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/10/2020, 4:21:15 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    5/10/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
public class QE_OpportunityAndProductsBatchS3Test
{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }

    static testMethod void testMethods3Opp()
    {
      
        
        
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Source__c = 'call Virtuoso';
        lead.email = 'testtesttest@quintevents.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
        Id recId = [Select ID from RecordType WHERE SobjectType='Opportunity' and DeveloperName='Business_Opportunity'].Id;
        // Opportunity
        Opportunity oppTest = new Opportunity();
        oppTest.Name = 'Formula 1';
        oppTest.AccountId = testLead.ConvertedAccountId;        
        oppTest.Pricebook2Id= Test.getStandardPricebookId();
        oppTest.StageName = 'Under Review';
        oppTest.CloseDate = System.today();
        oppTest.Contact_Site__c = 'quintevents.com';
        oppTest.Shipping_Outside_US__c = 'Yes';
        oppTest.Email__c = 'test12m@gmail.com';
        oppTest.Billing_Street__c = '123 street';
        oppTest.Billing_City__c = 'testcity';
        oppTest.Billing_State_Province__c = 'California';
        oppTest.Billing_Zip_Postal_Code__c = '1234521';
        oppTest.Billing_Country__c = 'United States';
        oppTest.RecordTypeId = recId;

               
        oppTest.Payment_Method__c = 'Credit Card';
        insert oppTest;
        System.debug('=====opportunity--'+ oppTest);
        
        Quote quot = new Quote(Name='Test Quote',Payment_Terms__c = '1/2',OpportunityId=oppTest.Id,Status='Draft',Payment_Method__c='Credit Card',Email='test@test435.com',Pricebook2Id = Test.getStandardPricebookId());
        insert quot;
        
      
        // Products to be inserted
        List<Product2> productsToBeInserted = new List<Product2>();
        
        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Pricebook2__c = Test.getStandardPricebookId();
        insert parentPackage;


        // Package
        Product2 testPackage = new Product2(Name='BXCD11',Primary_Price_Book__c=Test.getStandardPricebookId(), Parent_Package__c=parentPackage.id, Type__c='Package', isActive=true,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId());
        productsToBeInserted.add(testPackage);
        
        // Products
        Product2 testProduct = new Product2(Name='BXCD22', Type__c='Ticket',Primary_Price_Book__c=Test.getStandardPricebookId(), isActive=true,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId(), A_La_Carte__c = true, Available__c=true,Quantity_Per_Order_Threshold__c=1);
        productsToBeInserted.add(testProduct);
        
        Product2 testProduct2 = new Product2(Name='BXCD33', Type__c='Ticket',Primary_Price_Book__c=Test.getStandardPricebookId(), isActive=true,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        productsToBeInserted.add(testProduct2);
        
        Product2 testHotel = new Product2(Name='BXCD44', Type__c='Hotel',Primary_Price_Book__c=Test.getStandardPricebookId(), isActive=true,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotel').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        productsToBeInserted.add(testHotel);
        
        Product2 testProductShippingAndHandling = new Product2(Name='BXCD34',Primary_Price_Book__c=Test.getStandardPricebookId(), isActive=true,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId(),Available__c=true,Type__c='Shipping and Handling', Quantity_Per_Order_Threshold__c=1);
        productsToBeInserted.add(testProductShippingAndHandling);

        insert productsToBeInserted;
        Test.StartTest();
        
        // Package Products
        List<Package_Products__c> packageProductsToBeInserted = new List<Package_Products__c>();
        
        Package_Products__c packageProduct = new Package_Products__c(Package__c = testPackage.Id, Products_and_Hotels__c = testProduct.Id);
        packageProductsToBeInserted.add(packageProduct);
        
        Package_Products__c packageProduct2 = new Package_Products__c(Package__c = testPackage.Id, Products_and_Hotels__c = testProduct2.Id);
        packageProductsToBeInserted.add(packageProduct2);
        
        Package_Products__c packageProductHotel = new Package_Products__c(Package__c = testPackage.Id, Products_and_Hotels__c = testHotel.Id);
        packageProductsToBeInserted.add(packageProductHotel);
        
        Insert packageProductsToBeInserted;
        

        // Price book entries
        List<PricebookEntry> pricebookEntriesToBeAdded = new List<PricebookEntry>();
        
        PricebookEntry pricebookEntryPackage =new PricebookEntry(unitprice=0.01,Product2Id=testPackage.Id,Pricebook2Id=Test.getStandardPricebookId(),isActive=true,UseStandardPrice = false);
        pricebookEntriesToBeAdded.add(pricebookEntryPackage);
        
        PricebookEntry pricebookEntryTestProduct = new PricebookEntry(unitprice=0.01,Product2Id=testProduct.Id,Pricebook2Id=Test.getStandardPricebookId(),isActive=true,UseStandardPrice = false);
        pricebookEntriesToBeAdded.add(pricebookEntryTestProduct);
        
        PricebookEntry pricebookEntryTestProduct2 = new PricebookEntry(unitprice=0.01,Product2Id=testProduct2.Id,Pricebook2Id=Test.getStandardPricebookId(),isActive=true,UseStandardPrice = false);
        pricebookEntriesToBeAdded.add(pricebookEntryTestProduct2);
        
        PricebookEntry pricebookEntryShippingAndHandling = new PricebookEntry(unitprice=0.01,Product2Id=testProductShippingAndHandling.Id,Pricebook2Id=Test.getStandardPricebookId(),isActive=true,UseStandardPrice = false);
        pricebookEntriesToBeAdded.add(pricebookEntryShippingAndHandling);
        
        Insert pricebookEntriesToBeAdded;
        
        // Opportunity Line Items
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem (Record_Type__c = 'Package',UnitPrice=0.2, Quantity=2, OpportunityId=oppTest.Id,PriceBookEntryId=pricebookEntryPackage.Id,product2id=testProduct.Id);
        insert opportunityLineItem;
        System.debug('----opportunityLineItem--'+ opportunityLineItem);
        
        OpportunityLineItem opportunityLineItemTestProduct = new OpportunityLineItem(Record_Type__c = 'Package',UnitPrice=0.6,Quantity=2, OpportunityId=oppTest.Id,PriceBookEntryId=pricebookEntryTestProduct.Id,product2id=testPackage.Id);
        insert opportunityLineItemTestProduct;
        
        oppTest.StageName = 'Closed Won';
        update oppTest;
   
          
        QE_OpportunityAndProductsBatchUploadS3 S3UpdateWithOpp = new QE_OpportunityAndProductsBatchUploadS3();        
        Id batchId = DataBase.executeBatch(S3UpdateWithOpp);
        
        Test.StopTest();
    
}


}
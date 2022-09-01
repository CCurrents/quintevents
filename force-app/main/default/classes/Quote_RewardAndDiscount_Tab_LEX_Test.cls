/**
 * @File Name          : Quote_RewardAndDiscount_Tab_LEX_Test.cls
 * @Description        : This test class use for Quote_RewardAndDiscount_Tab_LEX.
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 12-28-2020
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    26/04/2020   fsuraitawala@addonblue.com     Initial Version
**/
@isTest
private class Quote_RewardAndDiscount_Tab_LEX_Test {
    
    /****************************************/
    @TestSetup
    static void setupTestData() {
        TestDataFactory.createTriggerSettingsEntry();
        
        //******* Pricebook *******//
        Pricebook2 testPricebook = TestDataFactory.createPricebook();
        
        //******* Parent Package *******//
        List<Parent_Package__c> lstParentPackage = TestDataFactory.createParentPackage(1, true, testPricebook.Id);
        
        //******* Product *******//
        List<Product2> lstProduct = new List<Product2>();
        Product2 objProduct = TestDataFactory.createProduct('Test Package Product', 'Package', 'Package', lstParentPackage[0].Id, testPricebook.Id);
        lstProduct.add(objProduct);
        lstProduct = Utility.processRecords(lstProduct, 'insert');
        
        //******* Account *******//
        Account acc = TestDataFactory.createAccount();
        
        //******* Contact *******//
        Contact con = TestDataFactory.createContact(acc.Id);
        
        //******* Opportunity *******// 
        Opportunity opportunity = TestDataFactory.createOpportunity(1, acc.Id, con.Id, testPricebook.Id, true)[0];
        
        //******* Quote *******//
        Quote objquote = TestDataFactory.createQuote(1, opportunity, testPricebook.Id)[0];
    
    }
    
    /****************************************/
    @isTest
    static void testRunOne() {
        Quote currentQuote = [Select Id, Pricebook2Id From Quote Limit 1];
        
        PricebookEntry objPBE = [Select Id, Product2.Type__c FROM PricebookEntry 
                                 WHERE Product2.Type__c = 'Package' AND Pricebook2Id = :currentQuote.Pricebook2Id LIMIT 1];
        QuoteLineItem newParentQLI = TestDataFactory.createQuoteLineItem(currentQuote.Id, objPBE.Id, 'Package', null, null, true);
        
        Test.startTest();
        Quote_RewardAndDiscount_Tab_LEX.getDiscountLineItem(currentQuote.Id);
        Quote_RewardAndDiscount_Tab_LEX.getRewardLineItem(currentQuote.Id);
        Quote_RewardAndDiscount_Tab_LEX.fetchContactRole(currentQuote.Id);
        Quote_RewardAndDiscount_Tab_LEX.getPriceBookEntries(currentQuote.Id);
        SW_Utility_LEX.LineItemBundles objLineItemBundles = Quote_RewardAndDiscount_Tab_LEX.getSavedLineItems(currentQuote.Id);
        
        Quote_RewardAndDiscount_Tab_LEX.saveQuoteLineItem(objLineItemBundles, currentQuote.Id, null, 500, true);
        
        Quote_RewardAndDiscount_Tab_LEX.getSavedLineItems(currentQuote.Id);
        Quote_RewardAndDiscount_Tab_LEX.getDiscountLineItem(currentQuote.Id);
        Quote_RewardAndDiscount_Tab_LEX.getRewardLineItem(currentQuote.Id);
        Quote_RewardAndDiscount_Tab_LEX.getRewardPointsOfContact([Select Id From Contact Limit 1].Id);
        Quote_RewardAndDiscount_Tab_LEX.getCurrentQuoteRecord(currentQuote.Id);
        
        Test.stopTest();
    }
}
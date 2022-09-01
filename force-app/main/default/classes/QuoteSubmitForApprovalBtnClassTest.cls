@isTest
public class QuoteSubmitForApprovalBtnClassTest {
	@isTest static void testMethod_one() {
        TestDataFactory.createTriggerSettingsEntry();
        Quote quote = TestDataFactory.createQuote(1,false)[0];        
        List<QuoteLineItem> qli = TestDataFactory.createQuoteLineItem(1);        
        QuoteSubmitForApprovalBtnClass.updateQuoteStatusLightning(qli[0].quoteId);
        QuoteSubmitForApprovalBtnClass.updateQuoteStatusLightning(null);
        quote.Status = 'Draft - Approved';
        Utility.processRecords(quote, 'insert');
        QuoteSubmitForApprovalBtnClass.updateQuoteStatusLightning(quote.Id);
        System.assertEquals(1, qli.size());
    }
    @isTest static void testMethod_two() {
        TestDataFactory.createTriggerSettingsEntry();
        List<Quote> quoteList = new List<Quote>();
        Quote quote = TestDataFactory.createQuote(1,false)[0]; 
        quote.Status = 'Draft';
        Quote quote2 = TestDataFactory.createQuote(1,false)[0]; 
        quote2.Status = 'Draft';
        quoteList.add(quote);
        quoteList.add(quote2);
        Utility.processRecords(quoteList, 'insert');
        
        Product2 objProduct = TestDataFactory.createProduct();
        PricebookEntry PBEObj = TestDataFactory.createPricebookEntry();
        
        
        List<QuoteLineItem> qli = new List<QuoteLineItem>();
		QuoteLineItem objQLI1 = new QuoteLineItem(
            Quantity = 2,
            Product2ID= objProduct.Id,
            QuoteId = quote.Id,
            UnitPrice = 0.01,
            PriceBookEntryId = PBEObj.Id );
        
        QuoteLineItem objQLI2 = new QuoteLineItem(
            Quantity = 2,
            Product2ID= objProduct.Id,
            QuoteId = quote2.Id,
            UnitPrice = 0.01,
            PriceBookEntryId = PBEObj.Id );	
        
        QuoteLineItem objQLI3 = new QuoteLineItem(
            Quantity = 2,
            Product2ID= objProduct.Id,
            QuoteId = quote.Id,
            UnitPrice = 0.01,
            PriceBookEntryId = PBEObj.Id );
        
        QuoteLineItem objQLI4 = new QuoteLineItem(
            Quantity = 2,
            Product2ID= objProduct.Id,
            QuoteId = quote2.Id,
            UnitPrice = 0.01,
            PriceBookEntryId = PBEObj.Id );	
        
        qli.add(objQLI1);
        qli.add(objQLI2);
        qli.add(objQLI3);
        qli.add(objQLI4);
        insert qli;
        
        Quote objQuote = new Quote();
        objQuote.Id = quote2.ID;
        objQuote.Original_Quote__c = quote.ID;
        update objQuote;
        QuoteSubmitForApprovalBtnClass.updateQuoteStatusLightning(quote.Id);
        QuoteSubmitForApprovalBtnClass.updateQuoteStatusLightning(quote2.Id);
        
    }
}
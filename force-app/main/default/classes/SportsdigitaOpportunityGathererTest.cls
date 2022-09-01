@isTest
public class SportsdigitaOpportunityGathererTest {
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        TestDataFactory.createSFDCIntacctMapping();
    }
    @isTest static void testOppGatherer(){
        Opportunity opp = TestDataFactory.createOpportunity();
        List<Quote> quote = TestDataFactory.createQuote(1, opp.Id, opp.Pricebook2Id);
        Test.startTest();
        List<QuoteLineItem> testQuoteLineItems = TestDataFactory.createQuoteLineItem(4, quote[0].Id, true);
        
        //Leave the first QuoteLineItem as the default
        testQuoteLineItems[0].Record_Type__c = 'Package';
        
        testQuoteLineItems[1].Record_Type__c = 'Package Hotel';
        testQuoteLineItems[2].Record_Type__c = 'Hotel Transportation';
        testQuoteLineItems[3].Record_Type__c = 'A La Carte';
        Utility.processRecords(testQuoteLineItems, 'update');
        Opportunity objopp = TestDataFactory.createOpportunity();
        SportsdigitaOpportunityGatherer oppGatherer = new SportsdigitaOpportunityGatherer();
        oppGatherer.mapDigideckSlides(objopp.Id, 'test');
        oppGatherer.getRulesetData(opp.Id);
        System.debug('quoteId@@'+quote[0].Id);
        Test.stopTest();
        
    }
    
}
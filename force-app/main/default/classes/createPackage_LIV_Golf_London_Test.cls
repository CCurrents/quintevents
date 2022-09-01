@isTest
private class createPackage_LIV_Golf_London_Test{
    @testSetup 
    static void setup() {
        TestDataFactory.createTriggerSettingsEntry();
        QuoteLineItem objQLI = TestDataFactory.createQuoteLineItem();
        System.debug('objQLI-->'+objQLI);
    }
    static testmethod void test() {        
        Test.startTest();
        
        Quote objQuote = [Select Id FROM Quote LIMIT 1];
        Map<String, Integer> mapQuotewithQty = new Map<String, Integer>();
        mapQuotewithQty.put(objQuote.Id, 1);
        
        PriceBookEntry objPBE = [Select Id FROM PriceBookEntry LIMIT 1];
        
        createPackage_LIV_Golf_London objBatch = new createPackage_LIV_Golf_London(mapQuotewithQty, objPBE.Id);
        Id batchId = Database.executeBatch(objBatch);
        Test.stopTest();
    }
}
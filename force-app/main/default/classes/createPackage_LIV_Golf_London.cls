global class createPackage_LIV_Golf_London implements Database.Batchable<sObject>, Database.Stateful {
    
    global Map<String, Integer> mapQuotewithQty;
    global String PBEId;
    
    global createPackage_LIV_Golf_London(Map<String, Integer> mapQuote, String PricebookId){
        this.mapQuotewithQty = mapQuote;
        this.PBEId = PricebookId;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug(mapQuotewithQty.keyset());
        Set<String> setQuoteId = mapQuotewithQty.keyset();
        return Database.getQueryLocator('Select Id From Quote WHERE Id IN :setQuoteId ');
    }
    global void execute(Database.BatchableContext bc, List<Quote> scope) {
        
        for(Quote objQuote: scope){
            PriceBookEntry selectedPriceBookEntry = [Select Id, Product2Id FROM PriceBookEntry WHERE Id = :PBEId];
            
            Quote_Product_Package_Tab_LEX.saveLineItemRecords(objQuote.Id, mapQuotewithQty.get(objQuote.Id), selectedPriceBookEntry);
        }
    }    
    global void finish(Database.BatchableContext bc) {
        System.debug('Records processed. Shazam!');
    }    
}
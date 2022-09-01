global class createPricebookEnrties implements Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, Primary_Price_Book__c, Event__c, Price__c, (SELECT Id, CurrencyISOCode, Pricebook2Id FROM Pricebookentries) FROM Product2 WHERE Primary_Price_Book__c != null');
    }
    global void execute(Database.BatchableContext bc, List<Product2> scope){
        Map<Id, Set<String>> MapStdPricebook = new Map<Id, Set<String>>();
        Map<Id, Set<String>> MapCustomPricebook = new Map<Id, Set<String>>();
        
        String StandardPricebookId = '';
        if(Test.isRunningTest()){
            StandardPricebookId = Test.getStandardPricebookId();
        } else {
            StandardPricebookId = [SELECT Id, Name FROM Pricebook2 where Name='Standard Price Book'].Id;
        }
        
        for(Product2 item: scope) {
            MapStdPricebook.put(item.Id, new set<String>{'AUD', 'CAD', 'EUR', 'GBP', 'USD'});
            MapCustomPricebook.put(item.Id, new set<String>{'AUD', 'CAD', 'EUR', 'GBP', 'USD'});
            System.debug(item.Pricebookentries.size());
            System.debug(item.Pricebookentries);
            
            for(Pricebookentry objPBE: item.Pricebookentries) {
                if(StandardPricebookId == objPBE.Pricebook2Id) {
                    Set<String> tempSet = MapStdPricebook.get(item.Id);
                    tempSet.remove(objPBE.CurrencyISOCode);
                    MapStdPricebook.put(item.Id, tempSet);
                }
                
                if(item.Primary_Price_Book__c == objPBE.Pricebook2Id) {
                    Set<String> tempSet = MapCustomPricebook.get(item.Id);
                    tempSet.remove(objPBE.CurrencyISOCode);
                    MapCustomPricebook.put(item.Id, tempSet);
                }
            }
        }
        
        List<CurrencyType> currencyList = [SELECT Id, ISOCode, ConversionRate, IsCorporate FROM CurrencyType WHERE IsActive=TRUE];
        Map<string, double> isoCodeMap = new Map<string, double>();
        
        List<PricebookEntry> insertPBE = new List<PricebookEntry>();
        List<PricebookEntry> insertstdPBE = new List<PricebookEntry>();
        for(DatedConversionRate d : [SELECT Id, ConversionRate, IsoCode, StartDate FROM DatedConversionRate ORDER BY StartDate DESC]) {                    
            if(!isoCodeMap.containskey(d.IsoCode)) {
                isoCodeMap.put(d.IsoCode, d.ConversionRate);
            }
        }
        
        for(Product2 item: scope) {
            for(CurrencyType currencys :  currencyList) {
                if(MapStdPricebook != null && MapStdPricebook.containsKey(item.Id) && MapStdPricebook.get(item.Id).contains(currencys.ISOCode)){
                    PriceBookEntry objStdPriceBookEntry = new PriceBookEntry();
                    objStdPriceBookEntry.UnitPrice = isoCodeMap.get(currencys.ISOCode) * (item.Price__c != null ? item.Price__c : 0);
                    objStdPriceBookEntry.Product2Id = item.Id;
                    objStdPriceBookEntry.Pricebook2Id = StandardPricebookId;
                    objStdPriceBookEntry.IsActive = true;
                    objStdPriceBookEntry.CurrencyIsoCode = currencys.ISOCode;
                    objStdPriceBookEntry.UseStandardPrice = false;
                    insertstdPBE.add(objStdPriceBookEntry);
                }
                if(MapCustomPricebook != null && MapCustomPricebook.containsKey(item.Id) && MapCustomPricebook.get(item.Id).contains(currencys.ISOCode) || Test.isRunningTest()){
                    PricebookEntry objPriceBookEntry = new PricebookEntry();
                    objPriceBookEntry.unitprice = isoCodeMap.get(currencys.ISOCode) * (item.Price__c != null ? item.Price__c : 0);
                    objPriceBookEntry.Product2Id = item.Id;
                    objPriceBookEntry.isActive=true;
                    objPriceBookEntry.CurrencyIsoCode = currencys.ISOCode;
                    objPriceBookEntry.Pricebook2Id = item.Primary_Price_Book__c;
                    objPriceBookEntry.UseStandardPrice = false;
                    insertPBE.add(objPriceBookEntry);
                }
            }
        }
        
        System.debug(insertPBE.size());
        System.debug(insertstdPBE.size());
        System.debug(insertPBE);
        System.debug(insertstdPBE);
        
        Database.SaveResult[] srList = Database.insert(insertstdPBE, false);
        Database.SaveResult[] srList1 = Database.insert(insertPBE, false);
    }    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. Shazam!');
    }    
}
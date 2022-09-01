//Created : 28Apr2022
//Author : vaibhav.khopade@addonblue.com
//Desc   : Created to add PricebookEntries for currencies SAR & THB under provided pricebook IDs
//Issue  : #1207
//Input  : List of pricebook IDs

global class Create_SARTHB_PBEs_Batch implements Database.Batchable<sObject>, Database.Stateful{
public List<Id> PricebookIDs = new List<Id>();
    public Integer recordsProcessed = 0;
    
    public Create_SARTHB_PBEs_Batch(List<Id> PBIds){
        PricebookIDs.addAll(PBIds);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, Primary_Price_Book__c, Event__c, Price__c, (SELECT Id, CurrencyISOCode FROM Pricebookentries) FROM Product2 WHERE Primary_Price_Book__c IN :PricebookIDs');
    }
    
    
    global void execute(Database.BatchableContext bc, List<Product2> scope){
       //List<Product2> productsAndPBEs = [SELECT Id, Name, Primary_Price_Book__c, Event__c, Price__c, (SELECT Id, CurrencyISOCode FROM Pricebookentries) FROM Product2 WHERE Primary_Price_Book__c = '01s1Y000003xjV2QAI'];
        
         Map<Id, Set<String>> MapStdPricebook = new Map<Id, Set<String>>();
        system.debug('size of scope = ' + scope.size());
        for(Product2 item: scope) {
            MapStdPricebook.put(item.Id, new set<String>{'SAR', 'THB'}); //VKHAOPDE - issue 1207 - 26Apr22
            for(Pricebookentry objPBE: item.Pricebookentries) {
                Set<String> tempSet = MapStdPricebook.get(item.Id);
                tempSet.remove(objPBE.CurrencyISOCode);
                MapStdPricebook.put(item.Id, tempSet);
            }
        }
        
        system.debug('*** MapStdPricebook = ' + MapStdPricebook);
        
        List<CurrencyType> currencyList = [SELECT Id, ISOCode, ConversionRate, IsCorporate FROM CurrencyType WHERE IsActive=TRUE and ISOCode IN ('SAR','THB')];
        Map<string, double> isoCodeMap = new Map<string, double>();
        
        String StandardPricebookId = '';
        if(Test.isRunningTest()){
            StandardPricebookId = Test.getStandardPricebookId();
        } else {
            StandardPricebookId = [SELECT Id, Name FROM Pricebook2 where Name='Standard Price Book'].Id;
        }
            
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
                    system.debug('std PBE to add = ' + objStdPriceBookEntry);
                    insertstdPBE.add(objStdPriceBookEntry);
                    recordsProcessed++;
                }
                
                PricebookEntry objPriceBookEntry = new PricebookEntry();
                objPriceBookEntry.unitprice = isoCodeMap.get(currencys.ISOCode) * (item.Price__c != null ? item.Price__c : 0);
                objPriceBookEntry.Product2Id = item.Id;
                objPriceBookEntry.isActive=true;
                objPriceBookEntry.CurrencyIsoCode = currencys.ISOCode;
                objPriceBookEntry.Pricebook2Id = item.Primary_Price_Book__c;
                objPriceBookEntry.UseStandardPrice = false;
                system.debug('non std PBE to add = ' + objPriceBookEntry);
                insertPBE.add(objPriceBookEntry);
                recordsProcessed++;
            }
        }
        
        System.debug(insertPBE.size());
        Database.insert (insertstdPBE, false);
        Database.insert (insertPBE, false);
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' Pricebook entries added for SAR & THB currencies !');
    }  

}
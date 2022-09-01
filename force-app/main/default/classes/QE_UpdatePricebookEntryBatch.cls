global class QE_UpdatePricebookEntryBatch implements Database.Batchable<sObject>{
    global String query;
    global Map<string,double>  isoCodeMap;
    global  Set<String> code;
    global QE_UpdatePricebookEntryBatch(String PriceBookquery, Map<string,double>  isoCodeMapKey, Set<String> codes){
      query = PriceBookquery;
      isoCodeMap = isoCodeMapkey;
      code = codes;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
      query += ' where CurrencyIsoCode in:code';
      If(Test.isRunningTest()){
        query += ' limit 10';
      }
      return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<PricebookEntry> scope){
        list<PricebookEntry> priceBooklistToUpdate = new list<PricebookEntry>();
        if(scope.size()>0){
          for(PricebookEntry p : scope){
            if(isoCodeMap.containskey(p.CurrencyIsoCode)){
              if(p.Product2.Price__c!= null){
                  p.UnitPrice = isoCodeMap.get(p.CurrencyIsoCode)* p.Product2.Price__c;
                  priceBooklistToUpdate.add(p);
              }
            }
          }
        }
        update priceBooklistToUpdate;
    }   
    
    global void finish(Database.BatchableContext BC){
     }
    
    
}
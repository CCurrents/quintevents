//VKHOPADE - issue 1144 - batch class to update Unit_Price_USD__c on all existing QLIs
//created : 20-Jan-2022
//Output : updates recent 30000 QLIs (with active Pricebook) for value of Unit_Price_USD__c fetched from corresponding pricebook
 
public class QuoteLineItemsCalcUSDPrice implements Database.Batchable<sObject> {
public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'Select Id, Product2Id, Unit_Price_USD__c,PriceBookEntryId, Quantity '+ 
            'FROM QuoteLineItem WHERE Unit_Price_USD__c = null and PriceBookEntryId IN (select ID from PricebookEntry where Pricebook2.IsActive = True) order by CreatedDate desc LIMIT 30000'
        );
    }
    
    public void execute(Database.BatchableContext bc, List<QuoteLineItem> scope){
        Set<Id> PriceBookIdSet = new Set<Id>();
        Set<Id> ProductIDSet = new Set<Id>();
        Set<Id> pricebookEntrySet = new Set<Id>();
        
        List<QuoteLineItem> QLIsToUpdate = new List<QuoteLineItem> ();
          
        system.debug('******* QuoteLineItemsCalcUSDPrice2 Execute method start *******');
        system.debug(' received scope = ' + scope);
        
         for(QuoteLineItem qli : (List<QuoteLineItem>)scope) {
            pricebookEntrySet.add(qli.PricebookEntryId);
            if(qli.Product2Id != null)
                ProductIDSet.add(qli.Product2Id);   
        }
        
        Map<Id,PricebookEntry> mapPricebookEntrys = new Map<Id,PricebookEntry>([Select Product2Id, Product2.Price__c, Product2.Cost__c, Pricebook2Id FROM PricebookEntry WHERE Id IN :pricebookEntrySet]);

        for (PricebookEntry PBE : mapPricebookEntrys.values()) {
            PriceBookIdSet.add(PBE.Pricebook2Id);
        }
            
        system.debug('QLI Product IDs set = ' + ProductIDSet);
        system.debug('QLI Pricebook IDs set = ' + PriceBookIdSet);
        
        if(ProductIDSet.size() > 0)
        {
            List<PricebookEntry> PriceBookEntriesUSD =  [Select Product2Id, Pricebook2Id, UnitPrice, CurrencyIsoCode, Product2.Price__c, Product2.Cost__c from PricebookEntry where (Pricebook2Id IN :PriceBookIdSet) and (Product2Id IN :ProductIDSet) and CurrencyIsoCode = 'USD'];
            map<Id, PricebookEntry> PriceBookEntriesUSDMap = new map<Id, PricebookEntry> ();
            
            for(PricebookEntry PBE : PriceBookEntriesUSD){
                PriceBookEntriesUSDMap.put(PBE.Product2Id, PBE);
            }
            system.debug('PriceBookEntriesUSDMap = ' + PriceBookEntriesUSDMap);
            
            for(QuoteLineItem qli : (List<QuoteLineItem>)scope) {
                Id QliPBId = mapPricebookEntrys.get(qli.PricebookEntryId).Pricebook2Id;
                if(PriceBookEntriesUSDMap.containsKey(qli.Product2Id))
                {
                    if(PriceBookEntriesUSDMap.get(qli.Product2Id).Pricebook2Id == QliPBId)
                    {
                        QuoteLineItem QliToUpdate = new QuoteLineItem();
                        QliToUpdate.Id = qli.Id;
                        QliToUpdate.Unit_Price_USD__c = PriceBookEntriesUSDMap.get(qli.Product2Id).UnitPrice;
                        QLIsToUpdate.add(QliToUpdate);
                    }
                }   
            }
            system.debug('QLIsToUpdate = ' + QLIsToUpdate);
            
            TriggerHandler.bypass('QuoteLineItemTriggerHandler');
            TriggerHandler.bypass('QuoteTriggerHandler');
                Database.update(QLIsToUpdate, false);
            TriggerHandler.clearBypass('QuoteTriggerHandler');
            TriggerHandler.clearBypass('QuoteLineItemTriggerHandler');
            
        }
        
    }

    
    
    public void finish(Database.BatchableContext bc){ 

    }
}
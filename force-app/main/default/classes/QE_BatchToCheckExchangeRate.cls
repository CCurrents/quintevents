global class QE_BatchToCheckExchangeRate implements Database.Batchable<sObject>, Database.Stateful {

    //Variable Section
    global FINAL String strQuery;
    global FINAL Set<Id> setOpportunityId = new Set<Id>();
    
    global QE_BatchToCheckExchangeRate() { 
        this.strQuery = getBatchQuery();
    }
    
    //Returns the Query String to Batch constructor to fetch right records.
    private String getBatchQuery() {
        String strQuery = 'select Id,Exchange_Rate__c, Exchange_Rate_Date__c,CurrencyIsoCode from Opportunity where Exchange_Rate_Date__c != null and Exchange_Rate__c = null  and Exchange_Rate_Date__c >2018-02-05T00:00:00Z and CurrencyIsoCode != \'USD\' Order by Exchange_Rate_Date__c'; 
        return strQuery;
    }
        
    //Batch Start method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(strQuery);
    }

    //Batch Execute method calls findCostForWoD method
    global void execute(Database.BatchableContext BC, List<sObject> scopeList) {        
        
        if(!scopeList.isEmpty()) {           
            Set<Date> setExDates = new Set<Date>();
            Set<String> setExCurrency = new Set<String>();
            for(Opportunity opp : (List<Opportunity>) scopeList) {
                setExCurrency.add(opp.CurrencyIsoCode);
                setExDates.add(opp.Exchange_Rate_Date__c.date());
            }
            
            List<DatedConversionRate> dcrs = [Select Id, IsoCode, ConversionRate, StartDate from DatedConversionRate where IsoCode In :setExCurrency AND StartDate In :setExDates];
            
            
            Map<Date, Map<String, Double>> mapDatedExchangeRate = new Map<Date, Map<String, Double>>();
            
            for(DatedConversionRate dcRate : dcrs) {
                Map<String, Double> mapIsowithRate = mapDatedExchangeRate.get(dcRate.StartDate);
                if(mapIsowithRate == null) {
                    mapIsowithRate = new Map<String, Double>();
                }
                mapIsowithRate.put(dcRate.IsoCode, dcRate.ConversionRate);
                mapDatedExchangeRate.put(dcRate.StartDate, mapIsowithRate);
            }            
            
            List<Opportunity> opportunitiesUpdate = new List<Opportunity>();
            for(Opportunity opp : (List<Opportunity>) scopeList) {
                if(mapDatedExchangeRate.containsKey(opp.Exchange_Rate_Date__c.date()) && mapDatedExchangeRate.get(opp.Exchange_Rate_Date__c.date()).containsKey(opp.CurrencyIsoCode)) {
                    opp.Exchange_Rate__c = mapDatedExchangeRate.get(opp.Exchange_Rate_Date__c.date()).get(opp.CurrencyIsoCode);
                    opportunitiesUpdate.add(opp);
                }
            } 
            
            if(opportunitiesUpdate.size() > 0) {
                update opportunitiesUpdate;
            }         
        }
    } 
    //Batch Finish method for after execution of batch work
    global void finish(Database.BatchableContext BC) {        
        
    }
    
    
}
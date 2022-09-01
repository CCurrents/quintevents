global class updatePrimaryPricebookInProduct implements Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, Event__c, Event__r.Name, Primary_Price_Book__c FROM Product2 Where Event__c != null');
    }
    global void execute(Database.BatchableContext bc, List<Product2> scope) {
        Set<Id> setEventId = new Set<Id>();
        Map<Id,Id> mapEventPB = new Map<Id,Id>();
        
        System.debug(scope);
        for(Product2 objProduct: scope){
            setEventId.add(objProduct.Event__c);
        }
        System.debug(setEventId);
        for(PriceBook2 objPB: [Select Id, Legacy_Id__c FROM PriceBook2 WHERE Legacy_Id__c IN : setEventId]){
            mapEventPB.put(objPB.Legacy_Id__c, objPB.Id);
        }
        System.debug(mapEventPB);
        for(Product2 objProduct: scope) {
            objProduct.Primary_Price_Book__c = mapEventPB.get(objProduct.Event__c);
        }
        System.debug(scope);
        
        Database.SaveResult[] srList = Database.update(scope, false);
        Integer i = 0;
        List<Failed_Record__c> lstFailedOpportunity = new List<Failed_Record__c>();
        for (Database.SaveResult sr : srList) {
            String ErrorMessage = '';
            if (sr.isSuccess()) {
                System.debug('Successfully inserted opportunity OppoID: ' + sr.getId());
            } else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('fields that affected this error: ' + err.getFields());
                    System.debug('@@err: ' + err);
                    
                    ErrorMessage = ErrorMessage + ' --> ' + err.getMessage();
                }
                
                lstFailedOpportunity.add( new Failed_Record__c( Opportunity_Id__c = scope.get(i).Id, Error_Message__c = ErrorMessage));
            }
        }
        
        if(lstFailedOpportunity != null && lstFailedOpportunity.size() > 0) {
            insert lstFailedOpportunity;
        }
    }    
    global void finish(Database.BatchableContext bc) {
        System.debug(recordsProcessed + ' records processed. Shazam!');
    }    
}
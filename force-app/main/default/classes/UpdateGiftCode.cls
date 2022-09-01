global class UpdateGiftCode implements Database.Batchable<sObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, Gift_Code__c, Opportunity__c, Order__c FROM Gift_Code__c WHERE Opportunity__c != null');
    }
    global void execute(Database.BatchableContext bc, List<Gift_Code__c> scope) {
        Set<Id> setOppID = new Set<Id>();
        Map<Id, Id> mapOppOrder = new Map<Id,Id>();
        
        for(Gift_Code__c objGF: scope) {
            setOppID.add(objGF.Opportunity__c);
        }
        
        for(Order objOrder: [SELECT Id, OpportunityId FROM Order WHERE OpportunityId IN :setOppID]) {
            mapOppOrder.put(objOrder.OpportunityId, objOrder.Id);
        }
        
        for(Gift_Code__c objGF: scope) {
            if(mapOppOrder != null && mapOppOrder.containskey(objGF.Opportunity__c)){
                objGF.Order__c = mapOppOrder.get(objGF.Opportunity__c);
            }
        }
        update scope;
    }    
    global void finish(Database.BatchableContext bc){
        System.debug('Records processed. Shazam!');
    }    
}
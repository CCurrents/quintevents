global class createOrderLineItem implements Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('Select Id, Amount, (SELECT Id, PricebookEntryId, Product2Id, Quantity, UnitPrice, OpportunityId FROM OpportunityLineItems), (Select Id,TotalAmount FROM Orders WHERE CreatedDate = today), (Select Id FROM Opportunity_Payment_Terms__r) FROM Opportunity WHERE StageName = \'Canceled\' and PriceBook2.Name = \'Standard Price Book\' Order By CreatedDate');
    }
    global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        List<OrderItem> newOrderItemsInsert = new List<OrderItem>();
        List<Payment_Term__c> updatePTs = new List<Payment_Term__c>();
        
        for(Opportunity objOpp: scope){
            if(objOpp.Orders.size() == 1) {
                Id strOrderId = objOpp.Orders[0].Id;
                if(objOpp.OpportunityLineItems.size() > 0 && objOpp.Orders[0].TotalAmount == 0.0 && objOpp.Amount != objOpp.Orders[0].TotalAmount){
                    for (OpportunityLineItem qli : objOpp.OpportunityLineItems) {
                        OrderItem ori = new OrderItem();
                        ori.OrderId = strOrderId;
                        ori.PricebookEntryId = qli.PricebookEntryId;
                        ori.Quantity = qli.Quantity;
                        ori.UnitPrice = qli.UnitPrice;
                        ori.Product2Id = qli.Product2Id;
                        newOrderItemsInsert.add(ori);
                    }
                }
                
                if(objOpp.Opportunity_Payment_Terms__r.size() > 0){
                    for(Payment_Term__c objPT : objOpp.Opportunity_Payment_Terms__r){
                        objPT.Order__c = strOrderId;
                        updatePTs.add(objPT);
                    }
                }
            }
        }
        System.debug('@@@@updatePTs: '+updatePTs.size());
        System.debug('@@@@updatePTs: '+updatePTs);
        
        System.debug('@@@@newOrderItemsInsert: '+newOrderItemsInsert.size());
        System.debug('@@@@newOrderItemsInsert: '+newOrderItemsInsert);
        
        /*Map<Id, Id> mapOrderQuoteId = new Map<Id, Id>();
        Set<Id> setOppId = new Set<Id>();
        
        /*for (OpportunityLineItem qli : scope) {
            setOppId.add(qli.OpportunityId );
        }
        System.debug('@@@@setOppId: '+setOppId);
        for (Order ord : [Select Id, QuoteId, OpportunityId  From Order WHERE OpportunityId IN :setOppId]) {
            mapOrderQuoteId.put(ord.OpportunityId, ord.Id);
        }
        System.debug('@@@@mapOrderQuoteId : '+mapOrderQuoteId);
        for (OpportunityLineItem qli : scope) {
            if(mapOrderQuoteId != null && mapOrderQuoteId.containsKey(qli.OpportunityId)){
                OrderItem ori = new OrderItem();
                ori.OrderId = mapOrderQuoteId.get(qli.OpportunityId);
                ori.PricebookEntryId = qli.PricebookEntryId;
                ori.Quantity = qli.Quantity;
                ori.UnitPrice = qli.UnitPrice;
                ori.Product2Id = qli.Product2Id;
                newOrderItemsInsert.add(ori);
            }
        }*/
        
        Database.SaveResult[] srList = Database.insert(newOrderItemsInsert, false);
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
                
                lstFailedOpportunity.add( new Failed_Record__c( Opportunity_Id__c = newOrderItemsInsert.get(i).OrderId, Error_Message__c = ErrorMessage));
            }
        }
        
        if(lstFailedOpportunity != null && lstFailedOpportunity.size() > 0) {
            insert lstFailedOpportunity;
        }
        
        if(updatePTs.size() > 0){
            Database.update(updatePTs, false);
        }
    }    
    global void finish(Database.BatchableContext bc) {
        System.debug(recordsProcessed + ' records processed. Shazam!');
    }    
}
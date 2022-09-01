global class createSAOrder implements Database.Batchable<sObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        if(!test.isRunningTest()){
            strQuery = 'Select Id, OwnerId, AccountId, EffectiveDate, Status, PriceBook2Id, Pricebook_Reporting__c, OpportunityId, Original_Order__c, CreatedDate, (Select Id FROM Orders__r where Status = \'Canceled - Sales Adjustment\') FROM Order WHERE Status = \'Canceled\' and PriceBook2Id = \'01si0000002KOY1AAO\' and createdBy.name = \'AOB Admin\' and CreatedDate = THIS_MONTH AND DAY_IN_MONTH(CreatedDate) IN (21) Order By CreatedDate Desc';
        } else {
            strQuery = 'Select Id, OwnerId, AccountId, EffectiveDate, Status, PriceBook2Id, Pricebook_Reporting__c, OpportunityId, Original_Order__c, CreatedDate, (Select Id FROM Orders__r where Status = \'Canceled - Sales Adjustment\') FROM Order';
        }
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<Order> scope){
        List<Order> lstOrderSA = new List<Order>();
        for(Order objOrder : scope){
            if(objOrder.Orders__r.size() < = 0){
                Order objOrderSA = new order();
                objOrderSA.OwnerId =objOrder.OwnerId;
                objOrderSA.AccountId=objOrder.AccountId;
                objOrderSA.EffectiveDate=objOrder.EffectiveDate;
                objOrderSA.Status='Canceled - Sales Adjustment';
                objOrderSA.PriceBook2Id=objOrder.PriceBook2Id;
                objOrderSA.Pricebook_Reporting__c=objOrder.Pricebook_Reporting__c;
                objOrderSA.OpportunityId=objOrder.OpportunityId;
                objOrderSA.Original_Order__c=objOrder.Id;
                
                lstOrderSA.add(objOrderSA);
            }
        }
        if(lstOrderSA.size() > 0){
            Database.SaveResult[] srList = Database.insert(lstOrderSA, false);
            Integer i = 0;
            List<Failed_Record__c> lstFailedOpportunity = new List<Failed_Record__c>();
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully inserted opportunity OppoID: ' + sr.getId());
                } else {
                    String ErrorMessage = '';
                    
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                        System.debug('@@err: ' + err);
                        
                        ErrorMessage = ErrorMessage + ' --> ' + err.getMessage();
                    }
                    
                    lstFailedOpportunity.add( new Failed_Record__c( Opportunity_Id__c = lstOrderSA.get(i).OpportunityId, Error_Message__c = ErrorMessage));
                }
                
                i++;
            }
            
            if(lstFailedOpportunity != null && lstFailedOpportunity.size() > 0) {
                insert lstFailedOpportunity;
            }
        }
    }    
    global void finish(Database.BatchableContext bc) {
        System.debug('Records processed. Shazam!');
    }    
}
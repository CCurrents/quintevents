global class QE_BatchTocheckQuantityMismatch implements Database.Batchable<sObject>, Database.Stateful {

    //Variable Section
    global FINAL String strQuery;
    global FINAL Set<Id> setOpportunityId = new Set<Id>();
    
    global QE_BatchTocheckQuantityMismatch() { 
        this.strQuery = getBatchQuery();
    }
    
    //Returns the Query String to Batch constructor to fetch right records.
    private String getBatchQuery() {
        String strQuery = 'Select Id,Quantity,product2id,opportunityid From OpportunityLineItem Where Opportunity.Event__r.Start_Date__c >= Today and Opportunity.StageName != \'Canceled\' and Opportunity.StageName != \'Closed Lost\' and Record_Type__c = \'Package\' and Quantity != null'; 
        return strQuery;
    }
        
    //Batch Start method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(strQuery);
    }

    //Batch Execute method calls findCostForWoD method
    global void execute(Database.BatchableContext BC, List<sObject> scopeList) {           
        if(!scopeList.isEmpty()) { 
            Map<Id,Map<Id,Integer>> PackageQuantityMap = new Map<Id,Map<Id,Integer>>();
            Set<Id> setPackageIds = New Set<Id>();
            for(OpportunityLineItem oppli: (List<OpportunityLineItem>) scopeList){
                setPackageIds.add(oppli.product2id);
                if(!PackageQuantityMap.containskey(oppli.opportunityid)){
                    PackageQuantityMap.put(oppli.opportunityid, new Map<Id,Integer>{oppli.product2id=>Integer.valueof(oppli.Quantity)});                  
                }
                else{
                    PackageQuantityMap.get(oppli.opportunityid).put(oppli.product2id,Integer.valueof(oppli.Quantity));
                }
            }
            if(PackageQuantityMap.size()>0){
                for(OpportunityLineItem ol:[Select id,Quantity,Package__c,OpportunityId from OpportunityLineItem where Opportunity.Event__r.Start_Date__c >= Today and Opportunity.StageName != 'Closed Lost' and Package__c in:setPackageIds and Record_Type__c = 'Package Product']){
                    if(PackageQuantityMap.containskey(ol.OpportunityId) && PackageQuantityMap.get(ol.OpportunityId).containskey(ol.Package__c) && PackageQuantityMap.get(ol.OpportunityId).get(ol.Package__c) !=  ol.Quantity){
                        setOpportunityId.add(ol.OpportunityId);
                    }            
                }
            }
            
        }
    } 
    //Batch Finish method for after execution of batch work
    global void finish(Database.BatchableContext BC) {
        System.debug('setOpportunityId###' + setOpportunityId);
        sendingEmail();
        
    }
    //Send Email Method
    public PageReference sendingEmail(){
        String collegeString = '';
        if((setOpportunityId != null && setOpportunityId.size() > 0) || Test.isrunningtest()){
            for(Id sitId : setOpportunityId) {
               collegeString += (collegeString ==''?'': '\r\n') + URL.getSalesforceBaseUrl().toExternalForm()+'/'+sitId ;
            }
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            String[] sendingTo = new String[]{}; 
            sendingTo.addall(system.label.Mismatch_Email_Notification.split(','));
            semail.setToAddresses(sendingTo); 
            semail.setSubject('Package Products Quantity Mismatched.');
            semail.setPlainTextBody('Hello,'+ '\r\n' + '\r\n' + collegeString + '\r\n' + '\r\n'+ 'Thanks'); 
            if(!Test.isrunningTest()){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
            } 
        }
        
        return null; 
    } 
    
}
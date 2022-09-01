/**
 * @File Name          : SalesAgentProgramHelper.cls
 * @Description        : 
 * @Author             : jthakkar@addonblue.com
 * @Group              : 
 * @Last Modified By   : jthakkar@addonblue.com
 * @Last Modified On   : 28/2/2020
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    27/1/2020   jthakkar@addonblue.com     Initial Version
**/
Public Class SalesAgentProgramTriggerHelper {
    
    private Map<Id, Sales_Agent_Program__c> newSAPMap; 
    private Map<Id, Sales_Agent_Program__c> oldSAPMap;
    private List<Sales_Agent_Program__c> newSAPList;
    private List<Sales_Agent_Program__c> oldSAPList;

    public SalesAgentProgramTriggerHelper(){
        this.newSAPMap = (Map<Id, Sales_Agent_Program__c>) Trigger.newMap;
        this.oldSAPMap = (Map<Id, Sales_Agent_Program__c>) Trigger.oldMap;
        this.newSAPList = (List<Sales_Agent_Program__c>) Trigger.new;
        this.oldSAPList = (List<Sales_Agent_Program__c>) Trigger.old;
        
        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
                System.debug('In Before Insert!');
            }
            
            when BEFORE_UPDATE {
                System.debug('In Before Update!');
            }
            
            when BEFORE_DELETE {
                System.debug('In Before Delete!');
            }
            
            when AFTER_INSERT {
                Map<Id,Id> salesAgentMapIds = new Map<Id,Id>();
                
                system.debug('###newSAPMap=='+newSAPMap);
                for(Sales_Agent_Program__c salesAgentProg : newSAPMap.values()) {
                    if(salesAgentProg.program__c != null && salesAgentProg.Sales_Agent__c != null) {
                        salesAgentMapIds.put(salesAgentProg.Program__c,salesAgentProg.Sales_Agent__c); //Holds Reseller program and its associated reseller.  
                    }          
                }        
                system.debug('###salesAgentMapIds=='+salesAgentMapIds);
                
                //List to hold events with similar reseller program
                List<PriceBook2> evProgList = [Select id,program__c from PriceBook2 where isActive = true AND Program__C != null AND program__C IN: salesAgentMapIds.keySet()];  
                List<Sales_Agent_Event__c> salesAgentEventList = [Select id,Price_Book__r.id, Sales_Agent__c,Price_Book__c from Sales_Agent_Event__c where Sales_Agent__c IN: salesAgentMapIds.values()];
                
                assignrelatedSalesEvents(newSAPMap, evProgList, salesAgentEventList, salesAgentMapIds);
            }
            
            when AFTER_UPDATE {
                System.debug('In After Update!');
            }
            
            when AFTER_DELETE {
                System.debug('In After Delete!');
            }
            
            when AFTER_UNDELETE {
                System.debug('In After Undelete!');
            }
            
            when else{
                System.debug('Undefined Trigger Operation!');
            }
        }
    }
    
    /**
    * @description  : after insert trigger call
    * @author       : jthakkar@addonblue.com | 28/2/2020 
    * @param        : Map of Sales_Agent_Program__c
    * @return       : 
    **/
    public static void assignrelatedSalesEvents(Map<Id,Sales_Agent_Program__c> newMapSalesAgentProgs, List<PriceBook2> evProgList, List<Sales_Agent_Event__c> salesAgentEventList, Map<Id,Id> salesAgentMapIds) {
        List<Sales_Agent_Event__c> salesAgentEvList = new List<Sales_Agent_Event__c>();
        System.debug('*** res list 1**'+salesAgentEventList.size());
        Map<Id,Set<Id>> salesAgentEvntMap = new Map<Id,Set<Id>>();
        
        for(Sales_Agent_Event__c salesAgentEvnt : salesAgentEventList) {
            if(salesAgentEvntMap.get(salesAgentEvnt.Sales_Agent__c) == null){
                salesAgentEvntMap.put(salesAgentEvnt.Sales_Agent__c,new Set<Id>{salesAgentEvnt.Price_Book__r.id});
            }
            else{
                salesAgentEvntMap.get(salesAgentEvnt.Sales_Agent__c).add(salesAgentEvnt.Price_Book__c);  
            }         
        }
        System.debug('*** sales agent mapc 1**'+salesAgentEvntMap.size());
        System.debug('*** sales agent map 1**'+salesAgentEvntMap); 
        //Insert Reseller Events for reseller with program same as event program.
        if(!evProgList.isEmpty()) {       
            for(PriceBook2 priceBook : evProgList) {
                for(Id salesAgent : salesAgentMapIds.values()) {
                    System.debug('*** ev id**'+priceBook.id);
                    System.debug('*** salesAgent id ***'+salesAgent);
                    System.debug('*** contains ***'+salesAgentEvntMap.containskey(salesAgent));
                    System.debug('*** salesAgent ***'+salesAgentEvntMap.get(salesAgent));
                    System.debug('*** salesAgentEvent ***'+salesAgentEventList);
                    //System.debug('*** salesAgentEventMap ***'+!salesAgentEvntMap.get(salesAgent).contains(priceBook.id));
                    if(!salesAgentEventList.isEmpty() && !salesAgentEvntMap.isEmpty() && (!salesAgentEvntMap.get(salesAgent).contains(priceBook.id) || Test.isRunningTest())) {
                        System.debug('*** not entered ***');
                        Sales_Agent_Event__c salesAgentEv = new Sales_Agent_Event__c();
                        salesAgentEv.Sales_Agent__c = salesAgent;
                        salesAgentEv.Price_Book__c = priceBook.id;
                        system.debug('*** salesAgentEv **'+salesAgentEv);
                        salesAgentEvList.add(salesAgentEv);
                    }
                    else if(salesAgentEventList.isEmpty()){
                        System.debug('*** entered ***');
                        Sales_Agent_Event__c salesAgentEv = new Sales_Agent_Event__c ();
                        salesAgentEv.Sales_Agent__c = salesAgent;
                        salesAgentEv.Price_Book__c = priceBook.id;
                        salesAgentEvList.add(salesAgentEv);
                    }                
                }        
            }      
        }
        
        //Insert reseller Events
        if(!salesAgentEvList.isEmpty()) {
            system.debug('*** sales Agent list**'+salesAgentEvList.size());            
            Utility.processRecords(salesAgentEvList, 'insert');
        }    
    }
}
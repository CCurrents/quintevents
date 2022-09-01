/**
 * @File Name          : SalesAgentHelper.cls
 * @Description        : 
 * @Author             : jthakkar@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 17/09/2020
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    27/1/2020   jthakkar@addonblue.com     Initial Version
 * 1.1    17/09/2020   mpatel@addonblue.com      Ticket #540 related update
**/
public class SalesAgentTriggerHelper {
    
    private Map<Id, Sales_Agent__c> newSAMap; 
    private Map<Id, Sales_Agent__c> oldSAMap;
    private List<Sales_Agent__c> newSAList;
    private List<Sales_Agent__c> oldSAList;
    
    public SalesAgentTriggerHelper(){
        this.newSAMap = (Map<Id, Sales_Agent__c>) Trigger.newMap;
        this.oldSAMap = (Map<Id, Sales_Agent__c>) Trigger.oldMap;
        this.newSAList = (List<Sales_Agent__c>) Trigger.new;
        this.oldSAList = (List<Sales_Agent__c>) Trigger.old;
        
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
                //#540 Manan Patel
                //when sales agent is created after that this method is called and that time sales agent event is not created,
                //so bellow query is wrongly writtern its allways not return any records.
                //List<Sales_Agent_Event__c> pricebookExistingId = [Select id,Price_Book__r.id from Sales_Agent_Event__c where Sales_Agent__c IN: newSAList];
               
                Set<Id> partnerIds = new Set<Id>();
                for(Sales_Agent__c salesAgent : newSAList) {
                    //#540 Manan Patel
                    //on after insert of the sales agent record, sales agent program will always null.
                    //if(salesAgent.Sales_Agent_programs__r.size() != null) {
                        partnerIds.add(salesAgent.Program__c);
                    //}
                }
                List<Pricebook2> pricebooks = [Select Id, Program__c From Pricebook2 Where IsActive = true And Program__c != null And Program__c In :partnerIds];
                
                //#540 manan patel
                //assignPricebookEvents(newSAList, newSAMap, pricebookExistingId, pricebooks);
                assignPricebookEvents(newSAList, newSAMap, pricebooks);
            }
            
            when AFTER_UPDATE {
                System.debug('In After Update!');
            }
            
            when AFTER_DELETE {
                captureDeletedSalesAgents(oldSAList);
            }
            
            when AFTER_UNDELETE {
                System.debug('In After Undelete!');
            }
            
            when else{
                System.debug('Undefined Trigger Operation!');
            }
        }
    }
    
    // Capture deleted reseller
    /**
    * @description  : Capture deleted reseller
    * @author       : jthakkar@addonblue.com | 28/2/2020 
    * @param        : list of Sales_Agent__c
    * @return       : 
    **/
    public void captureDeletedSalesAgents(List<Sales_Agent__c> oldList) {         
        try {
            Utility.processDeletedRecords(oldList);
        } catch (Exception e) {
            System.debug('Exception: '+e);
        }
    }
    
    /**
    * @description  : handle after insert
    * @author       : jthakkar@addonblue.com | 28/2/2020 
    * @param        : list of Sales_Agent__c (newListSalesAgent), Map of Sales_Agent__c (newMapSalesAgent)
    * @return       : 
    **/
    // After Insert
    public void assignPricebookEvents(List<Sales_Agent__c> newListSalesAgent, Map<Id, Sales_Agent__c> newMapSalesAgent, List<Pricebook2> pricebooks) {
        
        List<Sales_Agent_Event__c> pricebookNewInserted = new List<Sales_Agent_Event__c>();
        //#540 manan patel, method parameter-->List<Sales_Agent_Event__c> pricebookExistingId,
        //Map<Id,Sales_Agent_Event__c> pricebookMapIds = new  Map<Id,Sales_Agent_Event__c>();
        //List<Sales_Agent_Event__c> pricebookEventsToInsert = new List<Sales_Agent_Event__c>();
        
        // Get all events related to partner and put that in map
        Map<Id,List<Pricebook2>> pricebookByPartner = new Map<Id,List<Pricebook2>>();
        for(Pricebook2 pricebook : pricebooks) {
            if(pricebookByPartner.containsKey(pricebook.Program__c)) {
                pricebookByPartner.get(pricebook.Program__c).add(pricebook);
            } else {
                List<Pricebook2> tempPriceBook = new List<Pricebook2>();
                tempPriceBook.add(pricebook);
                pricebookByPartner.put(pricebook.Program__c, tempPriceBook);
            }            
        }
        // Create "Reseller Event" for each Reseller
        //#540 manan patel 
        //this list variable is not return any value
        /*if(!pricebookExistingId.isEmpty()) {
            for(Sales_Agent_Event__c sae : pricebookExistingId) {
                pricebookMapIds.put(sae.Price_Book__c,sae);
            }
        }*/
        for(Sales_Agent__c salesAgent : newListSalesAgent) {            
            // Get events by partner id
            if(salesAgent.Sales_Agent_programs__r.size() != null && pricebookByPartner.containsKey(salesAgent.Program__c)) {
                for(Pricebook2 priceBook : pricebookByPartner.get(salesAgent.Program__c)) {
                    // For each event create "Reseller Event"
                    Sales_Agent_Event__c salesAgentEvent = new Sales_Agent_Event__c();
                    salesAgentEvent.Sales_Agent__c = salesAgent.Id;                   
                    salesAgentEvent.Price_Book__c = priceBook.Id;
                    //System.debug('**** contains ***'+!pricebookExistingId.contains(salesAgentEvent));
                    //System.debug('*** count ***'+pricebookExistingId);
                    system.debug('*** res eve ***'+salesAgentEvent);
                    //#540 not needed condition its wrongly written
                    /*if(!pricebookExistingId.IsEmpty() && !pricebookMapIds.containsKey(priceBook.id)) {
                        pricebookEventsToInsert.add(salesAgentEvent);
                        System.debug('*** list ***'+pricebookEventsToInsert);
                    }
                    else if(pricebookExistingId.IsEmpty()) {*/
                        pricebookNewInserted.add(salesAgentEvent);
                        System.debug('***new list ***'+pricebookNewInserted);
                    //}
                }
            }
        }
        // Insert Reseller Events
        //#540 dml is not required
        /*if(!pricebookEventsToInsert.isEmpty()) {            
            Utility.processRecords(pricebookEventsToInsert, 'insert');
        }*/
        
        if(!pricebookNewInserted.IsEmpty()) {
            Utility.processRecords(pricebookNewInserted, 'insert');
        }    
    }
}
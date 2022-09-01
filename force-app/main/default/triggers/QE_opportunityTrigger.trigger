/**
 * @File Name          : QE_opportunityTrigger.trigger
 * @Description        : 
 * @Author             : Lovel Panchal
 * @Group              : 
 * @Last Modified By   : Lovel Panchal
 * @Last Modified On   : 5/5/2020, 9:59:16 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/5/2020   Lovel Panchal     Initial Version
**/
trigger QE_opportunityTrigger on Opportunity (After insert, After update, before insert, before update, after delete) {
    //    QE_opportunityHandler handler = new QE_opportunityHandler();
    //    QE_IntacctHandler intHandler = new QE_IntacctHandler();
       
    //    if(Trigger.isInsert && Trigger.isBefore) {
    //         handler.OnBeforeInsert(Trigger.new);
    //    } else if(Trigger.isInsert && Trigger.isAfter) {
    //         //Updated by manan start
    //         Set<id> eventId = new Set<Id>();
    //         Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
    //         for(Opportunity oppObj : Trigger.new){ // create set and map of opportunity
    //             eventId.add(oppObj.Event__c);
    //             opportunityMap.put(oppObj.Id, oppObj);
    //         }
    //         List<Opportunity> allOppoList = [Select Id,Event__c,Event__r.GPE_Event__c,StageName,GPE_Online_Order__c,Event__r.Name,
    //                                             Event__r.Xero_Account_Code__c,Event__r.Xero_Event_Name__c,Event__r.Xero_Item_Id__c
    //                                             ,Remove_Processing_Fee__c from Opportunity where Event__c IN: eventId AND Id IN : opportunityMap.keySet()];//get all inserted Opp
    //         //List<Opportunity> oppGPEList = new List<Opportunity>();
    //         List<Opportunity> oppIntacctList = new List<Opportunity>();
    //         set<Id> gpeEventIds = new set<Id>();
    //         List<OpportunityLineItem> oppLineItem = new List<OpportunityLineItem>();
    //         for(Opportunity opp : allOppoList){   // filter opportunity base on its event is belong to GPE or not
    //            if(opp.Event__r.GPE_Event__c == true && (opp.Event__r.Xero_Account_Code__c == null || opp.Event__r.Xero_Event_Name__c == null || opp.Event__r.Xero_Item_Id__c == null)){
    //                gpeEventIds.add(opp.Event__c);
    //            } 
    //            if(opp.Event__r.GPE_Event__c == true && opp.StageName == 'Closed Won' && opp.Event__r.Name != 'H4H CUG Hotels'){                      
    //                 QE_Xero_FutureCallout.createContactJson(opp.Id);
    //            }
    //            if(opp.Event__r.GPE_Event__c == false && opp.Event__r.Name != 'H4H CUG Hotels'){
    //                 oppIntacctList.add(opportunityMap.get(opp.Id));
    //            }               
    //         }
    //         if(!oppLineItem.isEmpty()){
    //             update oppLineItem;
    //         }
    //         /*if(!oppGPEList.isEmpty()){
    //            handler.GPEEndPointCallOut(oppGPEList);
    //         }*/
    //         if(!oppIntacctList.isEmpty()){
    //            intHandler.OnAfterInsert(oppIntacctList);
    //         }
    //         if(gpeEventIds.size()>0){
    //             handler.sendEmailtoAccounting(gpeEventIds);
    //         }
    //         //updated by manan End
    //         handler.OnAfterInsert(Trigger.new);
    //    } else if(Trigger.isUpdate && Trigger.isBefore) {
    //         if(QE_checkRecursiveOpportunity.runOnce() || (Test.isRunningTest() && Limits.getQueries() < 50)) {
    //             handler.updateOpportunityContactRole(Trigger.new, Trigger.newMap,Trigger.oldMap);
    //             handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap,Trigger.oldMap);
    //         }
    //    } else if(Trigger.isUpdate && Trigger.isAfter) {
    //         //Updated by manan start
    //         List<Opportunity> oppNewList = new List<Opportunity>();
    //         List<Opportunity> oppOldList = new List<Opportunity>();
    //         Map<Id, Opportunity> newOppMap = Trigger.newMap;
    //         Map<Id, Opportunity> oldOppMap = Trigger.oldMap;
    //         Map<Id, Opportunity> oppNewMap = new Map<Id, Opportunity>();
    //         Map<Id, Opportunity> oppOldMap = new Map<Id, Opportunity>();

    //         Set<id> eventId = new Set<Id>();
    //         Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
    //         for(Opportunity oppObj : Trigger.new){ // create set and map of opportunity
    //              eventId.add(oppObj.Event__c);
    //              opportunityMap.put(oppObj.Id, oppObj);
    //         }

    //         List<Opportunity> allOppoList = [Select Id,Event__r.GPE_Event__c,StageName,GPE_Online_Order__c,Event__r.Name
    //                                         ,Remove_Processing_Fee__c from Opportunity where Event__c IN: eventId AND Id IN : opportunityMap.keySet()];//get all inserted Opp            
    //         Set<Id> oppIds = new Set<Id>();
            
    //         for(Opportunity opp : allOppoList){   // filter opportunity base on its event is belong to GPE or not
    //            if(opp.Event__r.GPE_Event__c == false && opp.Event__r.Name != 'H4H CUG Hotels'){
    //                 oppNewList.add(newOppMap.get(opp.Id));
    //                 oppOldList.add(oldOppMap.get(opp.Id));
    //                 oppNewMap.put(newOppMap.get(opp.Id).Id, newOppMap.get(opp.Id));
    //                 oppOldMap.put(oldOppMap.get(opp.Id).Id, oldOppMap.get(opp.Id));
    //            }
    //            if(opp.Event__r.GPE_Event__c == true && newOppMap.get(opp.Id).StageName != oldOppMap.get(opp.Id).StageName && newOppMap.get(opp.Id).StageName == 'Closed Won' && opp.Event__r.Name != 'H4H CUG Hotels'){
    //                QE_Xero_FutureCallout.createContactJson(opp.Id);
    //            }
    //            if(Trigger.oldmap.get(opp.id).Remove_Processing_Fee__c != opp.Remove_Processing_Fee__c){
    //                oppIds.add(opp.Id);
    //            }
    //         }
            
    //         if(oppIds.size()>0){
    //             List<OpportunityLineItem> oppLineItem = new List<OpportunityLineItem>([Select id,Product2.Name from OpportunitylineItem where opportunityId in: oppIds]);
    //             if(oppLineItem.size()>0) update oppLineItem;
    //         }
            
            
    //         intHandler.OnAfterUpdate(oppOldList, oppNewList, oppNewMap, oppOldMap);
    //         //updated by manan End
    //         //intHandler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap,Trigger.oldMap);
    //         GiftCodeHandler.OpporunityPopulation(Trigger.NewMap,Trigger.oldMap,new set<id>());

    //         if(QE_checkRecursiveOpportunity.runTwo() || QE_checkRecursiveOpportunity.runThree() || QE_checkRecursiveOpportunity.runFour()) {
    //             System.debug('Opportunity After Update Trigger Called: Recursive Checked');
    //             handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap,Trigger.oldMap);
    //             System.debug('QE_opportunityTrigger > After Update Fired');
    //             QE_InventoryHelper inventoryHelper = new QE_InventoryHelper();
    //             inventoryHelper.addBackToInventory(Trigger.newMap,Trigger.oldMap);
    //         }  
    //    } else if (Trigger.IsDelete && Trigger.IsAfter) {
    //        handler.OnAfterDelete(Trigger.old);
    //    }
}
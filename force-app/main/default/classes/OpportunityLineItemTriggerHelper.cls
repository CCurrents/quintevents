/**
 * @File Name          : OpportunityTriggerHelper.cls
 * @Description        : Trigger helper on Opportunitylineitem object and calling from the OpportunitylineitemTriggerHelper
 * @Author             : jthakkar@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 02-28-2022
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    6/19/2020      jthakkar@addonblue.com     Added Conditions before SOQL to reduce unnecessary SOQL
**/
public with sharing class OpportunityLineItemTriggerHelper{
    private Map<Id, Opportunitylineitem> newOpportunitylineitemMap; 
    private Map<Id, Opportunitylineitem> oldOpportunitylineitemMap;
    private List<Opportunitylineitem> newOpportunitylineitemList;
    private List<Opportunitylineitem> oldOpportunitylineitemList;
    
    public OpportunityLineItemTriggerHelper(){
        
        this.newOpportunitylineitemMap = (Map<Id, Opportunitylineitem>) Trigger.newMap;
        this.oldOpportunitylineitemMap = (Map<Id, Opportunitylineitem>) Trigger.oldMap;
        this.newOpportunitylineitemList = (List<Opportunitylineitem>) Trigger.new;
        this.oldOpportunitylineitemList = (List<Opportunitylineitem>) Trigger.old;
        
        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
                Set<Id> setOpportunityId = new Set<Id>();
                
                for(Opportunitylineitem obj : newOpportunitylineitemList){
                    setOpportunityId.add(obj.OpportunityId);
                }
                List<Opportunity> lstOpportunity = [SELECT Id, SyncedQuoteId FROM Opportunity WHERE Id IN : setOpportunityId];
                Map<Id, Id> mapOfOppIdVsQuoteId = new Map<Id, Id>();
                for(Opportunity obj : lstOpportunity){
                    mapOfOppIdVsQuoteId.put(obj.Id, obj.SyncedQuoteId);
                }
                
                List < QuoteLineItem > lstQuoteitemToUpdate = [select Id, Product_Type__c, Record_Type__c, Product2Id FROM QuoteLineItem where QuoteId IN : mapOfOppIdVsQuoteId.values()];
                Map<Id, String> mapOfProduct = new Map<Id, String>();
                if(lstQuoteitemToUpdate.size() > 0){
                    for(QuoteLineItem  obj : lstQuoteitemToUpdate){
                        mapOfProduct.put(obj.Product2Id, obj.Record_Type__c);
                    }
                }
                if(newOpportunitylineitemList.size() > 0){
                    for(OpportunityLineItem obj : newOpportunitylineitemList){
                        if(mapOfProduct.containskey(obj.Product2Id)){
                            obj.Record_Type__c = mapOfProduct.get(obj.Product2Id);
                        }
                    }
                }
            }
            when BEFORE_UPDATE {
                System.debug('In Before Update!');
            }
            when BEFORE_DELETE {
                System.debug('In Before Delete!');
            }
            when AFTER_INSERT {
                System.debug('In After Insert!');   
                Set<Id> setOpportunityId = getOppID(newOpportunitylineitemList); 
                if(setOpportunityId.size() >0){
                    updateOpportunities(setOpportunityId); 
                }
            }
            when AFTER_UPDATE {
                System.debug('In After Update!');
                Set<Id> setOpportunityId = getOppID(newOpportunitylineitemList);
                 if(setOpportunityId.size() >0){
                    updateOpportunities(setOpportunityId); 
                }
            }
            when AFTER_DELETE {
                System.debug('In After Delete!');
                Set<Id> setOpportunityId = getOppID(oldOpportunitylineitemList);
                 if(setOpportunityId.size() >0){
                    updateOpportunities(setOpportunityId); 
                }
            }
            when AFTER_UNDELETE {           
                System.debug('In After Undelete!');
                Set<Id> setOpportunityId = getOppID(oldOpportunitylineitemList);
                if(setOpportunityId.size() >0){
                    updateOpportunities(setOpportunityId); 
                }
            }
            when else{
                System.debug('Undefined Trigger Operation!');
            }
        }
    }

    public static Set<Id> getOppID(List<Opportunitylineitem> lstOLI){
        Set<Id> setOpportunityId = new Set<Id>();
        for(Opportunitylineitem obj : lstOLI){
            if(obj.Product2.Auto_Generated_Product__c == false){ //Skipping if 'Shipping and Handling' is updating
                setOpportunityId.add(obj.OpportunityId);
            }
        }
        return setOpportunityId;
    }

    public static void updateOpportunities(Set<Id> setOpportunityId){
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        for(Opportunity obj : [SELECT Id, Name, Order_s_Products__c, Order_s_Packages__c, (SELECT id,  Name, Product_Name__c, Record_Type__c, Product2.recordType.Name, Product2.a_la_carte__C, Quantity FROM OpportunityLineItems order by LastModifiedDate) FROM Opportunity  WHERE Id IN: setOpportunityId]){
            List<OpportunityLineItem> lstOppItem = obj.OpportunityLineItems;
            List<String> lstPackageName = new List<String>();
            List<String> lstOpplineItem = new List<String>();
            System.debug('No of oppLineItem on Opportunity: ' + lstOppItem.size());
            for(OpportunityLineItem oppItem: lstOppItem) {
                String recordTypeString = oppItem.Product2.recordtype.Name;
                if(recordTypeString.equals('Package') || recordTypeString.equals('Hotel') || oppItem.Product2.a_la_carte__C == true) {
                    lstOpplineItem.add(oppItem.Product_Name__c);
                }
                if(oppItem.Record_Type__c == 'Package' || recordTypeString.equals('Package')){
                    lstPackageName.add(oppItem.Product_Name__c + ' - '+Integer.valueOf(oppItem.Quantity)+' Qty');
                }
            }
            obj.Order_s_Products__c = '';
            obj.Order_s_Packages__c = '--';
            if(lstOpplineItem.size() > 0) {
                obj.Order_s_Products__c = String.join(lstOpplineItem,', '); 
            }
            if(lstPackageName.size() > 0) {
                obj.Order_s_Packages__c = String.join(lstPackageName,'\r\n');
            }
            lstOpportunity.add(obj);
        }

        System.debug('updating Count: ' + lstOpportunity.size());         
        if(lstOpportunity.size() > 0){
            Utility.processRecords(lstOpportunity, 'update');
        } 
    }
}
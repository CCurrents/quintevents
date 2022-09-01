/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 10-07-2021
 * @last modified by  : ratiksinghal@addonblue.com
**/
global with sharing class UpdateOpportunityBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    global String query;
    
    global UpdateOpportunityBatch(String pbName) {
        query = 'Select id, Opportunity.Name, OpportunityId from Order where status = \'Active\' and OpportunityId!= null ';
        if(String.isNotEmpty(pbName)){
            query+= 'and Pricebook2.Name like \'%'+pbName+'%\'';
        }
        System.debug('Query: '+query);
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order> scope){ 
        Set<Id> setOpportunityId = getOppID(scope);
        System.debug('Total Opportunity: '+setOpportunityId.size());
        updateOpportunities(setOpportunityId);
    }

    global void finish(Database.BatchableContext BC){

    }

    public static void updateOpportunities(Set<Id> setOpportunityId){
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        for(Opportunity obj : [SELECT Id, Name, Order_s_Products__c,  (SELECT id,  Name, Product_Name__c, product2.recordType.Name, product2.a_la_carte__C FROM OpportunityLineItems  order by LastModifiedDate) FROM Opportunity  WHERE Id IN: setOpportunityId]){
            List<String> lstOppProduct = new List<String>();
            List<OpportunityLineItem> lstOppItem = obj.OpportunityLineItems;
            for(OpportunityLineItem oppItem: lstOppItem){
                String recordTypeString = oppItem.Product2.recordtype.Name;
                if(recordTypeString.equals('Package') || recordTypeString.equals('Hotel') || oppItem.Product2.a_la_carte__C == true){
                    lstOppProduct.add(oppItem.Product_Name__c);
                }
            }
            //System.debug('No of oppLineItem matched ' + lstOppItem.size());
            if(lstOppProduct.size()>0){
                obj.Order_s_Products__c = String.join(lstOppProduct,', '); 
                lstOpportunity.add(obj);
            } 
            else if(!String.isBlank(obj.Order_s_Products__c)){
                obj.Order_s_Products__c = '';
                lstOpportunity.add(obj);
            }     
        }
        System.debug('Updating Opportunity Count: ' + lstOpportunity.size());
        if(lstOpportunity.size() > 0){
            List<Opportunity> updateOpp = Utility.processRecords(lstOpportunity, 'update');
            System.debug('Total: ' + lstOpportunity.size() + 'updated successfully');
        } 
    }

    public static Set<Id> getOppID(List<Order> lstOrder){
        Set<Id> setOpportunityId = new Set<Id>();
        for(Order obj : lstOrder){
            setOpportunityId.add(obj.OpportunityId);
        }
        return setOpportunityId;
    }
}
/**
 * @File Name          : MCShipmentTriggerHelper.cls
 * @Description        : Trigger helper on shipment object
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 2/28/2020, 3:11:00 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    9/26/2019     mpatel@addonblue.com      Initial Version
 * 1.1     2/3/2020      mpatel@addonblue.com      Refactored the code by changing the structure of the code as per the standards
**/
public with sharing class MCShipmentTriggerHelper{

    private Map<Id, zkmulti__MCShipment__c> newShipmentMap; 
    private Map<Id, zkmulti__MCShipment__c> oldShipmentMap;
    private List<zkmulti__MCShipment__c> newShipmentList;
    private List<zkmulti__MCShipment__c> oldShipmentList;
    
    public MCShipmentTriggerHelper(){
        Utility.getSOQLCount();
        Utility.getTriggerSize();  
        this.newShipmentMap = (Map<Id, zkmulti__MCShipment__c>) Trigger.newMap;
        this.oldShipmentMap = (Map<Id, zkmulti__MCShipment__c>) Trigger.oldMap;
        this.newShipmentList = (List<zkmulti__MCShipment__c>) Trigger.new;
        this.oldShipmentList = (List<zkmulti__MCShipment__c>) Trigger.old;
        
        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
            }
            when BEFORE_UPDATE {
            }
            when BEFORE_DELETE {
            }
            when AFTER_INSERT {
                
                Set<String> setOfOrderId = new Set<String>();
                for(zkmulti__MCShipment__c objshipment : newShipmentList ) {
                   setOfOrderId.add(objshipment.Order__c);
                }
                if(!setOfOrderId.isEmpty()){
                    List<Order> listOfOldOrder = [SELECT Id, Tracking_Number__c,(Select Id,zkmulti__Tracking_Number__c from Shipments__r where zkmulti__Tracking_Number__c != null)  FROM Order where Id IN : setOfOrderId];
                    updateTrackingNumber(listOfOldOrder);
                }
            }
            when AFTER_UPDATE {
                Set<String> setOfOrderId = new Set<String>();        
                for(zkmulti__MCShipment__c objShipment : newShipmentList) {
                    if(oldShipmentMap  == null || oldShipmentMap.get(objShipment.id).Order__c != objShipment.Order__c || 
                    oldShipmentMap.get(objShipment.id).zkmulti__Tracking_Number__c  != objShipment.zkmulti__Tracking_Number__c){
                        setOfOrderId.add(objShipment.Order__c);
                    }
                }
                if(!setOfOrderId.isEmpty()){
                    List<Order> listOfOldOrder = [SELECT Id, Tracking_Number__c,(Select Id,zkmulti__Tracking_Number__c from Shipments__r where zkmulti__Tracking_Number__c != null)  FROM Order where Id IN : setOfOrderId];
                    updateTrackingNumber(listOfOldOrder);
                }
            }
            when AFTER_DELETE {
                
                Set<String> setOfOrderId = new Set<String>();
                for(zkmulti__MCShipment__c objshipment : oldShipmentList ) {
                    setOfOrderId.add(objshipment.Order__c);
                }
                List<Order> listOfOldOrder;
                if(!setOfOrderId.isEmpty()){
                    listOfOldOrder = [SELECT Id, Tracking_Number__c,(Select Id,zkmulti__Tracking_Number__c from Shipments__r where zkmulti__Tracking_Number__c != null)  FROM Order where Id IN : setOfOrderId];
                }
                deleteTrackingNumber(oldShipmentList, listOfOldOrder);     
            }
            when AFTER_UNDELETE {
                Set<String> setOfOrderId = new Set<String>();        
                for(zkmulti__MCShipment__c objShipment : newShipmentList) {
                    if(oldShipmentMap  == null || oldShipmentMap.get(objShipment.id).Order__c != objShipment.Order__c || 
                    oldShipmentMap.get(objShipment.id).zkmulti__Tracking_Number__c  != objShipment.zkmulti__Tracking_Number__c){
                        setOfOrderId.add(objShipment.Order__c);
                    }
                }
                if(!setOfOrderId.isEmpty()){
                    List<Order> listOfOldOrder = [SELECT Id, Tracking_Number__c,(Select Id,zkmulti__Tracking_Number__c from Shipments__r where zkmulti__Tracking_Number__c != null)  FROM Order where Id IN : setOfOrderId];
                    updateTrackingNumber(listOfOldOrder);
                }
            }
            when else{
                System.debug('Undefined Trigger Operation!');
            }
        }
    }
    /**
    * @description  : update the tracking number on opportunity object
    * @author       : mpatel@addonblue.com | 1/28/2020 
    * @param        : List<Order> listOfOldOrder
    * @return       : void 
    **/
    private void updateTrackingNumber(List<Order> listOfOldOrder){
        try{     
            Boolean isFirst = true;
            if(!listOfOldOrder.isEmpty()){
                for(Order ObjOrder : listOfOldOrder) {
                    ObjOrder.Tracking_Number__c = '';  
                    for (zkmulti__MCShipment__c mcshpment : ObjOrder.Shipments__r){
                        if(isFirst) {
                            ObjOrder.Tracking_Number__c += mcshpment.zkmulti__Tracking_Number__c;
                            isFirst = false;
                        }
                        else {
                            ObjOrder.Tracking_Number__c += ',' + mcshpment.zkmulti__Tracking_Number__c; 
                        }
                        
                    }
                }
                Utility.processRecords(listOfOldOrder, 'upsert');
            }
        }catch(Exception ex){
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }

    /**
    * @description  : delete the tracking number on opportunity object
    * @author       : mpatel@addonblue.com | 1/28/2020 
    * @param        : List<zkmulti__MCShipment__c> oldShipmentList
    * @param        : List<Order> listOfOldOrder
    * @return       : void 
    **/
    private void deleteTrackingNumber(List<zkmulti__MCShipment__c> oldShipmentList, List<Order> listOfOldOrder) {
        try{
            Utility.processDeletedRecords(oldShipmentList);

            List<Order> listOfOpportunity = new List<Order>();
            
            Boolean isFirst = true;
            if(!listOfOldOrder.isEmpty()){
                for(Order ObjOrder : listOfOldOrder) {
                    ObjOrder.Tracking_Number__c = '';                
                    for (zkmulti__MCShipment__c objMcshpiment : ObjOrder.Shipments__r){                    
                        if(isFirst) {
                            ObjOrder.Tracking_Number__c += objMcshpiment .zkmulti__Tracking_Number__c;
                            isFirst = false;
                        }
                        else {
                            ObjOrder.Tracking_Number__c += ',' + objMcshpiment .zkmulti__Tracking_Number__c; 
                        }                    
                    }
                    listOfOpportunity.add(ObjOrder);
                    
                }
                if(!listOfOpportunity.isEmpty()) {
                    Utility.processRecords(listOfOpportunity, 'update');
                }
            }
        }catch(Exception ex){
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
}
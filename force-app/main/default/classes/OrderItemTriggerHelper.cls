/**
 * @File Name          : OrderItemTriggerHandler.cls
 * @Description        : 
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : rama.krishna@addonblue.com
 * @Last Modified On   : 18-10-2021
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    22/12/2020   fsuraitawala@addonblue.com     Initial Version
**/
public with sharing class OrderItemTriggerHelper {
    
    private Map<Id, OrderItem> newOrderItemMap; 
    private Map<Id, OrderItem> oldOrderItemMap;
    private List<OrderItem> newOrderItemList;
    private List<OrderItem> oldOrderItemList;
    
    /**
    * @description Constructor
    * @author jagrawal@addonblue.com | 6/3/2020 
    * @return void 
    **/
    public OrderItemTriggerHelper() {
        this.newOrderItemMap = (Map<Id, OrderItem>) Trigger.newMap;
        this.oldOrderItemMap = (Map<Id, OrderItem>) Trigger.oldMap;
        this.newOrderItemList = (List<OrderItem>) Trigger.new;
        this.oldOrderItemList = (List<OrderItem>) Trigger.old;
        
        switch on Trigger.operationType {
            when AFTER_INSERT {
                Set<Id> setOrderId = new Set<Id>();
                for(OrderItem objOI: newOrderItemList){
                    setOrderId.add(objOI.OrderId);
                }
                
                if(setOrderId.size() > 0){
                    updateOrderGiftCodeRelatedFields(setOrderId);
                }
            }
            when BEFORE_DELETE {
                List<Inventory_Transaction__c> InventoriesList = new List<Inventory_Transaction__c>();
                if(oldOrderItemList.size() > 0) {
                    InventoriesList = [SELECT Id, Order_Item__c FROM Inventory_Transaction__c WHERE Order_Item__c IN :oldOrderItemList];
                }
                if(InventoriesList.size() > 0) {
                    Delete InventoriesList;
                }
            }
            when AFTER_DELETE {
                Set<Id> setOrderId = new Set<Id>();
                for(OrderItem objOI: oldOrderItemList){
                    setOrderId.add(objOI.OrderId);
                }
                
                if(setOrderId.size() > 0){
                    updateOrderGiftCodeRelatedFields(setOrderId);
                }
            }
        }
    }

    /**
    * @description: Update Order Gift Code Related Fields
    * @author fsuraitawala@addonblue.com | 06/04/2021
    * @param set<Id> setOrderIds
    * @return void
    **/
    public static void updateOrderGiftCodeRelatedFields(Set<Id> setOrderIds){
        List<Order> lstUpdateOrder = new List<Order>();
        
        for(Order objOrder: [Select Id, Fanatics_Gift_Code_Assignment_Pending__c, F1_Access_Code_Assignment_Pending__c,NBA_League_Pass_Assignment_Pending__c,NBA_Top_Shot_Assignment_Pending__c,NBA_TV_Assignment_Pending__c,
                            (Select Id, Product2.Type__c FROM OrderItems WHERE Product2.Type__c IN ('F1 Access Code' , 'Fanatics Gift Code' ,'NBA League Pass' , 'NBA TV' , 'NBA Top Shot')) FROM Order WHERE Id IN :setOrderIds]){
            Boolean isOrderUpdate = false;
            if(objOrder.OrderItems.size() > 0) {
                Boolean isF1AccessCode = false;
                Boolean isFanaticsGiftCode = false;
                Boolean isNBALeaguePass = false;
                Boolean isNBATopShot = false;
                Boolean isNBATV = false;

                for(OrderItem objItem : objOrder.OrderItems){
                    if(objItem.Product2.Type__c == 'F1 Access Code'){
                       isF1AccessCode = true;
                    }
                    if(objItem.Product2.Type__c == 'Fanatics Gift Code'){
                       isFanaticsGiftCode = true;
                    }
                    if(objItem.Product2.Type__c == 'NBA League Pass'){
                       isNBALeaguePass = true;
                    }
                    if(objItem.Product2.Type__c == 'NBA TV'){
                       isNBATV = true;
                    }
                    if(objItem.Product2.Type__c == 'NBA Top Shot'){
                       isNBATopShot = true;
                    }
                }
                if(isF1AccessCode && !objOrder.F1_Access_Code_Assignment_Pending__c){
                    objOrder.F1_Access_Code_Assignment_Pending__c = true;
                    isOrderUpdate = true;
                }
                if(isFanaticsGiftCode && !objOrder.Fanatics_Gift_Code_Assignment_Pending__c){
                    objOrder.Fanatics_Gift_Code_Assignment_Pending__c = true;
                    isOrderUpdate = true;
                }
                 if(isNBALeaguePass && !objOrder.NBA_League_Pass_Assignment_Pending__c){
                    objOrder.NBA_League_Pass_Assignment_Pending__c= true;
                    isOrderUpdate = true;
                }
                 if(isNBATV && !objOrder.NBA_TV_Assignment_Pending__c){
                    objOrder.NBA_TV_Assignment_Pending__c= true;
                    isOrderUpdate = true;
                }
                 if(isNBATopShot && !objOrder.NBA_Top_Shot_Assignment_Pending__c){
                    objOrder.NBA_Top_Shot_Assignment_Pending__c= true;
                    isOrderUpdate = true;
                }
                
            } else {
                if(objOrder.Fanatics_Gift_Code_Assignment_Pending__c){
                    objOrder.Fanatics_Gift_Code_Assignment_Pending__c = false;
                    isOrderUpdate = true;
                }
                if(objOrder.F1_Access_Code_Assignment_Pending__c){
                    objOrder.F1_Access_Code_Assignment_Pending__c = false;
                    isOrderUpdate = true;
                }
                
                 if(objOrder.NBA_League_Pass_Assignment_Pending__c){
                    objOrder.NBA_League_Pass_Assignment_Pending__c= false;
                    isOrderUpdate = true;
                }
                 if(objOrder.NBA_Top_Shot_Assignment_Pending__c){
                    objOrder.NBA_Top_Shot_Assignment_Pending__c= false;
                    isOrderUpdate = true;
                }
                 if(objOrder.NBA_TV_Assignment_Pending__c){
                    objOrder.NBA_TV_Assignment_Pending__c= false;
                    isOrderUpdate = true;
                }
            }
            if(isOrderUpdate){
                lstUpdateOrder.add(objOrder);
            }
        }
        
        if(lstUpdateOrder.size() > 0){
            TriggerHandler.bypass('OrderTriggerHandler');
            Utility.processRecords(lstUpdateOrder,'update');
            TriggerHandler.clearBypass('OrderTriggerHandler');
        }
    }
}
/**
 * @File Name          : InventoryTransactionTriggerHelper.cls
 * @Description        : Helper class for InventoryTransactionTriggerHandler
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 03-04-2022
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    11/03/2020   fsuraitawala@addonblue.com    Initial Version
 * 2.0    12/22/2020   fsuraitawala@addonblue.com   #641 Inventory Related Change
**/
public with sharing class InventoryTransactionTriggerHelper {
    private Map<Id, Inventory_Transaction__c> newITMap; 
    private Map<Id, Inventory_Transaction__c> oldITMap;
    private List<Inventory_Transaction__c> newITList;
    private List<Inventory_Transaction__c> oldITList;
    
    /**
    * @description: Constructor
    * @author: fsuraitawala@addonblue.com
    **/
    public InventoryTransactionTriggerHelper() {
        Utility.getSOQLCount();
        Utility.getTriggerSize();
        this.newITMap = (Map<Id, Inventory_Transaction__c>) Trigger.newMap;
        this.oldITMap = (Map<Id, Inventory_Transaction__c>) Trigger.oldMap;
        this.newITList = (List<Inventory_Transaction__c>) Trigger.new;
        this.oldITList = (List<Inventory_Transaction__c>) Trigger.old;
        
        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
                System.debug('In Inventory Transaction Before Insert!');
                onBeforeInsertInventory();
            }
            
            when BEFORE_UPDATE {
                prepopulateFieldsonIT();
                System.debug('In Inventory Transaction Before Update!');
            }
            
            when BEFORE_DELETE {
                System.debug('In Inventory Transaction Before Delete!');
                onBeforeDeleteInventory();
            }
            
            when AFTER_INSERT {
                System.debug('In Inventory Transaction After Insert!');
                onAfterInsertInventory();
            }
            
            when AFTER_UPDATE {
                System.debug('In Inventory Transaction After Update!');
            }
            
            when AFTER_DELETE {
                System.debug('In Inventory Transaction After Delete!');
                onAfterDeleteInventory();
            }
            
            when AFTER_UNDELETE {
                System.debug('In Inventory Transaction After Undelete!');
            }
            
            when else {
                System.debug('Undefined Trigger Operation!');
            }
        }
    }
    
    public void prepopulateFieldsonIT() {
        for(Inventory_Transaction__c objIT : (List<Inventory_Transaction__c>)Trigger.New) {
            if(objIT.Quantity__c != null && objIT.Cost_Per_Quantity__c != null){
                objIT.Cost__c = objIT.Quantity__c * objIT.Cost_Per_Quantity__c;
            }
        }
    }
    
    /**
    * @description  : Method for before Insert Event of trigger
    * @author       : fsuraitawala@addonblue.com
    * @param        : newPricebooks(New list of object)
    * @return       : void
    **/
    public void onBeforeInsertInventory() {
        Id InventoryLoadId = Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByDeveloperName().get('Inventory_Load').getRecordTypeId();
        Set<Id> setProductIds = new Set<Id>();
        Map<Id, Product2> mapProduct = new Map<Id, Product2>();
        
        try {
            for(Inventory_Transaction__c objInventory: newITList) {
                if(objInventory.RecordTypeId == InventoryLoadId) {
                    setProductIds.add(objInventory.Product__c);
                }
            }
            
            if(setProductIds != null && setProductIds.size() > 0) {
                for(Product2 objProduct : [Select Id, Current_Inventory__c, Cost__c From Product2 Where Id In :setProductIds]) {
                    mapProduct.put(objProduct.Id, objProduct);
                }
            }
            
            for(Inventory_Transaction__c objInventory: newITList) {
                if(objInventory.Quantity__c != null && objInventory.Cost_Per_Quantity__c != null){
                    objInventory.Cost__c = objInventory.Quantity__c * objInventory.Cost_Per_Quantity__c;
                }
                if(objInventory.RecordTypeId == InventoryLoadId && mapProduct != null && mapProduct.containskey(objInventory.Product__c)) {
                    Product2 objProduct = mapProduct.get(objInventory.Product__c);
                    
                    objInventory.Inventory_Before_Load__c = objProduct.Current_Inventory__c;
                    objInventory.Inventory_After_Load__c = objProduct.Current_Inventory__c + objInventory.Quantity__c;
                }
            }
        } catch(Exception ex) {
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
    
    /**
    * @description  : Method for after Insert Event of trigger
    * @author       : fsuraitawala@addonblue.com
    * @param        : newPricebooks(New list of object)
    * @return       : void
    **/
    public void onAfterInsertInventory() {
        Set<Id> setProductIds = new Set<Id>();

        try {
            for(Inventory_Transaction__c objInventory: newITList) {
                setProductIds.add(objInventory.Product__c);
            }
            
            if(setProductIds != null && setProductIds.size() > 0) {
                updateProductFieldsOnQuantityChange(setProductIds);
            }
        } catch(Exception ex) {
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
    /**
    * @description  : Method for before Delete Event of trigger
    * @author       : fsuraitawala@addonblue.com
    * @param        : newPricebooks(New list of object)
    * @return       : void
    **/
    public void onBeforeDeleteInventory() {
        String strProfileName = [Select Id, Name FROM Profile WHERE ID = :UserInfo.getProfileId()].Name;
        for(Inventory_Transaction__c objInventory: oldITList) {
            if(objInventory.Hold_Released_Processed__c && objInventory.RecordTypeId == Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByDeveloperName().get('Inventory_Hold').getRecordTypeId()){
                objInventory.addError('You cannot delete Inventory Hold which is released.');
            }
            if(strProfileName == 'QE360 - Operations' && objInventory.RecordTypeId != Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByDeveloperName().get('Inventory_Hold').getRecordTypeId()){
                objInventory.addError('Inventory Load and Order Inventory cannot be deleted.');
            }
        }
    }
    /**
    * @description  : Method for update Inventory on Delete #641
    * @author       : fsuraitawala@addonblue.com
    * @param        : 
    * @return       : void
    **/
    public void onAfterDeleteInventory() {
        Set<Id> setProductIds = new Set<Id>();
        Map<Id,Product2> mapProduct = new  Map<Id, Product2>();
        List<Product2> updatableProduct = new List<Product2>();
        
        try {
            for(Inventory_Transaction__c objInventory: oldITList) {
                setProductIds.add(objInventory.Product__c);
            }
            if(setProductIds.size() > 0){
                mapProduct = new  Map<Id, Product2>([Select Id, Total_Inventory__c, Total_Ordered_Quantity__c, Total_Quote_Holds__c, Total_Manual_Holds__c FROM Product2 WHERE Id IN :setProductIds]);
                /*********************************/
                Map<Id,List<Inventory_Transaction__c>> mapProductWithInventories = new Map<Id,List<Inventory_Transaction__c>>();
                for(Inventory_Transaction__c objIT : oldITList){
                    List<Inventory_Transaction__c> lstInventories = new List<Inventory_Transaction__c>();
                    if(mapProductWithInventories != null && mapProductWithInventories.get(objIT.Product__c) != null){
                        lstInventories = mapProductWithInventories.get(objIT.Product__c);
                    }
                    lstInventories.add(objIT);
                    mapProductWithInventories.put(objIT.Product__c, lstInventories);
                }
                /*********************************/
                for(Id productId: mapProductWithInventories.keyset()) {
                    Product2 objProduct = mapProduct.get(productId);
                    
                    Decimal totalInventory = objProduct.Total_Inventory__c;
                    Decimal totalOrderInventory = objProduct.Total_Ordered_Quantity__c;
                    Decimal totalHoldQuoteInventory = objProduct.Total_Quote_Holds__c;
                    Decimal totalHoldManualInventory = objProduct.Total_Manual_Holds__c;
                    
                    if(!mapProductWithInventories.get(productId).isEmpty()) {
                        for(Inventory_Transaction__c item : mapProductWithInventories.get(objProduct.Id)) {
                            Decimal Quantity = item.Quantity__c != null ? item.Quantity__c : 0;
                            //Order_Inventory
                            if(item.RecordTypeId == Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByDeveloperName().get('Order_Inventory').getRecordTypeId()) {
                                totalOrderInventory = totalOrderInventory - Quantity;
                            }
                            //Inventory_Load
                            if(item.RecordTypeId == Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByDeveloperName().get('Inventory_Load').getRecordTypeId()) {
                                totalInventory = totalInventory - Quantity;
                            }

                            if(item.RecordTypeId == Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByDeveloperName().get('Inventory_Hold').getRecordTypeId()) {
                                if(item.Quote_Line_Item__c != null && item.Quote__c != null)
                                {
                                    totalHoldQuoteInventory = totalHoldQuoteInventory - Quantity;
                                }else{
                                    totalHoldManualInventory = totalHoldManualInventory - Quantity;
                                }
                            }
                        }
                    }
                    
                    Boolean isUpdate = false;
                    if(totalInventory != objProduct.Total_Inventory__c){
                        objProduct.Total_Inventory__c = totalInventory;
                        isUpdate = true;
                    }
                    if(totalOrderInventory != objProduct.Total_Ordered_Quantity__c){
                        objProduct.Total_Ordered_Quantity__c = totalOrderInventory;
                        isUpdate = true;
                    }
                    if(totalHoldQuoteInventory != objProduct.Total_Quote_Holds__c){
                        objProduct.Total_Quote_Holds__c = totalHoldQuoteInventory;
                        isUpdate = true;
                    }
                    if(totalHoldManualInventory != objProduct.Total_Manual_Holds__c){
                        objProduct.Total_Manual_Holds__c = totalHoldManualInventory;
                        isUpdate = true;
                    }
                   
                    if(isUpdate){
                        updatableProduct.add(objProduct);
                    }       
                }
                if(!updatableProduct.isEmpty()){
                    Utility.processRecords(updatableProduct, 'update');
                }
                
            }
        } catch(Exception ex) {
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
    
    /**
    * @description  : Method for update Product Fields On Quantity Change
    * @author       : fsuraitawala@addonblue.com
    * @param        : setProductIds(Set of updatable Product Ids)
    * @return       : void
    **/
    public void updateProductFieldsOnQuantityChange(Set<Id> setProductIds) {
        try {
            List<Product2> updatableProduct = new List<Product2>();
            Map<Id,Product2> mapProduct = new  Map<Id, Product2>([Select Cost__c, Current_Inventory__c, Total_Inventory__c, Total_Ordered_Quantity__c, Total_Cost__c, Total_Manual_Holds__c, Total_Quote_Holds__c from Product2 where Id in: setProductIds]);
            List<Inventory_Transaction__c> lstInventoryTransction = [SELECT Id, Name, Cost__c, Product__c, Cost_Per_Quantity__c, Quantity__c, RecordType.DeveloperName, Quote_Line_Item__c, Quote__c From Inventory_Transaction__c where Id IN :newITList];
            Map<Id,List<Inventory_Transaction__c>> mapIT = new Map<Id,List<Inventory_Transaction__c>>();
            for(Inventory_Transaction__c objIT : lstInventoryTransction){
                List<Inventory_Transaction__c> lstIT = new List<Inventory_Transaction__c>();
                if( mapIT.get(objIT.Product__c) != null){
                    lstIT = mapIT.get(objIT.Product__c);
                }
                lstIT.add(objIT);
                mapIT.put(objIT.Product__c,lstIT);
            }
            for(Product2 objProduct: mapProduct.values()) {
                objProduct.Total_Inventory__c =  objProduct.Total_Inventory__c == null ? 0 : objProduct.Total_Inventory__c;
                objProduct.Total_Cost__c = objProduct.Total_Cost__c == null ? 0 : objProduct.Total_Cost__c;
                objProduct.Total_Ordered_Quantity__c = objProduct.Total_Ordered_Quantity__c == null ? 0 : objProduct.Total_Ordered_Quantity__c;
                objProduct.Cost__c = objProduct.Cost__c == null ? 0 : objProduct.Cost__c;
                objProduct.Total_Quote_Holds__c = objProduct.Total_Quote_Holds__c == null ? 0 : objProduct.Total_Quote_Holds__c;
                objProduct.Total_Manual_Holds__c = objProduct.Total_Manual_Holds__c == null ? 0 : objProduct.Total_Manual_Holds__c;
                
                if(!mapIT.get(objProduct.Id).isEmpty()) {
                    for(Inventory_Transaction__c item : mapIT.get(objProduct.Id)) {
                        Decimal costPerQuantity = item.Cost_Per_Quantity__c != null ? item.Cost_Per_Quantity__c : 0;
                        Decimal Quantity = item.Quantity__c != null ? item.Quantity__c : 0;
                        Decimal productCost = objProduct.Cost__c != null ? objProduct.Cost__c : 0;
                        Decimal costPerUnit = objProduct.Current_Inventory__c + Quantity;
                        
                        //Order_Inventory
                        if(item.RecordType.DeveloperName == 'Order_Inventory') {
                            objProduct.Total_Ordered_Quantity__c += Quantity;
                        }
                        
                        //Inventory_Load
                        else if(item.RecordType.DeveloperName == 'Inventory_Load') {
                            objProduct.Total_Inventory__c += Quantity;
                            //Added by Jheel for #100
                            objProduct.Total_Cost__c +=  item.Cost__c != null ? item.Cost__c : 0;
                            if(costPerUnit == 0) {
                                objProduct.Cost__c = ((costPerQuantity * Quantity) + (objProduct.Current_Inventory__c * productCost));
                            } else {
                                objProduct.Cost__c = ((costPerQuantity * Quantity) + (objProduct.Current_Inventory__c * productCost)) / costPerUnit;
                            }
                        }

                        //Inventory_Load
                        else if(item.RecordType.DeveloperName == 'Inventory_Hold') {
                            if(item.Quote_Line_Item__c != null && item.Quote__c != null)
                            {
                                objProduct.Total_Quote_Holds__c += Quantity;
                            }else{
                                objProduct.Total_Manual_Holds__c += Quantity;
                            }
                        }
                    }
                }
                updatableProduct.add(objProduct);
            }
            if(updatableProduct != null && updatableProduct.size() > 0) {
                Utility.processRecords(updatableProduct, 'update');
                updatePackageInvetory(setProductIds);
            }
        } catch(Exception ex) {
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
    
    /**
    * @description  : Method for update Package Invetory of Parent Package
    * @author       : fsuraitawala@addonblue.com
    * @param        : setProductIds(Set of updatable Product Ids)
    * @return       : void
    **/
    public void updatePackageInvetory(Set<Id> setProductIds) {
        List<Products_Bundle__c> lstProductsBundle = new List<Products_Bundle__c>();
        Map<Id, Integer> mapPackageInventory = new Map<Id, Integer>();
        Map<Id, String> mapOldInventory = new Map<Id, String>();
        Set<Id> ParentProductIds = new Set<Id>();
        
        lstProductsBundle = [SELECT Id, Name, Type__c, Child_product__c, Child_product__r.Current_Inventory__c, Parent_Product__c 
                             FROM Products_Bundle__c 
                             WHERE Type__c = 'Package Product' AND Child_product__c IN :setProductIds];
        
        for(Products_Bundle__c objBundle : lstProductsBundle) {
            ParentProductIds.add(objBundle.Parent_Product__c);
        }
        
        for(Products_Bundle__c objBundle : [SELECT Id, Name, Type__c, Child_product__c, Child_product__r.Current_Inventory__c, 
                                            Parent_Product__c, Parent_Product__r.Package_Inventory__c FROM Products_Bundle__c 
                                            Where Parent_Product__r.RecordType.Name = 'Package' 
                                            AND Child_Product__r.Available__c = false AND Type__c = 'Package Product'
                                            AND Parent_Product__c IN :ParentProductIds]) {
            
            mapOldInventory.put(objBundle.Parent_Product__c, objBundle.Parent_Product__r.Package_Inventory__c);
            
            Integer childInventory = (Integer) objBundle.Child_product__r.Current_Inventory__c;
            
            if(objBundle.Parent_Product__c != null){
                if(mapPackageInventory != null && mapPackageInventory.containsKey(objBundle.Parent_Product__c)) {
                    if(childInventory < mapPackageInventory.get(objBundle.Parent_Product__c)) {
                        mapPackageInventory.put(objBundle.Parent_Product__c, childInventory);
                    }
                } else {
                    mapPackageInventory.put(objBundle.Parent_Product__c, childInventory);
                }
            }
        }
        
        List<Product2> lstProduct = new List<Product2>();
        
        for(Id ProductId : mapPackageInventory.keyset()) {
            if(mapOldInventory != null && mapOldInventory.containsKey(ProductId)){
                String oldInventory = mapOldInventory.get(ProductId);
                String newInventory = String.valueOf(mapPackageInventory.get(ProductId));
                
                if(oldInventory != newInventory){
                    Product2 objProduct = new Product2();
                    objProduct.Id = ProductId;
                    objProduct.Package_Inventory__c = newInventory;
                    
                    lstProduct.add(objProduct);
                }
            }
        }
        if(!lstProduct.isEmpty()){
            Utility.processRecords(lstProduct, 'update');
        }
    }
}
/**
 * @File Name          : ProductBundleTriggerHandler.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 05-05-2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    5/15/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class ProductBundleTriggerHelper {
    private Map<Id, Products_Bundle__c> newProductBundleMap; 
    private Map<Id, Products_Bundle__c> oldProductBundleMap;
    private List<Products_Bundle__c> newProductBundleList;
    private List<Products_Bundle__c> oldProductBundleList;
    
    /**
    * @description Constructor to query all data at once and then pass it in the Helper methods for specific Trigger event
    * @author jagrawal@addonblue.com | 6/3/2020 
    * @return void 
    **/
    public ProductBundleTriggerHelper() {
        
        this.newProductBundleMap = (Map<Id, Products_Bundle__c>) Trigger.newMap;
        this.oldProductBundleMap = (Map<Id, Products_Bundle__c>) Trigger.oldMap;
        this.newProductBundleList = (List<Products_Bundle__c>) Trigger.new;
        this.oldProductBundleList = (List<Products_Bundle__c>) Trigger.old;
        
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
                System.debug('In After Insert!');
                onAfterInsertProductBundle();
            }
            
            when AFTER_UPDATE {
                System.debug('In After Update!');
            }
            
            when AFTER_DELETE {
                System.debug('In After Delete!');
                captureDeletedProductBundles(oldProductBundleList);
                onAfterDeleteProductBundle();
            }
            
            when AFTER_UNDELETE {
                System.debug('In After Undelete!');
            }
            
            when else {
                System.debug('Undefined Trigger Operation!');
            }
        }
    }
    
     /**
    * @description  : Method for handle after insert event
    * @author       : fsuraitawala@addonblue.com
    * @return       : void
    **/
    public void onAfterInsertProductBundle() {
        Set<Id> ParentProductIds = new Set<Id>();
        
        for(Products_Bundle__c objProductBundle : newProductBundleList) {
            ParentProductIds.add(objProductBundle.Parent_Product__c);
        }
        
        if(ParentProductIds != null && ParentProductIds.size() > 0) {
            updatePackageInvetory(ParentProductIds);
        }
    }
    
    /**
    * @description  : Method for handle after delete event
    * @author       : fsuraitawala@addonblue.com
    * @return       : void
    **/
    public void onAfterDeleteProductBundle() {
        Set<Id> ParentProductIds = new Set<Id>();
        
        for(Products_Bundle__c objProductBundle : oldProductBundleList) {
            ParentProductIds.add(objProductBundle.Parent_Product__c);
        }
        
        if(ParentProductIds != null && ParentProductIds.size() > 0) {
            updatePackageInvetory(ParentProductIds);
        }
    }
    
    /**
    * @description  : Method for update Package Invetory of Parent Package
    * @author       : fsuraitawala@addonblue.com
    * @param        : setProductIds(Set of updatable Product Ids)
    * @return       : void
    **/
    public void updatePackageInvetory(Set<Id> ParentProductIds) {
        List<Product2> lstParentProducts = new List<Product2>();
        List<Product2> lstUpdateProducts = new List<Product2>();
        
        if(ParentProductIds.size() > 0){
            lstParentProducts = [Select Id, RecordType.Name, Package_Inventory__c, Available__c, Package_Average_Cost__c,
                                 (SELECT Id, Name, Type__c, Child_product__c, Child_product__r.Current_Inventory__c, Child_product__r.Available__c, 
                                  Child_product__r.Cost_for_Available_Product__c, Child_product__r.Running_Average_Cost__c 
                                  FROM Products_Bundles__r WHERE Type__c = 'Package Product' AND Child_product__c != null
                                 ) 
                                 FROM Product2 WHERE Id IN :ParentProductIds AND RecordType.Name = 'Package'];
        }
        
        if(lstParentProducts.size() > 0) {
            for(Product2 objProduct: lstParentProducts){
                Integer tempPackageInventory = null;
                Integer i = 0;
                Decimal avgDecimal = 0.0;
                Boolean isProductUpdate = false;
                String oldPackageInventory = objProduct.Package_Inventory__c;
                
                for(Products_Bundle__c objBundle : objProduct.Products_Bundles__r) {
                    if(objBundle.Child_product__r.Available__c) {
                        avgDecimal = avgDecimal + (objBundle.Child_product__r.Cost_for_Available_Product__c != null ? objBundle.Child_product__r.Cost_for_Available_Product__c : 0);
                    } else {
                        avgDecimal = avgDecimal + (objBundle.Child_product__r.Running_Average_Cost__c != null ? objBundle.Child_product__r.Running_Average_Cost__c : 0);
                        //Package Inventory Calculation
                        if(i == 0) {
                            tempPackageInventory = (Integer) objBundle.Child_product__r.Current_Inventory__c;
                        } else if(tempPackageInventory > objBundle.Child_product__r.Current_Inventory__c) {
                            tempPackageInventory = (Integer) objBundle.Child_product__r.Current_Inventory__c;
                        }
                        i++;
                    }
                }
                if(objProduct.Products_Bundles__r.size() > 0 && i == 0 && objProduct.Package_Inventory__c != 'Available'){
                    objProduct.Package_Inventory__c = 'Available';
                } else if(objProduct.Products_Bundles__r.size() <= 0 && objProduct.Package_Inventory__c != null) {
                    objProduct.Package_Inventory__c = null;
                } else if(String.valueOf(tempPackageInventory) != objProduct.Package_Inventory__c) {
                    objProduct.Package_Inventory__c = String.valueOf(tempPackageInventory);
                }
                if(objProduct.Package_Inventory__c != oldPackageInventory){
                    isProductUpdate = true;
                }
                if(avgDecimal != objProduct.Package_Average_Cost__c) {
                    objProduct.Package_Average_Cost__c = avgDecimal;
                    isProductUpdate = true;
                }
                
                if(isProductUpdate) {
                    lstUpdateProducts.add(objProduct);
                }
            }
        }
        
        if(lstUpdateProducts.size() > 0){
            Utility.processRecords(lstUpdateProducts, 'update');
        }
    }
    
    /**
    * @description Create entry of Deleted ProductBundles in "Deleted Record" Object
    * @author jagrawal@addonblue.com | 5/15/2020 
    * @param oldList 
    * @return void 
    **/
    private void captureDeletedProductBundles(List<Products_Bundle__c> oldProductBundleList) {
        //try {
            Utility.processDeletedRecords(oldProductBundleList);
        //}
        //catch(Exception ex){
          //  System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            //Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        //}
    }
}
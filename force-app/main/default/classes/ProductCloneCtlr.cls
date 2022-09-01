/**
* @File Name          : ProductCloneCtlr.cls
* @Description        : 
* @Author             : jthakkar@addonblue.com
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 9/6/2020, 2:59:15 pm
* @Modification Log   : 
* Ver       Date            Author              Modification
* 1.0    4/10/2020   jthakkar@addonblue.com     Initial Version
**/
public class ProductCloneCtlr {
    
    public static Product2 oldpackRecord; //FETCHING THE OLD RECORD VALUES BEFORE CLONING PRODUCT
    public static Product2 newPackRecord; //USED TO HANDLE THE NEW VALUES AFTER CLONING PRODUCT
    public static List<Package_Products__c> oldPackProdRecords; //FETCHING THE OLD RECORD VALUES BEFORE CLONING PRODUCT PACKAGE RECORD
    public static List<Package_Products__c> newPackProdRecords; //USED TO HANDLE THE NEW VALUES AFTER CLONING PRODUCT PACKAGE RECORD
    public static List<Products_Bundle__c> newProdBundleRecords; //USED TO HANDLE THE NEW VALUES AFTER CLONING PRODUCT BUNDLES RECORD
    public static List<PricebookEntry> newPricebookentries;
    public string errorMessage='This Product name already exists. Please choose a unique name.';
    
    //FETCHING THE OLD RECORD VALUES FOR CLONING FUNCTIONALITY AND INSERTING THE NEW CLONED RECORD
    
    /**
    * @description  : Method for returning the base Url of the environment
    * @author       : jthakkar@addonblue.com
    * @param        : 
    * @return       : String
    **/    
    @AuraEnabled
    public static String fetchBaseUrl() {
        String sfurl = String.valueof(URL.getSalesforceBaseUrl().toExternalForm());
        system.debug('###'+sfurl);
        return sfurl;
    }
    
    /**
    * @description  : Method for cloning the Product
    * @author       : jthakkar@addonblue.com
    * @param        : Product Id
    * @return       : String
    **/
    @AuraEnabled
    public static String fetchPackageValues(String productId){
        Savepoint sp = Database.setSavepoint();
        try{            
            newPackProdRecords = new List<Package_Products__c>();
            newProdBundleRecords = new List<Products_Bundle__c>();
            newPricebookentries = new List<PricebookEntry>();
            // Get all fields of Product2
            Map<String, Schema.SObjectField> fieldMap = Product2.sObjectType.getDescribe().fields.getMap();
            // Get all of the fields on the object
            Set<String> fieldNames = fieldMap.keySet();
            // Build a Dynamic Query 
            String soqlQuery = 'SELECT ' + String.join(new List<String>(fieldNames), ',') + ' FROM Product2 Where Id =: productId Limit 1';
            oldPackRecord = Database.query(soqlQuery);
            system.debug('###'+oldPackRecord.Id);
            // Clone old record
            newPackRecord = new Product2();
            newPackRecord = oldPackRecord.clone(false, true);
            newPackRecord.Name = 'Copy-'+oldPackRecord.Name;
            newPackRecord.API__C = false;
            newPackRecord.Legacy_ID__c = ''; 
			newPackRecord.Total_Inventory__c= null;
			newPackRecord.Total_Ordered_Quantity__c= null;
            			
            Utility.processRecords(newPackRecord, 'insert');
            
            // Copy products from Bundle Products
            List<Products_Bundle__c> lstProductBundle = [select Id, Name, Child_Product_Record_Type__c, Child_product__c, Parent_Product__c, Type__c from Products_Bundle__c where Parent_Product__c =: productId];
            system.debug('###lstProductBundle=='+lstProductBundle);
            if(lstProductBundle.size() > 0) {
                for(Products_Bundle__c obj : lstProductBundle) {
                    Products_Bundle__c objClone = obj.clone(false, true);
                    objClone.Parent_Product__c = newPackRecord.Id;
                    newProdBundleRecords.add(objClone);
                }
                Utility.processRecords(newProdBundleRecords, 'insert');
            }
            
            return newPackRecord.Id;
            
        } catch(Exception e) {
            Database.rollback(sp);
            return 'ERROR';
        }    
    }
}
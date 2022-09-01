/**
 * @File Name          : RL_Package_Hotels_LEX.cls
 * @Description        : 
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 15/6/2020, 12:03:12 pm
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    25/03/2020   fsuraitawala@addonblue.com     Initial Version
**/
public class RL_Product_Packages_LEX {
    
    /**
    * @description  : This method return list of Package Product.
    * @author       : fsuraitawala@addonblue.com
    * @param        : currentRecordId(Current Record Id)
    * @return       : List<productListWrapper>
    **/
    @AuraEnabled 
    public static List<SW_Utility_LEX.productListWrapper> fetchProductWrapper(String currentRecordId) {
        Set<Id> setParentProductIds = new Set<Id>();
        
        Set<Id> recordTypeIds = new Set<Id>();
        recordTypeIds.add(Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId());
        
        Product2 CurrentProduct = new Product2();
        String strPriceBookId = '';
        if(String.isNotBlank(currentRecordId)) {
            CurrentProduct = [SELECT Id, Name, Primary_Price_Book__c FROM Product2 WHERE Id = :currentRecordId];
            if(CurrentProduct.Primary_Price_Book__c != null) {
                strPriceBookId = CurrentProduct.Primary_Price_Book__c;
            }
            
            for(Products_Bundle__c objPB: getAllProductsBundles(currentRecordId)) {
                setParentProductIds.add(objPB.Parent_Product__c);
            }
        }
        
        List<SW_Utility_LEX.productListWrapper> lstProductListWrapper = new List<SW_Utility_LEX.productListWrapper>();
        if(strPriceBookId != '') {
            List<Product2> products = new List<Product2>();
            products = [Select Id, Name, Product_Type__c, Current_Inventory__c, Package_Inventory__c, RecordTypeId, RecordType.Name, Primary_Price_Book__r.Name 
                        From Product2 
                        WHERE Id != :currentRecordId
                        AND Auto_Generated_Product__c = false
                        AND Id in (Select Product2Id From PricebookEntry where Pricebook2Id = :strPriceBookId AND Product2.RecordTypeId IN :recordTypeIds)];
            for(Product2 objProduct: products) {
                if(setParentProductIds == null || (setParentProductIds != null && !setParentProductIds.contains(objProduct.Id))){
                    lstProductListWrapper.add(new SW_Utility_LEX.productListWrapper(false, objProduct));
                }
            }
        }
        
        return lstProductListWrapper; 
    }
    
    /****************************************************************************/
    @AuraEnabled
    public static List<Products_Bundle__c> getProductsBundles(String currentRecordId) {
         Product2 CurrentProduct = new Product2();
        String strPriceBookId = '';
        if(String.isNotBlank(currentRecordId)) {
            CurrentProduct = [SELECT Id, Name, Primary_Price_Book__c FROM Product2 WHERE Id = :currentRecordId];
            if(CurrentProduct.Primary_Price_Book__c != null) {
                strPriceBookId = CurrentProduct.Primary_Price_Book__c;
            }
        }
        
        return [SELECT Id, Name, Child_product__c, Child_product__r.Name, Parent_Product__c, Parent_Product__r.Name, 
                Child_Product_Record_Type__c, Parent_Product__r.RecordType.Name
                FROM Products_Bundle__c 
                WHERE Child_product__c = :currentRecordId AND (Type__c = 'Package Product') and Parent_Product__r.Primary_Price_Book__c = :strPriceBookId];
    }
    
    /****************************************************************************/
    @AuraEnabled
    public static List<Products_Bundle__c> getAllProductsBundles(String currentRecordId) {
        return [SELECT Id, Name, Child_product__c, Child_product__r.Name, Parent_Product__c, Parent_Product__r.Name, 
                Child_Product_Record_Type__c, Parent_Product__r.RecordType.Name
                FROM Products_Bundle__c 
                WHERE Child_product__c = :currentRecordId AND Type__c = 'Package Product'];
    }
    
    /****************************************************************************/
    @AuraEnabled
    public static List<Products_Bundle__c> AddProductsBundles(List<SW_Utility_LEX.productListWrapper> selectedProduct, String parentProductId) {
        if(parentProductId != null && selectedProduct != null){
            List<Products_Bundle__c> insertPBs = new List<Products_Bundle__c>();
            
            for(SW_Utility_LEX.productListWrapper objWrp: selectedProduct){
                if(objWrp.isChecked){
                    Products_Bundle__c newPB = new Products_Bundle__c();
                    newPB.Child_product__c = parentProductId;
                    newPB.Parent_Product__c = objWrp.objProduct.Id;
                    newPB.Type__c = 'Package Product';
                    insertPBs.add(newPB);
                }
            }
            
            if(insertPBs != null && insertPBs.size() > 0) {
                Utility.processRecords(insertPBs, 'insert');
            }
            
            return getProductsBundles(parentProductId);
        }
        return null;
    }
}
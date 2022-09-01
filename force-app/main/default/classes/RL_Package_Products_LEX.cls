/**
 * @File Name          : RL_Package_Products_LEX.cls
 * @Description        : 
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/8/2020, 4:03:06 AM
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    25/03/2020   fsuraitawala@addonblue.com     Initial Version
**/
public class RL_Package_Products_LEX {
    
    /****************************************************************************/
    @AuraEnabled 
    public static List<SW_Utility_LEX.productListWrapper> fetchProductWrapper(String currentRecordId) {
        Set<Id> setChildProductIds = new Set<Id>();
        
        Set<Id> recordTypeIds = new Set<Id>();
        recordTypeIds.add(Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId());
        
        Product2 CurrentProduct = new Product2();
        String strPriceBookId = '';
        if(String.isNotBlank(currentRecordId)) {
            CurrentProduct = [SELECT Id, Name, Primary_Price_Book__c FROM Product2 WHERE Id = :currentRecordId];
            if(CurrentProduct.Primary_Price_Book__c != null) {
                strPriceBookId = CurrentProduct.Primary_Price_Book__c;
            }
            
            for(Products_Bundle__c objPB: getAllProductsBundles(currentRecordId)) {
                setChildProductIds.add(objPB.Child_product__c);
            }
        }
        
        List<SW_Utility_LEX.productListWrapper> lstProductListWrapper = new List<SW_Utility_LEX.productListWrapper>();
        if(strPriceBookId != '') {
            List<Product2> products = new List<Product2>();
            products = [Select Id, Name, Product_Type__c, Current_Inventory__c, Package_Inventory__c, RecordTypeId, RecordType.Name, Primary_Price_Book__r.Name
                        From Product2 
                        WHERE RecordTypeId IN :recordTypeIds 
                              AND Id != :currentRecordId
                              AND Auto_Generated_Product__c = false
                              AND Id in (Select Product2Id From PricebookEntry where Pricebook2Id = :strPriceBookId)];
            
            for(Product2 objProduct: products) {
                if(setChildProductIds == null || (setChildProductIds != null && !setChildProductIds.contains(objProduct.Id))){
                    lstProductListWrapper.add(new SW_Utility_LEX.productListWrapper(false,objProduct));
                } else if(setChildProductIds != null && setChildProductIds.contains(objProduct.Id)){
                    //lstProductListWrapper.add(new productListWrapper(true,objProduct));
                }
            }
        }
        
        return lstProductListWrapper; 
    }
    
    /****************************************************************************/
    @AuraEnabled
    public static List<Products_Bundle__c> getProductsBundles(String currentRecordId) {
        return [SELECT Id, Name, Child_product__c, Child_product__r.Name, Parent_Product__c, Child_Product_Record_Type__c 
                FROM Products_Bundle__c 
                WHERE Parent_Product__c = :currentRecordId AND (Type__c = 'Package Product')];
    }
    
    /****************************************************************************/
    @AuraEnabled
    public static List<Products_Bundle__c> getAllProductsBundles(String currentRecordId) {
        return [SELECT Id, Name, Child_product__c, Child_product__r.Name, Parent_Product__c, Child_Product_Record_Type__c 
                FROM Products_Bundle__c 
                WHERE Parent_Product__c = :currentRecordId AND (Type__c = 'Package Product' OR Type__c = 'Package Hotel' OR Type__c = 'Addon')];
    }
    
    /****************************************************************************/
    @AuraEnabled
    public static List<Products_Bundle__c> AddProductsBundles(List<SW_Utility_LEX.productListWrapper> selectedProduct, String parentProductId) {
        
        if(parentProductId != null && selectedProduct != null){
            List<Products_Bundle__c> insertPBs = new List<Products_Bundle__c>();
            Set<Id> setChildProduct = new Set<Id>();
            
            for(Products_Bundle__c obj : [SELECT Id, Name, Child_product__c FROM Products_Bundle__c 
                                          WHERE Parent_Product__c = :parentProductId AND Type__c = 'Addon']){
                if(obj.Child_product__c != null) {
                    setChildProduct.add(obj.Child_product__c);
                }
            }
            
            String strExsitingProduct = '';
            
            for(SW_Utility_LEX.productListWrapper objWrp: selectedProduct){
                if(objWrp.isChecked){
                    if(setChildProduct != null && setChildProduct.contains(objWrp.objProduct.Id)){
                        if(strExsitingProduct == ''){
                            strExsitingProduct = objWrp.objProduct.Name;
                        } else {
                            strExsitingProduct = strExsitingProduct + ',' + objWrp.objProduct.Name;
                        }
                    }
                    
                    Products_Bundle__c newPB = new Products_Bundle__c();
                    newPB.Child_product__c = objWrp.objProduct.Id;
                    newPB.Parent_Product__c = parentProductId;
                    if(objWrp.objProduct.RecordType.Name == 'Product'){
                         newPB.Type__c = 'Package Product';
                    }
                    if(objWrp.objProduct.RecordType.Name == 'Hotel'){
                         newPB.Type__c = 'Package Hotel';
                    }
                    insertPBs.add(newPB);
                }
            }
            
            if(strExsitingProduct != '') {
                throw new AuraHandledException(strExsitingProduct + ' : This Product name already select as Addon Product');
            }
            
            if(insertPBs != null && insertPBs.size() > 0) {
                Utility.processRecords(insertPBs, 'insert');
            }
            
            return getProductsBundles(parentProductId);
        }
        return null;
    }
}
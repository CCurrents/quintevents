/**
 * @File Name          : RL_BundleProduct_Table_LEX.cls
 * @Description        : This class use for Product Budle in Pricebook module.
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 11-30-2021
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    12/06/2020   fsuraitawala@addonblue.com     Initial Version
**/
public class RL_BundleProduct_Table_LEX {
    
    /****************************************************************************/
    @AuraEnabled
    public static List<Products_Bundle__c> getProductsBundles(String currentRecordId, String BundleType, Boolean isPackage) {
        Product2 CurrentProduct = new Product2();
        String strPriceBookId = '';
        if(String.isNotBlank(currentRecordId)) {
            CurrentProduct = [SELECT Id, Name, Primary_Price_Book__c FROM Product2 WHERE Id = :currentRecordId];
            if(CurrentProduct.Primary_Price_Book__c != null) {
                strPriceBookId = CurrentProduct.Primary_Price_Book__c;
            }
        }
        
        String sQUERY = 'SELECT Id, Name, Type__c, Child_product__c, Child_product__r.Name, Child_Product_Record_Type__c, Child_product__r.Room_Type__c, Child_product__r.Current_Inventory__c, Child_product__r.Available__c,';
        sQuery += 'Parent_Product__c, Parent_Product__r.Name, Parent_Product__r.RecordType.Name, Parent_Product__r.Package_Inventory__c, Parent_Product__r.Available__c FROM Products_Bundle__c';
        sQuery += ' WHERE Type__c = :BundleType';
        
        if(isPackage && (BundleType == 'Package Hotel' || BundleType == 'Package Product')) {
            sQuery += ' AND Child_product__c = :currentRecordId';
        } else {
            sQuery += ' AND Parent_Product__c = :currentRecordId';
        }
        if(BundleType == 'Hotel Transportation') {
            sQuery += ' AND Child_product__r.Type__c = \'Transportation\' AND Child_product__r.RecordType.Name = \'Product\'';
        }
        system.debug('@@@sQuery :'+sQuery);
        return Database.query(sQuery);
    }
    
    /****************************************************************************/
    @AuraEnabled
    public static List<Products_Bundle__c> deleteBundleProductRecords(String currentRecordId, String BundleType, Boolean isPackage, List<Products_Bundle__c> lstBundleProducts) {
        if(lstBundleProducts.size() > 0) {
            delete lstBundleProducts;
        }
        
        return getProductsBundles(currentRecordId,BundleType, isPackage);
    }
    
}
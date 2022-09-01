/**
 * @File Name          : RL_PriceBookProducts_LEX.cls
 * @Description        : This class use for Related List Components of Pricebook.
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 04-30-2021
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0      03/16/2020  fsuraitawala@addonblue.com  Initial Version
 * 2.0      11/25/2020  fsuraitawala@addonblue.com  #609 Add Available Checkbox as coloumn to Products Tab
**/
public class RL_PriceBook_Products_LEX {
    
    /**
    * @description  : This method return list of recordtype of Product Object.
    * @author       : fsuraitawala@addonblue.com
    * @param        : currentPricebookId(Current Pricebook Id)
    * @return       : List<Pricebook2>
    **/
    @AuraEnabled
    public static List<Pricebook2> getActivePriceBooks(String currentPricebookId) {
        return [SELECT Id, Name, IsActive FROM Pricebook2 
                WHERE IsActive = true AND Id != :currentPricebookId ORDER BY Name ASC];  
    }
    
    /**
    * @description  : This method return list of recordtype of Product Object.
    * @author       : fsuraitawala@addonblue.com
    * @param        : 
    * @return       : List<RecordType>
    **/
    @AuraEnabled
    public static List<RecordType> getListOfRecordType() {
        List<RecordType> rtNames = new List<RecordType>();
        
        rtNames.add(new RecordType(Id = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId(), Name = 'Package'));
        rtNames.add(new RecordType(Id = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId(), Name = 'Product'));
        rtNames.add(new RecordType(Id = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotel').getRecordTypeId(), Name = 'Hotel'));
        rtNames.add(new RecordType(Id = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotel Stay').getRecordTypeId(), Name = 'Hotel Stay'));
        
        return rtNames;  
    }
    
    /**
    * @description  : This method return list of PricebookEntry of related PricebookEntry.
    * @author       : fsuraitawala@addonblue.com
    * @param        : currentRecordId(Current Record Id)
    * @return       : List<PricebookEntry>
    **/
    @AuraEnabled
    public static List<PricebookEntry> getPricebookEntry(String currentRecordId) {
        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
        
        if(currentRecordId != null && currentRecordId != '') {
            set<String> setProduct2Id = new set<String>();
            for(PricebookEntry obj: [SELECT Id, Name, Pricebook2Id, Product2Id, Product2.Name, Product2.RecordType.Name, Product2.Primary_Price_Book__r.Name, Product2.Room_Type__c,
                                     Product2.CurrencyIsoCode, Product2.Price__c, Product2.Type__c, Product2.Current_Inventory__c, 
                                     Product2.Package_Inventory__c, Product2.IsActive, Product2.Available__c, UnitPrice, IsActive, UseStandardPrice, ProductCode
                                     FROM PricebookEntry Where Product2.Primary_Price_Book__c = :currentRecordId
                                     AND Product2.RecordType.Name != 'Products' AND Product2.RecordType.Name != 'Hotels' 
                                     AND Product2.RecordType.Name != 'Stay']) {
                if(!setProduct2Id.contains(obj.Product2Id)) {
                    lstPricebookEntry.add(obj);
                    setProduct2Id.add(obj.Product2Id);
                }
            }
        }
        
        return lstPricebookEntry;
    }
    
    /**
    * @description  : This method return list of PricebookEntry of related PricebookEntry.
    * @author       : fsuraitawala@addonblue.com
    * @param        : currentRecordId(Current Record Id)
    * @return       : List<PricebookEntry>
    **/
    @AuraEnabled
    public static List<PricebookEntry> getPricebookEntryForExistingList(String currentRecordId) {
        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
        
        if(currentRecordId != null && currentRecordId != '') {
            set<String> setProduct2Id = new set<String>();
            for(PricebookEntry obj: [SELECT Id, Name, Pricebook2Id, Product2Id, Product2.Name, Product2.RecordType.Name, Product2.Primary_Price_Book__r.Name, 
                                     Product2.CurrencyIsoCode, Product2.Price__c, Product2.Type__c, Product2.Current_Inventory__c, 
                                     Product2.Package_Inventory__c, Product2.IsActive, Product2.Available__c, UnitPrice, IsActive, UseStandardPrice, ProductCode
                                     FROM PricebookEntry 
                                     WHERE Pricebook2Id = :currentRecordId AND Product2.Primary_Price_Book__c != :currentRecordId
                                     AND Product2.RecordType.Name != 'Products' AND Product2.RecordType.Name != 'Hotels' 
                                     AND Product2.RecordType.Name != 'Stay']) {
                if(!setProduct2Id.contains(obj.Product2Id)) {
                    lstPricebookEntry.add(obj);
                    setProduct2Id.add(obj.Product2Id);
                }
            }
        }
        
        return lstPricebookEntry;
    }
    
    /**
    * @description  : 
    * @author       : fsuraitawala@addonblue.com
    * @param        : PriceBookRecordId(Selected PriceBook Record Id), currentPricebookId(Current Pricebook Record Id)
    * @return       : List<SW_Utility_LEX.productListWrapper>
    **/
    @AuraEnabled 
    public static List<SW_Utility_LEX.productListWrapper> fetchProductWrapper(String PriceBookRecordId, String currentPricebookId) {
        Set<String> setIds = new Set<String>();
        Set<String> setProductName = new Set<String>();
        List<PricebookEntry> lst = new List<PricebookEntry>([SELECT Id, Name, Pricebook2Id, Product2Id, Product2.Name, Product2.Primary_Price_Book__r.Name, UnitPrice, IsActive, UseStandardPrice, ProductCode 
                                    FROM PricebookEntry Where Pricebook2Id = :currentPricebookId]);
        
        for(PricebookEntry obj: lst) {
            setIds.add(obj.Product2Id);
            setProductName.add(obj.Product2.Name);
        }
        
        List<SW_Utility_LEX.productListWrapper> lstProductListWrapper = new List<SW_Utility_LEX.productListWrapper>();
        
        List<Product2> lstProduct = new List<Product2>([Select Id, Name, Product_Type__c, Current_Inventory__c, RecordTypeId, Price__c, Primary_Price_Book__c From Product2 Where Primary_Price_Book__c = :PriceBookRecordId]);
        
        for(Product2 objProduct : lstProduct) {
            if(!(setIds.contains(objProduct.Id) || setProductName.contains(objProduct.Name))) {
                lstProductListWrapper.add(new SW_Utility_LEX.productListWrapper(false,objProduct));
            }
        }
        
        return lstProductListWrapper;
    }
    
    /**
    * @description  : 
    * @author       : fsuraitawala@addonblue.com
    * @param        : PriceBookRecordId, SelectedProduct
    * @return       : List<SW_Utility_LEX.productListWrapper>
    **/
    @AuraEnabled 
    public static List<PricebookEntry> SaveProductRecords(String PriceBookRecordId, List<SW_Utility_LEX.productListWrapper> SelectedProduct) {
        
        Map<string, double> isoCodeMap = new Map<string, double>();
        for(DatedConversionRate d : [SELECT Id, ConversionRate, IsoCode, StartDate FROM DatedConversionRate ORDER BY StartDate DESC]) {                    
            if(!isoCodeMap.containskey(d.IsoCode)) {
                isoCodeMap.put(d.IsoCode, d.ConversionRate);
            }
        }
        
        List<PricebookEntry> insertPBE = new List<PricebookEntry>();
        Set<String> setProductName = new Set<String>();
        
        for(PricebookEntry obj: [SELECT Id, Name, Pricebook2Id, Product2Id, Product2.Name, Product2.Primary_Price_Book__r.Name, UnitPrice, IsActive, UseStandardPrice, ProductCode 
                                 FROM PricebookEntry Where Pricebook2Id = :PriceBookRecordId]) {
            setProductName.add(obj.Product2.Name);
        }
        String strExsitingProduct = '';
        for(SW_Utility_LEX.productListWrapper obj: SelectedProduct) {
            if(setProductName.contains(obj.objProduct.Name)){
                if(strExsitingProduct == ''){
                    strExsitingProduct = obj.objProduct.Name;
                } else {
                    strExsitingProduct = strExsitingProduct + ',' + obj.objProduct.Name;
                }
                
            }
        }
        
        if(strExsitingProduct != '') {
            throw new AuraHandledException(strExsitingProduct + ' : This Product name already exists. Please choose a another Product.');
        }
        
        for(SW_Utility_LEX.productListWrapper obj: SelectedProduct) {
            if(obj.objProduct != null) {
                for(CurrencyType currencys :  [SELECT Id, ISOCode, ConversionRate, IsCorporate FROM CurrencyType WHERE IsActive=TRUE]) {
                    PricebookEntry objPriceBook = new PricebookEntry(unitprice = isoCodeMap.get(currencys.ISOCode) * obj.objProduct.Price__c, 
                                                                     Product2Id = obj.objProduct.Id, 
                                                                     Pricebook2Id = PriceBookRecordId, 
                                                                     isActive=true, 
                                                                     UseStandardPrice = false,
                                                                     CurrencyIsoCode = currencys.ISOCode);
                    insertPBE.add(objPriceBook);
                }
                
            }
        }
        
        if(insertPBE != null && insertPBE.size() > 0) {
            insertPBE = Utility.processRecords(insertPBE, 'insert');
            
            /***** Custom Price Book Entry *****/
            List<Price_Book_Entry_Custom__c> lstCustomPBE = new List<Price_Book_Entry_Custom__c>();
            for(PricebookEntry objPBE: insertPBE) {
                Price_Book_Entry_Custom__c objCustomPBE = new Price_Book_Entry_Custom__c();
                objCustomPBE.CurrencyIsoCode = objPBE.CurrencyIsoCode;
                objCustomPBE.Price_Book__c = objPBE.Pricebook2Id;
                objCustomPBE.Price_Book_Entry_Id__c = objPBE.Id;
                objCustomPBE.Product__c = objPBE.Product2Id;
                lstCustomPBE.add(objCustomPBE);
            }
            
            Utility.processRecords(lstCustomPBE, 'insert');
        }
        
        return getPricebookEntryForExistingList(PriceBookRecordId);
    }
}
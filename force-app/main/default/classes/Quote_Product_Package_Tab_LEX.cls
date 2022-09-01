/**
 * @File Name          : Quote_Product_Package_LEX.cls
 * @Description        : This class use for Package Tab in Sales Wizard.
 * @Author             : fsuraitawalal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 04-19-2021
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    15/10/2019   fsuraitawalal@addonblue.com     Initial Version
 * 1.1    04/10/2020    jagrawal@addonblue.com          Added code to populate Product2Id while QLI creation
**/
public class Quote_Product_Package_Tab_LEX {
    
    /****************************************************************************/
    @AuraEnabled 
    public static List<PricebookEntry> getProductRecords(String currentRecordId) {
        Quote objQuote = new Quote();
        if(currentRecordId != null && currentRecordId.startswith('0Q0')) {
            objQuote = [Select Id, CurrencyIsoCode, OpportunityId, Opportunity.CurrencyIsoCode, PriceBook2Id 
                        FROM Quote WHERE Id = :currentRecordId];
            
            List<PricebookEntry> lstPBE = [SELECT Id, Name, Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice, IsActive,
                                           Product2.Recordtype.Name, Product2.Current_Inventory__c, Product2.Package_Inventory__c, Product2.Available__c
                                           FROM PricebookEntry 
                                           WHERE Pricebook2Id = :objQuote.Pricebook2Id AND CurrencyIsoCode = :objQuote.CurrencyIsoCode 
                                           AND Product2.Recordtype.Name = 'Package' AND Product2.IsActive = true AND IsActive = true];
            
            return lstPBE;
        }
        return null;
    }
    
    /****************************************************************************/
    @AuraEnabled 
    public static PricebookEntry validateUpDownProduct(String ProductId, String currentQuoteId) {
        
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            Quote objQuote = new Quote();
            Product2 objProduct = new Product2();
            
            objQuote = [Select Id, CurrencyIsoCode, OpportunityId, Opportunity.CurrencyIsoCode, PriceBook2Id 
                        FROM Quote WHERE Id = :currentQuoteId];
            
            if(ProductId != null && ProductId.startswith('01t')){
                objProduct = [Select Id, Primary_Price_Book__c FROM Product2 WHERE Id = :ProductId];
            }
            if(objQuote != null && objProduct != null && objQuote.PriceBook2Id == objProduct.Primary_Price_Book__c){
                PricebookEntry objPBE = [SELECT Id, Name, Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice, IsActive, Product2.Recordtype.Name 
                                           FROM PricebookEntry 
                                           WHERE Pricebook2Id = :objQuote.Pricebook2Id AND CurrencyIsoCode = :objQuote.CurrencyIsoCode 
                                           AND Product2Id = :objProduct.Id Limit 1];
               return objPBE;
            } else {
                throw new AuraHandledException('Pricebook is not same for Upgraded Product.');
            }
            
        }
        
        return null;
    }
    
    /****************************************************************************/
    @AuraEnabled 
    public static PricebookEntryClass getProductById(String ProductId, String currentQuoteId) {
        PricebookEntryClass objBundleClass = new PricebookEntryClass();
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            Quote objQuote = new Quote();
            PricebookEntry objProduct = new PricebookEntry ();
            Set<Id> setProductIds = new set<Id>();
            objQuote = [Select Id, CurrencyIsoCode, OpportunityId, Opportunity.CurrencyIsoCode, PriceBook2Id 
                        FROM Quote WHERE Id = :currentQuoteId];
            
            objProduct = [Select Id, Name, Product2.RecordType.Name, Product2.CurrencyIsoCode, Product2.Price__c, 
                          Product2.Upgrade__c, Product2.Upgrade__r.Name, Product2.Upgrade__r.Price__c, Product2.Upgrade__r.CurrencyIsoCode,
                          Product2.Downgrade__c, Product2.Downgrade__r.Name, Product2.Downgrade__r.Price__c, Product2.Downgrade__r.CurrencyIsoCode
                          From PricebookEntry WHERE Id = :ProductId];
            objBundleClass.currentPBE = objProduct;
                
            if(objProduct.Product2.Upgrade__c != null){
                setProductIds.add(objProduct.Product2.Upgrade__c);
            }
            if(objProduct.Product2.Downgrade__c!= null){
                setProductIds.add(objProduct.Product2.Downgrade__c);
            }
            
            if(setProductIds != null && setProductIds.size() > 0){
                for(PriceBookEntry obj: [Select Id, Name, Product2.Name, CurrencyIsoCode, UnitPrice, Product2.RecordType.Name, Product2.CurrencyIsoCode, Product2.Price__c
                                         From PricebookEntry WHERE Product2Id IN :setProductIds AND CurrencyIsoCode = :objQuote.CurrencyIsoCode
                                         AND PriceBook2Id = :objQuote.PriceBook2Id]){
                    if(objProduct.Product2.Upgrade__c != null && objProduct.Product2.Upgrade__c == obj.Product2Id){
                        objBundleClass.upgradePBE = obj;
                    }
                    
                    if(objProduct.Product2.Downgrade__c != null && objProduct.Product2.Downgrade__c == obj.Product2Id){
                        objBundleClass.downgradePBE = obj;
                    }
                }
                
            }
        }
        return objBundleClass;
    }
    
    /****************************************************************************/
    @AuraEnabled 
    public static QuoteLineItem updateLineItemRecords(QuoteLineItem PackageLineItem) {
        
        if(PackageLineItem != null && PackageLineItem.Id != null) {
            update PackageLineItem;
            
            List<QuoteLineItem> childQLIs = new List<QuoteLineItem>();
            childQLIs = [Select Id, Quantity From QuoteLineItem WHERE Quote_Package__c = :PackageLineItem.Id AND Record_Type__c = 'Package Product'];
            
            for(QuoteLineItem obj: childQLIs) { obj.Quantity = PackageLineItem.Quantity; }
            
            if(childQLIs.size() > 0) { update childQLIs; }
            
            return PackageLineItem;
        }
        return null;
    }
    
    /****************************************************************************/
    @AuraEnabled 
    public static QuoteLineItem saveLineItemRecords(String currentQuoteId, Integer quantity, PriceBookEntry selectedPriceBookEntry) {
        
        Quote objQuote = new Quote();
        List<QuoteLineItem> lstChildQLI = new List<QuoteLineItem>();
        
        try {
            if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
                objQuote = getCurrentQuote(currentQuoteId);
                
                if(objQuote != null && selectedPriceBookEntry != null) {
                    
                    QuoteLineItem newParentQLI = new QuoteLineItem();
                    newParentQLI.QuoteId = currentQuoteId;
                    newParentQLI.Quantity = quantity;
                    newParentQLI.UnitPrice = 0;
                    newParentQLI.PriceBookEntryId = selectedPriceBookEntry.Id;
                    newParentQLI.Record_Type__c = 'Package';
                    
                    insert newParentQLI;
                    
                    if(selectedPriceBookEntry.Product2Id != null) {
                        Set<Id> setIds = new Set<Id>();
                        
                        for(Products_Bundle__c obj: getProductsBundles(selectedPriceBookEntry.Product2Id)) { setIds.add(obj.Child_product__c); }
                        
                        if(setIds != null && setIds.size() > 0) {
                            for(PricebookEntry obj: [SELECT Id, Product2Id FROM PricebookEntry 
                                                     WHERE Pricebook2Id = :objQuote.Pricebook2Id 
                                                     AND CurrencyIsoCode = :objQuote.CurrencyIsoCode 
                                                     AND Product2Id IN :setIds]) {
                                QuoteLineItem newQLI = new QuoteLineItem();
                                newQLI.QuoteId = currentQuoteId;
                                newQLI.Quantity = quantity;
                                newQLI.UnitPrice = 0;
                                newQLI.PriceBookEntryId = obj.Id;
                                newQLI.Record_Type__c = 'Package Product';
                                newQLI.Quote_Package__c = newParentQLI.Id;
                                lstChildQLI.add(newQLI);
                            }
                        }
                    }
                    
                    if(lstChildQLI.size() > 0) { insert lstChildQLI; }
                
                    return getQuoteLineItem(newParentQLI.Id);
                }
            }
        } catch(Exception ex) { throw new AuraHandledException(ex.getMessage()); }
        
        return null;
    }
    
    /****************************************************************************/
    @AuraEnabled
    public static List<Products_Bundle__c> getProductsBundles(String currentRecordId) {
        return [SELECT Id, Name, Child_product__c, Child_product__r.Name, Parent_Product__c, Child_Product_Record_Type__c 
                FROM Products_Bundle__c 
                WHERE Parent_Product__c = :currentRecordId AND Type__c = 'Package Product'];
    }
    
    /****************************************************************************/
    @AuraEnabled
    public static Quote getCurrentQuote(String currentQuoteId) {
        return [Select Id, CurrencyIsoCode, OpportunityId, Opportunity.CurrencyIsoCode, PriceBook2Id from Quote Where Id = :currentQuoteId];
    }
    
    /****************************************************************************/
    @AuraEnabled 
    public static QuoteLineItem getQuoteLineItem(String currentLineItemId) {
        
        if(currentLineItemId != null) {
            return [SELECT Id, LineNumber, QuoteId, PricebookEntryId, PricebookEntry.Name, Quantity, Product2Id, Product2.Name, Product2.RecordType.Name, 
                    Quote_Package__c, Record_Type__c
                    FROM QuoteLineItem WHERE Id = :currentLineItemId];
        }
        return null;
    }
    
    /****************************************************************************/
    public class PricebookEntryClass {
        @AuraEnabled public PricebookEntry currentPBE {get;set;}
        @AuraEnabled public PricebookEntry upgradePBE {get;set;}
        @AuraEnabled public PricebookEntry downgradePBE {get;set;}
        
        public PricebookEntryClass() {
            currentPBE = new PricebookEntry();
            upgradePBE = new PricebookEntry();
            downgradePBE = new PricebookEntry();
        }
    }
}
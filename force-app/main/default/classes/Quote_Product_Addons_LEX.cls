/**
 * @File Name          : Quote_Product_Addons_LEX.cls
 * @Description        : This class use for Addon Tab in Sales Wizard.
 * @Author             : fsuraitawalal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 10-12-2021
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    26/12/2019   fsuraitawalal@addonblue.com     Initial Version
**/
public class Quote_Product_Addons_LEX {
    
    /**
    * @description  : Method for fetch addon products of selected package product
    * @author       : fsuraitawala@addonblue.com
    * @param        : CurrentQuoteId(Quote Id)
    * @param        : PackageLineItemId(Selected Package Product Id)
    * @return       : List<addonListClass>
    **/
    @AuraEnabled 
    public static List<PricebookEntry> getAddonRelatedProduct(String currentQuoteId) {
        
        Set<String> setChildAddons = new Set<String>();
        
        Quote objQuote = new Quote();
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            objQuote = [Select Id, CurrencyIsoCode, OpportunityId, Opportunity.CurrencyIsoCode, PriceBook2Id 
                        FROM Quote WHERE Id = :currentQuoteId];
        }
        
        if(objQuote != null) {
            for(Products_Bundle__c obj: [SELECT Id, Name, Child_product__c, Child_product__r.Name, Parent_Product__c FROM Products_Bundle__c 
                                         WHERE Type__c = 'Addon']) {
                setChildAddons.add(obj.Child_product__c);
            }
            
            if(setChildAddons != null) {
                List<PricebookEntry> lstPBE = [SELECT Id, Name, Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice, IsActive, 
                                               Product2.Recordtype.Name, Product2.Current_Inventory__c, Product2.Available__c 
                                               FROM PricebookEntry 
                                               WHERE Product2Id In :setChildAddons AND CurrencyIsoCode = :objQuote.CurrencyIsoCode 
                                               AND Pricebook2Id = :objQuote.Pricebook2Id AND Product2.Recordtype.Name = 'Product'
                                               AND Product2.IsActive = true AND IsActive = true];
                return lstPBE;
            }
        }
        
        return null;
    }
    
    /**
    * @description  : Method for fatch saved addon lineItems
    * @author       : fsuraitawala@addonblue.com
    * @param        : CurrentQuoteId(Quote Id)
    * @param        : PackageLineItemId(Selected Package Product Id)
    * @return       : List<addonListClass>
    **/
    @AuraEnabled 
    public static List<SW_Utility_LEX.addonListClass> getAddonLineItems(String ParentPackageId, String currentQuoteId) {
        
        List<SW_Utility_LEX.addonListClass> lstAddon = new List<SW_Utility_LEX.addonListClass>();
        
        for(QuoteLineItem obj: [SELECT Id, PricebookEntryId, PricebookEntry.Name, Quantity, Quote_Package__c, Record_Type__c FROM QuoteLineItem 
                                WHERE QuoteId = :currentQuoteId AND Quote_Package__c = :ParentPackageId AND Record_Type__c = 'Addon' ORDER BY CreatedDate]) {
            SW_Utility_LEX.addonListClass objAddon = new SW_Utility_LEX.addonListClass();
            objAddon.QuoteLineItem = obj;
            objAddon.ProductName = obj.PricebookEntry.Name;
            lstAddon.add(objAddon);
        }
        
        return lstAddon;
    }
    
    
    /**
    * @description  : Method for insert/update addon products
    * @author       : fsuraitawala@addonblue.com
    * @param        : CurrentQuoteId(Quote Id)
    * @param        : QuoteLineItems(List of LineItems)
    * @param        : PackageLineItemId(Selected Package Product Id)
    * @return       : List<addonListClass>
    **/
    @AuraEnabled 
    public static List<SW_Utility_LEX.addonListClass> saveLineItems(String CurrentQuoteId, List<SW_Utility_LEX.addonListClass> QuoteLineItems, String PackageLineItemId){
        
        List<QuoteLineItem> lstAddonItems = new List<QuoteLineItem>();
        
        try {
            if(QuoteLineItems.size() > 0) {
                for(SW_Utility_LEX.addonListClass obj: QuoteLineItems) {
                    if(obj.QuoteLineItem.Id == null) {
                        obj.QuoteLineItem.QuoteId = currentQuoteId;
                        obj.QuoteLineItem.Quote_Package__c = PackageLineItemId;
                        obj.QuoteLineItem.Record_Type__c = 'Addon';
                        obj.QuoteLineItem.UnitPrice = 0;
                    }
                    lstAddonItems.add(obj.QuoteLineItem);
                }
                upsert lstAddonItems;
            }
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
        return getAddonLineItems(PackageLineItemId,CurrentQuoteId);
    }
}
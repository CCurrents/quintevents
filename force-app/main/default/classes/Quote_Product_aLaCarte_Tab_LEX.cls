/**
 * @File Name          : Quote_Product_aLaCarte_Tab_LEX.cls
 * @Description        : This class use for a La Carte Tab in Sales Wizard.
 * @Author             : fsuraitawalal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 10-12-2021
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    15/10/2019   fsuraitawalal@addonblue.com     Initial Version
**/
public class Quote_Product_aLaCarte_Tab_LEX {
    
    /**
    * @description  : Method for fetch saved A La Carte lineItems of current Quote
    * @author       : fsuraitawala@addonblue.com
    * @param        : CurrentQuoteId(Quote Id)
    * @return       : List<aLaCarteObjClass>
    **/
    @AuraEnabled 
    public static List<SW_Utility_LEX.aLaCarteObjClass> getaLaCarteLineItems(String currentQuoteId) {
        
        List<SW_Utility_LEX.aLaCarteObjClass> lstLaCarte = new List<SW_Utility_LEX.aLaCarteObjClass>();
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            for(QuoteLineItem obj: [SELECT Id, PricebookEntryId, PricebookEntry.Name, Quantity, Quote_Package__c, Record_Type__c, Product2.Type__c
                                    FROM QuoteLineItem WHERE QuoteId = :currentQuoteId AND Record_Type__c = 'A La Carte' AND Product2.A_La_Carte__c = true 
                                    AND Product2.Type__c != 'Shipping and Handling' AND Product2.Recordtype.Name = 'Product'
                                    ORDER BY CreatedDate]) {
                SW_Utility_LEX.aLaCarteObjClass objLaCarte = new SW_Utility_LEX.aLaCarteObjClass();
                objLaCarte.QuoteLineItem = obj;
                objLaCarte.ProductName = obj.PricebookEntry.Name;
                objLaCarte.ProductType = obj.Product2.Type__c;
                lstLaCarte.add(objLaCarte);
            }
        }
        return lstLaCarte;
    }
    
    /**
    * @description  : Method for get Product Type option from schema object
    * @author       : fsuraitawala@addonblue.com
    * @param        : 
    * @return       : List<customOptionClass>
    **/
    @AuraEnabled 
    public static List<SW_Utility_LEX.customOptionClass> getProductTypeOptions() {
        List<SW_Utility_LEX.customOptionClass> pickListValuesList = new List<SW_Utility_LEX.customOptionClass>();
        SW_Utility_LEX.customOptionClass obj = new SW_Utility_LEX.customOptionClass();
        obj.label = '--None--';
        obj.value = '';
        pickListValuesList.add(obj);
        
        Schema.DescribeFieldResult fieldResult = Product2.Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
            obj = new SW_Utility_LEX.customOptionClass();
            obj.label = pickListVal.getLabel();
            obj.value = pickListVal.getValue();
            pickListValuesList.add(obj);
        }
        return pickListValuesList;
    }
    
    /**
    * @description  : Method for get A La Carte lineItems of selected Product
    * @author       : fsuraitawala@addonblue.com
    * @param        : ParentPackageId(Package Product Id)
    * @param        : CurrentQuoteId(Quote Id)
    * @return       : List<PricebookEntry>
    **/
    @AuraEnabled 
    public static List<PricebookEntry> getaLaCarteRelatedProduct(String currentQuoteId) {
        
        Quote objQuote = new Quote();
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            objQuote = [Select Id, CurrencyIsoCode, OpportunityId, Opportunity.CurrencyIsoCode, PriceBook2Id 
                        FROM Quote WHERE Id = :currentQuoteId];
            
            List<PricebookEntry> lstPBE = [SELECT Id, Name, Pricebook2Id, Product2Id, Product2.Type__c, Product2.Recordtype.Name,
                                           CurrencyIsoCode, UnitPrice, IsActive, Product2.Current_Inventory__c, Product2.Available__c
                                           FROM PricebookEntry 
                                           WHERE Product2.A_La_Carte__c = true AND Product2.Recordtype.Name = 'Product' AND
                                           CurrencyIsoCode = :objQuote.CurrencyIsoCode AND Pricebook2Id = :objQuote.Pricebook2Id
                                           AND Product2.IsActive = true AND IsActive = true];
            return lstPBE;
        }
        
        return null;
    }
    
    /**
    * @description  : Method for insert/update a La Carte products
    * @author       : fsuraitawala@addonblue.com
    * @param        : ParentPackageId(Package Product Id)
    * @param        : CurrentQuoteId(Quote Id)
    * @param        : aLaCarteItems(List of LineItems)
    * @return       : List<aLaCarteObjClass>
    **/
    @AuraEnabled 
    public static List<SW_Utility_LEX.aLaCarteObjClass> saveLineItems(String currentQuoteId, List<SW_Utility_LEX.aLaCarteObjClass> aLaCarteItems) {
        
        Quote objQuote = new Quote();
        List<QuoteLineItem> lstQuoteLineItems = new List<QuoteLineItem>();
        
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            for(SW_Utility_LEX.aLaCarteObjClass obj: aLaCarteItems) {
                
                if(string.isNotblank(obj.QuoteLineItem.PricebookEntryId) && string.isblank(obj.QuoteLineItem.Id)){
                    obj.QuoteLineItem.QuoteId = currentQuoteId;
                    obj.QuoteLineItem.UnitPrice = 0;
                    obj.QuoteLineItem.Record_Type__c = 'A La Carte';
                }
                lstQuoteLineItems.add(obj.QuoteLineItem);
            }
        }
        
        if(lstQuoteLineItems != null && lstQuoteLineItems.size() > 0) {
            lstQuoteLineItems = Utility.processRecords(lstQuoteLineItems, 'upsert');
        }
        return getaLaCarteLineItems(currentQuoteId);
    }
}
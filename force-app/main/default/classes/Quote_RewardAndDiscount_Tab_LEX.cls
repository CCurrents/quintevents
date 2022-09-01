/**
 * @File Name          : Quote_RewardAndDiscount_Tab_LEX.cls
 * @Description        : This class use for RewardAndDiscount Tab in Sales Wizard.
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 01-11-2021
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    15/10/2019   fsuraitawala@addonblue.com     Initial Version
 * 1.1    12/17/2020   jagrawal@addonblue.com         #659 Rewards Discount
**/
public with sharing class Quote_RewardAndDiscount_Tab_LEX {
    
    /*********************************************************************************/
    @AuraEnabled
    public static List<OpportunityContactRole> fetchContactRole(String currentRecordId) {
        System.debug('recordId-->'+currentRecordId);
        Opportunity opp = [Select Id, (Select Id, Contact.Name, Contact.Email, ContactId, Custom_Contact__c, Role, Opportunity.AccountId 
                                       FROM OpportunityContactRoles WHERE Role = 'H4H Rewards Contact') 
                           FROM Opportunity WHERE Id IN (Select OpportunityId from quote where id=: currentRecordId)];
        System.debug(opp.OpportunityContactRoles.size());
        System.debug(opp.OpportunityContactRoles);
        return opp.OpportunityContactRoles;
    }
    
    /*********************************************************************************/
    @AuraEnabled
    public static List<PricebookEntry> getPriceBookEntries(String currentQuoteId) {
        
        List<PricebookEntry> lstPBE = new List<PricebookEntry>();
        Quote objQuote = new Quote();
        
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            objQuote = [Select Id, Opportunity.Pricebook2Id, Pricebook2Id, CurrencyIsoCode FROM Quote where id =: currentQuoteId];
            
            if(objQuote != null) {
                lstPBE = [SELECT Name, Id, Product2Id, IsActive, UnitPrice, Product2.Type__c, Product2.Name FROM PricebookEntry
                          WHERE Product2.Primary_Price_Book__c =: objQuote.Pricebook2Id
                          AND (Product2.Type__c = 'Discount' OR Product2.Type__c = 'Reward Discount')
                          AND Pricebook2Id =: objQuote.Pricebook2Id AND CurrencyIsoCode =: objQuote.CurrencyIsoCode];
            }
        }
        return lstPBE;
    }
    
    /*********************************************************************************/
    @AuraEnabled
    public static SW_Utility_LEX.LineItemBundles getSavedLineItems(String currentQuoteId) {
        System.debug(currentQuoteId);
        SW_Utility_LEX.LineItemBundles SavedLineItems = new SW_Utility_LEX.LineItemBundles();
        SavedLineItems.DiscountLineItem = getDiscountLineItem(currentQuoteId);
        SavedLineItems.RewardLineItem = getRewardLineItem(currentQuoteId);
        
        return SavedLineItems;
    }
    
    /*********************************************************************************/
    @AuraEnabled
    public static SW_Utility_LEX.LineItemBundles saveQuoteLineItem(SW_Utility_LEX.LineItemBundles LineItems, String currentQuoteId, String H4HContactId, Decimal discountAmount, Boolean isUseRewards) {
        System.debug(LineItems);
        System.debug(discountAmount);
        System.debug(H4HContactId);
        System.debug(currentQuoteId);
        // #659 Rewards Discount
        List<Quote> lstQuote = [select Id,CurrencyISOCode,CreatedDate  from Quote where Id =: currentQuoteId];
        List<QuoteLineItem> lstQuoteLineItem = new List<QuoteLineItem>();
        try {
            if(LineItems.DiscountLineItem != null && discountAmount != null) {
                LineItems.DiscountLineItem.UnitPrice = discountAmount * -1;
                lstQuoteLineItem.add(LineItems.DiscountLineItem);
            }
            if(isUseRewards && LineItems.RewardLineItem != null) {
                // #659 Rewards Discount
                Double maxUsablePoints = Double.valueof(getMaxUsablePoints(currentQuoteId));
                Double h4hRewardsPoints = test.isRunningTest() ? 0.0 : getRewardPointsOfContact(H4HContactId);
                System.debug('maxUsablePoints: '+maxUsablePoints);
                System.debug('h4hRewardsPoints: '+h4hRewardsPoints);
                Double rewardPoints = -(h4hRewardsPoints >= maxUsablePoints ? maxUsablePoints : h4hRewardsPoints);
                
                if(lstQuote[0].CurrencyISOCode == 'USD'){
                    LineItems.RewardLineItem.UnitPrice = rewardPoints;
                } else {
                    LineItems.RewardLineItem.UnitPrice = Utility.convert(rewardPoints, lstQuote[0].CurrencyISOCode, Date.valueOf(lstQuote[0].CreatedDate));
                }
                
                lstQuoteLineItem.add(LineItems.RewardLineItem);
            }
            
            System.debug(LineItems.RewardLineItem.UnitPrice);
            System.debug(LineItems.DiscountLineItem.UnitPrice);
            
            System.debug(lstQuoteLineItem);
            if(lstQuoteLineItem.size() > 0) {
                upsert lstQuoteLineItem;
            }
            
            System.debug(lstQuoteLineItem);
            
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getLineNumber()+':'+ex.getMessage());
        }
        return LineItems;
    }
    
    /*********************************************************************************/
    @AuraEnabled
    public static Decimal  getMaxUsablePoints(String currentQuoteId) {
        Set<String> setPackage = new Set<String>();
        Map<String, SW_Utility_LEX.LineItemBundleClass> MapLineItem = new Map<String, SW_Utility_LEX.LineItemBundleClass>();
        
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            for(QuoteLineItem objLineItem: getQuoteLineItems(currentQuoteId)) {
                SW_Utility_LEX.LineItemBundleClass objLineBundle = new SW_Utility_LEX.LineItemBundleClass();
                
                if(objLineItem.Record_Type__c == 'Package' && !objLineItem.Product2.Name.Contains('Deposit')) {
                    objLineBundle.ParentPackage = objLineItem;
                    MapLineItem.put(objLineItem.Id, objLineBundle);
                }
                
                if(String.isNotBlank(objLineItem.Quote_Package__c) && MapLineItem.containsKey(objLineItem.Quote_Package__c)) {
                    objLineBundle = MapLineItem.get(objLineItem.Quote_Package__c);
                    
                    if(objLineItem.Record_Type__c == 'Hotel Transportation' || objLineItem.Record_Type__c == 'Hotel Stay') {
                        objLineBundle.ChildLineItems.add(objLineItem);
                    }
                }
            }
            
            System.debug('MapLineItem: '+MapLineItem);
            
            if(MapLineItem != null && MapLineItem.size() > 0) {
                SW_Utility_LEX.RewardPointsClass objRewardPoints = new SW_Utility_LEX.RewardPointsClass();
                
                Decimal maxUsablePoints = 0;
                Decimal minUsablePoints = 50;
                for(String str: MapLineItem.KeySet()) {
                    SW_Utility_LEX.LineItemBundleClass obj = MapLineItem.get(str);
                    Decimal rewardPoint = 50;
                    if(obj.ParentPackage != null && obj.ChildLineItems.size() > 0) {
                        rewardPoint = 100;
                        minUsablePoints = 100;
                    }
                    maxUsablePoints = maxUsablePoints + (rewardPoint * obj.ParentPackage.Quantity);
                }
                
                objRewardPoints.maxUsablePoints = maxUsablePoints;
                objRewardPoints.minUsablePoints = minUsablePoints;
                
                return maxUsablePoints;
            }
        }
        
        return 0;
    }
    
    /****************************************************************************/
    @AuraEnabled 
    public static List<QuoteLineItem> getQuoteLineItems(String currentQuoteId) {
        
        System.debug(currentQuoteId);
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            return [SELECT Id, LineNumber, QuoteId, PricebookEntryId, PricebookEntry.Name, Quantity, Product2Id, Product2.Name, Product2.RecordType.Name, 
                    Quote_Package__c, Record_Type__c
                    FROM QuoteLineItem WHERE QuoteId = :currentQuoteId ORDER BY CreatedDate];
        }
        return null;
    }
    
    /*********************************************************************************/
    @AuraEnabled
    public static Decimal getRewardPointsOfContact(String SelectedContactId) {
        //Changed by Jheel
        System.debug(SelectedContactId);
        Contact objContact = new Contact();
        objContact = [Select Firstname, lastname, email From Contact Where Id =: SelectedContactId];
        Decimal memberPointsFromRes = H4HUtility.getRewardPointsOfContacts(objContact);
        return memberPointsFromRes;
    }
    
    
    
    /*********************************************************************************/
    @AuraEnabled
    public static QuoteLineItem getDiscountLineItem(String currentQuoteId) {
        QuoteLineItem DiscountLineItem = new QuoteLineItem();
        List<PricebookEntry> lstPBE = new List<PricebookEntry>();
        Quote objQuote = new Quote();
        
        //#508 code change by Fesal for Reward and Discount issue
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            objQuote = [Select Id, Opportunity.Pricebook2Id, Pricebook2Id, CurrencyIsoCode,
                        (SELECT Id, LineNumber, QuoteId, PricebookEntryId, PricebookEntry.Name, Quantity, UnitPrice,
                         Record_Type__c, Description, Discount_Description__c
                         FROM QuoteLineItems
                         WHERE Product2.Type__c = 'Discount' AND Product2.Name = 'Discount' AND Product2.Auto_Generated_Product__c = true )
                        FROM Quote where id =: currentQuoteId];
            
            if(objQuote != null) {
                if(objQuote.QuoteLineItems != null && objQuote.QuoteLineItems.size() > 0) {
                    DiscountLineItem = objQuote.QuoteLineItems[0];
                }
                else {
                    lstPBE = [SELECT Name, Id, Product2Id, IsActive, UnitPrice, Product2.Type__c, Product2.Name FROM PricebookEntry
                              WHERE Product2.Primary_Price_Book__c =: objQuote.Pricebook2Id 
                              AND Product2.Type__c = 'Discount' AND Product2.Name = 'Discount' AND Product2.Auto_Generated_Product__c = true 
                              AND Pricebook2Id =: objQuote.Pricebook2Id AND CurrencyIsoCode =: objQuote.CurrencyIsoCode AND isActive = true];
                    
                    if(lstPBE != null && lstPBE.size() > 0) {
                        DiscountLineItem.QuoteId = objQuote.Id;
                        DiscountLineItem.PriceBookEntryId = lstPBE[0].Id;
                        DiscountLineItem.Quantity = 1;
                        DiscountLineItem.Record_Type__c = 'A La Carte';
                        DiscountLineItem.Discount_Description__c = '';
                        DiscountLineItem.ProductType__c = 'Discount';
                    }
                }
            }
        }
        
        return DiscountLineItem;
    }
    
    /*********************************************************************************/
    @AuraEnabled
    public static QuoteLineItem getRewardLineItem(String currentQuoteId) {
        QuoteLineItem RewardLineItem = new QuoteLineItem();
        List<PricebookEntry> lstPBE = new List<PricebookEntry>();
        Quote objQuote = new Quote();
        
        //#508 code change by Fesal for Reward and Discount issue
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            objQuote = [Select Id, Opportunity.Pricebook2Id, Pricebook2Id, CurrencyIsoCode,
                        (SELECT Id, LineNumber, QuoteId, PricebookEntryId, PricebookEntry.Name, Quantity, UnitPrice, Record_Type__c, Description 
                         FROM QuoteLineItems
                         WHERE Product2.Type__c = 'Reward Discount' AND Product2.Name = 'Reward Discount' AND Product2.Auto_Generated_Product__c = true)
                        FROM Quote where id =: currentQuoteId];
            
            if(objQuote != null) {
                if(objQuote.QuoteLineItems != null && objQuote.QuoteLineItems.size() > 0) {
                    RewardLineItem = objQuote.QuoteLineItems[0];
                }
                else {
                    lstPBE = [SELECT Name, Id, Product2Id, IsActive, UnitPrice, Product2.Type__c, Product2.Name FROM PricebookEntry
                              WHERE Product2.Primary_Price_Book__c =: objQuote.Pricebook2Id AND Product2.Auto_Generated_Product__c = true
                              AND Product2.Name = 'Reward Discount' AND Product2.Type__c = 'Reward Discount'  
                              AND Pricebook2Id =: objQuote.Pricebook2Id AND CurrencyIsoCode =: objQuote.CurrencyIsoCode AND isActive = true];
                    
                    if(lstPBE != null && lstPBE.size() > 0) {
                        RewardLineItem.QuoteId = objQuote.Id;
                        RewardLineItem.PriceBookEntryId = lstPBE[0].Id;
                        RewardLineItem.Quantity = 1;
                        RewardLineItem.Record_Type__c = 'A La Carte';
                        RewardLineItem.ProductType__c = 'Reward Discount';
                        RewardLineItem.UnitPrice = 0;
                    }
                }
            }
        }
        
        return RewardLineItem;
    }
    
    /*********************************************************************************/
    @AuraEnabled
    public static Quote getCurrentQuoteRecord(String currentRecordId) {
        Quote objQuote = new Quote();
        
        if(currentRecordId != null && currentRecordId.startswith('0Q0')) {
            objQuote = [Select Id, Status, Opportunity.Pricebook2Id, Pricebook2Id, Pricebook2.Program__c, 
                        Pricebook2.Program__r.Name, CurrencyIsoCode 
                        FROM Quote 
                        WHERE Id =: currentRecordId];
        }
        
        return objQuote;
    }
}
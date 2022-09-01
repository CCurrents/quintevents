/**
* @File Name          : QuoteLineItemTriggerHelper.cls
* @Description        : 
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              : 
* @Last Modified By   : fsuraitawala@addonblue.com
* @Last Modified On   : 03-02-2022
* @Modification Log   : 
* Ver       Date            Author                  Modification
* 1.0    11/3/2020   jagrawal@addonblue.com     Initial Version
* 1.1    6/9/2020    jagrawal@addonblue.com     Added Conditions before SOQL to reduce unnecessary SOQL
* 1.2    11/13/2020  jagrawal@addonblue.com     #451 Protectgroup Integration
* 1.3    01/11/2021  jagrawal@addonblue.com     #695 Added Retail Hotel Integration Product Type
* 1.4    03/02/2021  fSuraitawala@addonblue.com #744 Shipping fee logic for manual gpe orders
* 1.5    03/08/2021  vshah@addonblue.com         #834 Unit price intact for change orders
* 1.6    04/28/2021  kchavda@addonblue.com       #934 101 soql error for online order
* 1.7    05/28/2021  fSuraitawala@addonblue.com #878 Hide "Quote to Online Order" link from quote for double approval products
* 1.8    07/25/2021  fsuraitawala@addonblue.com #1033 club seacret Price change
* 1.9    10/28/2021  mohit.shishodia@addonblue.com     #1096 Replace 'GPE Online Order' with 'Online order' field
* 1.10   20/01/2022  vaibhav.khopade@addonblue.com     #1144 Display USD price for a product purchased
* 1.11   02/02/2022  vaibhav.khopade@addonblue.com     #1152 Remove Related Rooming List when Hotel Stay Line Item deleted
**/
public class QuoteLineItemTriggerHelper {
    
    private Map<Id, QuoteLineItem> newQuoteLineItemMap; 
    private Map<Id, QuoteLineItem> oldQuoteLineItemMap;
    private List<QuoteLineItem> newQuoteLineItemList;
    private List<QuoteLineItem> oldQuoteLineItemList;
    public Boolean IsQuoteLineItemTrigger = false;
    
    /**
    * @description Constructor to query all data at once and then pass it in the Helper methods for specific Trigger event
    * @author jagrawal@addonblue.com | 11/3/2020 
    * @return void 
    **/
    public QuoteLineItemTriggerHelper(){
        Utility.getSOQLCount();
        Utility.getTriggerSize();
        this.newQuoteLineItemMap = (Map<Id, QuoteLineItem>) Trigger.newMap;
        this.oldQuoteLineItemMap = (Map<Id, QuoteLineItem>) Trigger.oldMap;
        this.newQuoteLineItemList = (List<QuoteLineItem>) Trigger.new;
        this.oldQuoteLineItemList = (List<QuoteLineItem>) Trigger.old;
        
        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
                System.debug('In Before Insert!');
                Set<Id> pricebookEntrySet = new Set<Id>();
                Set<ID> quoteSet = new Set<Id>();
                Set<Id> QLIPriceBookIdSet = new Set<Id>(); //VKHOPADE - issue 1144
                Set<Id> QLIProductIDSet = new Set<Id>();   //VKHOPADE - issue 1144
                
                for(QuoteLineItem objQLI : newQuoteLineItemList){
                    pricebookEntrySet.add(objQLI.PricebookEntryId);
                    System.debug('pricebookEntrySet@@@@'+objQLI.PricebookEntryId);
                    quoteSet.add(objQLI.QuoteId);
                }
                /* Map<Id,PricebookEntry> mapPricebookEntrys = new Map<Id,PricebookEntry>([Select Product2Id, Product2.Price__c, Product2.Cost__c, 
                                                                                        Product2.Tax_Percentage__c, Product2.VAT_Tax__c, Product2.Processing_Fee__c, Product2.Type__c, UnitPrice, Product2.Reward_Points_Percentage__c, Product2.RecordType.Name,
                                                                                        Product2.Shipping_And_Handling__c, Product2.Shipping_And_Handling_Outside_US__c, Pricebook2.Shipping_and_Handling_Fee_Outside_US__c, 
                                                                                        Pricebook2.Shipping_and_Handling_Fee__c, Pricebook2.Tax_Percentage__c, Pricebook2.Processing_Fee__c, Product2.Display_VAT_Amount__c, PriceBook2.GPE_Event__c
                                                                                        FROM PricebookEntry WHERE Id IN :pricebookEntrySet]); */ //commented : VKHOPADE : issue 1144
                //VKHOPADE - issue 1144 - start
                List<Product2> ProductsPBEntriesList = new List<Product2> ([Select Id, (Select Id, Product2Id, Product2.Price__c, Product2.Cost__c, CurrencyIsoCode,Pricebook2Id,
                                                                                        Product2.Tax_Percentage__c, Product2.VAT_Tax__c, Product2.Processing_Fee__c, Product2.Type__c, UnitPrice, Product2.Reward_Points_Percentage__c, Product2.RecordType.Name,
                                                                                        Product2.Shipping_And_Handling__c, Product2.Shipping_And_Handling_Outside_US__c, Pricebook2.Shipping_and_Handling_Fee_Outside_US__c, 
                                                                                        Pricebook2.Shipping_and_Handling_Fee__c, Pricebook2.Tax_Percentage__c, Pricebook2.Processing_Fee__c, Product2.Display_VAT_Amount__c, PriceBook2.GPE_Event__c FROM PriceBookEntries) 
                                                                                        from Product2 WHERE Id IN (Select Product2Id FROM PriceBookEntry Where Id IN :pricebookEntrySet)]);
                
                Map<Id,PricebookEntry> mapPricebookEntrys = new Map<Id,PricebookEntry> ();
                map<Id, PricebookEntry> QliPriceBookEntriesUSDMap = new map<Id, PricebookEntry> ();
                List<PricebookEntry> PriceBookEntriesUSDList =  new List<PricebookEntry> ();
                
                for(Product2 productObj : ProductsPBEntriesList){
                    QLIProductIDSet.add(productObj.Id);
                    for(PricebookEntry pbe : productObj.PriceBookEntries){
                        if(pricebookEntrySet.contains(pbe.Id)){
                            mapPricebookEntrys.put (pbe.Id, pbe);
                            QLIPriceBookIdSet.add(pbe.Pricebook2Id);
                        }
                        if(pbe.CurrencyIsoCode == 'USD'){
                            PriceBookEntriesUSDList.add(pbe);
                        }
                    }
                }
                
                for(PricebookEntry pbe : PriceBookEntriesUSDList){
                    if(QLIPriceBookIdSet.contains(pbe.Pricebook2Id))
                        QliPriceBookEntriesUSDMap.put(pbe.Product2Id, pbe);
                }
                system.debug('PriceBookEntriesUSDMap = ' + QliPriceBookEntriesUSDMap);
                //VKHOPADE - issue 1144 - end
                    
                if(mapPricebookEntrys.values().size() > 0){
                    AddProductTypes(newQuoteLineItemList,mapPricebookEntrys);
                }
                Map<Id,Quote> mapQuotes = new Map<Id,Quote>([Select Id, Status, Remove_Processing_Fee__c, Original_Quote__c, Online_Order__c, GPE_Online_Order__c, Opportunity.Payment_Method__c, Opportunity.Reward_Percentage__c, opportunity.Qualifies_for_Reward_Points__c, ShippingCountryCode,
                                                             OpportunityId, Opportunity.Shipping_Outside_US__c, Opportunity.CurrencyIsoCode from Quote where Id IN: quoteSet]);
                                                                                        
                for(QuoteLineItem objQLI : newQuoteLineItemList){
                    if(mapQuotes != null && mapQuotes.containsKey(objQLI.QuoteId) && mapQuotes.get(objQLI.QuoteId).Status == 'Draft - Approved'){
                        objQLI.addError('You can\'t add any Product in "Draft Approved" quote, Please change quote status to "Draft" before add any Product.');
                    }
                    objQLI.Unit_Price_USD__c =  QliPriceBookEntriesUSDMap.get(mapPricebookEntrys.get(objQLI.PriceBookEntryId).Product2Id).UnitPrice;//VKHOPADE- issue# 1144 
                }
                calculateQuoteLineItems(mapPricebookEntrys,mapQuotes);
            }
            when BEFORE_UPDATE {
                System.debug('In Before Update!');
                Set<Id> pricebookEntrySet = new Set<Id>();
                Set<ID> quoteSet = new Set<Id>();
                for(QuoteLineItem objQLI : newQuoteLineItemList){
                    System.debug('PricebookEntryId-->'+objQLI.PricebookEntryId);
                    pricebookEntrySet.add(objQLI.PricebookEntryId);
                    quoteSet.add(objQLI.QuoteId);
                }
                Map<Id,PricebookEntry> mapPricebookEntrys = new Map<Id,PricebookEntry>([Select Product2Id, Product2.Price__c, Product2.Cost__c, Product2.Display_VAT_Amount__c,
                                                                                        Product2.Tax_Percentage__c, Product2.VAT_Tax__c, Product2.Processing_Fee__c, Product2.Type__c, UnitPrice, Product2.Reward_Points_Percentage__c,
                                                                                        Product2.Shipping_And_Handling__c, Product2.Shipping_And_Handling_Outside_US__c, Pricebook2.Shipping_and_Handling_Fee_Outside_US__c, 
                                                                                        Pricebook2.Shipping_and_Handling_Fee__c, Pricebook2.Tax_Percentage__c, Pricebook2.Processing_Fee__c, PriceBook2.GPE_Event__c
                                                                                        FROM PricebookEntry where Id IN :pricebookEntrySet]);
                Map<Id,Quote> mapQuotes = new Map<Id,Quote>([Select Id, Status, Remove_Processing_Fee__c, Original_Quote__c, GPE_Online_Order__c,Opportunity.Payment_Method__c,Opportunity.Reward_Percentage__c,opportunity.Qualifies_for_Reward_Points__c,ShippingCountryCode,
                                                             OpportunityId,Opportunity.Shipping_Outside_US__c,Opportunity.CurrencyIsoCode from Quote where Id IN: quoteSet]);
                for(QuoteLineItem objQLI : newQuoteLineItemList){
                    if(mapQuotes != null && mapQuotes.containsKey(objQLI.QuoteId) && mapQuotes.get(objQLI.QuoteId).Status == 'Draft - Approved'){
                        if(objQLI.Quantity != oldQuoteLineItemMap.get(objQLI.Id).Quantity){
                            objQLI.addError('You can\'t update Quantity in "Draft Approved" quote, Please change quote status to "Draft" before update Product.');
                        }
                    }
                }
                calculateQuoteLineItems(mapPricebookEntrys,mapQuotes);
                
                if(mapPricebookEntrys.values().size() > 0){
                    AddProductTypes(newQuoteLineItemList,mapPricebookEntrys);
                }
            }
            when BEFORE_DELETE {
                System.debug('In Before Delete!');
                Set<Id> setQuoteIds = new Set<Id>();
                for(QuoteLineItem objQLI : oldQuoteLineItemList) {
                    setQuoteIds.add(objQLI.QuoteId);
                }
                Map<Id,Quote> mapQuotes = new Map<Id,Quote>([Select Id, Status FROM Quote WHERE Id IN: setQuoteIds]);
                                                             
                for(QuoteLineItem objQLI : oldQuoteLineItemList){
                    if(!test.isRunningTest() && Label.Allow_to_Delete_QLI == 'true' && !TriggerHandler.allowToDelete){
                        objQLI.addError(Label.QLI_Delete_Message);
                    }
                    if(mapQuotes != null && mapQuotes.containsKey(objQLI.QuoteId) && mapQuotes.get(objQLI.QuoteId).Status == 'Draft - Approved'){
                        objQLI.addError('You can\'t Edit/Delete Line Item on "Draft Approved" quote, Please change quote status to "Draft" before update Product.');
                    }
                    if(mapQuotes != null && mapQuotes.containsKey(objQLI.QuoteId) && mapQuotes.get(objQLI.QuoteId).Status == 'Signed - Approved'){
                        objQLI.addError('You can\'t Edit/Delete Line Item, once Quote was "Signed - Approved".');
                    }
                }
            }
            when AFTER_INSERT {
                System.debug('In After Insert!');
                 //#878 changes -- START
                Set<Id> setQuoteId = new Set<Id>();
                for(QuoteLineItem objLineItem: newQuoteLineItemList){
                    setQuoteId.add(objLineItem.QuoteId);
                }
                if(setQuoteId.size() > 0){
                    updateOnlineLinkOnQuote(setQuoteId);
                }
                //#878 changes -- END
                
                //#934 101 soql error for online order - Start
                /*Set<Id> setOfQuotes = new Set<Id>();
                Map<Id, Quote> mapOfQuote;
                
                if(newQuoteLineItemList.size() > 0){
                    for(Quotelineitem obj : newQuoteLineItemList){
                        setOfQuotes.add(obj.QuoteId);
                    }
                }
                
                if(setOfQuotes.size() > 0){
                    mapOfQuote = new Map<Id, Quote>([select id, Subtotal, OpportunityId  FROM Quote WHERE Id IN : setOfQuotes]);
                }
                
                List<Payment_Term__c> lstOfOppPaymentTerms;
                
                if(mapOfQuote.size() > 0){
                    lstOfOppPaymentTerms = [select id, Percentage_Of_Payment__c, Payment_Due_Date__c, Amount__c, Quote__c FROM Payment_Term__c where Quote__c IN : mapOfQuote.keyset()];            
                }*/
                //#934 101 soql error for online order - End
            }
            when AFTER_UPDATE {
                System.debug('In After Update!');
                
                System.debug('oldQuoteLineItemMap'+ oldQuoteLineItemMap);
                System.debug('newQuoteLineItemList'+ newQuoteLineItemList);
                Set<Id> packageQuoteIds = new Set<Id>();
                for(QuoteLineItem objLineItem : newQuoteLineItemList) {
                    if(objLineItem.Quantity != oldQuoteLineItemMap.get(objLineItem.Id).Quantity && objLineItem.Record_Type__c == 'Package' && objLineItem.QuoteId != null) {
                        packageQuoteIds.add(objLineItem.QuoteId);
                    }
                }
                if(packageQuoteIds.size() > 0){
                    updateRewardDiscoutQLIs(packageQuoteIds);
                }
                
                //#934 101 soql error for online order - Start
                /* Added by Jimmy */                
                /*Set<Id> setOfQuotes = new Set<Id>();
                Map<Id, Quote> mapOfQuote;
                
                if(newQuoteLineItemList.size() > 0){
                    for(Quotelineitem obj : newQuoteLineItemList){
                        setOfQuotes.add(obj.QuoteId);
                    }
                }
                
                if(setOfQuotes.size() > 0){
                    mapOfQuote = new Map<Id, Quote>([select id, Subtotal, OpportunityId  FROM Quote WHERE Id IN : setOfQuotes]);
                }
                
                List<Payment_Term__c> lstOfOppPaymentTerms;
                
                if(mapOfQuote.size() > 0){
                    lstOfOppPaymentTerms = [select id, Percentage_Of_Payment__c, Payment_Due_Date__c, Amount__c, Quote__c FROM Payment_Term__c where Quote__c IN : mapOfQuote.keyset()];            
                }*/
                
                /* End of Added by Jimmy */
                
                //#934 101 soql error for online order - END
                
                Map<QuoteLineItem, Id> quotesAndOpportunitylineItemIds = new Map<QuoteLineItem, Id>();// mapQuoteLineItem
            
                for(QuoteLineItem currentQuoteLineItem : newQuoteLineItemList) {
                    quotesAndOpportunitylineItemIds.put(currentQuoteLineItem , currentQuoteLineItem.OpportunityLineItemId);
                }
            }
            when AFTER_DELETE {
                System.debug('In After Delete!');
                Set<Id> setPackageId = new Set<Id>();
                Set<Id> setPackageQuoteId = new Set<Id>();
                Set<Id> setHotelStayQliId = new Set<Id>(); //#1152 - VKHOPADE

                //#878 changes -- START
                Set<Id> setQuoteId = new Set<Id>();
                for(QuoteLineItem objLineItem: oldQuoteLineItemList){
                    setQuoteId.add(objLineItem.QuoteId);

                    if(objLineItem.Record_Type__c == 'Package' || objLineItem.Product_Record_Type__c == 'Hotel'){
                        setPackageId.add(objLineItem.Id);
                        setPackageQuoteId.add(objLineItem.QuoteId);
                    }

                    //#1152 - VKHOPADE - added below if
                    if(objLineItem.Product_Record_Type__c == 'Hotel Stay')
                       {
                           setHotelStayQliId.add(objLineItem.Id);
                       }
                }
                if(setQuoteId.size() > 0){
                    updateOnlineLinkOnQuote(setQuoteId);
                }
                //#878 changes -- END
                if(setPackageId.size() > 0){
                    deleteRelatedLineItem(setPackageQuoteId, setPackageId);
                }

                //#1152 - VKHOPADE - added below if
                if(setHotelStayQliId.size() > 0){
                    deleteRelatedRoomingLists(setHotelStayQliId);
                }
                //#934 101 soql error for online order - Start
                /*Set<Id> setOfQuotes = new Set<Id>();
                Map<Id, Quote> mapOfQuote;
                
                if(oldQuoteLineItemList.size() > 0){
                    for(Quotelineitem obj : oldQuoteLineItemList){
                        setOfQuotes.add(obj.QuoteId);
                    }
                }
                
                if(setOfQuotes.size() > 0){
                    mapOfQuote = new Map<Id, Quote>([select id, Subtotal, OpportunityId  FROM Quote WHERE Id IN : setOfQuotes]);
                }
                
                List<Payment_Term__c> lstOfOppPaymentTerms;
                
                if(mapOfQuote.size() > 0){
                    lstOfOppPaymentTerms = [select id, Percentage_Of_Payment__c, Payment_Due_Date__c, Amount__c, Quote__c FROM Payment_Term__c where Quote__c IN : mapOfQuote.keyset()];            
                }*/
                //#934 101 soql error for online order - END
            }
            when AFTER_UNDELETE {
                System.debug('In After Undelete!');
            }
            when else{
                System.debug('Undefined Trigger Operation!');
            }
        }
    }

    /**
    * @description Method for crea
    * @author jagrawal@addonblue.com | 3/31/2020 
    * @return void 
    **/
    @future(callout = true)
    private static void updateRewardDiscoutQLIs(Set<Id> packageQuoteIds){
        List<Quote> lstQuoteAndQLIs = new List<Quote>();
        if(packageQuoteIds.size() > 0){
            lstQuoteAndQLIs = [Select Id, OpportunityId, (SELECT Id, LineNumber, QuoteId, PricebookEntryId, PricebookEntry.Name, Quantity, Product2Id, Product2.Name, 
                     Product2.RecordType.Name, Quote_Package__c, Record_Type__c, Product2.Type__c FROM QuoteLineItems) FROM Quote WHERE Id in : packageQuoteIds];
        }
        List<QuoteLineItem> lstUpdatableRecords = new List<QuoteLineItem>();
        Set<Id> oppIds = new Set<Id>();
        map<Id,Id> mapOppContact = new map<Id, Id>();
        for(Quote objQuote : lstQuoteAndQLIs) {
            oppIds.add(objQuote.OpportunityId);
        }
        for(OpportunityContactRole objContactRole :[Select Id, Contact.Name, Contact.Email, ContactId, Custom_Contact__c, Role, OpportunityId, Opportunity.AccountId FROM OpportunityContactRole WHERE Role = 'H4H Rewards Contact' and OpportunityId IN :oppIds]) {
            mapOppContact.put(objContactRole.OpportunityId, objContactRole.ContactId);
        }
        for(Quote objQuote : lstQuoteAndQLIs) {
            Map<String, QuoteLineItemUtility.LineItemBundleClass> MapLineItem = new Map<String, QuoteLineItemUtility.LineItemBundleClass>();
            Map<String,QuoteLineItem> mapRewardLineItem = new Map<String,QuoteLineItem>();
            
            for(QuoteLineItem objLineItem : objQuote.QuoteLineItems) {
                QuoteLineItemUtility.LineItemBundleClass objLineBundle = new QuoteLineItemUtility.LineItemBundleClass();
                System.debug(objLineItem);
                if(objLineItem.Record_Type__c == 'Package' && !objLineItem.Product2.Name.Contains('Deposit')){
                    System.debug(objLineItem);
                    objLineBundle.ParentPackage = objLineItem;
                    MapLineItem.put(objLineItem.Id, objLineBundle);
                }
                
                if(objLineItem.Product2.Type__c == 'Reward Discount' && objLineItem.Product2.Name == 'Reward Discount') {
                    mapRewardLineItem.put(objQuote.Id, objLineItem);
                }
                
                if(String.isNotBlank(objLineItem.Quote_Package__c) && MapLineItem.containsKey(objLineItem.Quote_Package__c)) {
                    objLineBundle = MapLineItem.get(objLineItem.Quote_Package__c);
                    
                    if(objLineItem.Record_Type__c == 'Hotel Transportation' || objLineItem.Record_Type__c == 'Hotel Stay') {
                        objLineBundle.ChildLineItems.add(objLineItem);
                    }
                }
            }
            
            if(MapLineItem != null && MapLineItem.size() > 0) {
                Decimal maxUsablePoints = 0;
                Decimal minUsablePoints = 50;
                for(String str: MapLineItem.KeySet()) {
                    QuoteLineItemUtility.LineItemBundleClass obj = MapLineItem.get(str);
                    Decimal rewardPoint = 50;
                    if(obj.ParentPackage != null && obj.ChildLineItems.size() > 0) {
                        rewardPoint = 100;
                        minUsablePoints = 100;
                    }
                    maxUsablePoints = maxUsablePoints + (rewardPoint * obj.ParentPackage.Quantity);
                }
                
                Double h4hRewardsPoints = Quote_RewardAndDiscount_Tab_LEX.getRewardPointsOfContact(mapOppContact.get(objQuote.OpportunityId));
                System.debug('maxUsablePoints: '+maxUsablePoints);
                System.debug('h4hRewardsPoints: '+h4hRewardsPoints);
                Double rewardPoints = -(h4hRewardsPoints >= maxUsablePoints ? maxUsablePoints : h4hRewardsPoints);
                
                if(mapRewardLineItem != null && mapRewardLineItem.containskey(objQuote.Id)){
                    QuoteLineItem obj = mapRewardLineItem.get(objQuote.Id);
                    obj.UnitPrice = rewardPoints;
                    lstUpdatableRecords.add(obj);
                }
            }
        }
        
        if(lstUpdatableRecords.size() > 0){
            Utility.processRecords(lstUpdatableRecords, 'update');
        }
    }

    /**
    * @description  : Caculate opportunity line item
    * @author       : ChangeMeIn@UserSettingsUnder.SFDoc
    * @param        : 
    * @return       : List of Quotelineitems
    **/
    public void calculateQuoteLineItems(Map<Id,PricebookEntry> mapPricebookEntrys, Map<Id,Quote> mapQuotes) {
        System.debug('mapProduct-->'+mapPricebookEntrys);
        System.debug('mapQuotes-->'+mapQuotes);
        IsQuoteLineItemTrigger = true;
        // CurrencyType Helper
        DatedConversionRateHelper datedConversionRateHelper = new DatedConversionRateHelper();
        
        // List of opportunity line items to update 
        List<QuoteLineItem> quoteLineItemsToUpdate = new List<QuoteLineItem>();
        // Set field values for opportunity line items
        for(QuoteLineItem qliToUpdate : (List<QuoteLineItem>)Trigger.new) {
            if(mapQuotes.get(qliToUpdate.quoteid).GPE_Online_Order__c == false){
                System.debug('mapPricebookEntrys@@@'+mapPricebookEntrys);
                if(mapPricebookEntrys != null && mapPricebookEntrys.containskey(qliToUpdate.PriceBookEntryId)){
                    qliToUpdate.VAT_Amount_Calculation__c = mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Display_VAT_Amount__c == null ? 0 : mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Display_VAT_Amount__c * qliToUpdate.Quantity;
                }
                
                // Only calculate if its Package or Package Product or Hotel Transportation or Hotel Stay or Addon or A La Carte 
                if(qliToUpdate.Record_Type__c != null && qliToUpdate.ProductType__c != 'Discount' 
                   && (qliToUpdate.Record_Type__c.equals('Package') || qliToUpdate.Record_Type__c.equals('Hotel Transportation') 
                       || qliToUpdate.Record_Type__c.equals('Hotel Stay') || qliToUpdate.Record_Type__c.equals('Addon') 
                       || qliToUpdate.Record_Type__c.equals('A La Carte'))) {
                           // Cost
                           if(qliToUpdate.CurrencyIsoCode.equals('USD')) {
                               // For USD
                               qliToUpdate.Cost__c = mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Cost__c == null ? 0 : mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Cost__c;
                           } else {
                               // For rest of Currencies
                               qliToUpdate.Cost__c = mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Cost__c == null ? 0 : datedConversionRateHelper.convert(mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Cost__c, qliToUpdate.CurrencyIsoCode); // Amount, CurrencyIsoCode of LineItem
                           }
                           qliToUpdate.Cost__c = (qliToUpdate.Cost__c).setScale(2);
                           
                           // Price for shipping and handling
                           if((qliToUpdate.Record_Type__c != null && qliToUpdate.Record_Type__c.equals('A La Carte') && qliToUpdate.ProductType__c != null && qliToUpdate.ProductType__c.equals('Shipping and Handling'))) {
                               if(!String.isEmpty(mapQuotes.get(qliToUpdate.QuoteId).ShippingCountryCode)) {
                                   if(!mapQuotes.get(qliToUpdate.QuoteId).Opportunity.Shipping_Outside_US__c.equals('Yes') && 
                                      (mapQuotes.get(qliToUpdate.QuoteId).Original_Quote__c ==NULL || qliToUpdate.Original_Quantity__c ==NULL )){//if(!mapQuotes.get(qliToUpdate.QuoteId).ShippingCountryCode.equals('US')){
                                          // Outside US                            
                                          if(qliToUpdate.CurrencyIsoCode.equals('USD')) {
                                              // For USD
                                              qliToUpdate.ListPrice_Used__c = mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Pricebook2.Shipping_and_Handling_Fee_Outside_US__c == null 
                                                  ? 0 : mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Pricebook2.Shipping_and_Handling_Fee_Outside_US__c;
                                          } 
                                          else {
                                              // For Non USD
                                              qliToUpdate.ListPrice_Used__c = mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Pricebook2.Shipping_and_Handling_Fee_Outside_US__c == null 
                                                  ? 0 : datedConversionRateHelper.convert(mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Pricebook2.Shipping_and_Handling_Fee_Outside_US__c, qliToUpdate.CurrencyIsoCode); // Amount, CurrencyIsoCode of LineItem
                                          }
                                      }
                               } 
                               else {
                                   if(mapQuotes.get(qliToUpdate.QuoteId).Original_Quote__c ==NULL || qliToUpdate.Original_Quantity__c ==NULL){
                                       // Inside US
                                       if(qliToUpdate.CurrencyIsoCode.equals('USD')) {
                                           // For USD
                                           qliToUpdate.ListPrice_Used__c = mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Pricebook2.Shipping_and_Handling_Fee__c == null 
                                               ? 0 : mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Pricebook2.Shipping_and_Handling_Fee__c;
                                       } 
                                       else {
                                           // For Non USD
                                           qliToUpdate.ListPrice_Used__c = mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Pricebook2.Shipping_and_Handling_Fee__c == null 
                                               ? 0 : datedConversionRateHelper.convert(mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Pricebook2.Shipping_and_Handling_Fee__c, qliToUpdate.CurrencyIsoCode); // Amount, CurrencyIsoCode of LineItem
                                       }
                                   }
                               }
                               qliToUpdate.ListPrice_Used__c = (qliToUpdate.ListPrice_Used__c != null ? (qliToUpdate.ListPrice_Used__c).setScale(2): null);//mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).UnitPrice; //(qliToUpdate.ListPrice == null ? 0 : qliToUpdate.ListPrice).setScale(2);
                           }
                           else {
                               if(mapQuotes.get(qliToUpdate.QuoteId).Original_Quote__c ==NULL || qliToUpdate.Original_Quantity__c ==NULL){
                                   // Price for regular products
                                   if(Trigger.isInsert) {
                                       System.debug('2-UnitPrice@@- '+mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).UnitPrice);
                                       if((mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.RecordType.Name == 'Package' || mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Type__c == 'Reward Discount' || mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Type__c == 'Discount')  && mapQuotes.get(qliToUpdate.quoteid).Online_Order__c){
                                           qliToUpdate.ListPrice_Used__c =  qliToUpdate.UnitPrice != 0 ? qliToUpdate.UnitPrice : mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).UnitPrice;
                                       } else {
                                           qliToUpdate.ListPrice_Used__c =  mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).UnitPrice;
                                       }
                                   } else {
                                       if((mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Type__c == 'Reward Discount' || mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Type__c == 'Discount')  && mapQuotes.get(qliToUpdate.quoteid).Online_Order__c){
                                           qliToUpdate.ListPrice_Used__c =  qliToUpdate.UnitPrice;
                                       } else {
                                           qliToUpdate.ListPrice_Used__c = qliToUpdate.ListPrice_Used__c != NULL ? ((qliToUpdate.ListPrice_Used__c).setScale(2)) : 0;
                                       }
                                   }
                               }                        
                           }
                           // Tax
                           if(mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Tax_Percentage__c == null) {
                               qliToUpdate.Tax_Percentage_Used__c = mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Pricebook2.Tax_Percentage__c == null ? 0 : mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Pricebook2.Tax_Percentage__c;
                           } else {
                               qliToUpdate.Tax_Percentage_Used__c = mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Tax_Percentage__c;
                           }
                           // Set tax to 0 if its shipping and handling jthakkar@line item
                           if(qliToUpdate.Record_Type__c != null && qliToUpdate.Record_Type__c.equals('A La Carte') && qliToUpdate.ProductType__c != null && (qliToUpdate.ProductType__c.equals('Shipping and Handling') || qliToUpdate.ProductType__c.equals('Discount'))) {
                               qliToUpdate.Tax_Amount__c = 0.00;
                           } else {
                               system.debug('###'+qliToUpdate.ListPrice_Used__c +'<==>'+ qliToUpdate.Tax_Percentage_Used__c);
                               qliToUpdate.Tax_Amount__c = (qliToUpdate.ListPrice_Used__c !=NULL && qliToUpdate.Tax_Percentage_Used__c !=NULL) ? ((qliToUpdate.ListPrice_Used__c * qliToUpdate.Tax_Percentage_Used__c/100).setScale(2,System.RoundingMode.HALF_UP)) : 0;                    
                           }
                           qliToUpdate.Total_Tax_Amount__c = (qliToUpdate.Tax_Amount__c * qliToUpdate.Quantity).setScale(2,System.RoundingMode.HALF_UP);
                           // VAT Tax
                           qliToUpdate.VAT_Tax_Amount__c = (mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.VAT_Tax__c == null ? 0 : mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.VAT_Tax__c).setScale(2,System.RoundingMode.HALF_UP);
                           qliToUpdate.Total_VAT_Tax__c = (qliToUpdate.VAT_Tax_Amount__c * qliToUpdate.Quantity).setScale(2,System.RoundingMode.HALF_UP);
                           // Subtotal
                           Decimal subtotal = 0;
                           // For shipping and handling
                           if(qliToUpdate.Record_Type__c != null && qliToUpdate.Record_Type__c.equals('A La Carte') && qliToUpdate.ProductType__c != null && qliToUpdate.ProductType__c.equals('Shipping and Handling')) {
                               system.debug('###IN IF for Shipping and Handling');
                               subtotal = qliToUpdate.ListPrice_Used__c;
                           } else {
                               // For regular products                    
                               system.debug('### Else for Regular Products'+qliToUpdate.ListPrice_Used__c + qliToUpdate.Tax_Amount__c + qliToUpdate.VAT_Tax_Amount__c);
                               if(qliToUpdate.ListPrice_Used__c !=NULL){
                                   subtotal += qliToUpdate.ListPrice_Used__c;
                               }
                               if(qliToUpdate.Tax_Amount__c !=NULL){
                                   subtotal += qliToUpdate.Tax_Amount__c;
                               }
                               if(qliToUpdate.VAT_Tax_Amount__c !=NULL){
                                   subtotal += qliToUpdate.VAT_Tax_Amount__c;
                               }
                           }
                           subtotal = (subtotal != null? subtotal.setScale(2,System.RoundingMode.HALF_UP): 0);
                           // Credit Card Fee, Calculate this as long as Credit Card Fee/Processing Fee field has value.
                           if(mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Processing_Fee__c == null) {
                               qliToUpdate.Processing_Fee_Percentage_Used__c = mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Pricebook2.Processing_Fee__c == null ? 0 : mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Pricebook2.Processing_Fee__c;
                           } else {
                               qliToUpdate.Processing_Fee_Percentage_Used__c = mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Processing_Fee__c == null ? 0 : mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Processing_Fee__c;
                           }
                           
                           qliToUpdate.Processing_Fee_Amount__c = (subtotal * (qliToUpdate.Processing_Fee_Percentage_Used__c == null ? 0 : qliToUpdate.Processing_Fee_Percentage_Used__c)/100).setScale(2,System.RoundingMode.HALF_UP);
                           qliToUpdate.Total_Processing_Fee_Amount__c = (qliToUpdate.Processing_Fee_Amount__c * qliToUpdate.Quantity).setScale(2,System.RoundingMode.HALF_UP);
                           // UnitPrice
                           // For VAT Tax QLI
                           //#508 code change by Fesal for Reward and Discount issue
                           //#451 Added Protectgroup Integration Product Type
                           //#695 Added Retail Hotel Integration Product Type
                           if((qliToUpdate.Record_Type__c != null && qliToUpdate.ProductType__c != null && qliToUpdate.Record_Type__c.equals('A La Carte') && qliToUpdate.ProductType__c.equals('VAT Tax')) 
                              || ((mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Type__c == 'Reward Discount' || mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Type__c == 'Discount') && mapQuotes.get(qliToUpdate.quoteid).Online_Order__c == false)
                              || mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Type__c == 'Protect Group'
                              || mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Type__c == 'Retail Hotel') {
                                  // Don't update the unit price, its being set in QuoteLineItemHandler based on Package's VAT Tax.
                                  // Don't update the unit price for Discount producttype__c QLI. It is set in QuoteLineItemHandler based on other QLI of the Quote
                                  
                              } else {
                                  // For regular products
                                  System.debug('subtotal:-'+subtotal+'--qliToUpdate.Processing_Fee_Amount__c:-'+qliToUpdate.Processing_Fee_Amount__c);
                                  if(mapQuotes.get(qliToUpdate.QuoteId).Remove_Processing_Fee__c){
                                      qliToUpdate.UnitPrice = (subtotal + 0.0).setScale(2,System.RoundingMode.HALF_UP);
                                  } else {
                                      qliToUpdate.UnitPrice = (subtotal + qliToUpdate.Processing_Fee_Amount__c).setScale(2,System.RoundingMode.HALF_UP);
                                  }
                              }
                           // To calculate the Earned_Reward_Points__c value by taking total price and percentage defined in product.
                           If(Trigger.isUpdate){
                               if(qliToUpdate.Quantity != oldQuoteLineItemMap.get(qliToUpdate.Id).Quantity || qliToUpdate.TotalPrice != oldQuoteLineItemMap.get(qliToUpdate.Id).TotalPrice) {
                                   //#744 Shipping fee logic for manual gpe orders
                                   if(mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).PriceBook2.GPE_Event__c) {
                                       qliToUpdate.GPE_Total_Price__c = qliToUpdate.UnitPrice * qliToUpdate.Quantity;
                                   }
                               }
                           } else If(Trigger.isInsert) {
                               //#744 Shipping fee logic for manual gpe orders
                               if(mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).PriceBook2.GPE_Event__c){
                                   qliToUpdate.GPE_Total_Price__c = qliToUpdate.UnitPrice * qliToUpdate.Quantity;
                               }
                           }
                           // TotalPrice
                           // SF automatically caculates TotalPrice (UnitPrice * Quantity)
                           // Add to list of OLI's to update
                           system.debug('qliToUpdate---'+qliToUpdate);
                           //quoteLineItemsToUpdate.add(qliToUpdate);
                       }
            }
            System.debug('Protect Group'+qliToUpdate);
            System.debug('Protect Group'+qliToUpdate.ProductType__c);
            // Only calculate if its Package or Package Product or Hotel Transportation or Hotel Stay or Addon or A La Carte 
            if(qliToUpdate.Record_Type__c != null && qliToUpdate.ProductType__c != 'Discount' && qliToUpdate.Product_Types__c != 'Protect Group' &&
              (qliToUpdate.Record_Type__c.equals('Package') || qliToUpdate.Record_Type__c.equals('Hotel Transportation') || qliToUpdate.Record_Type__c.equals('Hotel Stay') || qliToUpdate.Record_Type__c.equals('Addon') || qliToUpdate.Record_Type__c.equals('A La Carte'))
              ) {
                // To calculate the Earned_Reward_Points__c value by taking total price and percentage defined in product.
                If(Trigger.isUpdate){
                    if(qliToUpdate.Quantity != oldQuoteLineItemMap.get(qliToUpdate.Id).Quantity || qliToUpdate.TotalPrice != oldQuoteLineItemMap.get(qliToUpdate.Id).TotalPrice) {
                        System.debug(qliToUpdate.Reward_Points_Percentage__c);
                        System.debug('RoomCash_Points: '+qliToUpdate.RoomCash_Points__c);
                        if(qliToUpdate.RoomCash_Points__c != null && qliToUpdate.RoomCash_Points__c != 0){
                            qliToUpdate.Earned_Reward_Points__c = qliToUpdate.RoomCash_Points__c;
                        } else {
                            qliToUpdate.Earned_Reward_Points__c = qliToUpdate.TotalPrice * qliToUpdate.Reward_Points_Percentage__c / 100;
                        }
                    }
                } else If(Trigger.isInsert) {
                    System.debug('RoomCash_Points: '+qliToUpdate.RoomCash_Points__c);
                    if(qliToUpdate.RoomCash_Points__c != null && qliToUpdate.RoomCash_Points__c != 0){
                        qliToUpdate.Earned_Reward_Points__c = qliToUpdate.RoomCash_Points__c;
                    } else {
                        qliToUpdate.Earned_Reward_Points__c = qliToUpdate.UnitPrice * qliToUpdate.Quantity * 
                            (mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Reward_Points_Percentage__c != null 
                             ? mapPricebookEntrys.get(qliToUpdate.PriceBookEntryId).Product2.Reward_Points_Percentage__c : 10 ) / 100;
                    }
                }
            }
        }
    }
    
    /**
    * @description 
    * @author jagrawal@addonblue.com | 4/3/2020 
    * @param Map<Id QuoteLineItem> newQuoteLineItemMap 
    * @param Map<Id Product2> mapProduct 
    * @return void 
    **/
    public static void AddProductTypes(List<QuoteLineItem> newQuoteLineItemList, Map<Id, PricebookEntry> mapPricebookEntrys){
        List<QuoteLineItem> lstQuoteLineItem = new List<QuoteLineItem>();
        for(QuoteLineItem objQuoteLineItem : newQuoteLineItemList){
            if(mapPricebookEntrys.containsKey(objQuoteLineItem.PricebookEntryID)){
                System.debug('Type-->'+mapPricebookEntrys.get(objQuoteLineItem.PricebookEntryID).Product2.Type__c);
                if(mapPricebookEntrys.get(objQuoteLineItem.PricebookEntryID).Product2.Type__c != null 
                && mapPricebookEntrys.get(objQuoteLineItem.PricebookEntryID).Product2.Type__c == 'Shipping and Handling'){
                    objQuoteLineItem.ProductType__c = mapPricebookEntrys.get(objQuoteLineItem.PricebookEntryID).Product2.Type__c;
                    lstQuoteLineItem.add(objQuoteLineItem);
                }
            }
        }
        System.debug('lstQuoteLineItem'+lstQuoteLineItem);
    }

     /**
    * @description 
    * @author fsuraitawala@addonblue.com | 05/28/2021 
    * @param Set<Id> setQuoteId 
    * @return void 
    **/
    public static void updateOnlineLinkOnQuote(set<Id> setQuoteId){
        List<Quote> lstupdateQuote = new List<Quote>();
        if(setQuoteId.size() > 0) {
            for(Quote objQuote: [Select Id, Don_t_Copy_Quote_to_Online_Order_Link__c, 
                                (Select Id FROM QuoteLineItems WHERE Product2.Requires_Double_Approval__c = true)
                                FROM Quote WHERE Id IN :setQuoteId]){
                if(objQuote.QuoteLineItems.size() > 0 && objQuote.Don_t_Copy_Quote_to_Online_Order_Link__c == false){
                    objQuote.Don_t_Copy_Quote_to_Online_Order_Link__c = true;
                    lstupdateQuote.add(objQuote);
                } else if(objQuote.QuoteLineItems.size() <= 0 && objQuote.Don_t_Copy_Quote_to_Online_Order_Link__c == true) {
                    objQuote.Don_t_Copy_Quote_to_Online_Order_Link__c = false;
                    lstupdateQuote.add(objQuote);
                }
            }
        }
        
        if(lstupdateQuote.size() > 0){
            TriggerHandler.bypass('QuoteTriggerHandler');
            Utility.processRecords(lstupdateQuote,'update');
            TriggerHandler.clearBypass('QuoteTriggerHandler');
        }
    }
    /**
    * @description #1006 delete child QLI on Parent delete
    * @author fsuraitawala@addonblue.com | 06/28/2021 
    * @param Set<Id> setQuoteId 
    * @param Set<Id> setPackageId
    * @return void 
    **/
    public static void deleteRelatedLineItem(set<Id> setQuoteId, set<Id> setPackageId){
        List<QuoteLineItem> deleteQLI = new List<QuoteLineitem>();
        List<Rooming_List__c> deleteRoomingLists = new List<Rooming_List__c>();
        
        deleteQLI = [Select Id FROM QuoteLineItem WHERE (Quote_Package__c IN :setPackageId  OR Hotel_Package_Id__c IN :setPackageId) AND QuoteId IN :setQuoteId];
        
        if(deleteQLI.size() > 0){
            delete deleteQLI;
        }
        
        deleteRoomingLists = [SELECT Id, Hotel_Package_Id__c FROM Rooming_List__c WHERE Quote_Package__c IN :setPackageId OR Hotel_Package_Id__c IN :setPackageId];
        
        if(deleteRoomingLists.size() > 0) {
            delete deleteRoomingLists;
        }
    }


    /**
    * @description #1152 delete related rooming lists when Hotel Stay is deleted
    * @author vaibhav.khopade@addonblue.com | 02/02/2022 
    * @param Set<Id> setQuoteLineId 
    * @return void 
    **/
    public static void deleteRelatedRoomingLists(set<Id> setQuoteLineId){
        List<Rooming_List__c> deleteRoomingLists = new List<Rooming_List__c>();
        
        deleteRoomingLists = [SELECT Id, QuoteLineItem_Id__c FROM Rooming_List__c WHERE QuoteLineItem_Id__c IN :setQuoteLineId];
        
        if(deleteRoomingLists.size() > 0) {
            delete deleteRoomingLists;
        }
    }
}
/**
 * @File Name          : SW_Product_LEX.cls
 * @Description        : This class use for Product Tab in Sales Wizard.
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 01-11-2021
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    15/10/2019   fsuraitawalal@addonblue.com     Initial Version
**/
public class Quote_Product_Tab_LEX {
    /****************************************************************************/
    @AuraEnabled 
    public static Quote getQuoteWithData(String currentQuoteId) {
        System.debug(currentQuoteId);
        Quote objQuote = new Quote();
        
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            objQuote = [Select Id, Name, Status, Opportunity.Pricebook2Id, Pricebook2Id, Pricebook2.Program__c, Pricebook2.Program__r.Name, CurrencyIsoCode 
                        FROM Quote 
                        WHERE Id =: currentQuoteId];
        }
        
        return objQuote;
    }
    /****************************************************************************/
    @AuraEnabled 
    public static List<QuoteLineItem> getaLaCarteLineItems(String currentQuoteId) {
        
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            return [SELECT Id, PricebookEntryId, PricebookEntry.Name, Quantity, Quote_Package__c, Record_Type__c, Product2.Type__c, PricebookEntry_Name__c
                    FROM QuoteLineItem WHERE QuoteId = :currentQuoteId AND Record_Type__c = 'A La Carte' 
                    ORDER BY CreatedDate];
        }
        return null;
    }
    
    /****************************************************************************/
    @AuraEnabled 
    public static SW_Utility_LEX.LineItemBundleClass getRelatedLineItems(String currentQuoteId, String PackageLineItemId) {
        System.debug(PackageLineItemId);
        System.debug(currentQuoteId);
        List<QuoteLineItem> LineItemsRecord = new List<QuoteLineItem>();
        
        SW_Utility_LEX.LineItemBundleClass objBundle = new SW_Utility_LEX.LineItemBundleClass();
        Map<String, SW_Utility_LEX.HotelBundleClass> MapHotelBundle = new Map<String, SW_Utility_LEX.HotelBundleClass>();
        
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            for(QuoteLineItem objLineItem: [SELECT Id, LineNumber, QuoteId, PricebookEntryId, PricebookEntry.Name, Quantity, Quote_Package__c,
                                            Product2Id, Product2.Name, Product2.RecordType.Name, Record_Type__c, Product2.Downgrade__c,
                                            Product2.Downgrade__r.Name, Product2.Downgrade__r.CurrencyIsoCode, Product2.Downgrade__r.Price__c,
                                            Product2.Upgrade__c, Product2.Upgrade__r.Name, Product2.Upgrade__r.CurrencyIsoCode, Product2.Upgrade__r.Price__c,
                                            Hotel_Package_Id__c, Room_Type__c, Room_Quantity__c, PricebookEntry_Name__c 
                                            FROM QuoteLineItem WHERE QuoteId = :currentQuoteId 
                                            AND (Id =: PackageLineItemId OR Quote_Package__c = :PackageLineItemId) ORDER BY CreatedDate]) {
                if(PackageLineItemId == objLineItem.Id) {
                    objBundle.ParentPackage = objLineItem;
                }
                if(PackageLineItemId == objLineItem.Quote_Package__c) {
                    if(objLineItem.Record_Type__c == 'Package Product') {
                        objBundle.ChildLineItems.add(objLineItem);
                    }
                    
                    SW_Utility_LEX.HotelBundleClass objHotelBundle = new SW_Utility_LEX.HotelBundleClass();
                    if(objLineItem.Record_Type__c == 'Package Hotel') {
                        objHotelBundle.Hotel = objLineItem;
                        MapHotelBundle.put(objLineItem.Id, objHotelBundle);
                    }
                    
                    if(objLineItem.Record_Type__c == 'Hotel Transportation') {
                        if(MapHotelBundle != null && MapHotelBundle.containskey(objLineItem.Hotel_Package_Id__c)){
                            objHotelBundle = MapHotelBundle.get(objLineItem.Hotel_Package_Id__c); objHotelBundle.HotelTransportation = objLineItem; 
                            objHotelBundle.HotelTransportations.add(objLineItem); MapHotelBundle.put(objLineItem.Hotel_Package_Id__c, objHotelBundle);
                        } else {
                            objHotelBundle.HotelTransportation = objLineItem;
                            objHotelBundle.HotelTransportations.add(objLineItem);
                            MapHotelBundle.put(objLineItem.Hotel_Package_Id__c, objHotelBundle);
                        }
                    }
                    
                    if(objLineItem.Record_Type__c == 'Hotel Stay') {
                        if(MapHotelBundle != null && MapHotelBundle.containskey(objLineItem.Hotel_Package_Id__c)){
                            objHotelBundle = MapHotelBundle.get(objLineItem.Hotel_Package_Id__c);
                            objHotelBundle.HotelStay = objLineItem;
                            MapHotelBundle.put(objLineItem.Hotel_Package_Id__c, objHotelBundle);
                        } else {
                            objHotelBundle.HotelStay = objLineItem; MapHotelBundle.put(objLineItem.Hotel_Package_Id__c, objHotelBundle);
                        }
                    }
                    
                    if(objLineItem.Record_Type__c == 'Addon') {
                        objBundle.AddonLineItems.add(objLineItem);
                    }
                }
            }
            
            Map<String, List<Rooming_List__c>> mapRoomingList = new Map<String,List<Rooming_List__c>>();
            
            if(MapHotelBundle != null && MapHotelBundle.size() > 0) {
                for(Rooming_List__c obj: [SELECT Id, Name, Guest_Name__c, Number_of_Adults__c, QuoteLineItem_Id__c, Hotel_Package_Id__c, Quote_Package__c 
                                          FROM Rooming_List__c WHERE Hotel_Package_Id__c In :MapHotelBundle.keyset()]) {
                    List<Rooming_List__c> lstRooom = new List<Rooming_List__c>();
                    if(mapRoomingList != null && mapRoomingList.containskey(obj.Hotel_Package_Id__c)){
                        List<Rooming_List__c> lst = mapRoomingList.get(obj.Hotel_Package_Id__c); lst.add(obj); mapRoomingList.put(obj.Hotel_Package_Id__c, lst);
                    } else {
                        mapRoomingList.put(obj.Hotel_Package_Id__c, new List<Rooming_List__c>{obj});
                    }
                }
                objBundle.HotelBundle = MapHotelBundle.values();
                
                for(SW_Utility_LEX.HotelBundleClass obj : objBundle.HotelBundle) {
                    if(mapRoomingList != null && mapRoomingList.containskey(obj.Hotel.Id)){ obj.RoomingList.addall(mapRoomingList.get(obj.Hotel.Id));
                        obj.oldRoomingList = new Map<Id, Rooming_List__c>(obj.RoomingList); obj.RoomQty = mapRoomingList.get(obj.Hotel.Id).size();
                    }
                }
            }
        }
        System.debug(MapHotelBundle);
        System.debug(objBundle.ParentPackage);
        System.debug(objBundle.ChildLineItems);
        System.debug(objBundle.ChildLineItems.size());
        System.debug(objBundle.HotelBundle);
        System.debug(objBundle.HotelBundle.size());
        System.debug(objBundle.AddonLineItems);
        System.debug(objBundle.AddonLineItems.size());
        System.debug(MapHotelBundle);
        return objBundle;
    }
}
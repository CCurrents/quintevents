/**
 * @File Name          : Quote_Product_Hotel_Tab_LEX.cls
 * @Description        : This class use for Hotel Tab in Sales Wizard.
 * @Author             : fsuraitawalal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 10-12-2021
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    21/10/2019   fsuraitawalal@addonblue.com     Initial Version
**/
global class Quote_Product_Hotel_Tab_LEX {
    private Map<Id,PricebookEntry> mapPriceBookEntry;
    /**
    * @description  : Method for get RoomType option of Product Field
    * @author       : fsuraitawala@addonblue.com
    * @param        : 
    * @return       : List<SW_Utility_LEX.customOptionClass>
    **/
    @AuraEnabled
    public static List<SW_Utility_LEX.customOptionClass> getRoomTypeOptions() {
        List<SW_Utility_LEX.customOptionClass> pickListValuesList= new List<SW_Utility_LEX.customOptionClass>();
        SW_Utility_LEX.customOptionClass obj = new SW_Utility_LEX.customOptionClass();
        obj.label = '--None--';
        obj.value = '';
        pickListValuesList.add(obj);
        
        Schema.DescribeFieldResult fieldResult = Product2.Room_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple) {
            obj = new SW_Utility_LEX.customOptionClass();
            obj.label = pickListVal.getLabel();
            obj.value = pickListVal.getValue();
            pickListValuesList.add(obj);
        }
        return pickListValuesList;
    }
    
    /**
    * @description  : Method for get Related Saved LineItems related Parent Package
    * @author       : fsuraitawala@addonblue.com
    * @param        : 
    * @return       : List<QuoteLineItem>
    **/
    @AuraEnabled 
    public static List<QuoteLineItem> getReletedHotelLineItems(String PackageLineItemId) {
        system.debug(PackageLineItemId);
        
        List<QuoteLineItem>  hotelLineItems = new List<QuoteLineItem>();
        if(PackageLineItemId != '' && String.isNotBlank(PackageLineItemId)) {
            hotelLineItems = [SELECT Id, LineNumber, QuoteId, PricebookEntryId, PricebookEntry.Name, Quantity, Product2Id, Product2.Name, 
                              Product2.RecordType.Name, Product2.Current_Inventory__c, Quote_Package__c, Record_Type__c, PricebookEntry_Name__c
                              FROM QuoteLineItem 
                              WHERE (Quote_Package__c = :PackageLineItemId AND (Record_Type__c = 'Hotel Stay' OR Record_Type__c = 'Hotel Transportation')) 
                              OR Id = :PackageLineItemId];
        }
        
        System.debug(hotelLineItems);
        
        return hotelLineItems;
    }
    
    /**
    * @description  : Method for get Related Hotel Stay for Selected Hotel
    * @author       : fsuraitawala@addonblue.com
    * @param        : currentQuoteId
    * @param        : SelectedHotelId
    * @return       : List<PricebookEntry>
    **/
    @AuraEnabled 
    public static List<PricebookEntry> getRelatedHotelStay(String currentQuoteId, String SelectedHotelId) {
        System.debug(currentQuoteId);
        System.debug(SelectedHotelId);
        
        Set<String> setChildProduct = new Set<String>();
        
        Quote objQuote = new Quote();
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            objQuote = [Select Id, CurrencyIsoCode, OpportunityId, Opportunity.CurrencyIsoCode, PriceBook2Id 
                        FROM Quote WHERE Id = :currentQuoteId];
            System.debug(objQuote);
        }
        
        if(SelectedHotelId != null && objQuote != null) {
            for(Products_Bundle__c obj: [SELECT Id, Name, Child_product__c, Child_product__r.Name, Parent_Product__c FROM Products_Bundle__c 
                                         WHERE Parent_Product__c = :SelectedHotelId/* AND Type__c = 'Addon'*/]) {
                setChildProduct.add(obj.Child_product__c);
            }
            System.debug(setChildProduct);
            
            if(setChildProduct != null) {
                List<PricebookEntry> lstPBE = [SELECT Id, Name, Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice, IsActive, Product2.Recordtype.Name,
                                               Product2.Type__c, Product2.Room_Type__c, Product2.Current_Inventory__c, Product2.Available__c
                                               FROM PricebookEntry 
                                               WHERE Product2Id In :setChildProduct AND CurrencyIsoCode = :objQuote.CurrencyIsoCode 
                                               AND Pricebook2Id = :objQuote.Pricebook2Id AND Product2.IsActive = true 
                                               AND IsActive = true];
                
                /*mapPriceBookEntry = new Map<Id,PricebookEntry>();
                for(PricebookEntry objPBE: lstPBE){
                    mapPriceBookEntry(objPBE.Id, objPBE);
                }*/
                
                return lstPBE;
            }
        }
        
        return null;
    }
    
    /**
    * @description  : Method for get Related Hotel for Selected Package
    * @author       : fsuraitawala@addonblue.com
    * @param        : currentQuoteId(Quote Id)
    * @return       : List<PricebookEntry>
    **/
    @AuraEnabled 
    public static List<PricebookEntry> getProductRecords(String currentQuoteId) {
        System.debug(currentQuoteId);
        Quote objQuote = new Quote();
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            objQuote = [Select Id, CurrencyIsoCode, OpportunityId, Opportunity.CurrencyIsoCode, PriceBook2Id 
                        FROM Quote WHERE Id = :currentQuoteId];
            System.debug(objQuote);
            
            List<PricebookEntry> lstPBE = [SELECT Id, Name, Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice, IsActive, Product2.Recordtype.Name,
                                           Product2.Current_Inventory__c
                                           FROM PricebookEntry 
                                           WHERE Pricebook2Id = :objQuote.Pricebook2Id AND CurrencyIsoCode = :objQuote.CurrencyIsoCode 
                                           AND Product2.Recordtype.Name = 'Hotel' AND Product2.IsActive = true 
                                           AND IsActive = true];
            
            return lstPBE;
        }
        return null;
    }
    
    /**
    * @description  : Method for get Related Hotel of selected Package
    * @author       : fsuraitawala@addonblue.com
    * @param        : currentQuoteId
    * @param        : parentPackageId
    * @return       : List<PricebookEntry>
    **/
    @AuraEnabled 
    public static List<PricebookEntry> getRelatedHotelsRecords(String currentQuoteId, String parentPackageId) {
        System.debug(currentQuoteId);
        System.debug(parentPackageId);
        Quote objQuote = new Quote();
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            objQuote = [Select Id, CurrencyIsoCode, OpportunityId, Opportunity.CurrencyIsoCode, PriceBook2Id 
                        FROM Quote WHERE Id = :currentQuoteId];
            System.debug(objQuote);
            List<PricebookEntry> lstPBE = new List<PricebookEntry>();
            
            if(parentPackageId != null) {
                lstPBE = [SELECT Id, Name, Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice, IsActive, Product2.Recordtype.Name,
                          Product2.Current_Inventory__c
                          FROM PricebookEntry 
                          WHERE CurrencyIsoCode = :objQuote.CurrencyIsoCode AND Pricebook2Id =:objQuote.PriceBook2Id
                          AND Product2Id In (SELECT Child_product__c FROM Products_Bundle__c 
                          WHERE Parent_Product__c = :parentPackageId AND Type__c = 'Package Hotel') AND Product2.IsActive = true AND IsActive = true];
            } else {
                lstPBE = [SELECT Id, Name, Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice, IsActive, Product2.Recordtype.Name,
                          Product2.Current_Inventory__c
                          FROM PricebookEntry 
                          WHERE CurrencyIsoCode = :objQuote.CurrencyIsoCode AND Pricebook2Id =:objQuote.PriceBook2Id
                          AND Product2.Recordtype.Name = 'Hotel' AND Product2.A_La_Carte__c = true AND Product2.IsActive = true AND IsActive = true];
            }
            
            if(lstPBE.size() > 0) {
                Set<Id> setHotelIds = new Set<Id>();
                Set<Id> setParentProduct = new Set<Id>();
                
                for(PricebookEntry objPBE: lstPBE) {
                    setHotelIds.add(objPBE.Product2Id);
                }
                
                for(Products_Bundle__c obj: [SELECT Id, Name, Child_product__c, Child_product__r.Name, Parent_Product__c FROM Products_Bundle__c 
                                             WHERE Parent_Product__c IN :setHotelIds AND Type__c = 'Hotel Stay']) {
                    setParentProduct.add(obj.Parent_Product__c);
                }
                List<PricebookEntry> lstNewPBE = new List<PricebookEntry>();
                
                for(PricebookEntry objPBE: lstPBE) {
                    if(setParentProduct.contains(objPBE.Product2Id)) {
                        lstNewPBE.add(objPBE);
                    }
                }
                return lstNewPBE;
            }
            return lstPBE;
        }
        return null;
    }
    
    /**
    * @description  : Method for get Saved LineItems for Selected Package
    * @author       : fsuraitawala@addonblue.com
    * @param        : currentQuoteId
    * @param        : parentPackageId
    * @return       : List<SW_Utility_LEX.HotelBundleClass>
    **/
    @AuraEnabled 
    public static List<SW_Utility_LEX.HotelBundleClass> getRelatedLineItems(String currentQuoteId, String PackageLineItemId) {
        System.debug(PackageLineItemId);
        System.debug(currentQuoteId);
        List<QuoteLineItem> LineItemsRecord = new List<QuoteLineItem>();
        
        //LineItemBundleClass objBundle = new LineItemBundleClass();
        Map<String, SW_Utility_LEX.HotelBundleClass> MapHotelBundle = new Map<String, SW_Utility_LEX.HotelBundleClass>();
        List<SW_Utility_LEX.HotelBundleClass> HotelBundle = new List<SW_Utility_LEX.HotelBundleClass>();
        
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            for(QuoteLineItem objLineItem: [SELECT Id, PricebookEntryId, PricebookEntry.Name, Quantity, Quote_Package__c, Record_Type__c,
                                            Hotel_Package_Id__c, Room_Type__c, Room_Quantity__c, PricebookEntry_Name__c
                                            FROM QuoteLineItem 
                                            WHERE QuoteId = :currentQuoteId AND Quote_Package__c = :PackageLineItemId AND 
                                            (Record_Type__c = 'Package Hotel' OR Record_Type__c = 'Hotel Transportation' OR Record_Type__c = 'Hotel Stay')
                                            ORDER BY CreatedDate]) {
                if(PackageLineItemId == objLineItem.Quote_Package__c) {
                    SW_Utility_LEX.HotelBundleClass objHotelBundle = new SW_Utility_LEX.HotelBundleClass();
                    if(objLineItem.Record_Type__c == 'Package Hotel') {
                        objHotelBundle.Hotel = objLineItem;
                        MapHotelBundle.put(objLineItem.Id, objHotelBundle);
                    }
                    
                    if(objLineItem.Record_Type__c == 'Hotel Transportation') {
                        if(MapHotelBundle != null && MapHotelBundle.containskey(objLineItem.Hotel_Package_Id__c)){
                            objHotelBundle = MapHotelBundle.get(objLineItem.Hotel_Package_Id__c);
                            objHotelBundle.HotelTransportation = objLineItem;
                            objHotelBundle.HotelTransportations.add(objLineItem);
                            MapHotelBundle.put(objLineItem.Hotel_Package_Id__c, objHotelBundle);
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
                            objHotelBundle.HotelStay = objLineItem;
                            MapHotelBundle.put(objLineItem.Hotel_Package_Id__c, objHotelBundle);
                        }
                    }
                }
            }
            
            Map<String, List<Rooming_List__c>> mapRoomingList = new Map<String,List<Rooming_List__c>>();
            
            if(MapHotelBundle != null && MapHotelBundle.size() > 0) {
                for(Rooming_List__c obj: [SELECT Id, Name, Guest_Name__c, Number_of_Adults__c, QuoteLineItem_Id__c, Hotel_Package_Id__c, 
                                          Quote_Package__c
                                          FROM Rooming_List__c WHERE Hotel_Package_Id__c In :MapHotelBundle.keyset()]) {
                    List<Rooming_List__c> lstRooom = new List<Rooming_List__c>();
                    if(mapRoomingList != null && mapRoomingList.containskey(obj.Hotel_Package_Id__c)){
                        List<Rooming_List__c> lst = mapRoomingList.get(obj.Hotel_Package_Id__c);
                        lst.add(obj);
                        mapRoomingList.put(obj.Hotel_Package_Id__c, lst);
                    } else {
                        mapRoomingList.put(obj.Hotel_Package_Id__c, new List<Rooming_List__c>{obj});
                    }
                }
                HotelBundle = MapHotelBundle.values();
                System.debug(mapRoomingList);
                for(SW_Utility_LEX.HotelBundleClass obj : HotelBundle) {
                    if(mapRoomingList != null && mapRoomingList.containskey(obj.Hotel.Id)){
                        obj.RoomingList.addall(mapRoomingList.get(obj.Hotel.Id));
                        obj.oldRoomingList = new Map<Id, Rooming_List__c>(obj.RoomingList);
                        obj.RoomQty = mapRoomingList.get(obj.Hotel.Id).size();
                    }
                }
            }
        }
        return HotelBundle;
    }
    
    /**
    * @description  : Method for Save LineItems
    * @author       : fsuraitawala@addonblue.com
    * @param        : currentQuoteId
    * @param        : lstHotelBundles
    * @param        : isFromPackageTab
    * @param        : PackageLineItemId
    * @return       : String
    **/
    @AuraEnabled 
    public static String saveLineItemRecords(String currentQuoteId, List<SW_Utility_LEX.HotelBundleClass> lstHotelBundles, Boolean isFromPackageTab, String PackageLineItemId) {
        
        List<SW_Utility_LEX.HotelBundleClass> updateList = new List<SW_Utility_LEX.HotelBundleClass>();
        List<SW_Utility_LEX.HotelBundleClass> insertList = new List<SW_Utility_LEX.HotelBundleClass>();
        
        //try {
            for(SW_Utility_LEX.HotelBundleClass objBundle: lstHotelBundles) {
                System.debug('@@@@oldRoomingList: '+objBundle.oldRoomingList);
                if(objBundle.Hotel != null) {
                    if(objBundle.Hotel.Id != null) {
                        updateList.add(objBundle);
                    } else {
                        insertList.add(objBundle);
                    }
                }
            }
            
            if(updateList.size() > 0) {
                updateLineItem(currentQuoteId, updateList, isFromPackageTab, PackageLineItemId);
            }
            if(insertList.size() > 0) {
                insertLineItem(currentQuoteId, insertList, isFromPackageTab, PackageLineItemId);
            }
        /*} catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }*/
        
        return 'Success';
    }
    
    /**
    * @description  : Method for update Line Items
    * @author       : fsuraitawala@addonblue.com
    * @param        : currentQuoteId
    * @param        : lstHotelBundles
    * @param        : isFromPackageTab
    * @param        : PackageLineItemId
    * @return       : String
    **/
    @AuraEnabled 
    public static void updateLineItem(String currentQuoteId, List<SW_Utility_LEX.HotelBundleClass> lstHotelBundles, Boolean isFromPackageTab, String PackageLineItemId) {
        
        List<QuoteLineItem> upsertHotelQLI = new List<QuoteLineItem>();
        List<QuoteLineItem> insertStayQLI = new List<QuoteLineItem>();
        List<Rooming_List__c> updateRoomingList = new List<Rooming_List__c>();
        List<Rooming_List__c> newRoomingList = new List<Rooming_List__c>();
        List<Rooming_List__c> deleteRoomingList = new List<Rooming_List__c>();
        
        for(SW_Utility_LEX.HotelBundleClass objBundle: lstHotelBundles) {
            Integer oldRoomQuantity = objBundle.Hotel.Room_Quantity__c != null ? (Integer) objBundle.Hotel.Room_Quantity__c : 0;
            System.debug(oldRoomQuantity);
            System.debug(objBundle.RoomQty);
            System.debug(objBundle.oldRoomingList);
            if(oldRoomQuantity != objBundle.RoomQty) {
                if(objBundle.RoomQty != null && objBundle.RoomQty > 0) {
                    //#731 Extra Rooming List records related to change orders
                    objBundle.Hotel.Room_Quantity__c = objBundle.RoomQty;
                    if(objBundle.RoomQty > oldRoomQuantity) {
                        Integer diff = objBundle.RoomQty - oldRoomQuantity;
                        for(Integer i = 0; i < diff; i++) {
                            QuoteLineItem newQLI = new QuoteLineItem();
                            newQLI.QuoteId = currentQuoteId;
                            newQLI.Quantity = 1;
                            newQLI.UnitPrice = 0;
                            newQLI.PriceBookEntryId = objBundle.HotelStay.PricebookEntryId;
                            newQLI.Quote_Package__c = objBundle.Hotel.Quote_Package__c;
                            newQLI.Hotel_Package_Id__c = objBundle.Hotel.Id;
                            newQLI.Room_Quantity__c = objBundle.RoomQty;
                            if(isFromPackageTab) {
                                newQLI.Record_Type__c = 'Hotel Stay';
                            } else {
                                newQLI.Record_Type__c = 'A La Carte';
                            }
                            insertStayQLI.add(newQLI);
                        }
                    }
                    if(objBundle.RoomQty < oldRoomQuantity) {
                        Integer diff = oldRoomQuantity - objBundle.RoomQty;
                        System.debug(objBundle.oldRoomingList);
                        List<Rooming_List__c> lstRoomingList = new List<Rooming_List__c>();
                        if(objBundle.oldRoomingList != null && objBundle.oldRoomingList.size() > 0) {
                            lstRoomingList = objBundle.oldRoomingList.values();
                        }
                        
                        for(Integer i = lstRoomingList.size(); i > objBundle.RoomQty; i--){
                            System.debug(lstRoomingList[i-1]);
                            deleteRoomingList.add(lstRoomingList[i-1]);
                        }
                    }
                    
                    System.debug('@@@@insertStayQLI: '+insertStayQLI);
                } else {
                    objBundle.Hotel.Room_Quantity__c = 0;
                    System.debug('@@@@Delete: '+ objBundle.oldRoomingList);
                    if(objBundle.oldRoomingList != null && objBundle.oldRoomingList.size() > 0) {
                        deleteRoomingList.addall(objBundle.oldRoomingList.values());
                    }
                    System.debug('@@@@deleteRoomingList : '+deleteRoomingList);
                }
                System.debug('@@@deleteRoomingList: '+deleteRoomingList);
                upsertHotelQLI.add(objBundle.Hotel);
            }
            
            //Transportation Line Items
            for(QuoteLineItem objLineItem: objBundle.HotelTransportations) {
                if(objLineItem.Id == null) {
                    objLineItem.QuoteId = objBundle.Hotel.QuoteId;
                    objLineItem.UnitPrice = 0;
                    objLineItem.Quote_Package__c = objBundle.Hotel.Quote_Package__c;
                    objLineItem.Hotel_Package_Id__c = objBundle.Hotel.Id;
                    if(isFromPackageTab) {
                        objLineItem.Record_Type__c = 'Hotel Transportation';
                    } else {
                        objLineItem.Record_Type__c = 'A La Carte';
                    }
                }
                upsertHotelQLI.add(objLineItem);
            }
            
            for(Rooming_List__c objRooming :objBundle.RoomingList) {
                if(objRooming.Id != null) {
                    updateRoomingList.add(objRooming);
                } else {
                    //objRooming.QuoteLineItem_Id__c = lstRoomQLI[i].Id;
                    objRooming.Quote_Package__c = objBundle.Hotel.Quote_Package__c;
                    objRooming.Hotel_Package_Id__c = objBundle.Hotel.Id;
                    objRooming.Quote__c = currentQuoteId;
                    newRoomingList.add(objRooming);
                }
            }
        }
        
        
        if(insertStayQLI.size() > 0) {
            insert insertStayQLI;
            insertStayQLI = [Select Id, Product2Id, Quote_Package__c, Hotel_Package_Id__c, Quantity From QuoteLineItem Where Id IN :insertStayQLI ORDER BY CreatedDate];
            Integer i = 0;
            for(Rooming_List__c objRooming: newRoomingList) {
                if(insertStayQLI != null && insertStayQLI.size() > i) {
                    objRooming.QuoteLineItem_Id__c = insertStayQLI[i].Id;
                    objRooming.Product__c = insertStayQLI[i].Product2Id;
                    objRooming.Quantity__c = insertStayQLI[i].Quantity;
                }
                i++;
            }
        }
        
        if(upsertHotelQLI.size() > 0) {
            upsert upsertHotelQLI;
        }
        
        if(newRoomingList != null && newRoomingList.size() > 0){
            updateRoomingList.addall(newRoomingList);
        }
        if(updateRoomingList.size() > 0) {
            upsert updateRoomingList;
        } 
        if(deleteRoomingList.size() > 0){
            List<QuoteLineItem> DeleteLineItem = new List<QuoteLineItem>();
            for(Rooming_List__c objRooming: deleteRoomingList){
                if(objRooming.QuoteLineItem_Id__c != null) {
                    QuoteLineItem obj = new QuoteLineItem();
                    obj.Id = objRooming.QuoteLineItem_Id__c;
                    DeleteLineItem.add(obj);
                }
            }
            delete deleteRoomingList;
            if(DeleteLineItem != null && DeleteLineItem.size() > 0) {
                Delete DeleteLineItem;
            }
            
        }
    }
    
    /**
    * @description  : Method for insert LineItems records
    * @author       : fsuraitawala@addonblue.com
    * @param        : currentQuoteId
    * @param        : lstHotelBundles
    * @param        : isFromPackageTab
    * @param        : PackageLineItemId
    * @return       : String
    **/
    @AuraEnabled 
    public static void insertLineItem(String currentQuoteId, List<SW_Utility_LEX.HotelBundleClass> lstHotelBundles, Boolean isFromPackageTab, String PackageLineItemId) {
        List<QuoteLineItem> lstQuoteLineItem = new List<QuoteLineItem>();
        List<QuoteLineItem> lstRoomQLI = new List<QuoteLineItem>();
        List<QuoteLineItem> lstHotelQLI = new List<QuoteLineItem>();
        
        try {
            for(SW_Utility_LEX.HotelBundleClass objBundle: lstHotelBundles) {
                QuoteLineItem HotelQLI = new QuoteLineItem();
                if(objBundle.Hotel.Id == null) {
                    HotelQLI.QuoteId = currentQuoteId;
                    HotelQLI.Quote_Package__c = PackageLineItemId;
                    //#827 Set 'A La Carte' record type if adding hotel from "Add Hotel"
                    if(isFromPackageTab) {
                        HotelQLI.Record_Type__c = 'Package Hotel';
                    } else {
                        HotelQLI.Record_Type__c = 'A La Carte';
                    }
                    HotelQLI.Quantity = 1;
                    HotelQLI.UnitPrice = 0;
                    HotelQLI.PriceBookEntryId = objBundle.Hotel.PricebookEntryId;
                    HotelQLI.Room_Type__c = objBundle.Hotel.Room_Type__c;
                    if(objBundle.RoomQty != null && objBundle.RoomQty > 0) {
                        HotelQLI.Room_Quantity__c = objBundle.RoomQty;
                    } else {
                        HotelQLI.Room_Quantity__c = 0;
                    }
                    lstHotelQLI.add(HotelQLI);
                }
            }
            System.debug(lstHotelQLI);
            if(lstHotelQLI.size() > 0) {
                insert lstHotelQLI;
            }
            
            Integer j = 0;
            for(SW_Utility_LEX.HotelBundleClass obj: lstHotelBundles) {
                System.debug(obj);
                System.debug(obj.HotelTransportations);
                System.debug(lstHotelQLI[j]);
                
                if(obj.HotelTransportations != null) {
                    for(QuoteLineItem objLineItem: obj.HotelTransportations) {
                        System.debug(objLineItem);
                        if(objLineItem.PricebookEntryId != null) {
                            if(objLineItem.Id == null) {
                                objLineItem.QuoteId = currentQuoteId;
                                objLineItem.UnitPrice = 0;
                                //objLineItem.PriceBookEntryId = obj.HotelTransportation.PricebookEntryId;
                                objLineItem.Quote_Package__c = PackageLineItemId;
                                objLineItem.Hotel_Package_Id__c = lstHotelQLI[j].Id;
                                if(isFromPackageTab) {
                                    objLineItem.Record_Type__c = 'Hotel Transportation';
                                } else {
                                    objLineItem.Record_Type__c = 'A La Carte';
                                }
                            }
                            System.debug(objLineItem);
                            lstQuoteLineItem.add(objLineItem);
                        }
                    }
                }
                
                if(obj.RoomQty != null && obj.RoomQty > 0 && obj.HotelStay != null) {
                    for(Integer i = 0; i < obj.RoomQty; i++) {
                        QuoteLineItem newQLI = new QuoteLineItem();
                        newQLI.QuoteId = currentQuoteId;
                        newQLI.Quantity = 1;
                        newQLI.UnitPrice = 0;
                        newQLI.PriceBookEntryId = obj.HotelStay.PricebookEntryId;
                        newQLI.Quote_Package__c = PackageLineItemId;
                        newQLI.Hotel_Package_Id__c = lstHotelQLI[j].Id;
                        newQLI.Room_Quantity__c = obj.RoomQty;
                        if(isFromPackageTab) {
                            newQLI.Record_Type__c = 'Hotel Stay';
                        } else {
                            newQLI.Record_Type__c = 'A La Carte';
                        }
                        lstRoomQLI.add(newQLI);
                    }
                }
                j++;
            }
            
            System.debug(lstRoomQLI.size());
            System.debug(lstRoomQLI);
            if(lstRoomQLI != null && lstRoomQLI.size() > 0) {
                insert lstRoomQLI;
                lstRoomQLI = [Select Id, Product2Id, Quote_Package__c, Hotel_Package_Id__c, Quantity FROM QuoteLineItem WHERE Id IN :lstRoomQLI ORDER BY CreatedDate];
            }
            System.debug(lstQuoteLineItem);
            if(lstQuoteLineItem != null && lstQuoteLineItem.size() > 0) {
                insert lstQuoteLineItem;
            }
            Integer i = 0;
            List<Rooming_List__c> lstRoomingList = new List<Rooming_List__c>();
            for(SW_Utility_LEX.HotelBundleClass obj: lstHotelBundles) {
                for(Rooming_List__c objRooming: obj.RoomingList) {
                    if(lstRoomQLI != null && lstRoomQLI.size() > i) {
                        System.debug('@@@@ : '+lstRoomQLI[i]);
                        System.debug('@@@@ : '+objRooming);
                        objRooming.QuoteLineItem_Id__c = lstRoomQLI[i].Id;
                        objRooming.Quote_Package__c = lstRoomQLI[i].Quote_Package__c;
                        objRooming.Hotel_Package_Id__c = lstRoomQLI[i].Hotel_Package_Id__c;
                        objRooming.Quote__c = currentQuoteId;
                        objRooming.Product__c = lstRoomQLI[i].Product2Id;
                        objRooming.Quantity__c = lstRoomQLI[i].Quantity;
                    }
                    lstRoomingList.add(objRooming);
                    i++;
                }
            }
            
            if(lstRoomingList != null && lstRoomingList.size() > 0) {
                System.debug(lstRoomingList);
                insert lstRoomingList;
            }
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
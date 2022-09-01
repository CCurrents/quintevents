/**
 * @File Name          : Quote_Summary_Tab_LEX.cls
 * @Description        : This class use for Package Tab in Sales Wizard.
 * @Author             : fsuraitawalal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 06-29-2021
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    15/10/2019   fsuraitawalal@addonblue.com     Initial Version
**/
global class Quote_Summary_Tab_LEX {
    /**
    * @description #535 Do not allow to Edit Quote once it's Signed Approved
    * @author fsuraitawala@addonblue.com | 12-16-2020
    * @param currentRecordId
    * @return Quote
    **/
    @AuraEnabled 
    global static Quote getQuoteWithData(String currentRecordId) {
        Quote objQuote = new Quote();
        if(currentRecordId != null && currentRecordId.startswith('0Q0')) {
            objQuote = [Select Id, Name, Status, Opportunity.Pricebook2Id, Pricebook2Id, Pricebook2.Program__c, Pricebook2.Program__r.Name, CurrencyIsoCode 
                        FROM Quote 
                        WHERE Id =: currentRecordId];
        }
        return objQuote;
    }

    /****************************************************************************/
    @AuraEnabled 
    global static List<QuoteLineItem> getRelatedLineItems(String currentQuoteId) {
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            return [SELECT Id, LineNumber, QuoteId, PricebookEntryId, PricebookEntry.Name, Quantity, Product2Id, Product2.Name, Product2.RecordType.Name, 
                    Quote_Package__c, Record_Type__c, Hotel_Package_Id__c, Room_Quantity__c
                    FROM QuoteLineItem WHERE QuoteId = :currentQuoteId ORDER BY CreatedDate];
        }
        return null;
    }
    
    /****************************************************************************/
    @AuraEnabled 
    global static List<LineItemBundleClass> deleteQuoteLineItems(String currentQuoteId, QuoteLineItem selectedLineItem) {
        QuoteLineItem currentLineItem = new QuoteLineItem();
        List<QuoteLineItem> deleteItems = new List<QuoteLineItem>();
        
        try {
            List<QuoteLineItem> lstLineItems = getRelatedLineItems(currentQuoteId);
            for(QuoteLineItem obj: lstLineItems) {
                if(selectedLineItem.Id == obj.Id) {
                    currentLineItem = obj;
                    deleteItems.add(obj);
                    break;
                }
            }
            /*for(QuoteLineItem obj: lstLineItems) {
                
                if(currentLineItem.Product2.RecordType.Name == 'Package' && obj.Quote_Package__c != null && obj.Quote_Package__c == currentLineItem.Id) {
                    deleteItems.add(obj);
                }
                
                if(currentLineItem.Product2.RecordType.Name == 'Hotel' && obj.Hotel_Package_Id__c != null && obj.Hotel_Package_Id__c == currentLineItem.Id) {
                    deleteItems.add(obj);
                }
            }*/
            
            if(deleteItems.size() > 0) {
                TriggerHandler.allowToDelete = true;
                delete deleteItems;
            }
            
            /*List<Rooming_List__c> lstRooming = new List<Rooming_List__c>();
            if(currentLineItem.Product2.RecordType.Name == 'Hotel'){
                lstRooming = [SELECT Id, Hotel_Package_Id__c FROM Rooming_List__c WHERE Hotel_Package_Id__c = :currentLineItem.Id];
            }
            if(currentLineItem.Product2.RecordType.Name == 'Package'){
                lstRooming = [SELECT Id, Hotel_Package_Id__c FROM Rooming_List__c WHERE Quote_Package__c = :currentLineItem.Id];
            }
            
            if(lstRooming != null && lstRooming.size() > 0) {
                delete lstRooming;
            }*/
            return getQuoteLineItems(currentQuoteId);
            
        } catch(Exception Ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /****************************************************************************/
    @AuraEnabled 
    global static List<LineItemBundleClass> getQuoteLineItems(String currentQuoteId) {
        
        Map<String,LineItemBundleClass> MapLineItemBundle = new Map<String,LineItemBundleClass>();
        List<QuoteLineItem> lstLineItem = new List<QuoteLineItem>();
        
        if(currentQuoteId != null && currentQuoteId.startswith('0Q0')) {
            lstLineItem = [SELECT Id, LineNumber, QuoteId, PricebookEntryId, PricebookEntry.Name, Quantity, Quote_Package__c, Room_Quantity__c,
                                            Product2Id, Product2.Name, Product2.RecordType.Name, Product2.Type__c, Record_Type__c, Hotel_Package_Id__c
                                            FROM QuoteLineItem WHERE QuoteId = :currentQuoteId ORDER BY CreatedDate];
            
            for(QuoteLineItem objLineItem: lstLineItem) {
                
                LineItemClass objLI = new LineItemClass();
                objLI.LineItem = objLineItem;
                objLI.IsUpdatable = false;
                objLI.IsBold = false;
                
                LineItemBundleClass objLIBundle = new LineItemBundleClass();
                
                if(objLineItem.Record_Type__c == 'Package' || (objLineItem.Record_Type__c == 'A La Carte' && String.isBlank(objLineItem.Hotel_Package_Id__c))
                   || (objLineItem.Product2.RecordType.Name == 'Hotel' && String.isBlank(objLineItem.Quote_Package__c))
                   || (objLineItem.Record_Type__c == 'A La Carte' && (objLineItem.Product2.Type__c == 'Discount' || objLineItem.Product2.Type__c == 'Reward Discount'))) {
                    objLI.IsUpdatable = true;
                    if(objLineItem.Product2.Type__c == 'Shipping and Handling'){
                        objLI.IsUpdatable = false;
                    }
                    objLI.IsBold = true;
                    objLIBundle.ParentPackage = objLI;
                    MapLineItemBundle.put(objLineItem.Id, objLIBundle);
                }
            }
        }
        Set<String> setPBE = new Set<String>();
        for(QuoteLineItem objLineItem: lstLineItem) {
            LineItemClass objLI = new LineItemClass();
            objLI.LineItem = objLineItem;
            objLI.IsUpdatable = false;
            objLI.IsBold = false;
            LineItemBundleClass objLIBundle = new LineItemBundleClass();
            
            if(objLineItem.Record_Type__c == 'A La Carte' && String.isNotBlank(objLineItem.Hotel_Package_Id__c) 
                && MapLineItemBundle.containsKey(objLineItem.Hotel_Package_Id__c)) {
                objLIBundle = MapLineItemBundle.get(objLineItem.Hotel_Package_Id__c);
                if(!setPBE.contains(objLineItem.PricebookEntryId+objLineItem.Hotel_Package_Id__c)){
                    objLIBundle.ChildLineItems.add(objLI);
                    setPBE.add(objLineItem.PricebookEntryId+objLineItem.Hotel_Package_Id__c);
                }
            }
            
            if(String.isNotBlank(objLineItem.Quote_Package__c) && MapLineItemBundle.containsKey(objLineItem.Quote_Package__c)) {
                objLIBundle = MapLineItemBundle.get(objLineItem.Quote_Package__c);
                if(objLineItem.Record_Type__c == 'Package Product') {
                    objLIBundle.ChildLineItems.add(objLI);
                }
                HotelBundleClass objHotelBundle = new HotelBundleClass();
                //#731 Extra roominng list change
                if(objLineItem.Record_Type__c == 'Package Hotel') {
                    objLI.IsUpdatable = true;
                    objLI.IsBold = true;
                    if(objLIBundle.mapHotelBundle != null && objLIBundle.mapHotelBundle.containskey(objLineItem.Id)){
                        objHotelBundle = objLIBundle.mapHotelBundle.get(objLineItem.Id);
                        objHotelBundle.Hotel = objLI;
                    } else {
                        objHotelBundle.Hotel = objLI;
                    }
                    objLIBundle.mapHotelBundle.put(objLineItem.Id, objHotelBundle);
                }
                
                if(objLineItem.Record_Type__c == 'Hotel Transportation') {
                    objLI.IsUpdatable = false;
                    if(objLIBundle.mapHotelBundle != null && objLIBundle.mapHotelBundle.containskey(objLineItem.Hotel_Package_Id__c)){
                        objHotelBundle = objLIBundle.mapHotelBundle.get(objLineItem.Hotel_Package_Id__c);
                        objHotelBundle.HotelTransportations.add(objLI);
                        objLIBundle.mapHotelBundle.put(objLineItem.Hotel_Package_Id__c, objHotelBundle);
                    } else {
                        objHotelBundle.HotelTransportations.add(objLI);
                        objLIBundle.mapHotelBundle.put(objLineItem.Hotel_Package_Id__c, objHotelBundle);
                    }
                }
                
                if(objLineItem.Record_Type__c == 'Hotel Stay') {
                    objLI.IsUpdatable = false;
                    if(objLIBundle.mapHotelBundle != null && objLIBundle.mapHotelBundle.containskey(objLineItem.Hotel_Package_Id__c)){
                        objHotelBundle = objLIBundle.mapHotelBundle.get(objLineItem.Hotel_Package_Id__c);
                        objHotelBundle.HotelStay = objLI;
                        objLIBundle.mapHotelBundle.put(objLineItem.Hotel_Package_Id__c, objHotelBundle);
                    } else {
                        objHotelBundle.HotelStay = objLI;
                        objLIBundle.mapHotelBundle.put(objLineItem.Hotel_Package_Id__c, objHotelBundle);
                    }
                }
                if(objLineItem.Record_Type__c == 'Addon') {
                    objLI.IsUpdatable = true;
                    objLIBundle.AddonLineItems.add(objLI);
                }
            }
        }
        
        for(LineItemBundleClass obj: MapLineItemBundle.values()){
            if(obj.mapHotelBundle != null && obj.mapHotelBundle.size() > 0) {
                Map<String, HotelBundleClass> tempHotelBundle = new Map<String, HotelBundleClass>();
                for(HotelBundleClass o: obj.mapHotelBundle.values()){
                    if(tempHotelBundle != null && tempHotelBundle.containskey(o.Hotel.LineItem.PricebookEntryId)) {
                        HotelBundleClass objHotelBundle = tempHotelBundle.get(o.Hotel.LineItem.PricebookEntryId);
                        objHotelBundle.HotelTransportations.add(o.HotelStay);
                        objHotelBundle.HotelTransportations.addall(o.HotelTransportations);
                        tempHotelBundle.put(o.Hotel.LineItem.PricebookEntryId, objHotelBundle);
                    } else {
                        tempHotelBundle.put(o.Hotel.LineItem.PricebookEntryId, o);
                    }
                }
                
                obj.HotelBundle = tempHotelBundle.values();
            }
        }
        return MapLineItemBundle.values();
    }
    
    /*********************** wrapper class ***********************************/
    global class LineItemBundleClass {
        @AuraEnabled global LineItemClass ParentPackage{get;set;}
        @AuraEnabled global List<LineItemClass> ChildLineItems{get;set;}
        @AuraEnabled global Map<String,HotelBundleClass> mapHotelBundle{get;set;}
        @AuraEnabled global List<HotelBundleClass> HotelBundle{get;set;}
        @AuraEnabled global List<LineItemClass> AddonLineItems{get;set;}
        
        global LineItemBundleClass() {
            ParentPackage = new LineItemClass();
            ChildLineItems = new List<LineItemClass>();
            mapHotelBundle = new Map<String,HotelBundleClass>();
            HotelBundle = new List<HotelBundleClass>();
            AddonLineItems = new List<LineItemClass>();
        }
    }
    
    global class HotelBundleClass {
        @AuraEnabled global LineItemClass Hotel {get;set;}
        @AuraEnabled global LineItemClass HotelStay {get;set;}
        @AuraEnabled global LineItemClass HotelTransportation {get;set;}
        @AuraEnabled global List<LineItemClass> HotelTransportations{get;set;}
        
        global HotelBundleClass() {
            Hotel = new LineItemClass();
            HotelStay = new LineItemClass();
            HotelTransportation = new LineItemClass();
            HotelTransportations = new List<LineItemClass>();
        }
    }
    
    global class LineItemClass {
        @AuraEnabled global QuoteLineItem LineItem{get;set;}
        @AuraEnabled global Boolean IsUpdatable{get;set;}
        @AuraEnabled global Boolean IsBold{get;set;}
        @AuraEnabled global Boolean IsHide{get;set;}
        
        global LineItemClass() {
            LineItem = new QuoteLineItem();
            IsUpdatable = false;
            IsBold = false;
        }
    }
    
}
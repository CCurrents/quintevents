/**
 * @File Name          : SW_Utility_LEX.cls
 * @Description        : 
 * @Author             : fsuraitawalal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawalal@addonblue.com
 * @Last Modified On   : 28/2/2020
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    26/12/2019   fsuraitawalal@addonblue.com     Initial Version
**/
global class SW_Utility_LEX {
    
    /**
    * @description  : no-arg constructor
    * @author       : fsuraitawala@addonblue.com
    **/
    global SW_Utility_LEX() {
        //No-arg constructor
    }
    
    /**
    * @description  : Use to fill pickListValues
    * @author       : fsuraitawala@addonblue.com
    **/
    global class customOptionClass {
        @AuraEnabled global String label {get;set;}
        @AuraEnabled global String value {get;set;}
        global customOptionClass() {
            this.label = label;
            this.value = value;
        }
    }
    
    /**
    * @description  : Addon Product
    * @author       : fsuraitawala@addonblue.com
    **/
    global class addonListClass {
        @AuraEnabled global QuoteLineItem QuoteLineItem {get;set;}
        @AuraEnabled global String ProductName {get;set;}
        
        global addonListClass() {
            QuoteLineItem = new QuoteLineItem();
            this.ProductName = ProductName;
        }
    }
    
    /**
    * @description  : aLaCarte Product
    * @author       : fsuraitawala@addonblue.com
    **/
    global class aLaCarteObjClass {
        @AuraEnabled global String ProductName {get;set;}
        @AuraEnabled global QuoteLineItem QuoteLineItem {get;set;}
        @AuraEnabled global String ProductType {get;set;}
        
        global aLaCarteObjClass() {
            QuoteLineItem = new QuoteLineItem();
            this.ProductName = ProductName;
            this.ProductType = ProductType;
        }
    }
    
    /**
    * @description  : Hotel Product
    * @author       : fsuraitawala@addonblue.com
    **/
    global class HotelBundleClass {
        @AuraEnabled global QuoteLineItem Hotel{get;set;}
        @AuraEnabled global QuoteLineItem HotelStay{get;set;}
        @AuraEnabled global QuoteLineItem HotelTransportation{get;set;} 
        @AuraEnabled global List<QuoteLineItem> HotelTransportations{get;set;}
        @AuraEnabled global Integer RoomQty {get;set;}
        @AuraEnabled global Integer TransQty {get;set;}
        @AuraEnabled global String RoomType {get;set;}
        @AuraEnabled global List<Rooming_List__c> RoomingList{get;set;}
        @AuraEnabled global Map<Id, Rooming_List__c> oldRoomingList{get;set;}
        
        global HotelBundleClass() {
            Hotel = new QuoteLineItem();
            HotelStay = new QuoteLineItem();
            HotelTransportation = new QuoteLineItem();
            HotelTransportations = new List<QuoteLineItem>();
            this.RoomQty = RoomQty;
            this.TransQty = TransQty;
            this.RoomType = RoomType;
            RoomingList = new List<Rooming_List__c>();
            oldRoomingList = new Map<Id, Rooming_List__c>();
        }
    }
    
    /**
    * @description  : Common Product Tab
    * @author       : fsuraitawala@addonblue.com
    **/
    global class LineItemBundleClass {
        @AuraEnabled global QuoteLineItem ParentPackage{get;set;}
        @AuraEnabled global List<QuoteLineItem> ChildLineItems{get;set;}
        @AuraEnabled global List<SW_Utility_LEX.HotelBundleClass> HotelBundle{get;set;}
        @AuraEnabled global List<QuoteLineItem> AddonLineItems{get;set;}
        
        global LineItemBundleClass() {
            ParentPackage = new QuoteLineItem();
            ChildLineItems = new List<QuoteLineItem>();
            HotelBundle = new List<SW_Utility_LEX.HotelBundleClass>();
            AddonLineItems = new List<QuoteLineItem>();
        }
    }
    
    /**
    * @description  : Review Quote WrapperClass
    * @author       : fsuraitawala@addonblue.com
    **/
    global class ReviewQuoteWrapperClass {
        @AuraEnabled global List<QuoteLineItem> hotelPackageQuoteLineItem{get;set;}
        @AuraEnabled global Quote quote{get;set;}
        @AuraEnabled global List<QuoteLineItem> discountQuoteLineItem{get;set;}
        @AuraEnabled global List<OpportunityContactRole> oppContactRoleList{get;set;}
        @AuraEnabled global List<Payment_Term__c> opportunityPaymentTermList{get;set;}
        @AuraEnabled global Decimal totalPaymenttermAmount{get;set;}
        @AuraEnabled global Boolean isDowngradeQuote{get;set;} 
        @AuraEnabled global Boolean isOrderExist{get; set;}
        @AuraEnabled global Boolean isDepositQuoteValidation{get; set;}
        
        global ReviewQuoteWrapperClass() {
            //No Arg-Constructor
        }
        global ReviewQuoteWrapperClass(List<QuoteLineItem> hotelPackageQuoteLineItem, Quote quote, List<QuoteLineItem> discountQuoteLineItem, List<OpportunityContactRole> oppContactRoleList, List<Payment_Term__c> opportunityPaymentTermList, Decimal totalPaymenttermAmount){
            this.hotelPackageQuoteLineItem = hotelPackageQuoteLineItem;
            this.quote = quote;
            this.discountQuoteLineItem = discountQuoteLineItem;
            this.oppContactRoleList = oppContactRoleList;
            this.opportunityPaymentTermList = opportunityPaymentTermList;
            this.totalPaymenttermAmount  = totalPaymenttermAmount;
        }
    }
    
    /**
    * @description  : Reward Discount Tab
    * @author       : fsuraitawala@addonblue.com
    **/
    global class RewardPointsClass {
        @AuraEnabled global Decimal maxUsablePoints {get;set;}
        @AuraEnabled global Decimal minUsablePoints {get;set;}
        
        global RewardPointsClass() {
            maxUsablePoints = 0;
            minUsablePoints = 50;
        }
    }
    
    /**
    * @description  : LineItemBundles
    * @author       : fsuraitawala@addonblue.com
    **/
    global class LineItemBundles {
        @AuraEnabled global QuoteLineItem DiscountLineItem {get;set;}
        @AuraEnabled global QuoteLineItem RewardLineItem {get;set;}
        
        global LineItemBundles() {
            DiscountLineItem = new QuoteLineItem();
            RewardLineItem = new QuoteLineItem();
        }
    }
    
    /**
    * @description  : Product List Wrapper
    * @author       : fsuraitawala@addonblue.com
    **/
    global class productListWrapper {
        @AuraEnabled global boolean isChecked {get;set;}
        @AuraEnabled global  Product2 objProduct{get;set;}
        global productListWrapper(boolean isChecked, Product2 objProduct){
            this.isChecked = isChecked;
            this.objProduct = objProduct;
        }
        global productListWrapper(){}
    }

}
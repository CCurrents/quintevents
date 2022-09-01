/* ====================================================
@Name:  QE_QuoteCreatePDFClass
@Copyright notice: 
Copyright (c) 2016, developed by
    All rights reserved.
    
    Redistribution and use in source and binary forms, 
  with or without modification, are not permitted.                                                                                                    
@======================================================
@======================================================
@Purpose: 
@======================================================
@======================================================
@History                                                                                                                    
@---------                                                                                                                       
@VERSION________AUTHOR______________DATE______________DETAIL                   
 1.0        Sundar Subramaniam   19/12/2016      INITIAL DEVELOPMENT                                 
   
@======================================================= */
public class QE_QuoteCreatePDFClass {

    // public List<QuoteLineItem> packages {get; set;}
    // public List<QuoteLineItem> aLaCartes {get; set;}
    // public List<QuoteLineItem> hotels {get; set;}
    // public List<QuoteLineItem> hospitality {get; set;}
    // public List<QuoteLineItem> hotelsWithRoomRequest {get; set;}
    // public List<QuoteLineItem> transportations {get; set;}
    // public Map<Id,List<QuoteLineItem>> packageProductsByPackageId {get; set;}
    // public Quote quote { get; set; }
    // public Website__c wb {get;set;}
    // public String currencySymbol {get; set;}
    // public boolean blnproductid {get; set;}
    // public boolean isParkingPassIncluded {get; set;}
    // public boolean displayHospitalitySeparatly {get; set;}
    // public List<OpportunityLineItem> opplineItems {get; set;}

    public QE_QuoteCreatePDFClass(ApexPages.StandardController controller) {
        // system.debug('call');
        // // Get quote id from url and query quote and related data. 
        // Id id = ApexPages.currentPage().getParameters().get('id');
        // oppHMapQuantity = new Map<Id,Map<Id,Decimal >>();
        // blnproductid = false;
        // isParkingPassIncluded = false;
        // quote = [
        //     select Id,Opportunity.Show_Price_Details_on_Quote__c, opportunity.contact_site__c,Opportunity.Event__r.Logo__c, Opportunity.Event__r.Processing_Fee__c,
        //         Opportunity.Event__r.Name, Opportunity.Event__r.International_Stripe__c, Opportunity.Event__r.Quote_Custom_Text__c,Opportunity.Event__r.Deposit_T_C__c,
        //         Opportunity.Event__r.Terms_and_Conditions__c,Opportunity.Event__r.Program__r.Name,Opportunity.RecordType.DeveloperName,
        //         Opportunity.Language__c,Opportunity.Event__r.Terms_and_Conditions_FR__c,Opportunity.Event__r.Terms_and_Conditions_DE__c, ShippingName, ShippingStreet,
        //         Opportunity.Event__r.Terms_And_Conditions_ZH__c,Opportunity.Event__r.Terms_And_Conditions_JA__c,Opportunity.Event__r.Terms_And_Conditions_IT__c,
        //         Opportunity.Event__r.Terms_And_Conditions_AR__c,Opportunity.Event__r.Terms_And_Conditions_ES__c,Opportunity.Event__r.Location__c,
        //         Opportunity.Event__r.Addendum_A_Waiver_ZH__c,Opportunity.Event__r.Addendum_A_Waiver_JA__c,
        //         Opportunity.Event__r.Addendum_A_Waiver_IT__c,Opportunity.Event__r.Addendum_A_Waiver_FR__c,
        //         Opportunity.Event__r.Addendum_A_Waiver_ES__c,Opportunity.Event__r.Addendum_A_Waiver_DE__c,
        //         Opportunity.Event__r.Addendum_A_Waiver_AR__c,Opportunity.Event__r.Addendum_A_Waiver__c,
        //         ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
        //         GrandTotal, Grand_Total__c, Phone, Email, Payment_Method__c, BillingName, 
        //         Opportunity.Owner.Name, Opportunity.Owner.Phone, Opportunity.Owner.Email,
        //         BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
        //         Opportunity.Payment_Terms__c, Opportunity.Custom_Payment_Terms__c, Comment__c, Opportunity.Pick_Up__c,
        //         A_La_Carte_Sub_Total__c, Package_Sub_Total__c,Primary_Contact__c, Opportunity.Online_Order__c,
        //         Shipping_and_Handling__c, Taxes__c, VAT_Tax__c, CurrencyIsoCode,CreatedDate, Opportunity.Addendum_A_Waiver__c,
        //         Opportunity.Commission_Rate__c, Processing_Fee__c,Opportunity.Primary_Attendee_Name__c, Event__r.Display_Hospitality_Separately_on_PDF__c, Opportunity.Terms_And_Conditions__c, Opportunity.CurrencyISOCode
        //         // , 
        //         // (
        //         //     Select Id, Record_Type__c, Quantity, ListPrice_Used__c, Total_Tax_Amount__c, Total_VAT_Tax__c,
        //         //         TotalPrice, Quote_Product_Package_Hotel__c, Product2.Name, Product2Id, ProductType__c, Product2.Display_On_Contract__c,Product2.Display_Name__c,Product2.Event__r.GPE_Event__c,
        //         //         Product2.Short_Description__c, Quote_Package__c, OpportunityLineItemId, Room_Type__c, Total_Processing_Fee_Amount__c, Product2.Type__c                      
        //         //     FROM QuoteLineItems
        //         // )
        //     from Quote
        //     where Id = :id
        // ];
        // List<QuoteLineItem> qliList = [Select Id, Record_Type__c, Quantity, ListPrice_Used__c, Total_Tax_Amount__c, Total_VAT_Tax__c,
        //                 TotalPrice, Quote_Product_Package_Hotel__c, Product2.Name, Product2Id, ProductType__c, Product2.Display_On_Contract__c,Product2.Display_Name__c,Product2.Event__r.GPE_Event__c,
        //                 Product2.Short_Description__c, Quote_Package__c, OpportunityLineItemId, Room_Type__c, Total_Processing_Fee_Amount__c, Product2.Type__c                      
        //             FROM QuoteLineItem where Quoteid =: quote.Id];

        // Opportunity oppList = [Select Id,(Select Id,Product2Id,Description from OpportunityLineItems) from Opportunity where Id =: quote.OpportunityId];        
        // opplineItems = new List<OpportunityLineItem>();     
        // opplineItems = oppList.OpportunityLineItems;
        
        // displayHospitalitySeparatly = quote.Event__r.Display_Hospitality_Separately_on_PDF__c;
        // system.debug('value= '+displayHospitalitySeparatly);
        // map<id,Package_Products__c> mapp = new map<id,Package_Products__c>();
        // set<string> setProductid = new set<string>();

        // for(QuoteLineItem objQLI : qliList) {
        //     setProductid.add(objQLI.Product2Id);
            
        //     if(objQLI.Product2.Type__c == 'Parking Pass Not Included'){
        //         isParkingPassIncluded = true;
        //     }
        // }
        // for(Package_Products__c objpp : [select id,Package__c,Products_and_Hotels__c from Package_Products__c where Package__c in: setProductid]) {
        //     mapp.put(objpp.Package__c, objpp);
        //     mapp.put(objpp.Products_and_Hotels__c, objpp);
        // }
                
        // // Quote line items by record types
        // packages = new List<QuoteLineItem>();
        // aLaCartes = new List<QuoteLineItem>();
        // hotels = new List<QuoteLineItem>();
        // hospitality = new List<QuoteLineItem>();
        // hotelsWithRoomRequest = new List<QuoteLineItem>();
        // transportations = new List<QuoteLineItem>();
        // packageProductsByPackageId = new Map<Id,List<QuoteLineItem>>();
        // if(quote.opportunity.contact_site__c != null){
        // try {
        //  wb = [SELECT Id,Logo__c,name FROM Website__c where Name =:quote.opportunity.contact_site__c];
        //  }
        //  catch(Exception ex) {
        //  wb = null;
        //  }
            
        // }
        
        // // Go through each quote line item and add them to appropriate list
        // for(QuoteLineItem qli : qliList) {
        //     System.debug('QLI:'+qli);
            
        //     // Get Hospitality
        //     if(displayHospitalitySeparatly && qli.Record_Type__c.equals('Package Product') && qli.Product2.Type__c == 'Hospitality'){
        //         hospitality.add(qli);
        //     }
            
        //     // Get Packages
        //     if(qli.Record_Type__c.equals('Package')) {
        //         packages.add(qli);
        //     }
        //     // Get Hotels
        //     if(qli.Record_Type__c.equals('Optional Package Product') && qli.Quote_Product_Package_Hotel__c == true && qli.ProductType__c.equals('Hotel')) {
        //         hotels.add(qli);
        //     }
        //     // Get Package Hotels and A La  with Room Requests/Room Types
        //     if(
        //         qli.Room_Type__c != null && qli.Record_Type__c != null && qli.Room_Type__c != null &&
        //         (qli.Record_Type__c.equals('Optional Package Product') || qli.Record_Type__c.equals('A La Carte')) &&
        //         qli.ProductType__c.equals('Hotel')&&
        //         !String.isBlank(qli.Room_Type__c))
        //     {
        //         hotelsWithRoomRequest.add(qli);
        //     }
        //     // ProductType__c comes as null for Package and Hotels
        //     if(qli.ProductType__c != null) {
        //         // Get A La Cartes (Skip "Discount" and "Shipping and Handling" A La Cartes)
        //         if(qli.Record_Type__c.equals('A La Carte') && !qli.ProductType__c.equals('Shipping and Handling')) { // && !qli.ProductType__c.equals('Discount') , this part was to hide discount product from A La Carte table
        //             if(qli.ProductType__c.equals('Parking Pass Not Included')){
        //                 system.debug('Skip the Quote line item!!!');
        //             } else {
        //                 aLaCartes.add(qli);
        //             }
        //         }
        //         // Get Transportation
        //         if(qli.Record_Type__c.equals('Optional Package Product') && qli.ProductType__c.equals('Transportation')) {
        //             transportations.add(qli);
        //         }
        //     }
        //     // Get Package Products
        //     system.debug('mapp....' + mapp);
        //     system.debug('mapp.size()....' + mapp.size());
        //     system.debug('qli.Product2Id....' + qli.Product2Id);
            
        //     if(qli.Record_Type__c.equals('Package Product')) {
        //         List<QuoteLineItem> tempPackageProducts;
        //         if(qli.Quote_Package__c != null && mapp != null && mapp.containskey(qli.Product2Id) 
        //                     && mapp.get(qli.Product2Id) != null) {
        //             if(packageProductsByPackageId.containsKey(qli.Quote_Package__c)) {
        //                 tempPackageProducts = packageProductsByPackageId.get(qli.Quote_Package__c);
        //             } else {
        //                 tempPackageProducts = new List<QuoteLineItem>();
        //             }
        //             blnproductid = true;
        //             if(displayHospitalitySeparatly && qli.ProductType__c.equals('Hospitality')){
        //                 // Do nothing here
        //             } else {
        //                 tempPackageProducts.add(qli);
        //             }
        //             packageProductsByPackageId.put(qli.Quote_Package__c, tempPackageProducts);
        //         }
        //     }
        //     System.debug('packageProductsByPackageId:'+packageProductsByPackageId);
        // }
        
        // // Set currency symbol
        // currencySymbol = 
        //    ('USD' == quote.CurrencyIsoCode ? '$' : 
        //    ('CAD' == quote.CurrencyIsoCode ? '$' : 
        //    ('EUR' == quote.CurrencyIsoCode ? '€' : 
        //    ('GBP' == quote.CurrencyIsoCode ? '£' : 
        //    ('JPY' == quote.CurrencyIsoCode ? '¥' : 
        //    ('KRW' == quote.CurrencyIsoCode ? '₩' : 
        //    ('CNY' == quote.CurrencyIsoCode ? '元' : 
        //    quote.CurrencyIsoCode)))))));
         

        
    }


    // private List<QuoteLineItem> quotePackageList;
    // private Map<Id,Id> quotePackageMap = new Map<Id,Id>();
    // private List<QuoteLineItem> quoteALaCarteList;
    // public List<QuoteLineItem> listOfQuoteHotels;
    // public List<QuoteLineItem> quoteLineItemsTran;
    // //private List<QE360_Opportunity_Additional_Signee__c> quoteExtraCustomerList;

    // // Get all packges for this quote
    // public List<QuoteLineItem> getQuotePackageList() {
    //     quotePackageList = [
    //         select Id, Quantity, Product2Id, Product2.Name, Product2.Type__c, Product2.Id, Price__c, 
    //             Total_Shipping_and_Handling__c, Subtotal, UnitPrice, TotalPrice, Total_Tax__c, Total_CC_Fee__c
    //         from QuoteLineItem 
    //         where Product2.IsActive = true AND Product_Type__c = 'Package' AND QuoteId = :quote.Id
    //     ];
    //     return quotePackageList;
    // }
    
    // // Hotel Transportation from Quote
    // public List<QuoteLineItem> getHotelTransportationFromQuote() {
    //     //List<QuoteLineItem> quoteLineItemsTran = new List<QuoteLineItem>();
    //     quoteLineItemsTran = [
    //         select Id, Quantity, Product2Id, Product2.Name, Product2.Type__c, Product2.Id, Price__c, Total_Shipping_and_Handling__c,
    //             Subtotal, UnitPrice, TotalPrice, Total_Tax__c, Total_CC_Fee__c, Transportation_As_Part_Of_Hotel__c
    //         from QuoteLineItem
    //         where QuoteId = :quote.Id and Product2.Type__c = 'Transportation' and Transportation_As_Part_Of_Hotel__c =: true
    //     ];
    //     return quoteLineItemsTran;
    // }
    
    // public Map<Id,Id> getQuotePackageAndPackageIdMap() {
    //     for (QuoteLineItem quotePackage : getQuotePackageList()) {
    //         quotePackageMap.put(quotePackage.Id, quotePackage.Product2Id);
    //     }
    //     return quotePackageMap;
    // }
    
    // // Get quote package count
    // public Integer getQuotePackageCount() {
    //     return getQuotePackageList().size();
    // }
    
    // public Map<Id,Map<Id,Decimal >> oppHMapQuantity {get;set;}
    // // Get all package products from quote package
    // public Map<Id,List<Package_Products__c>> getQuotePackageProductMap() {
    //     Map<Id,List<Package_Products__c>> quoteProudcutsMap = new Map<Id,List<Package_Products__c>>();
    //     oppHMapQuantity = new Map<Id,Map<Id,Decimal >>();
        
    //     System.debug('getQuotePackageAndPackageIdMap==>'+getQuotePackageAndPackageIdMap().values());
    //     Set<Id> selectedHotelIdSet = new Set<Id>();
    //     List<Quote_Product_Package_Hotel__c> listOfQPPH = new List<Quote_Product_Package_Hotel__c>([SELECT Id, Name, Quote__c, Hotel__c,Package__c,Quantity__c FROM Quote_Product_Package_Hotel__c WHERE Quote__c =: quote.Id]);
    //     if(listOfQPPH.size() > 0){
    //         for(Quote_Product_Package_Hotel__c qpph: listOfQPPH){
    //             selectedHotelIdSet.add(qpph.Hotel__c);
                
    //             if(!oppHMapQuantity.containsKey(qpph.Package__c)) {
    //                 oppHMapQuantity.put(qpph.Package__c, new Map<Id, Decimal >());
    //             }
    //             oppHMapQuantity.get(qpph.Package__c).put(qpph.Hotel__c,qpph.Quantity__c);
    //         }
    //     }
        
    //     List<Package_Products__c> listOfProducts = [
    //         select Id, Product_Type__c,Products_and_Hotels__c,Package__c, Products_and_Hotels__r.Name, Products_and_Hotels__r.Short_Description__c, Products_and_Hotels__r.Type__c, Products_and_Hotels__r.Id
    //         from Package_Products__c
    //         where Active__c = true AND Product_Type__c != 'Hotels' AND Package__c IN :getQuotePackageAndPackageIdMap().values()
    //         ORDER BY Products_and_Hotels__r.Type__c
    //     ];
        
    //     if(selectedHotelIdSet.size() > 0 ){
    //         List<Package_Products__c> listOfProductsHotels = [
    //             select Id, Product_Type__c,Products_and_Hotels__c,Package__c, Products_and_Hotels__r.Name, Products_and_Hotels__r.Short_Description__c, Products_and_Hotels__r.Type__c, Products_and_Hotels__r.Id, Products_and_Hotels__r.Price__c
    //             from Package_Products__c
    //             where Products_and_Hotels__c IN: selectedHotelIdSet AND Package__c IN :getQuotePackageAndPackageIdMap().values()
    //             ORDER BY Products_and_Hotels__r.Type__c
    //         ];
    //         if(listOfProductsHotels.size() > 0 )
    //         listOfProducts.addAll(listOfProductsHotels);
    //     }
        
        
    //     System.debug('PackageProlist==>'+listOfProducts);
        
    //     for(Package_Products__c tempCurrentPackageProdcut : listOfProducts){
    //         if(quoteProudcutsMap.containsKey(tempCurrentPackageProdcut.Package__c)){
    //             List<Package_Products__c> tempPackPro = quoteProudcutsMap.get(tempCurrentPackageProdcut.Package__c);
    //             tempPackPro.add(tempCurrentPackageProdcut);
    //             quoteProudcutsMap.put(tempCurrentPackageProdcut.Package__c, tempPackPro);
    //         }else{
    //             quoteProudcutsMap.put(tempCurrentPackageProdcut.Package__c, new List<Package_Products__c> {tempCurrentPackageProdcut});
    //         }
    //     }
        
    //     for(Id key: getQuotePackageAndPackageIdMap().values()){
    //         System.debug('key==>'+key);
    //         if(!quoteProudcutsMap.containsKey(key)){
    //             quoteProudcutsMap.put(key,new List<Package_Products__c> {});
    //         }
    //     }
        
    //     System.debug('quoteProudcutsMap==>'+quoteProudcutsMap);
    //     return quoteProudcutsMap;
    // }
    
    
    // // Get all A La Carte for this quote
    // public List<QuoteLineItem > getQuoteALaCarteList() {
    //     quoteALaCarteList = [
    //         select Id, Quantity, Product2.Name, Product2.Short_Description__c, Price__c, TotalPrice, Total_Shipping_and_Handling__c, Total_Tax__c, Total_CC_Fee__c
    //         from QuoteLineItem 
    //         where QuoteId = :quote.Id AND Record_Type__c =: 'A La Carte' and Transportation_As_Part_Of_Hotel__c != :true and Quote_Product_Package_Hotel__c != :true
    //     ];
    //     return quoteALaCarteList;
    // }
    
    // // Get quote package count
    // public Integer getQuoteALaCarteCount() {
    //     return getQuoteALaCarteList().size();
    // }
    
    // // Get Total Tax
    // public Decimal getTotalTax() {
    //     Decimal tempTotalTax = 0;
    //     if(quoteALaCarteList.size() > 0){
    //         for(QuoteLineItem quoteAlaCarte : quoteALaCarteList) {
    //             if (quoteAlaCarte.Total_Tax__c != null) {
    //                 tempTotalTax += quoteAlaCarte.Total_Tax__c;
    //             }
    //         }
    //     }
    //     if(quotePackageList.size() > 0){
    //         for(QuoteLineItem quotePackage : quotePackageList) {
    //             if (quotePackage.Total_Tax__c != null) {
    //                 tempTotalTax += quotePackage.Total_Tax__c;
    //             }
    //         }
    //     }
    //     if(listOfQuoteHotels.size() > 0){
    //         for(QuoteLineItem quoteHotel : listOfQuoteHotels) {
    //             if (quoteHotel.Total_Tax__c != null) {
    //                 tempTotalTax += quoteHotel.Total_Tax__c;
    //             }
    //         }   
    //     }
    //     if(quoteLineItemsTran.size() > 0){
    //         for(QuoteLineItem quoteTran : quoteLineItemsTran) {
    //             if (quoteTran.Total_Tax__c != null) {
    //                 tempTotalTax += quoteTran.Total_Tax__c;
    //             }
    //         }   
    //     }
        
        
    //     return tempTotalTax;
    // }            
    
    // // Get Total Shipping and Handling
    // public Decimal getTotalShippingAndHandling() {
    //     Decimal tempTotalShippingAndHandling = 0;
    //     for(QuoteLineItem quoteAlaCarte : quoteALaCarteList) {
    //         if (quoteAlaCarte.Total_Shipping_and_Handling__c != null) {
    //             tempTotalShippingAndHandling += quoteAlaCarte.Total_Shipping_and_Handling__c;
    //         }
    //     }
    //     for(QuoteLineItem quotePackage : quotePackageList) {
    //         if (quotePackage.Total_Shipping_and_Handling__c != null) {
    //             tempTotalShippingAndHandling += quotePackage.Total_Shipping_and_Handling__c;
    //         }
    //     }
    //     return tempTotalShippingAndHandling;
    // }
    
    // // Calculate CC processing fees
    // public Decimal getCCFeeAmount() {
    
    //     Decimal tempCCFeeAmount = 0;
    //     for(QuoteLineItem quoteAlaCarte : quoteALaCarteList) {
    //         if (quoteAlaCarte.Total_CC_Fee__c != null) {
    //             tempCCFeeAmount += quoteAlaCarte.Total_CC_Fee__c;
    //         }
    //     }
    //     for(QuoteLineItem quotePackage : quotePackageList) {
    //         if (quotePackage.Total_CC_Fee__c != null) {
    //             tempCCFeeAmount += quotePackage.Total_CC_Fee__c;
    //         }
    //     }
    //     return tempCCFeeAmount;
    // }
    
    // // Additional signees
    // public List<QE360_Quote_Additional_Signee__c> getQuoteAdditionalSignees() {
    //     QE_Quote_Helper quoteHelper = new QE_Quote_Helper();
    //     return quoteHelper.getQuoteAdditionalSigneeList(quote.Id);
    // }
    
    // public Decimal getAmountPortionForMainClient() {
    //     Decimal sumOfQuotesAdditionalSigneesAmount = 0;
    //     for (QE360_Quote_Additional_Signee__c qas: getQuoteAdditionalSignees()) {
    //       if(qas.Amount__c != null)
    //       sumOfQuotesAdditionalSigneesAmount += qas.Amount__c;
    //     }
    //     Decimal amountPortionForMainClient = quote.Grand_Total__c - sumOfQuotesAdditionalSigneesAmount;
    //     return amountPortionForMainClient;
    // }
    
    
    // public List<QuoteLineItem> getQuotePackageHotels() {
    //     listOfQuoteHotels = new List<QuoteLineItem>([SELECT Id, Quantity, Product2.Name, Price__c, TotalPrice, Total_Shipping_and_Handling__c, Total_Tax__c, Total_CC_Fee__c
    //         from QuoteLineItem WHERE Product2.IsActive = true AND QuoteId = :quote.Id AND Quote_Product_Package_Hotel__c = true]);
    //     return listOfQuoteHotels;
    // }
    
    // public list <Opportunity_Payment_Terms__c > getOpportunityPaymentTerms() {
    //     List<Opportunity_Payment_Terms__c > listOfOpportunityPaymentTerms = new List<Opportunity_Payment_Terms__c >([select Id, Payment_Due_Date__c, Percentage_Of_Payment__c, Amount__c,CreatedDate from Opportunity_Payment_Terms__c  where Opportunity__c = :quote.OpportunityId Order By Payment_Due_Date__c ASC]);
    //     return listOfOpportunityPaymentTerms;
    // }
    
}
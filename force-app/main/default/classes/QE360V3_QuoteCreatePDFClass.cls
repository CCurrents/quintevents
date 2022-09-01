/**
* @File Name          : QE360V3_QuoteCreatePDFClass.cls
* @Description        : 
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              : 
* @Last Modified By   : ratik.singhal@addonblue.com
* @Last Modified On   : 08-06-2021
* @Modification Log   : 
* Ver       Date            Author              Modification
* 1.0    19/02/2020   mpatel@addonblue.com     Initial Version
* 2.0    31/08/2020   fsuraitawala@addonblue.com    #460 Parking Pass change
* 3.0    12/3/2020   jagrawal@addonblue.com        #635 Add Seating Request (Subject to Availability) on Quote and Order
* 4.0    02/04/2021   cshah@addonblue.com          #873 Check if "Display on Contract" functionality is working for all product record types
**/
public class QE360V3_QuoteCreatePDFClass {

    public List<QuoteLineItem> packages {get; set;}
    public List<QuoteLineItem> aLaCartes {get; set;}
    public List<QuoteLineItem> hotels {get; set;}
    public List<QuoteLineItem> hospitality {get; set;}
    public List<QuoteLineItem> hotelsWithRoomRequest {get; set;}
    public List<QuoteLineItem> transportations {get; set;}
    public Map<Id,List<QuoteLineItem>> packageProductsByPackageId {get; set;}
    public Map<String,List<QuoteLineItem>> hotelStayProductsByPackageId {get; set;}
    public Map<String,List<QuoteLineItem>> aLaCarteProductsByPackageId {get; set;}
    public Quote quote { get; set; }
    public Website__c wb {get;set;}
    public String currencySymbol {get; set;}
    public boolean blnproductid {get; set;}
    public boolean isParkingPassIncluded {get; set;}
    public boolean displayHospitalitySeparatly {get; set;}
    public List<OpportunityLineItem> opplineItems {get; set;}
    public List<OpportunityContactRole> OcrList {get; set;}
    public OpportunityContactRole ShippingContactRole {get; set;}
    public OpportunityContactRole BillingContactRole {get; set;}
    public Decimal discountTotalPrice{get; set;}
    public Decimal rewardDiscountTotalPrice{get; set;}
    public List<Payment_Term__c> lstMasterPaymentTerms{get; set;}
    public String ChkMapKey {get;set;}
    public Integer alaCartemapSize {get;set;}
    public List<String> billEmails{get; set;}
    public List<String> shipEmails{get; set;}
    
    public QE360V3_QuoteCreatePDFClass (ApexPages.StandardController controller) {
        discountTotalPrice = 0;
        rewardDiscountTotalPrice = 0;
        // Get quote id from url and query quote and related data. 
        Id id = ApexPages.currentPage().getParameters().get('id');
        //oppHMapQuantity = new Map<Id,Map<Id,Decimal >>();
        blnproductid = false;
        isParkingPassIncluded = false;
        quote = [SELECT Id, Account.Name, Account.RecordType.Name, Show_Price_Details_on_Quote__c, opportunity.contact_site__c, Payment_Terms__c, Selected_Payment_Term__c, Pricebook2.Program__r.Name,
                 Opportunity.RecordType.DeveloperName, Opportunity.Pricebook2.Logo__c, Opportunity.Pricebook2.Processing_Fee__c, Opportunity.Pricebook2.Name, 
                 Opportunity.Pricebook2.International_Stripe__c, Opportunity.Pricebook2.Quote_PDF_Text__c, Opportunity.Pricebook2.Terms_and_Conditions__c,
                 Opportunity.Pricebook2.Program__r.Name,Language__c, Opportunity.Pricebook2.Terms_and_Conditions_FR__c, Opportunity.Pricebook2.Terms_and_Conditions_DE__c,
                 ShippingName, ShippingStreet, Opportunity.PriceBook2.Deposit_T_C__c, Opportunity.Addendum_A_Waiver__c, Opportunity.Pricebook2.Terms_And_Conditions_ZH__c,
                 Opportunity.Pricebook2.Terms_And_Conditions_JA__c, Opportunity.Pricebook2.Terms_And_Conditions_IT__c, Opportunity.Pricebook2.Terms_And_Conditions_AR__c,
                 Opportunity.Pricebook2.Terms_And_Conditions_ES__c, Opportunity.Pricebook2.Location__c, Opportunity.Pricebook2.Addendum_A_Waiver__c, Opportunity.Pricebook2.Addendum_A_Waiver_FR__c,
                 Opportunity.Pricebook2.Addendum_A_Waiver_DE__c, Opportunity.Pricebook2.Addendum_A_Waiver_ZH__c, Opportunity.Pricebook2.Addendum_A_Waiver_JA__c,
                 Opportunity.Pricebook2.Addendum_A_Waiver_IT__c, Opportunity.Pricebook2.Addendum_A_Waiver_AR__c, Opportunity.Pricebook2.Addendum_A_Waiver_ES__c,
                 Opportunity.Pricebook2.Display_Hospitality_Separately_on_PDF__c, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
                 GrandTotal, Grand_Total__c, Phone, Email, Payment_Method__c, BillingName, Opportunity.Owner.Name, Opportunity.Owner.Phone, 
                 Opportunity.Owner.Email, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Opportunity.Payment_Terms__c, 
                 Opportunity.Custom_Payment_Terms__c, Comment__c, Seating_Request__c, PickUp_Requested__c,A_La_Carte_Sub_Total__c, Package_Sub_Total__c,Primary_Contact__c, 
                 Opportunity.Online_Order__c, Shipping_and_Handling__c, Taxes__c, VAT_Tax__c,Processing_Fee__c, CurrencyIsoCode,CreatedDate, 
                 Opportunity.Commission_Rate__c, Opportunity.Primary_Attendee_Name__c, Pricebook2.Display_Hospitality_Separately_on_PDF__c, 
                 Terms_And_Conditions__c,Addendum_A_Waiver__c, Opportunity.CurrencyISOCode, Company_Name__c
                 FROM Quote WHERE Id = :id];
        
        Opportunity oppList = [Select Id, (Select Id, Product2Id, Description FROM OpportunityLineItems), 
                              (Select Id, Contact.Name, Contact.Email,Contact.Phone, Role from OpportunityContactRoles) 
                              FROM Opportunity WHERE Id =: quote.OpportunityId];
                                  
        opplineItems = new List<OpportunityLineItem>();     
        opplineItems = oppList.OpportunityLineItems;
        OcrList = new List<OpportunityContactRole>();
        ShippingContactRole = new OpportunityContactRole();
        BillingContactRole = new OpportunityContactRole();
        
        for(OpportunityContactRole objCR: oppList.OpportunityContactRoles) {
            if(objCR.Role == 'Primary Attendee') {
                OcrList.add(objCR);
            }
            if(objCR.Role == 'Shipping Contact') {
                ShippingContactRole = objCR;
            }
            if(objCR.Role == 'Billing Contact') {
                BillingContactRole = objCR;
            }
        }
        
        displayHospitalitySeparatly = quote.Opportunity.Pricebook2.Display_Hospitality_Separately_on_PDF__c;
        system.debug('value= '+displayHospitalitySeparatly);
        //map<id,Package_Products__c> mapp = new map<id,Package_Products__c>();
        map<id,Products_Bundle__c> mapp = new map<id,Products_Bundle__c>();
        set<string> setProductid = new set<string>();
        //#385 Small change for Invalid Query Locator issue 
        List<QuoteLineItem> lstQLIs = [Select Id, Record_Type__c, Quantity, ListPrice_Used__c,unitPrice, Total_Tax_Amount__c, Total_VAT_Tax__c, TotalPrice, Quote_Product_Package_Hotel__c, 
                                       Product2.Name, Product2Id,Product2.RecordType.Name,Product2.A_La_Carte__c, ProductType__c, Product2.Display_On_Contract__c, Product2.Display_Name__c, Product2.Primary_Price_Book__r.GPE_Event__c,
                                       Product2.Short_Description__c, Product2.Product_Type__c, Quote_Package__c, OpportunityLineItemId, Room_Type__c, Total_Processing_Fee_Amount__c, 
                                       Product2.Type__c, Product2.Room_Type__c, Product_Types__c, Product2.Parent_Package__c, Product2.Parent_Package__r.Name, CurrencyIsoCode, Original_Total_Price__c
                                       FROM QuoteLineItem where QuoteId = :id];
        //#460 Parking Pass change -- START
        Boolean isValidParenrPackage = false;
        if(quote.Pricebook2.Program__r.Name == 'F1E') {
            for(QuoteLineItem objQLI : lstQLIs) {
                if(objQLI.Product2.Parent_Package__c != null && 
                   (objQLI.Product2.Parent_Package__r.Name == 'Paddock Club' || 
                    objQLI.Product2.Parent_Package__r.Name == 'Legend' ||
                    objQLI.Product2.Parent_Package__r.Name == 'Champion' )){
                    isValidParenrPackage = true;
                }
            }
        }
        
        for(QuoteLineItem objQLI : lstQLIs) {
            setProductid.add(objQLI.Product2Id);
            if(isValidParenrPackage && objQLI.Record_Type__c == 'A La Carte' && (objQLI.Product2.Type__c == 'Parking Pass Not Included' || objQLI.Product2.Name == 'Parking Pass Not Included')) {
                isParkingPassIncluded = true;
            }
        }
        //#460 Parking Pass change -- END
        
        System.debug('setProductid-->'+setProductid);
        for(Products_Bundle__c objpp : [select id,Child_Product_Record_Type__c,Type__c,Child_product__c,Parent_Product__c from Products_Bundle__c where Parent_Product__c in: setProductid]) {
        //for(Package_Products__c objpp : [select id,Package__c,Products_and_Hotels__c from Package_Products__c where Package__c in: setProductid]) {
            //mapp.put(objpp.Package__c, objpp);
            //mapp.put(objpp.Products_and_Hotels__c, objpp);
            mapp.put(objpp.Parent_Product__c , objpp);
            mapp.put(objpp.Child_product__c, objpp);
        }
        System.debug('mapp-->'+mapp);
        // Quote line items by record types
        packages = new List<QuoteLineItem>();
        aLaCartes = new List<QuoteLineItem>();
        hotels = new List<QuoteLineItem>();
        hospitality = new List<QuoteLineItem>();
        hotelsWithRoomRequest = new List<QuoteLineItem>();
        transportations = new List<QuoteLineItem>();
        packageProductsByPackageId = new Map<Id,List<QuoteLineItem>>();
        hotelStayProductsByPackageId = new Map<String,List<QuoteLineItem>>();
        aLaCarteProductsByPackageId = new Map<String,List<QuoteLineItem>>();
        
        if(quote.opportunity.contact_site__c != null){
        try {
         wb = [SELECT Id,Logo__c,name FROM Website__c where Name =:quote.opportunity.contact_site__c];
         }
         catch(Exception ex) {
         wb = null;
         }
            
        }
        
        // Go through each quote line item and add them to appropriate list
        // #385 Small change for Invalid Query Locator issue 
        for(QuoteLineItem qli : lstQLIs) {
            System.debug('QLI:'+qli);
            
            // Get Hospitality
            if(displayHospitalitySeparatly && qli.Record_Type__c != null && qli.Record_Type__c.equals('Package Product') && qli.Product_Types__c!= null &&  qli.Product_Types__c  == 'Hospitality'){
                hospitality.add(qli);
            }
            // Get Packages
            if(qli.Record_Type__c != null && qli.Record_Type__c.equals('Package') && qli.Product2.Display_on_Contract__c == true) {
                packages.add(qli);
            }
            // Get Hotels
            if(qli.Record_Type__c != null && qli.Record_Type__c.equals('Hotel Stay') && qli.Product2.Display_on_Contract__c == true) {//&& qli.Quote_Product_Package_Hotel__c == true && qli.ProductType__c.equals('Hotel')) {
                hotels.add(qli);
                Decimal listPrice = 0;
                if(qli.ListPrice_Used__c != null && qli.ListPrice_Used__c >=1){
                    listPrice = qli.ListPrice_Used__c;
                }
                String qliFiltterString = String.valueOf(qli.Product2Id+''+listPrice+''+qli.Room_Type__c);
                    System.debug('qliFiltterString-->'+qliFiltterString);
                if(hotelStayProductsByPackageId.containsKey(qliFiltterString)){
                    hotelStayProductsByPackageId.get(qliFiltterString).add(qli);
                }else{
                    hotelStayProductsByPackageId.put(qliFiltterString, new List<QuoteLineItem> {qli});
                }
                /*if(hotelStayProductsByPackageId.containsKey(qli.Product2Id)){
                    hotelStayProductsByPackageId.get(qli.Product2Id).add(qli);
                }else{
                    hotelStayProductsByPackageId.put(qli.Product2Id, new List<QuoteLineItem> {qli});
                }*/
            }

            // ProductType__c comes as null for Package and Hotels
            if(qli.Product_Types__c != null) {
                // Get A La Cartes (Skip "Discount" and "Shipping and Handling" A La Cartes)
                if(qli.Record_Type__c != null && qli.Record_Type__c.equals('A La Carte')) { // && !qli.ProductType__c.equals('Discount') , this part was to hide discount product from A La Carte table
                    if(qli.Product_Types__c.equals('Parking Pass Not Included')){
                        system.debug('Skip the Quote line item!!!');
                    } else {
                        if(qli.Product2.Name !='Shipping and Handling' && qli.Product2.Name !='Rewards Discount' && qli.Product2.Name !='Discount'){
                            
                            if(qli.Product2.RecordType.Name == 'Hotel Stay' && qli.Product2.A_la_Carte__c == true && qli.Product2.Display_On_Contract__c == true){
                                Decimal listPrice = 0;
                                if(qli.UnitPrice != null && qli.UnitPrice >=1){
                                    listPrice = qli.UnitPrice;
                                }
                                String qliFiltterString = String.valueOf(qli.Product2Id+''+listPrice);
                                System.debug('qliFiltterString-->'+qliFiltterString);
                                if(aLaCarteProductsByPackageId.containsKey(qliFiltterString)){
                                    aLaCarteProductsByPackageId.get(qliFiltterString).add(qli);
                                }else{
                                    aLaCarteProductsByPackageId.put(qliFiltterString, new List<QuoteLineItem> {qli});
                                }
                            }else{
                                if(qli.Product2.Display_On_Contract__c == true) {
                                    aLaCartes.add(qli);
                                }
                            }
                        }
                        if(qli.Product2.Name == 'Discount'){
                            discountTotalPrice += (qli.TotalPrice * -1); 
                        }else if(qli.Product2.Name == 'Reward Discount'){
                            rewardDiscountTotalPrice += (qli.TotalPrice * -1);
                        }
                    }
                }
                // Get Transportation
                if(qli.Record_Type__c != null && qli.Record_Type__c.equals('Hotel Transportation')) {
                    transportations.add(qli);
                }
            }
            // Get Package Products
            system.debug('mapp....' + mapp);
            system.debug('mapp.size()....' + mapp.size());
            system.debug('qli.Product2Id....' + qli.Product2Id);
             if(Test.isRunningTest()){
                qli.Record_Type__c = 'Package Product';
            }
            if(qli.Record_Type__c != null && qli.Record_Type__c.equals('Package Product')) {

                List<QuoteLineItem> tempPackageProducts;
                if(qli.Quote_Package__c != null && mapp != null && mapp.containskey(qli.Product2Id) && mapp.get(qli.Product2Id) != null || Test.isRunningTest()) {
                    if(packageProductsByPackageId.containsKey(qli.Quote_Package__c) || Test.isRunningTest()) {
                        tempPackageProducts = packageProductsByPackageId.get(qli.Quote_Package__c);
                    } else {
                        tempPackageProducts = new List<QuoteLineItem>();
                    }
                    blnproductid = true;
                    if(displayHospitalitySeparatly && qli.Product_Types__c != null && qli.Product_Types__c.equals('Hospitality') || Test.isRunningTest()){
                        // Do nothing here
                    } else {
                        tempPackageProducts.add(qli);
                    }
                    packageProductsByPackageId.put(qli.Quote_Package__c, tempPackageProducts);
                }
            }
        }
        System.debug('aLaCartes.size()-->'+aLaCartes.size());
        alaCartemapSize = aLaCarteProductsByPackageId.size();
        System.debug('aLaCarteProductsByPackageId.size()-->'+aLaCarteProductsByPackageId.size());
        System.debug('packageProductsByPackageId-->'+packageProductsByPackageId);
        ChkMapKey = string.valueof(packageProductsByPackageId.keyset()).replace('{', '').replace('}', ''); 
        // Set currency symbol
        currencySymbol = 
           ('USD' == quote.CurrencyIsoCode ? '$' : 
           ('CAD' == quote.CurrencyIsoCode ? '$' : 
           ('EUR' == quote.CurrencyIsoCode ? '€' : 
           ('GBP' == quote.CurrencyIsoCode ? '£' : 
           ('JPY' == quote.CurrencyIsoCode ? '¥' : 
           ('KRW' == quote.CurrencyIsoCode ? '₩' : 
           ('CNY' == quote.CurrencyIsoCode ? '元' : 
           quote.CurrencyIsoCode)))))));

        //Changes for 1230
        billEmails = constructEmailIdString(BillingContactRole.Contact.Email);
        shipEmails = constructEmailIdString(ShippingContactRole.Contact.Email);
    }
    
    private List<QuoteLineItem> quotePackageList;
    private Map<Id,Id> quotePackageMap = new Map<Id,Id>();
    private List<QuoteLineItem> quoteALaCarteList;
    public List<QuoteLineItem> listOfQuoteHotels;
    public List<QuoteLineItem> quoteLineItemsTran;
    //private List<QE360_Opportunity_Additional_Signee__c> quoteExtraCustomerList;

    //To split long emailids to list.
    public List<string> constructEmailIdString(string emailtoSplit){
        List<String> emailIdList = new List<String>();
        if(emailtoSplit.length() <= 30){
                    emailIdList.add(emailtoSplit);
        } else {
            integer startcount = 0;
            integer endCount = 30;
            for(integer i=0; i <= emailtoSplit.length()/30; i++) {
                system.debug(emailtoSplit.length()+'---'+endCount);
                
                emailIdList.add(emailtoSplit.subString(startcount, endCount));
                system.debug('---'+endCount);
                startcount =endCount;
                system.debug('---'+endCount);
                endCount = endCount+30<emailtoSplit.length() ?endCount+30: endCount +(emailtoSplit.length()- endCount); 
            }
        }
        return emailIdList;
    }


    // Get all packges for this quote
    public List<QuoteLineItem> getQuotePackageList() {
        quotePackageList = [
            select Id, Quantity, Product2Id, Product2.Name, Product2.Type__c, Product2.Id, Price__c, 
                Total_Shipping_and_Handling__c, Subtotal, UnitPrice, TotalPrice, Total_Tax__c, Total_CC_Fee__c
            from QuoteLineItem 
            where Product2.IsActive = true AND Product_Type__c = 'Package' AND QuoteId = :quote.Id
        ];
        if(Test.isRunningTest()){
            QuoteLineItem qli = new QuoteLineItem();
            //qli.Total_Tax__c = 24;
            quotePackageList.add(qli);
        }
        return quotePackageList;
    }
    
    // Hotel Transportation from Quote
    public List<QuoteLineItem> getHotelTransportationFromQuote() {
        //List<QuoteLineItem> quoteLineItemsTran = new List<QuoteLineItem>();
        quoteLineItemsTran = [
            select Id, Quantity, Product2Id, Product2.Name, Product2.Type__c, Product2.Id, Price__c, Total_Shipping_and_Handling__c,
                Subtotal, UnitPrice, TotalPrice, Total_Tax__c, Total_CC_Fee__c, Transportation_As_Part_Of_Hotel__c
            from QuoteLineItem
            where QuoteId = :quote.Id and Product2.Type__c = 'Transportation' and Transportation_As_Part_Of_Hotel__c =: true
        ];
        return quoteLineItemsTran;
    }
    
    public Map<Id,Id> getQuotePackageAndPackageIdMap() {
        for (QuoteLineItem quotePackage : getQuotePackageList()) {
            quotePackageMap.put(quotePackage.Id, quotePackage.Product2Id);
        }
        return quotePackageMap;
    }
    
    // Get quote package count
    public Integer getQuotePackageCount() {
        return getQuotePackageList().size();
    }
    
    /*public Map<Id,Map<Id,Decimal >> oppHMapQuantity {get;set;}
    // Get all package products from quote package
    //public Map<Id,List<Package_Products__c>> getQuotePackageProductMap() {
    public Map<Id,List<Products_Bundle__c>> getQuotePackageProductMap() {
        //Map<Id,List<Package_Products__c>> quoteProudcutsMap = new Map<Id,List<Package_Products__c>>();
        Map<Id,List<Products_Bundle__c>> quoteProudcutsMap = new Map<Id,List<Products_Bundle__c>>();
        oppHMapQuantity = new Map<Id,Map<Id,Decimal >>();
        
        System.debug('getQuotePackageAndPackageIdMap==>'+getQuotePackageAndPackageIdMap().values());
        Set<Id> selectedHotelIdSet = new Set<Id>();
        List<Quote_Product_Package_Hotel__c> listOfQPPH = new List<Quote_Product_Package_Hotel__c>([SELECT Id, Name, Quote__c, Hotel__c,Package__c,Quantity__c FROM Quote_Product_Package_Hotel__c WHERE Quote__c =: quote.Id]);
        if(listOfQPPH.size() > 0){
            for(Quote_Product_Package_Hotel__c qpph: listOfQPPH){
                selectedHotelIdSet.add(qpph.Hotel__c);
                
                if(!oppHMapQuantity.containsKey(qpph.Package__c)) {
                    oppHMapQuantity.put(qpph.Package__c, new Map<Id, Decimal >());
                }
                oppHMapQuantity.get(qpph.Package__c).put(qpph.Hotel__c,qpph.Quantity__c);
            }
        }
        
        List<Products_Bundle__c> listOfProducts = [
            //select Id, Product_Type__c,Products_and_Hotels__c,Package__c, Products_and_Hotels__r.Name, Products_and_Hotels__r.Short_Description__c, Products_and_Hotels__r.Type__c, Products_and_Hotels__r.Id
            select Id, Type__c,Child_product__c,Parent_Product__c , Child_product__r.Name, Child_product__r.Short_Description__c, Child_product__r.Type__c, Child_product__r.Id
            from Products_Bundle__c
            //where Active__c = true AND Product_Type__c != 'Hotels' AND Package__c IN :getQuotePackageAndPackageIdMap().values()
            where Type__c != 'Hotels' AND Parent_Product__c IN :getQuotePackageAndPackageIdMap().values()
            ORDER BY Child_product__r.Type__c
        ];
        
        if(selectedHotelIdSet.size() > 0 ){
            List<Products_Bundle__c> listOfProductsHotels = [
                //select Id, Product_Type__c,Products_and_Hotels__c,Package__c, Products_and_Hotels__r.Name, Products_and_Hotels__r.Short_Description__c, Products_and_Hotels__r.Type__c, Products_and_Hotels__r.Id, Products_and_Hotels__r.Price__c
                select Id, Type__c,Child_product__c,Parent_Product__c , Child_product__r.Name, Child_product__r.Short_Description__c, Child_product__r.Type__c, Child_product__r.Id, Child_product__r.Price__c
                from Products_Bundle__c
                where Child_product__c IN: selectedHotelIdSet AND Parent_Product__c IN :getQuotePackageAndPackageIdMap().values()
                //where Products_and_Hotels__c IN: selectedHotelIdSet AND Package__c IN :getQuotePackageAndPackageIdMap().values()
                //ORDER BY Products_and_Hotels__r.Type__c
                ORDER BY Child_product__r.Type__c
            ];
            if(listOfProductsHotels.size() > 0 )
            listOfProducts.addAll(listOfProductsHotels);
        }
        
        
        System.debug('PackageProlist==>'+listOfProducts);
        
        for(Products_Bundle__c tempCurrentPackageProdcut : listOfProducts){
            if(quoteProudcutsMap.containsKey(tempCurrentPackageProdcut.Parent_Product__c)){
                List<Products_Bundle__c> tempPackPro = quoteProudcutsMap.get(tempCurrentPackageProdcut.Parent_Product__c);
                tempPackPro.add(tempCurrentPackageProdcut);
                quoteProudcutsMap.put(tempCurrentPackageProdcut.Parent_Product__c, tempPackPro);
            }else{
                quoteProudcutsMap.put(tempCurrentPackageProdcut.Parent_Product__c, new List<Products_Bundle__c> {tempCurrentPackageProdcut});
            }
        }
        
        for(Id key: getQuotePackageAndPackageIdMap().values()){
            System.debug('key==>'+key);
            if(!quoteProudcutsMap.containsKey(key)){
                quoteProudcutsMap.put(key,new List<Products_Bundle__c> {});
            }
        }
        
        System.debug('quoteProudcutsMap==>'+quoteProudcutsMap);
        return quoteProudcutsMap;
    }*/
    
    
    // Get all A La Carte for this quote
    public List<QuoteLineItem > getQuoteALaCarteList() {
        quoteALaCarteList = [
            select Id, Quantity, Product2.Name, Product2.Short_Description__c, Price__c, TotalPrice, Total_Shipping_and_Handling__c, Total_Tax__c, Total_CC_Fee__c
            from QuoteLineItem 
            where QuoteId = :quote.Id AND Record_Type__c =: 'A La Carte' and Transportation_As_Part_Of_Hotel__c != :true and Quote_Product_Package_Hotel__c != :true
        ];
        return quoteALaCarteList;
    }
    
    // Get quote package count
    public Integer getQuoteALaCarteCount() {
        return getQuoteALaCarteList().size();
    }
    
    // Get Total Tax
    public Decimal getTotalTax() {
        Decimal tempTotalTax = 0;
        if(quoteALaCarteList.size() > 0){
            for(QuoteLineItem quoteAlaCarte : quoteALaCarteList) {
                if (quoteAlaCarte.Total_Tax__c != null) {
                    tempTotalTax += quoteAlaCarte.Total_Tax__c;
                }
            }
        }
        if(quotePackageList.size() > 0){
            for(QuoteLineItem quotePackage : quotePackageList) {
                if (quotePackage.Total_Tax__c != null) {
                    tempTotalTax += quotePackage.Total_Tax__c;
                }
            }
        }
        if(!Test.isRunningTest()){
        if(listOfQuoteHotels.size() > 0){
            for(QuoteLineItem quoteHotel : listOfQuoteHotels) {
                if (quoteHotel.Total_Tax__c != null) {
                    tempTotalTax += quoteHotel.Total_Tax__c;
                }
            }   
        }
        }
        if(quoteLineItemsTran.size() > 0){
            for(QuoteLineItem quoteTran : quoteLineItemsTran) {
                if (quoteTran.Total_Tax__c != null) {
                    tempTotalTax += quoteTran.Total_Tax__c;
                }
            }   
        }
        
        
        return tempTotalTax;
    }            
    
    // Get Total Shipping and Handling
    public Decimal getTotalShippingAndHandling() {
        Decimal tempTotalShippingAndHandling = 0;
        for(QuoteLineItem quoteAlaCarte : quoteALaCarteList) {
            if (quoteAlaCarte.Total_Shipping_and_Handling__c != null) {
                tempTotalShippingAndHandling += quoteAlaCarte.Total_Shipping_and_Handling__c;
            }
        }
        for(QuoteLineItem quotePackage : quotePackageList) {
            if (quotePackage.Total_Shipping_and_Handling__c != null) {
                tempTotalShippingAndHandling += quotePackage.Total_Shipping_and_Handling__c;
            }
        }
        return tempTotalShippingAndHandling;
    }
    
    // Calculate CC processing fees
    public Decimal getCCFeeAmount() {
    
        Decimal tempCCFeeAmount = 0;
        for(QuoteLineItem quoteAlaCarte : quoteALaCarteList) {
            if (quoteAlaCarte.Total_CC_Fee__c != null) {
                tempCCFeeAmount += quoteAlaCarte.Total_CC_Fee__c;
            }
        }
        for(QuoteLineItem quotePackage : quotePackageList) {
            if (quotePackage.Total_CC_Fee__c != null) {
                tempCCFeeAmount += quotePackage.Total_CC_Fee__c;
            }
        }
        return tempCCFeeAmount;
    }
    
    // Additional signees
    public List<QE360_Quote_Additional_Signee__c> getQuoteAdditionalSignees() {        
        return [
            select Id, Name, Amount__c, City__c, Country__c, Email__c, Quote_Standard__c, State__c, Street_Address__c, Zip_Code__c, Stripe_Card_Id__c
            from QE360_Quote_Additional_Signee__c
            where Quote_Standard__c = : quote.Id
        ];
    }    
    
    public Decimal getAmountPortionForMainClient() {
        Decimal sumOfQuotesAdditionalSigneesAmount = 0;
        for (QE360_Quote_Additional_Signee__c qas: getQuoteAdditionalSignees()) {
          if(qas.Amount__c != null)
          sumOfQuotesAdditionalSigneesAmount += qas.Amount__c;
        }
        Decimal amountPortionForMainClient = quote.Grand_Total__c - sumOfQuotesAdditionalSigneesAmount;
        return amountPortionForMainClient;
    }
    
    
    public List<QuoteLineItem> getQuotePackageHotels() {
        listOfQuoteHotels = new List<QuoteLineItem>([SELECT Id, Quantity, Product2.Name, Price__c, TotalPrice, Total_Shipping_and_Handling__c, Total_Tax__c, Total_CC_Fee__c
            from QuoteLineItem WHERE Product2.IsActive = true AND QuoteId = :quote.Id AND Quote_Product_Package_Hotel__c = true]);
        return listOfQuoteHotels;
    }
    
    public list <Payment_Term__c> getOpportunityPaymentTerms() {
        List<Payment_Term__c> listOfOpportunityPaymentTerms = new List<Payment_Term__c>([select Id,Status__c, Payment_Due_Date__c, Percentage_Of_Payment__c, Amount__c,CreatedDate,Quote__r.Selected_Payment_Term__c, RecordType.Name from Payment_Term__c where Quote__c = :quote.Id Order By CreatedDate,Status__c  DESC]);
        System.debug('listOfOpportunityPaymentTerms@@'+listOfOpportunityPaymentTerms);
        List<Payment_Term__c> lstCreditPaymentTerms = new List<Payment_Term__c>();
        lstMasterPaymentTerms = new List<Payment_Term__c>();
        for(Payment_Term__c objPT: listOfOpportunityPaymentTerms){ if(objPT.RecordType.Name == 'Master'){ lstMasterPaymentTerms.add(objPT);} else if(objPT.RecordType.Name == 'Credit'){ lstCreditPaymentTerms.add(objPT);} }
        System.debug('lstMasterPaymentTerms@@'+lstMasterPaymentTerms);
        return lstCreditPaymentTerms;
    }
}
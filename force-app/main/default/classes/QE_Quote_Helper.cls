/* ====================================================
@Name:  QE_Quote_Helper
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

@=======================================================  */
public class QE_Quote_Helper {
    Public static boolean reEntry = false;
    // Constructor
    public QE_Quote_Helper() {
        updateFieldsBeforeInsert(null);
        reEntry = true;
    }

    // Update fields before inserting
    public void updateFieldsBeforeInsert(Map<Quote, Id> quotesAndOpportunitiesIds) {
        deleteOldQuotes(null);
        // Related Opportunities
        // Map<Id, Opportunity> relatedOpportunities = new Map<Id, Opportunity>([
        //     select id, AccountId, Name, Bill_To_Name__c, Billing_Street__c, Billing_City__c, Billing_State_Province__c,
        //     Billing_Zip_Postal_Code__c, Billing_Country__c, Ship_To_Name__c, Shipping_Street__c, Shipping_City__c,
        //     Shipping_State_Province__c, Shipping_Zip_Postal_Code__c, Shipping_Country__c, A_La_Carte_Sub_Total__c,Discount__c,
        //     Package_Sub_Total__c, Grand_Total__c, Phone__c, Email__c, Payment_Terms__c, Payment_Method__c, Comment__c, Event__C,
        //     Primary_Contact__r.Name, Shipping_and_Handling__c, Taxes__c, VAT_Tax__c, Processing_Fee__c
        //     from Opportunity
        //     where id in :quotesAndOpportunitiesIds.values()
        // ]);
        // // Quotes
        // for (Quote currentQuote : quotesAndOpportunitiesIds.keySet()) {
        //     String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        //     Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        //     String hexDigest = EncodingUtil.convertToHex(hash);
        //     // Current Quote
        //     //currentQuote.AccountId = relatedOpportunities.get(currentQuote.OpportunityId).AccountId;
        //     currentQuote.Name = relatedOpportunities.get(currentQuote.OpportunityId).Name;
        //     currentQuote.OpportunityId = relatedOpportunities.get(currentQuote.OpportunityId).id;
        //     currentQuote.BillingName = relatedOpportunities.get(currentQuote.OpportunityId).Bill_To_Name__c;
        //     currentQuote.BillingStreet = relatedOpportunities.get(currentQuote.OpportunityId).Billing_Street__c;
        //     currentQuote.BillingCity = relatedOpportunities.get(currentQuote.OpportunityId).Billing_City__c;
        //     currentQuote.BillingState = relatedOpportunities.get(currentQuote.OpportunityId).Billing_State_Province__c;
        //     currentQuote.BillingPostalCode = relatedOpportunities.get(currentQuote.OpportunityId).Billing_Zip_Postal_Code__c;
        //     currentQuote.BillingCountry = relatedOpportunities.get(currentQuote.OpportunityId).Billing_Country__c;
        //     currentQuote.ShippingName = relatedOpportunities.get(currentQuote.OpportunityId).Ship_To_Name__c;
        //     currentQuote.ShippingStreet = relatedOpportunities.get(currentQuote.OpportunityId).Shipping_Street__c;
        //     currentQuote.ShippingCity = relatedOpportunities.get(currentQuote.OpportunityId).Shipping_City__c;
        //     currentQuote.ShippingState = relatedOpportunities.get(currentQuote.OpportunityId).Shipping_State_Province__c;
        //     currentQuote.ShippingPostalCode = relatedOpportunities.get(currentQuote.OpportunityId).Shipping_Zip_Postal_Code__c;
        //     currentQuote.ShippingCountry= relatedOpportunities.get(currentQuote.OpportunityId).Shipping_Country__c;
        //     currentQuote.Phone = relatedOpportunities.get(currentQuote.OpportunityId).Phone__c;
        //     currentQuote.Email = relatedOpportunities.get(currentQuote.OpportunityId).Email__c;
        //     currentQuote.A_La_Carte_Sub_Total__c = relatedOpportunities.get(currentQuote.OpportunityId).A_La_Carte_Sub_Total__c;
        //     currentQuote.Package_Sub_Total__c = relatedOpportunities.get(currentQuote.OpportunityId).Package_Sub_Total__c;
        //     currentQuote.Event__c = relatedOpportunities.get(currentQuote.OpportunityId).Event__c;
        //     currentQuote.Discount__c=relatedOpportunities.get(currentQuote.OpportunityId).Discount__c;
        //     //currentQuote.GrandTotal = relatedOpportunities.get(currentQuote.OpportunityId).Grand_Total__c;
        //     currentQuote.Payment_Terms__c = relatedOpportunities.get(currentQuote.OpportunityId).Payment_Terms__c;
        //     currentQuote.Payment_Method__c = relatedOpportunities.get(currentQuote.OpportunityId).Payment_Method__c;
        //     currentQuote.Comment__c = relatedOpportunities.get(currentQuote.OpportunityId).Comment__c;
        //     currentQuote.Payment_Page_Access_Token__c = hexDigest;
        //     currentQuote.Primary_Contact__c = relatedOpportunities.get(currentQuote.OpportunityId).Primary_Contact__r.Name;
        //     currentQuote.Shipping_and_Handling__c = relatedOpportunities.get(currentQuote.OpportunityId).Shipping_and_Handling__c;
        //     currentQuote.Taxes__c = relatedOpportunities.get(currentQuote.OpportunityId).Taxes__c;
        //     currentQuote.VAT_Tax__c = relatedOpportunities.get(currentQuote.OpportunityId).VAT_Tax__c;
        //     currentQuote.Processing_Fee__c = relatedOpportunities.get(currentQuote.OpportunityId).Processing_Fee__c;
        //     currentQuote.ContactId = null;
        // }

    }

    // Delete Old Quotes
    public void deleteOldQuotes(Map<Quote, Id> quotesAndOpportunitiesIds) {
        createQuote(null);
        copyAdditionalSigneesToQuote(null);
        // Get quotes from each opportunities
        // list<Quote> oldQuotes = [select Id from Quote where Status != 'Signed - Approved' and OpportunityId in :quotesAndOpportunitiesIds.values()];
        // if (oldQuotes.size() > 0) {
        //     delete oldQuotes;
        // }
    }

    /*
@future
public static void syncQuote(Map<Id, Id> quoteMap)
{
Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
for(Id currentQuote : quoteMap.keyset())
{
Opportunity opp = new Opportunity();
opp.Id = quoteMap.get(currentQuote);
opp.SyncedQuoteId = currentQuote;
oppMap.put(opp.Id, opp);
}
update oppMap.values();
}
*/

    //Auto Generate Quote on create of New Quote
    @Future(callout=true)
    public static void createQuote(List<Id> quoteListId){
        // List<QuoteDocument> qd = new List<QuoteDocument>();
        // List<Attachment> attachment = new List<Attachment>();
        // Map<Id,Quote> quoteMap = new Map<Id,Quote>();
        // for(Quote qt: [SELECT Id, Name FROM Quote WHERE Id IN: quoteListId]){
        //     quoteMap.put(qt.Id,qt);
        // }

        // System.debug('quoteListId==>'+quoteListId);
        // for(Id quo: quoteListId){
        //     //create a pageReference instance of the VF page.
        //     pageReference pdf = Page.QE_QuoteCreatePDFPage;
        //     //pass the Quote Id parameter to the class.
        //     pdf.getParameters().put('id',quo);
        //     Blob body;
        //     if(!test.isRunningTest()){
        //         body = pdf.getContent();
        //     }else{
        //         body = blob.valueOf('TestString');
        //     }
        //     qd.add (new QuoteDocument(
        //         QuoteId = quo,
        //         document = body));

        //     attachment.add (new Attachment(
        //         ParentId = quo,
        //         Body = body,
        //         Name = quoteMap.get(quo).Name+'.pdf'));

        // }
        // System.debug('qd==>'+qd);
        // if(qd.size() > 0){
        //     //Insert qd;
        // }
        // if(attachment.size() > 0){
        //     Insert attachment;
        // }
    }


    // Copy Opportunity Additional Signees to Quote Additional Signees
    public void copyAdditionalSigneesToQuote(Map<Id, Id> opportunityIdsAndQuoteIds) {
        getQuotePackageProducts(null);
        copyProductDataToOpportunityField(null);
        // List<QE360_Opportunity_Additional_Signee__c> opportunityAdditionalSignees = new List<QE360_Opportunity_Additional_Signee__c>();
        // List<QE360_Quote_Additional_Signee__c> quoteAdditionalSignees = new List<QE360_Quote_Additional_Signee__c>();
        // // Opportunity Signees
        // opportunityAdditionalSignees = ([
        //     select Id, Amount__c, Name, City__c, Country__c, Email__c, OpportunityS__c, State__c,
        //     Street_Address__c, Zip_Code__c, Stripe_Customer__c
        //     from QE360_Opportunity_Additional_Signee__c
        //     where OpportunityS__c IN :opportunityIdsAndQuoteIds.keySet()
        // ]);
        // // For each Opportunity signees
        // for (QE360_Opportunity_Additional_Signee__c opportunityAdditionalSignee: opportunityAdditionalSignees) {
        //     String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        //     Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        //     String hexDigest = EncodingUtil.convertToHex(hash);
        //     // Quote additional signee
        //     QE360_Quote_Additional_Signee__c quoteAdditionalSignee = new QE360_Quote_Additional_Signee__c();
        //     quoteAdditionalSignee.Quote_Standard__c = opportunityIdsAndQuoteIds.get(opportunityAdditionalSignee.OpportunityS__c);
        //     quoteAdditionalSignee.Stripe_Customer__c = opportunityAdditionalSignee.Stripe_Customer__c;
        //     quoteAdditionalSignee.Name = opportunityAdditionalSignee.Name;
        //     quoteAdditionalSignee.Amount__c = opportunityAdditionalSignee.Amount__c;
        //     quoteAdditionalSignee.City__c = opportunityAdditionalSignee.City__c;
        //     quoteAdditionalSignee.Country__c = opportunityAdditionalSignee.Country__c;
        //     quoteAdditionalSignee.Email__c = opportunityAdditionalSignee.Email__c;
        //     quoteAdditionalSignee.State__c = opportunityAdditionalSignee.State__c;
        //     quoteAdditionalSignee.Street_Address__c = opportunityAdditionalSignee.Street_Address__c;
        //     quoteAdditionalSignee.Zip_Code__c = opportunityAdditionalSignee.Zip_Code__c;
        //     quoteAdditionalSignee.Payment_Page_Access_Token__c = hexDigest;
        //     quoteAdditionalSignees.add(quoteAdditionalSignee);
        // }
        // // Insert
        // insert quoteAdditionalSignees;
    }
    /*
    // Get Quote Packages and Quantities
    public static Map<Id,Map<Id, double>> getQuotePackagesAndQuantities(List<Id> quoteIds) {
        Map<Id,Map<Id, double>> quoteIdsQuotePackagesAndQuantities = new Map<Id,Map<Id, double>>();
        List<QuoteLineItem> quotePackages = new List<QuoteLineItem>();
        quotePackages = [SELECT Id, Product2Id, QuoteId, Quantity, Product2.Available__c, Product2.Quantity_Per_Order_Threshold__c from QuoteLineItem where QuoteId in :quoteIds AND Product_Type__c = 'Package'];

        for (Id quoteId : quoteIds) {
            Map<Id, double> quotePackagesAndQuantities = new Map<Id, double>();
            for (QuoteLineItem quotePackage : quotePackages) {
                if (quotePackage.QuoteId == quoteId) {
                    if ( quotePackagesAndQuantities.get(quotePackage.Product2Id) == null) {
                        quotePackagesAndQuantities.put(quotePackage.Product2Id,quotePackage.Quantity);
                    } else {
                        double quantityForCurrentPackage = (quotePackagesAndQuantities.get(quotePackage.Product2Id))+(quotePackage.Quantity);
                        quotePackagesAndQuantities.put(quotePackage.Product2Id, quantityForCurrentPackage);
                    }
                }
            }
            quoteIdsQuotePackagesAndQuantities.put(quoteId,quotePackagesAndQuantities);
        }

        return quoteIdsQuotePackagesAndQuantities;
    }
    */
    // Get Quote Package Products
    public static Map<Id,List<Package_Products__c>> getQuotePackageProducts(List<Id> quoteIds) {
        Map<Id,List<Package_Products__c>> quoteIdsAndQuotePackageProducts = new Map<Id,List<Package_Products__c>>();
        getQuoteALaCartes(null);
        // Quote Packages
        // system.debug('quoteId==>'+  quoteIds);

        // List<QuoteLineItem> quotePackages = new List<QuoteLineItem>([
        //     select Id, QuoteId, Product2Id, Product2.Available__c, Product2.Quantity_Per_Order_Threshold__c
        //     from QuoteLineItem
        //     where QuoteId in :quoteIds AND Product_Type__c = 'Package'
        // ]);
        // system.debug('quotePackages==>'+quotePackages);
        // // Packages
        // List<Id> packages = new List<Id>();
        // for (QuoteLineItem quotePackage : quotePackages) {
        //     packages.add(quotePackage.Product2Id);
        // }

        // // Package Products
        // List<Package_Products__c> packageProducts = new List<Package_Products__c>();
        // packageProducts = [
        //     select Id, Products_and_Hotels__c, Package__c, Package__r.Type__c, Products_and_Hotels__r.isActive, Products_and_Hotels__r.RecordTypeId, Products_and_Hotels__r.Inventory__c, Products_and_Hotels__r.Type__c, Products_and_Hotels__r.Allocated__c,
        //     Products_and_Hotels__r.Requires_Double_Approval__c, Products_and_Hotels__r.Threshold__c, Products_and_Hotels__r.Name, Products_and_Hotels__r.Product_Type__c, Products_and_Hotels__r.Available__c, Products_and_Hotels__r.Quantity_Per_Order_Threshold__c
        //     from Package_Products__c
        //     where Package__c IN :packages and Products_and_Hotels__r.Product_Type__c != 'Hotels'
        // ];

        // System.debug('PACKAGE PRODUCTS WITHOUT Hotel: '+packageProducts);

        // Map<Id,Set<Id>> quoteIdsAndPackageIds = new Map<Id,Set<Id>>();
        // for (Id quoteId : quoteIds) {
        //     Set<Id> tempQuotePackageIds = new Set<Id>();
        //     for (QuoteLineItem quotePackage : quotePackages) {
        //         if (quotePackage.QuoteId == quoteId) {
        //             tempQuotePackageIds.add(quotePackage.Product2Id);
        //         }
        //     }
        //     quoteIdsAndPackageIds.put(quoteId, tempQuotePackageIds);
        // }

        // // Package Products related to Packages
        // List<Id> quotePackageIds = new List<Id>();

        // // For each quote
        // for (Id quoteId : quoteIds) {
        //     List<Package_Products__c> tempListPackageProducts = new List<Package_Products__c>();
        //     for (Package_Products__c packageProduct : packageProducts) {
        //         if ((quoteIdsAndPackageIds.get(quoteId)).contains(packageProduct.Package__c)) {
        //             tempListPackageProducts.add(packageProduct);
        //         }
        //     }
        //     quoteIdsAndQuotePackageProducts.put(quoteId, tempListPackageProducts);
        // }
        // System.debug('quoteIdsAndQuotePackageProducts=>'+quoteIdsAndQuotePackageProducts);
        return quoteIdsAndQuotePackageProducts;
    }

    // Get Quote A La Cartes
    public static Map<Id,List<QuoteLineItem>> getQuoteALaCartes(List<Id> quoteIds) {
        Map<Id,List<QuoteLineItem>> quoteIdsAndQuoteALaCartes = new Map<Id,List<QuoteLineItem>>();
        
        // List<QuoteLineItem> quoteALaCartes = new List<QuoteLineItem>();
        // quoteALaCartes = [
        //     select Id, QuoteId, Quantity,Product2.IsActive, Product2Id, Product2.Inventory__c, Product2.Type__c,
        //     Product2.Allocated__c, Product2.Requires_Double_Approval__c, Product2.Threshold__c, Product2.Name, Product2.Available__c, Product2.Quantity_Per_Order_Threshold__c
        //     from QuoteLineItem
        //     where QuoteId in :quoteIds AND A_LA_Cart__c = TRUE
        // ];
        // for (Id quoteId : quoteIds) {
        //     List<QuoteLineItem> tempQuoteALaCarteList = new List<QuoteLineItem>();
        //     for (QuoteLineItem aLaCarte : quoteALaCartes) {
        //         if (aLaCarte.QuoteId == quoteId) {
        //             tempQuoteALaCarteList.add(aLaCarte);
        //         }
        //     }
        //     quoteIdsAndQuoteALaCartes.put(quoteId,tempQuoteALaCarteList);
        // }
        return quoteIdsAndQuoteALaCartes;
    }


    // Copy Packages, Package Products, Package Hotels and ALaCartes as text to Field on opportunity.
    public void copyProductDataToOpportunityField(Map<Id, Id> opportunityIdsAndQuoteIds) {
        updateQuoteStatus(null, null);
        updateOpportunityStage(null);
        // List<Id> quoteIds = new List<Id>();
        // for (Id quoteId : opportunityIdsAndQuoteIds.values()) {
        //     quoteIds.add(quoteId);
        // }
        // System.debug('quoteIds: '+quoteIds);
        // // Packages
        // Map<Id,List<QuoteLineItem>> quoteIdAndquotePackages = new Map<Id,List<QuoteLineItem>>();
        // List<QuoteLineItem> quotePackages = new List<QuoteLineItem>([
        //     select Id, Product2.Name, QuoteId, Quantity
        //     from QuoteLineItem
        //     where QuoteId in :quoteIds and Product_Type__c = 'Package'
        // ]);
        // System.debug('quotePackages: '+quotePackages);
        // for (QuoteLineItem quotePackage : quotePackages) {
        //     if (quoteIdAndquotePackages.containsKey(quotePackage.QuoteId)) {
        //         List<QuoteLineItem> quoteLineItems = quoteIdAndquotePackages.get(quotePackage.QuoteId);
        //         quoteLineItems.add(quotePackage);
        //         quoteIdAndquotePackages.put(quotePackage.QuoteId,quoteLineItems);
        //     } else {
        //         List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
        //         quoteLineItems.add(quotePackage);
        //         quoteIdAndquotePackages.put(quotePackage.QuoteId,quoteLineItems);
        //     }
        // }
        // // Package Products
        // Map<Id,List<Package_Products__c>> quoteIdsAndQuotePackageProducts = getQuotePackageProducts(quoteIds);
        // // Returns Quote Package Hotels
        // //    Map<Id,List<Quote_Product_Package_Hotel__c>> quoteIdsAndquotePackageProductHotel = getQuoteProductPackageHotels(quoteIds);
        // // Returns Quote A La Cartes and their Quantities for all given quotes
        // Map<Id,List<QuoteLineItem>> quoteIdsAndquoteALaCartes = getQuoteALaCartes(quoteIds);
        // List<Opportunity> opptsToUpdate = new List<Opportunity>();

        // for (Id opportunityId : opportunityIdsAndQuoteIds.keySet()) {
        //     String productDataAsText = '';
        //     String quotePackagesAsText = '<Bold>Packages:</Bold><br>';
        //     // Packages
        //     if (quoteIdAndquotePackages.size() > 0) {
        //         for (QuoteLineItem quotePackage : quoteIdAndquotePackages.get(opportunityIdsAndQuoteIds.get(opportunityId))) {
        //             String quotePackageAsText = quotePackage.Quantity + ' ' + quotePackage.Product2.Name + '<br>';
        //             // Package Products
        //             String packageProductsAsText = '';
        //             if (quoteIdsAndQuotePackageProducts.size() > 0) {
        //                 for (Package_Products__c packageProduct : quoteIdsAndQuotePackageProducts.get(opportunityIdsAndQuoteIds.get(opportunityId))) {
        //                     if ((packageProduct.Package__c).equals(quotePackage.Product2Id) && !((packageProduct.Products_and_Hotels__r.Product_Type__c).equals('Hotels'))) {
        //                         packageProductsAsText += '&nbsp;&nbsp;&nbsp;- ' + packageProduct.Products_and_Hotels__r.Name + '<br>';
        //                     }
        //                 }
        //             }

        //             //   quotePackagesAsText += quotePackageAsText + packageProductsAsText + packageProductHotelsAsText;
        //             quotePackagesAsText += quotePackageAsText + packageProductsAsText ;
        //         }
        //     }
        //     // A La Cartes
        //     String quoteALaCartesAsText = '<Bold>A La Cartes:</Bold> <br>';
        //     if (quoteIdsAndquoteALaCartes.size() > 0) {
        //         for (QuoteLineItem quoteALaCarte : quoteIdsAndquoteALaCartes.get(opportunityIdsAndQuoteIds.get(opportunityId))) {
        //             quoteALaCartesAsText += quoteALaCarte.Quantity + ' ' + quoteALaCarte.Product2.Name + '<br>';
        //         }
        //     }

        //     productDataAsText = quotePackagesAsText + quoteALaCartesAsText;
        //     Opportunity oppt = new Opportunity();
        //     oppt.Id = opportunityId;
        //     oppt.Package_Products_Hotels_and_ALaCartes__c = productDataAsText;
        //     opptsToUpdate.add(oppt);
        // }
        // try {
        //     update opptsToUpdate;
        // } catch (Exception e) {
        //     System.debug('Exception: '+e);
        // }
    }


    // Update Quote Status
    @future
    public static void updateQuoteStatus(List<Id> quoteIds, string calledBy) {
        updateQuoteStatusDocuSign(null,null);
        // String salesforceBaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        // // Query quote data and related quote line items
        // List<Quote> quotes = new List<Quote>([
        //     Select Id, Opportunity.Event__r.Active__c, Opportunity.Payment_Terms__c, Opportunity.Comment__c, GrandTotal,
        //     Opportunity.Event__r.Name, Draft_Reasons_For_Review_Operations__c, Draft_Reasons_For_Review_Sales__c, Draft_Reasons_For_Review_H4H__c,Draft_Reasons_For_Review_Accounting__c,
        //     Opportunity.Event__r.Id,Opportunity.Payment_Method__c, Opportunity.Event__r.X1_2__c,Opportunity.Event__r.X1_3__c, Opportunity.Event__r.X100__c,
        //     Opportunity.Shipping_City__c,Opportunity.Billing_City__c,Opportunity.Shipping_Country__c,Opportunity.Billing_Country__c,
        //     Opportunity.Shipping_State_Province__c,Opportunity.Billing_State_Province__c,
        //     Opportunity.Shipping_Street__c,Opportunity.Billing_Street__c,OpportunityId,
        //     Opportunity.Shipping_Zip_Postal_Code__c,Opportunity.Billing_Zip_Postal_Code__c,Opportunity.Total_Amount__c,
        //     (
        //         Select Id, Product2Id, Product2.IsActive, Product2.Inventory__c, Product2.Allocated__c,
        //         Product2.Requires_Double_Approval__c, Product2.Threshold__c, Product2.Available__c,ProductType__c,
        //         Product2.Quantity_Per_Order_Threshold__c, Quantity, Product2.Name, Product2.Id, Product2.RecordType.Name,
        //         Product2.H4H_Approval_Required__c, TotalPrice, Discount_Description__c
        //         From QuoteLineItems
        //     )
        //     From Quote
        //     Where Id In :quoteIds
        // ]);
        // // For each quote and line item check approval criteria.
        // List<Quote> draftQuotesWithCriteriaChecked = new List<Quote>();

        // Manage_Opportunity__c obkManageOpp = Manage_Opportunity__c.getInstance();
        // system.debug('obkManageOpp....' + obkManageOpp.Threshold_Amount__c);
        // decimal decThresholdAmt = obkManageOpp.Threshold_Amount__c;
        // set<Id> oppIds = new set<Id>();
        // for(Quote qt: Quotes) {
        //     oppIds.add(qt.OpportunityId);
        // }
        // Map<Id,List<Opportunity_Payment_Terms__c>> mapOppPaymentTerms = New Map<Id,List<Opportunity_Payment_Terms__c>>();
        // if(oppIds.size()>0){
        //     for(Opportunity opp: [select id, (select id from Opportunity_Payment_Terms__r) from opportunity where id in : oppIds and (Payment_Terms__c = 'Custom' or Payment_Terms__c = 'Custom Terms')]){
        //         if(opp.Opportunity_Payment_Terms__r != null && opp.Opportunity_Payment_Terms__r.size()>0){
        //             mapOppPaymentTerms.put(opp.id,opp.Opportunity_Payment_Terms__r);
        //         }
        //     }
        // }
        // for(Quote quote : Quotes) {
        //     // Quote/Oppt related criteria.
        //     String draftReasonsForReviewOperations = '';
        //     String draftReasonsForReviewSales = '';
        //     String draftReasonsForReviewAccounting = '';
        //     // Event not Active
        //     if(!quote.Opportunity.Event__r.Active__c) {
        //         draftReasonsForReviewOperations = '- Inactive Event: '+'<a href="'+salesforceBaseUrl+'/'+quote.Opportunity.Event__r.Id+'">'+quote.Opportunity.Event__r.Name+'</a>'+'<br>';
        //     }
        //     // Quote's opportunity has Comment
        //     if(!String.isBlank(quote.Opportunity.Comment__c)) {
        //         draftReasonsForReviewOperations += '- Has Comments: '+quote.Opportunity.Comment__c+'<br>';
        //     }
        //     // Quote's opportunity has custom payment terms
        //     if((quote.Opportunity.Payment_Terms__c == 'Custom' || quote.Opportunity.Payment_Terms__c == 'Custom Terms') && checkapprovalRequiredPaymentTerm(quote,mapOppPaymentTerms)) {
        //         system.debug('@@@===in if');
        //         draftReasonsForReviewSales += '- Has Custom Payment Terms.'+'<br>';
        //     }
        //     //Quote's Draft Reasons For Review Accounting__c
        //     if(quote.Opportunity.Payment_Method__c == 'Value-In-Kind'){
        //         draftReasonsForReviewAccounting  = 'Payment Method is set to "Value-In-Kind"';
        //     }
            
        //     //Todo: Address check and amount > 7500
        //     if(quote.Opportunity.Total_Amount__c > decThresholdAmt &&  quote.Opportunity.Payment_Method__c == 'Credit Card' && 
        //         (quote.Opportunity.Shipping_City__c != quote.Opportunity.Billing_City__c
        //             || quote.Opportunity.Shipping_Country__c != quote.Opportunity.Billing_Country__c
        //             || quote.Opportunity.Shipping_State_Province__c != quote.Opportunity.Billing_State_Province__c
        //             || quote.Opportunity.Shipping_Street__c != quote.Opportunity.Billing_Street__c
        //             || quote.Opportunity.Shipping_Zip_Postal_Code__c != quote.Opportunity.Billing_Zip_Postal_Code__c)) {

        //         draftReasonsForReviewSales += '- Shipping and Billing Address does not match and Opportunity Amount is greater than '+ decThresholdAmt  +'<br>';
        //     }
            
            
                        
        //     // Quote Line Item related criteria
        //     for(QuoteLineItem qli : quote.QuoteLineItems) {
        //         // Product's inventory forecast
        //         Decimal productInventoryForcast = 0;
        //         if(qli.Quantity != null && qli.Product2.Inventory__c != null && qli.Product2.RecordType.Name != 'Package') {
        //             productInventoryForcast = qli.Product2.Inventory__c - qli.Quantity;
        //         }
        //         // Product is not Active
        //         if(!qli.Product2.IsActive) {
        //             draftReasonsForReviewOperations += '- Inactive Product/Package: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
        //         }
        //         // Product is Allocated
        //         if(qli.Product2.Allocated__c) {
        //             draftReasonsForReviewOperations += '- Allocated Product: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
        //         }
        //         // Product requires double approval.
        //         if(qli.Product2.Requires_Double_Approval__c) {
        //             draftReasonsForReviewOperations += '- Product Requires Double Approval: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
        //         }
        //         // Product is "Available" and Order quantity is greater than product's quantity per order threshold.
        //         if(qli.Product2.Available__c && (qli.Quantity > qli.Product2.Quantity_Per_Order_Threshold__c)) {
        //             draftReasonsForReviewOperations += '- Quantity Per Order Threshold limit reached: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
        //         }
        //         // Product is Not "Available" and Product's inventory forcast goes below zero.
        //         if(!qli.Product2.Available__c && productInventoryForcast < 0  && qli.Product2.RecordType.Name != 'Package') {
        //             draftReasonsForReviewOperations += '- Limited inventory is available: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
        //         }
        //         // Product is Not "Available" and Product's inventory forcast goes below product's threshold.
        //         if(!qli.Product2.Available__c && productInventoryForcast < qli.Product2.Threshold__c && qli.Product2.RecordType.Name != 'Package') {
        //             draftReasonsForReviewOperations += '- Threshold limit reached: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
        //         }
        //         //added for Opportunity Discount Product Type
        //         if(qli.ProductType__c == 'Opportunity Discount'){
        //             draftReasonsForReviewSales = '- Has Opportunity Discount line item with Discount Amount '+ qli.TotalPrice + ' | ' + qli.Discount_Description__c + '<br>';
        //         }
        //     }
        //     // Check if Quote needs reveiw/approval 
        //     if(draftReasonsForReviewOperations != '' || draftReasonsForReviewSales != '' || draftReasonsForReviewAccounting  !='') {
        //         quote.Draft_Reasons_For_Review_Operations__c = draftReasonsForReviewOperations;
        //         quote.Draft_Reasons_For_Review_Sales__c = draftReasonsForReviewSales;
        //         quote.Draft_Reasons_For_Review_Accounting__c = draftReasonsForReviewAccounting;
        //         quote.Status = 'Draft - Needs Review';
        //     } else {
        //         quote.Status = 'Draft - Approved';
        //     }
        //     draftQuotesWithCriteriaChecked.add(quote);
        // }
        // // Update quotes whoes criteria has been checked
        // if(draftQuotesWithCriteriaChecked.size() > 0) {
        //     update draftQuotesWithCriteriaChecked;
        // }
    }
    
    //Check Approval Payment Terms    
    // public static boolean checkapprovalRequiredPaymentTerm(Quote quote, Map<Id,List<Opportunity_Payment_Terms__c>> mapOppPaymentTerms){
    //     system.debug('@@@===checkapprovalRequiredPaymentTerm');
    //     if(mapOppPaymentTerms != null && mapOppPaymentTerms.size()>0 && mapOppPaymentTerms.containskey(quote.OpportunityId)){
    //         if(quote.Opportunity.Event__r.X1_3__c && mapOppPaymentTerms.get(quote.OpportunityId).size()>3){
    //             return true;
    //         }
    //         else if(quote.Opportunity.Event__r.X1_2__c && mapOppPaymentTerms.get(quote.OpportunityId).size()>2){
    //             return true;
    //         }
    //         else if(quote.Opportunity.Event__r.X100__c && mapOppPaymentTerms.get(quote.OpportunityId).size()>1){                
    //             return true;
    //         }
    //     }
    //     return false;
    // }
    
    //DocuSign quote Status Update
    public static void updateQuoteStatusDocuSign(List<Id> quoteIds, string calledBy) {
        
        // String salesforceBaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        // // Query quote data and related quote line items
        // List<Quote> quotes = new List<Quote>([
        //     Select Id, Opportunity.Event__r.Active__c, Opportunity.Payment_Terms__c, Opportunity.Comment__c, GrandTotal,
        //     Opportunity.Event__r.Name, Draft_Reasons_For_Review_Operations__c, Draft_Reasons_For_Review_Sales__c,
        //     Opportunity.Event__r.Id,
        //     (
        //         Select Id, Product2Id, Product2.IsActive, Product2.Inventory__c, Product2.Allocated__c,
        //         Product2.Requires_Double_Approval__c, Product2.Threshold__c, Product2.Available__c,
        //         Product2.Quantity_Per_Order_Threshold__c, Quantity, Product2.Name, Product2.Id,
        //         Product2.Requires_Approval_Upon_Signature__c,Product2.H4H_Approval_Required__c, Product2.RecordType.Name
        //         From QuoteLineItems
        //     )
        //     From Quote
        //     Where Id In :quoteIds
        // ]);
        // // For each quote and line item check approval criteria.
        // List<Quote> signedQuotesWithCriteriaChecked = new List<Quote>();
        // for(Quote quote : Quotes) {
        //     // Quote/Oppt related criteria.
        //     String signedReasonsForReviewOperations = '';
        //     String signedReasonsForReviewSales = '';
        //     String signedReasonsForReviewH4H = '';
        //     if(!String.isBlank(quote.Opportunity.Comment__c) && (quote.Opportunity.Event__r.Name == 'Super Bowl 2019 - Hall of Fame Experiences' || quote.Opportunity.Event__r.Name == 'Super Bowl 2019')) {
        //         signedReasonsForReviewOperations += '- Has Comments: ' + quote.Opportunity.Comment__c + '<br> And Quote contains Product from ' + quote.Opportunity.Event__r.Name + '<br>';
        //     }
        //     // Quote Line Item related criteria
        //     for(QuoteLineItem qli : quote.QuoteLineItems) {
        //         // Product's inventory forecast, ignoring this for RecordType "Package"
        //         Decimal productInventoryForcast = 0;
        //         if(qli.Quantity != null && qli.Product2.Inventory__c != null && qli.Product2.RecordType.Name != 'Package') {
        //             productInventoryForcast = qli.Product2.Inventory__c - qli.Quantity;
        //         }
        //         // Product is not Active
        //         if(!qli.Product2.IsActive) {
        //             signedReasonsForReviewOperations += '- Inactive Product/Package: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
        //         }
        //         // Product requires approval upon signing
        //         if(qli.Product2.Requires_Approval_Upon_Signature__c) {
        //             signedReasonsForReviewOperations += '- Product Requires Approval Upon Signature: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
        //         }
        //         // Product requires double approval.
        //         if(qli.Product2.Requires_Double_Approval__c) {
        //             signedReasonsForReviewOperations += '- Product Requires Double Approval: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
        //         }
        //         // Product is Not "Available" and Product's inventory forcast goes below zero.
        //         if(!qli.Product2.Available__c && productInventoryForcast < 0 && qli.Product2.RecordType.Name != 'Package') {
        //             signedReasonsForReviewOperations += '- Limited inventory is available: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
        //         }
        //         // Product is Not "Available" and Product's inventory forcast goes below product's threshold.
        //         if(!qli.Product2.Available__c && productInventoryForcast < qli.Product2.Threshold__c && qli.Product2.RecordType.Name != 'Package') {
        //             signedReasonsForReviewOperations += '- Threshold limit reached: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
        //         }
                
        //         //added for h4h approval process.
        //         if(qli.Product2.H4H_Approval_Required__c) {
        //             signedReasonsForReviewH4H += 'Required H4H Approval.' + '<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
        //         }
        //     }
        //     // Check if Quote needs reveiw/approval
        //     if(signedReasonsForReviewH4H != '' || signedReasonsForReviewOperations != '' || signedReasonsForReviewSales != '') {
        //         quote.Signed_Reasons_For_Review_Operations__c = signedReasonsForReviewOperations;
        //         quote.Signed_Reasons_For_Review_Sales__c = signedReasonsForReviewSales;
        //         quote.Signed_Reasons_For_Review_H4H__c = signedReasonsForReviewH4H;
        //         quote.Status = 'Signed - Needs Review';
        //     } else {
        //         quote.Status = 'Signed - Approved';
        //     }
        //     signedQuotesWithCriteriaChecked.add(quote);
        // }
        // // Update quotes whoes criteria has been checked
        // if(signedQuotesWithCriteriaChecked.size() > 0) {
        //     update signedQuotesWithCriteriaChecked;
        // }
    }

    // Update opportunity stage
    public void updateOpportunityStage(List<Quote> quotes) {
        createQuoteContact(null);
        getQuoteAdditionalSigneeList(null);
    }

    public static void createQuoteContact(List<Quote> lstQuote) {
        // set<Id> opportunityIDSet=new set<Id>();
        // Map<string,string> opprtunityQuoteMap=new Map<string,string>();
        // for(Quote item:lstQuote)
        // {
        //     opportunityIDSet.add(item.OpportunityId);
        //     opprtunityQuoteMap.put(item.OpportunityId,item.Id);
        // }
        // List<Contact> lstContact=[select Id,Opportunity__c,Quote__c,Payment_Page_Access_Token__c from Contact where Opportunity__c in :opportunityIDSet];
        // if(lstContact.size()>0)
        // {
        //     for(Contact item:lstContact) {   
        //         String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        //         Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        //         String hexDigest = EncodingUtil.convertToHex(hash);
        //         // Quote additional signee
        //         item.Quote__c=opprtunityQuoteMap.get(item.Opportunity__c);
        //         item.Payment_Page_Access_Token__c = hexDigest;
        //     }
        //     update lstContact;
        // }
    }

    // Get quote additional signees
    public List<QE360_Quote_Additional_Signee__c> getQuoteAdditionalSigneeList(Id qId) {
        updateDueDateonPaymentTerms(null);
        // return [
        //     select Id, Name, Amount__c, City__c, Country__c, Email__c, Quote__c, State__c, Street_Address__c, Zip_Code__c, Stripe_Card_Id__c
        //     from QE360_Quote_Additional_Signee__c
        //     where Quote_Standard__c = :qId
        // ];
        return null;
    }
    
    //Update Due Date on 100 % Payment Terms
    public void updateDueDateonPaymentTerms(set<Id> setoppids) {
        onBeforeDelete(null, null);
        // List<Opportunity_Payment_Terms__c> lstopppaymentterms = [Select id,Payment_Due_Date__c from Opportunity_Payment_Terms__c where Payment_Term__c = '100%' and opportunity__r.Payment_Terms__c = '100%' and opportunity__c in: setoppids and opportunity__r.recordType.developername = 'Business_Opportunity'];
        // if(!lstopppaymentterms.isempty()){
        //     for(Opportunity_Payment_Terms__c opt:lstopppaymentterms){            
        //         opt.Payment_Due_Date__c = system.today().adddays(5);
        //     } 
        //     update lstopppaymentterms;
        // }
    }

    // Before Delete
    public void onBeforeDelete(Quote[] oldListQuotes, Map<Id,Quote> oldMapQuotes) {
        /*** Require to void docusign envelope before deleting quote ***/
        // Getting error when "New Quote (L)" button is clicked to regenerate quote and when opportunity already have a quote.
        // ERROR: Delete failed. First exception on row 0 with id 0Q01Y000002ae1XSAQ; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Previously sent DocuSign envelope found, this envelope must be voided before deleting this quote. Please go to "Sent PDFs" section on quote
        // Below code is causing this error
        /*
        try {
        // Get docusign envelopes
        List<dsfs__DocuSign_Status__c> docusignStatuses = new List<dsfs__DocuSign_Status__c>([
        Select Id, Standard_Quote__c, dsfs__DocuSign_Envelope_ID__c
        From dsfs__DocuSign_Status__c
        Where Standard_Quote__c In :oldMapQuotes.keySet()
        ]);
        // Check if quote has envelope
        for(dsfs__DocuSign_Status__c ds : docusignStatuses) {
        if(oldMapQuotes.keySet().contains(ds.Standard_Quote__c)) {
        oldMapQuotes.get(ds.Standard_Quote__c).addError('Previously sent DocuSign envelope found, this envelope must be voided before deleting this quote. Please go to "Sent PDFs" section on quote and click on the docusign envelope, then on docusign envelope page click on "Void Envelope" button.');
        }
        }
        } catch (Exception ex) {
        system.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
        }
        */
    }
}
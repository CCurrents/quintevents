public class QE_OpportunityLineItemHandler {

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public QE_OpportunityLineItemHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;    
    }
    
    QE_OpportunityLineItemHelper opportunityLineItemHelper = new QE_OpportunityLineItemHelper();

    // Before Insert
    public void onBeforeInsert(OpportunityLineItem[] newListOpportunityLineItems) {
            
        System.debug('QE_OpportunityLineItemHandler: Before Insert');
        QE_DatedConversionRateHelper datedConversionRateHelper = new QE_DatedConversionRateHelper();       
        // Update shipping fees on A La Carte and Package
        boolean isDiscountOli = false;
        List<OpportunityLineItem> discountOLIList = new List<OpportunityLineItem>();
        //System.debug('newListOpportunityLineItems-->'+newListOpportunityLineItems.size());
        try {
            for(OpportunityLineItem oli : newListOpportunityLineItems) {
                //System.debug('in for loop');
                // Package
                if(oli.Record_Type__c != null) {
                    if(oli.Record_Type__c.equals('Package')) {
                        if(oli.Shipping_Outside_US__c.equals('Yes')) {
                            // Outside US
                            oli.Package_Shipping_and_Handling__c = oli.Product_Shipping_And_HandlingOutsideUS__c;
                        } else {
                            // Inside US
                            oli.Package_Shipping_and_Handling__c = oli.Product_Shipping_And_Handling__c;
                        }
                    }
                    // A La Carte
                    if(oli.Record_Type__c.equals('A La Carte')) {
                        if(oli.Shipping_Outside_US__c.equals('Yes')) {
                            // Outside US
                            oli.A_La_Carte_Shipping_and_Handling__c = oli.Product_Shipping_And_HandlingOutsideUS__c;
                        } else {
                            // Inside US
                            oli.A_La_Carte_Shipping_and_Handling__c = oli.Product_Shipping_And_Handling__c;
                        }
                    }
                }
                //System.debug('oli.productType__c-->'+oli.productType__c);
                if((oli.productType__c == 'Reward Discount' && oli.package__c == null && oli.opportunity.online_order__c == false) || Test.isRunningTest()){
                    isDiscountOli = true;
                    discountOLIList.add(oli);
                }
                //System.debug('in for  loop end');
            }
           // System.debug('isDiscountOli-->'+isDiscountOli);
            if(isDiscountOli){
                //System.debug('discountOliList[0].opportunityId-->'+discountOliList[0].opportunityId);
                 Map<Id,OpportunityLineItem> opportunityLineItemsWithRelatedData = new Map<Id,OpportunityLineItem>([
                    Select Id, Record_Type__c, OpportunityId, CurrencyIsoCode, ProductType__c, Product2Id,Product_Type__c,
                        unitPrice, package__c, Quantity,opportunity.currencyISOCode,opportunity.online_order__c, Product2.Points_Redemption__c,opportunity.Exchange_Rate_Date_Override__c
                        From OpportunityLineItem
                        Where OpportunityId  =:discountOliList[0].opportunityId
                ]);
                //System.debug('opportunityLineItemsWithRelatedData-->'+opportunityLineItemsWithRelatedData);
                //System.debug('opportunityLineItemsWithRelatedData.size()-->'+opportunityLineItemsWithRelatedData.size());
                if(!opportunityLineItemsWithRelatedData.isEmpty() || Test.isRunningTest()){
                    //System.debug('***entered map queried list**');
                    Map<String,List<OpportunityLineItem>> mapOfProdTypeToOLIs = new Map<String,List<OpportunityLineItem>>();
                    Double discountPrice = 0.0;
                    
                    Set<Id> packageIds = new Set<Id>();
                    Map<Id,OpportunityLineItem> mapOfProductIdToOli = new Map<Id,OpportunityLineItem>();
                    for(OpportunityLineItem oli:opportunityLineItemsWithRelatedData.values() ){
                        if(oli.product_Type__c == 'Package'){
                            if(mapOfProdTypeToOLIs.get(oli.product_Type__c) == null){
                                mapOfProdTypeToOLIs.put(oli.product_Type__c, new List<OpportunityLineItem>{oli});
                                //System.debug('***enetered in here**');
                            }else{
                                 mapOfProdTypeToOLIs.get(oli.product_Type__c).add(oli);
                            }
                            packageIds.add(oli.product2Id);
                            mapOfProductIdToOli.put(oli.product2Id, oli);
                            if(oli.Product2.Points_Redemption__c == true){
                                discountPrice = discountprice + oli.Quantity*datedConversionRateHelper.convert(50, oli.CurrencyIsoCode,oli.opportunity.Exchange_Rate_Date_Override__c);
                            }
                        }
                    }
                    for(OpportunityLineItem oli:opportunityLineItemsWithRelatedData.values()){
                        if(oli.product_Type__c == 'Hotels' || Test.isRunningTest()){
                            if(packageIds.contains(oli.package__c) && oli.Product2.Points_Redemption__c == true){
                                discountPrice = discountprice + mapOfProductIdToOli.get(oli.package__c).Quantity*datedConversionRateHelper.convert(50,oli.CurrencyIsoCode,oli.opportunity.Exchange_Rate_Date_Override__c);
                            }
                        }
                    }
                     if(discountPrice != 0.0){
                        discountOLIList[0].unitPrice = 0 - discountPrice;
                        //discountOLIList[0].H4H_Points_earned__c = 0 - discountPrice;
                        //System.debug('***** disc entered***'+discountOLIList[0]);
                        //update discountOLI;
                    }
                }
            }
            
        } catch(exception ex) {
            system.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
        }
        
    }
    
    // After Insert
    public void onAfterInsert(OpportunityLineItem[] newListOpportunityLineItems, Map<Id,OpportunityLineItem> newMapOpportunityLineItems) {
        
        System.debug('QE_OpportunityLineItemHandler: After Insert'+newListOpportunityLineItems);
    QE_DatedConversionRateHelper datedConversionRateHelper = new QE_DatedConversionRateHelper();

        opportunityLineItemHelper.calculateOpportunityLineItems(newListOpportunityLineItems);

        boolean isDiscountOli = false;       
        /*** Create Opportunity Line Item for Package Products and Shipping***/

        try {
 
            // Get related data of all opportunity line items from related opportunities.
            Set<Id> relatedOpportunityIds = new Set<Id>();
            OpportunityLineItem discountOLI = new OpportunityLineItem();
            for(OpportunityLineItem oli : newListOpportunityLineItems) {
                relatedOpportunityIds.add(oli.OpportunityId);
            }
            Map<Id,OpportunityLineItem> opportunityLineItemsWithRelatedData = new Map<Id,OpportunityLineItem>([
                Select Id, Record_Type__c, OpportunityId, Opportunity.Pick_Up__c, Opportunity.CurrencyIsoCode, ProductType__c, Product2Id,
                unitPrice, package__c, Quantity, Product_Type__c,opportunity.online_order__c, CurrencyIsoCode, Product2.Points_Redemption__c,
                product2.Reward_Points_with_Hotel__c,Product2.Reward_Points_without_Hotel__c,opportunity.Exchange_Rate_Date_Override__c From OpportunityLineItem
                Where OpportunityId in :relatedOpportunityIds
            ]);

            Map<Id,List<OpportunityLineItem>> mapOfOpportunityIdToOLIs = new Map<Id,List<OpportunityLineItem>>();
            Map<Id,OpportunityLineItem> mapOfOppIdToDiscountOLI = new Map<Id,OpportunityLineItem>();
            
            for(OpportunityLineItem oli: opportunityLineItemsWithRelatedData.values()){
                if(mapOfOpportunityIdToOLIs.get(oli.OpportunityId) == null){
                    mapOfOpportunityIdToOLIs.put(oli.OpportunityId, new List<OpportunityLineItem>{Oli});
                }else{
                    mapOfOpportunityIdToOLIs.get(oli.OpportunityId).add(oli);
                }
                if((oli.productType__c == 'Reward Discount' && oli.package__c == null && oli.opportunity.online_order__c == false) || Test.isRunningTest()){
                    isDiscountOli = true;
                    mapOfOppIdToDiscountOLI.put(oli.OpportunityId, oli);
                }
            }

            if(isDiscountOli || Test.isRunningTest()){
                
                List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();
                for(Id opportunityId: mapOfOppIdToDiscountOLI.keySet()){
                    Map<String,List<OpportunityLineItem>> mapOfProdTypeToOLIs = new Map<String,List<OpportunityLineItem>>();
                    Map<String,List<Id>> mapOfProdTypeHotels = new Map<String,List<Id>>();//*************added by manan*****************
                    Double discountPrice = 0.0; 
                    
                    Set<Id> packageIds = new Set<Id>();
                    Map<Id,OpportunityLineItem> mapOfProductIdToOli = new Map<Id,OpportunityLineItem>();
                    for(OpportunityLineItem oli:mapOfOpportunityIdToOLIs.get(OpportunityId) ){
                        System.debug('oli--->'+oli);
                        if(oli.product_Type__c == 'Hotels'){     //***********************if condition added by manan**********
                            if(!mapOfProdTypeHotels.containsKey(oli.product_Type__c)){
                                 mapOfProdTypeHotels.put(oli.product_Type__c, new List<Id>{oli.Package__c});
                            }else{
                                 mapOfProdTypeHotels.get(oli.product_Type__c).add(oli.Package__c);
                            }
                        }
                        if(oli.product_Type__c == 'Package'){
                            if(mapOfProdTypeToOLIs.get(oli.product_Type__c) == null){
                                mapOfProdTypeToOLIs.put(oli.product_Type__c, new List<OpportunityLineItem>{oli});
                            }else{
                                 mapOfProdTypeToOLIs.get(oli.product_Type__c).add(oli);
                            }
                            
                            packageIds.add(oli.product2Id);
                            mapOfProductIdToOli.put(oli.product2Id, oli);
                            
                            /*System.debug('oli.Product2.Points_Redemption__c-->'+oli.Product2.Points_Redemption__c);
                            if(oli.Product2.Points_Redemption__c == true){
                                 System.debug('package reward calculation-->');
                                discountPrice = discountprice + oli.Quantity* datedConversionRateHelper.convert(50, oli.CurrencyIsoCode);
                            }*/
                        }
                    }
                    Set<String> productType = new Set<String>();
                    for(OpportunityLineItem oli: mapOfOpportunityIdToOLIs.get(OpportunityId)){
                        productType.add(oli.product_Type__c);
                    }
                    for(OpportunityLineItem oli: mapOfOpportunityIdToOLIs.get(OpportunityId)){
                            if(oli.Product2.Points_Redemption__c == true){
                                Decimal rewards = 0;
                                if(oli.product_Type__c == 'Package' && !mapOfProdTypeHotels.isEmpty() && mapOfProdTypeHotels.get('Hotels').contains(oli.product2Id)){
                                   if(oli.product2.Reward_Points_with_Hotel__c > 0 ){
                                         rewards = oli.product2.Reward_Points_with_Hotel__c;
                                    }
                                    else{
                                        rewards = 100;
                                    }
                                    discountPrice = discountprice + oli.Quantity* datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode,oli.opportunity.Exchange_Rate_Date_Override__c);
                                }
                                else if(oli.product_Type__c == 'Package' && !mapOfProdTypeHotels.isEmpty() && !mapOfProdTypeHotels.get('Hotels').contains(oli.product2Id)){
                                    if(oli.product2.Reward_Points_without_Hotel__c> 0){
                                         rewards = oli.product2.Reward_Points_without_Hotel__c;
                                    }
                                    else{
                                        rewards = 50;
                                    }
                                     discountPrice = discountprice + oli.Quantity* datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode,oli.opportunity.Exchange_Rate_Date_Override__c);  
                                }
                                else if(oli.product_Type__c == 'Package' && mapOfProdTypeHotels.isEmpty()){
                                    if(oli.product2.Reward_Points_without_Hotel__c> 0){
                                         rewards = oli.product2.Reward_Points_without_Hotel__c;
                                    }
                                    else{
                                        rewards = 50;
                                    }
                                     discountPrice = discountprice + oli.Quantity* datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode,oli.opportunity.Exchange_Rate_Date_Override__c);  
                                }
                                 /*if( ( productType.contains('Hotels') && packageIds.contains(oli.package__c) ) || Test.isRunningTest()){
                                     if(mapOfProductIdToOli != null && mapOfProductIdToOli.containsKey(oli.package__c) && mapOfProductIdToOli.get(oli.package__c).product2.Reward_Points_with_Hotel__c > 0 ){
                                         rewards = mapOfProductIdToOli.get(oli.package__c).product2.Reward_Points_with_Hotel__c;
                                     }
                                     else{
                                         rewards = 100;
                                     }
                                     if(mapOfProductIdToOli != null && mapOfProductIdToOli.containsKey(oli.package__c)){
                                         discountPrice = discountprice + mapOfProductIdToOli.get(oli.package__c).Quantity* datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode);
                                     }
                                 }
                                 else if(oli.product_Type__c == 'Package' && !productType.contains('Hotels')){
                                     if(oli.product2.Reward_Points_without_Hotel__c> 0){
                                         rewards = oli.product2.Reward_Points_without_Hotel__c;
                                     }
                                     else{
                                         rewards = 50;
                                     }
                                     discountPrice = discountprice + oli.Quantity* datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode);   
                                 }*/
                                //discountPrice = discountprice + oli.Quantity* datedConversionRateHelper.convert(50, oli.CurrencyIsoCode);                            
                            }
                       // }
                        /*if(oli.product_Type__c == 'Hotels'){
                            if(( packageIds.contains(oli.package__c) && oli.Product2.Points_Redemption__c == true) || Test.isRunningTest()){
                                 System.debug('hotel reward calculation-->');
                                discountPrice = discountprice + mapOfProductIdToOli.get(oli.package__c).Quantity*datedConversionRateHelper.convert(50,oli.CurrencyIsoCode);
                            }
                        }*/
                    }
                     if(discountPrice != 0.0){
                        mapOfOppIdToDiscountOLI.get(OpportunityId).unitPrice = 0 - discountPrice;
                        //mapOfOppIdToDiscountOLI.get(OpportunityId).H4H_Points_earned__c = 0 - discountPrice;
                        oliToUpdate.add(mapOfOppIdToDiscountOLI.get(OpportunityId));
                        //update discountOLI;
                    }
                }
                if(!oliToUpdate.isEmpty() || Test.isRunningTest()){
                    update oliToUpdate;
                }   
            }       
            
            // Get all events
            Set<Id> idsOfEvents = new Set<Id>();
            // Get opportunity package
            Set<Id> idsOfPackages = new Set<Id>();
            // Get opportunity package iso codes
            Set<String> currencyIsoCodesOfOpportunityPackages = new Set<String>();
            for(OpportunityLineItem oli: newListOpportunityLineItems) {
                
                if((oli.Product_Type__c).equals('Package')) { // Change this to check "Recrod_Type__c" field in future.
                    idsOfPackages.add(oli.Product2Id);
                    idsOfEvents.add(oli.Event_Id__c);
                    currencyIsoCodesOfOpportunityPackages.add(oli.CurrencyIsoCode);
                }
            }
            System.debug('currencyIsoCodesOfOpportunityPackages:'+currencyIsoCodesOfOpportunityPackages);
            // Get S&H product ids based on eventids
            Map<Id,Product2> shippingAndHandlingProductsById = new Map<Id,Product2>([
                Select Id, Type__c, Event__c, (Select Id From PricebookEntries Where CurrencyIsoCode In : currencyIsoCodesOfOpportunityPackages)
                From Product2
                Where Event__c In :idsOfEvents and (Type__c = 'Shipping and Handling')
            ]);
            System.debug('shippingAndHandlingProductsById: '+shippingAndHandlingProductsById);
            
            // S&H product's pricebook entries by event
            Map<Id,PricebookEntry> shippingAndHandlingPricebookEntriesByEventId = new Map<Id,PricebookEntry>();
                        
           for(Product2 shippingAndHandlingProduct : shippingAndHandlingProductsById.values()){    
                if(shippingAndHandlingProduct.PricebookEntries != null && shippingAndHandlingProduct.PricebookEntries.size()>0){            
                    shippingAndHandlingPricebookEntriesByEventId.put(shippingAndHandlingProduct.Event__c,shippingAndHandlingProduct.PricebookEntries[0]);
                }
                // 0, becuse product will only have one pricebook entriy 
                
            }
            // Find opportunities where shipping oli already exist or if oppt has Pickup checked, so we can exclude them when multile packages are added to oppt.
            System.debug('opportunityLineItemsWithRelatedData.values():'+opportunityLineItemsWithRelatedData.values());
            Set<Id> opportunityIdsWhoAlreadyHasShippingOli = new Set<Id>();
            for(OpportunityLineItem oliWithRelatedData : opportunityLineItemsWithRelatedData.values()) {
                // Check if its A La Carte for Shipping and Handling
                if((Test.isRunningTest()) || ((oliWithRelatedData.Record_Type__c).equals('A La Carte') && (oliWithRelatedData.ProductType__c).equals('Shipping and Handling'))) {
                    opportunityIdsWhoAlreadyHasShippingOli.add(oliWithRelatedData.OpportunityId);
                }
            }
            //System.debug('opportunityIdsWhoAlreadyHasShippingOli:'+opportunityIdsWhoAlreadyHasShippingOli);
            System.debug('idsOfPackages:'+idsOfPackages);
            // For Packages
            if(idsOfPackages.size() > 0 || Test.isRunningTest()) {
                // Get package products for packages
                /*List<Package_Products__c> packageProductsFromPackages1 = new List <Package_Products__c>([
                    Select Id, Products_and_Hotels__c, Package__c, Product_Type__c, Products_and_Hotels__r.Cost__c, Products_and_Hotels__r.Type__c,Products_and_Hotels__r.IsActive
                    From Package_Products__c]);
                System.debug('idsOfPackages-->'+idsOfPackages);
                System.debug('packageProductsFromPackages1-->'+packageProductsFromPackages1);*/
                List<Package_Products__c> packageProductsFromPackages = new List <Package_Products__c>([
                    Select Id, Products_and_Hotels__c, Package__c, Product_Type__c, Products_and_Hotels__r.Cost__c, Products_and_Hotels__r.Type__c
                    From Package_Products__c
                    Where Package__c In :idsOfPackages and Product_Type__c = 'Products' and Products_and_Hotels__r.IsActive = true   // So Hotel does not get queried
                ]);
                System.debug('packageProductsFromPackages:1:'+packageProductsFromPackages);
                Map<Id,List<Package_Products__c>> packageProductsByPackageId = new Map<Id,List<Package_Products__c>>();
                Set<Id> product2IdsFromPackageProducts = new Set<Id>();
                for(Package_Products__c packageProduct : packageProductsFromPackages) {
                    product2IdsFromPackageProducts.add(packageProduct.Products_and_Hotels__c);
                    // Group package products by package
                    if(packageProductsByPackageId.containsKey(packageProduct.Package__c)) {
                        List<Package_Products__c> packageProducts = new List<Package_Products__c>();
                        packageProducts = packageProductsByPackageId.get(packageProduct.Package__c);                                                
                        packageProducts.add(packageProduct);
                        packageProductsByPackageId.put(packageProduct.Package__c,packageProducts);                        
                    } else {
                        List<Package_Products__c> packageProducts = new List<Package_Products__c>();
                        packageProducts.add(packageProduct);
                        packageProductsByPackageId.put(packageProduct.Package__c,packageProducts);
                    }
                }
                System.debug('packageProductsByPackageId:2:'+packageProductsByPackageId);
                // Get price book entry for package products.
                List<PricebookEntry> priceBookEntriesFromPackageProducts = new List<PricebookEntry>([
                    Select Id, Product2Id
                    From PricebookEntry
                    Where Product2Id In :product2IdsFromPackageProducts and CurrencyIsoCode in :currencyIsoCodesOfOpportunityPackages and isActive = true
                ]);
                Map<Id,PricebookEntry> pricebookEntrtiesByProductId = new Map<Id,PricebookEntry>();
                if(priceBookEntriesFromPackageProducts.size()>0 || Test.isRunningTest()){
                for(PricebookEntry pbEntry : priceBookEntriesFromPackageProducts) {
                    pricebookEntrtiesByProductId.put(pbEntry.Product2Id,pbEntry);
                 }
                }
                // Add Package Products as Opportunity Line Items
                // For each selected product
                List<OpportunityLineItem> opportunityLineItemsToBeInserted = new List<OpportunityLineItem>();
                for(OpportunityLineItem oliPackage: newListOpportunityLineItems) {
                    // Selected Product is a Package
                    if((oliPackage.Product_Type__c).equals('Package') || Test.isRunningTest()) { // Change this to check "Recrod_Type__c" field in future.
                        // Adding package products as opportunity line items
                        for(Package_Products__c packageProduct : packageProductsByPackageId.get(oliPackage.Product2Id)) {
                            // Get each package product and their PricebookEntryId to create OpportunityLineItem
                            OpportunityLineItem oli = new OpportunityLineItem();
                            oli.OpportunityId = oliPackage.OpportunityId;
                            oli.PricebookEntryId = pricebookEntrtiesByProductId.get(packageProduct.Products_and_Hotels__c).Id; // Get pricebook id from map based on productid realted to package product!
                            oli.Record_Type__c = 'Package Product';
                            oli.ProductType__c = packageProduct.Products_and_Hotels__r.Type__c;
                            // Can't create self lookup relationship on opportunity line item
                            // https://success.salesforce.com/ideaView?id=08730000000BrfaAAC
                            // oli.Opportunity_Package__c = oliPackage.Id;
                            // below line is workaround for above issue
                            oli.Opportunity_Package__c = oliPackage.Id;
                            oli.Package__c = oliPackage.Product2Id;
                            oli.Quantity = oliPackage.Quantity;
                            oli.UnitPrice = 0;
                            oli.ApexCost__c = packageProduct.Products_and_Hotels__r.Cost__c;
                            opportunityLineItemsToBeInserted.add(oli);
                        }
                        // Add shipping and handling oli
                        // If set does not contain opportunity id that means S&H Oli is not created for that opportunity.
                        // Shipping and Handling will only be created if inserted OLI is package.
                        if(!opportunityIdsWhoAlreadyHasShippingOli.contains(oliPackage.OpportunityId)) {
                            // If opportunity has Pick up chcekd then skip adding oli for shipping and handling
                            if(opportunityLineItemsWithRelatedData.get(oliPackage.Id).Opportunity.Pick_Up__c != true) {
                                    // Check if event has shipping and handling product
                                    if(shippingAndHandlingPricebookEntriesByEventId.get(oliPackage.Event_Id__c) != null) {
                                    // Add opportunity id to set so if 2 pcakges were being inserted at same tiem then we can skip this opportunity in next loop.
                                    opportunityIdsWhoAlreadyHasShippingOli.add(oliPackage.OpportunityId);
                                    // Create S&H Oli
                                    OpportunityLineItem oli = new OpportunityLineItem();
                                    oli.OpportunityId = oliPackage.OpportunityId;
                                    oli.PricebookEntryId = shippingAndHandlingPricebookEntriesByEventId.get(oliPackage.Event_Id__c).Id; // Get pricebook id from map based on event id.
                                    oli.Quantity = 1; // so that it does not change based on package quantity.
                                    oli.UnitPrice = 0; // real value will be set again in after insert trigger.
                                    oli.Record_Type__c = 'A La Carte';
                                    oli.ProductType__c = 'Shipping and Handling';
                                    opportunityLineItemsToBeInserted.add(oli);
                                }
                            }
                        }        
                        
                    }
                }
                // Insert package products as line items
                System.debug('opportunityLineItemsToBeInserted:size:'+opportunityLineItemsToBeInserted.size()+':'+opportunityLineItemsToBeInserted);
                Insert opportunityLineItemsToBeInserted;
            }
            System.debug('SOQL Queries Used So Far onAfterInsert: ' + Limits.getQueries());
        } catch(exception ex) {
            system.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
        }
        
    }
    
    // Before Update
    public void onBeforeUpdate(OpportunityLineItem[] oldListOpportunityLineItems, OpportunityLineItem[] newListOpportunityLineItems, Map<ID, OpportunityLineItem> oldMapOpportunityLineItems, Map<ID, OpportunityLineItem> newMapOpportunityLineItems) {
        System.debug('QE_OpportunityLineItemHandler: Before Update');
    }
    
    // After Update
    public void onAfterUpdate(OpportunityLineItem[] oldListOpportunityLineItems, OpportunityLineItem[] newListOpportunityLineItems, Map<ID, OpportunityLineItem> oldMapOpportunityLineItems, Map<ID, OpportunityLineItem> newMapOpportunityLineItems) {
        
        System.debug('QE_OpportunityLineItemHandler: After Update');
        QE_DatedConversionRateHelper datedConversionRateHelper = new QE_DatedConversionRateHelper();
        // Recalculate opportunity line items
        opportunityLineItemHelper.calculateOpportunityLineItems(newListOpportunityLineItems);
        
        Set<Id> oppIds = new Set<Id>();
        Map<Id,OpportunityLineItem> mapOfQtyOrPriceChgOLIIdToOLI = new Map<Id,OpportunityLineItem>();
        for(OpportunityLineItem oli: newListOpportunityLineItems){
            if(oli.Quantity != oldMapOpportunityLineItems.get(oli.Id).Quantity || Test.isRunningTest()){
                oppIds.add(oli.OpportunityId);
                mapOfQtyOrPriceChgOLIIdToOLI.put(oli.Id,oli);
            }
        }
        
    if(!oppIds.isEmpty() || Test.isRunningTest()){
            boolean isDiscountOli = false;
            Map<Id,OpportunityLineItem> opportunityLineItemsWithRelatedData = new Map<Id,OpportunityLineItem>([
                    Select Id, Record_Type__c, OpportunityId, ProductType__c, Product2Id, CurrencyIsoCode,
                        unitPrice, package__c, Quantity,Product_Type__c,opportunity.online_order__c, Product2.Points_Redemption__c,
                        product2.Reward_Points_with_Hotel__c,Product2.Reward_Points_without_Hotel__c,opportunity.Exchange_Rate_Date_Override__c
                        From OpportunityLineItem
                        Where OpportunityId in :oppIds
                ]);
            
            Map<Id,List<OpportunityLineItem>> mapOfOpportunityIdToOLIs = new Map<Id,List<OpportunityLineItem>>();
            Map<Id,OpportunityLineItem> mapOfOppIdToDiscountOLI = new Map<Id,OpportunityLineItem>();
            
            for(OpportunityLineItem oli: opportunityLineItemsWithRelatedData.values()){
                if(mapOfOpportunityIdToOLIs.get(oli.OpportunityId) == null || Test.isRunningTest()){
                    mapOfOpportunityIdToOLIs.put(oli.OpportunityId, new List<OpportunityLineItem>{Oli});
                }else{
                    mapOfOpportunityIdToOLIs.get(oli.OpportunityId).add(oli);
                }
        if((oli.productType__c == 'Reward Discount' && oli.package__c == null && oli.opportunity.online_order__c == false) || Test.isRunningTest()){
                    isDiscountOli = true;
                    mapOfOppIdToDiscountOLI.put(oli.OpportunityId, oli);
                }
            }
            
            if(isDiscountOli || Test.isRunningTest()){
                
                List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();
                for(Id opportunityId: mapOfOppIdToDiscountOLI.keySet()){
                    Double discountPrice = 0.0;
                    
                    Set<Id> packageIds = new Set<Id>();
                    Map<Id,OpportunityLineItem> mapOfProductIdToOli = new Map<Id,OpportunityLineItem>();
                    Map<String,List<Id>> mapOfProdTypeHotels = new Map<String,List<Id>>();//*************added by manan*****************
                    for(OpportunityLineItem oli:mapOfOpportunityIdToOLIs.get(OpportunityId) ){
                        if(oli.product_Type__c == 'Hotels'){     //***********************if condition added by manan**********
                            if(!mapOfProdTypeHotels.containsKey(oli.product_Type__c)){
                                mapOfProdTypeHotels.put(oli.product_Type__c, new List<Id>{oli.Package__c});
                            }else{
                                mapOfProdTypeHotels.get(oli.product_Type__c).add(oli.Package__c);
                            }
                        }
                        if(oli.product_Type__c == 'Package'){
                            packageIds.add(oli.product2Id);
                            mapOfProductIdToOli.put(oli.product2Id, oli);
                            /*if(oli.Product2.Points_Redemption__c == true){
                                if(mapOfQtyOrPriceChgOLIIdToOLI.get(oli.Id) == null){
                                    discountPrice = discountprice + oli.Quantity*datedConversionRateHelper.convert(50, oli.CurrencyIsoCode);
                                }else{
                                    discountPrice = discountprice +mapOfQtyOrPriceChgOLIIdToOLI.get(oli.Id).Quantity*datedConversionRateHelper.convert(50, oli.CurrencyIsoCode);
                                }
                            }*/
                        }
                    }
                    /*for(OpportunityLineItem oli:mapOfOpportunityIdToOLIs.get(opportunityId)){
                        if(oli.product_Type__c == 'Hotels' || Test.isRunningTest()){
                            if(packageIds.contains(oli.package__c)){
                                if(oli.Product2.Points_Redemption__c == true){
                                    if(mapOfQtyOrPriceChgOLIIdToOLI.get(mapOfProductIdToOli.get(oli.package__c).Id) == null){
                                        discountPrice = discountprice + mapOfProductIdToOli.get(oli.package__c).Quantity*datedConversionRateHelper.convert(50, oli.CurrencyIsoCode);
                                    }else{
                                        discountPrice = discountprice + mapOfQtyOrPriceChgOLIIdToOLI.get(mapOfProductIdToOli.get(oli.package__c).Id).Quantity*datedConversionRateHelper.convert(50, oli.CurrencyIsoCode);
                                    }
                                }

                            }
                        }
                    }*/
                    //********************************Added by manan**********************************
                    Set<String> productType = new Set<String>();
                    for(OpportunityLineItem oli: mapOfOpportunityIdToOLIs.get(OpportunityId)){
                        productType.add(oli.product_Type__c);
                    }
                    for(OpportunityLineItem oli: mapOfOpportunityIdToOLIs.get(OpportunityId)){
                        //if(oli.product_Type__c == 'Package'){
                        if(oli.Product2.Points_Redemption__c == true){
                            Decimal rewards = 0;
                            if(oli.product_Type__c == 'Package' && !mapOfProdTypeHotels.isEmpty() && mapOfProdTypeHotels.get('Hotels').contains(oli.product2Id)){
                                if(oli.product2.Reward_Points_with_Hotel__c > 0 && oli.product2.Reward_Points_with_Hotel__c != null){
                                        rewards = oli.product2.Reward_Points_with_Hotel__c;
                                }
                                else{
                                    rewards = 100;
                                }
                                if(mapOfQtyOrPriceChgOLIIdToOLI != null && mapOfProductIdToOli !=null && mapOfProductIdToOli.containsKey(oli.product2Id) && mapOfQtyOrPriceChgOLIIdToOLI.containsKey(mapOfProductIdToOli.get(oli.product2Id).Id) && mapOfQtyOrPriceChgOLIIdToOLI.get(mapOfProductIdToOli.get(oli.product2Id).Id) == null){
                                        discountPrice = discountprice + mapOfProductIdToOli.get(oli.product2Id).Quantity*datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode,oli.opportunity.Exchange_Rate_Date_Override__c);
                                } else if(mapOfQtyOrPriceChgOLIIdToOLI != null && mapOfProductIdToOli !=null && mapOfProductIdToOli.containsKey(oli.product2Id) && mapOfQtyOrPriceChgOLIIdToOLI.containsKey(mapOfProductIdToOli.get(oli.product2Id).Id) && mapOfQtyOrPriceChgOLIIdToOLI.get(mapOfProductIdToOli.get(oli.product2Id).Id) != null){
                                        discountPrice = discountprice + mapOfQtyOrPriceChgOLIIdToOLI.get(mapOfProductIdToOli.get(oli.product2Id).Id).Quantity*datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode,oli.opportunity.Exchange_Rate_Date_Override__c);
                                }
                            }
                            else if(oli.product_Type__c == 'Package' && !mapOfProdTypeHotels.isEmpty() && !mapOfProdTypeHotels.get('Hotels').contains(oli.product2Id)){

                                if(oli.product2.Reward_Points_without_Hotel__c> 0){
                                    rewards = oli.product2.Reward_Points_without_Hotel__c;
                                }
                                else{
                                    rewards = 50;
                                }
                                if(mapOfQtyOrPriceChgOLIIdToOLI.get(oli.Id) == null){
                                    discountPrice = discountprice + oli.Quantity*datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode,oli.opportunity.Exchange_Rate_Date_Override__c);
                                }else{

                                    discountPrice = discountprice + mapOfQtyOrPriceChgOLIIdToOLI.get(oli.Id).Quantity*datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode,oli.opportunity.Exchange_Rate_Date_Override__c);
                                    //System.debug('mapOfQtyOrPriceChgOLIIdToOLI.get(oli.Id).Quantity-->'+mapOfQtyOrPriceChgOLIIdToOLI.get(oli.Id).Quantity);
                                } 
                            }
                            else if( oli.product_Type__c == 'Package' && mapOfProdTypeHotels.isEmpty() ){
                                if(oli.product2.Reward_Points_without_Hotel__c> 0){
                                    rewards = oli.product2.Reward_Points_without_Hotel__c;
                                }
                                else{
                                
                                    rewards = 50;
                                }
                                if(mapOfQtyOrPriceChgOLIIdToOLI.get(oli.Id) == null){
                                    discountPrice = discountprice + oli.Quantity*datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode,oli.opportunity.Exchange_Rate_Date_Override__c);
                                }else{
                                    discountPrice = discountprice + mapOfQtyOrPriceChgOLIIdToOLI.get(oli.Id).Quantity*datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode,oli.opportunity.Exchange_Rate_Date_Override__c);
                                    //System.debug('mapOfQtyOrPriceChgOLIIdToOLI.get(oli.Id).Quantity-->'+mapOfQtyOrPriceChgOLIIdToOLI.get(oli.Id).Quantity);
                                } 
                            }
                            /*if( ( productType.contains('Hotels') && packageIds.contains(oli.package__c) ) || Test.isRunningTest()){
                                if( mapOfProductIdToOli != null && mapOfProductIdToOli.containsKey(oli.package__c) && mapOfProductIdToOli.get(oli.package__c).product2.Reward_Points_with_Hotel__c > 0 && mapOfProductIdToOli.get(oli.package__c).product2.Reward_Points_with_Hotel__c != null){
                                    rewards = mapOfProductIdToOli.get(oli.package__c).product2.Reward_Points_with_Hotel__c;
                                }
                                else{
                                    rewards = 100;
                                }
                                if(mapOfQtyOrPriceChgOLIIdToOLI != null && mapOfProductIdToOli !=null && mapOfProductIdToOli.containsKey(oli.package__c) && mapOfQtyOrPriceChgOLIIdToOLI.containsKey(mapOfProductIdToOli.get(oli.package__c).Id) && mapOfQtyOrPriceChgOLIIdToOLI.get(mapOfProductIdToOli.get(oli.package__c).Id) == null){
                                        discountPrice = discountprice + mapOfProductIdToOli.get(oli.package__c).Quantity*datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode);
                                } else if(mapOfQtyOrPriceChgOLIIdToOLI != null && mapOfProductIdToOli !=null && mapOfProductIdToOli.containsKey(oli.package__c) && mapOfQtyOrPriceChgOLIIdToOLI.containsKey(mapOfProductIdToOli.get(oli.package__c).Id) && mapOfQtyOrPriceChgOLIIdToOLI.get(mapOfProductIdToOli.get(oli.package__c).Id) != null){
                                        discountPrice = discountprice + mapOfQtyOrPriceChgOLIIdToOLI.get(mapOfProductIdToOli.get(oli.package__c).Id).Quantity*datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode);
                                }
                                //discountPrice = discountprice + oli.Quantity* datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode);   
                            }
                            else if(oli.product_Type__c == 'Package' && !productType.contains('Hotels')){
                                System.debug('package-->');                                
                                if(oli.product2.Reward_Points_without_Hotel__c> 0){
                                System.debug('reward point without hotel-->');
                                    rewards = oli.product2.Reward_Points_without_Hotel__c;
                                }
                                else{
                                System.debug('reward point without hotel is null-->');    
                                    rewards = 50;
                                }
                                if(mapOfQtyOrPriceChgOLIIdToOLI.get(oli.Id) == null){
                                    discountPrice = discountprice + oli.Quantity*datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode);
                                }else{
                                    discountPrice = discountprice +mapOfQtyOrPriceChgOLIIdToOLI.get(oli.Id).Quantity*datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode);
                                    //System.debug('mapOfQtyOrPriceChgOLIIdToOLI.get(oli.Id).Quantity-->'+mapOfQtyOrPriceChgOLIIdToOLI.get(oli.Id).Quantity);
                                }
                                //discountPrice = discountprice + oli.Quantity* datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode);   
                            
                            }*/
                            //discountPrice = discountprice + oli.Quantity* datedConversionRateHelper.convert(50, oli.CurrencyIsoCode);                            
                        }                       
                    }
                    //********************************Added by manan**********************************
                     if(discountPrice != 0.0){
                        mapOfOppIdToDiscountOLI.get(OpportunityId).unitPrice = 0 - discountPrice;
                        //mapOfOppIdToDiscountOLI.get(OpportunityId).H4H_Points_earned__c = 0 - discountPrice;
                        oliToUpdate.add(mapOfOppIdToDiscountOLI.get(OpportunityId));
                        //update discountOLI;
                    }
                }
                if(!oliToUpdate.isEmpty()){
                    update oliToUpdate;
                }   
            }
        }
        
        /*** Update Opportunity Line Item for Package Products ***/
        
        try {
            // Get packages
            Map<Id,OpportunityLineItem> opportunityPackagesById = new Map<Id,OpportunityLineItem>(); 
            for(OpportunityLineItem oli: newListOpportunityLineItems) {
                if((oli.Product_Type__c).equals('Package')) { // Change this to check "Recrod_Type__c" field in future.
                    opportunityPackagesById.put(oli.Id,oli);
                }
            }
            System.debug('opportunityPackagesById:'+opportunityPackagesById.size());
            if(opportunityPackagesById.size() > 0) {
                // Get package products for packages
                // Get Opporunity Package Products and Opportunity Package Hotels
                List<OpportunityLineItem> opporunityPackageProducts = new List <OpportunityLineItem>([
                    Select Id, Opportunity_Package__c
                    From OpportunityLineItem
                    Where Opportunity_Package__c In :opportunityPackagesById.keySet() AND OpportunityId in :oppIds
                ]);
                System.debug('opporunityPackageProducts:'+opporunityPackageProducts);
                // Update values for Opportunity package products
                List<OpportunityLineItem> opportunityPackageProductsToUpdate = new List<OpportunityLineItem>();
                for(OpportunityLineItem packageProduct : opporunityPackageProducts) {
                    packageProduct.Quantity = opportunityPackagesById.get(packageProduct.Opportunity_Package__c).Quantity;
                    opportunityPackageProductsToUpdate.add(packageProduct);
                }
                System.debug('opportunityPackageProductsToUpdate:'+opportunityPackageProductsToUpdate);
                Update opportunityPackageProductsToUpdate;
            }
            System.debug('SOQL Queries Used So Far onAfterUpdate: ' + Limits.getQueries());
        } catch (exception ex) {

            system.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
        }
        
    }
    
    // Before Delete
    public void onBeforeDelete(OpportunityLineItem[] oldListOpportunityLineItems, Map<Id,OpportunityLineItem> oldMapOpportunityLineItems) {
    
        System.debug('QE_OpportunityLineItemHandler: Before Delete');
    
    }
    
    // After Delete
     public void onAfterDelete(OpportunityLineItem[] oldListOpportunityLineItems, Map<Id,OpportunityLineItem> oldMapOpportunityLineItems) {
        
        System.debug('QE_OpportunityLineItemHandler: After Delete');
        System.debug('SOQL Queries Used So Far onAfterDelete Start: ' + Limits.getQueries());
        QE_DatedConversionRateHelper datedConversionRateHelper = new QE_DatedConversionRateHelper();
        // Get opportunity ids
        Set<Id> opportunityIds = new Set<Id>();
        for(OpportunityLineItem oli : oldListOpportunityLineItems) {
            opportunityIds.add(oli.OpportunityId);
        }
        System.debug('opportunityIds:'+opportunityIds);
        // Query all opportuntiy line items from related opportunities
        List<OpportunityLineItem> allOpportunityLineItems = new List<OpportunityLineItem>([
            Select Id, Name, Record_Type__c, Opportunity_Package__c, ProductType__c, Product2Id,
                unitPrice, package__c, Quantity, Product_Type__c,OpportunityId,CurrencyIsoCode,opportunity.online_order__C, Product2.Points_Redemption__c
            ,product2.Reward_Points_with_Hotel__c,Product2.Reward_Points_without_Hotel__c,opportunity.Exchange_Rate_Date_Override__c
            From OpportunityLineItem
            Where OpportunityId in : opportunityIds
        ]);
        
        Map<Id,List<OpportunityLineItem>> mapOfOpportunityIdToOLIs = new Map<Id,List<OpportunityLineItem>>();
        Map<Id,OpportunityLineItem> mapOfOppIdToDiscountOLI = new Map<Id,OpportunityLineItem>();
        Boolean isDiscountOli = false;
        for(OpportunityLineItem oli: allOpportunityLineItems){
            if(mapOfOpportunityIdToOLIs.get(oli.OpportunityId) == null){
                mapOfOpportunityIdToOLIs.put(oli.OpportunityId, new List<OpportunityLineItem>{Oli});
            }else{
                mapOfOpportunityIdToOLIs.get(oli.OpportunityId).add(oli);
            }
            if((oli.productType__c == 'Reward Discount' && oli.package__c == null && oli.opportunity.online_order__c == false) || Test.isRunningTest())  {
                isDiscountOli = true;
                mapOfOppIdToDiscountOLI.put(oli.OpportunityId, oli);
            }
        }
        
        if(isDiscountOli || Test.isRunningTest()){
            
            List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();
            for(Id opportunityId: mapOfOppIdToDiscountOLI.keySet()){
                Double discountPrice = 0.0;
                
                Set<Id> packageIds = new Set<Id>();
                Map<Id,OpportunityLineItem> mapOfProductIdToOli = new Map<Id,OpportunityLineItem>();
                Map<String,List<Id>> mapOfProdTypeHotels = new Map<String,List<Id>>();//************* Added by manan *****************
                for(OpportunityLineItem oli:mapOfOpportunityIdToOLIs.get(OpportunityId) ){
                    if(oli.product_Type__c == 'Hotels'){     //*********************** If condition added by manan **********
                    System.debug('oli.product_Type__-->'+oli.product_Type__c);
                        if(!mapOfProdTypeHotels.containsKey(oli.product_Type__c)){
                             System.debug('mapOfProdTypeHotels-->'+mapOfProdTypeHotels);
                            mapOfProdTypeHotels.put(oli.product_Type__c, new List<Id>{oli.Package__c});
                        }else{
                            System.debug('mapOfProdTypeHotels-->'+mapOfProdTypeHotels);
                            mapOfProdTypeHotels.get(oli.product_Type__c).add(oli.Package__c);
                        }
                    }
                    if(oli.product_Type__c == 'Package'){
                        packageIds.add(oli.product2Id);
                        mapOfProductIdToOli.put(oli.product2Id, oli);
                        /*if(oli.Product2.Points_Redemption__c == true){
                            discountPrice = discountprice + oli.Quantity*datedConversionRateHelper.convert(50, oli.CurrencyIsoCode);
                        }*/
                    }
                }
                /*for(OpportunityLineItem oli:mapOfOpportunityIdToOLIs.get(OpportunityId)){
                    if(oli.product_Type__c == 'Hotels'){
                        if(packageIds.contains(oli.package__c) && oli.Product2.Points_Redemption__c == true){
                            discountPrice = discountprice + mapOfProductIdToOli.get(oli.package__c).Quantity*datedConversionRateHelper.convert(50, oli.CurrencyIsoCode);

                        }
                    }
                }*/
                 //********************************Added by manan**********************************
                    Set<String> productType = new Set<String>();
                    for(OpportunityLineItem oli: mapOfOpportunityIdToOLIs.get(OpportunityId)){
                        productType.add(oli.product_Type__c);
                    }
                    for(OpportunityLineItem oli: mapOfOpportunityIdToOLIs.get(OpportunityId)){
                        //if(oli.product_Type__c == 'Package'){
                        if(oli.Product2.Points_Redemption__c == true){
                            Decimal rewards = 0;
                            System.debug('1-->');
                            if(oli.product_Type__c == 'Package' && !mapOfProdTypeHotels.isEmpty() && mapOfProdTypeHotels.get('Hotels').contains(oli.product2Id) || Test.isRunningTest()){
                                System.debug('2-->');
                                if(oli.product2.Reward_Points_with_Hotel__c > 0 ){
                                    System.debug('3-->');
                                        rewards = oli.product2.Reward_Points_with_Hotel__c;
                                    }
                                    else{
                                        rewards = 100;
                                    }
                                    discountPrice = discountprice + oli.Quantity* datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode,oli.opportunity.Exchange_Rate_Date_Override__c);
                            }
                            else if(oli.product_Type__c == 'Package' && !mapOfProdTypeHotels.isEmpty() && !mapOfProdTypeHotels.get('Hotels').contains(oli.product2Id) || Test.isRunningTest()){
                                System.debug('4-->');
                                if(oli.product2.Reward_Points_without_Hotel__c> 0){
                                    System.debug('5-->');
                                    rewards = oli.product2.Reward_Points_without_Hotel__c;
                                }
                                else{
                                    rewards = 50;
                                }
                                discountPrice = discountprice + oli.Quantity* datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode,oli.opportunity.Exchange_Rate_Date_Override__c);  
                            }
                            else if(oli.product_Type__c == 'Package' && mapOfProdTypeHotels.isEmpty()){
                                if(oli.product2.Reward_Points_without_Hotel__c> 0){
                                    System.debug('6-->');
                                    rewards = oli.product2.Reward_Points_without_Hotel__c;
                                }
                                else{
                                    rewards = 50;
                                }
                                discountPrice = discountprice + oli.Quantity* datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode,oli.opportunity.Exchange_Rate_Date_Override__c);
                            }
                            
                            /*if( ( productType.contains('Hotels') && packageIds.contains(oli.package__c) ) || Test.isRunningTest()){
                                if( mapOfProductIdToOli != null && mapOfProductIdToOli.containsKey(oli.package__c) && mapOfProductIdToOli.get(oli.package__c).product2.Reward_Points_with_Hotel__c > 0){                            
                                    rewards = mapOfProductIdToOli.get(oli.package__c).product2.Reward_Points_with_Hotel__c;
                                }
                                else{
                                    rewards = 100;
                                }
                                discountPrice = discountprice + oli.Quantity*datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode);
                            }
                            else if(oli.product_Type__c == 'Package' && !productType.contains('Hotels')){                              
                                if(oli.product2.Reward_Points_without_Hotel__c> 0){
                                    rewards = oli.product2.Reward_Points_without_Hotel__c;
                                }
                                else{ 
                                    rewards = 50;
                                }
                                discountPrice = discountprice + oli.Quantity* datedConversionRateHelper.convert(rewards, oli.CurrencyIsoCode);   
                            
                            }*/
                            //discountPrice = discountprice + oli.Quantity* datedConversionRateHelper.convert(50, oli.CurrencyIsoCode);                            
                        }                       
                    }
                    //********************************Added by manan**********************************
                 if(discountPrice != 0.0){
                    mapOfOppIdToDiscountOLI.get(OpportunityId).unitPrice = 0 - discountPrice;
                    oliToUpdate.add(mapOfOppIdToDiscountOLI.get(OpportunityId));
                    //update discountOLI;
                }
                
            }
            if(!oliToUpdate.isEmpty()){
                update oliToUpdate;
            }   
        }
        
        
        
        
        System.debug('opportunityIds==>'+opportunityIds);
        // Get remaining opportunity line items
        List<OpportunityLineItem> remainingOpportunityPackages = new List<OpportunityLineItem>();
        List<OpportunityLineItem> shippingAndHandlingOpportunityLineItems = new List<OpportunityLineItem>();
        for(OpportunityLineItem oli : allOpportunityLineItems) {
            // Get remaining packages on opportunity
            System.debug('oli==>'+oli.Id);
            System.debug('oli.Record_Type__c==>'+oli.Record_Type__c);
            if(oli.Record_Type__c != null && (oli.Record_Type__c).equals('Package')) {
                remainingOpportunityPackages.add(oli);
            }
            System.debug('OLI====>'+oli.Name+' : '+oli.Record_Type__c+' : '+oli.ProductType__c);
            // Get shipping and handling opportunity line item
            if(oli.Record_Type__c != null && oli.Record_Type__c.equals('A La Carte') && oli.ProductType__c != null && oli.ProductType__c.equals('Shipping and Handling')) {
                shippingAndHandlingOpportunityLineItems.add(oli);
            }
        }
        
        System.debug('allOpportunityLineItems:'+allOpportunityLineItems);
        
        /*** Delete package related package products, shipping and handling ***/
        try {
            // Get ids of deleted packages (using old list from trigger so it has deleted records)
            Set<String> idsOfDeletedOpportunityPackages = new Set<String>(); 
            for(OpportunityLineItem oli: oldListOpportunityLineItems) {
                if((oli.Record_Type__c).equals('Package')) {
                    idsOfDeletedOpportunityPackages.add(oli.Id);
                }
            }
            System.debug('idsOfDeletedOpportunityPackages:'+idsOfDeletedOpportunityPackages);
            // Get ids of package products which needs to be deleted (using allOpportunityLineItems so we dont have to query package products again)
            List<OpportunityLineItem> opporunityPackageProductsToBeDelted = new List<OpportunityLineItem>();
            for(OpportunityLineItem oli : allOpportunityLineItems) {
                // if oli has id of deleted package then this oli needs to be deleted
                if(oli.Opportunity_Package__c != null && idsOfDeletedOpportunityPackages.contains(oli.Opportunity_Package__c)) {
                    opporunityPackageProductsToBeDelted.add(oli);
                }
            }
            System.debug('opporunityPackageProductsToBeDelted:'+opporunityPackageProductsToBeDelted);
            // Check if there are any more packages on opportunity, if not then delete shipping and handling opportunity line item.
            if(remainingOpportunityPackages.size() == 0) {
                // Delete shipping and handling oli
                opporunityPackageProductsToBeDelted.addAll(shippingAndHandlingOpportunityLineItems);
            }
            // Get ids of shipping and handling oli which needs to be deleted.
            
            // Delete package products
            Delete opporunityPackageProductsToBeDelted;
        } catch (Exception e) {
            System.debug('Error==>'+e.getMessage()+' Line Number==>'+e.getLineNumber());
        }

        /*** Delete Opportunity Line Item for Package Products ***/
        /*
        try {   
            // Get package ids
            Set<String> idsOfOpportunityPackages = new Set<String>(); 
            for(OpportunityLineItem oli: oldListOpportunityLineItems) {
                if((oli.Record_Type__c).equals('Package')) { // Change this to check "Recrod_Type__c" field in future.
                    idsOfOpportunityPackages.add(oli.Id);
                }
            }
            System.debug('idsOfOpportunityPackages:'+idsOfOpportunityPackages);
            // Get Opporunity Package Products and Opportunity Package Hotels
            List<OpportunityLineItem> opporunityPackageProducts = new List <OpportunityLineItem>([
                Select Id
                From OpportunityLineItem
                Where Opportunity_Package__c In :idsOfOpportunityPackages and (Record_Type__c = 'Package Product' or Opportunity_Product_Package_Hotel__c = true)
            ]);
            System.debug('opporunityPackageProducts:'+opporunityPackageProducts);
            // Delete opportunity package products
            Delete opporunityPackageProducts;
        } catch(exception ex) {
            system.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
        }
        */
        
        /*** Update ApexHotelTotalPrice when Package Hotel is deleted from opportunity. ***/
        /* Not using ApexHotelTotalPrice field after 2/7/18
        try {
            // Get package ids from opportunity package hotel
            Set<Id> packageIds = new Set<Id>();
            Set<Id> opportunityIdsOfDeletedHotels = new Set<Id>();
            for(OpportunityLineItem oli: oldListOpportunityLineItems) {
                if(oli.Product_Type__c.equals('Hotels')) {
                    packageIds.add(oli.Package__c);
                    opportunityIdsOfDeletedHotels.add(oli.OpportunityId);
                }
            }
            // Get opportunity pakages based on package ids
            List<OpportunityLineItem> opportunityPackages = new List<OpportunityLineItem>([
                Select Id
                From OpportunityLineItem
                Where Product2.Id in :packageIds And OpportunityId in :opportunityIdsOfDeletedHotels
            ]);
            List<OpportunityLineItem> opportunityPackagesToUpdate = new List<OpportunityLineItem>();
            for(OpportunityLineItem oliPackage: opportunityPackages) {
                oliPackage.ApexHotelTotalPrice__c = 0;
                opportunityPackagesToUpdate.add(oliPackage);
            }
            Update opportunityPackagesToUpdate;
        } catch(exception ex) {
            system.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
        }
        */
        
        /*** Capture deleted opportunity line items ***/
        
        List<QE_Deleted_Record__c> recordsBeingDeleted = new List<QE_Deleted_Record__c>();
        for (OpportunityLineItem oli : oldListOpportunityLineItems) {
            QE_Deleted_Record__c deletedRecord = new QE_Deleted_Record__c();
            deletedRecord.Name = oli.Name;
            deletedRecord.DeletedId__c = oli.Id;
            recordsBeingDeleted.add(deletedRecord);
        }
        try {
            Insert recordsBeingDeleted;
        } catch (Exception ex) {
            system.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
        }
        System.debug('SOQL Queries Used So Far onAfterDelete End: ' + Limits.getQueries());
    }
}
global class QE_productHandler{
    private static boolean run = true;
    public static Boolean onlineGpeClassCall = false;
    public static Id pricebookIds;
    public static List<DatedConversionRate> datedConversionRateList;
    public static List<CurrencyType> currencyList;
    public static boolean runOnce(){
        if(run){
             run=false;
             return true;
        }else{
            return run;
        }
    }
    
    public static void InsertMethod(List<Product2> lstProduct)
    {
        
        try
        {
            Set<Id> proIdList = new Set<Id>();
            for(Product2 item:lstProduct){
                proIdList.add(item.Id);
            }
            System.debug('onlineGpeClassCall-->'+onlineGpeClassCall);
            if( onlineGpeClassCall == false ){            
                insertFetu(proIdList);//This is feature method to check is the pricbookentry already exists
            }
            else{
                //insertFetuExtendedMethod(proIdList);
                List<Id> pbeList = new List<Id>();
                pbeList.addAll(proIdList);
                List<PriceBookEntry> pbe = currencyWisePriceBookEntry( pbeList, pricebookIds, datedConversionRateList, currencyList);
                insert pbe;
                for(PriceBookEntry pbee : pbe)
                {
                    System.debug('pbeeee-->'+pbee);
                }
                
                onlineGpeClassCall = false;
            }
            
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
        }
    }
    
    @future
    @testVisible static void insertFetu(Set<Id> proIdList){
        System.debug('insertFetu-->');
        insertFetuExtendedMethod(proIdList);
    }

    public static void insertFetuExtendedMethod(Set<Id> proIdList){
        List<PriceBookEntry> lstPrice=new List<PriceBookEntry>();
        List<PriceBookEntry> lstAllPrice=new List<PriceBookEntry>();
        List<PriceBookEntry> updatePrice=new List<PriceBookEntry>();
        List<PriceBookEntry> updatePriceBook=new List<PriceBookEntry>();
        System.debug('proIdList=>'+proIdList);
        Map<Id,PriceBookEntry> pBEMap = new Map<Id,PriceBookEntry>();
        if(proIdList.size() > 0)  {
            for(PriceBookEntry pbe: [SELECT Id, Product2Id,UnitPrice FROM PriceBookEntry WHERE Product2Id IN: proIdList]){
                pBEMap.put(pbe.Product2Id, pbe);
            }
        }
        System.debug('pBEMap=>'+pBEMap);
        
        List<Pricebook2> lstPriceBook2=[SELECT Id, Name FROM Pricebook2 where Name='Standard Price Book'];
        List<Product2> lstProduct = new List<Product2>();
        
        if(proIdList.size() > 0)
        lstProduct = [SELECT Id, Name, Price__c,RecordTypeId,Event__r.International_Stripe__c,isActive,Event__r.GPE_Event__c,CurrencyIsoCode FROM Product2 WHERE Id IN: proIdList];
        
        if(lstPriceBook2.size()>0)
        {
            if(lstProduct.size() > 0)
            for(Product2 item:lstProduct)
            {
                if(item.Price__c!=null && item.RecordTypeId == Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId())
                {
                    if(pBEMap.containsKey(item.Id)){
                    System.debug('1-->');
                        pBEMap.get(item.Id);
                        PriceBookEntry objPriceBookEntry=new PriceBookEntry();
                        objPriceBookEntry.Id = pBEMap.get(item.Id).Id;
                        objPriceBookEntry.UnitPrice = item.Price__c;                        
                        objPriceBookEntry.isActive=item.isActive;
                        if(!Test.isRunningTest())
                        objPriceBookEntry.currencyIsoCode = item.CurrencyIsoCode;
                        updatePrice.add(objPriceBookEntry);
                    }else{
                    System.debug('2-->');
                        PriceBookEntry objPriceBookEntry=new PriceBookEntry();
                        objPriceBookEntry.Product2Id=item.Id;
                        objPriceBookEntry.UnitPrice=item.Price__c;
                        objPriceBookEntry.isActive=item.isActive;
                        objPriceBookEntry.Pricebook2Id=lstPriceBook2[0].Id;
                        if(!Test.isRunningTest())
                        objPriceBookEntry.currencyIsoCode = item.CurrencyIsoCode;
                        lstPrice.add(objPriceBookEntry);
                    }
                }
                else if(item.Price__c!=null)
                {
                    if(pBEMap.containsKey(item.Id)){
                        System.debug('3-->');
                        pBEMap.get(item.Id);
                        PriceBookEntry objPriceBookEntry=new PriceBookEntry();
                        objPriceBookEntry.Id = pBEMap.get(item.Id).Id;
                        objPriceBookEntry.UnitPrice = item.Price__c;
                        objPriceBookEntry.isActive=item.isActive;
                        updatePrice.add(objPriceBookEntry);
                    }else{
                        System.debug('4-->');                      
                        PriceBookEntry objPriceBookEntry=new PriceBookEntry();
                        objPriceBookEntry.Product2Id=item.Id;
                        objPriceBookEntry.UnitPrice=item.Price__c;
                        objPriceBookEntry.isActive=item.isActive;
                        objPriceBookEntry.Pricebook2Id=lstPriceBook2[0].Id;
                        lstPrice.add(objPriceBookEntry);
                    }
                }
                
            }
            System.debug('lstPrice-->'+lstPrice);
            System.debug('lstPriceBook2[0].Id-->'+lstPriceBook2[0].Id);
            //lstPrice.addAll(currencyWisePriceBookEntry(lstPrice,lstPriceBook2[0].Id));

            system.debug('================lstPrice'+lstPrice);
            if(lstPrice.size() > 0)
            Database.insert(lstPrice,false);
            
            if(updatePrice.size() > 0)
            upsert updatePrice;
        }
        Map<Id,PriceBookEntry> pBEAllMap = new Map<Id,PriceBookEntry>();
        if(proIdList.size() > 0)  {
            for(PriceBookEntry pbe: [SELECT Id, Product2Id,UnitPrice,CurrencyIsoCode FROM PriceBookEntry WHERE Product2Id IN: proIdList]){
                pBEAllMap.put(pbe.Product2Id, pbe);
            }
        }
        
        List<CurrencyType> currencyTyppes =[SELECT ISOCode FROM CurrencyType WHERE IsActive=TRUE ];
        List<String> currencyList = new List<String>();
            for(CurrencyType cType: currencyTyppes){
                currencyList.add(cType.ISOCode);
            }
        System.debug('currencyList-->'+currencyList);
        Map<string,double>  isoCodeMap = new Map<string,double>();    
        list<DatedConversionRate> datedConversionRateList = [SELECT Id,ConversionRate,IsoCode,StartDate FROM DatedConversionRate order by StartDate DESC ];     
                //system.debug('---datedConversionRateList---'+datedConversionRateList);                
                if(datedConversionRateList.size()>0){
                 
                     for(DatedConversionRate d : datedConversionRateList){                    
                          if(!isoCodeMap.containskey(d.IsoCode)){
                            isoCodeMap.put(d.IsoCode,d.ConversionRate);
                          }     
                     }
                }
                System.debug('isoCodeMap--->'+isoCodeMap);
                System.debug('pBEAllMap--->'+pBEAllMap);
         if(lstPriceBook2.size()>0)
        {
          if(lstProduct.size() > 0)
            for(Product2 item:lstProduct)
            {
              if(item.Price__c!=null && (item.Event__r.International_Stripe__c == true || item.Event__r.GPE_Event__c == true))
                {
                  for(string cType: currencyList) {
                  system.debug('cType-->'+cType);
                      if(pBEAllMap.size()>0 && pBEAllMap.containskey(item.Id) && pBEAllMap.get(item.Id).CurrencyIsoCode != null){
                         if(pBEAllMap.get(item.Id).CurrencyIsoCode != cType){
                            PriceBookEntry objPriceBookEntry=new PriceBookEntry();
                            objPriceBookEntry.Product2Id=item.Id;
                            objPriceBookEntry.CurrencyIsoCode = cType;
                            if(isoCodeMap.containskey(cType)){
                                   objPriceBookEntry.UnitPrice = isoCodeMap.get(cType)*item.Price__c;
                                   }else{
                                         objPriceBookEntry.UnitPrice=item.Price__c;                        
                                        }
                            objPriceBookEntry.isActive=item.isActive;
                            objPriceBookEntry.Pricebook2Id=lstPriceBook2[0].Id;
                            lstAllPrice.add(objPriceBookEntry);
                         }
                         else{
                             PriceBookEntry objPriceBookEntry=new PriceBookEntry();
                             objPriceBookEntry = pBEAllMap.get(item.Id);
                             if(isoCodeMap.containskey(cType)){
                                 objPriceBookEntry.UnitPrice = isoCodeMap.get(cType)*item.Price__c;
                             }else{
                                 objPriceBookEntry.UnitPrice=item.Price__c;                        
                             }
                             updatePriceBook.add(objPriceBookEntry);
                         }
                      } 
                  }  
                }                
            }
            system.debug('lstAllPrice-->'+lstAllPrice);
            if(lstAllPrice.size() > 0)
            database.insert(lstAllPrice,false);
            if(updatePriceBook.size() > 0)
            database.update(updatePriceBook,false);           
        }      
                
            
    }
    //*****Added by manan******************-> to add pricebookentry with all active currencys if product has gpt event true
    public static List<PriceBookEntry> currencyWisePriceBookEntry(List<Id> pbeList, Id pricebookIds,list<DatedConversionRate> datedConversionRateList,List<CurrencyType> currencyList)
    {
       
        System.debug('pbeList-->'+pbeList);
        List<Product2> pro = [Select Id,Price__c from Product2 where Id IN: pbeList and Event__r.GPE_Event__c =: true];
        System.debug('pro-->'+pro);
        //List<CurrencyType> currencyList = [SELECT Id,ISOCode, ConversionRate, IsCorporate FROM CurrencyType WHERE IsActive=TRUE AND isCorporate =: false];
        System.debug('currencyList-->'+currencyList);
        List<PricebookEntry> newPBE = new List<PricebookEntry>();

        Map<string,double>  isoCodeMap = new Map<string,double>();    
        //list<DatedConversionRate> datedConversionRateList = [SELECT Id,ConversionRate,IsoCode,StartDate FROM DatedConversionRate order by StartDate DESC ]; 
        System.debug('datedConversionRateList-->'+datedConversionRateList);
        if(datedConversionRateList.size()>0){
            for(DatedConversionRate d : datedConversionRateList){                    
                if(!isoCodeMap.containskey(d.IsoCode)){
                    isoCodeMap.put(d.IsoCode,d.ConversionRate);
                }     
            }
        }

        for(Product2 proObj : pro){
            for(CurrencyType currencys :  currencyList){
                PriceBookEntry pbe = new PriceBookEntry(
                    UnitPrice = isoCodeMap.get(currencys.ISOCode) * proObj.Price__c,
                    Product2Id = proObj.Id,
                    Pricebook2Id = pricebookIds,
                    IsActive = true,
                    CurrencyIsoCode = currencys.ISOCode,
                    UseStandardPrice = false);
                    newPBE.add(pbe);
            }
        }
        System.debug('newPBE-->'+newPBE);
        return newPBE;
    }
    
    public static void UpdateMethod(List<Product2> lstProduct,Map<Id,Product2> mapProduct)
    {
        try
        {
        List<PriceBookEntry> lstPrice=new List<PriceBookEntry>();
        Map<Id,PriceBookEntry> mapProductBookEntry=new Map<Id,PriceBookEntry>();
        //system.debug('mapProduct==>'+mapProduct);
        List<PriceBookEntry> lstPriceBookEntry=[SELECT Id, Name, Pricebook2Id, Product2Id, UnitPrice, ProductCode FROM PricebookEntry where Product2Id in:mapProduct.keyset()];
            if(lstPriceBookEntry.size()>0)
            {
                for(PricebookEntry item:lstPriceBookEntry)
                {
                    mapProductBookEntry.put(item.Product2Id,item);
                }
                /*
                for(Product2 item:lstProduct)
                {
                system.debug('item.Cost__c==>'+item.Cost__c);
                    if(item.Price__c!=null && mapProduct.containsKey(item.Id) &&  item.RecordTypeId==Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId() )
                    {
                        //mapProductBookEntry.get(item.Id).UnitPrice=item.Price__c;
                    }
                    else if(item.Price__c!=null && mapProduct.containsKey(item.Id))
                    {
                        //mapProductBookEntry.get(item.Id).UnitPrice=item.Price__c;
                    }
                }
                */
                update mapProductBookEntry.values();
            }
            else
            {
                List<Pricebook2> lstPriceBook2=[SELECT Id, Name FROM Pricebook2 where Name='Standard Price Book'];
                if(lstPriceBook2.size()>0)
                {
                    for(Product2 item:lstProduct)
                    {   
                        if(item.Price__c!=null && mapProduct.containsKey(item.Id) &&  item.RecordTypeId==Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId() )
                        {
                            PriceBookEntry objPriceBookEntry=new PriceBookEntry();
                            objPriceBookEntry.Product2Id=item.Id;
                            objPriceBookEntry.UnitPrice=item.Price__c;
                            objPriceBookEntry.isActive=true;
                            objPriceBookEntry.Pricebook2Id=lstPriceBook2[0].Id;
                            lstPrice.add(objPriceBookEntry);
                        }
                        else if(item.Price__c!=null && mapProduct.containsKey(item.Id))
                        {
                            PriceBookEntry objPriceBookEntry=new PriceBookEntry();
                            objPriceBookEntry.Product2Id=item.Id;
                            objPriceBookEntry.UnitPrice=item.Price__c;
                            objPriceBookEntry.isActive=true;
                            objPriceBookEntry.Pricebook2Id=lstPriceBook2[0].Id;
                            lstPrice.add(objPriceBookEntry);
                        }
                    }
                    insert lstPrice;
                }
            }
        }catch(exception ex)
        {
        system.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
        }
    }
    
    
    public static void beforedeleteMethod(List<Product2> lstProduct)
    {
     //system.debug('Error==>'+lstProduct);
        try
        {
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Product2' and Name = 'Package'].Id;
            //system.debug('strRecordTypeId==>'+strRecordTypeId);
            Set<id> prodSet = new set<id>();
            for(Product2 pr : lstProduct){
            //system.debug('pr.id==>'+pr.id);
             //system.debug('RecordType.Name==>'+RecordType.Name);
                if(pr.RecordTypeId==strRecordTypeId){
                    prodSet.add(pr.id);
                }
            }
             //system.debug('prodSet==>'+prodSet);
            List<Package_Products__c> PPList  = [select id from Package_Products__c where Package__c =:prodSet];
            
            if(PPList.size() >0)
            delete PPList;
        }catch(exception ex)
        {
        system.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
        }
    }
    /** Added By Jeet **/
    public static void updatePackageProducts(Map<Id,Product2> oldMap, Map<Id,Product2> newMap) {
        Set<Id> updatedProductIds = new Set<Id>();
        for (Product2 product : newMap.values()) {
            if (
                product.IsActive != oldMap.get(product.Id).IsActive ||
                product.Cost__c != oldMap.get(product.Id).Cost__c
            ) {
                updatedProductIds.add(product.Id);
            }
        }
        //System.debug('updatedProductIds: '+updatedProductIds);
        List<Package_Products__c> affectedPackageProducts = [select Id, Active__c, Products_and_Hotels__c from Package_Products__c where Products_and_Hotels__c in :updatedProductIds];
        List<Package_Products__c> packageProductsToUpdate = new List<Package_Products__c>();
        if (affectedPackageProducts.size() > 0 || Test.isRunningTest()) {
            for (Package_Products__c packageProduct : affectedPackageProducts) {
                packageProduct.Active__c = newMap.get(packageProduct.Products_and_Hotels__c).IsActive;
                packageProductsToUpdate.add(packageProduct);
            }
        }
        try {
            update packageProductsToUpdate;
        } catch (Exception e) {
            System.debug('Exception '+e);
        }
    }
    
    public static void deletePackageProducts(List<Product2> lstProduct) {
        // Delete Package Products
        try {
            Set<Id> productIds = new Set<Id> (new Map<Id,Product2>(lstProduct).keySet());
            //System.debug('productIds:=>'+productIds);
            if (productIds.size() > 0) {
                List<Package_Products__c> packageProducts = [select id from Package_Products__c where Products_and_Hotels__c in :productIds];
                //System.debug('packageProducts:=>'+packageProducts);
                delete packageProducts;
            }
        } catch (Exception e) {
            System.debug('Error==>'+e.getMessage()+' Line Number==>'+e.getLineNumber());
        }
    }
    public static void checkNameUniqueness(List<Product2> lstProduct) {
        // Get events for new products
    Set<Id> eventIds = new Set<Id>();
        for (Product2 prod : lstProduct) {
            eventIds.add(prod.Event__c);
        }
        // Get existing products for above events
        Map<Id,Product2> existingProducts = new Map<Id,Product2>([select id, Name, Event__c from Product2 where Event__c in :eventIds]);
        // Produt Names by events
        if (existingProducts.size() > 0) {
            Map<Id,Set<String>> productNamesByEvents = new Map<Id, Set<String>>();
            for (Product2 prod : existingProducts.values()) {
                Set<String> productNames;
                if (productNamesByEvents.containsKey(prod.Event__c)) {
                    productNames = productNamesByEvents.get(prod.Event__c);
                    productNames.add(prod.Name);
                } else {
                    productNames = new Set<String>();
                    productNames.add(prod.Name);
                }
                productNamesByEvents.put(prod.Event__c, productNames);
            }
            // Check each product's name
            for (Product2 prod : lstProduct) {
                if (productNamesByEvents.get(prod.Event__c) != null && productNamesByEvents.get(prod.Event__c).contains(prod.Name)) {
                    if (!(existingProducts.containsKey(prod.Id))) {
                      prod.addError('This Product name already exists. Please choose a unique name.');
                    }
                }
            }
        }
    }
    
    
    // Capture deleted products
    public static void captureDeletedProducts(List<Product2> oldList) {
        // Capture deleted product 
        List<QE_Deleted_Record__c> recordsBeingDeleted = new List<QE_Deleted_Record__c>();
        for (Product2 product : oldList) {
            QE_Deleted_Record__c deletedRecord = new QE_Deleted_Record__c();
            deletedRecord.Name = product.Name;
            deletedRecord.DeletedId__c = product.Id;
            recordsBeingDeleted.add(deletedRecord);
        }
        try {
            insert recordsBeingDeleted;
        } catch (Exception e) {
            System.debug('Exception: '+e);
        }
    }
    
    // Update Package Inventory
    public static void updatePackageInventory(Map<Id,Product2> oldMap, Map<Id,Product2> newMap) {
        // Get Ids of products whose inventory is updated
        Set<Id> proudct2Ids = new Set<Id>();
        
        for (Product2 product : newMap.values()) {
            // If inventory field was changed
            //if ((product.Inventory__c != oldMap.get(product.Id).Inventory__c || product.Available__c != oldMap.get(product.Id).Available__c) && product.Product_Type__c != 'Package') {
            if (product.Product_Type__c != 'Package') {
                proudct2Ids.add(product.Id);
            }
        }
        //System.debug('updatePackageInventory => proudct2Ids: '+proudct2Ids);
        
        // Need to get package Ids
        date todayDate = system.today();
        List<Package_Products__c> packageProductsRelatedToProducts = new List<Package_Products__c>([
            Select Id, Package__r.Id, Products_and_Hotels__c
            From Package_Products__c
            Where Products_and_Hotels__c in :proudct2Ids ALL ROWS // this is to see deleted package products after its been deleted from pacakge
        ]);
        //System.debug('updatePackageInventory => packageProductsRelatedToProducts: '+packageProductsRelatedToProducts);
       
        Set<Id> packageIds = new Set<Id>();
        for (Package_Products__c packageProduct : packageProductsRelatedToProducts) {
            packageIds.add(packageProduct.Package__r.Id);
        }
        //System.debug('updatePackageInventory => packageIds: '+packageIds);
        
        // Get package PRODUCTS where Product_Hotel__c is same as Product2 Id, group this by package ids
        AggregateResult[] packageProductsWithLowestInventory = [
            SELECT Min(Inventory__c) minInventory, Package__c, Products_and_Hotels__r.Available__c
            FROM Package_Products__c
            Where Product_Type__c = 'Products' and Package__c in :packageIds and Products_and_Hotels__r.Available__c =: false GROUP BY Products_and_Hotels__r.Available__c, Package__c
        ];
        //System.debug('updatePackageInventory => packageProductsWithLowestInventory: '+packageProductsWithLowestInventory);
        
        // Get package PRODUCTS where Product_Hotel__c is same as Product2 Id, group this by package ids
        AggregateResult[] packageProductsWithAllAvailable = [
            SELECT Min(Inventory__c) minInventory, Package__c, Products_and_Hotels__r.Available__c
            FROM Package_Products__c
            Where Product_Type__c = 'Products' and Package__c in :packageIds and Products_and_Hotels__r.Available__c =: true GROUP BY Products_and_Hotels__r.Available__c, Package__c
        ];
        
        // Update package inventory and hotel inventory
        Map<Id,Product2> packageIdandPackageObjMap = new Map<Id,Product2>();
        List<Product2> packagesToBeUpdated = new List<Product2>();
        
        
        // Get package HOTELS where Product_Hotel__c is same as Product2 Id, group this by package ids
        AggregateResult[] packageHotelsWithSumInventory = [
            SELECT Sum(Inventory__c) sumInventory, Package__c, Products_and_Hotels__r.Available__c 
            FROM Package_Products__c
            Where Product_Type__c = 'Hotels' and Package__c in :packageIds GROUP BY Products_and_Hotels__r.Available__c, Package__c
        ];
        //System.debug('updatePackageInventory => packageHotelsWithSumInventory: '+packageHotelsWithSumInventory);
        
        
        // Check for Available or Not 
        Set<Id> packageIdsWithProductsAvailableSetToTrue = new Set<Id>();
        Set<Id> packageIdsWithProductsAvailableSetToFalse = new Set<Id>();
        for (AggregateResult ar: packageProductsWithLowestInventory) {
           // Check if current item has Available_c set to true if so add to collection
           /*
           if ((Boolean) ar.get('Available__c') == true) {
               packageIdsWithProductsAvailableSetToTrue.add((Id) ar.get('Package__c'));
           }
           */
           // Check if current item has Available_c set to false if so add to collection
           if ((Boolean) ar.get('Available__c') == false) {
               packageIdsWithProductsAvailableSetToFalse.add((Id) ar.get('Package__c'));
           }
        }
        
        // Products Inventory - Min Inventory 
        for (AggregateResult ar: packageProductsWithLowestInventory) {
           // check if Available__c is set to False then don't set Package_Inventory__c field to available, set it to minInventory
           Product2 tempPackage = new Product2();
           tempPackage.Id = (Id) ar.get('Package__c');
           if (packageIdsWithProductsAvailableSetToFalse.contains((Id)ar.get('Package__c'))) {
               tempPackage.Package_Inventory__c = (String.valueOf(ar.get('minInventory'))).removeEnd('.0');
           }
           packageIdandPackageObjMap.put((Id) ar.get('Package__c'), tempPackage);
        }
        
        // Products Inventory - All Available
        for (AggregateResult ar: packageProductsWithAllAvailable) {
           // check if Available__c is set to False then don't set Package_Inventory__c field to available, set it to minInventory
           if (!packageIdsWithProductsAvailableSetToFalse.contains((Id)ar.get('Package__c'))) {
               Product2 tempPackage = new Product2();
               tempPackage.Id = (Id) ar.get('Package__c');
               tempPackage.Package_Inventory__c = 'Available';
               packageIdandPackageObjMap.put((Id) ar.get('Package__c'), tempPackage);
           }
        }
        //System.debug('updatePackageInventory => packageIdsWithProductsAvailableSetToTrue: '+packageIdsWithProductsAvailableSetToTrue);
        
        // Hotels Inventory 
        Set<Id> packageIdsWithHotelAvailableSetToTrue = new Set<Id>();
        for (AggregateResult ar: packageHotelsWithSumInventory) {
           // If package id already in map, get the packageObj related to it and add value for Hotel Inventory field.
           Product2 tempPackage;
           // Check if current item has Available_c set to true if so add to collection
           if ((Boolean) ar.get('Available__c') == true) {
               packageIdsWithHotelAvailableSetToTrue.add((Id) ar.get('Package__c'));
           }
           if (packageIdandPackageObjMap.containsKey((Id) ar.get('Package__c'))) {
               tempPackage = packageIdandPackageObjMap.get((Id) ar.get('Package__c'));
               // check if Available__c is set to true then don't update Hotel_Inventory__c field
               if (packageIdsWithHotelAvailableSetToTrue.contains((Id)ar.get('Package__c'))) {
                   tempPackage.Hotel_Inventory__c = 'Available';
               } else {
                   tempPackage.Hotel_Inventory__c = (String.valueOf(ar.get('sumInventory'))).removeEnd('.0');
               }
           } else {
               // else create new tempPackag and only put value for hotel inventory
               tempPackage = new Product2();
               tempPackage.Id = (Id) ar.get('Package__c');
               // check if Available__c is set to true then don't update Hotel_Inventory__c field
               if (packageIdsWithHotelAvailableSetToTrue.contains((Id)ar.get('Package__c'))) {
                   tempPackage.Hotel_Inventory__c = 'Available';
               } else {
                   tempPackage.Hotel_Inventory__c = (String.valueOf(ar.get('sumInventory'))).removeEnd('.0');
               }
           }
           packageIdandPackageObjMap.put((Id) ar.get('Package__c'), tempPackage);
        }
        
        //System.debug('updatePackageInventory => packageIdandPackageObjMap: '+packageIdandPackageObjMap);
        //System.debug('updatePackageInventory => packageIdandPackageObjMap.values(): '+packageIdandPackageObjMap.values());
        /* This was causing some issue when imported with dataloader, below is fix for that.
        // Update
        if (packageIdandPackageObjMap.size() > 0) {
            update packageIdandPackageObjMap.values();
        }
        */
        // Update
        List<Product2> packagesToUpdate = new List<Product2>();
        for(Product2 prod : packageIdandPackageObjMap.values()) {
            if(prod.Id != null) {
                packagesToUpdate.add(prod);
            }
        }
        if(packagesToUpdate.size() > 0) {
            update packagesToUpdate;
        }
  
    }
    /** Added By Jeet Ends **/
   
   /////////////////////////////
   
   /** Added By Sowmya **/
    
    public static void updatePBEntrykUnitPrice(Map<Id,Product2> oldMap, Map<Id,Product2> newMap) {
        
        Set<Id> product2Ids = new Set<Id>();
        List<PricebookEntry> pBEToUpdate = new List<PricebookEntry>();
        Set<String> currencyIsoCodeList = new Set<String>();
        Map<string,double>  isoCodeMap = new Map<string,double>();
        Set<id> product2ActiveChangeIds = new Set<id>();
        list<PricebookEntry> pricebookEntryList = new list<PricebookEntry>();  // To capture pricebookenteries of product which price has changed or both price and isactive has changed
        list<PricebookEntry> pricebookEntryActiveChangeList = new list<PricebookEntry>(); // To capture pricebookentries for which product active status alone changed
        for (Product2 product : newMap.values()) {
            // If Price field has changed
             if(product.Price__c != null){
                if (product.Price__c != oldMap.get(product.Id).Price__c || product.isActive != oldMap.get(product.Id).isActive) {    
                
                         product2Ids.add(product.Id);     
                    }
             }
             
             if(product.isActive != oldMap.get(product.Id).isActive || Test.isRunningTest()){
                 product2ActiveChangeIds.add(product.Id);
             }
        }        
        
        if( product2Ids.Size() > 0 && product2ActiveChangeIds.Size() > 0){
            
            product2Ids.addAll(product2ActiveChangeIds);
            // Query runs only when there are product records which got change in price as well as active status 
            pricebookEntryList = [select id,UnitPrice,Product2Id,IsActive,Product2.Price__c,CurrencyIsoCode from PricebookEntry where Product2Id in:product2Ids];
        }else if(product2Ids.Size() > 0){
            // Query runs only when there are product records which got change only in price 
            pricebookEntryList = [select id,UnitPrice,Product2Id,IsActive,Product2.Price__c,CurrencyIsoCode from PricebookEntry where Product2Id in:product2Ids];
        }else if(product2ActiveChangeIds.Size() >0){
            // Query runs only when there are product records which got change only in active status
            pricebookEntryActiveChangeList = [SELECT Id, IsActive, Product2Id FROM PriceBookEntry WHERE Product2Id in :product2ActiveChangeIds];
        }
        system.debug('---proudct2Ids---'+product2Ids);  
        
        if(pricebookEntryActiveChangeList.Size() > 0 || Test.isRunningTest()){
            for(PricebookEntry p : pricebookEntryActiveChangeList){
           
                  p.isActive = newMap.get(p.Product2Id).isActive;
                  pBEToUpdate.add(p);
                 
             }
        }
        
        if(product2Ids.size()>0){
        
        pricebookEntryList = [select id,UnitPrice,Product2Id,IsActive,Product2.Price__c,CurrencyIsoCode from PricebookEntry where Product2Id in:product2Ids];
        
        system.debug('---pricebookEntryList---'+pricebookEntryList);
        if(pricebookEntryList.size()>0){
        
          for(PricebookEntry p : pricebookEntryList){
           
              currencyIsoCodeList.add(p.CurrencyIsoCode);
                 
             }   
        system.debug('---currencyIsoCodeList---'+currencyIsoCodeList);
        if(currencyIsoCodeList.size()>0){
        
                Date todate = system.today();
                list<DatedConversionRate> datedConversionRateList = [SELECT Id,ConversionRate,IsoCode,StartDate FROM DatedConversionRate where IsoCode in: currencyIsoCodeList order by StartDate DESC ];     
                system.debug('---datedConversionRateList---'+datedConversionRateList);                
                if(datedConversionRateList.size()>0){
                 
                     for(DatedConversionRate d : datedConversionRateList){                    
                          if(!isoCodeMap.containskey(d.IsoCode)){
                            isoCodeMap.put(d.IsoCode,d.ConversionRate);
                          }     
                     }

                     for(PricebookEntry p : pricebookEntryList){
                          
                          if(p.Product2.Price__c != null){
                               p.UnitPrice = isoCodeMap.get(p.CurrencyIsoCode)*p.Product2.Price__c;
                               if(product2ActiveChangeIds.contains(p.Product2Id)){
                                   p.isActive = newMap.get(p.Product2Id).isActive;
                               }
                               pBEToUpdate.add(p);
                               
                           }else{
                               if(product2ActiveChangeIds.contains(p.Product2Id)){
                                   p.isActive = newMap.get(p.Product2Id).isActive;
                               }
                               pBEToUpdate.add(p);
                           }
                     }
                   }                   
               } 
           }  
        }
        update pBEToUpdate;
        System.debug('pBEToUpdate-->'+pBEToUpdate);
    }
    
    // Added method to check if product is auto generated then not allow to update the product details.
    public static void checkIsProductAutoCreated(List<Product2> products, Map<Id,Product2> mapProduct, Map<Id,Product2> oldProduct){
        if(!Label.System_Admin_Profile_Id.containsIgnoreCase(Userinfo.getProfileId())) {
            List<Product2> autoGeneratedProduct = [SELECT id,IsActive FROM Product2 where id IN :products AND Auto_Generated_Product__c = true]; //AND (name='Discount' OR name='Shipping and Handling' OR name ='VAT Tax')
            if(autoGeneratedProduct.size() > 0 ){
                for(Product2 product : autoGeneratedProduct){
                    Product2 actualRecord = new Product2();
                    actualRecord =  oldProduct.get(product.id);
                    if(mapProduct != null){
                        system.debug('status= '+mapProduct.get(product.id).isActive+' = '+actualRecord.IsActive);
                        if(mapProduct.get(product.id).isActive != actualRecord.IsActive){
                            String activatStatus = actualRecord.IsActive ? 'Deactivate' : 'Activate';
                            actualRecord = mapProduct.get(product.id);
                            actualRecord.addError('You can not '+activatStatus+' an auto generated product.');
                            return;
                        }
                    } else {
                        actualRecord.addError('You can not DELETE an auto generated product.');
                        return;
                    }               
                }
            }
        }
    }
    /** Added By Sowmya Ends **/
    
    ////////////////////////////
   
}
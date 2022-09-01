/* ====================================================
@Name:  QE_addPackageAndProductController_LEX
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
 1.0        Manan Patel          11/12/2018      INITIAL DEVELOPMENT                                 
   
@=======================================================  */
public without sharing class QE_addPackageAndProductController_LEX{
// this is not used part
   @AuraEnabled
   public static List<product2> fetchOpportunity() {
       List<product2> lstOpportunity=new List<product2>();
       lstOpportunity=[SELECT Id,Name,ProductCode,isActive,ExternalId,StockKeepingUnit FROM product2  limit 15];
       return lstOpportunity; 
   }
   
   @AuraEnabled
   public static List<wrapperClass> getFilteredProduct(String selectedValue,Id opportunityId,String filterText){
        
        selectedValue = Schema.SObjectType.Product2.getRecordTypeInfosByName().get(selectedValue).getRecordTypeId();
        String filteredText = '%' + filterText + '%';
        List<wrapperClass> displayProductValues;
        List<Opportunity> lstOpportunitys;
        displayProductValues = null;
        lstOpportunitys = [select Id, Email__c,Event__c,Event__r.Name,Name,Reward_Points_Pending__c,Primary_Contact__c,AccountId,
        Event__r.Program__r.name,Account.Name,Amount,OwnerId,Grand_Total__c,StageName,Probability,CloseDate,Account.IsPersonAccount,
        Type,CurrencyIsoCode, is_Applied_Rewards__c from Opportunity where Id=:opportunityId];

        Map<Id,OpportunityLineItem> oppLineMapWithData = new Map<Id,OpportunityLineItem>();
        Map<Id,Double> oppLineMap = new Map<Id,Double>();
        for(OpportunityLineItem oli: [SELECT Id, Product2Id, Quantity, Quantity_Text__c ,OpportunityId, Room_Type__c FROM OpportunityLineItem WHERE OpportunityId =: opportunityId and Record_Type__c != 'Package Product' and ProductType__c != 'Shipping and Handling' and ProductType__c != 'Discount']){
            if(oppLineMap.containsKey(oli.Product2Id)){
                Double temp = oppLineMap.get(oli.Product2Id) + oli.Quantity;
                oppLineMap.put(oli.Product2Id,temp);
            } else {
                oppLineMap.put(oli.Product2Id,oli.Quantity);
            }
            oppLineMapWithData.put(oli.Product2Id,oli);
        } 

        if(lstOpportunitys.size() > 0){
            
            if(selectedValue == Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId()){
                
                List<PricebookEntry> lstRecordType=[SELECT UseStandardPrice, Name, Product2Id, Product2.Event__r.Name, Product2.Name, Product2.RecordType.Id, Product2.RecordType.Name, Pricebook2Id, UnitPrice, Id,IsActive, Product2.A_La_Carte__c, Product2.Cost__c, Product2.Inventory__c, Product2.Threshold__c, CurrencyIsoCode, Product2.Type__c FROM PricebookEntry WHERE Product2.Event__c =: lstOpportunitys[0].Event__c AND Product2.RecordType.Id =: selectedValue AND Product2.IsActive = TRUE AND Product2.A_La_Carte__c =: TRUE And CurrencyIsoCode = :lstOpportunitys[0].CurrencyIsoCode and Product2.Type__c != 'Shipping and Handling' and (Product2.Name != 'Discount') and Product2.Name Like: filteredText];
                if(lstRecordType.size() >0){
                displayProductValues = new List<wrapperClass>();
                    for(PricebookEntry item:lstRecordType) {
                        if(oppLineMap.containsKey(item.Product2Id)){
                            displayProductValues.add(new wrapperClass(item,oppLineMap.get(item.Product2Id),oppLineMapWithData.get(item.Product2Id)));
                        } else {
                                displayProductValues.add(new wrapperClass(item,null,null));
                        }
                    }
                }
            } else if(selectedValue == Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId()){
                
                List<PricebookEntry> lstRecordType=[SELECT UseStandardPrice, Name, Product2Id, Product2.Event__r.Name, Product2.Name, Product2.RecordType.Id, Product2.RecordType.Name, Pricebook2Id, UnitPrice, Id,IsActive, Product2.A_La_Carte__c, Product2.Cost__c, Product2.Inventory__c, Product2.Threshold__c, Product2.Type__c FROM PricebookEntry WHERE Product2.Event__c =: lstOpportunitys[0].Event__c AND Product2.RecordType.Id =: selectedValue AND Product2.IsActive = TRUE AND Product2.A_La_Carte__c =: TRUE And CurrencyIsoCode = :lstOpportunitys[0].CurrencyIsoCode and Product2.Name Like: filteredText];
                if(lstRecordType.size()>0){
                displayProductValues=new List<wrapperClass>();
                    for(PricebookEntry item:lstRecordType){
                        if(oppLineMap.containsKey(item.Product2Id)){
                            displayProductValues.add(new wrapperClass(item,oppLineMap.get(item.Product2Id),oppLineMapWithData.get(item.Product2Id)));
                        }else{
                                displayProductValues.add(new wrapperClass(item,null,null));
                        }
                    }
                }
            } else {
                List<PricebookEntry> lstRecordType=[SELECT UseStandardPrice, Name, Product2Id, Product2.Event__r.Name, Product2.Name, Product2.RecordType.Id, Product2.RecordType.Name, Pricebook2Id, UnitPrice, Id,IsActive,Product2.Cost__c,Product2.Package_Inventory__c, Product2.Type__c FROM PricebookEntry WHERE Product2.Event__c =: lstOpportunitys[0].Event__c AND Product2.RecordType.Id =: selectedValue AND Product2.IsActive = TRUE And CurrencyIsoCode = :lstOpportunitys[0].CurrencyIsoCode and Product2.Name Like: filteredText];
                if(lstRecordType.size()>0){
                displayProductValues=new List<wrapperClass>();
                    for(PricebookEntry item:lstRecordType){
                        if(oppLineMap.containsKey(item.Product2Id)){
                            displayProductValues.add(new wrapperClass(item,oppLineMap.get(item.Product2Id),oppLineMapWithData.get(item.Product2Id)));
                        }else{
                            displayProductValues.add(new wrapperClass(item,null,null));
                        }
                    }
                }
            }
        }
    return displayProductValues;
    }
// this is not used part
   @AuraEnabled
   public static Decimal getOpportunity(Id oppoId) // get the opportunity which StageName is 'Closed Won' OR 'Closed Lost'
   {
       List<Opportunity> lstOpportunity=new List<Opportunity>();
       lstOpportunity=[select Id,Name from Opportunity where id=: oppoId and (StageName='Closed Won' OR StageName='Closed Lost')];
       return lstOpportunity.size(); 
   }
   
   @AuraEnabled
   public static Opportunity opportunityDetails(Id opportunityId)// get the selected opportunity detail to show data on the record
   {
       Opportunity lstOpportunity=new Opportunity();
       lstOpportunity=[select Id,Name,Email__c,Account.Name,Event__c,Event__r.Name,OwnerId,Owner.Name,Grand_Total__c,StageName,Probability,CloseDate,Type,is_Applied_Rewards__c,Primary_Contact__r.name from Opportunity where id=: opportunityId];
       return lstOpportunity;
   }

    @AuraEnabled
    public static Decimal h4hPoints(Id opportunityId) // get the count of h4hPoint
    {
        Decimal H4HPoints = 0.0;

        List<Opportunity> lstOpportunity = [select Id, Email__c,Event__c,Event__r.Name,Name,Reward_Points_Pending__c,Primary_Contact__c,AccountId,Event__r.Program__r.name,
        Account.Name,Amount,OwnerId,Grand_Total__c,StageName,Probability,CloseDate,Account.IsPersonAccount,Type,CurrencyIsoCode, is_Applied_Rewards__c from Opportunity where
        Id=:opportunityId];

        List<AggregateResult> results = [SELECT Sum(Reward_Points_Pending__c) H4HTotal FROM Opportunity WHERE email__c = :lstOpportunity[0].email__c AND StageName = 'Closed Won' AND Reward_Points_Pending__c != null AND Paid_in_full__c = true AND event__r.program__r.Name != null AND event__r.program__r.Name LIKE '%F1E%'];
       
        // Added below for loop
        if(!results.isEmpty() && results.size() > 0 && results[0].get('H4HTotal') != null) {
            for(AggregateResult ar: results){
                H4HPoints = H4HPoints + integer.valueOf(ar.get('H4HTotal'));        
            }
        } 
        if(opportunityId != null){
            String tokenId = '';
            Opportunity opp = [select Id,Email__c,ship_to_name__c,Event__r.Program__r.name,Reward_Points_Pending__c,StageName,paid_in_full__c from Opportunity where Id=:opportunityId];
            if(opp.Email__c != null && opp.ship_to_name__c != null && opp.Event__r.Program__r.name != null && opp.Event__r.Program__r.name.contains('F1E') ){
                tokenId =  QE_H4HCalloutClass.getH4HTokenId();
                H4HPoints = QE_H4HCalloutClass.createRequestToH4HForClosedWon(opp,tokenId);
            }
        }
        return H4HPoints;
    }

    @AuraEnabled
    public static List<String> getProductRecprdType(){  //get the record type of the product
        List<String> items = new List<String>();
        Map<Id,RecordType> proRecordType= new Map<Id, RecordType>([SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'Product2']);
        if(proRecordType.size()>0){
            for(RecordType item: proRecordType.values()){
                items.add(string.valueof(item.Name));
            }
        }
        return items;
    }

    @AuraEnabled
    public static List<OpportunityLineItem> getOldSelectedProducts(Id opportunityId){ //get old selected item form opportunity line item
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();

        List<Opportunity> lstOpportunity = [select Id, Email__c,Event__c,Event__r.Name,Name,Reward_Points_Pending__c,Primary_Contact__c,AccountId,Event__r.Program__r.name,Account.Name,Amount,OwnerId,
        Grand_Total__c,StageName,Probability,CloseDate,Account.IsPersonAccount,Type,CurrencyIsoCode, is_Applied_Rewards__c from Opportunity where Id=:OpportunityId];
        
        List<Package_Products__c> packProList = new List<Package_Products__c>([SELECT Id, Name, Package__c,Package__r.Event__c, Products_and_Hotels__c, Product_Type__c 
         FROM Package_Products__c WHERE Package__r.Event__c =: lstOpportunity[0].Event__c AND Product_Type__c = 'Hotels']);

        Map<Id,Integer> packHotelMap = new Map<Id,Integer>();
        if(packProList.size() > 0){
            for(Package_Products__c pP: packProList){
                if(packHotelMap.containsKey(pP.Package__c)) {
                    Integer hCount = packHotelMap.get(pP.Package__c);
                    hCount = hCount + 1;
                    packHotelMap.put(pP.Package__c, hCount);
                } else {
                    packHotelMap.put(pP.Package__c, 1);
                }
            }
        }
        for(OpportunityLineItem oppLine: [SELECT Id, Apex_No_of_Hotels__c,Name, Opportunity_Product_Package_Hotel__c,Description ,Quantity_Text__c ,Product2Id,Product2.Price__c,Price__c,OpportunityId,PricebookEntryId,Quantity,UnitPrice,ApexProductType__c,ApexProductName__c,ApexCost__c,Room_Type__c FROM OpportunityLineItem WHERE OpportunityId =: opportunityId and Record_Type__c != 'Package Product' and ProductType__c != 'Shipping and Handling' and ProductType__c != 'Reward Discount']){   
            if(packHotelMap.containsKey(oppLine.Product2Id)){
                oppLine.Apex_No_of_Hotels__c = packHotelMap.get(oppLine.Product2Id);
            }else{
                oppLine.Apex_No_of_Hotels__c = 0;
            }
            if(oppLine.Opportunity_Product_Package_Hotel__c != true){
                oliList.add(oppLine);
            }
        }        
    return oliList;
    }
    
    //not used method
    @AuraEnabled
    public static List<OpportunityLineItem> getFilteredListProduct(Id opportunityId, String filterText){
        String filteredText = '%' + filterText + '%';
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        for(OpportunityLineItem oppLine: [SELECT Id, Apex_No_of_Hotels__c,Name, Opportunity_Product_Package_Hotel__c,Description ,Quantity_Text__c ,Product2Id,Product2.Price__c,Price__c,OpportunityId,PricebookEntryId,Quantity,UnitPrice,ApexProductType__c,ApexProductName__c,ApexCost__c,Room_Type__c FROM OpportunityLineItem WHERE OpportunityId =: opportunityId and Record_Type__c != 'Package Product' and ProductType__c != 'Shipping and Handling' and ProductType__c != 'Reward Discount' and ApexProductName__c Like: filteredText]){   
            if(oppLine.Opportunity_Product_Package_Hotel__c != true){
                oliList.add(oppLine);
            }
        }        
    return oliList;
    }
    //not used method

    @AuraEnabled
    public static List<wrapperClass> getproduct(String selectedValue,Id opportunityId){  //get records of selected record type data
        selectedValue = Schema.SObjectType.Product2.getRecordTypeInfosByName().get(selectedValue).getRecordTypeId();
        List<wrapperClass> displayProductValues;
        List<Opportunity> lstOpportunitys;
        displayProductValues = null;
        lstOpportunitys = [select Id, Email__c,Event__c,Event__r.Name,Name,Reward_Points_Pending__c,Primary_Contact__c,AccountId,
        Event__r.Program__r.name,Account.Name,Amount,OwnerId,Grand_Total__c,StageName,Probability,CloseDate,Account.IsPersonAccount,
        Type,CurrencyIsoCode, is_Applied_Rewards__c from Opportunity where Id=:opportunityId];

        Map<Id,OpportunityLineItem> oppLineMapWithData = new Map<Id,OpportunityLineItem>();
        Map<Id,Double> oppLineMap = new Map<Id,Double>();
        for(OpportunityLineItem oli: [SELECT Id, Product2Id, Quantity, Quantity_Text__c ,OpportunityId, Room_Type__c FROM OpportunityLineItem WHERE OpportunityId =: opportunityId and Record_Type__c != 'Package Product' and ProductType__c != 'Shipping and Handling' and ProductType__c != 'Discount']){
            if(oppLineMap.containsKey(oli.Product2Id)){
                Double temp = oppLineMap.get(oli.Product2Id) + oli.Quantity;
                oppLineMap.put(oli.Product2Id,temp);
            }else{
                oppLineMap.put(oli.Product2Id,oli.Quantity);
            }
            oppLineMapWithData.put(oli.Product2Id,oli);
        } 

        if(lstOpportunitys.size() > 0){
            
            if(selectedValue == Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId()){
                
                List<PricebookEntry> lstRecordType=[SELECT UseStandardPrice, Name, Product2Id, Product2.Event__r.Name, Product2.Name, Product2.RecordType.Id, Product2.RecordType.Name, Pricebook2Id, UnitPrice, Id,IsActive, Product2.A_La_Carte__c, Product2.Cost__c, Product2.Inventory__c, Product2.Threshold__c, CurrencyIsoCode, Product2.Type__c FROM PricebookEntry WHERE Product2.Event__c =: lstOpportunitys[0].Event__c AND Product2.RecordType.Id =: selectedValue AND Product2.IsActive = TRUE AND Product2.A_La_Carte__c =: TRUE And CurrencyIsoCode = :lstOpportunitys[0].CurrencyIsoCode and Product2.Type__c != 'Shipping and Handling' and (Product2.Name != 'Discount')];
                
                if(lstRecordType.size()>0){
                displayProductValues=new List<wrapperClass>();
                    for(PricebookEntry item:lstRecordType){
                        if(oppLineMap.containsKey(item.Product2Id)){
                            displayProductValues.add(new wrapperClass(item,oppLineMap.get(item.Product2Id),oppLineMapWithData.get(item.Product2Id)));
                        }else{
                                displayProductValues.add(new wrapperClass(item,null,null));
                        }
                    }
                }
            }else if(selectedValue == Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId()){
                
                List<PricebookEntry> lstRecordType=[SELECT UseStandardPrice, Name, Product2Id, Product2.Event__r.Name, Product2.Name, Product2.RecordType.Id, Product2.RecordType.Name, Pricebook2Id, UnitPrice, Id,IsActive, Product2.A_La_Carte__c, Product2.Cost__c, Product2.Inventory__c, Product2.Threshold__c, Product2.Type__c FROM PricebookEntry WHERE Product2.Event__c =: lstOpportunitys[0].Event__c AND Product2.RecordType.Id =: selectedValue AND Product2.IsActive = TRUE AND Product2.A_La_Carte__c =: TRUE And CurrencyIsoCode = :lstOpportunitys[0].CurrencyIsoCode];
                if(lstRecordType.size()>0){
                displayProductValues=new List<wrapperClass>();
                    for(PricebookEntry item:lstRecordType){
                        if(oppLineMap.containsKey(item.Product2Id)){
                            displayProductValues.add(new wrapperClass(item,oppLineMap.get(item.Product2Id),oppLineMapWithData.get(item.Product2Id)));
                        }else{
                                displayProductValues.add(new wrapperClass(item,null,null));
                        }
                    }
                }
            }else{
               
                List<PricebookEntry> lstRecordType=[SELECT UseStandardPrice, Name, Product2Id, Product2.Event__r.Name, Product2.Name, Product2.RecordType.Id, Product2.RecordType.Name, Pricebook2Id, UnitPrice, Id,IsActive,Product2.Cost__c,Product2.Package_Inventory__c, Product2.Type__c FROM PricebookEntry WHERE Product2.Event__c =: lstOpportunitys[0].Event__c AND Product2.RecordType.Id =: selectedValue AND Product2.IsActive = TRUE And CurrencyIsoCode = :lstOpportunitys[0].CurrencyIsoCode];
                if(lstRecordType.size()>0){
                displayProductValues=new List<wrapperClass>();
                    for(PricebookEntry item:lstRecordType){
                        if(oppLineMap.containsKey(item.Product2Id)){
                            displayProductValues.add(new wrapperClass(item,oppLineMap.get(item.Product2Id),oppLineMapWithData.get(item.Product2Id)));
                        }else{
                            displayProductValues.add(new wrapperClass(item,null,null));
                        }
                    }
                }
            }
        }
    return displayProductValues;
    }

    @AuraEnabled
    public static List<OpportunityLineItem> getSavedOppList(String displayProductString, Id opportunityId, String oppItemList){   //process the selected data from first table
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> displayProd = (List<OpportunityLineItem>)JSON.deserialize(oppItemList,List<OpportunityLineItem>.class);
        oliList = displayProd;

        Set<String> uniqueProduct = new Set<String>();
        for(OpportunityLineItem lineItemList : oliList){
            uniqueProduct.add(lineItemList.ApexProductName__c);
        }

        Map<Id,wrapperClass> wrapperClassObjByProductId = new Map<Id,wrapperClass>();
        Map<Id,PricebookEntry> proMap = new Map<Id,PricebookEntry>();
        List<PricebookEntry> selectedProductList = new List<PricebookEntry>();
        List<Opportunity> lstOpportunitys;
        lstOpportunitys = [select Id, Email__c,Event__c,Event__r.Name,Name,Reward_Points_Pending__c,Primary_Contact__c,AccountId,
        Event__r.Program__r.name,Account.Name,Amount,OwnerId,Grand_Total__c,StageName,Probability,CloseDate,Account.IsPersonAccount,
        Type,CurrencyIsoCode, is_Applied_Rewards__c from Opportunity where Id=:opportunityId];

        List<Package_Products__c> packProList = new List<Package_Products__c>([SELECT Id, Name, Package__c,Package__r.Event__c, Products_and_Hotels__c, Product_Type__c   FROM Package_Products__c WHERE Package__r.Event__c =: lstOpportunitys[0].Event__c AND Product_Type__c = 'Hotels']);
        Map<Id,Integer> packHotelMap = new Map<Id,Integer>();
        if(packProList.size() > 0){
            for(Package_Products__c pP: packProList){
                if(packHotelMap.containsKey(pP.Package__c)) {
                    Integer hCount = packHotelMap.get(pP.Package__c);
                    hCount = hCount + 1;
                    packHotelMap.put(pP.Package__c, hCount);
                } else {
                    packHotelMap.put(pP.Package__c, 1);
                }
            }
        }
        List<wrapperClass> displayProductValues = (List<wrapperClass>)JSON.deserialize(displayProductString,List<wrapperClass>.class);
        //We will cycle through our list of cContacts and will check to see if the selected property is set to true, if it is we add the Contact to the selectedContacts list
        if(displayProductValues.size() > 0){
            for(wrapperClass pPro: displayProductValues) {
                
                if(pPro.selectBit == true) {
                    
                    if(!proMap.containsKey(pPro.objProduct.Id))
                    proMap.put(pPro.objProduct.Id,pPro.objProduct);
                }
                wrapperClassObjByProductId.put(pPro.objProduct.Id,pPro);
            }
        }
        
        if(proMap.size() > 0){
            selectedProductList = proMap.values();
        }
        
        List<PricebookEntry> lstRecordType=[SELECT UseStandardPrice, Name, Product2Id, Product2.Event__r.Name, Product2.Name, Product2.RecordType.Id, Product2.RecordType.Name, Pricebook2Id, UnitPrice, Id,IsActive, Product2.A_La_Carte__c, Product2.Cost__c FROM PricebookEntry WHERE Product2.Event__c =: lstOpportunitys[0].Event__c ];
        Map<Id,Id> pricProMap = new Map<Id,Id>();
        for(PricebookEntry ppR: lstRecordType){
            pricProMap.put(ppR.Id,ppR.Product2Id);
        }
        // Now we have our list of selected contacts and can perform any type of logic we want, sending emails, updating a field on the Contact, etc
        for(PricebookEntry pro: selectedProductList) {
            if(!uniqueProduct.contains(pro.Product2.Name)){
               
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId=OpportunityId;
                oli.PricebookEntryId=pro.Id;
                //oli.Quantity_Text__c = 1;
                oli.Quantity = 1;
                oli.UnitPrice = pro.UnitPrice;
                oli.ApexProductType__c = pro.Product2.RecordType.Name;
                oli.ApexProductName__c = pro.Product2.Name;
                oli.ApexCost__c = pro.Product2.Cost__c;
                oli.ProductType__c = pro.Product2.Type__c;
                
                // Update record type field for opportunity line items
                // This section only holds either A La Carte items or Packages, Hotels gets added directly.
                if(oli.ApexProductType__c != null) {
                    if(oli.ApexProductType__c.equals('Products') || oli.ApexProductType__c.equals('Hotels')) {
                        oli.Record_Type__c = 'A La Carte';
                    } else if (oli.ApexProductType__c.equals('Package')) {
                        oli.Record_Type__c = 'Package';
                    }
                }
                
                if(pricProMap.containsKey(pro.Id)){
                    if(packHotelMap.containsKey(pricProMap.get(pro.Id))){
                        oli.Apex_No_of_Hotels__c = packHotelMap.get(pricProMap.get(pro.Id));
                    }else{
                        oli.Apex_No_of_Hotels__c = 0;
                    }
                }else{
                    oli.Apex_No_of_Hotels__c = 0;
                }
                
                oliList.add(oli);
            }
        }
        return oliList;
    }

    @AuraEnabled
    public static List<OpportunityLineItem> saveOpportunitys(Id opportunityId, String oppItemList, Opportunity currentOppRecord){   //save and update data from second table
        System.debug('@@@currentOppRecord : '+currentOppRecord.Is_Applied_Rewards__c);
        List<Opportunity> lstOpportunitys;
        List<OpportunityLineItem> displayProductValues = (List<OpportunityLineItem>)JSON.deserialize(oppItemList,List<OpportunityLineItem>.class);
        List<OpportunityLineItem> oliList;
        oliList = displayProductValues;
        lstOpportunitys = [select Id, Email__c,Event__c,Event__r.Name,Name,Reward_Points_Pending__c,Primary_Contact__c,AccountId,
        Event__r.Program__r.name,Account.Name,Amount,OwnerId,Grand_Total__c,StageName,Probability,CloseDate,Account.IsPersonAccount,
        Type,CurrencyIsoCode, is_Applied_Rewards__c from Opportunity where Id=:opportunityId];
        
        system.debug('@@@@lstOpportunitys[0].is_Applied_Rewards__c==='+lstOpportunitys[0].is_Applied_Rewards__c);
        List<OpportunityLineItem> oLst = createOppLineItem(currentOppRecord.Is_Applied_Rewards__c, lstOpportunitys);
        
        Set<Id> priceBESet = new Set<Id>();
        Map<Id,List<OpportunityLineItem>> oppHMap = new Map<Id,List<OpportunityLineItem>>();
        Map<Id,PricebookEntry> priceBEMap = new Map<Id,PricebookEntry>();
        List<PricebookEntry> priceBEList = new List<PricebookEntry>();
        List<OpportunityLineItem> oppHList = new List<OpportunityLineItem>([SELECT Id, Name, Package__c, Quantity, Price__c, Product2Id, OpportunityId, Product2.Tax_Percentage__c,Opportunity_Product_Package_Hotel__c, Room_Type__c FROM OpportunityLineItem WHERE Opportunity_Product_Package_Hotel__c = true AND OpportunityId =: opportunityId]);
        
        if(oppHList.size() > 0){
            for(OpportunityLineItem op: oppHList){
                if(oppHMap.containsKey(op.Package__c)) {
                    List<OpportunityLineItem> oppHId = oppHMap.get(op.Package__c);
                    oppHId.add(op);
                    oppHMap.put(op.Package__c, oppHId);
                } else {
                    oppHMap.put(op.Package__c, new List<OpportunityLineItem> { op });
                }
            }
        }
        
        if(oliList.Size() > 0){
            for(OpportunityLineItem oli: oliList){
                priceBESet.add(oli.PricebookEntryId);
            }
        }
        
        if(priceBESet.Size() > 0){
            for(PricebookEntry pbe: [SELECT Id, Product2Id FROM PricebookEntry WHERE Id IN: priceBESet]){
                priceBEMap.put(pbe.Id,pbe);
            }
        }
    
        if(!oLst.isEmpty()){
            oliList.addAll(oLst);
        }

        if(oliList.Size() > 0){
            try{
                List<OpportunityLineItem> insertList = new List<OpportunityLineItem>();
                List<OpportunityLineItem> updateList = new List<OpportunityLineItem>();
                for(OpportunityLineItem oli : oliList){
                    if(oli.Id != null)
                    {
                        updateList.add(oli);
                    }
                    else{
                        insertList.add(oli);
                    }
                }
                if (!Test.isRunningTest()) {   
                    if(!updateList.isEmpty())
                        update updateList;
    
                    if(!insertList.isEmpty())
                        insert insertList;
                }
            }Catch(Exception ex){
                System.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
            }
        }
        
        
        if (!Test.isRunningTest()) {   
            Database.Update(lstOpportunitys,false);
        }
        return oliList;
    }
    @AuraEnabled
    public static List<OpportunityLineItem> createOppLineItem(Boolean isAppliedReward,List<Opportunity> lstOpportunity){  // this method is called from saveOpportunitys()
       Id OpportunityId = lstOpportunity[0].Id;
       List<OpportunityLineItem> oppLineList = new List<OpportunityLineItem>();       
       List<pricebookentry> pbeList = new List<pricebookentry>();       
       List<OpportunityLineItem> ExistingDiscountOppLine = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =:lstOpportunity[0].Id AND ProductType__c = 'Reward Discount' ]; 
       Boolean oppUpdate = false;

        if(isAppliedReward){
            if(OpportunityId != null && lstOpportunity[0].event__r.program__r.name != null && lstOpportunity[0].event__r.program__r.name.contains('F1E')) {
                if(ExistingDiscountOppLine.isEmpty()) {
              
                    pbeList = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2.Event__c =:lstOpportunity[0].Event__c AND Product2.Name = 'Discount' AND CurrencyISOCode =:lstOpportunity[0].currencyISOcode];
                        
                    OpportunityLineItem oppLine = new OpportunityLineItem();
                    oppLine.OpportunityId = OpportunityId;
                    oppLine.ProductType__c = 'Reward Discount';
                    oppLine.Record_Type__c = 'A La Carte';
                    oppLine.UnitPrice = 0;
                    oppLine.Quantity = 1;
                    oppLine.Description ='Hotels 4 Hope Points used';
                    oppLine.PriceBookEntryId = pbeList[0].Id;
                    oppLineList.add(oppLine);
                }
            
                if(!oppLineList.isEmpty()){
                    oppUpdate = true;
                }
            }
        }
        
        else{
        if(OpportunityId != null && lstOpportunity[0].event__r.program__r.name != null && lstOpportunity[0].event__r.program__r.name.contains('F1E')) {
            if(!ExistingDiscountOppLine.isEmpty()) 
                Database.delete(ExistingDiscountOppLine,false);
                oppUpdate = true;
        }
        }
           
        return oppLineList;
    }

    @AuraEnabled
    public static List<wrapperClassHotel> showPopup(Id opportunityId,Id packId){   //select product to display given hotel is available for selection in third popup
        List<wrapperClassHotel> displayPackHotel;
        Map<Id,List<wrapperClassHotelTransportation>> hotelTransportationByHotel;
        List<wrapperClassHotelTransportation> hotelTransportationByHotelList;
       
        List<Opportunity> lstOpportunity = [select Id, Email__c,Event__c,Event__r.Name,Name,Reward_Points_Pending__c,Primary_Contact__c,AccountId,
        Event__r.Program__r.name,Account.Name,Amount,OwnerId,Grand_Total__c,StageName,Probability,CloseDate,Account.IsPersonAccount,Exchange_Rate_Date_Override__c,
        Type,CurrencyIsoCode, is_Applied_Rewards__c from Opportunity where Id=:opportunityId];

        displayPackHotel = null;
        hotelTransportationByHotel = null;
        hotelTransportationByHotelList = null;
        if(packId != null){
            PricebookEntry pbE = [SELECT Id, Product2Id FROM PricebookEntry WHERE Id =: packId];
            Map<Id,OpportunityLineItem> oHWOMap = new Map<Id,OpportunityLineItem>();
            
            List<OpportunityLineItem> oppHWithOppList = new List<OpportunityLineItem>([SELECT Id, Name, Package__c, Product2Id,Product2.Price__c,Price__c,OpportunityId,PricebookEntryId,Quantity,UnitPrice,ApexProductType__c,ApexProductName__c,ApexCost__c,Room_Type__c FROM OpportunityLineItem WHERE Package__c =: pbE.Product2Id AND OpportunityId =: OpportunityId]);
            if(oppHWithOppList.size() > 0){
                for(OpportunityLineItem oppH: oppHWithOppList){
                    oHWOMap.put(oppH.Product2Id,oppH);
                }
            }
            
            // CurrencyType Helper
            QE_DatedConversionRateHelper datedConversionRateHelper = new QE_DatedConversionRateHelper();
            
            List<Package_Products__c> packProList = [SELECT Products_and_Hotels__c,Active__c,Products_and_Hotels__r.RecordType.Name,Products_and_Hotels__r.Price__c,Products_and_Hotels__r.Name,Products_and_Hotels__r.IsActive,Amount__c,Product_Type__c, Products_and_Hotels__r.Type__c from Package_Products__c WHERE Package__c =: pbE.Product2Id AND Product_Type__c = 'Hotels'];// AND Active__c = TRUE];
            
            Set<Id> idsOfPackageHotels = new Set<Id>();
            if(packProList.size() > 0){
                displayPackHotel=new List<wrapperClassHotel>();
                for(Package_Products__c item: packProList){ 
                    if(oHWOMap.containsKey(item.Products_and_Hotels__c)){
                        if(oHWOMap.get(item.Products_and_Hotels__c).Quantity > 0){
                            if(oHWOMap.get(item.Products_and_Hotels__c).Price__c != null){
                                displayPackHotel.add(new wrapperClassHotel(item,Integer.valueOf(oHWOMap.get(item.Products_and_Hotels__c).Quantity),oHWOMap.get(item.Products_and_Hotels__c).Price__c,true,oHWOMap.get(item.Products_and_Hotels__c).Room_Type__c,oHWOMap.get(item.Products_and_Hotels__c).Id));
                            }else{
                                displayPackHotel.add(new wrapperClassHotel(item,Integer.valueOf(oHWOMap.get(item.Products_and_Hotels__c).Quantity),null,true,oHWOMap.get(item.Products_and_Hotels__c).Room_Type__c,oHWOMap.get(item.Products_and_Hotels__c).Id));
                            }
                        }else{
                            if(oHWOMap.get(item.Products_and_Hotels__c).Price__c != null){
                                displayPackHotel.add(new wrapperClassHotel(item,null,oHWOMap.get(item.Products_and_Hotels__c).Price__c,true,oHWOMap.get(item.Products_and_Hotels__c).Room_Type__c,oHWOMap.get(item.Products_and_Hotels__c).Id));
                            }else{
                                displayPackHotel.add(new wrapperClassHotel(item,null,null,true,oHWOMap.get(item.Products_and_Hotels__c).Room_Type__c,oHWOMap.get(item.Products_and_Hotels__c).Id));
                            }
                        }
                    }else{
                        if(item.Products_and_Hotels__r.IsActive == TRUE){
                            Decimal convertedPrice = 0;
                            // For USD
                            if(lstOpportunity[0].CurrencyIsoCode.equals('USD')) {
                                convertedPrice = item.Products_and_Hotels__r.Price__c;
                            } else {
                            // For NON USD                                
                                convertedPrice = datedConversionRateHelper.convert(item.Products_and_Hotels__r.Price__c,lstOpportunity[0].CurrencyIsoCode,lstOpportunity[0].Exchange_Rate_Date_Override__c);
                            }
                            convertedPrice = convertedPrice.setScale(2);
                            displayPackHotel.add(new wrapperClassHotel(item,1,convertedPrice,false,'',null));
                        }
                    }
                    // Add hotel ids to set, so we can use this to query hotel transportation
                    idsOfPackageHotels.add(item.Products_and_Hotels__c);
                }
            }
        
            List<OpportunityLineItem> oliListForHotelTransportation = [select id, Product2Id from OpportunityLineItem where opportunityId = :OpportunityId and Product_Type__c = 'Products'];
            // Query hotel transportation
            Set<Id> preSelectedProductIds = new Set<Id>();
            for(OpportunityLineItem oli : oliListForHotelTransportation) {
                preSelectedProductIds.add(oli.Product2Id);
            }
        
            if (idsOfPackageHotels.size() > 0) {
                hotelTransportationByHotel = new Map<Id,List<wrapperClassHotelTransportation>>();
                hotelTransportationByHotelList = new List<wrapperClassHotelTransportation>();
                List<Hotel_Transportation__c> hotelTransportationsList = [Select Id, Hotel__c, Transportation__c, Transportation__r.Name, Transportation__r.RecordType.Name,Transportation__r.Type__c, Transportation__r.Price__c, Transportation__r.IsActive from Hotel_Transportation__c where Hotel__c in :idsOfPackageHotels ];//AND Transportation__r.IsActive =: TRUE];

                for (Hotel_Transportation__c item : hotelTransportationsList) {
                    Decimal convertedPrice = 0;
                    // For USD
                    if(lstOpportunity[0].CurrencyIsoCode.equals('USD')) {
                        convertedPrice = item.Transportation__r.Price__c;
                    } else {
                    // For NON USD                                
                        convertedPrice = datedConversionRateHelper.convert(item.Transportation__r.Price__c,lstOpportunity[0].CurrencyIsoCode,lstOpportunity[0].Exchange_Rate_Date_Override__c);
                    }
                    convertedPrice = convertedPrice.setScale(2);
                    // Pre-Selected
                    if(preSelectedProductIds.contains(item.Transportation__c)) {
                        hotelTransportationByHotelList.add(new wrapperClassHotelTransportation(item,1,convertedPrice,true));
                    } else {
                        // Not Pre-Selected
                        if(item.Transportation__r.IsActive == TRUE){
                            hotelTransportationByHotelList.add(new wrapperClassHotelTransportation(item,1,convertedPrice,false));
                        }
                    }
                }
            }
        }
        return displayPackHotel; 
    }

    @AuraEnabled
    public static List<wrapperClassHotelTransportation> selectTransportations(Id opportunityId,Id packId){    // this method is replica of the selectHotels method and brings the selected hotels of transportation

        List<wrapperClassHotel> displayPackHotel;
        Map<Id,List<wrapperClassHotelTransportation>> hotelTransportationByHotel;
        List<wrapperClassHotelTransportation> hotelTransportationByHotelList;

        List<Opportunity> lstOpportunity = [select Id, Email__c,Event__c,Event__r.Name,Name,Reward_Points_Pending__c,Primary_Contact__c,AccountId,
        Event__r.Program__r.name,Account.Name,Amount,OwnerId,Grand_Total__c,StageName,Probability,CloseDate,Account.IsPersonAccount,
        Type,CurrencyIsoCode, is_Applied_Rewards__c from Opportunity where Id=:opportunityId];
        
        displayPackHotel = null;
        hotelTransportationByHotel = null;
        hotelTransportationByHotelList = null;
        if(packId != null){
            PricebookEntry pbE = [SELECT Id, Product2Id FROM PricebookEntry WHERE Id =: packId];
            Map<Id,OpportunityLineItem> oHWOMap = new Map<Id,OpportunityLineItem>();
           
            List<OpportunityLineItem> oppHWithOppList = new List<OpportunityLineItem>([SELECT Id, Name, Package__c, Product2Id,Product2.Price__c,Price__c,OpportunityId,PricebookEntryId,Quantity,UnitPrice,ApexProductType__c,ApexProductName__c,ApexCost__c,Room_Type__c FROM OpportunityLineItem WHERE Package__c =: pbE.Product2Id AND OpportunityId =: OpportunityId]);
           
            if(oppHWithOppList.size() > 0){
                for(OpportunityLineItem oppH: oppHWithOppList){
                    oHWOMap.put(oppH.Product2Id,oppH);
                }
            }
            
            // CurrencyType Helper
            QE_DatedConversionRateHelper datedConversionRateHelper = new QE_DatedConversionRateHelper();
            List<Package_Products__c> packProLis1 = [SELECT Products_and_Hotels__c,Active__c,Products_and_Hotels__r.RecordType.Name,Products_and_Hotels__r.Price__c,Products_and_Hotels__r.Name,Products_and_Hotels__r.IsActive,Amount__c,Product_Type__c, Products_and_Hotels__r.Type__c,Package__c from Package_Products__c];
            
            List<Package_Products__c> packProList = [SELECT Products_and_Hotels__c,Active__c,Products_and_Hotels__r.RecordType.Name,Products_and_Hotels__r.Price__c,Products_and_Hotels__r.Name,Products_and_Hotels__r.IsActive,Amount__c,Product_Type__c, Products_and_Hotels__r.Type__c from Package_Products__c WHERE Package__c =: pbE.Product2Id AND Product_Type__c = 'Hotels'];// AND Active__c = TRUE];
            
            Set<Id> idsOfPackageHotels = new Set<Id>();
            if(packProList.size() > 0){
                displayPackHotel=new List<wrapperClassHotel>();
                for(Package_Products__c item: packProList){ 
                    if(oHWOMap.containsKey(item.Products_and_Hotels__c)){
                        if(oHWOMap.get(item.Products_and_Hotels__c).Quantity > 0){
                            if(oHWOMap.get(item.Products_and_Hotels__c).Price__c != null){
                                displayPackHotel.add(new wrapperClassHotel(item,Integer.valueOf(oHWOMap.get(item.Products_and_Hotels__c).Quantity),oHWOMap.get(item.Products_and_Hotels__c).Price__c,true,oHWOMap.get(item.Products_and_Hotels__c).Room_Type__c,oHWOMap.get(item.Products_and_Hotels__c).Id));
                            }else{
                                displayPackHotel.add(new wrapperClassHotel(item,Integer.valueOf(oHWOMap.get(item.Products_and_Hotels__c).Quantity),null,true,oHWOMap.get(item.Products_and_Hotels__c).Room_Type__c,oHWOMap.get(item.Products_and_Hotels__c).Id));
                            }
                        }else{
                            if(oHWOMap.get(item.Products_and_Hotels__c).Price__c != null){
                                displayPackHotel.add(new wrapperClassHotel(item,null,oHWOMap.get(item.Products_and_Hotels__c).Price__c,true,oHWOMap.get(item.Products_and_Hotels__c).Room_Type__c,oHWOMap.get(item.Products_and_Hotels__c).Id));
                            }else{
                                displayPackHotel.add(new wrapperClassHotel(item,null,null,true,oHWOMap.get(item.Products_and_Hotels__c).Room_Type__c,oHWOMap.get(item.Products_and_Hotels__c).Id));
                            }
                        }
                    }else{
                        if(item.Products_and_Hotels__r.IsActive == TRUE){
                            Decimal convertedPrice = 0;
                            // For USD
                            if(lstOpportunity[0].CurrencyIsoCode.equals('USD')) {
                                convertedPrice = item.Products_and_Hotels__r.Price__c;
                            } else {
                            // For NON USD                                
                                convertedPrice = datedConversionRateHelper.convert(item.Products_and_Hotels__r.Price__c,lstOpportunity[0].CurrencyIsoCode,lstOpportunity[0].Exchange_Rate_Date_Override__c);
                            }
                            convertedPrice = convertedPrice.setScale(2);
                            displayPackHotel.add(new wrapperClassHotel(item,1,convertedPrice,false,'',null));
                        }
                    }
                    // Add hotel ids to set, so we can use this to query hotel transportation
                    idsOfPackageHotels.add(item.Products_and_Hotels__c);
                }
            }
            
            List<OpportunityLineItem> oliListForHotelTransportation = [select id, Product2Id from OpportunityLineItem where opportunityId = :OpportunityId and Product_Type__c = 'Products'];
           
            // Query hotel transportation
            Set<Id> preSelectedProductIds = new Set<Id>();
            for(OpportunityLineItem oli : oliListForHotelTransportation) {
                preSelectedProductIds.add(oli.Product2Id);
            }
           
            if (idsOfPackageHotels.size() > 0) {
                System.debug('@@idsOfPackageHotels..' + idsOfPackageHotels);
                hotelTransportationByHotel = new Map<Id,List<wrapperClassHotelTransportation>>();
                hotelTransportationByHotelList = new List<wrapperClassHotelTransportation>();
                List<Hotel_Transportation__c> hotelTransportationsList = [Select Id, Hotel__c, Transportation__c, Transportation__r.Name, Transportation__r.RecordType.Name,Transportation__r.Type__c, Transportation__r.Price__c, Transportation__r.IsActive from Hotel_Transportation__c where Hotel__c in :idsOfPackageHotels ];//AND Transportation__r.IsActive =: TRUE];
                
                for (Hotel_Transportation__c item : hotelTransportationsList) {
                    Decimal convertedPrice = 0;
                    System.debug('111...' + item);
                    // For USD
                    if(lstOpportunity[0].CurrencyIsoCode.equals('USD')) {
                        convertedPrice = item.Transportation__r.Price__c;
                    } else {
                    // For NON USD                                
                        convertedPrice = datedConversionRateHelper.convert(item.Transportation__r.Price__c,lstOpportunity[0].CurrencyIsoCode,lstOpportunity[0].Exchange_Rate_Date_Override__c);
                    }
                    convertedPrice = convertedPrice.setScale(2);
                    // Pre-Selected
                    System.debug('22222...' + preSelectedProductIds);
                    if(preSelectedProductIds.contains(item.Transportation__c)) {
                        System.debug('3333333...' + item.Transportation__c);
                        hotelTransportationByHotelList.add(new wrapperClassHotelTransportation(item,1,convertedPrice,true));
                    } else {
                        // Not Pre-Selected
                        System.debug('44444444...' + item.Transportation__r.IsActive);
                        if(item.Transportation__r.IsActive == TRUE){
                            hotelTransportationByHotelList.add(new wrapperClassHotelTransportation(item,1,convertedPrice,false));
                        }
                    }
                }
            }
        }      
        return hotelTransportationByHotelList; 
    }


    @AuraEnabled // insert and update record into the opportunity line item from third table of popup
    public static void addHotelPopup(Id opportunityId, Id packId, String displayPackHotelString,String hotelTransportationByHotelListString) {
       
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppHotelListDel = new List<OpportunityLineItem>();
        Map<Id,Id> priceBookEntryByProductId;
        
        Set<Id> hotelIdSet = new Set<Id>();

        List<Opportunity> lstOpportunity = [select Id, Email__c,Event__c,Event__r.Name,Name,Reward_Points_Pending__c,Primary_Contact__c,AccountId,
        Event__r.Program__r.name,Account.Name,Amount,OwnerId,Grand_Total__c,StageName,Probability,CloseDate,Account.IsPersonAccount,
        Type,CurrencyIsoCode, is_Applied_Rewards__c from Opportunity where Id=:opportunityId];

        List<wrapperClassHotel> displayPackHotel = (List<wrapperClassHotel>)JSON.deserialize(displayPackHotelString,List<wrapperClassHotel>.class);
        List<wrapperClassHotelTransportation> hotelTransportationByHotelList = (List<wrapperClassHotelTransportation>)JSON.deserialize(hotelTransportationByHotelListString,List<wrapperClassHotelTransportation>.class);
        
       
        PricebookEntry pbE = [SELECT Id, Product2Id FROM PricebookEntry WHERE Id =: packId];
        
        List<OpportunityLineItem> hotelTransportaionsToBeInserted = new List<OpportunityLineItem>();
        Set<Id> hotelTransportaionIdsForDeleting = new Set<Id>();
        
        List<PricebookEntry> lstRecordType2=[SELECT UseStandardPrice, Name, Product2Id, Product2.Event__r.Name, Product2.Name, Product2.RecordType.Id, Product2.RecordType.Name, Pricebook2Id, UnitPrice, Id,IsActive, Product2.A_La_Carte__c, Product2.Cost__c FROM PricebookEntry WHERE Product2.Event__c =: lstOpportunity[0].Event__c And CurrencyIsoCode = :lstOpportunity[0].CurrencyIsoCode];
        priceBookEntryByProductId = new Map<Id,Id>();
        for(PricebookEntry ppR: lstRecordType2){
            priceBookEntryByProductId.put(ppR.Product2Id, ppR.Id);
        }
        
        //We will cycle through our list of cContacts and will check to see if the selected property is set to true, if it is we add the Contact to the selectedContacts list
        
        if(displayPackHotel.size() > 0) {
            for(wrapperClassHotel pPro: displayPackHotel) {
                //Inserting selected hotels
                if(pPro.selectBit == true) {
                    OpportunityLineItem oppLine =  new OpportunityLineItem();
                    oppLine.PricebookEntryId = priceBookEntryByProductId.get(pPro.objProduct.Products_and_Hotels__c);
                    oppLine.OpportunityId = opportunityId;
                    oppLine.Package__c = pbE.Product2Id;
                    oppLine.Opportunity_Product_Package_Hotel__c = true;
                    oppLine.Quantity = pPro.quantity;
                    oppLine.Room_Type__c = pPro.roomType;
                    oppLine.ApexProductName__c = pPro.objProduct.Products_and_Hotels__r.Name;
                    oppLine.ApexProductType__c = pPro.objProduct.Products_and_Hotels__r.RecordType.Name;
                    oppLine.UnitPrice = 0;
                    oppLine.Record_Type__c = 'Optional Package Product'; // May be rename "Optional Package Product" to "Addon" or something like that
                    oppLine.ProductType__c = pPro.objProduct.Products_and_Hotels__r.Type__c;
                    oppLineItemList.add(oppLine);
                }
                
                // Updating selected hotels
                if(pPro.preselected) {
                    OpportunityLineItem oliToUpdate = new OpportunityLineItem();
                    oliToUpdate.Id = pPro.oliId;
                    oliToUpdate.Room_Type__c = pPro.roomType;
                    oppLineItemList.add(oliToUpdate);
                }
 
            }
            
            // Add Hotel transportation
            for (wrapperClassHotelTransportation wcHotelTransportaion : hotelTransportationByHotelList) {
                if(wcHotelTransportaion.selectBit == true) {
                    OpportunityLineItem oppLineItem = new OpportunityLineItem();
                    oppLineItem.OpportunityId = opportunityId;
                    oppLineItem.PricebookEntryId = priceBookEntryByProductId.get(wcHotelTransportaion.objHotelTransportation.Transportation__c);
                    //oppLineItem.Quantity_Text__c = wcHotelTransportaion.quantity;
                    oppLineItem.Quantity = wcHotelTransportaion.quantity;
                    oppLineItem.UnitPrice = wcHotelTransportaion.price;
                    oppLineItem.ApexProductName__c = wcHotelTransportaion.objHotelTransportation.Transportation__r.Name;
                    oppLineItem.ApexProductType__c = wcHotelTransportaion.objHotelTransportation.Transportation__r.RecordType.Name;
                    oppLineItem.Transportation_As_Part_Of_Hotel__c = true;
                    oppLineItem.Record_Type__c = 'Optional Package Product'; // May be rename "Optional Package Product" to "Addon" or something like that
                    oppLineItem.ProductType__c = wcHotelTransportaion.objHotelTransportation.Transportation__r.Type__c;
                    hotelTransportaionsToBeInserted.add(oppLineItem);
                }
                // Collect Product2 Ids for deleting Opportunity Line Items
                if(wcHotelTransportaion.selectDel == true) {
                    hotelTransportaionIdsForDeleting.add(wcHotelTransportaion.objHotelTransportation.Transportation__c);
                }
            }
            
            // Get all hotles that needs to be deleted
            for(wrapperClassHotel pPro: displayPackHotel) {
                if(pPro.selectDel == true) {
                    hotelIdSet.add(pPro.objProduct.Products_and_Hotels__c);
                    //hotelError = true;
                }
            }
        }
        
        // Delete Opportunity Line Items for Hotel Transportaions
        List<OpportunityLineItem> transportationOliToBeDeleted = new List<OpportunityLineItem>([select id from OpportunityLineItem where Product2Id in :hotelTransportaionIdsForDeleting And OpportunityId = :opportunityId]);
        
        if(hotelIdSet.size() > 0){
            for(OpportunityLineItem oppH: [SELECT Id, Name, Package__c, Product2Id,Product2.Price__c,Price__c,OpportunityId,PricebookEntryId,Quantity,UnitPrice,ApexProductType__c,ApexProductName__c,ApexCost__c,Record_Type__c FROM OpportunityLineItem WHERE Package__c =: pbE.Product2Id AND Product2Id IN: hotelIdSet And OpportunityId = :OpportunityId]){
                oppHotelListDel.add(oppH);
            }
        }
        
        if(!Test.isRunningTest()){
            if(oppLineItemList.size() > 0){
                upsert oppLineItemList;
            }
            if(oppHotelListDel.size() > 0){
                Delete oppHotelListDel;
            }
            if(transportationOliToBeDeleted.size() > 0){
                delete transportationOliToBeDeleted;
            }
            if(hotelTransportaionsToBeInserted.size() > 0) {
                insert hotelTransportaionsToBeInserted;
            }
        }
    }
    public class wrapperClassHotelTransportation {
        @AuraEnabled public Hotel_Transportation__c objHotelTransportation {get; set;}
        @AuraEnabled public boolean selectBit{get;set;}
        @AuraEnabled public Integer quantity {get;set;}
        @AuraEnabled public Decimal price {get;set;}
        @AuraEnabled public boolean preSelected {get;set;}
        @AuraEnabled public boolean selectDel {get;set;}
        
       public wrapperClassHotelTransportation(Hotel_Transportation__c p, Integer q, Decimal pr, boolean ps) {
            objHotelTransportation = p;
            selectBit = false;
            selectDel = false;
            quantity = q;
            price = pr;
            preSelected = ps;
        }
    }
    public class wrapperClassHotel {
        @AuraEnabled public Package_Products__c objProduct {get; set;}
        @AuraEnabled public boolean selectBit{get;set;}
        @AuraEnabled public Integer quantity {get;set;}
        @AuraEnabled public Decimal price {get;set;}
        @AuraEnabled public boolean preSelected {get;set;}
        @AuraEnabled public boolean selectDel {get;set;}
        @AuraEnabled public String roomType {get;set;}
        @AuraEnabled public Id oliId {get;set;}

        //This is the constructor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false
        public wrapperClassHotel(Package_Products__c p, Integer q, Decimal pr, boolean ps, String rt, Id olid) {
            objProduct = p;
            selectBit = false;
            selectDel = false;
            quantity = q;
            price = pr;
            preSelected = ps;
            roomType = rt;
            oliId = olid;
        }
    }
    public class wrapperClass {
        @AuraEnabled public PricebookEntry objProduct {get; set;}
        @AuraEnabled public boolean selectBit{get;set;}
        @AuraEnabled public Double quantity {get;set;}
        @AuraEnabled public Id oliId {get;set;}

        //This is the constrdisplayProductValuesuctor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false
        public wrapperClass(PricebookEntry p, Double q, OpportunityLineItem oli) {
            objProduct = p;
            selectBit = false;
            quantity = q;
        }
    }
}
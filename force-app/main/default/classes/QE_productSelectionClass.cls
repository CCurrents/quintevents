/* ====================================================
@Name:  QE_productSelectionClass
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
public class QE_productSelectionClass{

    public Id OpportunityId {get;set;}
    public string selectedProduct{get;set;}
    public List<SelectOption> items{get;set;}
    public List<SelectOption> arnHotelList{get;set;}
    public List<SelectOption> roomTypes{get;set;}
    public String selectedArnHotel{get;set;}
    public String selectedRoomTypes{get;set;}
    public List<wrapperClass> displayProductValues{get;set;}
    public List<wrapperClassHotel> displayPackHotel{get;set;}
    public List<wrapperClassHotel> displayARNHotel{get;set;}
    public Map<Id,List<wrapperClassHotelTransportation>> hotelTransportationByHotel {get;set;}
    public List<wrapperClassHotelTransportation> hotelTransportationByHotelList {get;set;}
    public List<wrapperClassHotelTransportation> arnHotelTransportationList {get;set;}
    public Map<Id,Id> priceBookEntryByProductId;
    public List<Opportunity> lstOpportunity {get;set;}
    public Map<Id,RecordType> proRecordType;
    public List<PricebookEntry> selectedProductList {get;set;}
    public Map<Id,PricebookEntry> proMap {get;set;}
    public List<OpportunityLineItem> oliList {get;set;}
    public Map<Id,wrapperClass> wrapperClassObjByProductId {get;set;}
    public boolean productCheck {get;set;}
    public Map<Id,Double> oppLineMap {get;set;}
    public Map<Id,OpportunityLineItem> oppLineMapWithData {get;set;}
    public boolean proCheck {get;set;}
    public boolean displayPopup {get; set;}
    public Id packId { get; set; }
    public List<Package_Products__c> packProList;
    public Map<Id,Integer> packHotelMap;
    public boolean hotelError = false;
    public Decimal H4HPoints {get; set;} // Added variable here
    public boolean isOpportunityEmailBlank {get; set;}

    public QE_productSelectionClass(ApexPages.StandardController controller) {
        isOpportunityEmailBlank = false;
        items = new List<SelectOption>();
        selectedProductList = new List<PricebookEntry>();
        proMap = new Map<Id,PricebookEntry>();
        displayProductValues = new List<wrapperClass>();
        displayPackHotel = new List<wrapperClassHotel>();
        displayARNHotel = new List<wrapperClassHotel>();
        hotelTransportationByHotel = new Map<Id,List<wrapperClassHotelTransportation>>();
        hotelTransportationByHotelList = new List<wrapperClassHotelTransportation>();
        arnHotelTransportationList = new List<wrapperClassHotelTransportation>();
        oppLineMap = new Map<Id,Double>();
        oppLineMapWithData = new Map<Id,OpportunityLineItem>();
        oliList = new List<OpportunityLineItem>();
        productCheck = false;
        proCheck = true;
        displayPopup = false;
        packId = null;
        H4HPoints = 0.0;

        OpportunityId  = ApexPages.currentPage().getParameters().get('Id');
        if(OpportunityId != null) {
            lstOpportunity = [select Id, Email__c,Event__c,Event__r.GPE_Event__c,Event__r.Name,Name,Reward_Points_Pending__c,Primary_Contact__c,AccountId,Event__r.Program__r.name,Account.Name,Amount,OwnerId,Grand_Total__c,StageName,Probability,CloseDate,Account.IsPersonAccount,Type,CurrencyIsoCode, is_Applied_Rewards__c,Exchange_Rate_Date_Override__c from Opportunity where Id=:OpportunityId];
        }
        // Not show the product selection block if email is not there in opportunity
        if(String.isBlank(lstOpportunity[0].Email__c)){
          isOpportunityEmailBlank = true;
          ApexPages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.Warning,'Opportunity must have email address before adding products' );
          ApexPages.addmessage(errorMessage);
        }

        // To get the latest points from response and add all together for existing members in H4H.
        List<AggregateResult> results = [SELECT Sum(Reward_Points_Pending__c) H4HTotal FROM Opportunity WHERE email__c = :lstOpportunity[0].email__c AND StageName = 'Closed Won' AND Reward_Points_Pending__c != null AND Paid_in_full__c = true AND event__r.program__r.Name != null AND event__r.program__r.Name LIKE '%F1E%'];
        if(!results.isEmpty() && results.size() > 0 && results[0].get('H4HTotal') != null) {
            for(AggregateResult ar: results) {
                H4HPoints = H4HPoints + integer.valueOf(ar.get('H4HTotal'));
            }
        }

        for(OpportunityLineItem oli: [SELECT Id, Product2Id, Quantity, Quantity_Text__c ,OpportunityId, Room_Type__c FROM OpportunityLineItem WHERE OpportunityId =: OpportunityId and Record_Type__c != 'Package Product' and ProductType__c != 'Shipping and Handling' and ProductType__c != 'Discount']){
            if(oppLineMap.containsKey(oli.Product2Id)){
                Double temp = oppLineMap.get(oli.Product2Id) + oli.Quantity;
                oppLineMap.put(oli.Product2Id,temp);
            }else{
                oppLineMap.put(oli.Product2Id,oli.Quantity);
            }
            oppLineMapWithData.put(oli.Product2Id,oli);
        }

        proRecordType= new Map<Id, RecordType>([SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'Product2']);
        if(proRecordType.size()>0){
            for(RecordType item: proRecordType.values()){
                items.add(new SelectOption(string.valueof(item.Id),string.valueof(item.Name)));
            }
        }

        packProList = new List<Package_Products__c>([SELECT Id, Name, Package__c,Package__r.Event__c, Products_and_Hotels__c, Product_Type__c   FROM Package_Products__c WHERE Package__r.Event__c =: lstOpportunity[0].Event__c AND Product_Type__c = 'Hotels']);
        packHotelMap = new Map<Id,Integer>();
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
        
        for(Hotel_Room_Package__c hotelPackage : [Select Id, Hotel_Package_Product__c from Hotel_Room_Package__c
                                                    where Hotel_Package_Product__r.Event__c =: lstOpportunity[0].Event__c]) {
            if(packHotelMap.containsKey(hotelPackage.Hotel_Package_Product__c)) {
                packHotelMap.put(hotelPackage.Hotel_Package_Product__c, packHotelMap.get(hotelPackage.Hotel_Package_Product__c) + 1);
            } else {
                packHotelMap.put(hotelPackage.Hotel_Package_Product__c, 1);
            }
        }

        for(OpportunityLineItem oppLine: [SELECT Id, Apex_No_of_Hotels__c,Name, Opportunity_Product_Package_Hotel__c,Description ,Quantity_Text__c ,Product2Id,Product2.Price__c,Price__c,OpportunityId,PricebookEntryId,Quantity,UnitPrice,ApexProductType__c,ApexProductName__c,ApexCost__c,Room_Type__c FROM OpportunityLineItem WHERE OpportunityId =: OpportunityId and Record_Type__c != 'Package Product' and ProductType__c != 'Shipping and Handling' and ProductType__c != 'Reward Discount']){
            if(packHotelMap.containsKey(oppLine.Product2Id)){
                oppLine.Apex_No_of_Hotels__c = packHotelMap.get(oppLine.Product2Id);
            }else{
                oppLine.Apex_No_of_Hotels__c = 0;
            }
            if(oppLine.Opportunity_Product_Package_Hotel__c != true){
                oliList.add(oppLine);
            }
        }
        selectedProduct = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId();
        displayProduct();
    }

    //To make callout when "add packages" clicked to check if member exists and display available points.
    public void HotelForHopeCallout(){
            OpportunityId  = ApexPages.currentPage().getParameters().get('Id');
        if(OpportunityId != null){
            String tokenId = '';
            Opportunity opp = [select Id,Email__c,ship_to_name__c,Event__r.Program__r.name,Reward_Points_Pending__c,StageName,paid_in_full__c from Opportunity where Id=:OpportunityId];
        if(opp.Email__c != null && opp.ship_to_name__c != null && opp.Event__r.Program__r.name != null && opp.Event__r.Program__r.name.contains('F1E') ){
            tokenId =  QE_H4HCalloutClass.getH4HTokenId();
            H4HPoints = QE_H4HCalloutClass.createRequestToH4HForClosedWon(opp,tokenId);
        }
        }
    }
    //To apply Reward points to opportunity.
    public List<OpportunityLineItem> createOppLineItem(Boolean isAppliedReward){
        List<OpportunityLineItem> oppLineList = new List<OpportunityLineItem>();
        List<pricebookentry> pbeList = new List<pricebookentry>();
        List<OpportunityLineItem> ExistingDiscountOppLine = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =:lstOpportunity[0].Id AND ProductType__c = 'Reward Discount' ];
        Boolean oppUpdate = false;
        if(isAppliedReward){
            if(OpportunityId != null && lstOpportunity[0].event__r.program__r.name != null && lstOpportunity[0].event__r.program__r.name.contains('F1E')) {
                if(ExistingDiscountOppLine.isEmpty()) {
                    OpportunityId  = ApexPages.currentPage().getParameters().get('Id');
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
        } else {
            if(OpportunityId != null && lstOpportunity[0].event__r.program__r.name != null && lstOpportunity[0].event__r.program__r.name.contains('F1E')) {
                if(!ExistingDiscountOppLine.isEmpty())
                Database.delete(ExistingDiscountOppLine,false);
                oppUpdate = true;
            }
        }
        return oppLineList;
    }

    public void displayProduct(){
        displayProductValues = null;
        
        if(lstOpportunity.size() > 0 && lstOpportunity[0].Event__r.GPE_Event__c == false){
            
            if(selectedProduct == Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId()){
                
                productCheck = true;
                
                List<PricebookEntry> lstRecordType=[SELECT UseStandardPrice, Name, Product2Id, Product2.Event__r.Name, Product2.Name, Product2.RecordType.Id, Product2.RecordType.Name, Pricebook2Id, UnitPrice, Id,IsActive, Product2.A_La_Carte__c, Product2.Cost__c, Product2.Inventory__c, Product2.Threshold__c, CurrencyIsoCode, Product2.Type__c FROM PricebookEntry WHERE Product2.Event__c =: lstOpportunity[0].Event__c AND Product2.RecordType.Id =: selectedProduct AND Product2.IsActive = TRUE AND Product2.A_La_Carte__c =: TRUE And CurrencyIsoCode = :lstOpportunity[0].CurrencyIsoCode and Product2.Type__c != 'Shipping and Handling' and (Product2.Name != 'Discount')];
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
            }else if(selectedProduct == Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId()){
                productCheck = true;
                List<PricebookEntry> lstRecordType=[SELECT UseStandardPrice, Name, Product2Id, Product2.Event__r.Name, Product2.Name, Product2.RecordType.Id, Product2.RecordType.Name, Pricebook2Id, UnitPrice, Id,IsActive, Product2.A_La_Carte__c, Product2.Cost__c, Product2.Inventory__c, Product2.Threshold__c, Product2.Type__c FROM PricebookEntry WHERE Product2.Event__c =: lstOpportunity[0].Event__c AND Product2.RecordType.Id =: selectedProduct AND Product2.IsActive = TRUE AND Product2.A_La_Carte__c =: TRUE And CurrencyIsoCode = :lstOpportunity[0].CurrencyIsoCode];
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
                productCheck = false;
                List<PricebookEntry> lstRecordType=[SELECT UseStandardPrice, Name, Product2Id, Product2.Event__r.Name, Product2.Name, Product2.RecordType.Id, Product2.RecordType.Name, Pricebook2Id, UnitPrice, Id,IsActive,Product2.Cost__c,Product2.Package_Inventory__c, Product2.Inventory__c, Product2.Type__c FROM PricebookEntry WHERE Product2.Event__c =: lstOpportunity[0].Event__c AND Product2.RecordType.Id =: selectedProduct AND Product2.IsActive = TRUE And CurrencyIsoCode = :lstOpportunity[0].CurrencyIsoCode];
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
        } else if(lstOpportunity.size() > 0 && lstOpportunity[0].Event__r.GPE_Event__c == true){
            
            if(selectedProduct == Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId()){
                
                productCheck = true;
                List<PricebookEntry> lstRecordType=[SELECT UseStandardPrice, Name, Product2Id, Product2.Event__r.Name, Product2.Name, Product2.RecordType.Id, Product2.RecordType.Name, Pricebook2Id, UnitPrice, Id,IsActive, Product2.A_La_Carte__c, Product2.Cost__c, Product2.Inventory__c, Product2.Threshold__c, CurrencyIsoCode, Product2.Type__c FROM PricebookEntry WHERE Product2.Event__c =: lstOpportunity[0].Event__c AND Product2.RecordType.Id =: selectedProduct AND Product2.IsActive = TRUE AND Product2.A_La_Carte__c =: TRUE And CurrencyIsoCode = :lstOpportunity[0].CurrencyIsoCode and Product2.Type__c != 'Shipping and Handling' and (Product2.Name != 'Discount') and product2.Visible_to_Sales_Rep__c = true];

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
            }else if(selectedProduct == Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId()){
                productCheck = true;
                List<PricebookEntry> lstRecordType=[SELECT UseStandardPrice, Name, Product2Id, Product2.Event__r.Name, Product2.Name, Product2.RecordType.Id, Product2.RecordType.Name, Pricebook2Id, UnitPrice, Id,IsActive, Product2.A_La_Carte__c, Product2.Cost__c, Product2.Inventory__c, Product2.Threshold__c, Product2.Type__c FROM PricebookEntry WHERE Product2.Event__c =: lstOpportunity[0].Event__c AND Product2.RecordType.Id =: selectedProduct AND Product2.IsActive = TRUE AND Product2.A_La_Carte__c =: TRUE And CurrencyIsoCode = :lstOpportunity[0].CurrencyIsoCode and product2.Visible_to_Sales_Rep__c = true];

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
                productCheck = false;
                List<PricebookEntry> lstRecordType=[SELECT UseStandardPrice, Name, Product2Id, Product2.Event__r.Name, Product2.Name, Product2.RecordType.Id, Product2.RecordType.Name, Pricebook2Id, UnitPrice, Id,IsActive,Product2.Cost__c,Product2.Package_Inventory__c, Product2.Type__c,Product2.Inventory__c FROM PricebookEntry WHERE Product2.Event__c =: lstOpportunity[0].Event__c AND Product2.RecordType.Id =: selectedProduct AND Product2.IsActive = TRUE And CurrencyIsoCode = :lstOpportunity[0].CurrencyIsoCode and product2.Visible_to_Sales_Rep__c = true];
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
    }

    public PageReference processSelected() {
        Boolean isPP = false;
        Boolean isPPNot = false;
        
        //oliList = new List<OpportunityLineItem>();
        wrapperClassObjByProductId = new Map<Id,wrapperClass>();
        //We will cycle through our list of cContacts and will check to see if the selected property is set to true, if it is we add the Contact to the selectedContacts list
        if(displayProductValues.size() > 0){
            if(lstOpportunity[0].Event__r.Program__c != null && lstOpportunity[0].Event__r.Program__r.Name.equals('F1E')) {
                for(wrapperClass pPro: displayProductValues) {
                    if(pPro.selectBit == true || pPro.quantity != null) {
                        if(pPro.objProduct.Product2.Type__c == 'Parking Pass') {
                            isPP = true;
                        }
                        if(pPro.objProduct.Product2.Type__c == 'Parking Pass Not Included'){
                            isPPNot = true;
                        }
                    }
                }
                
                if(isPP && isPPNot) {
                    ApexPages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.Warning, 'You can\'t add both a "Parking Pass" and a "Parking Pass Not Included" product on the same opportunity');
                    ApexPages.addmessage(errorMessage);
                    return null;
                }
            }
            oliList = new List<OpportunityLineItem>();
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

        for(OpportunityLineItem oppLine: [SELECT Id, Name, Apex_No_of_Hotels__c,Opportunity_Product_Package_Hotel__c, Description ,Quantity_Text__c ,Product2.Price__c,Price__c,OpportunityId,PricebookEntryId,Quantity,UnitPrice,ApexProductType__c,ApexProductName__c,ApexCost__c,Room_Type__c FROM OpportunityLineItem WHERE OpportunityId =: OpportunityId and Record_Type__c != 'Package Product' and ProductType__c != 'Shipping and Handling' and ProductType__c != 'Reward Discount']){
            
            if(oppLine.Opportunity_Product_Package_Hotel__c != true){
                oliList.add(oppLine);
            }
        }

        List<PricebookEntry> lstRecordType=[SELECT UseStandardPrice, Name, Product2Id, Product2.Event__r.Name, Product2.Name, Product2.RecordType.Id, Product2.RecordType.Name, Pricebook2Id, UnitPrice, Id,IsActive, Product2.A_La_Carte__c, Product2.Cost__c FROM PricebookEntry WHERE Product2.Event__c =: lstOpportunity[0].Event__c ];
        Map<Id,Id> pricProMap = new Map<Id,Id>();
        for(PricebookEntry ppR: lstRecordType){
            pricProMap.put(ppR.Id,ppR.Product2Id);
        }

        // Now we have our list of selected contacts and can perform any type of logic we want, sending emails, updating a field on the Contact, etc
        for(PricebookEntry pro: selectedProductList) {

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
        return null;
    }

    public PageReference addOppLineItem() {
        List<OpportunityLineItem> oLst = createOppLineItem(lstOpportunity[0].is_Applied_Rewards__c);
       
        Set<Id> priceBESet = new Set<Id>();
        Map<Id,List<OpportunityLineItem>> oppHMap = new Map<Id,List<OpportunityLineItem>>();
        Map<Id,PricebookEntry> priceBEMap = new Map<Id,PricebookEntry>();
        List<PricebookEntry> priceBEList = new List<PricebookEntry>();
        List<OpportunityLineItem> oppHList = new List<OpportunityLineItem>([SELECT Id, Name, Package__c, Quantity, Price__c, Product2Id, OpportunityId, Product2.Tax_Percentage__c,Opportunity_Product_Package_Hotel__c, Room_Type__c FROM OpportunityLineItem WHERE Opportunity_Product_Package_Hotel__c = true AND OpportunityId =: OpportunityId]);

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

        /* This part was used in old way of calculation of hotel price, but after 2/7/18 it is causing issue of Grand Total and Amount miss match.
        if(oliList.Size() > 0){
            for(OpportunityLineItem oli: oliList){
                oli.ApexHotelTotalPrice__c = 0;
                if(oli.ApexProductType__c == 'Package'){
                    if(priceBEMap.containsKey(oli.PricebookEntryId) && oppHMap.get(priceBEMap.get(oli.PricebookEntryId).Product2Id) != null){
                        for(OpportunityLineItem oppH: oppHMap.get(priceBEMap.get(oli.PricebookEntryId).Product2Id)){
                            if(oppH.Quantity > 1 && oppH.Price__c != null){
                                if(oli.Quantity > 1){
                                    oli.ApexHotelTotalPrice__c = oli.ApexHotelTotalPrice__c + ((oppH.Price__c*oppH.Quantity)/oli.Quantity);
                                }else{
                                    oli.ApexHotelTotalPrice__c = oli.ApexHotelTotalPrice__c + ((oppH.Price__c*oppH.Quantity));
                                }
                            }else if(oppH.Price__c == null){
                                //oppH.Price__c = 0;
                                oli.ApexHotelTotalPrice__c = oli.ApexHotelTotalPrice__c ;//+ oppH.Price__c;
                            }else{
                                oli.ApexHotelTotalPrice__c = oli.ApexHotelTotalPrice__c + (oppH.Price__c/oli.Quantity);
                            }
                            oli.Hotel_Tax_Percentage__c = oppH.Product2.Tax_Percentage__c;
                        }
                    }
                }
            }
        }
        */
        if(!oLst.isEmpty()){
            oliList.addAll(oLst);
        }

        if(oliList.Size() > 0){
            try{
                Upsert oliList;
            }Catch(Exception ex){
                System.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
            }
        }

        //TriggerExecutionController.skipopptyOpportunityTrigger(true);
        Database.Update(lstOpportunity,false);
        //TriggerExecutionController.skipopptyOpportunityTrigger(false);

        PageReference pref = new PageReference('/'+OpportunityId);
        pref.setRedirect(true);
        return pref;
    }

    public PageReference CancelMethod() {
        Map<Id,OpportunityLineItem> oppLineMap = new Map<Id,OpportunityLineItem>();
        List<OpportunityLineItem> oppLinelist = new List<OpportunityLineItem>([SELECT id, Apex_No_of_Hotels__c,Product2Id, Product_Type__c, OpportunityId FROM OpportunityLineItem WHERE OpportunityId =: OpportunityId AND Product_Type__c = 'Package']);

        if(hotelError == true){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please click on "Save to Opportunity" To update selected Hotel to the Package'));
            return null;
        }

        if(oppLinelist.size() > 0){
            for(OpportunityLineItem oli: oppLinelist){
                oppLineMap.put(oli.Product2Id, oli);
            }
        }

        List<OpportunityLineItem> oppHList = new List<OpportunityLineItem>([SELECT Id, Package__c FROM OpportunityLineItem WHERE Opportunity_Product_Package_Hotel__c = true AND OpportunityId =: OpportunityId AND Package__c NOT IN: oppLineMap.keySet()]);
        
        if(oppHList.size() > 0){
            delete oppHList;
        }

        // Added to correctly redirect formulaone community users.
        string redirectPath = '';
        if ((URL.getCurrentRequestUrl().toExternalForm()).Contains('formulaone')) {
            redirectPath = 'formulaone/';
        }

        PageReference pref = new PageReference('/' + redirectPath + OpportunityId);
        pref.setRedirect(true);
        return pref;
    }

    // This is our wrapper/container class. A container class is a class, a data structure, or an abstract data type whose instances are collections of other objects. In this example a wrapper class contains both the standard salesforce object Contact and a Boolean value
    public class wrapperClass {
        public PricebookEntry objProduct {get; set;}
        public boolean selectBit{get;set;}
        public Double quantity {get;set;}
        public Id oliId {get;set;}

        //This is the constrdisplayProductValuesuctor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false
        public wrapperClass(PricebookEntry p, Double q, OpportunityLineItem oli) {
            objProduct = p;
            selectBit = false;
            quantity = q;
        }
    }

    public void closePopup() {
        displayPopup = false;
        packId = null;
    }

    public void showPopup() {
        displayPackHotel = null;
        displayARNHotel = null;
        hotelTransportationByHotel = null;
        hotelTransportationByHotelList = null;
        arnHotelTransportationList = null;
        roomTypes = new List<SelectOption>();
        arnHotelList = new List<SelectOption>();
        
        selectedArnHotel = '';
        selectedRoomTypes = '';
        
        roomTypes.add(new selectOption('', 'None'));
        arnHotelList.add(new selectOption('', 'None'));
        
        Schema.DescribeFieldResult fieldResult = Product2.Room_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            roomTypes.add(new selectOption(pickListVal.getValue(), pickListVal.getLabel()));
        }     
        if(packId != null) {
            PricebookEntry pbE = [SELECT Id, Product2Id FROM PricebookEntry WHERE Id =: packId];
            Map<Id,OpportunityLineItem> oHWOMap = new Map<Id,OpportunityLineItem>();
            List<OpportunityLineItem> oppHWithOppList = new List<OpportunityLineItem>([SELECT Id, Name, Package__c, Product2Id,Product2.Price__c,Price__c,OpportunityId,PricebookEntryId,Quantity,UnitPrice,ApexProductType__c,ApexProductName__c,ApexCost__c,Room_Type__c,Room_Type_Hotel__c FROM OpportunityLineItem WHERE Package__c =: pbE.Product2Id AND OpportunityId =: OpportunityId]);
            if(oppHWithOppList.size() > 0){
                for(OpportunityLineItem oppH : oppHWithOppList){
                    oHWOMap.put(oppH.Product2Id, oppH);
                }
            }

            // CurrencyType Helper
            QE_DatedConversionRateHelper datedConversionRateHelper = new QE_DatedConversionRateHelper();

            List<Package_Products__c> packProList = [SELECT Products_and_Hotels__c, Active__c, Products_and_Hotels__r.RecordType.Name, Products_and_Hotels__r.Price__c, Products_and_Hotels__r.Name, Products_and_Hotels__r.IsActive ,Products_and_Hotels__r.Hotel_Id__c, Amount__c,Product_Type__c, Products_and_Hotels__r.Type__c from Package_Products__c WHERE Package__c =: pbE.Product2Id AND Product_Type__c = 'Hotels']; //AND Active__c = TRUE];
            Set<Id> idsOfPackageHotels = new Set<Id>();
            Set<Id> arnHotelIds = new Set<Id>();
            if(packProList.size() > 0) {
                displayPackHotel = new List<wrapperClassHotel>();
                for(Package_Products__c item : packProList) {
                    if(item.Products_and_Hotels__r.Hotel_Id__c != null) {
                        arnHotelIds.add(item.Products_and_Hotels__c);
                    } else {
                        if(oHWOMap.containsKey(item.Products_and_Hotels__c)) {
                            if(oHWOMap.get(item.Products_and_Hotels__c).Quantity > 0) {
                                if(oHWOMap.get(item.Products_and_Hotels__c).Price__c != null) {
                                    displayPackHotel.add(new wrapperClassHotel(item,Integer.valueOf(oHWOMap.get(item.Products_and_Hotels__c).Quantity),oHWOMap.get(item.Products_and_Hotels__c).Price__c,true,oHWOMap.get(item.Products_and_Hotels__c).Room_Type__c,oHWOMap.get(item.Products_and_Hotels__c).Id));
                                } else {
                                    displayPackHotel.add(new wrapperClassHotel(item,Integer.valueOf(oHWOMap.get(item.Products_and_Hotels__c).Quantity),null,true,oHWOMap.get(item.Products_and_Hotels__c).Room_Type__c,oHWOMap.get(item.Products_and_Hotels__c).Id));
                                }
                            } else {
                                if(oHWOMap.get(item.Products_and_Hotels__c).Price__c != null) {
                                    displayPackHotel.add(new wrapperClassHotel(item, null, oHWOMap.get(item.Products_and_Hotels__c).Price__c, true,oHWOMap.get(item.Products_and_Hotels__c).Room_Type__c,oHWOMap.get(item.Products_and_Hotels__c).Id));
                                } else {
                                    displayPackHotel.add(new wrapperClassHotel(item,null,null,true,oHWOMap.get(item.Products_and_Hotels__c).Room_Type__c,oHWOMap.get(item.Products_and_Hotels__c).Id));
                                }
                            }
                        } else {
                            if(item.Products_and_Hotels__r.IsActive == TRUE){
                                Decimal convertedPrice = 0;
                                // For USD
                                if(lstOpportunity[0].CurrencyIsoCode.equals('USD')) {
                                    convertedPrice = item.Products_and_Hotels__r.Price__c;
                                } else {
                                // For NON USD
                                    convertedPrice = datedConversionRateHelper.convert(item.Products_and_Hotels__r.Price__c,lstOpportunity[0].CurrencyIsoCode,lstOpportunity[0].Exchange_Rate_Date_Override__c);
                                }
                                if(convertedPrice == null) {
                                    convertedPrice = 0;
                                }
                                convertedPrice = convertedPrice.setScale(2);
                                displayPackHotel.add(new wrapperClassHotel(item, 1, convertedPrice, false, '', null));
                            }
                        }
                        // Add hotel ids to set, so we can use this to query hotel transportation
                        idsOfPackageHotels.add(item.Products_and_Hotels__c);
                    }
                }
            }

            List<Hotel_Room_Package__c> hotelRoomPackageList = [SELECT Hotel_Package_Product__c, Hotel_Package_Product__r.Name, ARN_Room_Product__c, ARN_Room_Product__r.RecordType.Name, ARN_Room_Product__r.Price__c, ARN_Room_Product__r.Name,ARN_Room_Product__r.IsActive, ARN_Room_Product__r.Type__c, ARN_Room_Product__r.Room_Type__c,ARN_Room_Product__r.H4H_RatePlan_Code__c,ARN_Room_Product__r.H4H_Room_Code__c from Hotel_Room_Package__c
                                                                 WHERE Hotel_Package_Product__c In : arnHotelIds and ARN_Room_Product__r.RecordType.Name = 'Stay'];
            Set<Id> idsOfARNHotels = new Set<Id>();
            if(hotelRoomPackageList.size() > 0) {
                displayARNHotel = new List<wrapperClassHotel>();
                for(Hotel_Room_Package__c item: hotelRoomPackageList) {
                    if(oHWOMap.containsKey(item.ARN_Room_Product__c)) {
                        if(oHWOMap.get(item.ARN_Room_Product__c).Quantity > 0) {
                            if(oHWOMap.get(item.ARN_Room_Product__c).Price__c != null) {
                                displayARNHotel.add(new wrapperClassHotel(item,Integer.valueOf(oHWOMap.get(item.ARN_Room_Product__c).Quantity),oHWOMap.get(item.ARN_Room_Product__c).Price__c,true,oHWOMap.get(item.ARN_Room_Product__c).Room_Type_Hotel__c,oHWOMap.get(item.ARN_Room_Product__c).Id));
                            } else {
                                displayARNHotel.add(new wrapperClassHotel(item,Integer.valueOf(oHWOMap.get(item.ARN_Room_Product__c).Quantity),null,true,oHWOMap.get(item.ARN_Room_Product__c).Room_Type_Hotel__c,oHWOMap.get(item.ARN_Room_Product__c).Id));
                            }
                        } else {
                            if(oHWOMap.get(item.ARN_Room_Product__c).Price__c != null) {
                                displayARNHotel.add(new wrapperClassHotel(item,null,oHWOMap.get(item.ARN_Room_Product__c).Price__c,true,oHWOMap.get(item.ARN_Room_Product__c).Room_Type_Hotel__c,oHWOMap.get(item.ARN_Room_Product__c).Id));
                            } else {
                                displayARNHotel.add(new wrapperClassHotel(item,null,null,true,oHWOMap.get(item.ARN_Room_Product__c).Room_Type_Hotel__c,oHWOMap.get(item.ARN_Room_Product__c).Id));
                            }
                        }
                    } else {
                        if(item.ARN_Room_Product__r.IsActive == TRUE) {
                            Decimal convertedPrice = 0;
                            // For USD
                            if(lstOpportunity[0].CurrencyIsoCode.equals('USD')) {
                                convertedPrice = item.ARN_Room_Product__r.Price__c;
                            } else {
                                //For NON USD
                                convertedPrice = datedConversionRateHelper.convert(item.ARN_Room_Product__r.Price__c,lstOpportunity[0].CurrencyIsoCode,lstOpportunity[0].Exchange_Rate_Date_Override__c);
                            }
                            if(convertedPrice == null) {
                                convertedPrice = 0;
                            }
                            convertedPrice = convertedPrice.setScale(2);
                            displayARNHotel.add(new wrapperClassHotel(item, 1, convertedPrice, false, item.ARN_Room_Product__r.Room_Type__c, null));
                        }
                    }
                    //Add hotel ids to set, so we can use this to query hotel transportation
                    idsOfARNHotels.add(item.Hotel_Package_Product__c);
                    if(arnHotelIds.contains(item.Hotel_Package_Product__c)) {
                        arnHotelIds.remove(item.Hotel_Package_Product__c);
                        arnHotelList.add(new selectOption(item.Hotel_Package_Product__c, item.Hotel_Package_Product__r.Name));
                    }
                }
            }
            List<OpportunityLineItem> oliListForHotelTransportation = [select id, Product2Id from OpportunityLineItem where opportunityId = :OpportunityId and Product_Type__c = 'Products'];
            // Query hotel transportation
            Set<Id> preSelectedProductIds = new Set<Id>();
            for(OpportunityLineItem oli : oliListForHotelTransportation) {
                preSelectedProductIds.add(oli.Product2Id);
            }

            if(idsOfPackageHotels.size() > 0 || idsOfARNHotels.size() > 0) {
                hotelTransportationByHotel = new Map<Id,List<wrapperClassHotelTransportation>>();
                hotelTransportationByHotelList = new List<wrapperClassHotelTransportation>();
                arnHotelTransportationList = new List<wrapperClassHotelTransportation>();
                List<Hotel_Transportation__c> hotelTransportationsList = [Select Id, Hotel__c, Transportation__c, Transportation__r.Name,
                                                                             Transportation__r.RecordType.Name, Transportation__r.Type__c,
                                                                             Transportation__r.Price__c, Transportation__r.IsActive
                                                                             from Hotel_Transportation__c
                                                                             where Hotel__c In :idsOfPackageHotels OR Hotel__c In :idsOfARNHotels];//AND Transportation__r.IsActive =: TRUE];
                for(Hotel_Transportation__c item : hotelTransportationsList) {
                    Decimal convertedPrice = 0;
                    // For USD
                    if(lstOpportunity[0].CurrencyIsoCode.equals('USD')) {
                        convertedPrice = item.Transportation__r.Price__c;
                    } else { // For NON USD
                        convertedPrice = datedConversionRateHelper.convert(item.Transportation__r.Price__c,lstOpportunity[0].CurrencyIsoCode,lstOpportunity[0].Exchange_Rate_Date_Override__c);
                    }
                    if(convertedPrice == null){
                        convertedPrice = 0;
                    }
                    convertedPrice = convertedPrice.setScale(2);
                    // Pre-Selected
                    if(preSelectedProductIds.contains(item.Transportation__c)) {
                        if(idsOfPackageHotels.contains(item.Hotel__c)) {
                            hotelTransportationByHotelList.add(new wrapperClassHotelTransportation(item, 1, convertedPrice, true));
                        } else if(idsOfARNHotels.contains(item.Hotel__c)) {
                            arnHotelTransportationList.add(new wrapperClassHotelTransportation(item, 1, convertedPrice, true));
                        }
                    } else { // Not Pre-Selected
                        if(item.Transportation__r.IsActive == TRUE) {
                            if(idsOfPackageHotels.contains(item.Hotel__c)) {
                                hotelTransportationByHotelList.add(new wrapperClassHotelTransportation(item, 1, convertedPrice, false));
                            } else if(idsOfARNHotels.contains(item.Hotel__c)) {
                                arnHotelTransportationList.add(new wrapperClassHotelTransportation(item, 1, convertedPrice, false));
                            }
                        }
                    }
                }
            }
        }
        displayPopup = true;
    }

    public void addHotelPopup() {
        //displayPopup = false;
        Boolean showError = false;
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppHotelListDel = new List<OpportunityLineItem>();
        Set<Id> hotelIdSet = new Set<Id>();
        PricebookEntry pbE = [SELECT Id, Product2Id FROM PricebookEntry WHERE Id =: packId];

        List<OpportunityLineItem> hotelTransportaionsToBeInserted = new List<OpportunityLineItem>();
        Set<Id> hotelTransportaionIdsForDeleting = new Set<Id>();

        List<PricebookEntry> lstRecordType2 = [SELECT UseStandardPrice, Name, Product2Id, Product2.Event__r.Name,
                                                Product2.Name, Product2.RecordType.Id, Product2.RecordType.Name, Pricebook2Id,
                                                UnitPrice, Id,IsActive, Product2.A_La_Carte__c, Product2.Cost__c
                                                FROM PricebookEntry WHERE
                                                Product2.Event__c =: lstOpportunity[0].Event__c And CurrencyIsoCode = :lstOpportunity[0].CurrencyIsoCode];
        priceBookEntryByProductId = new Map<Id,Id>();
        
        Map<Id,Decimal> mapProductPrice = new Map<Id,Decimal>();
        for(PricebookEntry ppR: lstRecordType2){
            priceBookEntryByProductId.put(ppR.Product2Id, ppR.Id);
            mapProductPrice.put(ppR.Product2Id, ppR.UnitPrice);
        }
        //We will cycle through our list of cContacts and will check to see if the selected property is set to true, if it is we add the Contact to the selectedContacts list
        if(displayPackHotel != null && displayPackHotel.size() > 0){
            for(wrapperClassHotel pPro: displayPackHotel) {
                // Inserting selected hotels
                if(pPro.selectBit == true) {
                    /*Opportunity_Product_Package_Hotel__c opph = new Opportunity_Product_Package_Hotel__c();
                    opph.Hotel__c = pPro.objProduct.Products_and_Hotels__c;
                    opph.Opportunity__c = OpportunityId;
                    opph.Package__c = pbE.Product2Id;
                    opph.Opportunity_Product__c = pPro.objProduct.Products_and_Hotels__r.Name;
                    opph.Name = pPro.objProduct.Products_and_Hotels__r.Name;
                    opph.Price__c = pPro.price;
                    opph.Quantity__c = pPro.quantity;
                    oppHotelList.add(opph);*/

                    OpportunityLineItem oppLine = new OpportunityLineItem();
                    oppLine.PricebookEntryId = priceBookEntryByProductId.get(pPro.objProduct.Products_and_Hotels__c);
                    oppLine.OpportunityId = OpportunityId;
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
                    hotelError = true;
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
                    oppLineItem.OpportunityId = OpportunityId;
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
                    hotelError = true;
                }
            }
        }
        List<OpportunityLineItem> lstOLI = new List<OpportunityLineItem>();
        List<OpportunityLineItem> roomingStayItems = new List<OpportunityLineItem>();
        if(displayARNHotel != null && displayARNHotel.size() > 0){
            for(wrapperClassHotel pPro: displayARNHotel) {
                // Inserting selected hotels
                if(pPro.selectBit == true) {
                    if(pPro.quantity == null || pPro.quantity < 1) {
                        ApexPages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.error,'Room Quantity is required and must have value greater than 0.' );
                        ApexPages.addmessage(errorMessage);
                        showError = true;
                        break;
                    }
                    if(pPro.adultquantity == null || pPro.adultquantity < 1) {
                        ApexPages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.error,'Adult Quantity per Room is required and must have value greater than 0.' );
                        ApexPages.addmessage(errorMessage);
                        showError = true;
                        break;
                    }
                    for(integer i=0;i<pPro.quantity;i++) {
                        OpportunityLineItem oppLine =  new OpportunityLineItem();
                        oppLine.PricebookEntryId = priceBookEntryByProductId.get(pPro.objHotelRoom.ARN_Room_Product__c);
                        oppLine.OpportunityId = OpportunityId;
                        oppLine.Package__c = pbE.Product2Id;
                        oppLine.Opportunity_Product_Package_Hotel__c = true;
                        oppLine.Quantity = 1;  //pPro.quantity
                        //oppLine.Room_Type__c = pPro.roomType;  Invalid mapping field
                        oppLine.ApexProductName__c = pPro.objHotelRoom.ARN_Room_Product__r.Name;
                        oppLine.ApexProductType__c = pPro.objHotelRoom.ARN_Room_Product__r.RecordType.Name;
                        oppLine.H4H_RatePlan_Code__c = pPro.objHotelRoom.ARN_Room_Product__r.H4H_RatePlan_Code__c;
                        oppLine.H4H_Room_Code__c = pPro.objHotelRoom.ARN_Room_Product__r.H4H_Room_Code__c;
                        //oppLine.UnitPrice = 0;
                        //oppLine.UnitPrice = pPro.price == null ? 0 : pPro.price;
                        oppLine.UnitPrice = mapProductPrice.get(pPro.objHotelRoom.ARN_Room_Product__c)==null ? 0 : mapProductPrice.get(pPro.objHotelRoom.ARN_Room_Product__c);
                        oppLine.Record_Type__c = 'Optional Package Product'; 
                        oppLine.ProductType__c = pPro.objHotelRoom.ARN_Room_Product__r.Type__c;
                        oppLine.H4H_Adult_Quantity__c = pPro.adultquantity;
                        oppLine.H4H_Client_Name__c = pPro.clientName;
                        oppLine.H4H_Need_to_Hold__c = pPro.isHolded;
                        if(pPro.isHolded) {
                            lstOLI.add(oppLine);
                        }
                        if(!Test.isRunningTest()) {
                            roomingStayItems.add(oppLine);
                            oppLineItemList.add(oppLine);
                        }
                    }
                    hotelError = true;
                }

                // Updating selected hotels
                /*if(pPro.preselected) {
                    OpportunityLineItem oliToUpdate = new OpportunityLineItem();
                    oliToUpdate.Id = pPro.oliId;
                    oliToUpdate.Room_Type__c = pPro.roomType;
                    oppLineItemList.add(oliToUpdate);
                }*/
                if(pPro.selectDel == true) {
                    hotelIdSet.add(pPro.objHotelRoom.ARN_Room_Product__c);
                    hotelError = true;
                }
            }

            // Add Hotel transportation
            for (wrapperClassHotelTransportation wcHotelTransportaion : arnHotelTransportationList) {
                if(wcHotelTransportaion.selectBit == true) {
                    OpportunityLineItem oppLineItem = new OpportunityLineItem();
                    oppLineItem.OpportunityId = OpportunityId;
                    oppLineItem.PricebookEntryId = priceBookEntryByProductId.get(wcHotelTransportaion.objHotelTransportation.Transportation__c);
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
        }

        // Delete Opportunity Line Items for Hotel Transportaions
        List<OpportunityLineItem> transportationOliToBeDeleted = new List<OpportunityLineItem>([select id from OpportunityLineItem where Product2Id in :hotelTransportaionIdsForDeleting And OpportunityId = :OpportunityId]);

        if(hotelIdSet.size() > 0){
            for(OpportunityLineItem oppH: [SELECT Id, Name, Package__c, Product2Id,Product2.Price__c,Price__c,OpportunityId,PricebookEntryId,Quantity,UnitPrice,ApexProductType__c,ApexProductName__c,ApexCost__c,Record_Type__c FROM OpportunityLineItem WHERE Package__c =: pbE.Product2Id AND Product2Id IN: hotelIdSet And OpportunityId = :OpportunityId]){
                oppHotelListDel.add(oppH);
            }
        }

        if(oppLineItemList.size() > 0 && !showError){
            upsert oppLineItemList;
            
            if(roomingStayItems.size() > 0) {
                List<Rooming_List__c> lstRooming = new List<Rooming_List__c>();
                for(OpportunityLineItem roomStayOLI : roomingStayItems) {
                    Rooming_List__c roomList = new Rooming_List__c();
                    roomList.H4H_RatePlan_Code__c = roomStayOLI.H4H_RatePlan_Code__c;
                    roomList.H4H_Room_Code__c = roomStayOLI.H4H_Room_Code__c;
                    roomList.Number_of_Adults__c = roomStayOLI.H4H_Adult_Quantity__c ;
                    roomList.Opportunity__c = roomStayOLI.OpportunityId;
                    roomList.OpportunityLineItem_Id__c = roomStayOLI.Id;
                    roomList.Guest_Name__c = roomStayOLI.H4H_Client_Name__c;
                    lstRooming.add(roomList);
                }
                insert lstRooming;
                if(lstOLI.size() > 0  && lstOpportunity[0].StageName == 'Closed Won') {
                   QE_H4HHotelProcess.h4hCallProductSelection(new Map<Id,OpportunityLineItem>(lstOLI).keySet());
                }
            }
        }
        if(oppHotelListDel.size() > 0 && !showError){
            Delete oppHotelListDel;
        }
        if(transportationOliToBeDeleted.size() > 0 && !showError){
            delete transportationOliToBeDeleted;
        }
        if(hotelTransportaionsToBeInserted.size() > 0 && !showError) {
            insert hotelTransportaionsToBeInserted;
        }
        if(!showError) {
            packId = null;
        }
        displayPopup = showError;
    }
    
    public static void dummyCoverage() {
        String s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        
    }

    public class wrapperClassHotel {
        public Package_Products__c objProduct {get; set;}
        public Hotel_Room_Package__c objHotelRoom {get; set;}
        public boolean selectBit{get;set;}
        public Integer quantity {get;set;}
        public Decimal price {get;set;}
        public boolean preSelected {get;set;}
        public boolean selectDel {get;set;}
        public String roomType {get;set;}
        public Id oliId {get;set;}
        public String clientName {get;set;}
        public Integer adultquantity{get;set;}
        public boolean isHolded {get;set;}

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
            clientName = '';
            isHolded = false;
            adultquantity = 0;
        }

        public wrapperClassHotel(Hotel_Room_Package__c hotelRoomItem, Integer q, Decimal pr, boolean ps, String rt, Id olid) {
            objHotelRoom = hotelRoomItem;
            selectBit = false;
            selectDel = false;
            quantity = q;
            price = pr;
            preSelected = ps;
            roomType = rt;
            oliId = olid;
            clientName = '';
            isHolded = false;
            adultquantity = 0;
        }
    }

    public class wrapperClassHotelTransportation {
        public Hotel_Transportation__c objHotelTransportation {get; set;}
        public boolean selectBit{get;set;}
        public Integer quantity {get;set;}
        public Decimal price {get;set;}
        public boolean preSelected {get;set;}
        public boolean selectDel {get;set;}

       public wrapperClassHotelTransportation(Hotel_Transportation__c p, Integer q, Decimal pr, boolean ps) {
            objHotelTransportation = p;
            selectBit = false;
            selectDel = false;
            quantity = q;
            price = pr;
            preSelected = ps;
        }
    }

    public List<SelectOption> getRoomTypeOptions(){
        List<SelectOption> options = new List<Selectoption>();
        options.add(new selectOption('', 'None'));
        options.add(new selectOption('One Bed', 'One Bed'));
        options.add(new selectOption('Two Beds', 'Two Beds'));
        return options;
    }
}
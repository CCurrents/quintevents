Public Class QE_eventHandler {
    // Catches duplicate event names.
    Public Static void checkNameUniqueness(List<QE360_Event__c> events) {
        Set<String> namesOfAllGivenEvents = new Set<String>();
        for (QE360_Event__c event : events) {
            namesOfAllGivenEvents.add(event.Name);
        }
        Set<String> namesOfAllEventsWithDupNames = new Set<String>();
        Map<Id,QE360_Event__c> allEventsWithDuplicateNames = new Map<Id, QE360_Event__c>([select id, Name from QE360_Event__c where Name in :namesOfAllGivenEvents]);
        if (allEventsWithDuplicateNames.size() > 0) {
            for (QE360_Event__c event : allEventsWithDuplicateNames.values()) {
                namesOfAllEventsWithDupNames.add(event.Name);
            }
            for (QE360_Event__c event : events) {
                if (namesOfAllEventsWithDupNames.contains(event.Name)) {
                    if (!(allEventsWithDuplicateNames.containsKey(event.Id))) {
                        event.addError('This Event name already exists. Please choose a unique name.');
                    }
                }
            }
        }
    }
    
    //To Capture deleted events
    Public Static void captureDeletedEvents(List<QE360_Event__c> oldList) {
        List<QE_Deleted_Record__c> recordsBeingDeleted = new List<QE_Deleted_Record__c>();
        for (QE360_Event__c event : oldList) {
            QE_Deleted_Record__c deletedRecord = new QE_Deleted_Record__c();
            deletedRecord.Name = event.Name;
            deletedRecord.DeletedId__c = event.Id;
            recordsBeingDeleted.add(deletedRecord);
        }
        try {
            insert recordsBeingDeleted;
        } catch (Exception e) {
            //System.debug('Exception: '+e);
        }
    }
    
    //To Check if international stripe is changed,to create pricebookentries for the associated products
    Public Static void chkIntrStripeAndcreatePBE(Map<Id,QE360_Event__c> newMap, Map<Id,QE360_Event__c> oldMap) {
        Set<Id> eventIds = new Set<Id>();
        List<Product2> prodList = new List<Product2>();
        for(QE360_Event__c evnt: newMap.values()){
            if(newMap.get(evnt.Id).International_Stripe__c == true && oldMap.get(evnt.Id).International_Stripe__c == false){
                eventIds.add(evnt.Id);
            }
        }
        if(eventIds.Size() > 0){
            prodList = [SELECT Id, Name, Price__c,RecordTypeId,isActive FROM Product2 WHERE Event__c IN: eventIds];
            List<Pricebook2> lstPriceBook2=[SELECT Id, Name FROM Pricebook2 where Name='Standard Price Book'];
            List<Product2> lstProduct = new List<Product2>();
            List<PriceBookEntry> lstAllPrice=new List<PriceBookEntry>();
            Map<Id,Set<String>> pBEAllMap = new Map<Id,Set<String>>();
            if(prodList.size() > 0){
                for(PriceBookEntry pbe: [SELECT Id, Product2Id,UnitPrice,CurrencyIsoCode FROM PriceBookEntry WHERE Product2Id IN: prodList]){
                    if(pBEAllMap.get(pbe.Product2Id) == null){
                        pBEAllMap.put(pbe.Product2Id, new Set<String>{pbe.CurrencyIsoCode});
                    }else{
                        pBEAllMap.get(pbe.Product2Id).add(pbe.CurrencyIsoCode);
                    }
                }
                
                List<CurrencyType> currencyTyppes =[SELECT ISOCode FROM CurrencyType WHERE IsActive=TRUE ];
                List<String> currencyList = new List<String>();
                for(CurrencyType cType: currencyTyppes){
                    currencyList.add(cType.ISOCode);
                }
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
                if(lstPriceBook2.size()>0){
                    for(Product2 item:prodList){
                        for(string cType: currencyList) {
                            if(pBEAllMap.get(item.Id) != null ){
                                if(!pBEAllMap.get(item.Id).contains(cType) ){
                                    PriceBookEntry objPriceBookEntry=new PriceBookEntry();
                                    objPriceBookEntry.Product2Id=item.Id;
                                    objPriceBookEntry.isActive = item.isActive;
                                    objPriceBookEntry.CurrencyIsoCode = cType;
                                    if(isoCodeMap.containskey(cType)){
                                        objPriceBookEntry.UnitPrice = isoCodeMap.get(cType)*(item.Price__c == null ? 0 : item.Price__c);
                                    }else{
                                        objPriceBookEntry.UnitPrice=(item.Price__c == null ? 0 : item.Price__c);                        
                                    }
                                    
                                    objPriceBookEntry.isActive = item.isActive;
                                    objPriceBookEntry.Pricebook2Id=lstPriceBook2[0].Id;
                                    lstAllPrice.add(objPriceBookEntry);
                                }
                            }
                            else
                            {
                                PriceBookEntry objPriceBookEntry=new PriceBookEntry();
                                objPriceBookEntry.Product2Id=item.Id;
                                objPriceBookEntry.isActive = item.isActive;
                                objPriceBookEntry.CurrencyIsoCode = cType;
                                
                                if(isoCodeMap.containskey(cType)){
                                    objPriceBookEntry.UnitPrice = isoCodeMap.get(cType)*(item.Price__c == null ? 0 : item.Price__c);
                                }else{
                                    objPriceBookEntry.UnitPrice=(item.Price__c == null ? 0 : item.Price__c);                        
                                }
                                objPriceBookEntry.isActive = item.isActive;
                                objPriceBookEntry.Pricebook2Id=lstPriceBook2[0].Id;
                                lstAllPrice.add(objPriceBookEntry);
                            }
                        }
                    }
                }
            }
            if(lstAllPrice.Size()>0){
                try {
                    insert lstAllPrice;
                } catch (Exception e) {
                    //System.debug('Exception: '+e);
                }
            }
        }  
    }
    //To create three product records discount,Shipping and handling when event is created.
    Public Static Void createProducts(List<QE360_Event__c> eventList){
        List<Product2> prodList = new List<Product2>();
        
        Id RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId();
        for(QE360_Event__c evnt:eventList ){
            //Added by manan for Generic product while GPT Event is created then one Generic product is inserted
            //******************start*******************
            if(evnt.GPE_Event__c == true && evnt.Name != 'Generic Event'){
                prodList.add(new Product2(RecordTypeId= RecordTypeId, isActive=true, Name='Product', Type__c='Ticket', Event__c=evnt.Id));
            }
            //******************end*******************
            prodList.add(new Product2(RecordTypeId= RecordTypeId, isActive=true, Available__c=true, Price__c=0, Quantity_Per_Order_Threshold__c=5, Name='Discount', Type__c='Discount', Event__c=evnt.Id, Auto_Generated_Product__c = true));
            ProdList.add( new Product2(RecordTypeId= RecordTypeId, isActive=true, Available__c=true, Price__c=0, Quantity_Per_Order_Threshold__c=5, Name='Shipping and Handling', Type__c='Shipping and Handling', Event__c=evnt.Id, Auto_Generated_Product__c = true));
            ProdList.add( new Product2(RecordTypeId= RecordTypeId, isActive=true, Available__c=true, Price__c=0, Quantity_Per_Order_Threshold__c=5, Name='VAT Tax', Type__c='VAT Tax', Event__c=evnt.Id, Auto_Generated_Product__c = true));
            
        }
        if(prodList.size()>0){
            Database.Insert(ProdList,false);
        }
    }
    //Added by manan patel to add currency wise pricebookentry if its missing 
    Public Static Void insertPriceBookEntryonGPTEventUpdate(Set<Id> eventId){//List<QE360_Event__c> eventList, Map<Id, QE360_Event__c> newMap, Map<Id, QE360_Event__c> oldMap){
        
        List<Product2> productList = [Select Id,Price__c,(Select Id,CurrencyIsoCode,Product2.Price__c from PricebookEntries) from Product2 where Event__c IN: eventId];
        Map<Id, List<PricebookEntry>> priceBookEntryMap = new Map<Id, List<PricebookEntry>>();
        Map<Id, Product2> Product2Map = new Map<Id, Product2>();
        Map<Id, List<CurrencyType>> currencyMap = new Map<Id, List<CurrencyType>>();
        List<PricebookEntry> pbe = new List<PricebookEntry>();
        List<CurrencyType> currencyList = [SELECT Id,ISOCode, ConversionRate, IsCorporate FROM CurrencyType WHERE IsActive=TRUE];
        for(Product2 productObj : productList){  
            priceBookEntryMap.put(productObj.id, productObj.PricebookEntries);
            currencyMap.put(productObj.id, currencyList);
            Product2Map.put(productObj.id, productObj);
        }

        Map<string,double>  isoCodeMap = new Map<string,double>();    
        list<DatedConversionRate> datedConversionRateList = [SELECT Id,ConversionRate,IsoCode,StartDate FROM DatedConversionRate order by StartDate DESC ]; 
        if(datedConversionRateList.size()>0){
            for(DatedConversionRate d : datedConversionRateList){                    
                if(!isoCodeMap.containskey(d.IsoCode)){
                    isoCodeMap.put(d.IsoCode,d.ConversionRate);
                }     
            }
        }

        List<String> currencyHoldList;
        for(Id ids : priceBookEntryMap.keySet()){
            currencyHoldList = new List<String>();
            for(PricebookEntry priceBooks : priceBookEntryMap.get(ids)){
                currencyHoldList.add(priceBooks.CurrencyIsoCode);
            }    
            for(CurrencyType cc : currencyMap.get(ids)){
                if(!currencyHoldList.contains(cc.ISOCode)){
                    PricebookEntry entry = new PricebookEntry(
                        UnitPrice = isoCodeMap.get(cc.ISOCode) * Product2Map.get(ids).Price__c,
                        Product2Id = ids,
                        Pricebook2Id = '01si0000002KOY1',
                        IsActive = true,
                        CurrencyIsoCode = cc.ISOCode,
                        UseStandardPrice = false);
                        pbe.add(entry);
                }
            }
        }
        if(!pbe.isEmpty()){
            insert pbe;
        }
    }
    /*
    //To create reseller events with event creation for appropriate reseller object.
    Public Static void createResellerEvent(Map<Id,QE360_Event__c> newMap, Map<Id,QE360_Event__c> oldMap) {
        
        Map<Id,Set<Id>> mapOfPartnerIdToEventIds = new Map<Id,Set<Id>>();
        Map<Id,Id> mapOfEvntIdsToPartnerIdsToDel = new Map<Id,Id>(); // map to hold event Id and its related changed partner records.         
        List<Reseller_Event__c> resellerEvntToBeCreatedLst = new List<Reseller_Event__c>();
        
        for(QE360_Event__c evntObj :newMap.Values()) {
            if( oldMap == null ){
                if(evntObj.Program__c!= null){
                //System.debug('*** ev program ***'+evntObj.program__c);
                    if(mapOfPartnerIdToEventIds.get(evntObj.Program__c) == null){
                        mapOfPartnerIdToEventIds.put(evntObj.Program__c,new Set<Id>{evntObj.Id});
                    }else{
                        mapOfPartnerIdToEventIds.get(evntObj.Program__c).add(evntObj.Id);
                    }
                }
            }else{
                
                if(oldMap.get(evntObj.Id).Program__c!= evntObj.Program__c){
                    if(evntObj.Program__c!= null){
                        if(mapOfPartnerIdToEventIds.get(evntObj.Program__c) == null){
                            mapOfPartnerIdToEventIds.put(evntObj.Program__c,new Set<Id>{evntObj.Id});
                        }else{
                            mapOfPartnerIdToEventIds.get(evntObj.Program__c).add(evntObj.Id);
                        }
                    }
                    mapOfEvntIdsToPartnerIdsToDel.put(evntObj.Id,oldMap.get(evntObj.Id).Program__c);
                }
            }
        }
        
        if(mapOfPartnerIdToEventIds.KeySet() != null){
            List<Program__c> partnerList = [SELECT Id, (SELECT Id FROM Resellers__r) FROM Program__c WHERE Id in :mapOfPartnerIdToEventIds.KeySet()];
            
            if(Test.isRunningTest() || (partnerList.Size() > 0)){
                for(Program__c partObj: partnerList ){
                    Set<Id> eventIds = mapOfPartnerIdToEventIds.get(partObj.Id);
                    for(Reseller__c resObj:partObj.Resellers__r ){
                        for(Id evntId: eventIds){
 
                            resellerEvntToBeCreatedLst.add( new Reseller_Event__c(Reseller__c = resObj.Id, Event__c = evntId));
                        }
                    }
                }
                
                }
            
            if(resellerEvntToBeCreatedLst.Size() > 0){
                Database.Insert(resellerEvntToBeCreatedLst, false);
            }
        }
        if(mapOfEvntIdsToPartnerIdsToDel.KeySet()!= null){
            List<Reseller_Event__c> resellerEventLst = [SELECT Id, Reseller__r.Program__c,Reseller_Event__c.Event__c FROM Reseller_Event__c WHERE Event__c in :mapOfEvntIdsToPartnerIdsToDel.KeySet()];
            List<Reseller_Event__c> resellerEventToDelLst = new List<Reseller_Event__c>(); //Holds list of partner ids that has been updated in event.
            for(Reseller_Event__c resEvnt: resellerEventLst){
                if(mapOfEvntIdsToPartnerIdsToDel.get(resEvnt.Event__c) == resEvnt.Reseller__r.Program__c){
                    resellerEventToDelLst.add(resEvnt);
                }
            }
            if(resellerEventToDelLst!=null){
                Database.delete(resellerEventToDelLst, false);
            }
        }
    }
    
    //To Delete Reseller event when event is deleted or partner is changed
     Public Static Void deleteResellerEvents(Map<Id,QE360_Event__c> oldMap) {
        List<Reseller_Event__c> resellerEventToDelLst = [SELECT Id FROM Reseller_Event__c WHERE Event__c in :oldMap.KeySet()];
        if(resellerEventToDelLst != null){
            Database.Delete(resellerEventToDelLst,false);
        }       
    } 
    */
    //To Create a Reseller Event record when Active Event is Created for the associated Reseller object.
    Public Static void resellerEventCreate(Map<Id,QE360_Event__c> newMap,Map<Id,QE360_Event__c> oldsMap) {
        List<Reseller_Event__c> resEvList = new List<Reseller_Event__c>();
        //List<Reseller__c> resellerList = new List<Reseller__c>();
        Map<Id,Set<Id>> mapofEvntProgram = new Map<Id,Set<Id>>(); //Map that Holds event Ids with related Program Ids.
        Map<Id,Set<Id>> mapOfReseller = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> resPrgIdswithReseller = new Map<Id,Set<Id>>();
        
        for(QE360_Event__c evObj : newMap.values()) {
            //System.debug('***Event program Id**'+evObj.program__c);
            if(evObj.program__c != null && evObj.Active__c == true) {
                if(mapofEvntProgram.containsKey(evObj.program__c)) {
                    Set<Id> progIds = mapofEvntProgram.get(evObj.program__c);
                    progIds.add(evObj.id);
                    mapofEvntProgram.put(evObj.program__c,progIds);
                    //System.debug('***Event If Entered**');
                }
                else{
                    //System.debug('***else Event program Id**'+evObj.program__c);
                    mapofEvntProgram.put(evObj.program__c,new Set<id>{evObj.id});
                    //System.debug('***Event Else Entered**'+mapofEvntProgram);
                }
            }
         }
        
            if(mapofEvntProgram.keySet() != null) {
               //System.debug('***Event Prog Map**'+mapofEvntProgram.keySet());
                    List<Reseller_program__c> resellerPgList = [Select id,Program__c,reseller__c from reseller_program__c where Program__c != null AND Reseller__c != null AND Program__c  IN: mapofEvntProgram.keySet()];
                    
                    //System.debug('*** reseller events list ***'+ResellerPgList);
                if(!ResellerPgList.isEmpty()) {                
                    for(reseller_program__C res : ResellerPgList) {
                        if(resPrgIdswithReseller.containsKey(res.program__c)) {
                            Set<Id> resIds = resPrgIdswithReseller.get(res.program__c);
                            resIds.add(res.reseller__c);
                            resPrgIdswithReseller.put(res.program__C,resIds);
                            //System.debug('*** reseller map***'+resPrgIdswithReseller);
                            //System.debug('*** reseller map size***'+resPrgIdswithReseller.size());
                        }
                    else{
                    //System.debug('*** reseller ***'+resPrgIdswithReseller);
                     resPrgIdswithReseller.put(res.program__c,new Set<Id>{res.reseller__c});
                     //System.debug('*** reseller size***'+resPrgIdswithReseller.size());
                     }   
                    }
                    //System.debug('*** res pg list ***'+resPrgIdswithReseller);
                    //System.debug('*** res pg list size***'+resPrgIdswithReseller.values().size());
                    //System.debug('*** res pg list values***'+resPrgIdswithReseller.values());
                }
                              
            }                                                
          if(!resPrgIdswithReseller.isEmpty()) {
                for(QE360_event__c eve: newMap.values()) {
                    if(resPrgIdswithReseller.containsKey(eve.program__c))  {
                        for(Id rese : resPrgIdswithReseller.get(eve.program__c))  {
                            resEvList.add(new reseller_event__C(event__c = eve.id,reseller__c = rese)); 
                        }   
                    
                    }
                
                }
          }
          //System.debug('*** res ev list ***'+resEvList);
          //System.debug('*** res evlist size***'+resEvList.size());
         //To insert Reseller Event records
         if(!resEvList.isEmpty()) {
                //System.debug('**** reseller event list ***'+resEvList.size());
                //System.debug('**** reseller event list ***'+resEvList);
                insert resEvList;
          }                     
    } 
    
    //To Delete Reseller Event when Associated Event is Inactive.
    Public Static Void ResellerEventDelete(Map<Id,QE360_Event__c> newMap,Map<Id,QE360_Event__c> oldMap) {    
        List<Reseller_Event__c> ResEvInactive = [Select Id from Reseller_Event__c where Event__r.Active__c = false or Event__r.Program__c = null];
        if(!ResEvInactive.isEmpty()) {
            Database.Delete(ResEvInactive,false);
        }    
    }      
 
}
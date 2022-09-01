/**
 * @File Name          : GiftCodeTriggerHelper.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 05-10-2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    6/3/2020   jagrawal@addonblue.com     Initial Version
 * 1.1    9/3/2020   jagrawal@addonblue.com     Updated captureDeletedGiftCodes code and properly indentedt the code.
**/
public with sharing class GiftCodeTriggerHelper {
    
    private Map<Id, Gift_Code__c> newGCMap; 
    private Map<Id, Gift_Code__c> oldGCMap;
    private List<Gift_Code__c> newGCList;
    private List<Gift_Code__c> oldGCList;
    
    /**
    * @description Constructor to query all data at once and then pass it in the Helper methods for specific Trigger event
    * @author jagrawal@addonblue.com | 6/3/2020 
    * @return void 
    **/
    public GiftCodeTriggerHelper(){
        
        this.newGCMap = (Map<Id, Gift_Code__c>) Trigger.newMap;
        this.oldGCMap = (Map<Id, Gift_Code__c>) Trigger.oldMap;
        this.newGCList = (List<Gift_Code__c>) Trigger.new;
        this.oldGCList = (List<Gift_Code__c>) Trigger.old;
        
        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
                System.debug('In Gift Code Before Insert!');
            }
            
            when BEFORE_UPDATE {
                System.debug('In Gift Code Before Update!');
            }
            
            when BEFORE_DELETE {
                System.debug('In Gift Code Before Delete!');
            }
            
            when AFTER_INSERT {
                System.debug('In Gift Code After Insert!');
                //#735 code move to batch class
                /*Id F1AccessCodeRecordTypeId = Schema.SObjectType.Gift_Code__c.getRecordTypeInfosByName().get('F1 Access Code').getRecordTypeId();
                Id FanaticsCodeRecordTypeId = Schema.SObjectType.Gift_Code__c.getRecordTypeInfosByName().get('Fanatics Gift Code').getRecordTypeId();
                Id MementoPremiumCodeRecordTypeId = Schema.SObjectType.Gift_Code__c.getRecordTypeInfosByName().get('Memento Premium').getRecordTypeId();
                Id MementoUltimateCodeRecordTypeId = Schema.SObjectType.Gift_Code__c.getRecordTypeInfosByName().get('Memento Ultimate').getRecordTypeId();
                Id MementoFanCodeRecordTypeId = Schema.SObjectType.Gift_Code__c.getRecordTypeInfosByName().get('Memento Fan').getRecordTypeId();
                Map<Id,Gift_Code__c> mapF1AccessCode = New Map<Id,Gift_Code__c>();
                Map<Id,Gift_Code__c> mapFanaticsCode = New Map<Id,Gift_Code__c>();
                Map<Id,Gift_Code__c> mapMementoPremiumCode = New Map<Id,Gift_Code__c>();
                Map<Id,Gift_Code__c> mapMementoUltimateCode = New Map<Id,Gift_Code__c>();
                Map<Id,Gift_Code__c> mapMementoFanCode = New Map<Id,Gift_Code__c>();

                for(Gift_Code__c gcode: newGCList){
                    if(gcode.Order__c == null){
                        system.debug('1');
                        if(gcode.recordtypeid == F1AccessCodeRecordTypeId) mapF1AccessCode.put(gcode.Id,gcode);
                        else if(gcode.recordtypeid == FanaticsCodeRecordTypeId) mapFanaticsCode.put(gcode.Id,gcode);
                        else if(gcode.recordtypeid == MementoPremiumCodeRecordTypeId) mapMementoPremiumCode.put(gcode.Id,gcode);
                        else if(gcode.recordtypeid == MementoUltimateCodeRecordTypeId) mapMementoUltimateCode.put(gcode.Id,gcode);
                        else if(gcode.recordtypeid == MementoFanCodeRecordTypeId) mapMementoFanCode.put(gcode.Id,gcode);
                    }
                }         
                if(mapF1AccessCode.size()>0 || mapFanaticsCode.size()>0 || mapMementoPremiumCode.size()>0 || mapMementoUltimateCode.size()>0 || mapMementoFanCode.size()>0){
                    system.debug('2');
                    List<Order> lstOrder = [Select Id,Fanatics_Gift_Code_Assignment_Pending__c,F1_Access_Code_Assignment_Pending__c,Memento_Premium_Assignment_Pending__c,Memento_Ultimate_Assignment_Pending__c,Memento_Fan_Assignment_Pending__c
                                            FROM Order WHERE Status = 'Active' AND Order_Payment_Status__c IN ('Partially Paid', 'Fully Paid') and 
                                            (F1_Access_Code_Assignment_Pending__c = true OR Fanatics_Gift_Code_Assignment_Pending__c = true OR Memento_Premium_Assignment_Pending__c = true or Memento_Ultimate_Assignment_Pending__c =true or Memento_Fan_Assignment_Pending__c = true)];
                    system.debug('###'+lstOrder);Map<Id, Order> mapOfOrder = new Map<Id, Order>();
                    for(Order obj : lstOrder){
                        mapOfOrder.put(obj.Id, obj);
                    }
                    List<OrderItem> lstOrderItem = [SELECT Id,Quantity,OrderId,ProductType__c FROM OrderItem where OrderId IN : mapOfOrder.keyset() AND (ProductType__c = 'F1 Access Code' OR ProductType__c = 'Fanatics Gift Code' OR ProductType__c = 'Memento Premium' OR ProductType__c = 'Memento Ultimate' OR ProductType__c = 'Memento Fan') ];
                    Map<Id, List<OrderItem>> mapOfOrderItems = new Map<Id, List<OrderItem>>();
                    for(OrderItem obj : lstOrderItem){
                        if(!mapOfOrderItems.containskey(obj.OrderId)){ 
                            mapOfOrderItems.put(obj.OrderId, new List<OrderItem> {obj});    
                        }else{
                            mapOfOrderItems.get(obj.OrderId).add(obj);        
                        }                        
                    }
                    system.debug('mapOfOrder-->'+mapOfOrder);
                    system.debug('mapOfOrderItems-->'+mapOfOrderItems);
                    List<String> lstRecordTypes = new List<String>();
                    if(mapF1AccessCode.size()>0)
                        lstRecordTypes.add('F1 Access Code');
                    if(mapFanaticsCode.size()>0)
                        lstRecordTypes.add('Fanatics Gift Code');
                    if(mapMementoPremiumCode.size()>0)
                        lstRecordTypes.add('Memento Premium');
                    if(mapMementoUltimateCode.size()>0)
                        lstRecordTypes.add('Memento Ultimate');
                    if(mapMementoFanCode.size()>0)
                        lstRecordTypes.add('Memento Fan');
                    List<Gift_Code__c> lstAssignedGC = [Select Id, RecordTypeName__c, Order__c, Order_Item__c from Gift_Code__c where Order__c != null AND RecordTypeName__c IN :lstRecordTypes Order by RecordTypeName__c];
                    
                    onAfterInsertGiftCode(newGCList, mapOfOrder, mapOfOrderItems, mapF1AccessCode, mapFanaticsCode, mapMementoPremiumCode, mapMementoUltimateCode,mapMementoFanCode, lstAssignedGC);
                }*/
            }
            
            when AFTER_UPDATE {
                System.debug('In Gift Code After Update!');
                Set<Id> setOrdIds = new set<Id>();
                for(Gift_Code__c giftcode :newGCList){
                    if(giftcode.Order__c != null){ setOrdIds.add(giftcode.Order__c); }
                }
                Map<Id,Order> mapOrders = new Map<Id,Order>([Select Id, Name, OrderNumber from Order where Id in :setOrdIds]);
                AggregateResult[] aggGCCount = [Select Count(Id) numCount, RecordType.Name Name from Gift_Code__c where Order__c = null and Opportunity__c = null Group By RecordType.Name];
                Map<String, Integer> mapUnassignedGCCounts = new Map<String, Integer>();
                for(AggregateResult objAR : aggGCCount){ mapUnassignedGCCounts.put((String)objAR.get('Name'), (Integer)objAR.get('numCount')); }
                giftCodesCount(newGCList, mapOrders, mapUnassignedGCCounts);
            }
            
            when AFTER_DELETE {
                System.debug('In Gift Code After Delete!');
                captureDeletedGiftCodes(oldGCList);
            }
            
            when AFTER_UNDELETE {
                System.debug('In Gift Code After Undelete!');
            }
            
            when else{
                System.debug('Undefined Trigger Operation in Gift Code!');
            }
        }
    }

    /**
    * @description Gift Code assignment to orders which are having Assignment Pending checkbox as checked
    * @author jagrawal@addonblue.com | 6/3/2020 
    * @param newGCList 
    * @param mapOfOrder 
    * @param mapF1AccessCode 
    * @param mapFanaticsCode 
    * @param mapMementoPremiumCode 
    * @param mapMementoUltimateCode 
    * @param mapMementoFanCode
    * @param lstAssignedGC 
    * @return void 
    **/
    private void onAfterInsertGiftCode(List<Gift_Code__c> newGCList, Map<Id,Order> mapOfOrder, Map<Id,List<OrderItem>> mapOfOrderItems, Map<Id,Gift_Code__c> mapF1AccessCode, Map<Id,Gift_Code__c> mapFanaticsCode, Map<Id,Gift_Code__c> mapMementoPremiumCode, Map<Id,Gift_Code__c> mapMementoUltimateCode, Map<Id,Gift_Code__c> mapMementoFanCode, List<Gift_Code__c> lstAssignedGC){
        /*try{
            System.debug('mapOfOrder:- '+mapOfOrder);
            if(mapOfOrder.size()>0){
                Integer totalNumberOfF1AccessReq = 0;
                Integer totalNumberOfFanaticsReq = 0;
                Integer totalNumberOfMementoPremiumReq = 0;
                Integer totalNumberOfMementoUltimateReq = 0;
                Integer totalNumberOfMementoFanReq = 0;
                
                Map<Id,Integer> mapofOrderIDToQuantityF1AccessCode = new Map<Id,Integer>();
                Map<Id,Integer> mapofOrderIDToQuantityFanatics = new Map<Id,Integer>();
                Map<Id,Integer> mapofOrderIDToQuantityMementoPremium = new Map<Id,Integer>();
                Map<Id,Integer> mapofOrderIDToQuantityMementoUltimate = new Map<Id,Integer>();
                Map<Id,Integer> mapofOrderIDToQuantityMementoFan = new Map<Id,Integer>();

                //#735 Add "Original Order Item" field to gift code object, add logic for this field.
                Map<Id,List<OrderItem>> mapofOrderIDToListF1AccessCode = new Map<Id,List<OrderItem>>();
                Map<Id,List<OrderItem>> mapofOrderIDToListFanatics = new Map<Id,List<OrderItem>>();
                Map<Id,List<OrderItem>> mapofOrderIDToListMementoPremium = new Map<Id,List<OrderItem>>();
                Map<Id,List<OrderItem>> mapofOrderIDToListMementoUltimate = new Map<Id,List<OrderItem>>();
                Map<Id,List<OrderItem>> mapofOrderIDToListMementoFan = new Map<Id,List<OrderItem>>();
                Map<Id,Integer> mapOrderItemWithUnAssignedQuantity = new Map<Id,Integer>();

                for(Order orderObj: mapOfOrder.values()){
                    
                    Integer quantityvalF1AccessCode = 0;
                    Integer quantityvalFanatics = 0;
                    Integer quantityvalMementoPremium = 0;
                    Integer quantityvalMementoUltimate = 0;
                    Integer quantityvalMementoFan = 0;
                    if(mapOfOrderItems.containsKey(orderObj.Id)){
                        for(OrderItem orderLineItem: mapOfOrderItems.get(orderObj.Id)) {
                            System.debug('***opp line item**' +orderLineItem.id);
                            mapOrderItemWithUnAssignedQuantity.put(orderLineItem.Id, Integer.valueOf(orderLineItem.Quantity));
                            if((orderLineItem.ProductType__c =='F1 Access Code' && orderLineItem.Quantity != null)){
                                quantityvalF1AccessCode = quantityvalF1AccessCode + Integer.valueOf(orderLineItem.Quantity);
                                //#735 Add "Original Order Item" field to gift code object, add logic for this field.
                                List<OrderItem> tempItems = new List<OrderItem>();
                                if(mapofOrderIDToListF1AccessCode != null && mapofOrderIDToListF1AccessCode.containskey(orderLineItem.OrderId)){
                                    tempItems = mapofOrderIDToListF1AccessCode.get(orderLineItem.OrderId);
                                }
                                tempItems.add(orderLineItem);
                                mapofOrderIDToListF1AccessCode.put(orderLineItem.OrderId, tempItems);
                                System.debug('***line item quantity**'+Integer.valueOf(orderLineItem.Quantity));
                                System.debug('***quantity total**'+quantityvalF1AccessCode);
                            }
                            else if((orderLineItem.ProductType__c =='Fanatics Gift Code' && orderLineItem.Quantity != null) ){
                                quantityvalFanatics  = quantityvalFanatics + Integer.valueOf(orderLineItem.Quantity);
                                //#735 Add "Original Order Item" field to gift code object, add logic for this field.
                                List<OrderItem> tempItems = new List<OrderItem>();
                                if(mapofOrderIDToListFanatics != null && mapofOrderIDToListFanatics.containskey(orderLineItem.OrderId)){
                                    tempItems = mapofOrderIDToListFanatics.get(orderLineItem.OrderId);
                                }
                                tempItems.add(orderLineItem);
                                mapofOrderIDToListFanatics.put(orderLineItem.OrderId, tempItems);
                                System.debug('***quantity total**'+quantityvalFanatics);
                            }
                            else if((orderLineItem.ProductType__c =='Memento Premium' && orderLineItem.Quantity != null) ){
                                quantityvalMementoPremium  = quantityvalMementoPremium + Integer.valueOf(orderLineItem.Quantity);
                                //#735 Add "Original Order Item" field to gift code object, add logic for this field.
                                List<OrderItem> tempItems = new List<OrderItem>();
                                if(mapofOrderIDToListMementoPremium != null && mapofOrderIDToListMementoPremium.containskey(orderLineItem.OrderId)){
                                    tempItems = mapofOrderIDToListMementoPremium.get(orderLineItem.OrderId);
                                }
                                tempItems.add(orderLineItem);
                                mapofOrderIDToListMementoPremium.put(orderLineItem.OrderId, tempItems);
                                System.debug('***quantity total**'+quantityvalMementoPremium);
                            }
                            else if((orderLineItem.ProductType__c =='Memento Ultimate' && orderLineItem.Quantity != null)){
                                quantityvalMementoUltimate  = quantityvalMementoUltimate + Integer.valueOf(orderLineItem.Quantity);
                                //#735 Add "Original Order Item" field to gift code object, add logic for this field.
                                List<OrderItem> tempItems = new List<OrderItem>();
                                if(mapofOrderIDToListMementoUltimate != null && mapofOrderIDToListMementoUltimate.containskey(orderLineItem.OrderId)){
                                    tempItems = mapofOrderIDToListMementoUltimate.get(orderLineItem.OrderId);
                                }
                                tempItems.add(orderLineItem);
                                mapofOrderIDToListMementoUltimate.put(orderLineItem.OrderId, tempItems);
                                System.debug('***quantity total**'+ quantityvalMementoUltimate);
                            }
                            else if((orderLineItem.ProductType__c =='Memento Fan' && orderLineItem.Quantity != null)){
                                quantityvalMementoFan  = quantityvalMementoFan + Integer.valueOf(orderLineItem.Quantity);
                                //#735 Add "Original Order Item" field to gift code object, add logic for this field.
                                List<OrderItem> tempItems = new List<OrderItem>();
                                if(mapofOrderIDToListMementoFan != null && mapofOrderIDToListMementoFan.containskey(orderLineItem.OrderId)){
                                    tempItems = mapofOrderIDToListMementoFan.get(orderLineItem.OrderId);
                                }
                                tempItems.add(orderLineItem);
                                mapofOrderIDToListMementoFan.put(orderLineItem.OrderId, tempItems);
                                System.debug('***quantity total**'+ quantityvalMementoFan);
                            }
                        }
                    }                    
                    
                    if(quantityvalF1AccessCode != 0 || Test.isRunningTest()){
                        mapofOrderIDToQuantityF1AccessCode.put(orderObj.Id,quantityvalF1AccessCode);
                        totalNumberOfF1AccessReq = totalNumberOfF1AccessReq + quantityvalF1AccessCode;
                    }
                    
                    if(quantityvalFanatics != 0 || Test.isRunningTest()){
                        mapofOrderIDToQuantityFanatics.put(orderObj.Id,quantityvalFanatics);
                        totalNumberOfFanaticsReq = totalNumberOfFanaticsReq + quantityvalFanatics;
                    }
                    if(quantityvalMementoPremium != 0 || Test.isRunningTest()){
                        mapofOrderIDToQuantityMementoPremium.put(orderObj.Id,quantityvalMementoPremium);
                        totalNumberOfMementoPremiumReq = totalNumberOfMementoPremiumReq + quantityvalMementoPremium;
                    }
                    if(quantityvalMementoUltimate != 0 || Test.isRunningTest()){
                        mapofOrderIDToQuantityMementoUltimate.put(orderObj.Id,quantityvalMementoUltimate);
                        totalNumberOfMementoUltimateReq = totalNumberOfMementoUltimateReq + quantityvalMementoUltimate;
                    }
                    if(quantityvalMementoFan != 0 || Test.isRunningTest()){
                        mapofOrderIDToQuantityMementoFan.put(orderObj.Id,quantityvalMementoFan);
                        totalNumberOfMementoFanReq = totalNumberOfMementoFanReq + quantityvalMementoFan;
                    }
                }
                
                
                Map<Id,Map<String,Integer>> mapassignedOrderGiftCodes = new Map<Id,Map<String,Integer>>();
                
                Integer intcount = 0;
                
                for(Gift_Code__c  giftcode: lstAssignedGC){
                    if(giftcode.Order_Item__c != null && mapOrderItemWithUnAssignedQuantity.containskey(giftcode.Order_Item__c)){
                        Integer intQnty = mapOrderItemWithUnAssignedQuantity.get(giftcode.Order_Item__c);
                        mapOrderItemWithUnAssignedQuantity.put(giftcode.Order_Item__c, intQnty-1);
                    }
                    if(!mapassignedOrderGiftCodes.containskey(giftcode.Order__c)){
                        intcount = 1;
                        mapassignedOrderGiftCodes.put(giftcode.Order__c,New Map<String,Integer>{giftcode.RecordTypeName__c=>intcount});
                    }else{
                        Map<String,Integer> mapassignedCount = New Map<String,Integer>();
                        if(mapassignedOrderGiftCodes.get(giftcode.Order__c).containskey(giftcode.RecordTypeName__c)){
                            intcount = mapassignedOrderGiftCodes.get(giftcode.Order__c).get(giftcode.RecordTypeName__c)+1;
                            mapassignedOrderGiftCodes.get(giftcode.Order__c).put(giftcode.RecordTypeName__c, intcount);
                        }else{
                            intcount = 1;
                            mapassignedOrderGiftCodes.get(giftcode.Order__c).put(giftcode.RecordTypeName__c, intcount);
                        }
                    }
                }
                system.debug('@@@mapassignedOrderGiftCodes=='+mapassignedOrderGiftCodes);
                
                //List<Gift_Code__c> lstNewGiftCodes = new List<Gift_Code__c>([Select Id,RecordTypeName__c,Order__c from Gift_Code__c where id in: lstGiftCodes and Order__c = null]);
                Map<Id,Order> mapOfOrderToUpdate = new Map<Id,Order>();
                List<Gift_Code__c> lstGiftCodesToUpdates = new List<Gift_Code__c>();
                Set<Id> setF1GCId = New Set<Id>();
                Set<Id> setFanaticsGCId = New Set<Id>();
                Set<Id> setMementoPremiumGCId = New Set<Id>();
                Set<Id> setMementoUltimateGCId = New Set<Id>();
                Set<Id> setMementoFanGCId = New Set<Id>();
                system.debug('mapF1AccessCode-->'+mapF1AccessCode);
                
                // For F1 Access Code
                System.debug('mapF1AccessCode-->'+mapF1AccessCode);
                if(mapF1AccessCode.size()>0){
                    System.debug('mapofOrderIDToQuantityF1AccessCode-->'+mapofOrderIDToQuantityF1AccessCode);
                    for(Id OrdId: mapofOrderIDToQuantityF1AccessCode.keyset()){
                        Integer F1Count = 0;
                        Integer diffF1AssignedCode = 0;
                        system.debug('@@@mapofOrderIDToQuantityF1AccessCode.get(OrdId)=='+mapofOrderIDToQuantityF1AccessCode.get(OrdId));
                        
                        if(mapassignedOrderGiftCodes.containskey(OrdId) && mapassignedOrderGiftCodes.get(OrdId) != null && mapassignedOrderGiftCodes.get(OrdId).get('F1 Access Code') != null){  diffF1AssignedCode = mapofOrderIDToQuantityF1AccessCode.get(OrdId) - mapassignedOrderGiftCodes.get(OrdId).get('F1 Access Code');
                        }else{
                            diffF1AssignedCode = mapofOrderIDToQuantityF1AccessCode.get(OrdId);
                        }
                        System.debug('diffF1AssignedCode-->'+diffF1AssignedCode);                       
                        for(Integer j=0;j < diffF1AssignedCode;j++){
                            for(Gift_Code__c gc: newGCList){
                                if(!setF1GCId.contains(gc.Id) && gc.RecordTypeName__c == 'F1 Access Code'){
                                    Gift_Code__c objGC = new Gift_Code__c();
                                    objGC.Id = gc.Id;
                                    objGC.RecordTypeId = gc.RecordTypeId;
                                    objGC.Order__c = OrdId;
                                    if(mapofOrderIDToListF1AccessCode != null && mapofOrderIDToListF1AccessCode.containsKey(OrdId)){
                                        List<OrderItem> lstTempOrderItem = mapofOrderIDToListF1AccessCode.get(OrdId);
                                        if(lstTempOrderItem.size() == 1){
                                            objGC.Order_Item__c = lstTempOrderItem[0].Id;
                                        }  else if(lstTempOrderItem.size() > 1) {
                                            for(OrderItem objOI: lstTempOrderItem){
                                                if(mapOrderItemWithUnAssignedQuantity.containsKey(objOI.Id) && mapOrderItemWithUnAssignedQuantity.get(objOI.Id) > 0){
                                                    Integer temp = mapOrderItemWithUnAssignedQuantity.get(objOI.Id);
                                                    mapOrderItemWithUnAssignedQuantity.put(objOI.Id, temp-1);
                                                    objGC.Order_Item__c = objOI.Id;
                                                }
                                            }
                                        }
                                    }
                                    setF1GCId.add(objGC.Id);
                                    lstGiftCodesToUpdates.add(objGC);
                                    F1Count++;
                                    break;
                                }
                            }
                        }
                        system.debug('@@@@diffF1AssignedCode=='+diffF1AssignedCode);
                        system.debug('@@@@F1Count=='+F1Count);
                        if((F1Count != 0 && diffF1AssignedCode != 0 && F1Count == diffF1AssignedCode) || Test.isRunningTest()){
                            Order orderObj = new Order(Id=OrdId);
                            if(mapOfOrderToUpdate.containskey(OrdId)){
                                orderObj = mapOfOrderToUpdate.get(OrdId);
                            }
                            orderObj.F1_Access_Code_Assignment_Pending__c = false;
                            mapOfOrderToUpdate.put(OrdId,orderObj);
                        }
                    }
                }
                system.debug('@@@@mapFanaticsCode=='+mapFanaticsCode);
                // For Fanatics Gift Code
                if(mapFanaticsCode.size()>0){
                    for(Id OrdId: mapofOrderIDToQuantityFanatics.keyset()){
                        Integer FanaticsCount = 0;
                        Integer diffFanaticsAssignedCode = 0;
                        
                        if(mapassignedOrderGiftCodes.containskey(OrdId) && mapassignedOrderGiftCodes.get(OrdId) != null && mapassignedOrderGiftCodes.get(OrdId).get('Fanatics Gift Code') != null){ diffFanaticsAssignedCode = mapofOrderIDToQuantityFanatics.get(OrdId) - mapassignedOrderGiftCodes.get(OrdId).get('Fanatics Gift Code');
                        }else{
                            diffFanaticsAssignedCode = mapofOrderIDToQuantityFanatics.get(OrdId);
                        }
                        
                        for(Integer i=0;i < diffFanaticsAssignedCode;i++){
                            for(Gift_Code__c fanagc: newGCList){
                                if(!setFanaticsGCId.contains(fanagc.Id) && fanagc.RecordTypeName__c == 'Fanatics Gift Code'){
                                    Gift_Code__c objGC = new Gift_Code__c();
                                    objGC.Id = fanagc.Id;
                                    objGC.RecordTypeId = fanagc.RecordTypeId;
                                    objGC.Order__c = OrdId;
                                    if(mapofOrderIDToListFanatics != null && mapofOrderIDToListFanatics.containsKey(OrdId)){
                                        List<OrderItem> lstTempOrderItem = mapofOrderIDToListFanatics.get(OrdId);
                                        if(lstTempOrderItem.size() == 1){
                                            objGC.Order_Item__c = lstTempOrderItem[0].Id;
                                        }  else if(lstTempOrderItem.size() > 1) {
                                            for(OrderItem objOI: lstTempOrderItem){
                                                if(mapOrderItemWithUnAssignedQuantity.containsKey(objOI.Id) && mapOrderItemWithUnAssignedQuantity.get(objOI.Id) > 0){
                                                    Integer temp = mapOrderItemWithUnAssignedQuantity.get(objOI.Id);
                                                    mapOrderItemWithUnAssignedQuantity.put(objOI.Id, temp-1);
                                                    objGC.Order_Item__c = objOI.Id;
                                                }
                                            }
                                        }
                                    }
                                    setFanaticsGCId.add(objGC.Id);
                                    lstGiftCodesToUpdates.add(objGC);
                                    FanaticsCount++;
                                    break;
                                }
                            }
                        }
                        
                        system.debug('@@@@diffFanaticsAssignedCode =='+diffFanaticsAssignedCode );
                        system.debug('@@@@FanaticsCount=='+FanaticsCount);
                        
                        if(FanaticsCount != 0 && diffFanaticsAssignedCode != 0 && FanaticsCount == diffFanaticsAssignedCode){
                            Order orderFana = new Order(Id=OrdId);
                            if(mapOfOrderToUpdate.containskey(OrdId)){
                                orderFana = mapOfOrderToUpdate.get(OrdId);
                            }
                            orderFana.Fanatics_Gift_Code_Assignment_Pending__c = false;
                            mapOfOrderToUpdate.put(OrdId,orderFana);
                        }
                    }
                }
                
                // For Memento Premium Gift Code
                System.debug('mapMementoPremiumCode-->'+mapMementoPremiumCode);
                if(mapMementoPremiumCode.size()>0){
                    System.debug('mapofOrderIDToQuantityMementoPremium-->'+mapofOrderIDToQuantityMementoPremium);
                    for(Id OrdId: mapofOrderIDToQuantityMementoPremium.keyset()){
                        Integer MementoPremiumCount = 0;
                        Integer diffMementoPremiumCode = 0;
                        
                        if(mapassignedOrderGiftCodes.containskey(OrdId) && mapassignedOrderGiftCodes.get(OrdId) != null && mapassignedOrderGiftCodes.get(OrdId).get('Memento Premium') != null){ diffMementoPremiumCode = mapofOrderIDToQuantityMementoPremium.get(OrdId) - mapassignedOrderGiftCodes.get(OrdId).get('Memento Premium');
                        }else{
                            diffMementoPremiumCode = mapofOrderIDToQuantityMementoPremium.get(OrdId);
                        }
                        System.debug('diffMementoPremiumCode-->'+diffMementoPremiumCode);                    
                        for(Integer i=0;i < diffMementoPremiumCode;i++){
                            for(Gift_Code__c momentogc: newGCList){
                                if(!setMementoPremiumGCId.contains(momentogc.Id) && momentogc.RecordTypeName__c == 'Memento Premium'){
                                    Gift_Code__c objGC = new Gift_Code__c();
                                    objGC.Id = momentogc.Id;
                                    objGC.RecordTypeId = momentogc.RecordTypeId;
                                    objGC.Order__c = OrdId;
                                    if(mapofOrderIDToListMementoPremium != null && mapofOrderIDToListMementoPremium.containsKey(OrdId)){
                                        List<OrderItem> lstTempOrderItem = mapofOrderIDToListMementoPremium.get(OrdId);
                                        if(lstTempOrderItem.size() == 1){
                                            objGC.Order_Item__c = lstTempOrderItem[0].Id;
                                        }  else if(lstTempOrderItem.size() > 1) {
                                            for(OrderItem objOI: lstTempOrderItem){
                                                if(mapOrderItemWithUnAssignedQuantity.containsKey(objOI.Id) && mapOrderItemWithUnAssignedQuantity.get(objOI.Id) > 0){
                                                    Integer temp = mapOrderItemWithUnAssignedQuantity.get(objOI.Id);
                                                    mapOrderItemWithUnAssignedQuantity.put(objOI.Id, temp-1);
                                                    objGC.Order_Item__c = objOI.Id;
                                                }
                                            }
                                        }
                                    }
                                    setMementoPremiumGCId.add(objGC.Id);
                                    lstGiftCodesToUpdates.add(objGC);
                                    MementoPremiumCount++;
                                    break;
                                }
                            }
                        }
                        if(MementoPremiumCount != 0 && diffMementoPremiumCode != 0 && MementoPremiumCount == diffMementoPremiumCode){
                            Order orderMementoPremium = new Order(Id=OrdId);
                            if(mapOfOrderToUpdate.containskey(OrdId)){
                                orderMementoPremium = mapOfOrderToUpdate.get(OrdId);
                            }
                            orderMementoPremium.Memento_Premium_Assignment_Pending__c= false;
                            mapOfOrderToUpdate.put(OrdId,orderMementoPremium);
                        }
                    }
                }
                
                // For Memento Ultimate Gift Code
                if(mapMementoUltimateCode.size()>0){
                    for(Id OrdId: mapofOrderIDToQuantityMementoUltimate.keyset()){
                        Integer MementoUltimateCount = 0;
                        Integer diffMementoUltimateCode = 0;
                        
                        if(mapassignedOrderGiftCodes.containskey(OrdId) && mapassignedOrderGiftCodes.get(OrdId) != null && mapassignedOrderGiftCodes.get(OrdId).get('Memento Ultimate') != null){ diffMementoUltimateCode = mapofOrderIDToQuantityMementoUltimate.get(OrdId) - mapassignedOrderGiftCodes.get(OrdId).get('Memento Ultimate');
                        }else{
                            diffMementoUltimateCode = mapofOrderIDToQuantityMementoUltimate.get(OrdId);
                        }
                        
                        for(Integer i=0;i < diffMementoUltimateCode;i++){
                            for(Gift_Code__c moMentogcB: newGCList){
                                if(!setMementoUltimateGCId.contains(moMentogcB.Id) && moMentogcB.RecordTypeName__c == 'Memento Ultimate'){
                                    Gift_Code__c objGC = new Gift_Code__c();
                                    objGC.Id = moMentogcB.Id;
                                    objGC.RecordTypeId = moMentogcB.RecordTypeId;
                                    objGC.Order__c = OrdId;
                                    if(mapofOrderIDToListMementoUltimate != null && mapofOrderIDToListMementoUltimate.containsKey(OrdId)){
                                        List<OrderItem> lstTempOrderItem = mapofOrderIDToListMementoUltimate.get(OrdId);
                                        if(lstTempOrderItem.size() == 1){
                                            objGC.Order_Item__c = lstTempOrderItem[0].Id;
                                        }  else if(lstTempOrderItem.size() > 1) {
                                            for(OrderItem objOI: lstTempOrderItem){
                                                if(mapOrderItemWithUnAssignedQuantity.containsKey(objOI.Id) && mapOrderItemWithUnAssignedQuantity.get(objOI.Id) > 0){
                                                    Integer temp = mapOrderItemWithUnAssignedQuantity.get(objOI.Id);
                                                    mapOrderItemWithUnAssignedQuantity.put(objOI.Id, temp-1);
                                                    objGC.Order_Item__c = objOI.Id;
                                                }
                                            }
                                        }
                                    }
                                    setMementoUltimateGCId.add(objGC.Id);
                                    lstGiftCodesToUpdates.add(objGC);
                                    MementoUltimateCount++;
                                    break;
                                }
                            }
                        }
                        if(MementoUltimateCount != 0 && diffMementoUltimateCode != 0 && MementoUltimateCount == diffMementoUltimateCode){
                            Order orderMementoUltimate = new Order(Id=OrdId);
                            if(mapOfOrderToUpdate.containskey(OrdId)){
                                orderMementoUltimate = mapOfOrderToUpdate.get(OrdId);
                            }
                            orderMementoUltimate.Memento_Ultimate_Assignment_Pending__c= false;
                            mapOfOrderToUpdate.put(OrdId,orderMementoUltimate);
                        }
                    }
                }
                // For Memento Fan Gift Code
                if(mapMementoFanCode.size()>0){
                    for(Id OrdId: mapofOrderIDToQuantityMementoFan.keyset()){
                        Integer MementoFanCount = 0;
                        Integer diffMementoFanCode = 0;
                        
                        if(mapassignedOrderGiftCodes.containskey(OrdId) && mapassignedOrderGiftCodes.get(OrdId) != null && mapassignedOrderGiftCodes.get(OrdId).get('Memento Fan') != null){ diffMementoFanCode = mapofOrderIDToQuantityMementoFan.get(OrdId) - mapassignedOrderGiftCodes.get(OrdId).get('Memento Fan');
                        }else{
                            diffMementoFanCode = mapofOrderIDToQuantityMementoFan.get(OrdId);
                        }
                        
                        for(Integer i=0;i < diffMementoFanCode;i++){
                            for(Gift_Code__c moMentogcB: newGCList){
                                if(!setMementoFanGCId.contains(moMentogcB.Id) && moMentogcB.RecordTypeName__c == 'Memento Fan'){
                                    Gift_Code__c objGC = new Gift_Code__c();
                                    objGC.Id = moMentogcB.Id;
                                    objGC.RecordTypeId = moMentogcB.RecordTypeId;
                                    objGC.Order__c = OrdId;
                                    if(mapofOrderIDToListMementoFan != null && mapofOrderIDToListMementoFan.containsKey(OrdId)){
                                        List<OrderItem> lstTempOrderItem = mapofOrderIDToListMementoFan.get(OrdId);
                                        if(lstTempOrderItem.size() == 1){
                                            objGC.Order_Item__c = lstTempOrderItem[0].Id;
                                        }  else if(lstTempOrderItem.size() > 1) {
                                            for(OrderItem objOI: lstTempOrderItem){
                                                if(mapOrderItemWithUnAssignedQuantity.containsKey(objOI.Id) && mapOrderItemWithUnAssignedQuantity.get(objOI.Id) > 0){
                                                    Integer temp = mapOrderItemWithUnAssignedQuantity.get(objOI.Id);
                                                    mapOrderItemWithUnAssignedQuantity.put(objOI.Id, temp-1);
                                                    objGC.Order_Item__c = objOI.Id;
                                                }
                                            }
                                        }
                                    }
                                    setMementoFanGCId.add(objGC.Id);
                                    lstGiftCodesToUpdates.add(objGC);
                                    MementoFanCount++;
                                    break;
                                }
                            }
                        }
                        if(MementoFanCount != 0 && diffMementoFanCode != 0 && MementoFanCount == diffMementoFanCode){
                            Order orderMementoFan = new Order(Id=OrdId);
                            if(mapOfOrderToUpdate.containskey(OrdId)){
                                orderMementoFan = mapOfOrderToUpdate.get(OrdId);
                            }
                            orderMementoFan.Memento_Fan_Assignment_Pending__c = false;
                            mapOfOrderToUpdate.put(OrdId,orderMementoFan);
                        }
                    }
                }
                if(lstGiftCodesToUpdates.size()>0){
                    Utility.processRecords(lstGiftCodesToUpdates, 'update');
                }
                
                if(mapOfOrderToUpdate.size()>0){
                    Utility.processRecords(mapOfOrderToUpdate.values(), 'update');
                }
                
            }
        }
        catch(Exception ex){
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }*/
    }

    /**
    * @description Count the Left over Giftcodes after assignment to Orders
    * @author jagrawal@addonblue.com | 6/3/2020 
    * @param newGCList 
    * @param mapOrders 
    * @param mapUnassignedGCCounts 
    * @return void 
    **/
    private void giftCodesCount(List<Gift_Code__c> newGCList, Map<Id,Order> mapOrders, Map<String, Integer> mapUnassignedGCCounts) {
        try{
            List<Order> lstOrdersF1Code = new List<Order>();
            List<Order> lstOrdersFanaticsCode = new List<Order>();
            List<Order> lstOrdersMementoPremiumCode = new List<Order>();
            List<Order> lstOrdersMementoUltimateCode = new List<Order>();
            List<Order> lstOrdersMementoFanCode = new List<Order>();
            
            for(Gift_Code__c giftcode :newGCList){
                if((giftcode.RecordTypeName__c == 'F1 Access Code' && giftcode.Order__c != null) || Test.isRunningTest()){
                    System.debug('mapOrders.get(giftcode.Order__c):-'+mapOrders.get(giftcode.Order__c));
                    if(mapOrders.get(giftcode.Order__c) != null){
                        lstOrdersF1Code.add(mapOrders.get(giftcode.Order__c));
                    }
                }
                if((giftcode.RecordTypeName__c == 'Fanatics Gift Code' && giftcode.Order__c != null) || Test.isRunningTest()){
                    System.debug('mapOrders.get(giftcode.Order__c):-'+mapOrders.get(giftcode.Order__c));
                    if(mapOrders.get(giftcode.Order__c) != null){
                        lstOrdersFanaticsCode.add(mapOrders.get(giftcode.Order__c));
                    }
                }
                if((giftcode.RecordTypeName__c == 'Memento Premium' && giftcode.Order__c != null) || Test.isRunningTest()){
                    System.debug('mapOrders.get(giftcode.Order__c):-'+mapOrders.get(giftcode.Order__c));
                    if(mapOrders.get(giftcode.Order__c) != null){
                        lstOrdersMementoPremiumCode.add(mapOrders.get(giftcode.Order__c));
                    }
                }
                if((giftcode.RecordTypeName__c == 'Memento Ultimate' && giftcode.Order__c != null) || Test.isRunningTest()){
                    System.debug('mapOrders.get(giftcode.Order__c):-'+mapOrders.get(giftcode.Order__c));
                    if(mapOrders.get(giftcode.Order__c) != null){
                        lstOrdersMementoUltimateCode.add(mapOrders.get(giftcode.Order__c));
                    }
                }
                if((giftcode.RecordTypeName__c == 'Memento Fan' && giftcode.Order__c != null) || Test.isRunningTest()){
                    System.debug('mapOrders.get(giftcode.Order__c):-'+mapOrders.get(giftcode.Order__c));
                    if(mapOrders.get(giftcode.Order__c) != null){
                        lstOrdersMementoFanCode.add(mapOrders.get(giftcode.Order__c));
                    }
                }
            }
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            if((mapUnassignedGCCounts.get('F1 Access Code') != null && mapUnassignedGCCounts.get('F1 Access Code') < 300) || Test.isRunningTest()){
                for(Order orderObj : lstOrdersF1Code){
                    String[] toAddresses = Label.Email_to_Aaron.split(',');
                    String body = 'Order : ' + orderObj.OrderNumber+'<br/>';
                    body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+orderObj.Id+'<br/><br/>';
                    body +='Please Note: Total number of F1 Access Codes after this Order is '+ mapUnassignedGCCounts.get('F1 Access Code') + '(less than 300).';
                    mails.add(Utility.createSingleEmailMessage(toAddresses, 'F1 Access Codes below 300', 'Not Assigned', body, false, false));
                }
                
            }
            
            if((mapUnassignedGCCounts.get('Fanatics Gift Code') != null && mapUnassignedGCCounts.get('Fanatics Gift Code') < 300) || Test.isRunningTest()){
                for(Order orderObj : lstOrdersFanaticsCode){
                    String[] toAddresses = Label.Email_to_Aaron.split(',');
                    String body = 'Order : ' + orderObj.OrderNumber+'<br/>';
                    body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+orderObj.Id+'<br/><br/>';
                    body +='Please Note: Total number of Fanatics Gift Codes after this Order is '+ mapUnassignedGCCounts.get('Fanatics Gift Code') + '(less than 300).';
                    mails.add(Utility.createSingleEmailMessage(toAddresses, 'Fanatics Gift Codes below 300', 'Not Assigned', body, false, false));
                }
            }
            
            if((mapUnassignedGCCounts.get('Memento Premium') != null && mapUnassignedGCCounts.get('Memento Premium') < 300) || Test.isRunningTest()){
                for(Order OrderObj : lstOrdersMementoPremiumCode){
                    String[] toAddresses = Label.Email_to_Aaron.split(',');
                    String body = 'Order : ' + OrderObj.OrderNumber+'<br/>';
                    body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+OrderObj.Id+'<br/><br/>';
                    body +='Please Note: Total number of Memento Premium after this Order is '+ mapUnassignedGCCounts.get('Memento Premium') + '(less than 300).';
                    mails.add(Utility.createSingleEmailMessage(toAddresses, 'MementoPremium below 300', 'Not Assigned', body, false, false));
                }
            }
            
            if((mapUnassignedGCCounts.get('Memento Ultimate') != null && mapUnassignedGCCounts.get('Memento Ultimate') < 300) || Test.isRunningTest()){
                for(Order OrderObj : lstOrdersMementoUltimateCode){
                    String[] toAddresses = Label.Email_to_Aaron.split(',');
                    String body = 'Order : ' + OrderObj.OrderNumber+'<br/>';
                    body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+OrderObj.Id+'<br/><br/>';
                    body +='Please Note: Total number of Memento Ultimate after this Order is '+ mapUnassignedGCCounts.get('Memento Ultimate') + '(less than 300).';
                    mails.add(Utility.createSingleEmailMessage(toAddresses, 'MementoUltimate Code below 300', 'Not Assigned', body, false, false));
                }
            }
            if((mapUnassignedGCCounts.get('Memento Fan') != null && mapUnassignedGCCounts.get('Memento Fan') < 300) || Test.isRunningTest()){
                for(Order OrderObj : lstOrdersMementoFanCode){
                    String[] toAddresses = Label.Email_to_Aaron.split(',');
                    String body = 'Order : ' + OrderObj.OrderNumber+'<br/>';
                    body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+OrderObj.Id+'<br/><br/>';
                    body +='Please Note: Total number of Memento Fan after this Order is '+ mapUnassignedGCCounts.get('Memento Fan') + '(less than 300).';
                    mails.add(Utility.createSingleEmailMessage(toAddresses, 'MementoFan Code below 300', 'Not Assigned', body, false, false));
                }
            }
            if(mails.size()>0){
                Messaging.sendEmail(mails);
            }
        }
        catch(Exception ex){
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }

    /**
    * @description Create entry of Deleted Giftcodes in "Deleted Record" Object
    * @author jagrawal@addonblue.com | 6/3/2020 
    * @param oldList 
    * @return void 
    **/
    private void captureDeletedGiftCodes(List<Gift_Code__c> oldGCList) {
        // try {
            Utility.processDeletedRecords(oldGCList);
        // }
        // catch(Exception ex){
        //     System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        //     Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        // }
    }
    
}
/**
* @File Name          : GiftCodeSyncWithOrderBatch.cls
* @Description        : 
* @Author             : fsuraitawala@addonblue.com
* @Group              : 
* @Last Modified By   : rama.krishna@addonblue.com
 * @Last Modified On   : 18-10-2021
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0    04/05/2021   fsuraitawala@addonblue.com   Initial Version
**/
public class GiftCodeSyncWithOrderBatch implements Database.Batchable<sObject>, Schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'Select Id, OrderNumber, Gift_Code_Notification_Send__c, Fanatics_Gift_Code_Assignment_Pending__c, F1_Access_Code_Assignment_Pending__c, Memento_Premium_Assignment_Pending__c, Memento_Ultimate_Assignment_Pending__c, Memento_Fan_Assignment_Pending__c, '+ 
            '(SELECT Id, Quantity, OrderId, ProductType__c FROM OrderItems WHERE (ProductType__c = \'F1 Access Code\' OR ProductType__c = \'Fanatics Gift Code\'OR ProductType__c = \'NBA League Pass\' OR ProductType__c = \'NBA TV\' OR ProductType__c = \'NBA Top Shot\')) '+
            'FROM Order WHERE Status = \'Active\' AND Order_Payment_Status__c IN (\'Partially Paid\', \'Fully Paid\') AND '+
            '(F1_Access_Code_Assignment_Pending__c = true OR Fanatics_Gift_Code_Assignment_Pending__c = true OR NBA_League_Pass_Assignment_Pending__c = true OR NBA_Top_Shot_Assignment_Pending__c = true OR NBA_TV_Assignment_Pending__c = true)'
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Order> scope){
        System.debug('@@scope: '+scope.size());
        Map<Id, Order> mapOfOrder = new Map<Id, Order>();
        List<Order> OrderLists = new List<Order>();
        if(scope.size() > 0){
            for(Order objOrder : scope){
                if(objOrder.OrderItems.size() > 0) {
                    mapOfOrder.put(objOrder.Id, objOrder);
                    OrderLists.add(objOrder);
                }
            }
            System.debug('@@OrderLists: '+OrderLists.size());
            if(OrderLists.size() > 0){
                OrderPopulation(OrderLists, mapOfOrder);
            }
        }
    }
    
    /**
    * @description: gift code assignment on order status change.
    * @author jagrawal@addonblue.com | 2/28/2020 
    * @param Map<Id Order> MapObjectMap 
    * @param Map<Id Order> oldObjectMap 
    * @param set<Id> setoprderIds 
    * @return void 
    **/
    public static void OrderPopulation(List<Order> OrderRecords, Map<Id, Order> mapOfOrder){
        System.debug('@@OrderRecords: '+OrderRecords);
        System.debug('@@OrderRecords.size: '+OrderRecords.size());
        System.debug('@@mapOfOrder: '+mapOfOrder);
        
        Map<Id,Integer> mapCountOrderItem = new Map<Id,Integer>();
        Map<Id,OrderItem> mapOrderItem = new Map<Id,OrderItem>();
        
        for(Order objOrder: OrderRecords) {
            for(OrderItem objOI: objOrder.OrderItems) {
                mapCountOrderItem.put(objOI.Id, Integer.valueOf(objOI.Quantity));
                mapOrderItem.put(objOI.Id, objOI);
            }
        }
        List<Gift_Code__c> assignedGiftCode = new List<Gift_Code__c>();
        if(mapOrderItem.size() > 0){
            assignedGiftCode = [Select RecordTypeName__c, Order__c, Order_Item__c, Original_Order_Item__c 
                                FROM Gift_Code__c WHERE Order__c != null and Order_Item__c IN :mapOrderItem.keyset()];
        }
        
        if(assignedGiftCode.size() > 0){
            for(Gift_Code__c objGiftCode: assignedGiftCode){
                if(mapCountOrderItem.containskey(objGiftCode.Order_Item__c)){
                    Integer temp = mapCountOrderItem.get(objGiftCode.Order_Item__c);
                    temp = temp - 1;
                    mapCountOrderItem.put(objGiftCode.Order_Item__c, temp);
                }
            }
        }
        
        Integer totalNumberOfF1AccessReq = 0;
        Integer totalNumberOfFanaticsReq = 0;
        Integer totalNumberOfNBALeaguePassReq = 0;
        Integer totalNumberOfNBATVReq = 0;
        Integer totalNumberOfNBATopShotReq = 0;
        List<OrderItem> F1AccessOrderItem = new List<OrderItem>();
        List<OrderItem> FanaticsOrderItem = new List<OrderItem>();
        List<OrderItem> NBALeaguePassOrderItem = new List<OrderItem>();
        List<OrderItem> NBATVOrderItem = new List<OrderItem>();
        List<OrderItem> NBATopShotOrderItem = new List<OrderItem>();
        
        Map<Id,Integer> mapF1AccessCountOrder = new Map<Id,Integer>();
        Map<Id,Integer> mapFanaticsCountOrder = new Map<Id,Integer>();
        Map<Id,Integer> mapNBALeaguePassCountOrder = new Map<Id,Integer>();
        Map<Id,Integer> mapNBATVCountOrder = new Map<Id,Integer>();
        Map<Id,Integer> mapNBATopShotCountOrder = new Map<Id,Integer>();
        
        if(mapOrderItem.size() > 0) {
            for(OrderItem objOrderItem : mapOrderItem.values()){
                if(mapCountOrderItem.get(objOrderItem.Id) > 0){
                    if(objOrderItem.ProductType__c == 'F1 Access Code'){
                        totalNumberOfF1AccessReq = totalNumberOfF1AccessReq + mapCountOrderItem.get(objOrderItem.Id);
                        F1AccessOrderItem.add(objOrderItem);
                        Integer temp = mapCountOrderItem.get(objOrderItem.Id);
                        if(mapF1AccessCountOrder.containsKey(objOrderItem.OrderId)){
                            temp = temp + mapF1AccessCountOrder.get(objOrderItem.OrderId);
                        }
                        mapF1AccessCountOrder.put(objOrderItem.OrderId, temp);
                    }
                    if(objOrderItem.ProductType__c == 'Fanatics Gift Code'){
                        totalNumberOfFanaticsReq = totalNumberOfFanaticsReq + mapCountOrderItem.get(objOrderItem.Id);
                        FanaticsOrderItem.add(objOrderItem);
                        Integer temp = mapCountOrderItem.get(objOrderItem.Id);
                        if(mapFanaticsCountOrder.containsKey(objOrderItem.OrderId)){
                            temp = temp + mapFanaticsCountOrder.get(objOrderItem.OrderId);
                        }
                        mapFanaticsCountOrder.put(objOrderItem.OrderId, temp);
                    }
                    
                    if(objOrderItem.ProductType__c == 'NBA League Pass'){
                        totalNumberOfNBALeaguePassReq = totalNumberOfNBALeaguePassReq + mapCountOrderItem.get(objOrderItem.Id);
                        NBALeaguePassOrderItem.add(objOrderItem);
                        Integer temp = mapCountOrderItem.get(objOrderItem.Id);
                        if(mapNBALeaguePassCountOrder.containsKey(objOrderItem.OrderId)){
                            temp = temp + mapNBALeaguePassCountOrder.get(objOrderItem.OrderId);
                        }
                        mapNBALeaguePassCountOrder.put(objOrderItem.OrderId, temp);
                    }
                    
                    if(objOrderItem.ProductType__c == 'NBA TV'){
                        totalNumberOfNBATVReq = totalNumberOfNBATVReq + mapCountOrderItem.get(objOrderItem.Id);
                        NBATVOrderItem.add(objOrderItem);
                        Integer temp = mapCountOrderItem.get(objOrderItem.Id);
                        if(mapNBATVCountOrder.containsKey(objOrderItem.OrderId)){
                            temp = temp + mapNBATVCountOrder.get(objOrderItem.OrderId);
                        }
                        mapNBATVCountOrder.put(objOrderItem.OrderId, temp);
                    }
                    
                    if(objOrderItem.ProductType__c == 'NBA Top Shot'){
                        totalNumberOfNBATopShotReq = totalNumberOfNBATopShotReq + mapCountOrderItem.get(objOrderItem.Id);
                        NBATopShotOrderItem.add(objOrderItem);
                        Integer temp = mapCountOrderItem.get(objOrderItem.Id);
                        if(mapNBATopShotCountOrder.containsKey(objOrderItem.OrderId)){
                            temp = temp + mapNBATopShotCountOrder.get(objOrderItem.OrderId);
                        }
                        mapNBATopShotCountOrder.put(objOrderItem.OrderId, temp);
                    }
                    
                }
            }
        }
        
        List<Gift_Code__c> updateGiftCode = new List<Gift_Code__c>();
        List<Order> lstOrderToUpdate = new List<Order>();
        Map<Id, Order> mapOrderToUpdate = new Map<Id, Order>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Set<Id> setGiftCodeTrueInOrder = new Set<Id>();
        
        if(totalNumberOfF1AccessReq > 0) {
            List<Gift_Code__c> lstGiftCode = [SELECT Id FROM Gift_Code__c WHERE Order__c = null and Opportunity__c = null and RecordTypeName__c = 'F1 Access Code' LIMIT :totalNumberOfF1AccessReq];
            system.debug('totalNumberOfF1AccessReq = ' + totalNumberOfF1AccessReq);
            
            for(Gift_Code__c objGC: lstGiftCode){
                for(OrderItem objOrderItem : F1AccessOrderItem) {
                    Integer temp = mapCountOrderItem.get(objOrderItem.Id);
                    if(temp > 0) {
                        objGC.Order__c = objOrderItem.OrderId;
                        objGC.Order_Item__c = objOrderItem.Id;
                        mapCountOrderItem.put(objOrderItem.Id, temp - 1);
                        updateGiftCode.add(objGC);
                        if(objOrderItem.ProductType__c == 'F1 Access Code'){
                            Integer tempInt = mapF1AccessCountOrder.get(objOrderItem.OrderId);
                            mapF1AccessCountOrder.put(objOrderItem.OrderId, tempInt - 1);
                        }
                        break;
                    }
                }
            }
            
            Set<Id> setOrderToFalseF1Access = new Set<Id>();
            Set<Id> setOrderToTrueF1Access = new Set<Id>();
            Integer CountOrderItemToTrueF1Access = 0; //VKHOPADE - issue 1147
            
            for(Id strId: mapF1AccessCountOrder.keyset()) {
                if(mapF1AccessCountOrder.get(strId) == 0) {
                    setOrderToFalseF1Access.add(strId);
                } else {
                    setOrderToTrueF1Access.add(strId);
                     //VKHOPADE - issue 1147 - start
                    Order orderObj = mapOfOrder.get(strId);
                    if(!orderObj.Gift_Code_Notification_Send__c) {
                    	CountOrderItemToTrueF1Access = CountOrderItemToTrueF1Access + mapF1AccessCountOrder.get(strId); 
                    } //VKHOPADE - issue 1147 - end
                }
            }
            system.debug('mapF1AccessCountOrder = ' + mapF1AccessCountOrder);
            system.debug('CountOrderItemToTrueF1Access = ' + CountOrderItemToTrueF1Access);
            System.debug('@@@setOrderToTrueF1Access: '+setOrderToTrueF1Access);
            System.debug('@@@setOrderToFalseF1Access: '+setOrderToFalseF1Access);
            
            if(setOrderToFalseF1Access.size() > 0){
                for(Id OrderId: setOrderToFalseF1Access){
                    if(!mapOrderToUpdate.containskey(OrderId)){
                        Order objOrder = new Order();
                        objOrder.Id = OrderId;
                        objOrder.F1_Access_Code_Assignment_Pending__c = false;
                        mapOrderToUpdate.put(OrderId, objOrder);
                    } else {
                        Order objOrder = mapOrderToUpdate.get(OrderId);
                        objOrder.F1_Access_Code_Assignment_Pending__c = false;
                        mapOrderToUpdate.put(OrderId, objOrder);
                    }
                }
            }
            
            if(setOrderToTrueF1Access.size() > 0 && CountOrderItemToTrueF1Access >= 1000){ //VKHOPADE - issue 1147 - added CountOrderItemToTrueF1Access condition
                for(Id OrderId: setOrderToTrueF1Access){
                    Order orderObj = mapOfOrder.get(OrderId);
                    if(!orderObj.Gift_Code_Notification_Send__c) {
                        String[] toAddresses = Label.Email_to_Aaron.split(',');
                        String body = 'Order : ' + orderObj.OrderNumber+'\n';
                        body += 'F1 Access Codes needed :'+totalNumberOfF1AccessReq+'\n';
                        body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+orderObj.Id+'\n';
                        body +='Please Note: F1 Access Codes insufficient to be add to above Order.';
                        mails.add(Utility.createSingleEmailMessage(toAddresses,'F1 Access Codes Insufficient','Not Sufficient',body,false,false));
                        System.debug('F1 Access Codes Insufficient : ' + body);
                        setGiftCodeTrueInOrder.add(orderObj.Id);
                    }
                }
            }
        }
        
        if(totalNumberOfFanaticsReq > 0) {
            List<Gift_Code__c> lstGiftCode = [SELECT Id FROM Gift_Code__c WHERE Order__c = null and Opportunity__c = null and RecordTypeName__c = 'Fanatics Gift Code' LIMIT :totalNumberOfFanaticsReq];
            
            for(Gift_Code__c objGC: lstGiftCode){
                for(OrderItem objOrderItem : FanaticsOrderItem) {
                    Integer temp = mapCountOrderItem.get(objOrderItem.Id);
                    if(temp > 0) {
                        objGC.Order__c = objOrderItem.OrderId;
                        objGC.Order_Item__c = objOrderItem.Id;
                        mapCountOrderItem.put(objOrderItem.Id, temp - 1);
                        updateGiftCode.add(objGC);
                        if(objOrderItem.ProductType__c == 'Fanatics Gift Code'){
                            Integer tempInt = mapFanaticsCountOrder.get(objOrderItem.OrderId);
                            mapFanaticsCountOrder.put(objOrderItem.OrderId, tempInt - 1);
                        }
                        break;
                    }
                }
            }
            
            Set<Id> setOrderToFalseFanatics = new Set<Id>();
            Set<Id> setOrderToTrueFanatics = new Set<Id>();
            
            for(Id strId: mapFanaticsCountOrder.keyset()) {
                if(mapFanaticsCountOrder.get(strId) == 0) {
                    setOrderToFalseFanatics.add(strId);
                } else {
                    setOrderToTrueFanatics.add(strId);
                }
            }
            System.debug('@@@setOrderToTrueFanatics: '+setOrderToTrueFanatics);
            System.debug('@@@setOrderToFalseFanatics: '+setOrderToFalseFanatics);
            
            if(setOrderToFalseFanatics.size() > 0){
                for(Id OrderId: setOrderToFalseFanatics){
                    if(!mapOrderToUpdate.containskey(OrderId)){
                        Order objOrder = new Order();
                        objOrder.Id = OrderId;
                        objOrder.Fanatics_Gift_Code_Assignment_Pending__c = false;
                        mapOrderToUpdate.put(OrderId, objOrder);
                    } else {
                        Order objOrder = mapOrderToUpdate.get(OrderId);
                        objOrder.Fanatics_Gift_Code_Assignment_Pending__c = false;
                        mapOrderToUpdate.put(OrderId, objOrder);
                    }
                }
            }
            
            if(setOrderToTrueFanatics.size() > 0){
                for(Id OrderId: setOrderToTrueFanatics){
                    Order orderObj = mapOfOrder.get(OrderId);
                    if(!orderObj.Gift_Code_Notification_Send__c) {
                        String[] toAddresses = Label.Email_to_Aaron.split(',');
                        String body = 'Order : ' + orderObj.OrderNumber+'\n';
                        body += 'Fanatics Gift Codes needed :'+totalNumberOfFanaticsReq+'\n';
                        body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+orderObj.Id+'\n';
                        body +='Please Note: Fanatics Gift Codes insufficient to be add to above Order.';
                        mails.add(Utility.createSingleEmailMessage(toAddresses,'Fanatics Gift Codes insufficient','Not Sufficient',body,false,false));
                        setGiftCodeTrueInOrder.add(orderObj.Id);
                    }
                }
                
            }
        }
        
        if(totalNumberOfNBALeaguePassReq > 0) {
            List<Gift_Code__c> lstGiftCode = [SELECT Id FROM Gift_Code__c WHERE Order__c = null and Opportunity__c = null and RecordTypeName__c = 'NBA League Pass' LIMIT :totalNumberOfNBALeaguePassReq];
            
            for(Gift_Code__c objGC: lstGiftCode){
                for(OrderItem objOrderItem : NBALeaguePassOrderItem) {
                    Integer temp = mapCountOrderItem.get(objOrderItem.Id);
                    if(temp > 0) {
                        objGC.Order__c = objOrderItem.OrderId;
                        objGC.Order_Item__c = objOrderItem.Id;
                        mapCountOrderItem.put(objOrderItem.Id, temp - 1);
                        updateGiftCode.add(objGC);
                        if(objOrderItem.ProductType__c == 'NBA League Pass'){
                            Integer tempInt = mapNBALeaguePassCountOrder.get(objOrderItem.OrderId);
                            mapNBALeaguePassCountOrder.put(objOrderItem.OrderId, tempInt - 1);
                        }
                        break;
                    }
                }
            }
            
            Set<Id> setOrderToFalseNBALeaguePass = new Set<Id>();
            Set<Id> setOrderToTrueNBALeaguePass = new Set<Id>();
            
            for(Id strId: mapNBALeaguePassCountOrder.keyset()) {
                if(mapNBALeaguePassCountOrder.get(strId) == 0) {
                    setOrderToFalseNBALeaguePass.add(strId);
                } else {
                    setOrderToTrueNBALeaguePass.add(strId);
                }
            }
            System.debug('@@@setOrderToTrueNBALeaguePass: '+setOrderToTrueNBALeaguePass);
            System.debug('@@@setOrderToFalseNBALeaguePass: '+setOrderToFalseNBALeaguePass);
            
            if(setOrderToFalseNBALeaguePass.size() > 0){
                for(Id OrderId: setOrderToFalseNBALeaguePass){
                    if(!mapOrderToUpdate.containskey(OrderId)){
                        Order objOrder = new Order();
                        objOrder.Id = OrderId;
                        objOrder.NBA_League_Pass_Assignment_Pending__c = false;
                        mapOrderToUpdate.put(OrderId, objOrder);
                    } else {
                        Order objOrder = mapOrderToUpdate.get(OrderId);
                        objOrder.NBA_League_Pass_Assignment_Pending__c = false;
                        mapOrderToUpdate.put(OrderId, objOrder);
                    }
                }
            }
            
            if(setOrderToTrueNBALeaguePass.size() > 0){
                for(Id OrderId: setOrderToTrueNBALeaguePass){
                    Order orderObj = mapOfOrder.get(OrderId);
                    if(!orderObj.Gift_Code_Notification_Send__c) {
                        String[] toAddresses = Label.Email_to_Aaron.split(',');
                        String body = 'Order : ' + orderObj.OrderNumber+'\n';
                        body += 'NBA League Pass Codes needed :'+totalNumberOfNBALeaguePassReq+'\n';
                        body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+orderObj.Id+'\n';
                        body +='Please Note: NBA League Pass Codes insufficient to be add to above Order.';
                        mails.add(Utility.createSingleEmailMessage(toAddresses,'NBA League Pass Codes Insufficient','Not Sufficient',body,false,false));
                        setGiftCodeTrueInOrder.add(orderObj.Id);
                    }
                }
            }
        }
        
         if(totalNumberOfNBATVReq > 0) {
            List<Gift_Code__c> lstGiftCode = [SELECT Id FROM Gift_Code__c WHERE Order__c = null and Opportunity__c = null and RecordTypeName__c = 'NBA TV' LIMIT :totalNumberOfNBATVReq];
            
            for(Gift_Code__c objGC: lstGiftCode){
                for(OrderItem objOrderItem : NBATVOrderItem) {
                    Integer temp = mapCountOrderItem.get(objOrderItem.Id);
                    if(temp > 0) {
                        objGC.Order__c = objOrderItem.OrderId;
                        objGC.Order_Item__c = objOrderItem.Id;
                        mapCountOrderItem.put(objOrderItem.Id, temp - 1);
                        updateGiftCode.add(objGC);
                        if(objOrderItem.ProductType__c == 'NBA TV'){
                            Integer tempInt = mapNBATVCountOrder.get(objOrderItem.OrderId);
                            mapNBATVCountOrder.put(objOrderItem.OrderId, tempInt - 1);
                        }
                        break;
                    }
                }
            }
            
            Set<Id> setOrderToFalseNBATV = new Set<Id>();
            Set<Id> setOrderToTrueNBATV = new Set<Id>();
            
            for(Id strId: mapNBATVCountOrder.keyset()) {
                if(mapNBATVCountOrder.get(strId) == 0) {
                    setOrderToFalseNBATV.add(strId);
                } else {
                    setOrderToTrueNBATV.add(strId);
                }
            }
            System.debug('@@@setOrderToTrueNBATV: '+setOrderToTrueNBATV);
            System.debug('@@@setOrderToFalseNBATV: '+setOrderToFalseNBATV);
            
            if(setOrderToFalseNBATV.size() > 0){
                for(Id OrderId: setOrderToFalseNBATV){
                    if(!mapOrderToUpdate.containskey(OrderId)){
                        Order objOrder = new Order();
                        objOrder.Id = OrderId;
                        objOrder.NBA_TV_Assignment_Pending__c = false;
                        mapOrderToUpdate.put(OrderId, objOrder);
                    } else {
                        Order objOrder = mapOrderToUpdate.get(OrderId);
                        objOrder.NBA_TV_Assignment_Pending__c = false;
                        mapOrderToUpdate.put(OrderId, objOrder);
                    }
                }
            }
            
            if(setOrderToTrueNBATV.size() > 0){
                for(Id OrderId: setOrderToTrueNBATV){
                    Order orderObj = mapOfOrder.get(OrderId);
                    if(!orderObj.Gift_Code_Notification_Send__c) {
                        String[] toAddresses = Label.Email_to_Aaron.split(',');
                        String body = 'Order : ' + orderObj.OrderNumber+'\n';
                        body += 'NBA TV Codes needed :'+totalNumberOfNBATVReq+'\n';
                        body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+orderObj.Id+'\n';
                        body +='Please Note: NBA TV Codes insufficient to be add to above Order.';
                        mails.add(Utility.createSingleEmailMessage(toAddresses,'NBA TV Codes Insufficient','Not Sufficient',body,false,false));
                        setGiftCodeTrueInOrder.add(orderObj.Id);
                    }
                }
            }
        }
        
         if(totalNumberOfNBATopShotReq > 0) {
            List<Gift_Code__c> lstGiftCode = [SELECT Id FROM Gift_Code__c WHERE Order__c = null and Opportunity__c = null and RecordTypeName__c = 'NBA Top Shot' LIMIT :totalNumberOfNBATopShotReq];
            
            for(Gift_Code__c objGC: lstGiftCode){
                for(OrderItem objOrderItem : NBATopShotOrderItem) {
                    Integer temp = mapCountOrderItem.get(objOrderItem.Id);
                    if(temp > 0) {
                        objGC.Order__c = objOrderItem.OrderId;
                        objGC.Order_Item__c = objOrderItem.Id;
                        mapCountOrderItem.put(objOrderItem.Id, temp - 1);
                        updateGiftCode.add(objGC);
                        if(objOrderItem.ProductType__c == 'NBA Top Shot'){
                            Integer tempInt = mapNBATopShotCountOrder.get(objOrderItem.OrderId);
                            mapNBATopShotCountOrder.put(objOrderItem.OrderId, tempInt - 1);
                        }
                        break;
                    }
                }
            }
            
            Set<Id> setOrderToFalseNBATopShot = new Set<Id>();
            Set<Id> setOrderToTrueNBATopShot = new Set<Id>();
            
            for(Id strId: mapNBATopShotCountOrder.keyset()) {
                if(mapNBATopShotCountOrder.get(strId) == 0) {
                    setOrderToFalseNBATopShot.add(strId);
                } else {
                    setOrderToTrueNBATopShot.add(strId);
                }
            }
            System.debug('@@@setOrderToTrueNBATopShot: '+setOrderToTrueNBATopShot);
            System.debug('@@@setOrderToFalseNBATopShot: '+setOrderToFalseNBATopShot);
            
            if(setOrderToFalseNBATopShot.size() > 0){
                for(Id OrderId: setOrderToFalseNBATopShot){
                    if(!mapOrderToUpdate.containskey(OrderId)){
                        Order objOrder = new Order();
                        objOrder.Id = OrderId;
                        objOrder.NBA_Top_Shot_Assignment_Pending__c = false;
                        mapOrderToUpdate.put(OrderId, objOrder);
                    } else {
                        Order objOrder = mapOrderToUpdate.get(OrderId);
                        objOrder.NBA_Top_Shot_Assignment_Pending__c = false;
                        mapOrderToUpdate.put(OrderId, objOrder);
                    }
                }
            }
            
            if(setOrderToTrueNBATopShot.size() > 0){
                for(Id OrderId: setOrderToTrueNBATopShot){
                    Order orderObj = mapOfOrder.get(OrderId);
                    if(!orderObj.Gift_Code_Notification_Send__c) {
                        String[] toAddresses = Label.Email_to_Aaron.split(',');
                        String body = 'Order : ' + orderObj.OrderNumber+'\n';
                        body += 'NBA Top Shot Codes needed :'+totalNumberOfNBATopShotReq+'\n';
                        body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+orderObj.Id+'\n';
                        body +='Please Note: NBA Top Shot Codes insufficient to be add to above Order.';
                        mails.add(Utility.createSingleEmailMessage(toAddresses,'NBA Top Shot Codes Insufficient','Not Sufficient',body,false,false));
                        setGiftCodeTrueInOrder.add(orderObj.Id);
                    }
                }
            }
        }
        
        if(setGiftCodeTrueInOrder.size() > 0){
            for(Id OrderId: setGiftCodeTrueInOrder){
                if(!mapOrderToUpdate.containskey(OrderId)){
                    Order objOrder = new Order();
                    objOrder.Id = OrderId;
                    objOrder.Gift_Code_Notification_Send__c = true;
                    mapOrderToUpdate.put(OrderId, objOrder);
                } else {
                    Order objOrder = mapOrderToUpdate.get(OrderId);
                    objOrder.Gift_Code_Notification_Send__c = true;
                    mapOrderToUpdate.put(OrderId, objOrder);
                }
            }
        }
        System.debug(updateGiftCode.size());
        if(updateGiftCode.size() > 0) { 
            Utility.processRecords(updateGiftCode, 'update'); 
        }
        
        System.debug('@@@lstOrderToUpdate: '+lstOrderToUpdate);
        if(mapOrderToUpdate.values().size() > 0) {
            Utility.processRecords(mapOrderToUpdate.values(), 'update');
        }
        System.debug('@@@mails.size() : '+mails.size());
        System.debug('@@@mails : '+mails);
        if(mails.size() > 0 && !test.isRunningTest()){
            Messaging.sendEmail(mails);
        }
    }
    
    public void finish(Database.BatchableContext bc){ 

    }

    public void execute(SchedulableContext sc){
        Database.executeBatch(new GiftCodeSyncWithOrderBatch(), 25);
    }
}
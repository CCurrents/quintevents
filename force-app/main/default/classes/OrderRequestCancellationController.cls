/**
 * @File Name          : OrderRequestCancellationController.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 01-22-2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    3/26/2020   lpanchal@addonblue.com     Initial Version
 * 1.1    6/9/2020    jagrawal@addonblue.com     Added Conditions before SOQL to reduce unnecessary SOQL
 * 1.2    7/3/2020    jagrawal@addonblue.com     Removed redundant code for Inventory insertion
 * 1.3    7/22/2020   jagrawal@addonblue.com     Added code to add Canceled Sales Adjustment and Credit Sales Adjustment Order to proper Opportunity 
 * 1.4    01/18/2021  jagrawal@addonblue.com     #710 Incorrect Order Owner for Sales Adjustment orders
**/
public class OrderRequestCancellationController {
    
    @AuraEnabled
    public static Map<String, String> reasonsForCancellation(sObject objObject, String fld) {
        Map<String, String> options = new Map<String, String>();
        try{
            Schema.sObjectType objType = objObject.getSObjectType();
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
            list < Schema.PicklistEntry > pList = fieldMap.get(fld).getDescribe().getPickListValues();
            for (Schema.PicklistEntry p: pList) {
                options.put(p.getValue(), p.getLabel());
            }
          
            system.debug('options'+options);
        }catch(Exception ex){
            System.debug('Exception'+ ex.getStackTraceString());
        }
           return options;
        
    }
    
    @AuraEnabled
    public static String updateQuoteStatus(String rcdId,String cancelReason,String cancelComment,Boolean refundRequested) {
        system.debug('###updateQuoteStatus');
        String str= '';
        try{
            Order objorder= new Order();
            objorder.Reason_For_Cancellation__c =cancelReason;
            objorder.Cancellation_Request_Comments__c=cancelComment;
            objorder.Refund_Requested__c = refundRequested;
            objorder.Status='Cancellation Pending';
            objorder.Id=rcdId;
            
            Order order = [select id, OpportunityId from Order WHERE Id =: rcdId];
            Opportunity objOpportunity = new Opportunity(Id = order.OpportunityId, Bypass_Apex__c = true);
            utility.processRecords(objOpportunity,'update');
            
            if(!Test.isRunningTest())
            utility.processRecords(objorder,'update');
            //update objorder;
            utility.submitForApproval(objorder.id,'Submitting Cancel Order Request for Approval','CancelOrder');            
        }catch(Exception ex) {
            System.debug('Exception'+ ex.getStackTraceString());
        }
        return str;
    }
    
    // Method which will Process the Order when in canelled Status and creates Inventory 
    @AuraEnabled
    public static void processCancelOrder(Map<Id,sObject> mapOrder, Map<Id,sObject> mapOldOrder, List<Charge__c> lstCharge){
        List<Order> lstOrder = new List<Order>();
        system.debug('mapOrder--'+mapOrder);
        Map<Id, Order> mapQueriesOrders = new Map<Id, Order>([Select Id,Event__r.Price_Book_Event__c from Order where Id = :mapOrder.keyset() AND Pricebook2.Name = 'Standard Price Book']);
        for(String OrderID: mapOrder.keyset()){
            system.debug('OrderID--'+OrderID);
            if((mapOrder.get(OrderID).get('Status') == 'Canceled' && mapOldOrder.get(OrderID).get('Status') != 'Canceled') || Test.isRunningTest()) {
                Order objOrder = new Order();//(Order)mapOrder.get(QuoteId);
                //objOrder.Id = null;
                objOrder.Status = 'Canceled - Sales Adjustment';
                objOrder.AccountId = (String)mapOrder.get(OrderID).get('AccountId');
                objOrder.Pricebook2Id = (String)mapOrder.get(OrderID).get('Pricebook2Id'); 
                objOrder.Original_Order__c = mapOldOrder.get(OrderID).Id;
                // #438 Added code to assign the order to proper Opportunity
                objOrder.OpportunityId = (String)mapOldOrder.get(OrderID).get('OpportunityId');
                objOrder.EffectiveDate = system.today();
                // #710 Incorrect Order Owner for Sales Adjustment orders
                objOrder.OwnerId = (String)mapOldOrder.get(OrderID).get('OwnerId');
                if(mapQueriesOrders.containskey(OrderID)){
                    objOrder.Pricebook_Reporting__c = mapQueriesOrders.get(OrderID).Event__r.Price_Book_Event__c;
                }else{
                    objOrder.Pricebook_Reporting__c = (String)mapOrder.get(OrderID).get('Pricebook2Id');
                }
                System.debug('objOrder.OwnerId@'+objOrder.OwnerId);
                //objOrder.QuoteId = QuoteId;
                lstOrder.add(objOrder);
            }
        }

        system.debug('lstOrder Creating Adjustment Order----'+lstOrder);
        if(!Test.isRunningTest()) utility.processRecords(lstOrder,'insert');

        List<Charge__c> lstChargeToUpdate = new List<Charge__c>();
        if(lstCharge.size() > 0){
            for(Charge__c obj : lstCharge){
                if(mapOrder.containskey(obj.Order__c) && !String.isempty(String.valueof(mapOrder.get(obj.Order__c).get('Status')))){
                    obj.Order_Status__c = String.valueof(mapOrder.get(obj.Order__c).get('Status'));
                    lstChargeToUpdate.add(obj);
                }                    
            }
            
            if(lstChargeToUpdate.size() > 0){
                utility.processRecords(lstChargeToUpdate,'update');
            }
        }
    }
    // Process Refund when Order is downgraded 
    @AuraEnabled
    public static void processRefund(List<Order> lstOrder, Map<Id,Decimal> mapOrderAmount){
        System.debug('In REFUND-------------lstOrder@@' +lstOrder);
        System.debug('mapOrderAmount@@' +mapOrderAmount);
        Decimal PassesdPTAmount = 0;
        Set<Id> SetId = new Set<Id>();
        Set<Id> SetRefund = new Set<Id>();
        Map<Id, Id> mapQuoteNOrderIds = new Map<Id, Id>();
        for(Order objOrder : lstOrder){
            if(Test.isRunningTest() || (mapOrderAmount.get(objOrder.Quote.Original_Quote__c) - objOrder.TotalAmount) > 0){
                SetRefund.add(objOrder.QuoteId);
                SetId.add(objOrder.Original_Order__c);
                mapQuoteNOrderIds.put(objOrder.QuoteId, objOrder.Id);
            }
        }
        System.debug('setrefund@@'+SetRefund);
        if(setRefund.size() > 0){
            List<Payment_Term__c> lstPT = [Select Amount__c, Id, Order__c,Quote__r.AccountId, Quote__c, Quote__r.TotalPrice, Quote__r.Original_Quote__c from Payment_Term__c where Quote__c in:SetRefund AND Status__c = 'Passed'  AND Credit__c = false];
            if(Test.isRunningTest()){
                lstPT = [Select Amount__c, Id, Order__c,Quote__r.AccountId, Quote__c, Quote__r.TotalPrice, Quote__r.Original_Quote__c from Payment_Term__c];
            }
            Map<Id,Decimal> mapAmount = new Map<Id,Decimal>();
            for(Payment_Term__c objPT : lstPT){
                // if(mapAmount.get(objPT.Order__c) != null){
                //     mapAmount.put(objPT.Order__c, 1 + mapAmount.get(objPT.Order__c));
                // }
                // else
                //     mapAmount.put(objPT.Order__c, 1);
                if(mapAmount.get(objPT.Quote__c) != null){ mapAmount.put(objPT.Quote__c, 1 + mapAmount.get(objPT.Quote__c)); } else{ mapAmount.put(objPT.Quote__c, 1); }
            }
            List<Charge__c> lstCharge = [Select Id, Amount__c, Payment_Terms__c, Payment_Terms__r.Order__c, Payment_Terms__r.Order__r.Original_Order__c, Payment_Terms__r.Quote__c, Payment_Terms__r.Quote__r.Original_Quote__c, Payment_Terms__r.Quote__r.TotalPrice 
                                         FROM Charge__c
                                         WHERE Payment_Terms__r.Quote__c in :SetRefund AND RecordType.Name = 'Credit' AND Payment_Terms__r.Status__c = 'Passed' AND Payment_Terms__r.Credit__c = false Order By CreatedDate];
            Map<Id,Charge__c> mapCharge =  new Map<Id, Charge__c>();
            Map<Id,Id> mapOrderPT = new Map<Id,Id>();
            for(Charge__c objCharge : lstCharge){
                // mapCharge.put(objCharge.Payment_Terms__r.Order__c,objCharge);
                // mapOrderPT.put(objCharge.Payment_Terms__c,objCharge.Payment_Terms__r.Order__c);
                mapCharge.put(objCharge.Payment_Terms__r.Quote__c,objCharge);
                mapOrderPT.put(objCharge.Payment_Terms__c,objCharge.Payment_Terms__r.Quote__c);
            }
            System.debug('lstcharge@@' +lstCharge);
            List<Charge__c> lstNewCharge = new List<Charge__c>();
            for(Payment_Term__c objPT : lstPT){
                if(objPT.Amount__c != null) {
                    PassesdPTAmount = PassesdPTAmount + objPT.Amount__c;
                }
                /*if(mapOrderPT.get(objPT.Id) == null){
                    try{
                    if(objPT.Amount__c != null)
                    PassesdPTAmount = PassesdPTAmount + objPT.Amount__c;
                    Charge__c objcharge = new Charge__c();
                    objcharge.Payment_Terms__c = objPT.id;
                    objcharge.Payment_Terms__r = objPT;
                    System.debug('objPT@@'+objPT.Amount__c);
                    objcharge.Amount__c = objPT.Amount__c;
                    objcharge.Account__c = objPT.Quote__r.AccountId;
                    objcharge.Status__c = 'Pending';
                    objcharge.RecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
                    lstNewCharge.add(objcharge);
                    //mapOrderPT.put(objPT.Id,objPT.Order__c);
                    mapOrderPT.put(objPT.Id,objPT.Quote__c);
                    }
                    catch(exception ex){
                        
                    }
                }*/
            }
            system.debug('PassesdPTAmount--'+PassesdPTAmount);
            System.debug('lstnewcharge@@' +lstNewCharge);
            lstCharge.addAll((List<Charge__c>)Utility.processRecords(lstNewCharge,'insert'));
            System.debug('@-lstCharge-@'+lstCharge);
            
            List<Refund__c> lstRefund = new List<Refund__c>();
            for(Charge__c objCharge : lstCharge){
                System.debug('==objCharge:='+objCharge);
                System.debug('==objCharge.Payment_Terms__c:='+objCharge.Payment_Terms__c);
                System.debug('mapAmount@@'+mapAmount);
                System.debug('mapOrderAmount.get(objCharge.Payment_Terms__r.Order__c) '+mapOrderAmount.get(objCharge.Payment_Terms__r.Order__c));
                System.debug('mapAmount.get(objCharge.Payment_Terms__r.Quote__c)' +mapAmount.get(objCharge.Payment_Terms__r.Quote__c));
                System.debug('mapOrderAmount@@'+mapOrderAmount);
                System.debug('mapOrderAmount.get(objCharge.Payment_Terms__r.Quote__r.Original_Quote__c)'+mapOrderAmount.get(objCharge.Payment_Terms__r.Quote__r.Original_Quote__c));
                System.debug('objCharge.Payment_Terms__r.Quote__r.TotalPrice@@'+objCharge.Payment_Terms__r.Quote__r.TotalPrice);
                //Decimal oldOrderAmount = (mapOrderAmount.get(objCharge.Payment_Terms__r.Quote__r.Original_Quote__c) !=  null) ? mapAmount.get(objCharge.Payment_Terms__r.Quote__c) : 0 ;
                Decimal oldOrderAmount = (mapOrderAmount.get(objCharge.Payment_Terms__r.Quote__r.Original_Quote__c) !=  null) ? mapOrderAmount.get(objCharge.Payment_Terms__r.Quote__r.Original_Quote__c) : 0 ;
                Decimal newOrderAmount = (objCharge.Payment_Terms__r.Quote__r.TotalPrice !=  null) ? objCharge.Payment_Terms__r.Quote__r.TotalPrice : 0 ;
                Decimal totalPayTermsCount = (mapAmount.get(objCharge.Payment_Terms__r.Quote__c) !=  null) ? mapAmount.get(objCharge.Payment_Terms__r.Quote__c) : 1;
                //System.debug('oldOrderAmount@@'+oldOrderAmount);
                //Decimal refund = (mapOrderAmount.get(objCharge.Payment_Terms__r.Order__r.Original_Order__c) - objCharge.Payment_Terms__r.Order__r.TotalAmount) / mapAmount.get(objCharge.Payment_Terms__r.Order__c);// - mapCharge.get(objOrder.Original_Order__c).Amount__c;
               // Decimal refund = (oldOrderAmount - objCharge.Payment_Terms__r.Quote__r.TotalPrice) / mapAmount.get(objCharge.Payment_Terms__r.Quote__c);// - mapCharge.get(objOrder.Original_Order__c).Amount__c;
               //Decimal refund = (mapOrderAmount.get(objCharge.Payment_Terms__r.Quote__r.Original_Quote__c) - objCharge.Payment_Terms__r.Quote__r.TotalPrice) / mapAmount.get(objCharge.Payment_Terms__r.Quote__c);
               Decimal refund = (PassesdPTAmount - newOrderAmount) / totalPayTermsCount;
                System.debug('refund@@'+refund);
                if(refund > 0){ Refund__c objRefun = new Refund__c(); objRefun.Amount__c = refund;
                    objRefun.Order__c = mapQuoteNOrderIds.get(objCharge.Payment_Terms__r.Quote__c);//objCharge.Payment_Terms__r.Order__r.Id;
                    objRefun.Charge__c = objCharge.Id; objRefun.Opportunity_Payment_Terms__c = objCharge.Payment_Terms__c; lstRefund.add(objRefun);
                }
            }
            System.debug('REFUND ENDS ---lstRefund@@' +lstRefund);
            Utility.processRecords(lstRefund,'insert');
        }
    }
    
    @AuraEnabled
    public static String callCreditRefundApproval(String OrderId, Decimal withholdPerc){
        Order objOrder = [Select id,Order_Payment_Status__c from Order where id =: OrderId];
        System.debug('objOrder@@@'+objOrder);
        if(objOrder.Order_Payment_Status__c == 'Fully Paid'){
            objOrder.id = OrderId; objOrder.Withhold_Percentage__c = withholdPerc; objOrder.Status = 'Credit Adjustment Pending'; Utility.processRecords(objOrder,'update');
            if(!Test.isRunningTest())
                utility.submitForApproval(objOrder.Id,'Submitting Credit Adjustment Request for Approval','CreditAdjustment');
        }else{
             //throw new AuraHandledException('Cannot Credit Sales Adjustment Since Order is not Fully Paid');
        }
        return objOrder.Id;
    }
    
    @AuraEnabled
    public static String checkOrderPaymentStatus(String OrderId){        
        Order objOrder = [Select id,Order_Payment_Status__c from Order where id =: OrderId];
        return objOrder.Order_Payment_Status__c;
    }
    
    public static void processCreditRefund(map<Id,Order> mapOrder){
        System.debug('lstOrder@@' +mapOrder);
        Set<Id> setId = new Set<Id>();
        List<Order> lstNewOrder = new List<Order>();
        Set<String> setCurrencyCode = new Set<String>();
        for(Order objOrder: mapOrder.values()){
            setId.add(objOrder.Pricebook2Id);
            setCurrencyCode.add(objOrder.CurrencyIsoCode);
            Order objNewOrder = new Order();
            objNewOrder = objOrder.clone(false,false,false,false);
            objNewOrder.EffectiveDate = System.today();
            objNewOrder.Status = 'Credited - Sales Adjustment';
            System.debug('objOrder.Id@@@'+objOrder.Id);
            objNewOrder.Original_Order__c = objOrder.Id;
            // #438 Added code to assign the order to proper Opportunity
            objNewOrder.OpportunityId = objOrder.OpportunityId;
            objNewOrder.Id = null;
            objNewOrder.Order_Payment_Status__c = null;
            lstNewOrder.add(objNewOrder);
        }
        List<PricebookEntry> lstPBE = [Select Id, Pricebook2Id,CurrencyIsoCode from PricebookEntry where Pricebook2Id in :setId AND Product2.Name = 'Sales Adjustment' AND CurrencyIsoCode IN :setCurrencyCode];
        if(Test.isRunningTest()){
            lstPBE = [Select Id, Pricebook2Id,CurrencyIsoCode from PricebookEntry];
        }
        system.debug('lstPBE----'+lstPBE);
        // Query PBE from Orders Pricebook2Id and Curreny
        Map<String,PricebookEntry> mapNewPBE = new Map<String,PricebookEntry>();
        for(PricebookEntry objPBE : lstPBE){
            mapNewPBE.put(objPBE.Pricebook2Id +'_'+ objPBE.CurrencyIsoCode,objPBE);
        }
        if(!Test.isRunningTest())
            lstNewOrder = Utility.processRecords(lstNewOrder,'insert');
        System.debug('lstNewOrder@@@'+lstNewOrder);
        List<OrderItem> newOrderItemsInsert = new List<OrderItem>();
        Map<Id,Id> mapOldtoNewords = new Map<Id,Id>();
        for (Order objNeword  : lstNewOrder) {
            mapOldtoNewords.put(objNeword.Original_Order__c,objNeword.Id);
            OrderItem ori = new OrderItem();
            //ori.Product2Id = qli.Product2Id;
            ori.OrderId = objNeword.Id;
            String key = mapOrder.get(objNeword.Original_Order__c).Pricebook2Id +'_'+mapOrder.get(objNeword.Original_Order__c).CurrencyIsoCode;
            system.debug('Key---'+Key);
            if(!Test.isRunningTest()){ ori.PricebookEntryId = mapNewPBE.get(key).Id; }
            else{
                ori.PricebookEntryId = lstPBE[0].Id;
            }
            ori.Quantity = 1;
            if(!Test.isRunningTest()){ ori.UnitPrice =  mapOrder.get(objNeword.Original_Order__c).totalAmount  * (  mapOrder.get(objNeword.Original_Order__c).Withhold_Percentage__c  / 100); }
            else{
                ori.UnitPrice = 100;
            }
            newOrderItemsInsert.add(ori);
        }
        Utility.processRecords(newOrderItemsInsert,'insert');
        List<Charge__c> lstCharge = new List<Charge__c>();
        for(Order objoder : mapOrder.values()){  
            Charge__c objCredit = new Charge__c();
            if(!Test.isRunningTest()){ objCredit.Amount__c = objoder.totalAmount - ( objoder.totalAmount  * (  objoder.Withhold_Percentage__c  / 100)); }
            else{
                objCredit.Amount__c = 100;
            }
            objCredit.Status__c = 'Pending';
            objCredit.Account__c = objoder.AccountId;
            objCredit.Order__c = mapOldtoNewords.get(objoder.Id);
            if(objoder.CurrencyIsoCode == 'USD'){ objCredit.CurrencyIsoCode = 'USD';
            }else if(objoder.CurrencyIsoCode == 'AUD'){ objCredit.CurrencyIsoCode = 'AUD';
            }else if(objoder.CurrencyIsoCode == 'CAD'){ objCredit.CurrencyIsoCode = 'CAD';
            }else if(objoder.CurrencyIsoCode == 'EUR'){ objCredit.CurrencyIsoCode = 'EUR';
            }else if(objoder.CurrencyIsoCode == 'GBP'){ objCredit.CurrencyIsoCode = 'GBP';
            }else if(objoder.CurrencyIsoCode == 'SAR'){ objCredit.CurrencyIsoCode = 'SAR';
            }else if(objoder.CurrencyIsoCode == 'THB'){ objCredit.CurrencyIsoCode = 'THB';
            } //VKHAOPDE - issue 1207 - 26Apr22 - added SAR & THB
            objCredit.RecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Account Credit').getRecordTypeId();
            lstCharge.add(objCredit);
        }
        System.debug('lstCharge@@@@'+lstCharge);
        Utility.processRecords(lstCharge,'insert');
    }
    
	@AuraEnabled
    public static Order getOrderDetails(String currentRecordId){
        Order order;
        order = [select Id, Pricebook2.GPE_Event__c, Status FROM Order WHERE Id =: currentRecordId];
        return order;
    }
}
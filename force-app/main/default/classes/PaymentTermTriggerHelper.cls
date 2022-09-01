/**
 * @File Name          : PaymentTermTriggerHelper.cls
 * @Description        : Trigger helper on Opportunity payment term object and calling from the OpportunityPaymentTermTriggerHandler
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 02-24-2022
 * @Modification Log   : 
 * Ver       Date            Author                         Modification
 * 1.0    9/26/2019     fsuraitawala@addonblue.com      Initial Version
 * 1.1    2/3/2020      mpatel@addonblue.com            Refactored the code by changing the structure of the code as per the standards
 * 1.2    04/29/2020    kchavda@addonblue.com           Added Collected Revenue calculation functionality
 * 1.3    08/19/2020    kchavda@addonblue.com           #505 GPT - Online Order Related Changes
 * 1.4    08/24/2020    jagrawal@addonblue.com          #509 Added Code for deducting Refund amount from Collected Revenue
 * 1.5    09/02/2020    jagrawal@addonblue.com          #518 Added Code to populate revenue related fields on Order
 * 1.6    09/10/2020    jagrawal@addonblue.com          #518 Fixed RecorType issue for Collected Revenue
 * 1.7    09/21/2020    kchavda@addonblue.com           #542 Revenue fields on Order
 * 1.8    12/16/2020    kchavda@addonblue.com           #647 Create credit Memo in Intacct for Canceled Payments
 * 1.9    10/08/2020    jagrawal@addonblue.com          #574 Code Optimization and cleanup for the trigger 
 * 2.0    04/21/2021    kchavda@addonblue.com           #853 Order Payment status and Sum of Payment terms not being rolled for few orders 
 * 2.0    12/15/2021    rama.krishna@addonblue.com      #1130 If the amount on Payment term is changed, related charge amount should also be updated 
**/

public with sharing class PaymentTermTriggerHelper{
    private Map<Id, Payment_Term__c> newOPTMap; 
    private Map<Id, Payment_Term__c> oldOPTMap;
    private List<Payment_Term__c> newOPTList;
    private List<Payment_Term__c> oldOPTList;
    private Map<Id, Order> mapOrdersToUpdate;
    
    public PaymentTermTriggerHelper(){
        Utility.getSOQLCount();
        Utility.getTriggerSize();
        this.newOPTMap = (Map<Id, Payment_Term__c>) Trigger.newMap;
        this.oldOPTMap = (Map<Id, Payment_Term__c>) Trigger.oldMap;
        this.newOPTList = (List<Payment_Term__c>) Trigger.new;
        this.oldOPTList = (List<Payment_Term__c>) Trigger.old;
        this.mapOrdersToUpdate = new Map<Id, Order>();
    
        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
            }
            when BEFORE_UPDATE {
            }
            when BEFORE_DELETE {
                if(UserInfo.getProfileId()!=[select id,name from Profile where Name='System Administrator'].Id){
                  paymentTermDeleteCheck(oldOPTList);
                }
            }
            when AFTER_INSERT {
                
                Set<Id> orderIdset = new Set<Id>();
                Set<Id> orderRevenueIds = new Set<Id>();                
                Set<Id> setQuoteIdForInitialPTs = new Set<Id>();
                
                List<Payment_Term__c> lstPaymentTerms = [SELECT Id,Name,Status__c,Record_Id__c,Intacct_Status__c,Requested_Due_Date__c,
                                                        Opportunity__r.PriceBook2.Name, Opportunity__c,Opportunity__r.PriceBook2.GPE_Event__c,
                                                        Order__c,RecordTypeId,Amount__c, Order__r.Pricebook2.GPT_Event_Id__c, Quote__c 
                                                        FROM Payment_Term__c WHERE Id IN: newOPTMap.keySet()];

                for(Payment_Term__c opt: lstPaymentTerms){
                    //#893 "Initial Payment Term" change on Payment Term object -- START
                    if(opt.Quote__c != null){
                        setQuoteIdForInitialPTs.add(opt.Quote__c);
                    }
                    // #518 Added condition check for the Order on Payment Term
                    if(opt.Status__c == 'Passed' || opt.Order__c != null){
                        orderRevenueIds.add(opt.Order__c);
                    }
                    if(opt.Order__c != null) orderIdset.add(opt.Order__c);                                                     
                }

                createCreditMemoinIntacct(newOPTList,oldOPTMap);
                
                if(!orderRevenueIds.isEmpty()){
                    calculateCollectedRevenue(orderRevenueIds);
                    System.debug('collected revenue mapOrdersToUpdate-->'+this.mapOrdersToUpdate);
                }

                if(orderIdset.size() > 0){
                    List<Order> PayTermsLst = new List<Order>([Select Id,Order_Payment_Status__c,Subject_to_Cancellation__c, 
                            (Select Id, Opportunity__c,Status__c From Payment_Terms__r) From Order Where Id in : orderIdset]);

                    if(PayTermsLst.size() > 0){ 
                        updateOrderpayStatus(PayTermsLst); 
                    }
                    System.debug('payment status mapOrdersToUpdate-->'+this.mapOrdersToUpdate);
                }
                
                //#512 Added by Manan Patel
                if(!this.mapOrdersToUpdate.values().isEmpty()){
                    Utility.processRecords(this.mapOrdersToUpdate.values(), 'update');
                }
                //#893 "Initial Payment Term" change on Payment Term object
                if(setQuoteIdForInitialPTs.size() > 0){
                    updateInitialPTsForOnlineOrder(setQuoteIdForInitialPTs);
                }               
            }
            
            when AFTER_UPDATE {
                
                Set<id> orderIdList = new set<id>();
                Set<Id> orderRevenueIds = new Set<Id>();                
                Set<Id> setQuoteIdForInitialPTs = new Set<Id>();
                Set<Id> ptIds = new Set<Id>();
                Set<Id> applyAddjustmentPtIds = new Set<Id>(); 
                Set<Id> ptIdsToUpdateAmount = new Set<Id>();             

                // #509 Added Code for deducting Refund amount from Collected Revenue -- START
                List<Payment_Term__c> lstPaymentTerms = [SELECT Id, Name, Status__c, Record_Id__c, Commission__c, Intacct_Status__c, Commission_Paid__c, Intacct_Adjustment_Id__c, Opportunity__r.PriceBook2.Name,
                                                            Requested_Due_Date__c,Opportunity__c,Opportunity__r.PriceBook2.GPE_Event__c,
                                                            Order__c,RecordTypeId,Amount__c, Total_Refund_Amount__c, Order__r.Pricebook2.GPT_Event_Id__c, Quote__c, Intacct_Id__c
                                                            FROM Payment_Term__c WHERE Id IN: newOPTMap.keySet()];
                // #509 Added Code for deducting Refund amount from Collected Revenue -- END
                
                 
                
                for(Payment_Term__c opt: lstPaymentTerms) {  
                    
                    System.debug('PT New Status:'+opt.Status__c+' Old Status:'+oldOPTMap.get(opt.Id).Status__c);
                    System.debug('PT New Order:'+opt.Order__c+' Old Order:'+oldOPTMap.get(opt.id).Order__c);
                    if((opt.Status__c != oldOPTMap.get(opt.Id).Status__c) || (opt.Order__c != null && opt.Order__c != oldOPTMap.get(opt.id).Order__c)){
                        orderIdList.add(opt.Order__c);
                    }
                    // #509 Added Code for deducting Refund amount from Collected Revenue -- START
                    System.debug('@@opt.Total_Refund_Amount__c:-'+opt.Total_Refund_Amount__c);
                    System.debug('@@oldopt.Total_Refund_Amount__c:-'+oldOPTMap.get(opt.Id).Total_Refund_Amount__c);
                    // #518 Added condition check for the Amount change on Payment Term
                    // #518 Added condition check for the Order change on Payment Term
                    if(opt.Order__c != oldOPTMap.get(opt.Id).Order__c || opt.Status__c != oldOPTMap.get(opt.Id).Status__c  || opt.Total_Refund_Amount__c != oldOPTMap.get(opt.Id).Total_Refund_Amount__c || opt.Amount__c != oldOPTMap.get(opt.Id).Amount__c){
                        // #509 Added Code for deducting Refund amount from Collected Revenue -- END
                        orderRevenueIds.add(opt.Order__c);
                        // #1130 If the amount on Payment term is changed, related charge amount should also be updated
                        ptIds.add(opt.Id);
                        system.debug('Test PT AMOUNT update == '+ptIds);
                    }
                    //1158
                    if(opt.Order__c !=null && opt.Intacct_Id__c!=null && opt.Amount__c!=null && opt.Amount__c != oldOPTMap.get(opt.Id).Amount__c){
                        ptIdsToUpdateAmount.add(opt.Id);
                        System.debug('@@ amount updated PT Ids ...'+ptIdsToUpdateAmount);
                    }
                    
                    if(opt.Quote__c != null && oldOPTMap.get(opt.Id).Quote__c == null){
                        setQuoteIdForInitialPTs.add(opt.Quote__c); 
                    }
                    //#1150 Apply Adjument
                    if((opt.Record_Id__c != oldOPTMap.get(opt.Id).Record_Id__c) && !String.IsEmpty(opt.Record_Id__c) && opt.Commission__c > 0 && !opt.Commission_Paid__c && opt.Intacct_Adjustment_Id__c == null){
                        applyAddjustmentPtIds.add(opt.Id);
                    }
                }
                
                // #1130 If the amount on Payment term is changed, related charge amount should also be updated
                Map<Id, List<Charge__c>> chargeListByPTId = new Map<Id, List<Charge__c>>();
                for(Charge__c ch : [SELECT Id, Payment_Terms__C, Amount__C  FROM Charge__c WHERE Payment_Terms__C IN: ptIds]){
                 if(chargeListByPTId.containsKey(ch.Payment_Terms__C)){
                 chargeListByPTId.get(ch.Payment_Terms__C).add(ch);
                 }else{
                 List<Charge__c> details = new List<Charge__c>();
                 details.add(ch);
                 chargeListByPTId.put(ch.Payment_Terms__C, details);
                 }
                }

                List<Charge__c> chargeToUpdate = new List<Charge__c>();
                for(Payment_Term__C master : lstPaymentTerms) {
                    if(chargeListByPTId.containsKey(master.Id)){
                        for(Charge__c d : chargeListByPTId.get(master.Id)) {
                            d.Amount__C = master.Amount__c;
                            chargeToUpdate.add(d);
                        }
                    }
                }
                if(chargeToUpdate .size() > 0)
                {
                    update chargeToUpdate ;
                }
                //End #1130 If the amount on Payment term is changed, related charge amount should also be updated
                createCreditMemoinIntacct(newOPTList,oldOPTMap);
                
                if(!orderRevenueIds.isEmpty()) {
                    calculateCollectedRevenue(orderRevenueIds);
                    System.debug('collected revenue mapOrdersToUpdate-->'+this.mapOrdersToUpdate);
                }

                if(!orderIdList.isEmpty()) {
                    List<Order> PayTermsLst = new List<Order>([Select Id,Order_Payment_Status__c,Subject_to_Cancellation__c, 
                        (Select Id, Opportunity__c,Status__c From Payment_Terms__r) From Order Where Id in : orderIdList]);
                    
                    if(PayTermsLst.size() > 0){
                        updateOrderpayStatus(PayTermsLst);
                    }
                    System.debug('payment status mapOrdersToUpdate-->'+this.mapOrdersToUpdate);
                }
               
                //#512 Added by Manan Patel
                if(!this.mapOrdersToUpdate.values().isEmpty()){
                    Utility.processRecords(this.mapOrdersToUpdate.values(), 'update');
                }             
                //#893 "Initial Payment Term" change on Payment Term object
                if(setQuoteIdForInitialPTs.size() > 0){
                    updateInitialPTsForOnlineOrder(setQuoteIdForInitialPTs);
                } 
                //#1150 Apply Adjument
                if(applyAddjustmentPtIds.size() > 0){
                    IntacctAppyAdjustmentBatch objBatch = new IntacctAppyAdjustmentBatch(applyAddjustmentPtIds);
                    Id batchId = Database.executeBatch(objBatch, 1);
                }

                if(ptIdsToUpdateAmount.size() >0){
                    amountUpdatedInIntacct(ptIdsToUpdateAmount);
                }
            }
            when AFTER_DELETE {

                DeleteListOfPaymentTerm(oldOPTList);
                //Calculate collected revenue on related order
                Set<Id> orderRevenueIds = new Set<Id>();
                for(Payment_Term__c opt: oldOPTList){
                    if(opt.Status__c == 'Passed' || opt.Order__c != null){
                        orderRevenueIds.add(opt.order__c);
                    }
                }                
                if(!orderRevenueIds.isEmpty()){
                    calculateCollectedRevenue(orderRevenueIds);
                }                
                //#512 Added by Manan Patel
                if(!this.mapOrdersToUpdate.values().isEmpty()){
                    Utility.processRecords(this.mapOrdersToUpdate.values(), 'update');
                }
            }
            when AFTER_UNDELETE {
                //Calculate collected revenue on related order
                Set<Id> orderRevenueIds = new Set<Id>();
                
                for(Payment_Term__c opt: newOPTList){
                    if(opt.Status__c == 'Passed' || opt.Order__c != null){
                        orderRevenueIds.add(opt.order__c);            
                    }
                }                
                if(!orderRevenueIds.isEmpty()){
                    calculateCollectedRevenue(orderRevenueIds);
                }
                System.debug('In After Undelete!');
                //#512 Added by Manan Patel
                if(!this.mapOrdersToUpdate.values().isEmpty()){
                    Utility.processRecords(this.mapOrdersToUpdate.values(), 'update');
                }
            }
            when else{
                System.debug('Undefined Trigger Operation!');
            }
        }
    }
    /**
    * @description  : this method call after update the payment term record
    * @author       : mpatel@addonblue.com | 1/28/2020 
    * @param        : List<Payment_Term__c> oldOPTList
    * @return       : void 
    **/

    private void deleteListOfPaymentTerm(List<Payment_Term__c> oldOPTList){
        Utility.processDeletedRecords(oldOPTList);
    }

    /**
    * @description  : update the field orddr payment status in the opportunity object
    * @author       : mpatel@addonblue.com | 2/28/2020 
    * @param        : Set<id> opprtIds
    * @return       : void 
    **/

    private void updateOrderpayStatus(List<Order> PayTermsLst) {
        try{
            List<Order> OrderPayStatusList = new List<Order>();
            for(Order objOrder : PayTermsLst){
                integer i = 0;
                integer passSize = 0;
                integer Size = objOrder.Payment_Terms__r.size();
                System.debug('Object@@Paymentterms:--' +objOrder.Payment_Terms__r);
                if(objOrder.Payment_Terms__r != null && objOrder.Payment_Terms__r.size() >0){                                      
                    for(Payment_Term__c oppTerms: objOrder.Payment_Terms__r){
                        if(oppTerms.Status__c != null && oppTerms.status__c == 'Passed') {
                            passSize++;
                        }
                        else if(oppTerms.status__c == null || oppTerms.status__C != 'Passed'){
                            i++;
                        }
                    }
                }
                if(passSize > 0 && passSize < size) {                
                    objOrder.Order_Payment_Status__c = 'Partially Paid';
                    if(objOrder.Subject_to_Cancellation__c == true) {
                        objOrder.Subject_to_Cancellation__c = false;
                    }
                    //#512 Added by Manan Patel                    
                    if(!this.mapOrdersToUpdate.containsKey(objOrder.id)){
                        this.mapOrdersToUpdate.put(objOrder.id, objOrder);
                    }else{
                        this.mapOrdersToUpdate.get(objOrder.id).Subject_to_Cancellation__c = objOrder.Subject_to_Cancellation__c;
                        this.mapOrdersToUpdate.get(objOrder.id).Order_Payment_Status__c = 'Partially Paid';
                    }
                }
                else if(passSize == size) {
                    objOrder.Order_Payment_Status__c = 'Fully Paid';
                    objOrder.Paid_in_Full__c = true;
                    if(objOrder.Subject_to_Cancellation__c == true) {
                        objOrder.Subject_to_Cancellation__c = false;
                    }
                    //#512 Added by Manan Patel                    
                    if(!this.mapOrdersToUpdate.containsKey(objOrder.id)){
                        this.mapOrdersToUpdate.put(objOrder.id, objOrder);
                    }else{
                        this.mapOrdersToUpdate.get(objOrder.id).Subject_to_Cancellation__c = objOrder.Subject_to_Cancellation__c;
                        this.mapOrdersToUpdate.get(objOrder.id).Order_Payment_Status__c = 'Fully Paid';
                        this.mapOrdersToUpdate.get(objOrder.id).Paid_in_Full__c = true;
                    }
                }
                else if(passSize == 0) {
                    objOrder.Order_Payment_Status__c = 'Not Paid';
                    //#512 Added by Manan Patel                    
                    if(!this.mapOrdersToUpdate.containsKey(objOrder.id)){
                        this.mapOrdersToUpdate.put(objOrder.id, objOrder);
                    }else{
                        this.mapOrdersToUpdate.get(objOrder.id).Order_Payment_Status__c = 'Not Paid';
                    }
                }
            }            
        }catch(Exception ex){ Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
    
    /**
  * @description  : calculate Collected Revenue on order
  * @author       : kchavda@addonblue.com | 2/28/2020 
  * @param        : Set<id> opprtIds
  * @return       : void 
  **/
    private void calculateCollectedRevenue(Set<Id> orderIds) {
        try{
            System.debug('orderIds@@'+orderIds);
            if(orderIds.size()>0){
                // #509 Added Code for deducting Refund amount from Collected Revenue -- START
                List<Order> lstorders = new List<Order>([Select id,Collected_Revenue__c, (Select Id, Amount__c,Status__c, Total_Refund_Amount__c, RecordType.Name from Payment_Terms__r where Amount__c != null) from Order where id in: orderIds]);
                System.debug('lstorders@@'+lstorders);
                for(Order objOrder: lstorders){
                    // #518 Added Code to populate revenue related fields on Order -- START
                    Decimal TotalAmount = 0, SumOfRefunds = 0, SumOfCreditPTs = 0, GrossCollected = 0, TotalPTAmount=0;
                    system.debug('@@@odr.Payment_Terms__r =='+objOrder.Payment_Terms__r);
                    for(Payment_Term__c objPT: objOrder.Payment_Terms__r){      
                        // #518 Fixed RecorType issue for Collected Revenue
                        if(objPT.RecordType.Name == 'Master' && objPT.Status__c == 'Passed'){ 
                            if(objPT.Amount__c != NULL){
                                GrossCollected += objPT.Amount__c; TotalAmount += objPT.Amount__c; 
                            }
                            TotalAmount -= objPT.Total_Refund_Amount__c != null ? objPT.Total_Refund_Amount__c : 0;
                        }
                        SumOfRefunds += objPT.Total_Refund_Amount__c != null ? objPT.Total_Refund_Amount__c : 0;
                        if(objPT.RecordType.Name == 'Credit' && objPT.Amount__c !=NULL){ 
                            SumOfCreditPTs += objPT.Amount__c; 
                        }
                        TotalPTAmount += objPT.Amount__c !=NULL ? objPT.Amount__c : 0;
                    }
                    System.debug('TotalAmount@@'+TotalAmount);
                    System.debug('GrossCollected@@'+GrossCollected);
                    System.debug('SumOfCreditPTs@@'+SumOfCreditPTs);
                    objOrder.Collected_Revenue__c = TotalAmount;
                    objOrder.Sum_of_Refunds__c = SumOfRefunds;
                    objOrder.Credit_Applied__c = SumOfCreditPTs;
                    objOrder.Gross_Collected__c = GrossCollected;
                    objOrder.Sum_of_Payment_Terms__c = TotalPTAmount;
                    // #518 Added Code to populate revenue related fields on Order -- END
                    //#512 Added by Manan Patel
                    if(!this.mapOrdersToUpdate.containsKey(objOrder.id)){
                        this.mapOrdersToUpdate.put(objOrder.id, objOrder);
                    }else{
                        this.mapOrdersToUpdate.get(objOrder.id).Collected_Revenue__c = TotalAmount;
                        this.mapOrdersToUpdate.get(objOrder.id).Sum_of_Refunds__c = SumOfRefunds;
                        this.mapOrdersToUpdate.get(objOrder.id).Credit_Applied__c = SumOfCreditPTs;
                        this.mapOrdersToUpdate.get(objOrder.id).Gross_Collected__c = GrossCollected;
                        this.mapOrdersToUpdate.get(objOrder.id).Sum_of_Payment_Terms__c = TotalPTAmount;
                    }
                }
                System.debug('@@lstorders'+lstorders);                
            }
        }catch(Exception ex){ Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }    
     
    
    /**
  * @description  : Create Credit Memo in Intacct
  * @author       : kchavda@addonblue.com | 12/16/2020 
  * @param        : Set<id> opprtIds
  * @return       : void 
  **/
    Public void createCreditMemoinIntacct(List<Payment_Term__c> newPaymentTerms, Map<Id,Payment_Term__c> OldPaymentTermMap) {
        try{
           List<Payment_Term__c> lstPTs = new List<Payment_Term__c>(); 
           for(Payment_Term__c pt: newPaymentTerms){
               if(Trigger.IsInsert && pt.Status__c == 'Canceled' && pt.Record_Id__c != null) lstPTs.add(pt);
               else if(Trigger.Isupdate && pt.Status__c != OldPaymentTermMap.get(pt.id).status__c && pt.Status__c == 'Canceled' && pt.Record_Id__c != null) lstPTs.add(pt);
           }
           
           if(!lstPTs.isempty()){
               for(Payment_Term__c newPt: lstPTs){                   
                    IntacctOrderSyncBatch batch = new IntacctOrderSyncBatch(newPt.Order__c,new list<String> {'Sales Credit Memo'},newPt.Id+'###'+'dummy',false);
                    system.debug('objCharge call---'+batch);
                    Database.executebatch(batch);
               }
           }
        }catch(Exception ex){
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
        
    }
    /**
    * @description  : //#893 "Initial Payment Term" change on Payment Term object -- START
    * @author       : fsuraitawala@addonblue.com | 04/16/2021
    * @param        : Set<id> QuoteIds
    * @return       : void 
    **/
    Public void updateInitialPTsForOnlineOrder(Set<Id> QuoteIds) {
        List<Quote> lstQuote = new List<Quote>();
        List<Payment_Term__c> lstPTs = new List<Payment_Term__c>();
        for(Quote objQuote : [Select Id, (Select Id, Initial_Payment_Term__c, Last_Payment_Term__c FROM Payment_Terms__r WHERE RecordType.Name = 'Master' Order by Payment_Due_Date__c) FROM Quote WHERE Id IN :QuoteIds]) {
            if(objQuote.Payment_Terms__r.size() > 0) {
                integer i = 0;
                Boolean isPTUpdate = true;
                for(Payment_Term__c objPTs: objQuote.Payment_Terms__r) {
                    if(i == 0) {
                        if(objPTs.Initial_Payment_Term__c == false){
                            objPTs.Initial_Payment_Term__c = true;
                            isPTUpdate = true;
                        }
                    } else {
                        if(objPTs.Initial_Payment_Term__c == true){
                            objPTs.Initial_Payment_Term__c = false;
                            isPTUpdate = true;
                        }
                    }
                    if(i == objQuote.Payment_Terms__r.size() - 1){
                        if(objPTs.Last_Payment_Term__c == false){
                            objPTs.Last_Payment_Term__c = true;
                            isPTUpdate = true;
                        }
                    } else {
                        if(objPTs.Last_Payment_Term__c == true){
                            objPTs.Last_Payment_Term__c = false;
                            isPTUpdate = true;
                        }
                    }
                    if(isPTUpdate) {
                        lstPTs.add(objPTs);
                    }
                    i++;
                }
            }
            if(lstPTs.size() > 0) {
                TriggerHandler.bypass('PaymentTermTriggerHandler');
                Utility.processRecords(lstPTs, 'update');
                TriggerHandler.clearBypass('PaymentTermTriggerHandler');
            }
        }
    }
    
    @future(callout=true)
    public static void amountUpdatedInIntacct(Set<Id> ptIds) {
        IntacctOrderSyncBatchHelper intactBatchHelper = null;
        for(Payment_Term__c pt: [SELECT Id, Amount__c, Intacct_Id__c, Order__c from Payment_Term__c where Id IN :ptIds]){
            intactBatchHelper = new IntacctOrderSyncBatchHelper(pt.Order__c,'Sales Invoice');
            intactBatchHelper.updateAmoutOnInvoiceCallout(pt.Id, pt.Intacct_Id__c, String.valueOf(pt.Amount__c));
        }
    }

    /**
    * @description  : //#1249 "Restrict Deletion of  Payment Term" If it is intacct or order exist -- START
    * @author       : ravindra.isakapatla@addonblue.com | 07/04/2022
    * @param        : List<Payment_Term__c> paymentTerms
    * @return       : void 
    **/
    
    public static void paymentTermDeleteCheck(List<Payment_Term__c> paymentTerms){
       Set<Id> orderIds = new Set<Id>();
        for(Payment_Term__c objPTerm : paymentTerms){
            orderIds.add(objPTerm.Order__c);            
        } 
    
        Map<Id,Order> orderMap = new Map<Id,Order>([select id,Record_Id__c,Intacct_Id__c from order where Id In: orderIds and Record_Id__c!=null and Intacct_Id__c!=null]);
        for(Payment_Term__c objPTerm : paymentTerms){
            Order objOrder = orderMap.get(objPterm.Order__c); 
            if((objPTerm.Record_Id__c!=null && objPTerm.Intacct_Id__c!=null) || 
               (objorder!=null && objorder.Record_Id__c!=null && objorder.Intacct_Id__c!=null) ){
              objPterm.addError('Payment Term Cannot be deleted. As Order exists in Intacct.');    
            }
        }
    }
}
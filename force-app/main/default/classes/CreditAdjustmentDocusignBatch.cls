/**
 * @File Name          : CreditAdjustmentDocusignBatch.cls
 * @Description        : To update create order and charge records based on docusign status
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 05-12-2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    05/26/2020  kchavda@addonblue.com     Initial Version
 * 1.1    09/10/2020  kchavda@addonblue.com     #530 CreditAdjustmentBatch Issue
 * 1.2    09/16/2020  kchavda@addonblue.com     #539 Check for collected revenue from Order in the addendum batch
 * 1.3    02/11/2021  kchavda@addonblue.com     #716 Currently we use wording "2021 Event" for credit creation, need to be replaced with "Future Event".
 * 1.4    05/11/2021  fsuraitawala@addonblue.com #945 Need to exclude Protect Group Amount for credit creation process
**/
global class CreditAdjustmentDocusignBatch implements Database.Batchable<sObject>, Database.Stateful {
     //Variable Section
    global FINAL String strQuery;    
    global set<string> EventIds = new set<string>();
    
    global CreditAdjustmentDocusignBatch(string query, set<string> EvtIds) { 
        this.strQuery = query;      
        this.EventIds = EvtIds;       
    }        
        
    //Batch Start method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(strQuery);
    }

    //Batch Execute method calls findCostForWoD method
    global void execute(Database.BatchableContext BC, List<sObject> scopeList) {           
        if(!scopeList.isEmpty()) { 
           
             set<Id> oppIds = new set<Id>();             
             for(dsfs__DocuSign_Status__c ds: (List<dsfs__DocuSign_Status__c>)scopeList){
                 oppIds.add(ds.dsfs__Opportunity__c);
             } 
             
             Map<Id,Opportunity> mapOpps = new Map<Id,Opportunity>([Select Id, OwnerId, Pricebook2.Program__c, Refund_Response__c, Amount, Event__r.Program__c, CurrencyIsoCode, Event__c, Event__r.Program__r.Name, AccountId, Pricebook2.Program__r.Name, Pricebook2Id, Move_to_2020_Credit_Percentage__c, Move_to_2021_Credit_Percentage__c, Collected_Revenue__c, Collected_Revenue_in_USD__c,
                 (Select Id, Status, Collected_Revenue__c, Protect_Group_Amount__c, Exchange_rate__c FROM Orders WHERE Status = 'Active' LIMIT 1), 
                 (Select Id, Status__c FROM Opportunity_Payment_Terms__r WHERE Status__c != 'Passed' and status__c != 'Canceled') 
                  FROM Opportunity WHERE Id IN :oppIds AND StageName = 'Closed Won']);
             set<Id> legacyEventIds = new set<Id>();
             set<Id> PBIds = new set<Id>();
             Set<String> setCurrencyCode = new Set<String>();
             set<Id> OriginalOrderIds = new set<Id>();
             if(mapOpps.size()>0){
                 for(Opportunity op: mapOpps.values()){
                     if(op.Event__c != null){
                         legacyEventIds.add(op.Event__c);                         
                     }
                     if(op.Event__c == null && op.Pricebook2Id != null) PBIds.add(op.Pricebook2Id);
                     setCurrencyCode.add(op.CurrencyIsoCode);
                     if(op.orders != null && op.orders.size()>0) OriginalOrderIds.add(op.orders[0].id);
                 }
             }
             Map<Id,Pricebook2> mapPB = new Map<Id,Pricebook2>([select id,Legacy_Id__c,Move_to_2020_Credit_Percentage__c,Move_to_2021_Credit_Percentage__c from pricebook2 where Legacy_Id__c in: legacyEventIds or id in: PBIds]);
             Map<Id,Pricebook2> mapPBPercentage = new Map<Id,Pricebook2>();
             for(pricebook2 pb: mapPB.values()){
                 if(pb.Legacy_Id__c != null){
                     mapPBPercentage.put(pb.Legacy_Id__c,pb);
                 }
                 mapPBPercentage.put(pb.id,pb);
                 
             }
             List<PricebookEntry> lstPBE = [Select Id, Pricebook2Id,CurrencyIsoCode,Pricebook2.Legacy_Id__c from PricebookEntry where Pricebook2Id in :mapPB.keyset() AND Product2.Name = 'Sales Adjustment' AND CurrencyIsoCode IN :setCurrencyCode];
             Map<string, map<string,PricebookEntry>> mapPBEIds = new Map<string, map<string,PricebookEntry>>();             
             if(lstPBE.size()>0){
                 for(PricebookEntry pbe: lstPBE){
                     if(pbe.Pricebook2.Legacy_Id__c != null){
                         if(!mapPBEIds.containskey(pbe.Pricebook2.Legacy_Id__c)){
                             mapPBEIds.put(pbe.Pricebook2.Legacy_Id__c, new map<string,PricebookEntry>{pbe.CurrencyIsoCode=>pbe});
                         }else{
                             mapPBEIds.get(pbe.Pricebook2.Legacy_Id__c).put(pbe.CurrencyIsoCode,pbe);
                         }
                     }
                     if(pbe.Pricebook2Id != null){
                         if(!mapPBEIds.containskey(pbe.Pricebook2Id)){
                             mapPBEIds.put(pbe.Pricebook2Id, new map<string,PricebookEntry>{pbe.CurrencyIsoCode=>pbe});
                         }else{
                             mapPBEIds.get(pbe.Pricebook2Id).put(pbe.CurrencyIsoCode,pbe);
                         }
                     }
                 }
             }   
             map<string,map<string,integer>> mapOrderQuantity = new map<string,map<string,integer>>();
             if(OriginalOrderIds.size()>0){                 
                 for(OrderItem OdI: [select id,orderId,product2Id,quantity from OrderItem where orderId in: OriginalOrderIds]){
                     if(!mapOrderQuantity.containskey(OdI.orderId)){
                         mapOrderQuantity.put(OdI.orderId, new map<string,integer>{OdI.id+'###'+OdI.product2Id=>Integer.valueof(OdI.quantity)});
                     }
                     else{
                         mapOrderQuantity.get(OdI.orderId).put(OdI.id+'###'+OdI.product2Id,Integer.valueof(OdI.quantity));
                     }
                 }
             }          
             map<Integer,charge__c> mapcharges = new map<Integer,charge__c>();
             Map<Integer,order> maporders = new Map<Integer,order>();
             map<Integer,OrderItem> mapOrderItemsInsert = new Map<Integer,OrderItem>();
             //List<payment_term__c> payterms = new List<payment_term__c>();
             List<Order> originalordersToupdate = new List<Order>();
             List<Inventory_Transaction__c> newInventories = new List<Inventory_Transaction__c>();
             Integer count = 1;
             for(dsfs__DocuSign_Status__c ds: (List<dsfs__DocuSign_Status__c>)scopeList){                 
                 if(ds.dsfs__Opportunity__c != null && mapOpps.containskey(ds.dsfs__Opportunity__c)){
                     Opportunity opp = mapOpps.get(ds.dsfs__Opportunity__c);
                     String program = (opp.Event__c != null && opp.Event__r.Program__c != null ? opp.Event__r.Program__r.Name : (opp.Pricebook2.Program__c != null ? opp.Pricebook2.Program__r.Name: ''));
                     if((opp.Refund_Response__c == 'Apply Credit to New Date in 2020' && program  == 'F1E') || opp.Refund_Response__c == 'Apply Credit* to the Future Event'){  
                         system.debug('####opp.Refund_Response__c=='+opp.Refund_Response__c);                    
                         /*for(payment_term__c pt: opp.Opportunity_Payment_Terms__r){
                             pt.status__c = 'Canceled';
                             payterms.add(pt);
                         }*/
                         Order odr = new Order();
                         odr.accountId= opp.AccountId;
                         odr.EffectiveDate = system.today();
                         odr.CurrencyIsoCode = opp.CurrencyIsoCode;
                         odr.status = 'Credited - Sales Adjustment';                          
                         odr.OpportunityId = opp.id;
                         odr.ownerid = opp.ownerId;
                         if(opp.orders != null && opp.orders.size()>0){   
                             odr.Original_Order__c = opp.orders[0].id;
                             odr.Exchange_Rate__c = opp.orders[0].Exchange_Rate__c;
                         } 
                         odr.Pricebook2Id  = (mapPBPercentage.containskey(opp.Event__c) &&  mapPBPercentage.get(opp.Event__c) != null ? mapPBPercentage.get(opp.Event__c).id : (mapPBPercentage.containskey(opp.Pricebook2Id) && mapPBPercentage.get(opp.Pricebook2Id) != null ? mapPBPercentage.get(opp.Pricebook2Id).id:null));                                     
                         odr.Pricebook_Reporting__c = (mapPBPercentage.containskey(opp.Event__c) &&  mapPBPercentage.get(opp.Event__c) != null ? mapPBPercentage.get(opp.Event__c).id : (mapPBPercentage.containskey(opp.Pricebook2Id) && mapPBPercentage.get(opp.Pricebook2Id) != null ? mapPBPercentage.get(opp.Pricebook2Id).id:null));
                         OrderItem odI = new orderItem();
                         if(opp.Event__c != null && mapPBEIds.containskey(opp.Event__c)){
                             odI.PricebookEntryId = mapPBEIds.get(opp.Event__c).get(opp.CurrencyIsoCode).Id;
                         }
                         else if(opp.Pricebook2Id != null && mapPBEIds.containskey(opp.Pricebook2Id)){
                             odI.PricebookEntryId = mapPBEIds.get(opp.Pricebook2Id).get(opp.CurrencyIsoCode).Id;
                         }                         
                         odI.Quantity = 1;
                         
                         Charge__c charge = new Charge__c();                     
                         charge.recordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Account Credit').getRecordTypeId();
                         charge.account__c = opp.AccountId; 
                         charge.Is_Credit_Adjustment__c = true;  
                         
                         if(opp.Refund_Response__c == 'Apply Credit to New Date in 2020'){
                             Decimal creditPercent =  (opp.Event__c != null && mapPBPercentage.containskey(opp.Event__c) ? mapPBPercentage.get(opp.Event__c).Move_to_2020_Credit_Percentage__c: (mapPBPercentage.get(opp.Pricebook2Id) != null ? mapPBPercentage.get(opp.Pricebook2Id).Move_to_2020_Credit_Percentage__c:0));
                             Decimal percentagecal = (opp.Move_to_2020_Credit_Percentage__c != null? opp.Move_to_2020_Credit_Percentage__c: creditPercent);
                             if(opp.orders != null && opp.orders.size()>0){
                                 if(opp.orders[0].Collected_Revenue__c != null && percentagecal != null) {
                                     charge.Amount__c = (opp.orders[0].Collected_Revenue__c - opp.orders[0].Protect_Group_Amount__c) * (percentagecal/100);
                                 }      
                             }     
                         } 
                         else if(opp.Refund_Response__c == 'Apply Credit* to the Future Event'){                            
                             Decimal creditPercent =  (opp.Event__c != null && mapPBPercentage.containskey(opp.Event__c) && mapPBPercentage.get(opp.Event__c) !=null ? mapPBPercentage.get(opp.Event__c).Move_to_2021_Credit_Percentage__c: (mapPBPercentage.get(opp.Pricebook2Id) != null ? mapPBPercentage.get(opp.Pricebook2Id).Move_to_2021_Credit_Percentage__c: 0));
                             Decimal percentagecal = (opp.Move_to_2021_Credit_Percentage__c != null? opp.Move_to_2021_Credit_Percentage__c: creditPercent);
                             if(opp.orders != null && opp.orders.size()>0){
                                if(opp.orders[0].Collected_Revenue__c != null && percentagecal != null) {
                                    charge.Amount__c = (opp.orders[0].Collected_Revenue__c - opp.orders[0].Protect_Group_Amount__c) * (percentagecal/100);
                                }
                             }
                             
                         }
                         if(Test.isrunningtest()) charge.Amount__c = 10.00;
                         charge.Pricebook__c = (mapPBPercentage.containskey(opp.Event__c) &&  mapPBPercentage.get(opp.Event__c) != null ? mapPBPercentage.get(opp.Event__c).id : (mapPBPercentage.get(opp.Pricebook2Id) != null ? mapPBPercentage.get(opp.Pricebook2Id).id:null));
                         charge.Opportunity__c = opp.id;                         
                         odI.UnitPrice = charge.Amount__c;
                         if(opp.orders != null && opp.orders.size()>0){
                             if(mapOrderQuantity.containskey(opp.orders[0].id)){
                                for(string strkey: mapOrderQuantity.get(opp.orders[0].id).keyset()){
                                     Inventory_Transaction__c objInventory = new Inventory_Transaction__c();
                                     objInventory.RecordTypeId = Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByDeveloperName().get('Order_Inventory').getRecordTypeId();                                                           
                                     objInventory.Quantity__c = mapOrderQuantity.get(opp.orders[0].id).get(strkey); 
                                     objInventory.Order_Item__c = strkey.split('###')[0];
                                     objInventory.Product__c = strkey.split('###')[1];                                
                                     newInventories.add(objInventory);
                                 }
                              }
                         }   
                         
                         system.debug('###charge.Amount__c=='+charge.Amount__c);                         
                         if(charge.Amount__c != null){
                             maporders.put(count,odr);
                             mapOrderItemsInsert.put(count,odI); 
                             mapcharges.put(count,charge);                                                          
                             if(opp.orders != null && opp.orders.size()>0){
                                 opp.orders[0].status = 'Inactive - Credit Issued';
                                 originalordersToupdate.add(opp.orders[0]);
                             }
                         }
                         count++;
                         ds.Proceed_Refund__c = true;
                     }
                 }
             }
             
             
             
             if(maporders.size()>0){
                 Utility.processRecords(maporders.values(),'insert');                 
                 if(mapOrderItemsInsert.size()>0){
                     Integer i= 1;
                     for(OrderItem oi: mapOrderItemsInsert.values()){
                         oi.orderId =  maporders.get(i).Id;
                         i++;
                     }
                     Utility.processRecords(mapOrderItemsInsert.values(),'insert');
                     
                 }
                 if(newInventories.size()>0){                     
                     Utility.processRecords(newInventories,'insert');
                     
                 }
                 if(mapcharges.size()>0){  
                     Integer j= 1;
                     for(charge__c ch: mapcharges.values()){
                         ch.order__c =  maporders.get(j).Id;
                         j++;
                     }                                      
                     Utility.processRecords(mapcharges.values(),'insert');                     
                     
                 }
                 if(originalordersToupdate.size()>0){
                     Utility.processRecords(originalordersToupdate,'update');
                 } 
                 /*if(payterms.size()>0){
                     Utility.processRecords(payterms,'update'); 
                 }*/
                 Utility.processRecords(scopeList,'update');
             }
             
        }
    } 
    
    //Batch Finish method for after execution of batch work
    global void finish(Database.BatchableContext BC) {        
        
    }
    
    
    
}
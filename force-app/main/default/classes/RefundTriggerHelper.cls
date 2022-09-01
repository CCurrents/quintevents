/**
 * @File Name          : RefundTriggerHelper.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 03/08/2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    5/8/2020       jagrawal@addonblue.com     Initial Version
 * 1.1    08/24/2020     kchavda@addonblue.com      #465 Refund Orders
 * 1.2    09/16/2020     kchavda@addonblue.com      #539 Check for collected revenue from Order in the addendum batch
 * 1.3    02/18/2021     kchavda@addonblue.com      #788 Capture Intacct bank account id in Salesforce to which transactions are being sent to.
 * 1.4    03/08/2021     kchavda@addonblue.com      #845 Stop Sending Refund Records to Intacct
 * 1.3    03/10/2021     cshah@addonblue.comm       #831 Email alert to Order Owner when Refund record is created for their order 
**/
public with sharing class RefundTriggerHelper {

    private Map<Id, Refund__c> newRefundMap; 
    private Map<Id, Refund__c> oldRefundMap;
    private List<Refund__c> newRefundList;
    private List<Refund__c> oldRefundList;

    public RefundTriggerHelper(){
        Utility.getSOQLCount();
        this.newRefundMap = (Map<Id, Refund__c>) Trigger.newMap;
        this.oldRefundMap = (Map<Id, Refund__c>) Trigger.oldMap;
        this.newRefundList = (List<Refund__c>) Trigger.new;
        this.oldRefundList = (List<Refund__c>) Trigger.old;
        
        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
                System.debug('In Refund Before Insert!');
            }

            when BEFORE_UPDATE {
                System.debug('In Refund Before Update!');
            }

            when BEFORE_DELETE {
                System.debug('In Refund Before Delete!');
            }

            when AFTER_INSERT {
                System.debug('In Refund After Insert!');
                CreateRefundOrders(newRefundList);
                sendEmailOnRefundCreation(newRefundList,oldRefundMap); //#831
            }

            when After_UPDATE {
                System.debug('In Refund After Update!');
                sendEmailOnRefundCreation(newRefundList,oldRefundMap); //#831
            }

            /*when AFTER_DELETE {
                System.debug('In Refund After Delete!');
            }
            
            when AFTER_UNDELETE {
                System.debug('In Refund After Undelete!');
            }*/
            
            when else{
                System.debug('Undefined Trigger Operation!');
            }
        }
    }
    
    /**
    * @description  : To create refund orders (#465 Refund Orders)
    * @author       : kchavda@addonblue.com | 08/24/2020 
    * @param        : set<Id>
    * @return       : void 
    **/    
    @TestVisible
    private void CreateRefundOrders(List<Refund__c> newRefunds){
        try{ 
            Set<id> setOrderIDs = new Set<id>();
            Map<id,double> mapRefAmount = new  Map<id,double>();           
            for(Refund__c ref: newRefunds){
                if(ref.order__c != null) setOrderIDs.add(ref.order__c);                
            }            
            if(setOrderIDs.size()>0){
                for(Refund__c refund: [select id,Amount__c,order__c from refund__c where order__c in:setOrderIDs ]){
                    if(refund.Amount__c != null){
                         if(!mapRefAmount.containskey(refund.order__c)) mapRefAmount.put(refund.order__c, refund.Amount__c);                        
                        else mapRefAmount.put(refund.order__c,mapRefAmount.get(refund.order__c)+refund.Amount__c);
                    }
                    
                }
                List<order> lstorders = new List<order>([select id,Multiple_Refund_Dates__c,Refund_Amount__c,Exchange_rate__c,Opportunity.CurrencyISOCode,Opportunity.Event__c,Opportunity.pricebook2id,Status,OpportunityId,Opportunity.Refund_Amount__c,Opportunity.AccountId,Opportunity.OwnerId,(Select id,Quantity,Product2Id from orderItems) from order where id in:setOrderIDs and opportunity.Refund_Response__c = 'Confirm Refund' and status IN ('Active','Inactive - Refunded')]); 
                Map<id,order> mapsalesAdjustmentOrders = new Map<id,order>();
                for(order odrs: [select id,original_order__c,Refund_Amount__c from order where original_order__c in:lstorders and status = 'Refunded - Sales Adjustment']){
                    mapsalesAdjustmentOrders.put(odrs.original_order__c,odrs);
                }
                set<Id> legacyEventIds = new set<Id>();
                set<Id> PBIds = new set<Id>();
                Set<String> setCurrencyCode = new Set<String>();
                List<order> lstordersToUpdate = new List<order>();
                system.debug('###lstOrders=='+lstOrders);
                if(lstorders.size()>0){
                    for(order od: lstorders){
                        setCurrencyCode.add(od.Opportunity.CurrencyIsoCode);
                        if(od.Opportunity.Event__c != null) legacyEventIds.add(od.Opportunity.Event__c);
                        else if(od.Opportunity.Pricebook2Id != null) PBIds.add(od.Opportunity.Pricebook2Id);
                    }
                    
                    
                    Map<Integer,order> maporders = new Map<Integer,order>();
                    map<Integer,OrderItem> mapOrderItemsInsert = new Map<Integer,OrderItem>();  
                    Map<Id,Pricebook2> mapPBPercentage = new Map<Id,Pricebook2>();
                    Map<string, map<string,PricebookEntry>> mapPBEIds = new Map<string, map<string,PricebookEntry>>();
                    
                    if(legacyEventIds.size()>0 || PBIds.size()>0){
                        Map<Id,Pricebook2> mapPB = new Map<Id,Pricebook2>([select id,Legacy_Id__c,Move_to_2020_Credit_Percentage__c,Move_to_2021_Credit_Percentage__c from pricebook2 where Legacy_Id__c in: legacyEventIds or id in: PBIds]);
                        for(pricebook2 pb: mapPB.values()){
                             if(pb.Legacy_Id__c != null){
                                 mapPBPercentage.put(pb.Legacy_Id__c,pb);
                             }
                             mapPBPercentage.put(pb.id,pb);
                             
                         } 
                         
                         for(PricebookEntry pbe: [Select Id, Pricebook2Id,CurrencyIsoCode,Pricebook2.Legacy_Id__c from PricebookEntry where Pricebook2Id in :mapPB.keyset() AND Product2.Name = 'Sales Adjustment' AND CurrencyIsoCode IN :setCurrencyCode]){
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
                    system.debug('###mapPBEIds=='+mapPBEIds);                    
                    
                    Integer count = 1;
                    for(Order odr: lstOrders){                       
                        
                        system.debug('###odr=='+odr.orderItems);
                        if(odr.status == 'Active'){                            
                            Order oder = new Order();
                            oder.accountId= odr.Opportunity.AccountId;
                            oder.EffectiveDate = system.today();
                            oder.CurrencyIsoCode = odr.Opportunity.CurrencyIsoCode;
                            oder.status = 'Refunded - Sales Adjustment'; 
                            oder.Refund_Amount__c = mapRefAmount.containskey(odr.id) && mapRefAmount.get(odr.id) != null ? mapRefAmount.get(odr.id) : null;
                            oder.OpportunityId = odr.OpportunityId;
                            oder.ownerid = odr.Opportunity.OwnerId;
                            oder.Original_Order__c = odr.id;
                            oder.Exchange_rate__c =  odr.Exchange_rate__c;                           
                            oder.Pricebook2Id  = (mapPBPercentage.containskey(odr.Opportunity.Event__c) &&  mapPBPercentage.get(odr.Opportunity.Event__c) != null ? mapPBPercentage.get(odr.Opportunity.Event__c).id : (mapPBPercentage.get(odr.Opportunity.Pricebook2Id) != null ? mapPBPercentage.get(odr.Opportunity.Pricebook2Id).id:null));                                                              
                            oder.Pricebook_Reporting__c = (mapPBPercentage.containskey(odr.Opportunity.Event__c) &&  mapPBPercentage.get(odr.Opportunity.Event__c) != null ? mapPBPercentage.get(odr.Opportunity.Event__c).id : (mapPBPercentage.get(odr.Opportunity.Pricebook2Id) != null ? mapPBPercentage.get(odr.Opportunity.Pricebook2Id).id:null));
                            maporders.put(count,oder);
                            OrderItem odI = new orderItem();
                            odI.Quantity = 1;
                            system.debug('###odr.Opportunity.Event__c=='+odr.Opportunity.Event__c);
                            system.debug('###odr.Opportunity.Pricebook2Id=='+odr.Opportunity.Pricebook2Id);                    
                            if(mapPBEIds.containskey(odr.Opportunity.Event__c)){
                                odI.PricebookEntryId = mapPBEIds.get(odr.Opportunity.Event__c).get(odr.Opportunity.CurrencyIsoCode).Id;
                            }
                            else if(mapPBEIds.containskey(odr.Opportunity.Pricebook2Id)){
                                odI.PricebookEntryId = mapPBEIds.get(odr.Opportunity.Pricebook2Id).get(odr.Opportunity.CurrencyIsoCode).Id;
                            }          
                            odI.UnitPrice = 0;                    
                            mapOrderItemsInsert.put(count,odI);
                            count++; 
                       }
                       else if(odr.status == 'Inactive - Refunded'){
                           system.debug('###mapsalesAdjustmentOrders=='+mapsalesAdjustmentOrders);
                            if(mapsalesAdjustmentOrders.containskey(odr.id) && mapsalesAdjustmentOrders.get(odr.id) != null){
                                Order ordertoupdate = new order();
                                ordertoupdate = mapsalesAdjustmentOrders.get(odr.id);                                
                                ordertoupdate.Refund_Amount__c = (mapRefAmount.containskey(odr.id) && mapRefAmount.get(odr.id) != null ? mapRefAmount.get(odr.id) : null);
                                lstordersToUpdate.add(ordertoupdate);
                                
                                odr.Multiple_Refund_Dates__c = true;
                                lstordersToUpdate.add(odr);
                            }
                            
                           
                           
                       }
                       if(odr.status == 'Active'){
                           odr.status = 'Inactive - Refunded';
                           lstordersToUpdate.add(odr);
                       }
                       
                       
                    }
                    system.debug('###lstordersToUpdate=='+lstordersToUpdate);
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
                                            
                   }
                   if(lstordersToUpdate.size()>0) Utility.processRecords(lstordersToUpdate,'update');
                    
                }
            }
           
            
            
        }catch(Exception ex){ Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
   
    /**
    * @description  : To send email to order owner when refund record get's created(#831)
    * @author       : cshah@addonblue.com | 03/10/2021
    * @param        : Refund newlist and oldmap
    * @return       : void 
    **/   
    public void sendEmailOnRefundCreation(List<Refund__c> newRefundList,Map<Id, Refund__c> oldRefundMap) {
        try {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for(Refund__c objRefund: [Select Id,Opportunity_Payment_Terms__r.Order__c,Opportunity_Payment_Terms__r.Order__r.Name,Opportunity_Payment_Terms__r.Order__r.OrderNumber,Order_Owner_Email__c,Amount__c,Status__c,CurrencyIsoCode from Refund__c where Id IN :newRefundList]) {
                if(objRefund.Status__c == 'succeeded' && (Trigger.isInsert || (Trigger.isUpdate && objRefund.Status__c != oldRefundMap.get(objRefund.Id).Status__c))) {
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    if(objRefund.Order_Owner_Email__c != null) {
                        Decimal refundAmount = objRefund.Amount__c == null ? 0.00 : objRefund.Amount__c;
                        
                        List<String> args = new String[]{'0','number','#,###.0'};
                        String amount = String.format(refundAmount.format(), args);
                        
                        List<String> sendTo = new List<String>();    
                        sendTo.add(objRefund.Order_Owner_Email__c);
                        mail.setToAddresses(sendTo);
                        
                        mail.setSubject('A refund has been processed for your client');
                        
                        String emailbody = '<b>' +'Order URL: '+'</b>' + '<html><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+objRefund.Opportunity_Payment_Terms__r.Order__c+'">'+objRefund.Opportunity_Payment_Terms__r.Order__r.OrderNumber+'</a></html><br/>';
                        emailbody += '<b>' + 'Community Order URL : ' +'</b>' + '<html><a href="'+Label.Formula_1_Lightning_Community_URL +'/s/order/'+'/'+objRefund.Opportunity_Payment_Terms__r.Order__c+'">'+objRefund.Opportunity_Payment_Terms__r.Order__r.OrderNumber+'</a></html><br/>';
                        emailbody += '<b>' + 'Refund Amount: '+ '</b>' + objRefund.CurrencyISOCode +' '+ amount;
                        
                        mail.setHtmlBody(emailbody);
                        
                        mails.add(mail);
                    }
                }
            }
            if(mails.size() > 0) {
                 Messaging.sendEmail(mails);
            }
            
        } catch(Exception ex) {
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
}
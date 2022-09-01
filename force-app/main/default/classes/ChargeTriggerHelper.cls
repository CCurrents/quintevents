/**
 * @File Name          : ChargeTriggerHelper.cls
 * @Description        : 
 * @Author             : lpanchal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 7/2/2020, 5:10:46 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    3/27/2020   lpanchal@addonblue.com     Initial Version
**/
public with sharing class ChargeTriggerHelper {

    private Map<Id, Charge__c> newChargeMap; 
    private Map<Id, Charge__c> oldChargeMap;
    private List<Charge__c> newChargeList;
    private List<Charge__c> oldChargeList;


    public ChargeTriggerHelper() {
        
        this.newChargeMap = (Map<Id, Charge__c>) Trigger.newMap;
        this.oldChargeMap = (Map<Id, Charge__c>) Trigger.oldMap;
        this.newChargeList = (List<Charge__c>) Trigger.new;
        this.oldChargeList = (List<Charge__c>) Trigger.old;
        
        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
                System.debug('In Before Insert!');
              
                onBeforeInsertCharge();
            }
            
            when BEFORE_UPDATE {
                System.debug('In Before Update!');
                onBeforeInsertCharge();
            }
            
            when BEFORE_DELETE {
                System.debug('In Before Delete!');
            }
            
            when AFTER_INSERT {
                System.debug('Chargef -- In After Insert!');
                List<String> lstptIds= new List<String>();
                for(Charge__c objCharge :newChargeList )  {   
                    lstptIds.add(objCharge.Payment_Terms__c);
                }
                List<Payment_Term__c> lstPTs = [ Select Id,name,Order__c from Payment_Term__c where Id IN :lstptIds];
                List<Charge__c> Chargelist = [ Select Id,RecordTypeId,Payment_Terms__c,Credit_Used__c from Charge__c where Id IN :newChargeList and Payment_Terms__r.order__r.Refund_Reconciliation__c = false and Payment_Terms__r.order__r.Pricebook2.GPE_Event__c = false];
                //onAfterInsertCharge(Chargelist,lstPTs);
            }
            
            when AFTER_UPDATE {
                System.debug('In After Update!');
                onAfterUpdateCharge(newChargeList,oldChargeMap);
                
            }
            
            when AFTER_DELETE {
                System.debug('In After Delete!');
            }
            
            when AFTER_UNDELETE {
                System.debug('In After Undelete!');
            }
            
            when else {
                System.debug('Undefined Trigger Operation!');
            }
        }
    }
    public void onAfterInsertCharge(List<Charge__c> Chargelist,List<Payment_Term__c> lstPTs) {
        system.debug('----onAfterInsertCharge---');
        Id creditRecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
        Id AccCreditRecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Account Credit').getRecordTypeId();
        
        map<String,String> mpOfOrderIds = new map<String,String>();
        for(Payment_Term__c objPTS :lstPTs )  {   
            mpOfOrderIds.put(objPTS.Id,objPTS.Order__c);
        }
        for(Charge__c objCharge :Chargelist)  {   
            System.debug('objCharge'+objCharge);
            if(((AccCreditRecordTypeId == objCharge.RecordTypeId && objCharge.Credit_Used__c) || objCharge.RecordTypeId == creditRecordTypeId )) {
                system.debug('test11-->'+mpOfOrderIds.get(objCharge.Payment_Terms__c));
                IntacctOrderSyncBatch batch = new IntacctOrderSyncBatch(mpOfOrderIds.get(objCharge.Payment_Terms__c),new list<String> {'Sales Credit Memo'},objCharge.Payment_Terms__c+'###'+objCharge.id,false);
                system.debug('objCharge call---'+batch);
                Database.executebatch(batch);
            }
        }
    }
    public void onBeforeInsertCharge(){
        try{
            System.debug('Is Before insert:');
            Set<Id> setOrderIds = new Set<Id>();
            Set<Id> setAccountIds = new Set<Id>();
            Set<Id> setPaymentTermIds = new Set<Id>();
            List<Order> lstOrder = new List<Order>();
            for(Charge__c objCharge : newChargeList){
                if(objCharge.Order__c != null){
                    setOrderIds.add(objCharge.Order__c);
                }
                if(objCharge.Payment_Terms__c != null){
                    setPaymentTermIds.add(objCharge.Payment_Terms__c);
                }
            }
            Id ChargeDebitRecordId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Debit').getRecordTypeId();
            Map<Id,Order> maporders = New Map<Id,Order>([Select id,Status,AccountId,CurrencyISOCode from Order where Id in:setOrderIds]);
            List<Payment_Term__c> lstPT = [Select id,Order__c,Order__r.Status, Quote__r.AccountId,Amount__c, CurrencyISOCode from Payment_Term__c where Id in:setPaymentTermIds];
            Map<Id,Payment_Term__c> mapPaymentTerms = New Map<Id,Payment_Term__c>();
            for(Payment_Term__c objPT : lstPT){
                mapPaymentTerms.put(objPT.Id,objPT);
            }
            System.debug('maporders@@@'+maporders);
            for(Charge__c objnewcharge : (List<Charge__c>)Trigger.New){
                if(maporders.get(objnewcharge.Order__c) != null && maporders.get(objnewcharge.Order__c).Status == 'Credited - Sales Adjustment'){
                    objnewcharge.Is_Credit_Adjustment__c = true;                
                }
                else if(maporders.get(objnewcharge.Order__c) == null && Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Account Credit').getRecordTypeId() == objnewcharge.RecordTypeId){
                    
                }
                else{
                    objnewcharge.Is_Credit_Adjustment__c = false;
                }
                if(objnewcharge.Order__c != null){
                    //objnewcharge.Account__c = maporders.get(objnewcharge.Order__c).AccountId;
                    objnewcharge.Order_Status__c = maporders.get(objnewcharge.Order__c).Status;
                    objnewcharge.CurrencyISOCode = maporders.get(objnewcharge.Order__c).CurrencyISOCode;
                }else if(objnewcharge.Payment_Terms__c != null){
                    objnewcharge.Order__c = mapPaymentTerms.get(objnewcharge.Payment_Terms__c).Order__c;
                    objnewcharge.Order_Status__c = mapPaymentTerms.get(objnewcharge.Payment_Terms__c).Order__r.Status;
                    objnewcharge.CurrencyISOCode = mapPaymentTerms.get(objnewcharge.Payment_Terms__c).CurrencyISOCode;
                }
            }
            //For validation of not allowing user to use Credit if available credit is less than the debit amount -- START
            for(Charge__c objnewcharge : (List<Charge__c>)Trigger.New){
                if(objnewcharge.Account__c != null && objnewcharge.CurrencyISOCode != null && objnewcharge.RecordTypeId == ChargeDebitRecordId && objnewcharge.Credit_Used__c){
                    setAccountIds.add(objnewcharge.Account__c);
                }
            }
            Map<Id,Account> mapAccounts = New Map<Id,Account>([Select id, USD_Total_Credit_Available__c, CAD_Total_Credit_Available__c, EUR_Total_Credit_Available__c, GBP_Total_Credit_Available__c, AUD_Total_Credit_Available__c,THB_Total_Credit_Available__c,SAR_Total_Credit_Available__c  from Account where Id in:setAccountIds]); //Issues #1209 - sai
            for(Charge__c objnewcharge : (List<Charge__c>)Trigger.New){
                if(objnewcharge.RecordTypeId == ChargeDebitRecordId && objnewcharge.CurrencyISOCode != null && objnewcharge.Credit_Used__c){
                    if(objnewcharge.CurrencyISOCode == 'AUD'){
                        if(objnewcharge.Amount__c > mapAccounts.get(objnewcharge.Account__c).AUD_Total_Credit_Available__c){
                            objnewcharge.addError('Debit Amount cannot be greater than the available credit amount AUD on account.');
                        }
                    } else if(objnewcharge.CurrencyISOCode == 'CAD'){
                        if(objnewcharge.Amount__c > mapAccounts.get(objnewcharge.Account__c).CAD_Total_Credit_Available__c){
                            objnewcharge.addError('Debit Amount cannot be greater than the available credit amount CAD on account.');
                        }
                    } else if(objnewcharge.CurrencyISOCode == 'EUR'){
                        if(objnewcharge.Amount__c > mapAccounts.get(objnewcharge.Account__c).EUR_Total_Credit_Available__c){
                            objnewcharge.addError('Debit Amount cannot be greater than the available credit amount EUR on account.');
                        }
                    } else if(objnewcharge.CurrencyISOCode == 'GBP'){
                        if(objnewcharge.Amount__c > mapAccounts.get(objnewcharge.Account__c).GBP_Total_Credit_Available__c){
                            objnewcharge.addError('Debit Amount cannot be greater than the available credit amount GBP on account.');
                        }
                    } else if(objnewcharge.CurrencyISOCode == 'USD'){
                        if(objnewcharge.Amount__c > mapAccounts.get(objnewcharge.Account__c).USD_Total_Credit_Available__c){
                            objnewcharge.addError('Debit Amount cannot be greater than the available credit amount USD on account.');
                        }
                    } else if(objnewcharge.CurrencyISOCode == 'SAR'){
                        if(objnewcharge.Amount__c > mapAccounts.get(objnewcharge.Account__c).SAR_Total_Credit_Available__c ){
                            objnewcharge.addError('Debit Amount cannot be greater than the available credit amount SAR on account.'); //Issues #1209 - sai
                        }
                    } else if(objnewcharge.CurrencyISOCode == 'THB'){
                        if(objnewcharge.Amount__c > mapAccounts.get(objnewcharge.Account__c).THB_Total_Credit_Available__c ){
                            objnewcharge.addError('Debit Amount cannot be greater than the available credit amount THB on account.'); //Issues #1209 - sai
                        }
                    }
                    if(objnewcharge.Amount__c > mapPaymentTerms.get(objnewcharge.Payment_Terms__c).Amount__c){
                        objnewcharge.addError('Debit Amount cannot be greater than the Payment Term Amount.');
                    }
                }
            }
            //For validation of not allowing user to use Credit if available credit is less than the debit amount -- END
        }
        catch(exception ex){
           system.debug('Exception'+ex.getmessage() +'' +ex.getLineNumber());
        }
    }
    
    
    public void onAfterUpdateCharge(List<charge__c> lstCharges, map<Id,Charge__c> oldmapCharges){
        Map<Id,Double> ChargeorderAmount = new Map<Id,Double>();
        for(charge__c charge: lstCharges){
            if(Trigger.IsUpdate && charge.Amount__c != oldmapCharges.get(charge.id).Amount__c && charge.order__c != null && charge.Order_Status__c == 'Credited - Sales Adjustment'){
                ChargeorderAmount.put(charge.order__c,charge.Amount__c);    
            }        
        }
        
        if(ChargeorderAmount.size()>0){
            List<orderItem> lstorderitems = new List<orderItem>([select id,orderId,UnitPrice from orderItem where orderid in: ChargeorderAmount.keyset()]);
            if(!lstorderitems.isEmpty()){
                for(orderItem odritem: lstorderitems){
                    if(ChargeorderAmount.containskey(odritem.orderId) && ChargeorderAmount.get(odritem.orderId) != null){
                        odritem.UnitPrice = ChargeorderAmount.get(odritem.orderId);
                    }
                }
                Utility.processRecords(lstorderitems,'update');   
            }
        }
        
    }

}
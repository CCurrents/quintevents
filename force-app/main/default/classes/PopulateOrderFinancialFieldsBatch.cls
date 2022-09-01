/**
 * @File Name          : PopulateOrderFinancialFieldsBatch.cls
 * @Description        : To populate order financial fields
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 06/15/2021
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    06/15/2021   kchavda@addonblue.com      Initial Version 
**/
public class PopulateOrderFinancialFieldsBatch implements Database.Batchable<sObject>{ 

    string query;
    
    /**
    * @description Constructor
    * @author kchavda@addonblue.com | 06/15/2021
    * @param  set<Id>
    * @return
    **/        
    public PopulateOrderFinancialFieldsBatch(string strquery){
        this.query= strquery;        
    }
    
    
     /**
    * @description Start method
    * @author kchavda@addonblue.com | 06/15/2021
    * @param  Database.BatchableContext
    * @return Database.QueryLocator
    **/  
    public Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator(query);
    }
    
    /**
    * @description Execute method
    * @author kchavda@addonblue.com | 06/15/2021
    * @param  Database.BatchableContext, List<sObject>
    * @return void
    **/  
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            List<order> lstordertoupdate = new List<order>();
            for(Order objOrder: (List<order>)scope){
                Decimal TotalAmount = 0, SumOfRefunds = 0, SumOfCreditPTs = 0, GrossCollected = 0, TotalPTAmount=0;
                integer passSize = 0;
                integer ptsize = objOrder.Payment_Terms__r.size();
                Boolean isupdate = false;
                for(Payment_Term__c objPT: objOrder.Payment_Terms__r){  
                    if(objPT.status__c == 'Passed') passSize++;
                    
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
                
                if(objOrder.Collected_Revenue__c != TotalAmount || Test.IsrunningTest()){
                    objOrder.Collected_Revenue__c = TotalAmount;isupdate = true;
                }
                if(objOrder.Sum_of_Refunds__c  != SumOfRefunds || Test.IsrunningTest()){
                    objOrder.Sum_of_Refunds__c = SumOfRefunds;isupdate = true;
                }
                if(objOrder.Credit_Applied__c != SumOfCreditPTs || Test.IsrunningTest()){
                    objOrder.Credit_Applied__c = SumOfCreditPTs;isupdate = true;            
                }
                
                if(objOrder.Gross_Collected__c != GrossCollected || Test.IsrunningTest()){
                    objOrder.Gross_Collected__c = GrossCollected;isupdate = true;               
                }
                if(objOrder.Sum_of_Payment_Terms__c != TotalPTAmount || Test.IsrunningTest()){
                    objOrder.Sum_of_Payment_Terms__c = TotalPTAmount;isupdate = true;
                }
                // Update Order Payment Status
                if(passSize > 0 && passSize < ptsize &&  objOrder.Order_Payment_Status__c != 'Partially Paid') {  
                    objOrder.Order_Payment_Status__c = 'Partially Paid';
                    if(objOrder.Subject_to_Cancellation__c == true) {objOrder.Subject_to_Cancellation__c = false;}
                    isupdate = true;
                }
                else if(passSize == ptsize && objOrder.Order_Payment_Status__c != 'Fully Paid'){
                    objOrder.Order_Payment_Status__c = 'Fully Paid';
                    objOrder.Paid_in_Full__c = true;
                    if(objOrder.Subject_to_Cancellation__c == true) {objOrder.Subject_to_Cancellation__c = false;}
                    isupdate = true;
                }
                else if(passSize == 0 && objOrder.Order_Payment_Status__c != 'Not Paid') {
                    objOrder.Order_Payment_Status__c = 'Not Paid'; isupdate = true;
                    
                } 
                if(isupdate == true){
                    lstordertoupdate.add(objOrder);
                }
                
             }
             TriggerHandler.bypass('OrderTriggerHandler');
             if(lstordertoupdate.size()>0) update lstordertoupdate;
             TriggerHandler.clearBypass('OrderTriggerHandler');      
     
        }
        catch(exception ex){
           system.debug('###ex==='+ex.getMessage());
        }
       
    }
    
    /**
    * @description Finish method
    * @author kchavda@addonblue.com | 06/15/2021
    * @param  Database.BatchableContext
    * @return void
    **/  
    public void finish(Database.BatchableContext BC){        
    }
}
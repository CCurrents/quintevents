/**
 * @File Name          : SendOrderToGPT.cls
 * @Description        : To send failed Order to GPT
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 06/02/2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    06/02/2021    kchavda@addonblue.com     Initial Version
 * 1.1    06/14/2021    kchavda@addonblue.com     #997 Clear GPT Response field when clicking on Send To GPT button
*/
public with sharing class SendOrderToGPT{

   /**
    * @description To send Order to GPT
    * @author kchavda@addonblue.com | SendOrderToGPT
    * @param PaymentId 
    * @return string
    **/    
    @Auraenabled
    public static string processOrder(Id orderId){ 
        List<Order> lstOrders = new List<Order>();
        if(!Test.isrunningTest()){
            lstOrders = [select id,createddate,Xero_Invoice_ID__c,Sent_to_GPT__c,GPT_Booking_Id__c,GPT_Response__c from order where Order_Payment_Status__c = 'Fully Paid' and GPE_Order__c  = true and GPT_Booking_Id__c = null and id in (Select OrderID from OrderITem where Product2.GPT_Article_Id__c != null) and id =:orderId];
        }else{
            lstOrders = [select id,createddate,Xero_Invoice_ID__c,Sent_to_GPT__c,GPT_Booking_Id__c,GPT_Response__c from order limit 1];
        }
        String displayMsg = '';
        if(!lstOrders.isempty()){            
            
                if(lstOrders[0].GPT_Booking_Id__c != null){
                    displayMsg = 'Order is already sent to GPT';
                }else{                
                    lstOrders[0].GPT_Response__c ='';
                    TriggerHandler.bypass('OrderTriggerHandler');
                    Utility.processRecords(lstOrders[0], 'update');
                    TriggerHandler.clearBypass('OrderTriggerHandler'); 
                    set<id> orderIds = new set<id>{orderId}; 
                    string query = 'select id,createddate,Xero_Invoice_ID__c,Sent_to_GPT__c from order where id in: orderIds';
                    CreateOrderinGPTBatch batch = new CreateOrderinGPTBatch(query,orderIds);
                    if(!Test.isrunningTest()) database.executebatch(batch,1);                     
                }            
        }
        
        return displayMsg;
         
    }
}
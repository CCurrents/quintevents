/**
 * @File Name          : BrandFuelSchedule.cls
 * @Description        : To generate BrandFuel Link 
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 05/13/2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    05/13/2021  kchavda@addonblue.com         Initial Version
**/
global class BrandFuelSchedule implements schedulable{
   
    /**
    * @description execute method
    * @author kchavda@addonblue.com | 05/13/2021
    * @param SchedulableContext
    * @return void
    **/  
    global void execute(SchedulableContext sc) {
        Set<Id> setOrderIdsBF = new Set<Id>();
        Set<Id> setOrderItemIdsBF = new Set<Id>();
        for(OrderItem oitem: [Select id,orderId from orderitem where Order.Order_Payment_Status__c = 'Fully Paid' and Order.Status = 'Active' and order.PriceBook2.Brandfuel_Category_Id__c != null and Product2.Type__c = 'Giftbag' and product2.Brandfuel_Points__c != null and order.Brandfuel_Customer_Link__c = null]){
            setOrderIdsBF.add(oitem.orderId);
            setOrderItemIdsBF.add(oitem.id);
        }
        
        if(setOrderIdsBF.size() > 0 || Test.isrunningtest()){
            String query = 'Select Id, Status, Order_Payment_Status__c, OpportunityId, PriceBook2Id, PriceBook2.End_Date__c, PriceBook2.Name, PriceBook2.Brandfuel_End_Date__c, Brandfuel_Customer_Link__c from Order where Id IN :setOrderIdsBF';
            BrandFuelBatch objBFBatch = new BrandFuelBatch(query, setOrderIdsBF, setOrderItemIdsBF); Database.executeBatch(objBFBatch, 1);
        }      
    }
}
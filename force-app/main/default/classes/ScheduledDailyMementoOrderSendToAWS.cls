/**
* @File Name          : ScheduledDailyMementoOrderSendToAWS.cls
* @Description        : 
* @Author             : mpatel@addonblue.com
* @Group              : 
* @Last Modified By   : fsuraitawala@addonblue.com
* @Last Modified On   : 04-16-2021
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0    08/07/2020      mpatel@addonblue.com     Initial Version
**/
global class ScheduledDailyMementoOrderSendToAWS implements Schedulable {
   global void execute(SchedulableContext sc) {
        //#905 add filter on Order Payment Status
        String query = 'SELECT Id, QuoteLineItem.Original_Quantity__c, OrderId, Order.Account.Name, Order.Pricebook2.Name, Product2.Type__c, Quantity, Order.OpportunityId, Order.Status ' +
                       'FROM OrderItem WHERE Order.Status =: status AND Order.Order_Payment_Status__c IN (\'Partially Paid\', \'Fully Paid\') '+
                       'AND Product2.Type__c Like \'' +'%Memento%'+'\' AND Sent_To_Authentic__c = false AND day_only(createddate) >= 2020-08-10';
        
        MementoOrderSendToAWS obj = new MementoOrderSendToAWS(query);
        database.executebatch(obj);
   }
}
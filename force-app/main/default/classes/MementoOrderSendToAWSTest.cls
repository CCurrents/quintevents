/**
 * @description       : MementoOrderSendToAWSTest.cls
 * @author            : mpatel@addonblue.com
 * @group             : 
 * @last modified on  : 01-25-2021
 * @last modified by  : fsuraitawala@addonblue.com
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   08-06-2020   Manan Patel  Initial Version
**/
@isTest public class MementoOrderSendToAWSTest{
    @testSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    @isTest static void method1(){
        Payment_Term__c objPT = TestDataFactory.createPaymentTerm();
        objPT.Status__c = 'Passed';
        update objPT;
        Quote objQuote = [select Id, TotalPrice, Pricebook2Id, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode from Quote where Id=: objPT.Quote__c];
        QuoteLineItem QLI = TestDataFactory.createQuoteLineItem(1, objQuote.Id, true)[0];

        Product2 objProduct = new Product2(
            Name='Testdata123 - ',
            Primary_Price_Book__c = Test.getStandardPricebookId(),
            Type__c='Memento',
            A_La_Carte__c=true,
            //Inventory__c=10,
            RecordTypeId = Schema.SObjectType.product2.getRecordTypeInfosByName().get('Product').getRecordTypeId(),
            Check_In_Date__c = System.today()+2,
            Check_Out_Date__c = System.today()+5,
            H4H_Room_Code__c = '987654321',
            Block_Release_Date__c = Date.today().addDays(+2),
            CurrencyISOCode = 'USD',
            Total_Inventory__c = 0,
            Total_Ordered_Quantity__c = -7, 
            Room_Type__c = 'King', 
            Hotel_Id__c = '1684628',
            H4H_RatePlan_Code__c= 'ARN987654321',
            isActive=true,
            Send_Slack_Notifications__c = true);
            //objProductlstProduct.add(objProduct);
        
        Utility.processRecords(objProduct, 'insert');
        
        PricebookEntry pricebookEntry = TestDataFactory.createPriceBookEntry(objProduct, Test.getStandardPricebookId());
        pricebookEntry.UnitPrice = 10;
        insert pricebookEntry;
        QuoteLineItem objQLI = new QuoteLineItem(
                Quantity = 2,
                Product2ID= objProduct.Id,//createProduct().Id,
                QuoteId = objQuote.id,
                UnitPrice = 0.01,
                PriceBookEntryId = pricebookEntry.Id ); 
        insert objQLI;
        List<String> lstGiftCodeTypes1 = new List<String>{'F1 Access Code','Fanatics Gift Code','Memento Premium','Memento Ultimate'};
        Order objOrder = [Select Id from Order where Id =: objPT.Order__c];
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        for(integer i= 0; i<4; i++){ 
                
                OrderItem objOrderItem = new OrderItem(
                Quantity = 2,
                OrderId = objOrder.Id,
                UnitPrice = 100,
                quoteLineItemId = objQLI.Id,
                PricebookEntryId = objQLI.PricebookEntryId
                //Product_Type__c = lstGiftCodeTypes1[Math.Mod(i,4)]
            );
            lstOrderItem.add(objOrderItem);
        }
        lstOrderItem = Utility.processRecords(lstOrderItem, 'insert');
        system.debug('###lstOrderItem=='+lstOrderItem);
       
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new ScheduledDailyMementoOrderSendToAWS());  
        String query = 'SELECT Id, QuoteLineItem.Original_Quantity__c, OrderId, Order.Account.Name, order.Pricebook2.Name, Product2.Type__c, Quantity, Order.OpportunityId from OrderItem where Product2.Type__c Like \'' +'%Memento%'+'\' and Sent_To_Authentic__c = false and day_only(createddate) >= 2020-05-11';
        MementoOrderSendToAWS obj = new MementoOrderSendToAWS(query); 
        database.executebatch(obj);
    }
}
/**
 * @File Name          : GiftCodeTriggerHelperTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 07-23-2020
 * @Modification Log   : 
 * Ver       Date            Author              Modificatio
 * 1.0    5/9/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
public class GiftCodeTriggerHelperTest {
    
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        List<String> lstGiftCodeTypes = new List<String>{'F1 Access Code','Fanatics Gift Code','Memento Premium','Memento Ultimate'};
        
        Payment_Term__c objPT = TestDataFactory.createPaymentTerm();
        objPT.Status__c = 'Passed';
        update objPT;
        system.debug('###objPT=='+objPT);
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');
        Test.startTest();
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        
        Quote objQuote = [select Id, TotalPrice, Pricebook2Id, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode from Quote where Id=: objPT.Quote__c];
        QuoteLineItem QLI = TestDataFactory.createQuoteLineItem(1, objQuote.Id, true)[0];
        List<QuoteLineItem> lstQLI = new List<QuoteLineItem>();
        lstQLI.add(QLI);
        
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        Order objOrder = [Select Id from Order where Id =: objPT.Order__c];
        /*objOrder.Order_Payment_Status__c = 'Fully Paid'; 
        objOrder.F1_Access_Code_Assignment_Pending__c = true;
        update ObjOrder;*/
        lstOrderItem = TestDataFactory.createOrderItem(4, objOrder.Id, QLI);
        Pricebook2 pricebook = TestDataFactory.createPricebook();
        //List<PriceBook2> lstPricebooks = TestDataFactory.createPricebook(1, 'Test Pricebook');
        //Id lstPricebooks = Test.getStandardPricebookId();
        Product2 pro = TestDataFactory.createProduct(1, 'Product', Test.getStandardPricebookId(), false)[0];
        pro.Type__c = 'F1 Access Code'; 
        insert pro; 
        /*Product2 objProduct = new Product2(
            Name='Testdata123 - ',
            Primary_Price_Book__c = Test.getStandardPricebookId(),
            Type__c='F1 Access Code',
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
        system.debug('###lstOrderItem=='+lstOrderItem);*/
        
        List<Gift_Code__c> lstGiftCode = TestDataFactory.createGiftCode(100,false);
        Utility.processRecords(lstGiftCode, 'insert');        
        delete triggerSetting;
        Test.stopTest();
    }
    
    @isTest static void test1(){       
        List<Gift_Code__c> lstGiftCode = [Select Id from Gift_Code__c limit 5];
        
        Utility.processRecords(lstGiftCode, 'update');
        Utility.processRecords(lstGiftCode, 'delete');
    }
}
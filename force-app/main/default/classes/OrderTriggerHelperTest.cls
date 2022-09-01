/**
 * @File Name          : OrderTriggerHelperTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 04-20-2022
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    5/10/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest public class OrderTriggerHelperTest {
    
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        Test.startTest();
        List<String> lstGiftCodeTypes = new List<String>{'F1 Access Code','Fanatics Gift Code','Memento Premium','Memento Ultimate'};
        
        Account objAccount = new Account();
        objAccount.Name = 'Addon Blue ';
        insert objAccount;
        
        Contact objContact = new Contact();
        objContact.FirstName = 'Test data';
        objContact.LastName = 'Data';
        objContact.Email = 'addontest@addonblue.com';
        objContact.AccountId = objAccount.Id;
        insert objContact;
        
        //VKHOPADE - issue 1219 
        Pricebook2 PB = new Pricebook2(Id = Test.getStandardPricebookId());
        PB.Order_Notifications_Start_Date__c = system.today() - 1;
        PB.Dont_Allow_Order_Changes_After__c = system.today() + 1;
        update PB;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Accountid = objAccount.Id;
        objOpportunity.Name = 'Formula ';
        objOpportunity.Pricebook2Id = Test.getStandardPricebookId();//PricebookId;
        //objOpportunity.Pricebook2 = createPricebook(); 
        objOpportunity.Payment_Method__c ='Credit Card';
        objOpportunity.Email__c = 'testperson@quintevnts.com';
        objOpportunity.Send_Payment_Email__c = false;
        objOpportunity.StageName = 'Closed Won';
        objOpportunity.CloseDate = date.today(); 
        objOpportunity.Contact_Site__c = 'quintevents.com';   
        objOpportunity.Primary_Contact__c =  objContact.Id;  
        objOpportunity.Shipping_Outside_US__c = 'Yes';
        insert objOpportunity;
        
        Quote objQuote = new Quote(
                Name = 'person opportunity quote',
                Payment_Terms__c = '1/2',
                OpportunityId = objOpportunity.Id,
                Status = 'Draft',
                Payment_Method__c = 'Credit Card',
                Email = 'addonBlue@quintevnts.com',
                Primary_Contact__c = objContact.Id,
                ShippingCountryCode = 'IN',
                Pricebook2Id = Test.getStandardPricebookId(),
                Approval_Expected__c = '4 Hours',//createPricebook().id
                Description = 'Paid#100'
            );
        insert objQuote;
        Order objOrder = new Order(
                AccountId = objAccount.Id,
                QuoteId = objQuote.Id,
                OpportunityId = objOpportunity.Id,
                EffectiveDate = date.newInstance(2022, 3, 01),
                Status = 'Creation',
                Order_Payment_Status__c = 'Partially Paid',
                Pricebook2Id = Test.getStandardPricebookId(),
                ShipToContactId = objContact.Id,
                BillToContactId = objContact.Id,
                Primary_Attendee_Contact__c = objContact.Id
            );
        insert objOrder;
        
        //VKHOPADE - issue 1219 - start
        objOrder.Pick_Up_Requested__c = true;
        objOrder.Status = 'Draft';
        update objOrder;
        
        Order objOrder2 = new Order(
                AccountId = objAccount.Id,
                QuoteId = objQuote.Id,
                OpportunityId = objOpportunity.Id,
                EffectiveDate = date.newInstance(2022, 3, 01),
                Status = 'Credited - Sales Adjustment',
                Original_Order__c = objOrder.Id,
                Order_Payment_Status__c = 'Partially Paid',
                Pricebook2Id = Test.getStandardPricebookId(),
                ShipToContactId = objContact.Id,
                BillToContactId = objContact.Id,
                Primary_Attendee_Contact__c = objContact.Id
            );
        insert objOrder2;
        objOrder2.EffectiveDate = date.newInstance(2022,9, 09);
        update objOrder2;
        //VKHOPADE - issue 1219 - end
        
        OpportunityContactRole objOppRole1 = new OpportunityContactRole();
        objOppRole1.ContactId = objOrder.ShipToContactId;
        objOppRole1.OpportunityId = objOrder.OpportunityId;
        objOppRole1.Role = 'Shipping Contact';
        insert objOppRole1;
        
        OpportunityContactRole objOppRole2 = new OpportunityContactRole();
        objOppRole2.ContactId = objOrder.BillToContactId;
        objOppRole2.OpportunityId = objOrder.OpportunityId;
        objOppRole2.Role = 'Billing Contact';
        insert objOppRole2;
        
        OpportunityContactRole objOppRole3 = new OpportunityContactRole();
        objOppRole3.ContactId = objOrder.Primary_Attendee_Contact__c;
        objOppRole3.OpportunityId = objOrder.OpportunityId;
        objOppRole3.Role = 'Primary Attendee Contact';
        insert objOppRole3;
        //Order order = TestDataFactory.createOrder(1, true)[0];
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        
        Product2 objProduct = new Product2(
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
        system.debug('objProduct-->'+objProduct);
        PricebookEntry pricebookEntry = TestDataFactory.createPriceBookEntry(objProduct, Test.getStandardPricebookId());
        pricebookEntry.UnitPrice = 10;
        pricebookEntry.product2Id = objProduct.Id;
        insert pricebookEntry;
        QuoteLineItem objQLI = new QuoteLineItem(
                Quantity = 2,
                Product2ID= objProduct.Id,//createProduct().Id,
                QuoteId = objOrder.quoteId,
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
            system.debug('lstOrderItem.Product_Type__c-->'+objOrderItem.Product_Type__c);
        }
        lstOrderItem = Utility.processRecords(lstOrderItem, 'insert');
        system.debug('###lstOrderItem=='+lstOrderItem);
        
        Payment_Term__c objPaymentTerm = new Payment_Term__c(
            Quote__c = objQuote.Id,
            Order__c = objOrder.Id,
            Opportunity__c= objOpportunity.Id,
            Status__c = 'Passed',
            Amount__c = 100,
            Percentage_Of_Payment__c = 10,
            Payment_Due_Date__c = System.today()
            );
        Payment_Term__c objPaymentTerm1 = new Payment_Term__c(
            Quote__c = objQuote.Id,
            Order__c = objOrder.Id,
            Opportunity__c= objOpportunity.Id,
            Amount__c = 100,
            Percentage_Of_Payment__c = 10,
            Payment_Due_Date__c = System.today()
            );
        List<Payment_Term__c> payTermList = new List<Payment_Term__c>();
        payTermList.add(objPaymentTerm);
        payTermList.add(objPaymentTerm1);
        insert payTermList;
        
        List<Gift_Code__c> lstGiftCode = TestDataFactory.createGiftCode(100,false);        
        Utility.processRecords(lstGiftCode, 'insert');
  
        //delete triggerSetting;
        TestDataFactory.createTriggerSettingsEntry();
        TestDataFactory.createSFDCIntacctMapping();     
        Test.stopTest();
    }
    
    @isTest static void test1(){ 
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Quote');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        triggerSetting = Trigger_Settings__c.getInstance('Opportunity');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        Payment_Term__c payterm = TestDataFactory.createPaymentTerm();
        List<Order> lstord = [Select Id, Status, Tracking_Number__c, Refund_Requested__c from Order];//Id =: payterm.Order__c];
        List<Order> newlstOrd = new List<Order>();
        Test.startTest();
        triggerSetting = Trigger_Settings__c.getInstance('QuoteLineItem');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        triggerSetting = Trigger_Settings__c.getInstance('Product2');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        triggerSetting = Trigger_Settings__c.getInstance('Payment_Term__c');                
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        newlstOrd = Utility.processRecords(newlstOrd, 'update');
        System.debug('newlstOrd-->'+newlstOrd);       
        Test.stopTest();
    }

    @isTest static void test2(){ 
        List<Order> lstOrder = TestDataFactory.createOrder(1, true);
        OrderTriggerHelper.createInventoryRecords(lstOrder, lstOrder);
        OrderTriggerHelper.processOrdersForXero(lstOrder[0]);
        OrderTriggerHelper.processOrdersForIntacct(lstOrder[0]);
    }
    //#470 Defaulted change added by Fesal
    @isTest static void test3(){
        System.debug('Order Defaulted start');
        Order objOrder = [Select Id from Order limit 1];
        Test.startTest();
        objOrder.Status = 'Defaulted - Pending';
        objOrder.Defaulted_Comments__c = 'Defaulted Comments';
        update objOrder;
        
        objOrder.Status = 'Defaulted';
        objOrder.Comment__c = 'Test Comment';
        update objOrder;
        System.enqueueJob(new SendOrderToGPEQueueable(objOrder.Id));
        delete objOrder;
        Test.stopTest();
        
        System.debug('Order Defaulted end');
    }
    @isTest static void test4(){
        System.debug('Order Cancellation start');
        Order objOrder = [Select Id from Order limit 1];
        Test.startTest();
        objOrder.Status = 'Cancellation Pending';
        objOrder.Order_Payment_Status__c = 'Fully Paid';
        objOrder.Seating_Request__c = 'Test Seating Request';
        update objOrder;        
        Test.stopTest();
        System.debug('Order Cancellation end');
    }
  
  @isTest static void test5(){
        System.debug('Order Cancellation start');
        Order objOrder = [Select Id from Order limit 1];
        Test.startTest();
        objOrder.Status = 'Cancellation Pending';
        objOrder.Order_Payment_Status__c = 'Fully Paid';
        objOrder.Seating_Request__c = 'Test Seating Request';
        objOrder.Comment__c = 'Test Comment';
        update objOrder;        
        OrderTriggerHelper.validateOrder(new List<Order>{objOrder},new Map<Id, Order>{objOrder.id=>objOrder},'System Administrator');
        Test.stopTest();
        System.debug('Order Cancellation end');
    }
    
    @isTest static void test6(){
        Order objOrder = [Select Id, OpportunityId, Primary_Attendee_Contact__c, EffectiveDate  from Order limit 1];
        Test.startTest();
        List<Gift_Code__c> lstGiftCode = TestDataFactory.createGiftCode(10,false);   
        for(Gift_Code__c objGF: lstGiftCode){
            objGF.Order__c = objOrder.Id;
        }
        Utility.processRecords(lstGiftCode, 'insert');
        
        objOrder.ShiptoContactId = [Select Id from Contact limit 1].Id;
        objOrder.BillToContactId = [Select Id from Contact limit 1].Id;
        update objOrder;
        OrderTriggerHelper objOrderTriggerHelper = new OrderTriggerHelper();
        objOrderTriggerHelper.setOpportunityContactRole(new List<Order>{objOrder});
        
        objOrder.Status = 'Modified';
        update objOrder;
        
        OrderTriggerHelper.updateGiftCode(new Set<Id>{objOrder.Id});
        OrderTriggerHelper.OrderPopulation(null,null,null,null);

        Map<Id, Date> mapOfOrderIdAndStartDate = new Map<Id, Date>();
        mapOfOrderIdAndStartDate.put(objOrder.Id, objOrder.EffectiveDate);
        OrderTriggerHelper obj = new OrderTriggerHelper();
        obj.updateSalesAdjDateOnOriginOrder(mapOfOrderIdAndStartDate);
        
        Test.stopTest();
        
        System.debug('Order Defaulted end');
    }

    @isTest static void test7(){
        Test.startTest();
        List<Order> lstOrder = TestDataFactory.createOrder(2,true);
        Set<Id> lstIds = new Set<Id>();
        for(Order obj: lstOrder){
            lstIds.add(obj.Id);
        }
        OrderTriggerHelper.updateFirstBuyerOrders(lstIds);
        List<Id> orderIds = new List<Id>(lstIds);
        OrderTriggerHelper.reverseARPaymentInIntacct(orderIds);
        Test.stopTest();
    }
}
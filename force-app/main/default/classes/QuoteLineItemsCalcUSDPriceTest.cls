//VKHOPADE - issue 1144 - batch class to update Unit_Price_USD__c on all existing QLIs
//created : 20-Jan-2022

@isTest (SeeAllData = false)
public class QuoteLineItemsCalcUSDPriceTest {
    
  /*  @TestSetup static void makeData(){
        //TestDataFactory.createTriggerSettingsEntry();
        //Test.startTest();
        
        
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
       // Test.stopTest();
    } */
 
    @isTest  static void testMethod1()
     {
         TestDataFactory.createTriggerSettingsEntry();
         List<String> lstGiftCodeTypes = new List<String>{'F1 Access Code','Fanatics Gift Code','Memento Premium','Memento Ultimate'};
        
        Account objAccount = new Account();
        objAccount.Name = 'Addon Blue ';
        insert objAccount;
        
        Contact objContact = new Contact();
        objContact.FirstName = 'Test data';
        objContact.LastName = 'Data';
        objContact.Email = 'vkhtest@addonbl.com';
        objContact.AccountId = objAccount.Id;
        insert objContact;
        
        Id StdPBId = Test.getStandardPricebookId();
        Pricebook2 StdPB = new Pricebook2 ();
        StdPB.Id = StdPBId;
        StdPB.IsActive = True;
        update StdPB;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Accountid = objAccount.Id;
        objOpportunity.Name = 'Formula ';
        objOpportunity.Pricebook2Id = Test.getStandardPricebookId();//PricebookId;
        //objOpportunity.Pricebook2 = createPricebook(); 
        objOpportunity.Payment_Method__c ='Credit Card';
        objOpportunity.Email__c = 'testperson12@quintevnts.com';
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
                EffectiveDate = date.newInstance(2020, 3, 01),
                Status = 'Creation',
                Order_Payment_Status__c = 'Partially Paid',
                Pricebook2Id = Test.getStandardPricebookId(),
                ShipToContactId = objContact.Id,
                BillToContactId = objContact.Id,
                Primary_Attendee_Contact__c = objContact.Id
            );
        insert objOrder;
        
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
            // #994 - Update Product price as null/blank in test class
            Price__c = 0,
            Send_Slack_Notifications__c = true);
            //objProductlstProduct.add(objProduct);
        
        Utility.processRecords(objProduct, 'insert');
        system.debug('objProduct-->'+objProduct);
        PricebookEntry pricebookEntry1 = TestDataFactory.createPriceBookEntry(objProduct, Test.getStandardPricebookId());
        pricebookEntry1.UnitPrice = 100;
        pricebookEntry1.product2Id = objProduct.Id;
        insert pricebookEntry1;
        system.debug('pricebookEntry1 = ' + pricebookEntry1);
        QuoteLineItem objQLI = new QuoteLineItem(
                Quantity = 2,
                Product2ID= objProduct.Id,//createProduct().Id,
                QuoteId = objOrder.quoteId,
                UnitPrice = 10.01,
                PriceBookEntryId = pricebookEntry1.Id ); 
        insert objQLI;
        system.debug('inserted QLI = ' + objQLI);
        objQLI.Unit_Price_USD__c = null;
         update objQLI;
         
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
         
         List<QuoteLineItem> QLIs = new List<QuoteLineItem> ([Select Id, Product2Id, Unit_Price_USD__c,PriceBookEntryId, Quantity FROM QuoteLineItem WHERE Unit_Price_USD__c = null and PriceBookEntryId IN (select ID from PricebookEntry where Pricebook2.IsActive = True)]);
         system.debug('QLIs for batch = ' + QLIs); 
         Test.startTest();
        QuoteLineItemsCalcUSDPrice QLIsUpdateUSDPrices = new QuoteLineItemsCalcUSDPrice();
        Id batchId = Database.executeBatch(QLIsUpdateUSDPrices, 200);
        system.debug('batch job id = ' + batchId);
        Test.stopTest();
         TestDataFactory.createTriggerSettingsEntry();
     }
}
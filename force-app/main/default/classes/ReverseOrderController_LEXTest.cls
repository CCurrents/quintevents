@isTest
public class ReverseOrderController_LEXTest {

    @testsetup
    public static void testdata(){
         TestDataFactory.createTriggerSettingsEntry();
        
        List<String> lstGiftCodeTypes = new List<String>{'F1 Access Code','Fanatics Gift Code','Memento Premium','Memento Ultimate','NBA League Pass','NBA TV','NBA Top Shot'};
        
        Account objAccount = new Account();
        objAccount.Name = 'Addon Blue ';
        insert objAccount;
        
        Contact objContact = new Contact();
        objContact.FirstName = 'Test data';
        objContact.LastName = 'Data';
        objContact.Email = 'addontest@addonblue.com';
        objContact.AccountId = objAccount.Id;
        insert objContact;
        
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
                EffectiveDate = date.newInstance(2020, 3, 01),
                Status = 'Draft',Intacct_Id__c='1234544',Record_Id__c='qweqwrrrqt',
                Order_Payment_Status__c = 'Partially Paid',
                Pricebook2Id = Test.getStandardPricebookId()
            );
        insert objOrder;
         List<Order> odrlist = new List<Order>();
        Order objOrder1 = new Order(
                AccountId = objAccount.Id,
                QuoteId = objQuote.Id,
                Fanatics_Gift_Code_Assignment_Pending__c = true,
                EffectiveDate = date.newInstance(2020, 3, 01),
                Status = 'Draft',
                Order_Payment_Status__c = 'Partially Paid',
                Pricebook2Id = Test.getStandardPricebookId()
            );
        odrlist.Add(objOrder1);
          Order objOrder2 = new Order(
                AccountId = objAccount.Id,
                QuoteId = objQuote.Id,
                F1_Access_Code_Assignment_Pending__c = true,
                EffectiveDate = date.newInstance(2020, 3, 01),
                Status = 'Draft',
                Order_Payment_Status__c = 'Partially Paid',
                Pricebook2Id = Test.getStandardPricebookId()
            );
        
        odrlist.Add(objOrder2);
         Order objOrder3 = new Order(
                AccountId = objAccount.Id,
                QuoteId = objQuote.Id,
                NBA_League_Pass_Assignment_Pending__c= true,
                EffectiveDate = date.newInstance(2020, 3, 01),
                Status = 'Draft',
                Order_Payment_Status__c = 'Partially Paid',
                Pricebook2Id = Test.getStandardPricebookId()
            );
        
        odrlist.Add(objOrder3);
         Order objOrder4 = new Order(
                AccountId = objAccount.Id,
                QuoteId = objQuote.Id,
                NBA_Top_Shot_Assignment_Pending__c= true,
                EffectiveDate = date.newInstance(2020, 3, 01),
                Status = 'Draft',
                Order_Payment_Status__c = 'Partially Paid',
                Pricebook2Id = Test.getStandardPricebookId()
            );
        
        odrlist.Add(objOrder4);
        Order objOrder5 = new Order(
                AccountId = objAccount.Id,
                QuoteId = objQuote.Id,
                NBA_TV_Assignment_Pending__c = true,
                EffectiveDate = date.newInstance(2020, 3, 01),
                Status = 'Draft',
                Order_Payment_Status__c = 'Partially Paid',
                Pricebook2Id = Test.getStandardPricebookId()
            );
        
        odrlist.Add(objOrder5);
        insert odrlist;
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
        List<String> lstGiftCodeTypes1 = new List<String>{'F1 Access Code','Fanatics Gift Code','Memento Premium','Memento Ultimate','NBA League Pass','NBA TV','NBA Top Shot'};
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
            Amount__c = 100,Intacct_Id__c='34563454',Record_Id__c='123454',
            Percentage_Of_Payment__c = 10,
            Payment_Due_Date__c = System.today()
            );
        Payment_Term__c objPaymentTerm1 = new Payment_Term__c(
            Quote__c = objQuote.Id,
            Order__c = objOrder.Id,
            Opportunity__c= objOpportunity.Id,
            Amount__c = 100,Intacct_Id__c='2334563454',Record_Id__c='12345454',
            Percentage_Of_Payment__c = 10,
            Payment_Due_Date__c = System.today()
            );
        List<Payment_Term__c> payTermList = new List<Payment_Term__c>();
        payTermList.add(objPaymentTerm);
        //payTermList.add(objPaymentTerm1);
        insert payTermList;
        
    } 
    
    static testmethod void testReverseOrder(){
        order ord =[select id from order where Record_Id__c!=null and Intacct_Id__c!=null];
        ReverseOrderController_LEX.createReverseOrder(ord.Id);
    }
}
/**
* @File Name          : GiftCodeSyncWithOrderBatchTest.cls
* @Description        : 
* @Author             : fsuraitawala@addonblue.com
* @Group              : 
* @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 01-31-2022
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0    04/05/2021   fsuraitawala@addonblue.com   Initial Version
**/
@isTest
private class GiftCodeSyncWithOrderBatchTest {
    static testMethod void testgiftcodemethod(){
        TestDataFactory.createTriggerSettingsEntry();
        List<Gift_Code__c> lstGiftCode = new List<Gift_Code__c>();
        for(integer i = 0; i < 50; i++){
            Gift_Code__c objGiftCode = new Gift_Code__c();
            objGiftCode.Gift_Code__c = 'g1q852'+i;
            objGiftCode.RecordTypeId = Schema.SObjectType.Gift_Code__c.getRecordTypeInfosByName().get('F1 Access Code').getRecordTypeId();
            lstGiftCode.add(objGiftCode);
        }
        for(integer i = 0; i < 50; i++){
            Gift_Code__c objGiftCode = new Gift_Code__c();
            objGiftCode.Gift_Code__c = 'Fanatics'+i;
            objGiftCode.RecordTypeId = Schema.SObjectType.Gift_Code__c.getRecordTypeInfosByName().get('Fanatics Gift Code').getRecordTypeId();
            lstGiftCode.add(objGiftCode);
        }
          for(integer i = 0; i < 50; i++){
            Gift_Code__c objGiftCode3 = new Gift_Code__c();
            objGiftCode3.Gift_Code__c = 'NBA League Pass'+i;
            objGiftCode3.RecordTypeId = Schema.SObjectType.Gift_Code__c.getRecordTypeInfosByName().get('NBA League Pass').getRecordTypeId();
            lstGiftCode.add(objGiftCode3);
        }
          for(integer i = 0; i < 50; i++){
            Gift_Code__c objGiftCode4 = new Gift_Code__c();
            objGiftCode4.Gift_Code__c = 'NBA TV'+i;
            objGiftCode4.RecordTypeId = Schema.SObjectType.Gift_Code__c.getRecordTypeInfosByName().get('NBA TV').getRecordTypeId();
            lstGiftCode.add(objGiftCode4);
        }
          for(integer i = 0; i < 50; i++){
            Gift_Code__c objGiftCode5 = new Gift_Code__c();
            objGiftCode5.Gift_Code__c = 'NBA Top Shot'+i;
            objGiftCode5.RecordTypeId = Schema.SObjectType.Gift_Code__c.getRecordTypeInfosByName().get('NBA Top Shot').getRecordTypeId();
            lstGiftCode.add(objGiftCode5);
        }
        Utility.processRecords(lstGiftCode, 'insert');
        Test.startTest();
        
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
        
        List<Product2> lstProduct = new List<Product2>();
        Product2 objProduct1 = new Product2(
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
        lstProduct.add(objProduct1);
        Product2 objProduct2 = new Product2(
            Name='Test Fanatics Gift Code',
            Primary_Price_Book__c = Test.getStandardPricebookId(),
            Type__c='Fanatics Gift Code',
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
            system.debug('2222 '+ objProduct2.RecordType.Name);
        lstProduct.add(objProduct2);
        
        Product2 objProduct3 = new Product2(
            Name='Test NBA League Pass',
            Primary_Price_Book__c = Test.getStandardPricebookId(),
            Type__c='NBA League Pass',
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
             system.debug('3333 '+ objProduct2.RecordType.Name);
        lstProduct.add(objProduct3);
         Product2 objProduct4 = new Product2(
            Name='Test NBA TV',
            Primary_Price_Book__c = Test.getStandardPricebookId(),
            Type__c='NBA TV',
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
        lstProduct.add(objProduct4);
          Product2 objProduct5 = new Product2(
            Name='Test NBA Top Shot',
            Primary_Price_Book__c = Test.getStandardPricebookId(),
            Type__c='NBA Top Shot',
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
        lstProduct.add(objProduct5);
        
        Utility.processRecords(lstProduct, 'insert');
        
        PricebookEntry pricebookEntry1 = TestDataFactory.createPriceBookEntry(objProduct1, Test.getStandardPricebookId());
        pricebookEntry1.UnitPrice = 10;
        pricebookEntry1.product2Id = objProduct1.Id;
        insert pricebookEntry1;
        
        PricebookEntry pricebookEntry2 = TestDataFactory.createPriceBookEntry(objProduct1, Test.getStandardPricebookId());
        pricebookEntry2.UnitPrice = 10;
        pricebookEntry2.product2Id = objProduct2.Id;
        insert pricebookEntry2;
        
        PricebookEntry pricebookEntry3 = TestDataFactory.createPriceBookEntry(objProduct3, Test.getStandardPricebookId());
        pricebookEntry3.UnitPrice = 10;
        pricebookEntry3.product2Id = objProduct3.Id;
        insert pricebookEntry3;
        
        PricebookEntry pricebookEntry4 = TestDataFactory.createPriceBookEntry(objProduct4, Test.getStandardPricebookId());
        pricebookEntry4.UnitPrice = 10;
        pricebookEntry4.product2Id = objProduct4.Id;
        insert pricebookEntry4;
        PricebookEntry pricebookEntry5 = TestDataFactory.createPriceBookEntry(objProduct5, Test.getStandardPricebookId());
        pricebookEntry5.UnitPrice = 10;
        pricebookEntry5.product2Id = objProduct5.Id;
        insert pricebookEntry5;
        
        List<QuoteLineItem> lstQLI = new List<QuoteLineItem>();
        QuoteLineItem objQLI1 = new QuoteLineItem(
                Quantity = 100,
                Product2ID= objProduct1.Id,//createProduct().Id,
                QuoteId = objQuote.Id,
                UnitPrice = 0.01,
                PriceBookEntryId = pricebookEntry1.Id );
        lstQLI.add(objQLI1);
        QuoteLineItem objQLI2 = new QuoteLineItem(
                Quantity = 100,
                Product2ID= objProduct2.Id,//createProduct().Id,
                QuoteId = objQuote.Id,
                UnitPrice = 0.01,
                PriceBookEntryId = pricebookEntry2.Id );
                
                QuoteLineItem objQLI3 = new QuoteLineItem(
                Quantity = 100,
                Product2ID= objProduct3.Id,//createProduct().Id,
                QuoteId = objQuote.Id,
                UnitPrice = 0.01,
                PriceBookEntryId = pricebookEntry3.Id );
        lstQLI.add(objQLI3);
        QuoteLineItem objQLI4 = new QuoteLineItem(
                Quantity = 100,
                Product2ID= objProduct4.Id,//createProduct().Id,
                QuoteId = objQuote.Id,
                UnitPrice = 0.01,
                PriceBookEntryId = pricebookEntry4.Id );
        lstQLI.add(objQLI4);
        QuoteLineItem objQLI5 = new QuoteLineItem(
                Quantity = 100,
                Product2ID= objProduct5.Id,//createProduct().Id,
                QuoteId = objQuote.Id,
                UnitPrice = 0.01,
                PriceBookEntryId = pricebookEntry5.Id );
        lstQLI.add(objQLI5);
        lstQLI.add(objQLI2);
        insert lstQLI;
        Payment_Term__c objPaymentTerm = new Payment_Term__c(
            Quote__c = objQuote.Id,
            Opportunity__c= objOpportunity.Id,
            Status__c = 'Passed',
            Amount__c = 100,
            Percentage_Of_Payment__c = 10,
            Payment_Due_Date__c = System.today()
            );
        Payment_Term__c objPaymentTerm1 = new Payment_Term__c(
            Quote__c = objQuote.Id,
            Opportunity__c= objOpportunity.Id,
            Amount__c = 100,
            Percentage_Of_Payment__c = 10,
            Payment_Due_Date__c = System.today()
            );
        List<Payment_Term__c> payTermList = new List<Payment_Term__c>();
        payTermList.add(objPaymentTerm);
        payTermList.add(objPaymentTerm1);
        insert payTermList;
        
        objQuote.status = 'Signed - Approved';
        update objQuote;
        
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Order');
        triggerSetting.Deactivate__c = true;
        update triggerSetting;
        
        Order objOrder = [Select Id FROM Order WHERE QuoteId = :objQuote.Id];
        objOrder.F1_Access_Code_Assignment_Pending__c = true;
        objOrder.Order_Payment_Status__c = 'Fully Paid';
        update objOrder;
        
        GiftCodeSyncWithOrderBatch batch = new GiftCodeSyncWithOrderBatch();
        database.executebatch(batch,25);
        Test.stopTest();
    }
}
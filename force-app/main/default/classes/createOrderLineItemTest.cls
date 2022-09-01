@isTest
private class createOrderLineItemTest {
    @testSetup 
    static void setup() {
        TestDataFactory.createTriggerSettingsEntry();
        
        Pricebook2 testPricebook = new Pricebook2(Name = 'Standard Price Book', IsActive = true, Chargeable_Currencies__c = 'EUR');
        insert testPricebook;
        
        Product2 objProduct =new product2();
        objProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId();
        objProduct.Name = 'Test Product';
        objProduct.Primary_Price_Book__c = testPricebook.Id;
        objProduct.Type__c = 'Transportation';
        objProduct.CurrencyIsoCode = 'USD';
        objProduct.Price__c = 100.00;
        objProduct.A_La_Carte__c = true;
        objProduct.isActive = true;
        insert objProduct;
        
        List<PricebookEntry> stdPriceBookEntries = new List<PricebookEntry>();
        PricebookEntry objStdPriceBook = new PricebookEntry(unitprice = objProduct.Price__c,
                                                         Product2Id = objProduct.Id,
                                                         Pricebook2Id = Test.getStandardPricebookId(),
                                                         isActive=true,
                                                         UseStandardPrice = false,
                                                         CurrencyIsoCode = 'EUR');
        stdPriceBookEntries.add(objStdPriceBook);
        
         PricebookEntry objPriceBook = new PricebookEntry(unitprice = objProduct.Price__c, 
                                                         Product2Id = objProduct.Id, 
                                                         Pricebook2Id = testPricebook.Id, 
                                                         isActive=true, 
                                                         UseStandardPrice = false,
                                                         CurrencyIsoCode = 'EUR');
        stdPriceBookEntries.add(objPriceBook);
        
        insert stdPriceBookEntries;
        
        Account objAccount = new Account();
        objAccount.Name = 'Addon Blue Account';
        insert objAccount;
        
        Contact objContact = new Contact();
        objContact.FirstName = 'Test Contact';
        objContact.LastName = 'LastName';
        objContact.Email = 'addontest@addonblue.com';
        objContact.AccountId = objAccount.Id;
        insert objContact;
        
        objAccount.Primary_Contact__c = objContact.Id;
        update objAccount;
        
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        for(integer i= 0; i < 10; i++) { 
            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Accountid = objAccount.Id;
            objOpportunity.Name = 'person opportunity '+i;
            objOpportunity.Pricebook2Id = testPricebook.Id;
            objOpportunity.Payment_Method__c ='Credit Card';
            objOpportunity.Email__c = 'testperson'+ i +'@quintevnts.com';
            objOpportunity.Send_Payment_Email__c = false;
            objOpportunity.StageName = 'Canceled';
            objOpportunity.CloseDate = date.today(); 
            objOpportunity.Contact_Site__c = 'quintevents.com';   
            objOpportunity.Primary_Contact__c =  objContact.Id;  
            objOpportunity.Shipping_Outside_US__c = 'Yes';
            objOpportunity.CurrencyIsoCode = 'EUR'; 
            lstOpportunity.add(objOpportunity);
        }
        insert lstOpportunity;
        
        List<Order> lstOrder = new List<Order>();
        for(Opportunity objOpp : lstOpportunity) {
            Order objOrder = new Order();
            objOrder.AccountId = objOpp.AccountId;
            objOrder.Status = 'Draft';
            objOrder.OpportunityId = objOpp.Id;
            objOrder.CurrencyIsoCode = 'EUR';
            
            objOrder.Name = objOpp.Name.length() > 80 ? objOpp.Name.substring(0, 80) : objOpp.Name;
            objOrder.EffectiveDate = objOpp.Closedate;
            
            lstOrder.add(objOrder);
        }
        
        insert lstOrder;
        
        List<OpportunityLineItem> lstOppLineItem = new List<OpportunityLineItem>();
        for(Opportunity objOpportunity: lstOpportunity) { 
            OpportunityLineItem objoppLineItem = new OpportunityLineItem(
                Quantity = 3,
                PricebookEntryId = stdPriceBookEntries[1].Id, 
                Product2Id = stdPriceBookEntries[1].Id, 
                UnitPrice = 200, 
                OpportunityId = objOpportunity.Id
            );
            lstOppLineItem.add(objoppLineItem);
        }
        
        insert lstOppLineItem;
        
    }
    static testmethod void test() {        
        Test.startTest();
        createOrderLineItem objBatch = new createOrderLineItem();
        Id batchId = Database.executeBatch(objBatch);
        Test.stopTest();
    }
}
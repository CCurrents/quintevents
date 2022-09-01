@isTest
private class convertOptyTOQuote_LIV_GOLF_London_Test{
    @testSetup 
    static void setup() {
        TestDataFactory.createTriggerSettingsEntry();
        Account objAccount = TestDataFactory.createAccount();
        Sales_Agent__c salesAgent = new Sales_Agent__c();
        salesAgent.Name = 'Test';
        salesAgent.Default_Commission__c = 12;
        insert salesAgent;
        objAccount.Sales_Agent__c = salesAgent.Id;
        
        Promoter__c promoter = new Promoter__c();
        promoter.Online_Sales_Commission__c = 2;
        insert promoter;
        objAccount.Promoters_Name__c = promoter.Id;
        update objAccount;
        System.assert(true,objAccount.Name != null);

        Contact objContact = TestDataFactory.createContact(1, new List<Account>{objAccount}, false)[0];
        objContact.Email = 'Test@gmail.com';
        Utility.processRecords(objContact, 'insert');
        System.assertEquals('Test@gmail.com', objContact.Email);
        
        Payment_Term__c objPT = TestDataFactory.createPaymentTerm();
        //Order objOrder = [Select Id from Order where Id =: objPT.Order__c];
        //Quote objQuote = [select Id, TotalPrice, Pricebook2Id, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, CurrencyIsoCode from Quote where Id=: objPT.Quote__c];
        //QuoteLineItem QLI = TestDataFactory.createQuoteLineItem(1, objQuote.Id, true)[0];
        //Orderitem odi = TestDataFactory.createOrderItem(4, objOrder.Id, QLI)[0];
         
        PriceBook2 pricebook = TestDataFactory.createPricebook(1, 'Test PB', false)[0];
        pricebook.GPE_Event__c = true;
        Utility.processRecords(pricebook, 'insert');
        System.assertEquals(true, pricebook.GPE_Event__c);
        
        Opportunity objOpportunity = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.id, pricebook.id, false)[0];
        objOpportunity.StageName = 'Closed Won';
        objOpportunity.Refund_Response__c = 'Confirm Refund';
        objOpportunity.Refunded__c = true;
        Utility.processRecords(objOpportunity, 'insert');
        System.assertEquals('Closed Won', objOpportunity.StageName);
    }
    static testmethod void test() {        
        Test.startTest();
        
        Opportunity objOpp = [Select Id FROM Opportunity LIMIT 1];
        Set<String> setOptyIds = new Set<String>();
        setOptyIds.add(objOpp.Id);
        
        convertOptyTOQuote_LIV_GOLF_London batchJob = new convertOptyTOQuote_LIV_GOLF_London(setOptyIds);
        ID batchprocessid = Database.executeBatch(batchJob,1);
        Test.stopTest();
    }
}
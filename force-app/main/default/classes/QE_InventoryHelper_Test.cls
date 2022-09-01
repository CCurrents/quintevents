@isTest
private class QE_InventoryHelper_Test {
    
    static testMethod void testMethod_One() {
        // For Method: subtractFromInventory
        QE_TestDataFactory.createTestRecords();
        List<Quote> quotes = new List<Quote>([
            Select Id, Status, OpportunityId
            From Quote Limit 1
        ]);
        Quote personQuote = quotes[0];
        Test.startTest();
        personQuote.Status = 'Signed - Approved';
        update personQuote;
        Test.stopTest();
    }
    
    static testMethod void testMethod_Two() {
        // For Method: subtractFromInventory
        QE_TestDataFactory.createTestRecords();
        List<Quote> quotes = new List<Quote>([
            Select Id, Status, OpportunityId
            From Quote Limit 1
        ]);
        Quote personQuote = quotes[0];
        // For Method: addBackToInventory
        Opportunity personOpportunity = new Opportunity();
        personOpportunity.Id = personQuote.OpportunityId;
        personOpportunity.StageName = 'Request Cancelation';
        personOpportunity.Contract_Lost_Reason__c='Testing';
        personOpportunity.Reason_For_Cancellation__c = 'Training';
        personOpportunity.Change_Request_Detail__c = 'Testing';
        
        Test.startTest();        
        update personOpportunity;        
        system.debug('###'+personOpportunity.StageName);       
        personOpportunity.StageName = 'Canceled';
        update personOpportunity;
        system.debug('^^^^'+personOpportunity.StageName);
        Test.stopTest();
    }
    
    static testMethod void testMethod_Three() {
        // For Method: updateInventoryForOpportunity
        QE_TestDataFactory.createTestRecords();
        List<Quote> quotes = new List<Quote>([
            Select Id, Status, OpportunityId
            From Quote Limit 1
        ]);
        Quote personQuote = quotes[0];
        Opportunity personOpportunity = new Opportunity();
        personOpportunity.Id = personQuote.OpportunityId;
        personOpportunity.StageName = 'Closed Won';
               
        Test.startTest();
        QE_InventoryHelper.updateInventoryForOpportunity(new List<Opportunity>{personOpportunity});
        // Manually Closing Lost opportunity
        personOpportunity.StageName = 'Closed Lost';
        QE_InventoryHelper.updateInventoryForOpportunity(new List<Opportunity>{personOpportunity});
        Test.stopTest();
    }
    
}
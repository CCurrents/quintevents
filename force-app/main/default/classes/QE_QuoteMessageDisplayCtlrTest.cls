@isTest(SeeAllData = false)
private class QE_QuoteMessageDisplayCtlrTest { 
    static testMethod void quoteMessageDispTest() {
       Test.StartTest();
        Account a = new Account(Name='Test Account1');
        insert a;
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test2', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
        Insert eventTest;
        //INSERT OPPORTUNITY RECORD
        Opportunity opp = new Opportunity();
        opp.AccountId = a.Id;
        opp.Name = 'test record'; 
        opp.StageName = 'Prospecting';
        opp.CloseDate = date.today(); 
        opp.Event__c = eventTest.Id;
        insert opp;
        
        //INSERT QUOTE RECORD
        Quote quot = new Quote();
        quot.OpportunityId = opp.Id;
        quot.Name='Test Quote1';
        quot.Status='Draft';
        insert quot;
        
        //DEFINING STANDARD CONTROLLER
        ApexPages.StandardController sc = new ApexPages.StandardController(quot);        
        Test.setCurrentPageReference(new PageReference('Page.QE_QuoteMessageDisplayPage')); 
        System.currentPageReference().getParameters().put('id', quot.id);
        QE_QuoteMessageDisplayCtlr testQuoteMessageRecord = new QE_QuoteMessageDisplayCtlr(sc);

       Test.StopTest();
    }
}
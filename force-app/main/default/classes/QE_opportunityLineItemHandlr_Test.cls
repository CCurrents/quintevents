@isTest
public class QE_opportunityLineItemHandlr_Test{
     
    static testMethod void method1() { 
        Test.startTest();               
     
        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        Insert eventTest;
        
        Account accTest = new Account();
        accTest.Name = 'testAccount';
        insert accTest;
        
        Opportunity oppTest = new Opportunity();
        oppTest.Name = 'oppName';
        oppTest.AccountId = accTest.Id;
        oppTest.Event__c = eventTest.Id;
        oppTest.StageName = 'Prospecting';
        oppTest.CloseDate = System.today();
        insert oppTest;
        
        Pricebook2 pb22 = new Pricebook2(Name='testDIE');
        insert pb22;
        
        Product2 pro2 = new Product2(Name='BXCD', isActive=true, Event__c = eventTest.Id);
        insert pro2;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=pro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert OPplineitem2;
        delete OPplineitem2;
        Test.stopTest();
    }
    
 
}
@isTest
public class QE_Package_Helper_Test{
    
    static testMethod void method1() { 
        Test.startTest();
        Id prodRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Package'].Id;
        Account a = new Account(Name='Test Account');
        insert a;        
        QE360_Event__c even = new QE360_Event__c(Name='US',Active__c = true);
        insert even;
        Opportunity o = new Opportunity();
        o.Accountid = a.id;
        o.Name = 'test';
        o.Event__c=even.Id;
        o.Payment_Method__c='Credit Card';
        o.Send_Payment_Email__c=true;
        o.StageName = 'Prospecting';
        o.CloseDate = date.today();                
        insert o;
        Contact con =new Contact(LastName='Test',Primary_Contact__c=true,AccountId=a.Id,Opportunity__c=o.Id);
        insert con;
        QE360_Opportunity_Additional_Signee__c oppAddsign = new QE360_Opportunity_Additional_Signee__c();
        oppAddsign.Name='Test';
        oppAddsign.Amount__c=10;        
        oppAddsign.City__c='Test';        
        oppAddsign.Country__c='Test';        
        oppAddsign.Email__c='Test@test87.com';        
        oppAddsign.State__c='Test';
        oppAddsign.OpportunityS__c=o.Id;    
        insert oppAddsign;
        Quote quot = new Quote(Name='Test Quote',Payment_Terms__c = '1/2',OpportunityId=o.Id,Status='Signed - Approved',Payment_Method__c='Credit Card',Email='test@test435.com',Pricebook2Id = Test.getStandardPricebookId());
        insert quot;
        
        Product2 prod = new Product2(Name='Test Prod',Event__c=even.Id,RecordTypeId=prodRecType,isActive=false);
        insert prod; 
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=prod.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        QuoteLineItem Quolineitem2 = new QuoteLineItem (Quantity=2,Product2Id=prod.Id, QuoteId=quot.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert Quolineitem2;
        
        QE_Package_Helper obj = new QE_Package_Helper(new List<QuoteLineItem>{Quolineitem2});  
        obj.quoteAndQuotePackages.add(Quolineitem2);    
        obj.checkActive(); 
               
        Test.stopTest();
    }
    
}
/**
 * @File Name          : QE_Stripe_Customer_Helper_Test.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 12:29:11 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@istest
public class QE_Stripe_Customer_Helper_Test {
     @isTest static void test_method_one() {
 Test.startTest();
     
        Id prodRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Package'].Id;
        Account a = new Account(Name='Test Account');
        insert a;        
        QE360_Event__c even = new QE360_Event__c(Name='US');
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
        Quote quot = new Quote(Name='Test Quote',OpportunityId=o.Id,Status='Signed - Approved',Payment_Method__c='Credit Card',Email='test@test435.com',Pricebook2Id = Test.getStandardPricebookId());      
        insert quot;
        
         Quote quot1 = new Quote(Name='Test Quote',OpportunityId=o.Id,Status='Draft - Approved',Payment_Method__c='Credit Card',Email='test@test435.com',Pricebook2Id = Test.getStandardPricebookId());      
        insert quot1;
        
        Product2 prod = new Product2(Name='Test Prod',Event__c=even.Id,RecordTypeId=prodRecType,isActive=true);
        insert prod; 
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=prod.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        QuoteLineItem Quolineitem2 = new QuoteLineItem (Quantity=2, QuoteId=quot.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert Quolineitem2;
        
         
        QE360_Stripe_Customer__c testQeStripeCustomer = new QE360_Stripe_Customer__c(
            Email__c = 'jeetpatel24@quintevents.com',
            Stripe_Customer_Id__c = 'cus_2uDWpGJXnH0pyT'
        );
        insert testQeStripeCustomer;         
         QE_Stripe_Customer_Helper Q = new QE_Stripe_Customer_Helper();
            Q.searchCustomerRaw(testQeStripeCustomer.Email__c);
         Q.getStripeCustomerJson('test','123');
       
        Test.stopTest();
}
    
      @isTest static void test_method_one1() {
        Test.startTest();
        //init();
        Id prodRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Package'].Id;
        Account a = new Account(Name='Test Account');
        insert a;        
        QE360_Event__c even = new QE360_Event__c(Name='US');
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
        Quote quot = new Quote(Name='Test Quote',OpportunityId=o.Id,Status='Signed - Approved',Payment_Method__c='Credit Card',Email='test@test435.com',Pricebook2Id = Test.getStandardPricebookId());      
        insert quot;
        
         Quote quot1 = new Quote(Name='Test Quote',OpportunityId=o.Id,Status='Draft - Approved',Payment_Method__c='Credit Card',Email='test@test435.com',Pricebook2Id = Test.getStandardPricebookId());      
        insert quot1;
        
        Product2 prod = new Product2(Name='Test Prod',Event__c=even.Id,RecordTypeId=prodRecType,isActive=true);
        insert prod; 
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=prod.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        QuoteLineItem Quolineitem2 = new QuoteLineItem (Quantity=2, QuoteId=quot.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert Quolineitem2;
        

            
        ApexPages.StandardController sc = new ApexPages.StandardController(quot1);
        QE_EmailQuoteCtrl obj = new QE_EmailQuoteCtrl(sc);
        obj.sendWithDocuSign(); 
                
        //Email_Helper emaiObj = new Email_Helper();
        //emaiObj.compileEmail('00Xi0000001J3in', o.OwnerId, con.Id, quot.Id, quot.Email);
        //QE_Quote_Helper OE = new QE_Quote_Helper();
        //to cover QE_Quote_Helper
        // QE_Quote_Helper.createStipCustomer(new Set<Id>{o.Id});
        //QE_Quote_Helper.syncQuote(new Map<Id,Id>{quot.Id=>o.Id});   
        //OE.updateQuoteStatus(new List<Id>{quot.Id}, 'DocuSign-Trigger-AfterUpdate');
        obj.getQuoteAdditionalSignees();
        obj.closePopup();
        Test.stopTest();
    }
}
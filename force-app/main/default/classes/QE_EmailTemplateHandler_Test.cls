@isTest
public class QE_EmailTemplateHandler_Test{

    static testMethod void method1() { 
        Test.startTest();               
        Account a= new Account(Name='Test Account');
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
        Quote quot = new Quote(Name='Test Quote',Status='Signed - Approved',OpportunityId=o.Id,Payment_Method__c='Credit Card',Email='test@test435.com');
        insert quot;
        QE_EmailTemplateHandler obj = new QE_EmailTemplateHandler(); 
        obj.Confirmation_To_Client(quot);       
        obj.Confirmation_To_SalesRep(quot);       
        obj.Payment_Page_Access_Token(quot);       
        obj.Confirmation_To_Client_100_Payment();       
        obj.Confirmation_To_Accounting(quot);       
        Test.stopTest();
    }

}
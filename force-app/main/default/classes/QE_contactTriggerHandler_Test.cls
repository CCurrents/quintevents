@isTest
public class QE_contactTriggerHandler_Test{
    @testSetup static void dataSetUp() {
        
    }
    
    static testMethod void method1() { 
        Test.startTest();               
        Account acc = new Account(Name='Test Account');
        insert acc;
        List<Contact> conLst = new List<Contact>();
        conLst.add(new Contact(LastName='Test',Primary_Contact__c=true,AccountId=acc.Id));  
        conLst.add(new Contact(LastName='Test2',AccountId=acc.Id));  
        insert conLst; 
        conLst[1].Primary_Contact__c=true;
        conLst[1].LastName = 'Test4'; 
        conLst[1].Record_Id__c = 'Test4'; 
        conLst[1].FirstName = 'Test4'; 
        conLst[1].Salutation = 'Mr.'; 
        conLst[1].Sandbox_Record_Id__c = 'test5';
        update conLst[1];
        Intacct_API_Details__c cs = new Intacct_API_Details__c();
        cs.Production__c = false;
        cs.Sandbox_SenderId__c = '1234';
        cs.Sandbox_SenderPassword__c = '1234';
        cs.Sandbox_UserName__c = '1234';
        cs.Sandbox_CompanyId__c = '1234';
        cs.Sandbox_Password__c = '1234';
        cs.Sandbox_EndpointURL__c = 'test';
        insert cs;
        Test.stopTest();
    }
    
    static testMethod void method2() { 
        Test.startTest();               
        Account acc = new Account(Name='Test Account');
        insert acc;
        List<Contact> conLst = new List<Contact>();
        conLst.add(new Contact(LastName='Test',Primary_Contact__c=true,AccountId=acc.Id));  
        conLst.add(new Contact(LastName='Test2',AccountId=acc.Id));
        conLst.add(new Contact(LastName='Test3')); 
        insert conLst; 
        conLst[1].Primary_Contact__c=true; 
        update conLst[1];   
        Set<Id> ids = new Set<Id>();
        ids.add(conLst[1].Id);
        Test.stopTest();
    }
}
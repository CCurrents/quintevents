/**
 * @File Name          : QE_Quote_Trigger_Test.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 12:29:08 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
//This class also covers QE_Quote_Helper,QE_EmailQuoteCtrl,Email_Helper classes
@isTest
public class QE_Quote_Trigger_Test{
    @testSetup static void dataSetUp() {
        
    }
    
    static testMethod void method1() { 
        Test.startTest(); 
        Id prodRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Package'].Id;
        //Account a = new Account(Name='Test Account');
        //insert a;
        
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Source__c = 'call Virtuoso';
        lead.Email = 'test@quintevents.com';
        //lead.Company = 'test business';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
           
        QE360_Event__c even = new QE360_Event__c(Name='US');
        insert even;
        Opportunity o = new Opportunity();
        o.Accountid = testLead.ConvertedAccountId;
        o.Name = 'test';
        o.Event__c=even.Id;
        o.Payment_Method__c='Credit Card';
        o.Send_Payment_Email__c=true;
        o.StageName = 'Prospecting';
        o.CloseDate = date.today();     
        o.Contact_Site__c = 'quintevents.com';           
        insert o;
        //Contact con =new Contact(LastName='Test',Primary_Contact__c=true,AccountId=testLead.ConvertedAccountId,Opportunity__c=o.Id);
        //insert con;
        QE360_Opportunity_Additional_Signee__c oppAddsign = new QE360_Opportunity_Additional_Signee__c();
        oppAddsign.Name='Test';
        oppAddsign.Amount__c=10;        
        oppAddsign.City__c='Test';        
        oppAddsign.Country__c='Test';        
        oppAddsign.Email__c='Test@test87.com';        
        oppAddsign.State__c='Test';
        oppAddsign.OpportunityS__c=o.Id;    
        insert oppAddsign;
        Quote quot = new Quote(Name='Test Quote',OpportunityId=o.Id,Status='Signed - Approved',Payment_Method__c='Credit Card',Email='test@test435.com');
        insert quot;
        Product2 prod = new Product2(Name='Test Prod',Event__c=even.Id,RecordTypeId=prodRecType);
        insert prod; 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quot);
        QE_EmailQuoteCtrl obj = new QE_EmailQuoteCtrl(sc);
        obj.sendWithDocuSign(); 
                
        //Email_Helper emaiObj = new Email_Helper();
        //emaiObj.compileEmail('00Xi0000001J3in', o.OwnerId, con.Id, quot.Id, quot.Email);
        
        //to cover QE_Quote_Helper
        // QE_Quote_Helper.createStipCustomer(new Set<Id>{o.Id});
        //QE_Quote_Helper.syncQuote(new Map<Id,Id>{quot.Id=>o.Id});        
        Test.stopTest();
    }
    
    /*static testMethod void method2() { 
        Test.startTest();               
        Account acc = new Account(Name='Test Account');
        insert acc;
        List<Contact> conLst = new List<Contact>();
        conLst.add(new Contact(LastName='Test',Primary_Contact__c=true,AccountId=acc.Id));  
        conLst.add(new Contact(LastName='Test2',AccountId=acc.Id));  
        insert conLst; 
        conLst[1].Primary_Contact__c=true; 
        update conLst[1];       
        Test.stopTest();
    }*/
}
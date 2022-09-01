/**
 * @File Name          : QE_DSStatusHelperTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 2:31:24 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest(seeAllData=false)
global class QE_DSStatusHelperTest{

    @isTest static void test_method_one() {

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
        lead.Company = 'test business';
        lead.email = 'test@quintevents.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
        QE360_Event__c even = new QE360_Event__c(Name='mexico');
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
        Contact con =new Contact(LastName='Test',Primary_Contact__c=true,AccountId=testLead.ConvertedAccountId,Opportunity__c=o.Id);
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
        
        Quote quot = new Quote(Name='Test Quote',Payment_Terms__c = '1/2',OpportunityId=o.Id,Status='Draft',Payment_Method__c='Credit Card',Email='test@test435.com',Pricebook2Id = Test.getStandardPricebookId());
        insert quot;
        
        Product2 prod = new Product2(Name='Test Prod',Event__c=even.Id,RecordTypeId=prodRecType,isActive=true);
        insert prod; 
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=prod.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        QuoteLineItem Quolineitem2 = new QuoteLineItem (Quantity=2, QuoteId=quot.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert Quolineitem2;
                
        quot.Status = 'Draft - Approved';
        update quot;        
        
        dsfs__DocuSign_Status__c docuSign = new dsfs__DocuSign_Status__c(Standard_Quote__c=quot.id,dsfs__Envelope_Status__c='Completed Test',Counter_Signer_Envelope__c = false,dsfs__DocuSign_Envelope_ID__c='test123ID');                  
        list<dsfs__DocuSign_Status__c> docuSignList = new list<dsfs__DocuSign_Status__c>();
        Map<id,dsfs__DocuSign_Status__c> docuSignMap = new Map<id,dsfs__DocuSign_Status__c>();
        insert docuSign;
        
        dsfs__DocuSign_Status__c docuSign1 = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c='Completed',Counter_Signer_Envelope__c = false,dsfs__DocuSign_Envelope_ID__c='test1223ID');                  
        insert docuSign1;
        
        list<id> docuSignList1 = new list<id>();
        //docuSignList1.add(docuSign.id);
        
        list<id> quotids= new list<id>();
        quotids.add(quot.id);
        
        QE_DSStatusHelper.VoidEnvelope(quotids,docuSignList1);

        QE_DSStatusHelper.VoidEnvelopeFromOpp(quotids);
       
       
        Test.stopTest();
    }   
}
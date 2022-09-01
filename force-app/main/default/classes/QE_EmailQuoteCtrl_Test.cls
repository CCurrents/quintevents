@isTest(seeAllData=false)
public class QE_EmailQuoteCtrl_Test {
    
    @isTest static void test_method_one() {
        Test.startTest();
        Id prodRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Products'].Id;
        //Account a = new Account(Name='Test Account');
        //insert a;        
        
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Interested';
        lead.Source__c = 'call Virtuoso';
        lead.Company = 'test business';
        lead.Email = 'testemail@quintevents.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId, ConvertedContactId from Lead where Id = :lead.Id];
        
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
        o.Primary_Contact__c = testLead.ConvertedContactId;
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
        //Quote quot = new Quote(Name='Test Quote',Payment_Terms__c = '100%', OpportunityId=o.Id,Status='Signed - Approved',Payment_Method__c='Credit Card',Email='test@test435.com',Pricebook2Id = Test.getStandardPricebookId());      
        //insert quot;
        
         Quote quot1 = new Quote(Name='Test Quote',Payment_Terms__c = '100%', OpportunityId=o.Id,Status='Draft - Approved',Payment_Method__c='Credit Card',Email='test@test435.com',Pricebook2Id = Test.getStandardPricebookId());      
        insert quot1;
        
        dsfs__DocuSign_Status__c docuSignStatus = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Sent', Standard_Quote__c= quot1.id);
        insert docuSignStatus;
        
        Product2 prod = new Product2(Name='Test Prod',Type__c='Party',Event__c=even.Id,RecordTypeId=prodRecType,isActive=true);
        insert prod; 
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=prod.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        QuoteLineItem Quolineitem2 = new QuoteLineItem (Quantity=2, QuoteId=quot1.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert Quolineitem2;
        

            
        ApexPages.StandardController sc = new ApexPages.StandardController(quot1);
        QE_EmailQuoteCtrl obj = new QE_EmailQuoteCtrl(sc);
        obj.sendWithDocuSign(); 
        
        quot1.Status = 'Draft';
        update quot1;
        obj = new QE_EmailQuoteCtrl(sc);
        obj.sendWithDocuSign(); 
        //Email_Helper emaiObj = new Email_Helper();
        //emaiObj.compileEmail('00Xi0000001J3in', o.OwnerId, con.Id, quot.Id, quot.Email);
        //QE_Quote_Helper OE = new QE_Quote_Helper();
        //to cover QE_Quote_Helper
        //QE_Quote_Helper.createStipCustomer(new Set<Id>{o.Id});
        //QE_Quote_Helper.syncQuote(new Map<Id,Id>{quot.Id=>o.Id});   
        //OE.updateQuoteStatus(new List<Id>{quot.Id}, 'DocuSign-Trigger-AfterUpdate');
        obj.getQuoteAdditionalSignees();
        obj.createandSendWithDocuSign();
        obj.closePopup();
        Test.stopTest();
    }
    
}
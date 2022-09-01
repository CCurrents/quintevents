@isTest
public class QE_QuoteLineItemHandlerTest{

     @testSetup static void setup() {
        Id prodRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Package'].Id;
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
            lead.email = 'test@quintevents.com';
            insert lead;
            
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(lead.id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
    
            Lead testLead = [select Id, IsConverted, ConvertedAccountId, ConvertedContactId from Lead where Id = :lead.Id];
            
            QE360_Event__c even = new QE360_Event__c(Name='US',Active__c = true);
            even.End_Date__c = System.today().addDays(20);
            even.Start_Date__c = System.today().addDays(10);
            insert even;
            Parent_Package__c pp = new Parent_Package__c(Event__c=even.Id);
            insert pp;
            Product2 prod = new Product2(Name='Test Prod',Event__c=even.Id,RecordTypeId=prodRecType,isActive=true,Parent_Package__c=pp.Id);
            insert prod; 
            
            PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=prod.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                    isActive=true,UseStandardPrice = false);
            insert pbe2;
            
            // Opportunity        
            Opportunity o = new Opportunity();
            o.Accountid = testLead.ConvertedAccountId;
            o.Primary_Contact__c = testLead.ConvertedContactId;
            o.Name = 'test';
            o.Event__c=even.Id;
            o.Payment_Method__c='Credit Card';
            o.Send_Payment_Email__c=true;
            o.StageName = 'Prospecting';
            o.CloseDate = date.today();    
            o.Contact_Site__c = 'quintevents.com';            
            insert o;       
    }
    
    @isTest static void test_method() {
        
        Test.startTest();
        Opportunity o = [select id from opportunity where StageName = 'Prospecting' limit 1];
        pricebookentry pbe2 = [select id from pricebookentry limit 1];
        
        // Opportunity Line Item
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem (Record_Type__c = 'Package', Quantity=1, OpportunityId=o.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert opportunityLineItem;
    
        Quote quot = new Quote(Name='Test Quote',Payment_Terms__c = '1/2',OpportunityId=o.Id,Status='Draft',Payment_Method__c='Credit Card',Email='test@test435.com',Pricebook2Id = Test.getStandardPricebookId());
        insert quot;
        
        QuoteLineItem Quolineitem2 = new QuoteLineItem (Quantity=2, QuoteId=quot.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id,OpportunityLineItemId=opportunityLineItem.id);
        //insert Quolineitem2;
                
        quot.Status = 'Signed - Approved';
        //update quot;        
                      
        QE_QuoteLineItemHandler OE = new QE_QuoteLineItemHandler();
        
        //to cover QE_QuoteLineItemHandler
        OE.onBeforeInsert(new LIst<QuoteLineItem>{Quolineitem2});
        
        Test.stopTest();
    }
}
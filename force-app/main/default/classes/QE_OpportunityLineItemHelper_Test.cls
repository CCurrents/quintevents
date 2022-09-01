@isTest
public class QE_OpportunityLineItemHelper_Test {

    static testMethod void test_method_one() {
        
        
        // Lead to Account
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

        Lead testLead = [select Id, IsConverted, ConvertedAccountId,ConvertedContactId from Lead where Id = :lead.Id];
        
        // Event and Produts creation
        QE360_Event__c even = new QE360_Event__c(Name='US',Active__c = true, Start_Date__c = system.today(), End_Date__c = system.today().adddays(10));
        insert even;
        
        Id packageRecType =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId();
        Id productRecType =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId();
        
        Parent_Package__c  pp1 = new Parent_Package__c(Name = 'Parent Package 1 Demo', Event__c = even.Id);
        Insert pp1;
        
        Product2 packageOne = new Product2(Name='Test Prod',Shipping_and_Handling__c=1.00,Shipping_and_Handling_Outside_Us__c=1,Type__c='Package',Event__c=even.Id,RecordTypeId=packageRecType,isActive=true,Parent_Package__c = pp1.Id,Reward_Points_Percentage__c = 10);
        insert packageOne;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=packageOne.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false,CurrencyIsoCode='GBP');
        insert pbe2;
        
        Test.startTest();
        // Opportunity        
        Opportunity o = new Opportunity();
        o.Accountid = testLead.ConvertedAccountId;
        o.Name = 'test';
        o.Event__c=even.Id;
        o.Payment_Method__c='Credit Card';
        o.Send_Payment_Email__c=true;
        o.StageName = 'Prospecting';
        o.CloseDate = date.today();    
        o.Contact_Site__c = 'quintevents.com';
        o.Shipping_Outside_US__c = 'No';
        o.Primary_Contact__c = testLead.ConvertedContactId;
        o.Qualifies_For_Reward_Points__C =true;        
        o.CurrencyIsoCode = 'GBP';
        insert o;
        
        Contact con =new Contact(LastName='Test',Primary_Contact__c=true,AccountId=testLead.ConvertedAccountId,Opportunity__c=o.Id);
        insert con;
    
        // Opportunity Line Item
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem (Record_Type__c = 'Package', ProductType__c='Package', Quantity=1, OpportunityId=o.Id,TotalPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert opportunityLineItem;
        Update opportunityLineItem;
        QE_OpportunityLineItemHelper.DeleteVatProductCnt(new List<OpportunityLineItem>{opportunityLineItem});
        Test.stopTest();
  }
    
  

}
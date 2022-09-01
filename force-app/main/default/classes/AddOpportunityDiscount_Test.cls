@IsTest
private class AddOpportunityDiscount_Test{
    static testMethod void test_method_one() {
        Test.startTest();
        
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
        
        Id productRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Products'].Id;
        
        delete [Select Id from Product2 where Name='Discount'];
        Product2 packageOne = new Product2(Name='Discount',Shipping_and_Handling__c=1.00,Shipping_and_Handling_Outside_Us__c=1,Type__c='Discount',Event__c=even.Id,RecordTypeId=productRecType,isActive=true);
        insert packageOne;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=packageOne.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        system.debug('####pbe2=='+pbe2.id);
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
        insert o;
        
        Contact con =new Contact(LastName='Test',Primary_Contact__c=true,AccountId=testLead.ConvertedAccountId,Opportunity__c=o.Id);
        insert con;
    
        // Opportunity Line Item
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem (Record_Type__c = 'A La Carte', ProductType__c='Discount', Quantity=1, OpportunityId=o.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
       // insert opportunityLineItem;
        AddOpportunityDiscount.getDiscountType();
        AddOpportunityDiscount.getcreateDiscountItem(o.Id,125.00, 'Test Added Discount', 'Standard Sales Discount');
        
        Test.stopTest();
    }
}
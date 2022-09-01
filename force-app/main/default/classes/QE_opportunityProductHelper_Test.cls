@isTest
public class QE_opportunityProductHelper_Test {

    static testMethod void method1() {

        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        Insert eventTest;
        
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Converted';
        lead.Source__c = 'call Virtuoso';
        lead.email = 'testtesttest@quintevents.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId, ConvertedContactId from Lead where Id = :lead.Id];
        
        Opportunity oppTest = new Opportunity();
        oppTest.Name = 'oppName';
        oppTest.AccountId = testLead.ConvertedAccountId;
        oppTest.Event__c = eventTest.Id;
        oppTest.StageName = 'Prospecting';
        oppTest.CloseDate = System.today();
        oppTest.Contact_Site__c = 'quintevents.com';
        oppTest.Primary_Contact__c = testLead.ConvertedContactId;
        insert oppTest;
             Test.startTest();
         
        Parent_Package__c parentPakg = new Parent_Package__c(Event__c = eventTest.Id, Name='Test Parent pkg');
        insert parentPakg;

        Product2 proPack = new Product2(Name='BXCD11', isActive=true, 
                                        Event__c = eventTest.Id,
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId(), Parent_Package__c = parentPakg.Id);
        insert proPack ;
        
        Product2 proPro = new Product2(Name='BXCD22', isActive=true, 
                                       Event__c = eventTest.Id, Type__c = 'API',
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        insert proPro;
        
        Product2 proPro2 = new Product2(Name='BXCD33', isActive=true, 
                                       Event__c = eventTest.Id, Type__c = 'API',
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        insert proPro2;
        
        Product2 proHotel = new Product2(Name='BXCD44', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        insert proHotel;
        
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=proPack.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert OPplineitem2;
        
        new QE_opportunityProductHelper().captureDeletedOpportunityProducts(new List<OpportunityLineItem>{OPplineitem2});
        
        Opportunity_Product_Package_Hotel__c packHotel = new Opportunity_Product_Package_Hotel__c (Quantity__c=2, Opportunity__c =oppTest.Id,Package__c=proPro.Id,Hotel__c=proHotel.Id);
        insert packHotel;
        
        
        Package_Products__c packPro1 = new Package_Products__c(Package__c = proPack.Id, Products_and_Hotels__c = proPro.Id);
        insert packPro1;
        /*
        Package_Products__c packPro2 = new Package_Products__c(Package__c = proPack.Id, Products_and_Hotels__c = proHotel.Id);
        insert packPro2;
        */
        
        OPplineitem2.Quantity = 1;
        update OPplineitem2;
        delete OPplineitem2;
        
        Test.stopTest();
    }

}
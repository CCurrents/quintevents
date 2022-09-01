@isTest(seeAllData=false)
public class QE_hotelTransSelectionClass_Test {
 @isTest static void test_method_one() {
        
        
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
        Insert eventTest;
        
        //Account accTest = new Account(Name = 'testAccount');
        //insert accTest;
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
        lead.Source__c = 'call Virtuoso';
        lead.Company = 'test business';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
        Opportunity oppTest = new Opportunity(Name = 'oppName',Amount=1000,Payment_Terms__c= '1/2',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,StageName = 'Prospecting',CloseDate = System.today());
        insert oppTest;
        
        Pricebook2 pb22 = new Pricebook2(Name='testDIE');
        insert pb22;
        
        Product2 proPack = new Product2(Name='BXCD11', isActive=true, 
                                        Event__c = eventTest.Id,
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId());
        insert proPack ;
        Product2 proPro = new Product2(Name='BXCD22', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId());
        insert proPro;
        Product2 proPro2 = new Product2(Name='BXCD33', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId());
        insert proPro2;
        Product2 proHotel = new Product2(Name='BXCD44', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId());
        insert proHotel;
        
        Product2 proHotelTrans = new Product2(Name='BXCD46', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),
                                      Type__c='Transportation');
        insert proHotelTrans;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=proPack.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        Test.startTest();
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert OPplineitem2;
        
        Package_Products__c packPro1 = new Package_Products__c(Package__c = proPack.Id, Products_and_Hotels__c = proPro.Id);
        insert packPro1;
        Package_Products__c packPro2 = new Package_Products__c(Package__c = proPack.Id, Products_and_Hotels__c = proHotel.Id);
        insert packPro2;
        
        ApexPages.StandardController stdPro = new ApexPages.StandardController(proPack );
        ApexPages.currentPage().getParameters().put('id',proPack.id);
        QE_hotelTransportationSelectionClass QEClass = new QE_hotelTransportationSelectionClass(stdPro);
        
        QE_hotelTransportationSelectionClass.wrapperClass psec = new QE_hotelTransportationSelectionClass.wrapperClass( proPro, true);
        psec.selectedBit = true;
        QEClass.displayProduct();
        QEClass.displayProductValues[0].selectedBit = true;
        QEClass.addToHotel();
        QEClass.errorBit = true;
        
        Test.stopTest();
    }
}
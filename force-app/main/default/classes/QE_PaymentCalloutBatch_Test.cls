@isTest
public class QE_PaymentCalloutBatch_Test { 
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }
    /*
    static testmethod void test1(){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                          EmailEncodingKey = 'UTF-8', FirstName = 'First',LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id,
                          TimeZoneSidKey = 'America/Los_Angeles',
                          UserName = uniqueUserName);
        insert u;
        
        System.runAs(u) {
            List<Payment_Term__c> OptList = new List<Payment_Term__c>();
            
            
            Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
            Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();           
            
            //Id RecordTypeIdOpportunity =  [SELECT Id FROM RecordType WHERE sObjectType='Opportunity__c' AND Name='Business Account'].Id;
            //Id RecordTypeIdAccount =  [SELECT Id FROM RecordType WHERE sObjectType='Account' AND Name='Business Account'].Id;
            
            
            Lead lead = new Lead(Status = 'Qualified',FirstName = 'Test',LastName='Lead' , Source__c = 'call collegefootballexperiences.com',CurrencyIsoCode = 'EUR');
            insert lead;
            System.debug('lead >>> ' + lead);
            
            
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(lead.id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Account acc = new Account();
            acc.RecordTypeId = RecordTypeIdAccount;
            acc.Name = 'Test Account';
            acc.CurrencyIsoCode = 'EUR';
            acc.From_Lead_Convert__c = true;
            //acc.From_Lead_Convert__pc = true;
            insert acc;
            Lead convertedLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
            System.debug('convertedLead outside IF>>> ' + convertedLead);
            if (convertedLead != null) {
                System.debug('convertedLead inside IF >>> ' + convertedLead);
                acc.Id = convertedLead.ConvertedAccountId;
                System.debug('acc >>> ' + acc);
                update acc;
            }
            QE360_Event__c  event = new QE360_Event__c  (Name = 'Event For Testing',CurrencyIsoCode = 'EUR');
            insert event;
            Opportunity oppo = new Opportunity(RecordTypeId = RecordTypeIdOpportunity, Name = 'Hello world',StageName = 'ClosedWon',
                                               Payment_Method__c = 'Check',CloseDate = Date.newInstance(2018,2,2),Contact_Site__c = '   wimbledonexperiences.com',
                                               Account = acc,Event__c = event.Id);
            insert oppo;
            
            Payment_Term__c Opt = new Payment_Term__c(Intacct_Failure_Reason__c = 'Exception',
                                                                                Intacct_Line_Number__c = '12334', Intacct_Id__c = '324234',Record_Id__c = '223432',Intacct_Status__c = 'Failure',
                                                                                Opportunity__c = oppo.Id, Status__c = 'Failed');
            insert Opt;
            
            OptList.add(Opt);
            Database.QueryLocator QL;
            Database.BatchableContext BC;
            Test.startTest();
            QE_PaymentCalloutBatch pco = new QE_PaymentCalloutBatch();
            pco.start(BC);
            pco.execute(BC,OptList);
            pco.finish(BC);
            Test.stopTest();
        } 
    }
    */
    static testMethod void method1() {
        Test.startTest();               
     
        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        Insert eventTest;
        Intacct_API_Details__c batchfilter = Intacct_API_Details__c.getOrgDefaults();   
        batchfilter.Payment_Batch_Start_From__c = Date.newInstance(2018,12, 30);
        insert batchfilter;
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Interested';
        lead.Source__c = 'call Virtuoso';
        lead.Email = 'testemail@quintevents.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
        Opportunity oppTest = new Opportunity();
        oppTest.Name = 'oppName';
        oppTest.AccountId = testLead.ConvertedAccountId;
        oppTest.Event__c = eventTest.Id;
        oppTest.StageName = 'Prospecting';
        oppTest.CloseDate = System.today();
        oppTest.Contact_Site__c = 'quintevents.com';
        oppTest.Pricebook2Id = Test.getStandardPricebookId();
        insert oppTest;
        
        Pricebook2 pb22 = new Pricebook2(Name='testDIE');
        insert pb22;
        
        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = eventTest.Id;
        insert parentPackage;

        
        Product2 proPack = new Product2(Name='BXCD11', isActive=true, 
                                        Event__c = eventTest.Id,Parent_Package__c = parentPackage.id,
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId());
        insert proPack ;
        /*Product2 proPro = new Product2(Name='BXCD22', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        insert proPro;
        Product2 proPro2 = new Product2(Name='BXCD33', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        insert proPro2;*/
        Product2 proHotel = new Product2(Name='BXCD44', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        insert proHotel;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=proPack.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert OPplineitem2;
        
        
        Id RecordTypeIdOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Person Opportunity').getRecordTypeId();
        List<Payment_Term__c> OptList = new List<Payment_Term__c>();
        Payment_Term__c oppPayTermTest1 = new Payment_Term__c(Payment_Term__c = '1/2', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id,Status__c ='Passed');
        insert oppPayTermTest1;
                OptList.add(oppPayTermTest1);
        OPplineitem2.Quantity = 1;
        update OPplineitem2;
        
        Set<Id> opptIds = new Set<Id>();
        opptIds.add(oppTest.Id);
 
            Database.QueryLocator QL;
            Database.BatchableContext BC;
           
            QE_PaymentCalloutBatch pco = new QE_PaymentCalloutBatch();
            pco.start(BC);
            pco.execute(BC,OptList);
            pco.finish(BC);
        
        Test.stopTest();
    }
}
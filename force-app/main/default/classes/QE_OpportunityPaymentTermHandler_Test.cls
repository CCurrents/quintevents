/**
 * @File Name          : QE_OpportunityPaymentTermHandler_Test.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 4:45:47 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
public class QE_OpportunityPaymentTermHandler_Test {

    static testMethod void method1() {
        Test.startTest();               
     
        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        Insert eventTest;
        
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Qualified';
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
        insert oppTest;
        
        Pricebook2 pb22 = new Pricebook2(Name='testDIE');
        insert pb22;
        
        CS_Opportunity_Payment_Terms__c objcsOPT = new CS_Opportunity_Payment_Terms__c();
        objcsOPT.Profile_Id_for_delete_record__c = userinfo.getProfileId();
        insert objcsOPT;
        
        Product2 proPack = new Product2(Name='BXCD11', isActive=true, 
                                        Event__c = eventTest.Id,
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId());
        insert proPack ;
        Product2 proPro = new Product2(Name='BXCD22', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1,Type__c = 'ticket');
        insert proPro;
        Product2 proPro2 = new Product2(Name='BXCD33', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1,Type__c = 'Giftbag');
        insert proPro2;
        Product2 proHotel = new Product2(Name='BXCD44', isActive=true, 
                                       Event__c = eventTest.Id,
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        insert proHotel;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=proPack.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        Id RecordTypeIdOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Person Opportunity').getRecordTypeId();

        // Opportunity_Payment_Terms__c oppPayTermTest1 = new Opportunity_Payment_Terms__c(Payment_Term__c = '1/2', Amount__c=100, Percentage_Of_Payment__c=1, Opportunity__c = oppTest.Id,Status__c ='Passed');
        // insert oppPayTermTest1;
        
        // Delete oppPayTermTest1;
        QE_OpportunityPaymentTermHandler objCntrl = new QE_OpportunityPaymentTermHandler();
        Test.stopTest();
    }
    
}
/**
 * @File Name          : QE_MCShipmentHandlerTest.cls
 * @Description        : 
 * @Author             : Jheel Agrawal
 * @Group              : 
 * @Last Modified By   : Jheel Agrawal
 * @Last Modified On   : 7/7/2020, 5:17:09 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    7/7/2020   Jheel Agrawal     Initial Version
**/
@isTest
public class QE_MCShipmentHandlerTest {

    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();
    }
    
    static testMethod void InsertUpdateShipmentDetailsTest() { 
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
        o.Approval_Expected__c = '4 Hours';
        insert o;
        
        zkmulti__MCShipment__c  zz = new zkmulti__MCShipment__c();
        zz.Opportunity__c = O.Id;
        zz.zkmulti__Tracking_Number__c = 'Te!2312Wqe2';
        insert zz;
        
        zz.zkmulti__Tracking_Number__c = 'Te!2312Wqe2!!!!!!!';
        Update zz;
        
        //Delete [SELECT Name,Opportunity__c, Id, zkmulti__Tracking_Number__c FROM zkmulti__MCShipment__c where Opportunity__c =: o.id limit 1];
        //QE360_OpprotunityShipmentDetails.getShipmentRecords(o.id);
    
    Test.stopTest();
    }
    static testMethod void ShipmentDetailsTest_Delete() { 
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
        o.Approval_Expected__c = '4 Hours';
        insert o;
        
        zkmulti__MCShipment__c  zz = new zkmulti__MCShipment__c();
        zz.Opportunity__c = O.Id;
        zz.zkmulti__Tracking_Number__c = 'Te!2312Wqe2';
        insert zz;
        
        zz.zkmulti__Tracking_Number__c = 'Te!2312Wqe2!!!!!!!';
        Update zz;
        
        Delete [SELECT Name,Opportunity__c, Id, zkmulti__Tracking_Number__c FROM zkmulti__MCShipment__c where Opportunity__c =: o.id limit 1];
        //QE360_OpprotunityShipmentDetails.getShipmentRecords(o.id);
    
    Test.stopTest();
    }
    
}
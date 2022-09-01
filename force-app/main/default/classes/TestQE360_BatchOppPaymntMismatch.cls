/**
 * @File Name          : TestQE360_BatchOppPaymntMismatch.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 3:48:53 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
public class TestQE360_BatchOppPaymntMismatch{
    
    static testMethod void TestTocheckPayment() {
        String Accrecid = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        String Accrecid1 = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId  = Accrecid;
        acc.Name = 'testName';
        acc.From_Lead_Convert__c = true;
        acc.Record_Id__c = 'Sales Order-SO0050';
        insert acc;

        Contact contact = new Contact();
        contact.accountid = acc.id;
        contact.lastname='test';
        contact.email='test@test.com';
        contact.Primary_Contact__c  = true;
        contact.Record_Id__c = 'Sales Order-SO0050';
        insert contact;

        QE360_Event__c   evt = new QE360_Event__c();
        evt.Name = 'test event';
        evt.Start_Date__c = Date.Parse('8/21/2015');
        evt.End_Date__c = Date.Parse('8/24/2015');
        evt.Active__c = true;
        insert evt;

        String oppRecid = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecid;
        opp.accountid = acc.id;
        opp.Name = 'test opportunity';
        opp.StageName = 'Closed Won';
        opp.Payment_Method__c = 'Credit Card';
        opp.Event__c = evt.id;
        opp.CloseDate = date.parse('12/27/2017');
        opp.Contact_Site__c = 'barrettjacksonvip.com';
        opp.Record_Id__c  = 'Sales Order-SO0050';
        opp.Primary_Contact__c = contact.Id;
        opp.Online_Order__c = False;
        opp.Paid_In_Full__c = false;
        opp.order_payment_status__c = 'Not Paid';
        opp.Amount =10;
        insert opp;
        
    //     Opportunity_Payment_Terms__c objOppTerms = new Opportunity_Payment_Terms__c();
    //     objOppTerms.Opportunity__c = opp.Id;
    //     objOppTerms.Amount__c = 10;
    //     objOppTerms.Status__c = 'Passed';
    //     objOppTerms.Payment_Term__c = '100%';
    // //  objOppTerms.Opportunity_Event_Start_Date__c = system.today();
    // //  objOppTerms.Event_Payment_Term_Start_Date__c = system.today();
    //     insert objOppTerms;
        
        SchedulableContext sc = null;
        QE360_BatchOppPaymntMismatch tsc = new QE360_BatchOppPaymntMismatch();
        QE360_BatchOppPaymntMismatch.scheduleIt();
        tsc.execute(sc);
    
    }
}
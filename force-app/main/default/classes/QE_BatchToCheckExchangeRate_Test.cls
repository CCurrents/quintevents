@isTest
public class QE_BatchToCheckExchangeRate_Test{
    
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
        insert evt;

        String oppRecid = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecid;
        opp.accountid = acc.id;
        opp.Name = 'test opportunity';
        opp.StageName = 'Qualified';
        opp.Payment_Method__c = 'Check';
        opp.Event__c = evt.id;
        opp.CloseDate = date.parse('12/27/2017');
        opp.Contact_Site__c = 'barrettjacksonvip.com';
        opp.Record_Id__c  = 'Sales Order-SO0050';
        opp.Primary_Contact__c = contact.Id;
        opp.Online_Order__c = False;
        opp.Paid_In_Full__c = false;
        opp.order_payment_status__c = 'Not Paid';
        opp.GPE_Online_Order__c = true;        
        opp.CurrencyIsoCode = 'GBP';
        insert opp;
        
        //INSERT QUOTE RECORD
        Quote quot = new Quote();
        quot.OpportunityId = opp.Id;
        quot.Name='Test Quote1';
        quot.Status='Draft';
        insert quot;
               
        SchedulableContext sc = null;        
        QE_BatchToCheckExchangeRate  b1 = new QE_BatchToCheckExchangeRate();
        Database.executeBatch(b1);
        QE_ScheduleTocheckExchangeRateonOpp tsc = new QE_ScheduleTocheckExchangeRateonOpp();
        QE_ScheduleTocheckExchangeRateonOpp.scheduleMe();
        tsc.execute(sc);
       
        
    
    }
}
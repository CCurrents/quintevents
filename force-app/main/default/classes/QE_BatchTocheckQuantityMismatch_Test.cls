@isTest
public class QE_BatchTocheckQuantityMismatch_Test{
    
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
        evt.Start_Date__c = system.today().adddays(1);
        evt.End_Date__c = system.today().adddays(4);
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
        insert opp;
        
        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = evt.Id;
        insert parentPackage;
        
        Product2 proPack = new Product2(Name='BXCD11', isActive=true, 
                                        Event__c = evt.Id,Parent_Package__c = parentPackage.Id,
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId());
        insert proPack;
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=proPack.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        List<OpportunityLineItem> lstoppline = new List<OpportunityLineItem>();
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=opp.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id,Record_Type__c='Package');
        lstoppline.add(OPplineitem2);
        OpportunityLineItem OPplineitem3 = new OpportunityLineItem (Quantity=1, OpportunityId=opp.Id,Package__c= proPack.Id,UnitPrice=0.02,PriceBookEntryId=pbe2.Id,Record_Type__c='Package Product');
        lstoppline.add(OPplineitem3);
        
        insert lstoppline;
        
        SchedulableContext sc = null;        
        QE_BatchTocheckQuantityMismatch b1 = new QE_BatchTocheckQuantityMismatch();
        Database.executeBatch(b1);
        QE_ScheduleTocheckQuantityMismatch tsc = new QE_ScheduleTocheckQuantityMismatch();
        QE_ScheduleTocheckQuantityMismatch.scheduleMe();
        tsc.execute(sc);
       
        
    
    }
}
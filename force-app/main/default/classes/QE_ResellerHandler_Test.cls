@isTest
public class QE_ResellerHandler_Test {

    static testMethod void createReseller() {
        // Create Partner
        Program__c testPartner = new Program__c(
            Name = 'Test Partner One'
        );
        Insert testPartner;
        // Create Event
        List<QE360_Event__c> eventsToBeInserted = new List<QE360_Event__c>();
        QE360_Event__c testEventOne =  new QE360_Event__c(
            Name = 'Test Event One',
            Program__c = testPartner.Id,
            Active__c = true
        );
        eventsToBeInserted.add(testEventOne);
        QE360_Event__c testEventTwo =  new QE360_Event__c(
            Name = 'Test Event Two',
            Active__c = true,
            Program__c = testPartner.Id
        );
        eventsToBeInserted.add(testEventTwo);
        Insert eventsToBeInserted;
        
         Map<Id,Reseller__C> newresMap = new Map<Id,Reseller__c>();
         for( Reseller__c res:[select id,name,program__c from Reseller__c ]){
             newresMap.put(res.id,res);            
             }
        // Create Reseller
        List<Reseller__C> resToBeInserted = new List<Reseller__C>();
        Reseller__c reseller = new Reseller__c();
        reseller.Name = 'test';
        reseller.Program__c = testPartner.Id;
        resToBeInserted.add(reseller);
        Insert resToBeInserted;
        
        QE_ResellerHandler resHandler = new QE_ResellerHandler();
        resHandler.onAfterInsert(resToBeInserted,newresMap);
    }
    
    
}
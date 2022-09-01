@isTest
public class QE_EventPaymentTermsHelper_Test {

    static testMethod void deleteEventPaymentTerm() {
    
        Test.startTest();               
     
        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        Insert eventTest;
     
        Event_Payment_Terms__c evt1 = new Event_Payment_Terms__c(Event__c = eventTest.Id, Payment_Term__c = '100%');
        insert evt1;
                
        Delete evt1;
        
        Test.stopTest();
    }
    
}
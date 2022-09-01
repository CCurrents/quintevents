@isTest
public class QE_ResellerEventHelper_Test {

    static testMethod void deleteReseller() {
    
        Test.startTest();         
     
        Reseller_Event__c resellerEvent = new Reseller_Event__c();
        resellerEvent.Commission_Percent__c  = 2;
        Insert resellerEvent;
                
        Delete resellerEvent;
        
        Test.stopTest();
    }
    
}
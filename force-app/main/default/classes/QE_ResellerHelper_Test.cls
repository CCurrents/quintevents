@isTest
public class QE_ResellerHelper_Test {

    static testMethod void deleteReseller() {
    
        Test.startTest();               
     
        Reseller__c reseller = new Reseller__c();
        reseller.Name = 'test';
        Insert reseller;
                
        Delete reseller;
        
        Test.stopTest();
    }
    
}
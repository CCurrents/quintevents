@isTest
public class QE_PromoterHelper_Test {

    static testMethod void deletePromoter() {
    
        Test.startTest();               
     
        Promoter__c promoter = new Promoter__c();
        promoter.Name = 'test';
        Insert promoter;
                
        Delete promoter;
        
        Test.stopTest();
    }
    
}
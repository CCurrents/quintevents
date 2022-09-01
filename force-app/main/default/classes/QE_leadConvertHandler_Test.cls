@isTest(seeAllData=false)
public class QE_leadConvertHandler_Test {
	
    public static void init(){
    	
    }
    
    @isTest static void test_method_one() {
        Test.startTest();
        init();
        Lead newTestLead = new Lead();
		newTestLead.LastName = 'TestLead';
		newTestLead.Status = 'Open';
		newTestLead.Source__c = 'call collegefootballexperiences.com';
        newTestLead.Lead_Type__c = 'Business';
		insert newTestLead;
        QE_leadConvertHandler.convertLeadBasedOnLeadType( newTestLead.Id );
		
    	Test.stopTest();
    }
    @isTest static void test_method_two() {
        Test.startTest();
        init();
        Lead newTestLead = new Lead();
		newTestLead.LastName = 'TestLead';
		newTestLead.Status = 'Open';
		newTestLead.Source__c = 'call collegefootballexperiences.com';
        insert newTestLead;
        QE_leadConvertHandler.convertLeadBasedOnLeadType( newTestLead.Id );
		
        Lead newTestLead2 = new Lead();
		newTestLead2.LastName = 'TestLead';
		newTestLead2.Status = 'Open';
		newTestLead2.Source__c = 'call collegefootballexperiences.com';
        newTestLead2.Company_Name__c = 'tstcomp';
        insert newTestLead2;
        QE_leadConvertHandler.convertLeadBasedOnLeadType( newTestLead2.Id );
        QE_leadConvertHandler.convertLeadBasedOnLeadType( '01p21000000EnTZ' );
    	Test.stopTest();
    }
    
}
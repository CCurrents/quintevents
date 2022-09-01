@isTest(seeAllData=false)
public class QE_QuotePDFCustomButton_Test {
	public static void init(){
    	
    }
    
    @isTest static void test_method_one() {
        Test.startTest();
        init();
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
        Insert eventTest;
        
        Account accTest = new Account(Name = 'testAccount');
        insert accTest;
        
        Opportunity oppTest = new Opportunity(Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '1/2',AccountId = accTest.Id,Event__c = eventTest.Id,StageName = 'Prospecting',CloseDate = System.today());
        insert oppTest;
        
        Quote quoteTest = new Quote(Name = 'test',Payment_Method__c = 'Credit Card',OpportunityId = oppTest.Id,Pricebook2Id = Test.getStandardPricebookId());
        insert quoteTest;
        
        QE_QuotePDFCustomButton.makeQuotePDF(quoteTest.Id);
        Test.stopTest();
    }
}
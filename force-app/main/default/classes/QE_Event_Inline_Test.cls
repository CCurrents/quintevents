@isTest(seeAllData=false)
public class QE_Event_Inline_Test {
	
    public static void init(){
    	
    }
    
    @isTest static void test_method_one() {
        Test.startTest();
        init();
        QE360_Event__c qe = new QE360_Event__c();
		qe.Name = 'test';
        qe.X100__c = true;
        qe.X1_2__c = true;
        qe.X1_3__c = true;
        qe.Custom__c = 2;
		insert qe;
        
        Event_Payment_Terms__c evePayTermTest = new Event_Payment_Terms__c();
        evePayTermTest.Payment_Term__c = '100%';
        evePayTermTest.Event__c = qe.Id;
        insert evePayTermTest;
        Event_Payment_Terms__c evePayTermTest1 = new Event_Payment_Terms__c();
        evePayTermTest1.Payment_Term__c = '1/2';
        evePayTermTest1.Event__c = qe.Id;
        insert evePayTermTest1;
        Event_Payment_Terms__c evePayTermTest2 = new Event_Payment_Terms__c();
        evePayTermTest2.Payment_Term__c = '1/3';
        evePayTermTest2.Event__c = qe.Id;
        insert evePayTermTest2;
        Event_Payment_Terms__c evePayTermTest3 = new Event_Payment_Terms__c();
        evePayTermTest3.Payment_Term__c = 'Custom';
        evePayTermTest3.Event__c = qe.Id;
        insert evePayTermTest3;

        ApexPages.StandardController stdEvent = new ApexPages.StandardController(qe);
		ApexPages.currentPage().getParameters().put('id',qe.id);
		QE_Event_Inline QEClass = new QE_Event_Inline(stdEvent);
        ApexPages.currentPage().getParameters().put('index', '1');
	
		QEClass.paymentList();
        QEClass.savePaymentTerm();
        QEClass.delRow();
        QEClass.cangePaymentTerm();
        Test.stopTest();
    }
    
    @isTest static void test_method_two() {
        Test.startTest();
        init();
        QE360_Event__c qe = new QE360_Event__c();
		qe.Name = 'test';
        qe.X100__c = true;
        qe.X1_2__c = false;
        qe.X1_3__c = false;
        qe.Custom__c = null;
		insert qe;
        
        Event_Payment_Terms__c evePayTermTest = new Event_Payment_Terms__c();
        evePayTermTest.Payment_Term__c = '100%';
        evePayTermTest.Event__c = qe.Id;
        insert evePayTermTest;
        Event_Payment_Terms__c evePayTermTest1 = new Event_Payment_Terms__c();
        evePayTermTest1.Payment_Term__c = '1/2';
        evePayTermTest1.Event__c = qe.Id;
        insert evePayTermTest1;
        Event_Payment_Terms__c evePayTermTest2 = new Event_Payment_Terms__c();
        evePayTermTest2.Payment_Term__c = '1/3';
        evePayTermTest2.Event__c = qe.Id;
        insert evePayTermTest2;
        Event_Payment_Terms__c evePayTermTest3 = new Event_Payment_Terms__c();
        evePayTermTest3.Payment_Term__c = 'Custom';
        evePayTermTest3.Event__c = qe.Id;
        insert evePayTermTest3;

        ApexPages.StandardController stdEvent = new ApexPages.StandardController(qe);
		ApexPages.currentPage().getParameters().put('id',qe.id);
		QE_Event_Inline QEClass = new QE_Event_Inline(stdEvent);
        ApexPages.currentPage().getParameters().put('index', '1');
	
		QEClass.paymentList();
        QEClass.savePaymentTerm();
        QEClass.cangePaymentTerm();
        QEClass.selectedPayTerm = '1/2';
        Test.stopTest();
    }
}
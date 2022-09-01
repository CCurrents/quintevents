@isTest(seeAllData=false)
public class QE_leadConvertHandler_Class_Test { 
    public static void init(){
        
    }
    
    @isTest static void test_method_one() {
        Test.startTest();
        init();
        Lead newTestLead = new Lead();
        newTestLead.LastName = 'TestLead';
        newTestLead.Status = 'Open';
        newTestLead.Source__c = 'call collegefootballexperiences.com';
        newTestLead.Company = null;
        newTestLead.Company_Name__c = null;
        newTestLead.Lead_Type__c = 'Business';
        insert newTestLead;
        
         ApexPages.StandardController stdlead = new ApexPages.StandardController(newTestLead);
         ApexPages.currentPage().getParameters().put('id',newTestLead.id);
         QE_leadConvertHandler_Class LeadClass = new QE_leadConvertHandler_Class(stdlead);
        
         LeadClass.leadId = newTestLead.Id;
         LeadClass.convertLeadBasedOnLeadType();
         LeadClass.closePopup();
         LeadClass.leadId = null;
         LeadClass.closePopup();
         Test.stopTest();
    }
    
    @isTest static void test_method_two() {
        Test.startTest();
        init();
        
        Lead newTestLead1 = new Lead();
        newTestLead1.LastName = 'TestLead1';
        newTestLead1.Status = 'Open';
        newTestLead1.Company_Name__c = 'abcd';
        newTestLead1.Lead_Type__c = 'Person';
        newTestLead1.Company_Name__c = null;
        newTestLead1.Company = null;
        insert newTestLead1;
        
        Database.LeadConvert ldc = new database.LeadConvert();
        ldc.setLeadId(newTestLead1.id);
        ldc.setConvertedStatus('Converted');
        ldc.setDoNotCreateOpportunity(true);
        Database.LeadConvertResult lcr = Database.convertLead(ldc);
        
        
        ApexPages.StandardController stdlead = new ApexPages.StandardController(newTestLead1);
        ApexPages.currentPage().getParameters().put('id',newTestLead1.id);
        QE_leadConvertHandler_Class LeadClass = new QE_leadConvertHandler_Class(stdlead);
         
         LeadClass.leadId = newTestLead1.Id;
         LeadClass.convertLeadBasedOnLeadType();
         LeadClass.status = 'No Record';
         LeadClass.closePopup();
         LeadClass.leadId = null;
         LeadClass.closePopup();
         Test.stopTest();
    }
}
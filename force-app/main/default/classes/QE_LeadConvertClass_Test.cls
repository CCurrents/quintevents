@isTest(seeAllData=false)
public class QE_LeadConvertClass_Test{
    @isTest static void testMethodOne(){
        Test.startTest();
        
        Lead newTestLead = new Lead();
        newTestLead.FirstName = 'TestLead';
        newTestLead.LastName = 'TestLead';
        newTestLead.Status = 'Open';
        newTestLead.Source__c = 'call collegefootballexperiences.com';
        newTestLead.Company = null;
        newTestLead.Company_Name__c = null;
        newTestLead.Lead_Type__c = 'Business';
        insert newTestLead;
        
        
        Lead newTestLead1 = new Lead();
        newTestLead1.FirstName = 'TestLead';
        newTestLead1.LastName = 'TestLead';
        newTestLead1.Status = 'Open';
        newTestLead1.Source__c = 'call collegefootballexperiences.com';
        newTestLead1.Company = null;
        newTestLead1.Company_Name__c = null;
        newTestLead1.Lead_Type__c = 'Person';
        insert newTestLead1;
        
        Lead newTestLead2 = new Lead();
        newTestLead2.FirstName = 'TestLead';
        newTestLead2.LastName = 'TestLead';
        newTestLead2.Status = 'Open';
        newTestLead2.Source__c = 'call collegefootballexperiences.com';
        newTestLead2.Company = null;
        newTestLead2.Company_Name__c = null;
        newTestLead2.Lead_Type__c = 'Business';
        insert newTestLead2;
        
        QE360_Event__c testEvent = new QE360_Event__c(Name='Test Event');
        insert testEvent;
        
        Opportunity opportunity = new opportunity();
        opportunity.name = 'test opp123';  
        opportunity.stagename = 'Qualified'; 
        opportunity.Payment_Method__c = 'Check'; 
        opportunity.Event__c = testEvent.id; 
        opportunity.CloseDate = system.today().adddays(30); 
        opportunity.Contact_Site__c = 'test.com';
        opportunity.CurrencyIsoCode = 'U.S.Dollar';
        opportunity.Projected_Revenue__c = 100;
        
        Account acc = new Account();
        acc.Preferred_Method_of_Contact__pc = 'email';
               
        QE_LeadConvertClass.retrieveLeadInfo(newTestLead1.id);
        QE_LeadConvertClass.convertLead(newTestLead1.id,opportunity,acc,newTestLead2);
        
        Opportunity opportunity1 = new opportunity();
        opportunity1.name = 'test opp123';  
        opportunity1.stagename = 'Qualified'; 
        opportunity1.Payment_Method__c = null; 
        opportunity1.Event__c = null; 
        opportunity1.CloseDate = null; 
        opportunity1.Contact_Site__c = null;
        opportunity1.CurrencyIsoCode = null;
        opportunity.Projected_Revenue__c = null;
        QE_LeadConvertClass.retrieveLeadInfo(newTestLead2.id);
        QE_LeadConvertClass.convertLead(newTestLead2.id,opportunity1,acc,newTestLead2);
        
        Test.stopTest();
    }
}
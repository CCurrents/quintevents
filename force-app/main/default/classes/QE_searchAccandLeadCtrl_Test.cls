@isTest
public class QE_searchAccandLeadCtrl_Test{
    
    @isTest static void test_method_one() {      
        // Event
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
        Insert eventTest;
        
        // Lead
        Lead lead = new Lead();            
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Interested';
        lead.Source__c = 'call Virtuoso';
        lead.Email = 'test@test.com';
        lead.CreatedById = UserInfo.getUserId();
        lead.OwnerId = UserInfo.getUserId();
        lead.From_Lead_Convert__c = true;
        insert lead;
        
        // Convert Lead        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        QE_searchAccandLeadCtrl searchEvent = new QE_searchAccandLeadCtrl();
        
        test.startTest();
        searchEvent.searchbox(); 
        test.stopTest();
    }
    @isTest static void test_method_two() {      
        // Event
        QE360_Event__c eventTest1 = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
        Insert eventTest1;
        List<Lead> leadList = new List<Lead>();
        for(Integer i=1; i< 710; i++) {
            Lead lead = new Lead();            
            lead.FirstName = 'testName';
            lead.LastName = 'testName';
            lead.Status = 'Interested';
            lead.Source__c = 'call Virtuoso';
            lead.Email = 'test@test'+i+'.com';
            lead.CreatedById = UserInfo.getUserId();
            lead.OwnerId = UserInfo.getUserId();
            lead.From_Lead_Convert__c = true;
            leadList.add(lead);
        }
        insert leadList;
        Set<Id> ids = new Set<Id>();
        for(Lead ld:leadList){
            ids.add(ld.id);
        }
        List<Lead> ldlist = [SELECT Id From LEAD where id in :ids];
        System.debug('---ldlist---'+ldlist);     
        System.assertEquals(leadList.size(),709);
        
        QE_searchAccandLeadCtrl searchEvent = new QE_searchAccandLeadCtrl();
        test.startTest();
        searchEvent.searchstring ='Super bowl LIII';
        searchEvent.searchbox();
        test.stopTest();        
        
    }
}
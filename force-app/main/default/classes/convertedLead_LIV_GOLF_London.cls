global class convertedLead_LIV_GOLF_London implements Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global Set<String> setLeadId;
    global Date oppCloseDate;
    global convertedLead_LIV_GOLF_London(Set<String> setIds, Date closeDate){
        this.setLeadId = setIds;
        this.oppCloseDate = closeDate;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('Select Id From Lead WHERE Id IN :setLeadId');
    }
    global void execute(Database.BatchableContext bc, List<Lead> scope) {
        
        for(Lead objLead: scope){
            String LeadId = objLead.Id;

            Opportunity opportunity = new Opportunity();
            opportunity.Pricebook2Id = '01s4z0000004gYaAAI';
            Opportunity.Projected_Revenue__c = 100;
            Opportunity.CurrencyIsoCode = 'USD';
            Opportunity.CloseDate = oppCloseDate;
            
            Account account = new Account();
            Account.Preferred_Method_of_Contact__pc = 'Email';
            
            Lead lead = new Lead();
            lead.Lead_Type__c = 'Person';
            lead.Marketing_Email_Consent__c = 'Yes';
            
            LeadConvertClass_LEX.convertLead(LeadId, opportunity, account, lead);
        }
    }    
    global void finish(Database.BatchableContext bc) {
        System.debug(recordsProcessed + ' records processed. Shazam!');
    }    
}
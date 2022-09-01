public with sharing class QE_LeadConversionHelper {
  public static Database.LeadConvertResult convert(Id leadId) {
    Lead lead = [SELECT Id, Name, Company, Company_Name__c, Lead_Type__c FROM Lead WHERE Id = :leadId];

    Database.LeadConvert lc = new Database.LeadConvert();
    lc.setLeadId(lead.id);
    lc.setConvertedStatus('Converted');
    lc.setDoNotCreateOpportunity(true);

    if (lead.Lead_Type__c == 'Business') {
      if (lead.Company == null || lead.Company == '') {
        lead.Company = lead.Company_Name__c;
      }
    } else if (lead.Lead_Type__c == 'Person') {
      lead.Company = null;
    }

    update lead;

    return Database.convertLead(lc);
  }
}
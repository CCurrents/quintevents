/**
 * @File Name          : LeadConversionHelper.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/28/2020, 2:34:32 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/27/2020   jagrawal@addonblue.com     Initial Version
**/
public class LeadConversionHelper {
    // #243 Too many SOQL issue resolution -- START
    public static Database.LeadConvertResult convert(Lead lead) {
    // public static Database.LeadConvertResult convert(Id leadId) {
    //      Lead lead = [SELECT Id, Name, Company, Company_Name__c, Lead_Type__c FROM Lead WHERE Id = :leadId];
    // #243 Too many SOQL issue resolution -- END
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
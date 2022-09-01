/**
 * @File Name          : QE_OpportunityPaymentTermHandler.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 3:46:25 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
public class QE_OpportunityPaymentTermHandler {
 
    //Constructor 
    public QE_OpportunityPaymentTermHandler() {
    
    }
    
    //Update fields before inserting
    // public static void onBeforeDelete(List<Opportunity_Payment_Terms__c> lstOppPaymentTerms) {
    //     try {
    //         set<Id> setOpportunity = new Set<id>();
    //         Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>();
    //         for(Opportunity_Payment_Terms__c opt : lstOppPaymentTerms) {
    //             setOpportunity.add(opt.Opportunity__c);
    //         }
    //         for(Opportunity objopp : [select id,name,Stagename from Opportunity where id in:setOpportunity]) {
    //             mapOpp.put(objopp.id,objopp);
    //         }
    //         CS_Opportunity_Payment_Terms__c objcsOPT = CS_Opportunity_Payment_Terms__c.getInstance();
    //         String strcsOPT = objcsOPT.Profile_Id_for_delete_record__c;
            
    //         for(Opportunity_Payment_Terms__c objopt : lstOppPaymentTerms) {
    //             if(objopt.Opportunity__c != null && userinfo.getProfileId() != strcsOPT 
    //                     && mapOpp.get(objopt.Opportunity__c).StageName == 'Closed Won') {
    //                 objopt.addError(Label.Closed_won_validation_Message);
    //             }
    //         }
    //     } catch(exception ex) { }
    // }
}
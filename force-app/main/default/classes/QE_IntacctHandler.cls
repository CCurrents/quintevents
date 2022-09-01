public class QE_IntacctHandler{
    public void OnAfterInsert(List<Opportunity> newObjects){
        for(Opportunity oppt : newObjects){
        //Intacct Callout
           // System.debug('OnAfterInsert> ');
            Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults(); 
            if(oppt.StageName == 'Closed Won' && cs.Active__c == true) {
              QE_Intacct_FutureCallout.sendDataIntacct(oppt.Id);
            }
        }
    }
    
    public void OnAfterUpdate(List<Opportunity> oldObjects, List<Opportunity> updatedObjects,Map<Id,Opportunity> MapObjectMap,Map<Id,Opportunity> oldObjectMap){
        for(Opportunity opp: updatedObjects){
        //Intacct Callout
            Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults(); 
            if(opp.StageName == 'Closed Won' && oldObjectMap.get(opp.Id).StageName != 'Closed Won' && cs.Active__c == true) {
              QE_Intacct_FutureCallout.sendDataIntacct(opp.Id);
              //QE_Intacct_FutureCallout.createAttachmentsAPInfo(opp.Id);
            }
            if(opp.StageName == 'Closed Won' && ( MapObjectMap.get(opp.id).AP_Contact_Email__c != oldObjectMap.get(opp.id).AP_Contact_Email__c || MapObjectMap.get(opp.id).AP_Contact_Name__c != oldObjectMap.get(opp.id).AP_Contact_Name__c || MapObjectMap.get(opp.id).AP_Contact_Phone__c != oldObjectMap.get(opp.id).AP_Contact_Phone__c)){
            //if(opp.StageName == 'Closed Won' && oldObjectMap.get(opp.Id).StageName != 'Closed Won' && cs.Active__c == true) {
              QE_Intacct_FutureCallout.updateIntacctInvoiceAPInfo(opp.Id);
            }
        }
    }
}
public class QE_MCShipmentHelper {
 
   
    public static void updateTrackingNumber(set<string> CurrentOppId){
               
        List<opportunity> lstOpportunityold = [SELECT Id, Tracking_Number__c,(Select Id,zkmulti__Tracking_Number__c from Shipments__r where zkmulti__Tracking_Number__c != null)  FROM Opportunity where Id IN : CurrentOppId];
        Boolean isFirst = true;
        if(lstOpportunityold != null && lstOpportunityold.size()>0){
            for(Opportunity ObjOpp : lstOpportunityold) {
                ObjOpp.Tracking_Number__c = '';  
                for (zkmulti__MCShipment__c mcshpment : ObjOpp.Shipments__r){
                    if(isFirst) {
                        ObjOpp.Tracking_Number__c += mcshpment.zkmulti__Tracking_Number__c;
                        isFirst = false;
                    }
                    else {
                        ObjOpp.Tracking_Number__c += ',' + mcshpment.zkmulti__Tracking_Number__c; 
                    }
                    
                }
            }
            upsert lstOpportunityold;
        }
    }
    
    public static void deleteTrackingNumber(set<string> CurrentOppId) {
        List<opportunity> lstOpportunity = new List<opportunity>();
        
        List<opportunity> lstOpportunityold = [SELECT Id, Tracking_Number__c,(Select Id,zkmulti__Tracking_Number__c from Shipments__r where zkmulti__Tracking_Number__c != null)  FROM Opportunity where Id IN : CurrentOppId];
        
        Boolean isFirst = true;
        if(lstOpportunityold != null && lstOpportunityold.size()>0){
            for(Opportunity ObjOpp : lstOpportunityold) {
                ObjOpp.Tracking_Number__c = '';                
                for (zkmulti__MCShipment__c mcshpment : ObjOpp.Shipments__r){                    
                    if(isFirst) {
                        ObjOpp.Tracking_Number__c += mcshpment.zkmulti__Tracking_Number__c;
                        isFirst = false;
                    }
                    else {
                        ObjOpp.Tracking_Number__c += ',' + mcshpment.zkmulti__Tracking_Number__c; 
                    }                    
                }
                lstOpportunity.add(ObjOpp);
                
            }
            if(lstOpportunity.size() > 0) {
                update lstOpportunity;
            }
        }
    }
}
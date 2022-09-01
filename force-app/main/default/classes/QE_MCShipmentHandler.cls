public class QE_MCShipmentHandler {
    
    // After Insert
    public void OnAfterInsert(){
        List<zkmulti__MCShipment__c > lstMcShipment = (List<zkmulti__MCShipment__c >) trigger.new;
        map<Id,zkmulti__MCShipment__c > mapOldshipment = (map<Id,zkmulti__MCShipment__c >) trigger.oldMap;
        set<string> CurrentOppId = new set<string>();
        
        for(zkmulti__MCShipment__c objshipmnt : lstMcShipment) {
           CurrentOppId.add(objshipmnt.Opportunity__c);
        }
        if(CurrentOppId.size() > 0){
            QE_MCShipmentHelper.updateTrackingNumber(CurrentOppId);
        }
    }
    // After Update
     public void OnAfterUpdate(){
        List<zkmulti__MCShipment__c > lstMcShipment = (List<zkmulti__MCShipment__c >) trigger.new;
        map<Id,zkmulti__MCShipment__c > mapOldshipment = (map<Id,zkmulti__MCShipment__c >) trigger.oldMap;
        set<string> CurrentOppId = new set<string>();
        
        for(zkmulti__MCShipment__c objshipmnt : lstMcShipment) {
            if(mapOldshipment == null || mapOldshipment.get(objshipmnt.id).Opportunity__c != objshipmnt.Opportunity__c || 
               mapOldshipment.get(objshipmnt.id).zkmulti__Tracking_Number__c  != objshipmnt.zkmulti__Tracking_Number__c){
                   CurrentOppId.add(objshipmnt.Opportunity__c);
               }
        }
        if(CurrentOppId.size() > 0){
            QE_MCShipmentHelper.updateTrackingNumber(CurrentOppId);
        }
    }
    // After delete
    public void OnAfterDelete(List<zkmulti__MCShipment__c> oldList) {
        // Capture Deleted Opporunitites
        List<QE_Deleted_Record__c> recordsBeingDeleted = new List<QE_Deleted_Record__c>();
        for (zkmulti__MCShipment__c mcShipment : oldList) {
            QE_Deleted_Record__c deletedRecord = new QE_Deleted_Record__c();
            deletedRecord.Name = mcShipment.Name;
            deletedRecord.DeletedId__c = mcShipment.Id;
            recordsBeingDeleted.add(deletedRecord);
        }
        try {
            insert recordsBeingDeleted;
        } catch (Exception e) {
            System.debug('Exception: '+e);
        }
        
        //Update Tracking Numbers on Opportunity after Shipment delete.
        List<zkmulti__MCShipment__c > lstMcShipment = (List<zkmulti__MCShipment__c >) trigger.old;
        map<Id,zkmulti__MCShipment__c > mapOldshipment = (map<Id,zkmulti__MCShipment__c >) trigger.oldMap;
        
        set<string> CurrentOppId = new set<string>();
        
        for(zkmulti__MCShipment__c objshipmnt : lstMcShipment) {
            CurrentOppId.add(objshipmnt.Opportunity__c);
        }
        if(CurrentOppId.size() > 0){
            QE_MCShipmentHelper.deleteTrackingNumber(CurrentOppId);
        }
       
    }
}
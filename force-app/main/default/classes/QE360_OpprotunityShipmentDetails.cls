public class QE360_OpprotunityShipmentDetails {

    @AuraEnabled
    public static List<zkmulti__MCShipment__c> lstShipmentDetail {get;set;}
    
    @AuraEnabled
    public static String getShipmentRecords (String OppId) {
        
        lstShipmentDetail = new List<zkmulti__MCShipment__c>();
        
        for(zkmulti__MCShipment__c mcShipment : [SELECT Name,Opportunity__c, Id, zkmulti__Tracking_Number__c FROM zkmulti__MCShipment__c where Opportunity__c =: OppId]) {
            
            lstShipmentDetail.add(mcShipment);
        }
        String ShipmentDetail = Json.serialize(lstShipmentDetail);
        return ShipmentDetail;
        
        //return lstShipmentDetail;
    }
}
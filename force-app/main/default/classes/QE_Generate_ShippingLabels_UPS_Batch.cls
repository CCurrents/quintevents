public class QE_Generate_ShippingLabels_UPS_Batch implements Database.Batchable<Reports.ReportDetailRow>,Database.AllowsCallouts, Database.Stateful{
    public Map<String,Integer> columnIndexByColumnName;
    Public zkmulti__MCShipmate_Preference__c shipmatePreference;
    public List<Reports.ReportDetailRow> reportRowDetails;
    public zkmulti__MCBulk_Shipment__c bulkShipment;
    
    public QE_Generate_ShippingLabels_UPS_Batch(List<Reports.ReportDetailRow> reportRowDetail, zkmulti__MCShipmate_Preference__c shipmatePrefer,Map<String,Integer> colIndexByColumnName,zkmulti__MCBulk_Shipment__c bulkShip){
        this.reportRowDetails = reportRowDetail;        
        this.shipmatePreference = shipmatePrefer;        
        this.columnIndexByColumnName = colIndexByColumnName;
        this.bulkShipment = bulkShip;
    }
    public Iterable<Reports.ReportDetailRow> start(Database.BatchableContext BC){
        return reportRowDetails;
    }
    public void execute(Database.BatchableContext BC, List<Reports.ReportDetailRow> scope){
        
        QE_GenerateShippingLabels_UPS.ProcessShippingLabels(scope, columnIndexByColumnName, shipmatePreference, bulkShipment);
    }
    public void finish(Database.BatchableContext BC){// Process Bulk Shipment
            String bulkShipmentBatchId = 'testbatchid';
            if(Test.isRunningTest()) {
                bulkShipmentBatchId = 'testbatchid';
            } else {
                bulkShipmentBatchId = zkmulti.BulkShipmentInterface.asynchronousProcessBulkShipment(bulkShipment.Id);   
                System.debug('bulkShipmentBatchId: '+bulkShipmentBatchId);
            }            
            
            // Process started for this bulk shipment
            if(bulkShipmentBatchId != null) {
                bulkShipment.Processed__c = true;
                update bulkShipment;
            }
    }
    
}
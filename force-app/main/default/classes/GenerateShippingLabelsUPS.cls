/**
* @File Name          : GenerateShippingLabelsUPS.cls
* @Description        : This class is used to generate shipping lables for UPS shipping. This is reference to QE360V3_GenerateShippingLabels_UPS lightning component
* @Author             : kchavda@addonblue.com

* @Last Modified By   : fsuraitawala@addonblue.com
* @Last Modified On   : 03-07-2022
* @Modification Log   : 
* Ver       Date            Author               Modification
* 1.0       02/13/2020      kchavda              Initial Version
* 1.1       12/30/2020      kchavda              #676 New Shipment Preference for UK, Need a report functionality similar to existing one but specific to UK UPS account.
* 1.2       02/02/2022      VKHOPADE             #1149 for enabling FedEx intenational shipment
**/
public class GenerateShippingLabelsUPS{     
     
    
    /**
    * @description  : To get Report Id for Shipping Labels from Custom Settings
    * @author       : kchavda@addonblue.com
    * @param        : String 
    * @return       : string 
    **/
     @AuraEnabled
     public static string  toGetReportId(String bulkShipmentId) {
         // To get bul shipment record
         zkmulti__MCBulk_Shipment__c  bulkShipment  = new zkmulti__MCBulk_Shipment__c();    
         bulkShipment  = toGetBulkshipment(bulkShipmentId);
        // Get custom settings          
        string masterspreadReportId = '';
        ZK_Print_Labels_Settings__c printLabelsSetings = ZK_Print_Labels_Settings__c.getOrgDefaults();
        if(bulkShipment != null && bulkShipment.zkmulti__Shipmate_Preference__r.zkmulti__Shipping_Country__c == 'GB') masterspreadReportId = printLabelsSetings.Masterspread_UK_Report_Id__c;
        else masterspreadReportId = printLabelsSetings.Masterspread_Report_Id__c;       
        
        return masterspreadReportId;
     }
     
     
     /**
    * @description  : To get bulkshipment Id from Bulkshipment record view page
    * @author       : kchavda@addonblue.com
    * @param        : String (Buklshipment Id)
    * @return       : zkmulti__MCBulk_Shipment__c   
    **/
     @AuraEnabled
     public static zkmulti__MCBulk_Shipment__c  toGetBulkshipment(String bulkShipmentId) {        
        // Query bulk shipment  
        zkmulti__MCBulk_Shipment__c  bulkShipment  = new zkmulti__MCBulk_Shipment__c();     
        if(bulkShipmentId != null) {
            bulkShipment = [Select Id, PriceBook__c, PriceBook__r.Name, Weight__c, Signature_Required__c, Package_Type__c, Service_Type__c, zkmulti__Shipmate_Preference__c, Processed__c,zkmulti__Shipmate_Preference__r.zkmulti__Shipping_Country__c, Ship_Date__c From zkmulti__MCBulk_Shipment__c Where Id = :bulkShipmentId];
        }
        return bulkShipment;
     }

    
     //Generate Shipping Lables
     /**
    * @description  : To generate Shipping Labels on button click from Bulkshipment record view page
    * @author       : kchavda@addonblue.com
    * @param        : zkmulti__MCBulk_Shipment__c (Buklshipment), string (report Id)
    * @return       : string   
    **/
     @AuraEnabled
     public static string generateShippingLabels(zkmulti__MCBulk_Shipment__c bulkShipment,String masterspreadReportId) {
         string popupMessage;
         
        // If bulk shipment is allreay processed, skip the process and display message.
        if(bulkShipment.Processed__c) {
            popupMessage = 'This Bulk Shipment record has already been processed.';            
        }
        else{
             List<AsyncApexJob> asyncApexJobs = new List<AsyncApexJob>([Select id from AsyncApexJob where JobType = 'BatchApex' and 
             ApexClass.Name = 'BatchGenerateShippingLabelsUPS' and Status != 'Completed' and status != 'Aborted' and status != 'Failed']);
             if(!asyncApexJobs.isEmpty()){
                 popupMessage = 'This Bulk Shipment is in process, please wait for sometime.';
                 return popupMessage;
             }
            
            
            // Get shipmate preference
            zkmulti__MCShipmate_Preference__c shipmatePreference = [
            SELECT Id, Name, zkmulti__Carrier__c, zkmulti__Label_Image_Type_Default__c, zkmulti__Billing_City__c,
            zkmulti__Billing_Country__c, zkmulti__Billing_State__c, zkmulti__Billing_Street__c, 
            zkmulti__Billing_Zip_Postal_Code__c, zkmulti__Company_Name__c, zkmulti__Sender_Email_Default__c,
            zkmulti__Sender_Name_Default__c, zkmulti__Sender_Phone_Default__c, zkmulti__Shipping_City__c, 
            zkmulti__Shipping_Country__c, zkmulti__Shipping_Is_Residential__c, zkmulti__Shipping_State__c, 
            zkmulti__Shipping_Street__c, zkmulti__Shipping_Zip_Postal_Code__c, zkmulti__Currency_Default__c,
            zkmulti__AccountNumber__c FROM zkmulti__MCShipmate_Preference__c
            WHERE Id = :bulkShipment.zkmulti__Shipmate_Preference__c
            ];
            
            // Get the report metadata
            try{
                Map<String,Map<String,String>> shippingStateCodeByState = new Map<String,Map<String,String>>();
                Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(masterspreadReportId);
                Reports.ReportMetadata reportMetadata = describe.getReportMetadata();
                
                // Get exisiting columns
                List<String> existingColumns = reportMetadata.getDetailColumns();
                // New columns to be added
                List<String> columnNamesToBeAded = new List<String> {'ORDER_ID', 'ACCOUNT_NAME', 'ORDER_SHIPPING_FIRST_NAME','ORDER_SHIPPING_LAST_NAME',
                    'ORDER_SHIPPING_STREET', 'ORDER_SHIPPING_CITY', 'ORDER_SHIPPING_STATE_CODE','ORDER_TOTAL_AMOUNT.CONVERT',
                    'ORDER_SHIPPING_ZIP', 'ORDER_SHIPPING_COUNTRY_CODE', 'ORDER_SHIPPING_EMAIL',
                    'ORDER_SHIPPING_PHONE', 'Order.Pick_Up_Requested__c', 'Order.Order_Payment_Status__c', 'OrderItem.Record_Type__c',
                    'Product2.Commodity_Weight__c','Product2.Commodity_Harmonized_Code__c','Product2.Commodity_Unit_Price__c','Product2.Commodity_Description__c'           
                    };
                    
                // Add new columns
                for(String newColumnName : columnNamesToBeAded) {
                    // add only if it don't exist.
                    if(!existingColumns.contains(newColumnName)) {
                        existingColumns.add(newColumnName);
                    }
                }
                
                // Add column names to metadata
                reportMetadata.setDetailColumns(existingColumns);
                // Create map of column index by column name
                Map<String,Integer> columnIndexByColumnName = new Map<String,Integer>();
                Integer columnIndexCounter = 0;
                for(String columnName : reportMetadata.getDetailColumns()) {
                    System.debug('Column '+columnIndexCounter+': '+columnName);
                    columnIndexByColumnName.put(columnName,columnIndexCounter);
                    columnIndexCounter++;
                }
                System.debug('columnIndexByColumnName: '+columnIndexByColumnName);
                
                // Get current filters
                List<Reports.ReportFilter> reportFilters = reportMetadata.getReportFilters();
                Integer numberOfExistingFilters = reportFilters.size();
                System.debug('reportFilters: '+reportFilters + ' > '+reportFilters.size());
                // Add extra filters
                // Note: In Apex tests, report runs always ignore the SeeAllData annotation, regardless of whether the annotation is set to true or false. 
                // This means that report results will include pre-existing data that the test didn’t create.
                
                if(bulkShipment != null && bulkShipment.PriceBook__c != null && (shipmatePreference.zkmulti__Carrier__c.equals('UPS') || shipmatePreference.zkmulti__Carrier__c.equals('FedEx') || shipmatePreference.zkmulti__Carrier__c.equals('DHL Express')) && !Test.IsrunningTest()) { //VKHOPADE - issue 1149 - added for FedEx
                    reportFilters.add(new Reports.ReportFilter('Order.Event_15_digit_Id__c', 'equals', String.valueOf(bulkShipment.PriceBook__c).substring(0, 15)));
                    reportFilters.add(new Reports.ReportFilter('Order.Pick_Up_Requested__c', 'equals', 'False'));                    
                }
                
                system.debug('reportFilters Updated: ' + reportFilters+ ' > '+reportFilters.size());
                
                
                zkmulti__MCShipmentInfo__c shipInfo = new zkmulti__MCShipmentInfo__c();
                if(shipmatePreference.zkmulti__Carrier__c.equals('UPS') || shipmatePreference.zkmulti__Carrier__c.equals('FedEx')) { //VKHOPADE - issue 1149 - added for FedEx
                    // Shipment Info
                    shipInfo = new zkmulti__MCShipmentInfo__c(
                        zkmulti__Contents_Type__c = 'NON_DOCUMENTS',// NON_DOCUMENTS OR DOCUMENTS_ONLY
                        zkmulti__DutiesPaymentType__c = 'SENDER', 
                        // set duties
                        zkmulti__DutiesPayorAccount__c = shipmatePreference.zkmulti__AccountNumber__c, // intl info 
                        zkmulti__DutiesPayorAccountCountry__c = shipmatePreference.zkmulti__Billing_Country__c, // intl info
                        zkmulti__TotalCustomsValue__c = 10.0
                    );
                    
                    Utility.processRecords(shipInfo, 'insert');            
                }
                else if(shipmatePreference.zkmulti__Carrier__c.equals('DHL Express')){ //VKHOPADE - #1177
                    shipInfo = new zkmulti__MCShipmentInfo__c(
                        zkmulti__Contents_Type__c = 'NON_DOCUMENTS',// NON_DOCUMENTS OR DOCUMENTS_ONLY
                        zkmulti__DutiesPaymentType__c = 'shipper', 
                        // set duties
                        zkmulti__DutiesPayorAccount__c = shipmatePreference.zkmulti__AccountNumber__c, // intl info 
                        zkmulti__DutiesPayorAccountCountry__c = shipmatePreference.zkmulti__Billing_Country__c, // intl info
                        zkmulti__TotalCustomsValue__c = 10.0
                    );
                    
                    Utility.processRecords(shipInfo, 'insert');   
                }
                
                	
                // Add filter to report metadata
                reportMetadata.setReportFilters(reportFilters);
                
                
                // Get logical filters 
                String existingLogicalFilters = reportMetadata.getReportBooleanFilter();
                System.debug('existingLogicalFilters: '+existingLogicalFilters);
                
                // Add logical filters for new reportFilters
                System.debug('numberOfExistingFilters: '+numberOfExistingFilters);
                System.debug('numberTotalFilters: '+reportFilters.size());
                
                // Only add new logic filters if logical filters already existed in report
                if(existingLogicalFilters != null) {
                    existingLogicalFilters = '(' + existingLogicalFilters + ')';
                    for(Integer i = numberOfExistingFilters; i < reportFilters.size(); i++) {
                        System.debug('I > :'+i);
                        existingLogicalFilters += ' AND '+ (i+1);
                    }
                }
                
                System.debug('existingLogicalFilters updated: '+existingLogicalFilters);
                
                // Set logical filters 
                reportMetadata.setReportBooleanFilter(existingLogicalFilters);
               
                // Run report
                Reports.ReportResults results = Reports.ReportManager.runReport(masterspreadReportId, reportMetadata, true);
                
                // Get the fact map from the report results
                String factMapKey = 'T!T';
                Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get(factMapKey);                              
                             
                if(!Test.IsrunningTest()){
                    BatchGenerateShippingLabelsUPS batch = new BatchGenerateShippingLabelsUPS(factDetails.getRows(), shipmatePreference, columnIndexByColumnName,bulkShipment,shipInfo);
                    String bId = Database.executeBatch(batch,10);
                }                
                else{
                    BatchGenerateShippingLabelsUPS batch = new BatchGenerateShippingLabelsUPS(new list<reports.ReportDetailRow>{factDetails.getRows()[0]}, shipmatePreference, columnIndexByColumnName,bulkShipment,shipInfo);
                    String bId = Database.executeBatch(batch);                    
                }
                
                popupMessage = 'Process for generating shipping lables has been started, '+
                'You will receieve an email when process is complete.';
            }
            catch(exception ex){
                system.debug('Exception-'+ex.getLineNumber() +'--' + ex.getMessage());
                Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
                popupMessage = 'Exception-'+ex.getLineNumber() +'--' + ex.getMessage();
            }
            
        }
        
        return popupMessage;
    }
}
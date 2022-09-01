public class QE_GenerateShippingLabels {
    
    String masterspreadReportId = '';
    public String popupMessage {get; set;}
    public Map<String,String> shippingStateCodeByState{get; set;}
    zkmulti__MCBulk_Shipment__c bulkShipment;
    
    // Constructor
    public QE_GenerateShippingLabels(){
        // Get custom settings
        ZK_Print_Labels_Settings__c printLabelsSetings = ZK_Print_Labels_Settings__c.getOrgDefaults();
        masterspreadReportId = printLabelsSetings.Masterspread_Report_Id__c;
        // Query bulk shipment
        String bulkShipmentId = ApexPages.currentPage().getParameters().get('bulkshipmentid');
        if(bulkShipmentId != null) {
            bulkShipment = [
                Select Id, Event__c, Event__r.Name, Weight__c, Package_Type__c, Service_Type__c, zkmulti__Shipmate_Preference__c, Processed__c
                From zkmulti__MCBulk_Shipment__c
                Where Id = :bulkShipmentId
            ];
        }
        shippingStateCodeByState = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = User.statecode.getDescribe();
        List<Schema.PicklistEntry> enabledStateValue = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickVal : enabledStateValue){
            shippingStateCodeByState.put(pickVal.getLabel(), pickVal.getValue());
            System.debug('State Name: '+pickVal.getLabel()+' State Code:'+pickVal.getValue());
        }
    }
    
    // Generate Shipping Lables
    public PageReference generateShippingLabels() {
        // If bulk shipment is allreay processed, skip the process and display message.
        if(bulkShipment.Processed__c) {
            popupMessage = 'This Bulk Shipment record has already been processed.';
            return null;
        }
        // Get shipmate preference
        zkmulti__MCShipmate_Preference__c shipmatePreference = [
            SELECT Id, Name, zkmulti__Carrier__c, zkmulti__Label_Image_Type_Default__c, zkmulti__Billing_City__c,
            zkmulti__Billing_Country__c, zkmulti__Billing_State__c, zkmulti__Billing_Street__c, 
            zkmulti__Billing_Zip_Postal_Code__c, zkmulti__Company_Name__c, zkmulti__Sender_Email_Default__c,
            zkmulti__Sender_Name_Default__c, zkmulti__Sender_Phone_Default__c, zkmulti__Shipping_City__c, 
            zkmulti__Shipping_Country__c, zkmulti__Shipping_Is_Residential__c, zkmulti__Shipping_State__c, 
            zkmulti__Shipping_Street__c, zkmulti__Shipping_Zip_Postal_Code__c, zkmulti__Currency_Default__c,
            zkmulti__AccountNumber__c
            FROM zkmulti__MCShipmate_Preference__c
            WHERE Id = :bulkShipment.zkmulti__Shipmate_Preference__c
        ];
        // Get the report metadata
        Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(masterspreadReportId);
        Reports.ReportMetadata reportMetadata = describe.getReportMetadata();
        // Get exisiting columns
        List<String> existingColumns = reportMetadata.getDetailColumns();
        // New columns to be added
        List<String> columnNamesToBeAded = new List<String> {'OPPORTUNITY_ID', 'ACCOUNT_NAME', 'Opportunity.Ship_To_Name__c',
            'Opportunity.Shipping_Street__c', 'Opportunity.Shipping_City__c', 'Opportunity.Shipping_State_Province__c',
            'Opportunity.Shipping_Zip_Postal_Code__c', 'Opportunity.Shipping_Country__c', 'Opportunity.Email__c',
            'Opportunity.Phone__c', 'Opportunity.Pick_Up_Confirmed__c', 'Opportunity.Shipping_Outside_US__c', 'Opportunity.Paid_in_Full__c', 'OpportunityLineItem.Record_Type__c',
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
        if(!Test.isRunningTest()) {
            // If Fedex
            if(shipmatePreference.zkmulti__Carrier__c.equals('FedEx')) {
                reportFilters.add(new Reports.ReportFilter('Opportunity.Event_Id_15_Char__c', 'equals', String.valueOf(bulkShipment.Event__c).substring(0, 15)));
                reportFilters.add(new Reports.ReportFilter('Opportunity.Pick_Up_Confirmed__c', 'equals', 'False'));
                reportFilters.add(new Reports.ReportFilter('Opportunity.Shipping_Outside_US__c', 'notEqual', 'Yes'));
            }
            
            // If UPS
            if(shipmatePreference.zkmulti__Carrier__c.equals('UPS')) {
                reportFilters.add(new Reports.ReportFilter('Opportunity.Event_Id_15_Char__c', 'equals', String.valueOf(bulkShipment.Event__c).substring(0, 15)));
                reportFilters.add(new Reports.ReportFilter('Opportunity.Pick_Up_Confirmed__c', 'equals', 'False'));
                reportFilters.add(new Reports.ReportFilter('Opportunity.Shipping_Outside_US__c', 'notEqual', 'No'));
            }
            
            
        }
        system.debug('reportFilters Updated: ' + reportFilters+ ' > '+reportFilters.size());
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
        system.debug('results...' + results);
        // Get the fact map from the report results
        String factMapKey = 'T!T';
        Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get(factMapKey);
        // Process report result
        // Report type is Opportunities with Products, so it will have multiple rows for products for same opportunity.
        // Create map to get only one product row for each opportunity as all product rows will have opportunity data.
        Map<Id,Reports.ReportDetailRow> mapOfRowsByOpportunityId = new Map<Id,Reports.ReportDetailRow>();
        Map<Id,List<Reports.ReportDetailRow>> mapOfRowsByOppLineItem = new Map<Id,List<Reports.ReportDetailRow>>();        
        system.debug('factDetails.getRows()...' + factDetails.getRows());
        Map<string,Map<string,string>> mapOppLineItemsforCustomItems = New Map<string,Map<string,string>>();
        Integer countCI = 0; 
        For(Reports.ReportDetailRow row : factDetails.getRows()){
            System.debug('Row: '+row.getDataCells()[columnIndexByColumnName.get('OPPORTUNITY_ID')].getLabel());
            mapOfRowsByOpportunityId.put(row.getDataCells()[columnIndexByColumnName.get('OPPORTUNITY_ID')].getLabel(),row);            
            if(row.getDataCells()[columnIndexByColumnName.get('OpportunityLineItem.Record_Type__c')].getLabel() == 'Package'){
                if(!mapOfRowsByOppLineItem.containskey(row.getDataCells()[columnIndexByColumnName.get('OPPORTUNITY_ID')].getLabel())){
                    mapOfRowsByOppLineItem.put(row.getDataCells()[columnIndexByColumnName.get('OPPORTUNITY_ID')].getLabel(),new List<Reports.ReportDetailRow>{row});
                }else{
                    mapOfRowsByOppLineItem.get(row.getDataCells()[columnIndexByColumnName.get('OPPORTUNITY_ID')].getLabel()).add(row);
                }
            }
            if(shipmatePreference.zkmulti__Carrier__c.equals('UPS')) {
                //For Custom Items      
                if(row.getDataCells()[columnIndexByColumnName.get('Product2.Commodity_Harmonized_Code__c')].getLabel() != '-' && row.getDataCells()[columnIndexByColumnName.get('Product2.Commodity_Harmonized_Code__c')].getLabel() != null && row.getDataCells()[columnIndexByColumnName.get('Product2.Commodity_Harmonized_Code__c')].getLabel() != ''){                          
                    mapOppLineItemsforCustomItems.put(countCI+'###'+row.getDataCells()[columnIndexByColumnName.get('OPPORTUNITY_ID')].getLabel(),new Map<string,string>{'Weight'=>row.getDataCells()[columnIndexByColumnName.get('Product2.Commodity_Weight__c')].getLabel(),'Harmonized Code'=>row.getDataCells()[columnIndexByColumnName.get('Product2.Commodity_Harmonized_Code__c')].getLabel(),'Unit Price'=>row.getDataCells()[columnIndexByColumnName.get('Product2.Commodity_Unit_Price__c')].getLabel(),'Description'=>row.getDataCells()[columnIndexByColumnName.get('Product2.Commodity_Description__c')].getLabel(),'Quantity'=>row.getDataCells()[columnIndexByColumnName.get('QUANTITY')].getLabel()});
                    countCI++; 
                }
            }         
        }
        
        System.debug('mapOfRowsByOpportunityId.values(): '+mapOfRowsByOpportunityId.values());
        
        
        // If UPS Added on 11-13-2018
        zkmulti__MCShipmentInfo__c shipInfo = new zkmulti__MCShipmentInfo__c();
        if(shipmatePreference.zkmulti__Carrier__c.equals('UPS')) {
            // Shipment Info
            shipInfo = new zkmulti__MCShipmentInfo__c(
                zkmulti__Contents_Type__c = 'NON_DOCUMENTS',// NON_DOCUMENTS OR DOCUMENTS_ONLY
                zkmulti__DutiesPaymentType__c = 'SENDER', 
                // set duties
                zkmulti__DutiesPayorAccount__c = shipmatePreference.zkmulti__AccountNumber__c, // intl info 
                zkmulti__DutiesPayorAccountCountry__c = shipmatePreference.zkmulti__Billing_Country__c, // intl info
                zkmulti__TotalCustomsValue__c = 10.0
            );
            
            Insert shipInfo;
        }
        
        // Create Queued Shipments
        List<zkmulti__MCShipment__c> mcShipmentsToInsert = new List<zkmulti__MCShipment__c>();               
        For(Reports.ReportDetailRow row : mapOfRowsByOpportunityId.values()){        
            // Queued Shipment
            zkmulti__MCShipment__c mcShipment = new zkmulti__MCShipment__c();
            // Carrier
            mcShipment.zkmulti__Bulk_Shipment__c = bulkShipment.Id;
            mcShipment.zkmulti__Carrier__c = shipmatePreference.zkmulti__Carrier__c;
            mcShipment.zkmulti__Shipmate_Preference__c = shipmatePreference.Id;
            mcShipment.zkmulti__Currency__c = 'USD'; // ASK, shoud it be same as oppt?            
            mcShipment.zkmulti__Shipment_Type__c = 'Outbound';
            mcShipment.zkmulti__DropoffType__c = 'DROP_BOX';            
            mcShipment.zkmulti__Billing_Account_Number__c = shipmatePreference.zkmulti__AccountNumber__c;
            mcShipment.zkmulti__Billing_Country__c = shipmatePreference.zkmulti__Billing_Country__c;            
            mcShipment.zkmulti__Label_Image_Type__c = shipmatePreference.zkmulti__Label_Image_Type_Default__c; // This may need to change.
            mcShipment.zkmulti__Dimension_Units__c = 'IN'; // ASK            
            // If UPS
            if(shipmatePreference.zkmulti__Carrier__c.equals('UPS')) {
                 mcShipment.zkmulti__Weight_Units__c = 'LBS'; // ASK  
            }else{
                mcShipment.zkmulti__Weight_Units__c = 'LB'; // ASK  
            }         
           
            // If Fedex
            if(shipmatePreference.zkmulti__Carrier__c.equals('FedEx')) {
                //mcShipment.zkmulti__Service_Type__c = 'FEDEX_GROUND';
                //mcShipment.zkmulti__Package_Type__c = 'YOUR_PACKAGING';                
                system.debug('###bulkShipment.Service_Type__c=='+bulkShipment.Service_Type__c);
                
                //Added on 10/31/2018
                if(bulkShipment.Event__c != null){
                    mcShipment.zkmulti__Reference1_Value__c = bulkShipment.Event__r.Name.length() >40 ? bulkShipment.Event__r.Name.substring(0,40) : bulkShipment.Event__r.Name;
                }
                mcShipment.Weight__c = bulkShipment.Weight__c;
                mcShipment.zkmulti__Service_Type__c = bulkShipment.Service_Type__c;
                mcShipment.zkmulti__Package_Type__c = bulkShipment.Package_Type__c;
            }
            // If DHLExpress
            if(shipmatePreference.zkmulti__Carrier__c.equals('DHLExpress')) {
                mcShipment.zkmulti__Service_Type__c = 'Express1030NonDoc';
                mcShipment.zkmulti__Package_Type__c = 'JumboParcel';
                mcShipment.zkmulti__Package_Type__c = 'OtherDHLPackaging';
            }
            
            // If UPS
            if(shipmatePreference.zkmulti__Carrier__c.equals('UPS')) {
                mcShipment.zkmulti__ShipmentDescription__c = 'None';
                mcShipment.zkmulti__Shipment_Info__c = shipInfo.Id;  
                mcShipment.zkmulti__Service_Type__c = 'UPS_STANDARD';
                mcShipment.zkmulti__Package_Type__c = 'UPS_YOUR_PACKAGING';                                                          
            }
             
            
            // Sender info
            mcShipment.zkmulti__Payment_Type__c = 'SENDER';
            mcShipment.zkmulti__Sender_Name__c = shipmatePreference.zkmulti__Sender_Name_Default__c;
            mcShipment.zkmulti__Sender_Address_is_Residential__c = false; // ASK
            mcShipment.zkmulti__Sender_City__c = shipmatePreference.zkmulti__Shipping_City__c;
            mcShipment.zkmulti__Sender_Company__c = shipmatePreference.zkmulti__Company_Name__c;
            mcShipment.zkmulti__Sender_Country__c = shipmatePreference.zkmulti__Shipping_Country__c;
            mcShipment.zkmulti__Sender_Email__c = shipmatePreference.zkmulti__Sender_Email_Default__c;
            mcShipment.zkmulti__Sender_Phone__c = shipmatePreference.zkmulti__Sender_Phone_Default__c;
            mcShipment.zkmulti__Sender_State_Province__c = shipmatePreference.zkmulti__Shipping_State__c;
            mcShipment.zkmulti__Sender_Street__c = shipmatePreference.zkmulti__Shipping_Street__c;
            mcShipment.zkmulti__Sender_Zip_Postal_Code__c = shipmatePreference.zkmulti__Shipping_Zip_Postal_Code__c;
            mcShipment.zkmulti__Ship_Date__c = Date.today();
            // Recipient info
            //mcShipment.zkmulti__Recipient_Opportunity__c = row.getDataCells()[columnIndexByColumnName.get('OPPORTUNITY_ID')].getLabel(); // Default opportunity lookup which comes with the zenkraft package
            mcShipment.Opportunity__c = row.getDataCells()[columnIndexByColumnName.get('OPPORTUNITY_ID')].getLabel(); // Custom opportunity package to make everything work with custom opportunity address
            mcShipment.zkmulti__Recipient_Address_is_Residential__c = false;
            mcShipment.zkmulti__Recipient_Company__c = row.getDataCells()[columnIndexByColumnName.get('Opportunity.Ship_To_Name__c')].getLabel(); // ASK, shoud this be company for bussness oppt?
            mcShipment.zkmulti__Recipient_Street__c = row.getDataCells()[columnIndexByColumnName.get('Opportunity.Shipping_Street__c')].getLabel();
            mcShipment.zkmulti__Recipient_City__c = row.getDataCells()[columnIndexByColumnName.get('Opportunity.Shipping_City__c')].getLabel();
            String opportunityState = row.getDataCells()[columnIndexByColumnName.get('Opportunity.Shipping_State_Province__c')].getLabel();
            System.debug('opportunityState: '+opportunityState);
            System.debug('opportunityState code: '+shippingStateCodeByState.get(opportunityState));
            mcShipment.zkmulti__Recipient_State_Province__c = shippingStateCodeByState.get(opportunityState);
            mcShipment.zkmulti__Recipient_Zip_Postal_Code__c = row.getDataCells()[columnIndexByColumnName.get('Opportunity.Shipping_Zip_Postal_Code__c')].getLabel();    
            mcShipment.zkmulti__Recipient_Country__c = row.getDataCells()[columnIndexByColumnName.get('Opportunity.Shipping_Country__c')].getLabel();
            mcShipment.zkmulti__Recipient_Email__c = row.getDataCells()[columnIndexByColumnName.get('Opportunity.Email__c')].getLabel();
            mcShipment.zkmulti__Recipient_Name__c = row.getDataCells()[columnIndexByColumnName.get('Opportunity.Ship_To_Name__c')].getLabel();
            mcShipment.zkmulti__Recipient_Phone__c = row.getDataCells()[columnIndexByColumnName.get('Opportunity.Phone__c')].getLabel();
            
            
            // Other
            mcShipment.Event__c = bulkShipment.Event__c;
            
                        
            // Add to list
            
            // Updated on 10/31/2018
            system.debug('###Country=='+row.getDataCells()[columnIndexByColumnName.get('Opportunity.Shipping_Country__c')].getLabel());
            system.debug('###Paid in Full =='+row.getDataCells()[columnIndexByColumnName.get('Opportunity.Paid_in_Full__c')].getLabel());
            system.debug('###OpportunityLineItem =='+row.getDataCells()[columnIndexByColumnName.get('OpportunityLineItem.Record_Type__c')].getLabel());
            
            if(shipmatePreference.zkmulti__Carrier__c.equals('FedEx')){
                if((row.getDataCells()[columnIndexByColumnName.get('Opportunity.Shipping_Country__c')].getLabel() == 'US' || row.getDataCells()[columnIndexByColumnName.get('Opportunity.Shipping_Country__c')].getLabel() == 'USA' 
                    || row.getDataCells()[columnIndexByColumnName.get('Opportunity.Shipping_Country__c')].getLabel() == 'United States of America')
                    && row.getDataCells()[columnIndexByColumnName.get('Opportunity.Paid_in_Full__c')].getLabel() == 'true' && mapOfRowsByOppLineItem.containskey(row.getDataCells()[columnIndexByColumnName.get('OPPORTUNITY_ID')].getLabel()) 
                    && mapOfRowsByOppLineItem.get(row.getDataCells()[columnIndexByColumnName.get('OPPORTUNITY_ID')].getLabel()) != null && mapOfRowsByOppLineItem.get(row.getDataCells()[columnIndexByColumnName.get('OPPORTUNITY_ID')].getLabel()).size()>0){
                    mcShipmentsToInsert.add(mcShipment);
                }
            }else{
                mcShipmentsToInsert.add(mcShipment);
            }
        }
                
       
        if(mcShipmentsToInsert.size()>0){
            insert mcShipmentsToInsert;
        }
        System.debug('mcShipmentsToInsert: '+mcShipmentsToInsert);
        
        
        
        List<zkmulti__MCShipment_Special_Services__c> mcSpecialServiceToInsert = new List<zkmulti__MCShipment_Special_Services__c>();         
        for (zkmulti__MCShipment__c mcShipment : mcShipmentsToInsert) {
            // Create Shipment Special Services
            if(mcShipment.zkmulti__Carrier__c == 'FedEx'){
                zkmulti__MCShipment_Special_Services__c shipmentSS  = new zkmulti__MCShipment_Special_Services__c (
                    zkmulti__Shipment__c = mcShipment.Id,
                    zkmulti__SelectedSignatureOption__c = 'DIRECT',
                    zkmulti__SignatureReleaseNumber__c = mcShipment.Opportunity__c
                );
                mcSpecialServiceToInsert.add(shipmentSS);
            }            
            
        }
        if(mcSpecialServiceToInsert.size()>0){
            insert mcSpecialServiceToInsert;
        }
        System.debug('mcSpecialServiceToInsert: '+mcSpecialServiceToInsert);        
        
        // Create Queued Packages
        List<zkmulti__MCPackage__c> mcPackagesToInsert = new List<zkmulti__MCPackage__c>();
        for (zkmulti__MCShipment__c mcShipment : mcShipmentsToInsert) {
            zkmulti__MCPackage__c mcPackage = new zkmulti__MCPackage__c (
                zkmulti__Height__c = 1, // ASK
                zkmulti__Length__c = 1, // ASK
                zkmulti__Width__c = 1, // ASK
                zkmulti__Weight__c = 1, // ASK
                zkmulti__Weight_Units__c = 'LB', // ASK
                zkmulti__Dimension_Units__c = 'IN', // ASK
                zkmulti__Packaging_Type__c = 'Parcel', // ASK
                zkmulti__DeclaredValue__c = 0,
                zkmulti__Shipment__c = mcShipment.Id // ASK
            );
            mcPackagesToInsert.add(mcPackage);
        }
        
        if(mcPackagesToInsert.size()>0){
            insert mcPackagesToInsert;
        }
        System.debug('mcPackagesToInsert: '+mcPackagesToInsert);
        System.debug('mapOppLineItemsforCustomItems: '+mapOppLineItemsforCustomItems);
        
        //For UPS
        List<zkmulti__MCCustoms_Item__c> customItemsToInsert = new List<zkmulti__MCCustoms_Item__c>();                
        Map<Integer,zkmulti__CommercialInvoice__c> mapCommercialInvoiceToInsert = new Map<Integer,zkmulti__CommercialInvoice__c>();
        Map<Integer,zkmulti__MCShipment__c> mapShipment = new Map<Integer,zkmulti__MCShipment__c>();
        Integer icount = 0;
        for (zkmulti__MCShipment__c qs : mcShipmentsToInsert) {
            if(qs.zkmulti__Carrier__c == 'UPS'){
                // Create Custom Items
                if(mapOppLineItemsforCustomItems.size()>0){
                    for(string count: mapOppLineItemsforCustomItems.keyset()){
                        System.debug('count: '+count);
                        if(count.split('###')[1] == qs.Opportunity__c){                        
                            zkmulti__MCCustoms_Item__c customItem = new zkmulti__MCCustoms_Item__c();
                            if(mapOppLineItemsforCustomItems.containskey(count) && mapOppLineItemsforCustomItems.get(count) != null){
                                customItem.zkmulti__Weight__c = mapOppLineItemsforCustomItems.get(count).get('Weight') != null && mapOppLineItemsforCustomItems.get(count).get('Weight') != '-' ? double.valueof(mapOppLineItemsforCustomItems.get(count).get('Weight')) : null;
                                customItem.zkmulti__Harmonized_Code__c = mapOppLineItemsforCustomItems.get(count).get('Harmonized Code') != null ? string.valueof(mapOppLineItemsforCustomItems.get(count).get('Harmonized Code')) : '';
                                customItem.zkmulti__Quantity__c = mapOppLineItemsforCustomItems.get(count).get('Quantity') != null && mapOppLineItemsforCustomItems.get(count).get('Quantity') != '-' ? double.valueof(mapOppLineItemsforCustomItems.get(count).get('Quantity')) : null;
                                customItem.zkmulti__Value__c = mapOppLineItemsforCustomItems.get(count).get('Unit Price') != null && mapOppLineItemsforCustomItems.get(count).get('Unit Price') != '-' ? double.valueof(mapOppLineItemsforCustomItems.get(count).get('Unit Price'))*double.valueof(mapOppLineItemsforCustomItems.get(count).get('Quantity')): null;
                                customItem.zkmulti__Description__c = mapOppLineItemsforCustomItems.get(count).get('Description') != null ? string.valueof(mapOppLineItemsforCustomItems.get(count).get('Description')) : '';
                                customItem.zkmulti__UnitPrice__c = mapOppLineItemsforCustomItems.get(count).get('Unit Price') != null && mapOppLineItemsforCustomItems.get(count).get('Unit Price') != '-' ? double.valueof(mapOppLineItemsforCustomItems.get(count).get('Unit Price')): null;
                            }
                            customItem.zkmulti__Weight_Units__c = 'LB';
                            customItem.zkmulti__Country_of_Manufacture__c = 'US';                
                            customItem.zkmulti__Value_Currency__c = 'USD';                  
                            customItem.zkmulti__Shipment__c = qs.Id;
                            customItem.zkmulti__Carrier__c = 'UPS';
                            customItem.zkmulti__UnitOfMeasurement__c = 'Each';                 
                            customItem.zkmulti__UnitPriceCurrency__c = 'USD';                
                            customItemsToInsert.add(customItem);
                        }
                   }  
                   
                   // Create Commercial Invoices
                    zkmulti__CommercialInvoice__c mcCommercialInvoice  = new zkmulti__CommercialInvoice__c();                
                    mcCommercialInvoice.zkmulti__InvoiceDate__c = System.today();               
                    mcCommercialInvoice.zkmulti__Carrier__c = 'UPS';
                    mcCommercialInvoice.zkmulti__OriginatorName__c = qs.zkmulti__Sender_Name__c;
                    mcCommercialInvoice.zkmulti__ReasonForExport__c = 'Sample';
                    mapCommercialInvoiceToInsert.put(icount,mcCommercialInvoice);
                    mapShipment.put(icount,qs);
                    icount++;
               }
                        
                
            }
              
        }
        
        if(customItemsToInsert.size()>0){
            insert customItemsToInsert;
        }
        
        if(mapCommercialInvoiceToInsert.size()>0){
            insert mapCommercialInvoiceToInsert.values();            
        }        
        
        // Create Requestshipment Documents
        List<zkmulti__RequestedShipmentDocuments__c> lstRequestedShipmentDocuments = new List<zkmulti__RequestedShipmentDocuments__c>();
        if(mapShipment.size()>0 && mapCommercialInvoiceToInsert.size()>0){
            Integer i = 0;
            for(zkmulti__MCShipment__c ship:mapShipment.values()){
                zkmulti__RequestedShipmentDocuments__c reqShipDocs = new zkmulti__RequestedShipmentDocuments__c(
                   zkmulti__Shipment__c = ship.Id,
                   zkmulti__CommercialInvoice__c = mapCommercialInvoiceToInsert.get(i).Id,
                   zkmulti__ImporterSameAsConsignee__c = true
                );
                lstRequestedShipmentDocuments.add(reqShipDocs);
                i++;
            }
        }
        
        if(lstRequestedShipmentDocuments.size()>0){
            Insert lstRequestedShipmentDocuments;
        }
       
        // For DHL Express
        /*
        // Create Custom Items
        List<zkmulti__MCCustoms_Item__c> customItemsToInsert = new List<zkmulti__MCCustoms_Item__c>();
        for (zkmulti__MCShipment__c qs : mcShipmentsToInsert) {
            zkmulti__MCCustoms_Item__c customItem = new zkmulti__MCCustoms_Item__c (
                zkmulti__Weight__c = 1,
                zkmulti__Weight_Units__c = 'LB',
                zkmulti__Country_of_Manufacture__c = 'US',
                zkmulti__Harmonized_Code__c = '1234567',
                zkmulti__Quantity__c = 1,
                zkmulti__Value__c = 5,
                zkmulti__Value_Currency__c = 'USD',
                zkmulti__Description__c = 'Description',
                zkmulti__Shipment__c = qs.Id          
            );
            customItemsToInsert.add(customItem);
        }
        insert customItemsToInsert;
        
        // Ship Info
        zkmulti__MCShipmentInfo__c shipInfo = new zkmulti__MCShipmentInfo__c(
            zkmulti__Contents_Type__c = 'Merchandise'   
        );
        // Additional Parameters
        Map<String, Object> additionalParameters = new Map<String, Object>();
        additionalParameters.put('shipmentInfo', shipInfo);
        for (zkmulti__MCShipment__c mcShipment : mcShipmentsToInsert) {
            try {
                List<zkmulti.ShipmentRate> rates = zkmulti.BulkShipmentInterface.calculateRates(shipmatePreference.Id, mcShipmentsToInsert.get(0), mcPackagesToInsert, null, customItemsToInsert, additionalParameters);
                System.debug('RATES: ' + rates);            
            } catch(Exception e) {
                System.debug('Exception:' + e.getMessage());
                System.debug('Exception at Line:' + e.getLineNumber());
                System.debug('Exception Cause:' + e.getCause());
            }
        }
        */
        
        // Process Bulk Shipment
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
            popupMessage = 'Process for generating shipping lables has been started, '+
                'You will receieve an email when process is complete.';
        }
        
        return null;
    }
    
    // Return to bulk shipment page
    public PageReference redirectToBulkShipmentDetailPage(){
        PageReference bulkShipmentDetailPage = new PageReference('/'+bulkShipment.Id);
        bulkShipmentDetailPage.setRedirect(true);
        return bulkShipmentDetailPage;
    }    
}
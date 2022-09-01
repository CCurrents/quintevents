/**
 * @description       : 
 * @author            : jagrawal@addonblue.com
 * @group             : 
 * @last modified on  : 07-29-2021
 * @last modified by  : fsuraitawala@addonblue.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   08-25-2020   jagrawal@addonblue.com   Initial Version
 * 1.1   08-25-2021   fsuraitawala@addonblue.com #1031 Generate Shipping address from Order
**/
public class QE_GenerateShippingLabels_UPS {
    
    String masterspreadReportId = '';
    public String popupMessage {get; set;}
    //public Map<String,Map<String,String>> shippingStateCodeByState{get; set;}
    zkmulti__MCBulk_Shipment__c bulkShipment;
    String bulkShipmentId;
    // Constructor
    public QE_GenerateShippingLabels_UPS(){
        // Get custom settings
        ZK_Print_Labels_Settings__c printLabelsSetings = ZK_Print_Labels_Settings__c.getOrgDefaults();
        masterspreadReportId = printLabelsSetings.Masterspread_V2_Report_Id__c;
        // Query bulk shipment
        bulkShipmentId = ApexPages.currentPage().getParameters().get('bulkshipmentid');
        if(bulkShipmentId != null) {
            bulkShipment = [
                Select Id, Event__c, Event__r.Name, Weight__c,Signature_Required__c,Package_Type__c, Service_Type__c, zkmulti__Shipmate_Preference__c, Processed__c From zkmulti__MCBulk_Shipment__c
                Where Id = :bulkShipmentId];
        }
    }
    
    //Generate Shipping Lables
    public void generateShippingLabels() {
        // If bulk shipment is allreay processed, skip the process and display message.
        if(bulkShipment.Processed__c) {
            popupMessage = 'This Bulk Shipment record has already been processed.';            
        }
        else{
            List<AsyncApexJob> asyncApexJobs = new List<AsyncApexJob>([Select id from AsyncApexJob where JobType = 'BatchApex' and 
                ApexClass.Name = 'QE_Generate_ShippingLabels_UPS_Batch' and Status != 'Completed' and status != 'Aborted' and status != 'Failed']);
            if(!asyncApexJobs.isEmpty()){
                popupMessage = 'This Bulk Shipment is in process, please wait for sometime.';
                return;
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
            
           
            Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(masterspreadReportId);
            Reports.ReportMetadata reportMetadata = describe.getReportMetadata();
            
            
            // Get exisiting columns
            List<String> existingColumns = reportMetadata.getDetailColumns();
            // New columns to be added
            List<String> columnNamesToBeAded = new List<String> {'OPPORTUNITY_ID', 'ACCOUNT_NAME', 'Opportunity.Ship_To_Name__c','AMOUNT.CONVERT',
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
                // If UPS
                system.debug('bulkShipment---->' + bulkShipment);
                if(bulkShipment != null && bulkShipment.Event__c != null && shipmatePreference.zkmulti__Carrier__c.equals('UPS')) {
                    reportFilters.add(new Reports.ReportFilter('Opportunity.Event_Id_15_Char__c', 'equals', String.valueOf(bulkShipment.Event__c).substring(0, 15)));
                    reportFilters.add(new Reports.ReportFilter('Opportunity.Pick_Up_Confirmed__c', 'equals', 'False'));
                    //reportFilters.add(new Reports.ReportFilter('Opportunity.Shipping_Outside_US__c', 'notEqual', 'No'));
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
            QE_Generate_ShippingLabels_UPS_Batch  batch = new QE_Generate_ShippingLabels_UPS_Batch(factDetails.getRows(), shipmatePreference, columnIndexByColumnName,bulkShipment);
            String bId =  Database.executeBatch(batch,10);
            popupMessage = 'Process for generating shipping lables has been started, '+
            'You will receieve an email when process is complete.';
          }
    }
    public static void ProcessShippingLabels(List<Reports.ReportDetailRow> factDetails, Map<String,Integer> columnIndexByColumnName,zkmulti__MCShipmate_Preference__c shipmatePreference,zkmulti__MCBulk_Shipment__c bulkShipment) {
                
        // Get the report metadata
        try{
            Map<String, String> countryMap = new Map<String, String>();
            Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple){
              countryMap.put(f.getLabel().toUpperCase(), f.getValue().toUpperCase());
            }
            
             Map<String,Map<String,String>> shippingStateCodeByState = new Map<String,Map<String,String>>();
            // Process report result
            // Report type is Opportunities with Products, so it will have multiple rows for products for same opportunity.
            // Create map to get only one product row for each opportunity as all product rows will have opportunity data.
            Map<Id,Reports.ReportDetailRow> mapOfRowsByOpportunityId = new Map<Id,Reports.ReportDetailRow>();
            //Map<Id,List<Reports.ReportDetailRow>> mapOfRowsByOppLineItem = new Map<Id,List<Reports.ReportDetailRow>>();        
            
            Map<string,Map<string,string>> mapOppLineItemsforCustomItems = New Map<string,Map<string,string>>();
            Map<string,Map<string,string>> mapexistingCustomItems = New Map<string,Map<string,string>>();
            Map<string,Double> mapOppAmount = New Map<string,Double>();
            
            for(Reports.ReportDetailRow reportrow : factDetails){
                System.debug('reportrow: '+reportrow.getDataCells()[columnIndexByColumnName.get('OPPORTUNITY_ID')].getLabel());
                mapOfRowsByOpportunityId.put(reportrow.getDataCells()[columnIndexByColumnName.get('OPPORTUNITY_ID')].getLabel(),reportrow);
                Double amount = (reportrow.getDataCells()[columnIndexByColumnName.get('AMOUNT.CONVERT')].getLabel() != null ? double.valueof(reportrow.getDataCells()[columnIndexByColumnName.get('AMOUNT.CONVERT')].getLabel().replace(',','').split(' ')[1]): 0);
                mapOppAmount.put(reportrow.getDataCells()[columnIndexByColumnName.get('OPPORTUNITY_ID')].getLabel(),amount);
            }            
            //#1031 Generate Shipping address from Order
            Map<Id, Order> mapOrderByOpp = new Map<Id, Order>();
            if(mapOfRowsByOpportunityId != null && mapOfRowsByOpportunityId.keySet().size() > 0) {
                
                for(Opportunity objOpp: [Select Id, (Select Id, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingStateCode,
                                         ShippingCountryCode, ShippingAddress, ShipToContactId, ShipToContact.Name FROM Orders Where Status = 'Active' LIMIT 1) 
                                         FROM Opportunity WHERE Id IN :mapOfRowsByOpportunityId.keySet()]){
                    for(Order objOrder: objOpp.Orders){
                        mapOrderByOpp.put(objOpp.Id, objOrder);
                    }
                }
            }
            
            //Check existing shipment records
            Map<Id,zkmulti__MCShipment__c> mapexistingShipmentsforOpps = New Map<Id,zkmulti__MCShipment__c>();
            for(zkmulti__MCShipment__c mcship: [select id,Opportunity__c,zkmulti__Carrier__c, (select id from zkmulti__FedEx2_Requested_Shipment_Documents__r) from zkmulti__MCShipment__c where Opportunity__c in: mapOfRowsByOpportunityId.keyset() and zkmulti__Bulk_Shipment__c =: bulkShipment.Id]){
                mapexistingShipmentsforOpps.put(mcship.Opportunity__c,mcship);
            }            
            
            List<opportunityLineItem> oppLineItems = new List<opportunityLineItem>();
            if(!Test.IsrunningTest())  oppLineItems  = [select id,OpportunityId,Product2.Commodity_Harmonized_Code__c,Product2.Commodity_Weight__c,Product2.Commodity_Unit_Price__c,Product2.Commodity_Description__c,Quantity from opportunityLineITem where OpportunityId in: mapOfRowsByOpportunityId.keyset() and Product2.Commodity_Harmonized_Code__c != null];
            else  oppLineItems  = [select id,OpportunityId,Product2.Commodity_Harmonized_Code__c,Product2.Commodity_Weight__c,Product2.Commodity_Unit_Price__c,Product2.Commodity_Description__c,Quantity from opportunityLineITem where Product2.Commodity_Harmonized_Code__c != null limit 1];
            
            Integer countCI = 0; 
            Integer intCI = 0;            
            for(OpportunityLineItem row : oppLineItems){
                System.debug('Row: '+row.OpportunityId);               
                if(shipmatePreference.zkmulti__Carrier__c.equals('UPS')) {
                    //For Custom Items  
                    if(mapexistingShipmentsforOpps.containskey(row.OpportunityId) && mapexistingShipmentsforOpps.get(row.OpportunityId) != null){
                        if(row.Product2.Commodity_Harmonized_Code__c != '-' && row.Product2.Commodity_Harmonized_Code__c != null && row.Product2.Commodity_Harmonized_Code__c != ''){                          
                            mapexistingCustomItems.put(intCI+'###'+row.OpportunityId,new Map<string,string>{'Weight'=>(row.Product2.Commodity_Weight__c != null?string.valueof(row.Product2.Commodity_Weight__c):''),'Harmonized Code'=>row.Product2.Commodity_Harmonized_Code__c,'Unit Price'=>(row.Product2.Commodity_Unit_Price__c != null ? string.valueof(row.Product2.Commodity_Unit_Price__c): ''),'Description'=>row.Product2.Commodity_Description__c,'Quantity'=>(row.Quantity != null ? string.valueof(row.Quantity):'')});
                            intCI++; 
                        }
                    }
                    else{ 
                        if(row.Product2.Commodity_Harmonized_Code__c != '-' && row.Product2.Commodity_Harmonized_Code__c != null && row.Product2.Commodity_Harmonized_Code__c != ''){                          
                            mapOppLineItemsforCustomItems.put(countCI+'###'+row.OpportunityId,new Map<string,string>{'Weight'=>(row.Product2.Commodity_Weight__c != null?string.valueof(row.Product2.Commodity_Weight__c):''),'Harmonized Code'=>row.Product2.Commodity_Harmonized_Code__c,'Unit Price'=>(row.Product2.Commodity_Unit_Price__c != null ? string.valueof(row.Product2.Commodity_Unit_Price__c): ''),'Description'=>row.Product2.Commodity_Description__c,'Quantity'=>(row.Quantity != null ? string.valueof(row.Quantity):'')});
                            countCI++; 
                        }
                    }
                }         
            }
            
            System.debug('mapOfRowsByOpportunityId.values(): '+mapOfRowsByOpportunityId.values());
            System.debug('@@@mapOfRowsByOpportunityId.values() size: '+mapOfRowsByOpportunityId.size());
            
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
            
            system.debug('###mapexistingShipmentsforOpps=='+mapexistingShipmentsforOpps);
            system.debug('###mapexistingCustomItems=='+mapexistingCustomItems);
            
            // Create Queued Shipments
            List<zkmulti__MCShipment__c> mcShipmentsToInsert = new List<zkmulti__MCShipment__c>();               
            For(Reports.ReportDetailRow row : mapOfRowsByOpportunityId.values()){  
                Id oppId = row.getDataCells()[columnIndexByColumnName.get('OPPORTUNITY_ID')].getLabel();
                Order oppOrder = new Order();
                if(mapOrderByOpp != null && mapOrderByOpp.containsKey(oppId)) {
                    oppOrder = mapOrderByOpp.get(oppId);
                }
                if(mapexistingShipmentsforOpps.containskey(oppId)) continue;       
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
                if(shipmatePreference.zkmulti__Shipping_Country__c == 'GB') mcShipment.zkmulti__Dimension_Units__c = 'CM'; // ASK     
                else mcShipment.zkmulti__Dimension_Units__c = 'IN'; // ASK            
                // If UPS
                if(shipmatePreference.zkmulti__Carrier__c.equals('UPS')) {
                    if(shipmatePreference.zkmulti__Shipping_Country__c == 'GB') mcShipment.zkmulti__Weight_Units__c = 'KGS';  
                    else mcShipment.zkmulti__Weight_Units__c = 'LBS'; // ASK  
                }else{
                    mcShipment.zkmulti__Weight_Units__c = 'LB'; // ASK  
                }
                
                // If UPS International
                if(shipmatePreference.zkmulti__Carrier__c.equals('UPS')) {
                    mcShipment.zkmulti__ShipmentDescription__c = 'None';
                    mcShipment.zkmulti__Shipment_Info__c = shipInfo.Id;  
                    mcShipment.zkmulti__Service_Type__c = bulkShipment.Service_Type__c;
                    mcShipment.zkmulti__Package_Type__c = bulkShipment.Package_Type__c;                  
                }
                
                // If Fedex
                if(shipmatePreference.zkmulti__Carrier__c.equals('UPS') && row.getDataCells()[columnIndexByColumnName.get('Opportunity.Shipping_Outside_US__c')].getLabel() == 'No') {
                    //mcShipment.zkmulti__Service_Type__c = 'FEDEX_GROUND';
                    //mcShipment.zkmulti__Package_Type__c = 'YOUR_PACKAGING';                
                    system.debug('###bulkShipment.Service_Type__c=='+bulkShipment.Service_Type__c);
                    
                    //Added on 10/31/2018
                    if(bulkShipment.Event__c != null){
                        mcShipment.zkmulti__Reference1_Value__c = bulkShipment.Event__r.Name.length() > 35 ? bulkShipment.Event__r.Name.substring(0,35) : bulkShipment.Event__r.Name;
                    }
                    mcShipment.Weight__c = bulkShipment.Weight__c;
                    mcShipment.zkmulti__Service_Type__c = bulkShipment.Service_Type__c;
                    mcShipment.zkmulti__Package_Type__c = bulkShipment.Package_Type__c;
                }
                // If DHLExpress
                /*if(shipmatePreference.zkmulti__Carrier__c.equals('DHLExpress')) {
                    mcShipment.zkmulti__Service_Type__c = 'Express1030NonDoc';
                    mcShipment.zkmulti__Package_Type__c = 'JumboParcel';
                    mcShipment.zkmulti__Package_Type__c = 'OtherDHLPackaging';
                }*/
                
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
                mcShipment.zkmulti__Sender_Zip_Postal_Code__c = (shipmatePreference.zkmulti__Shipping_Zip_Postal_Code__c).replace(' ','');
                mcShipment.zkmulti__Ship_Date__c = Date.today();
                // Recipient info            
                Integer maxSize = 35;
                String newshippingStreet = '';
                //#1031 Generate Shipping address from Order
                String shippingStreet = '';
                String opportunityState = '';
                String opportunityCountry = '';
                if(oppOrder.Id != null) {
                    shippingStreet = oppOrder.ShippingStreet;
                    opportunityState = oppOrder.ShippingState;
                    opportunityCountry = oppOrder.ShippingCountry;
                    mcShipment.zkmulti__Recipient_Company__c = oppOrder.ShipToContact.Name;
                    mcShipment.zkmulti__Recipient_City__c = oppOrder.ShippingCity;
                    mcShipment.zkmulti__Recipient_Zip_Postal_Code__c = oppOrder.ShippingPostalCode != null ? (oppOrder.ShippingPostalCode).replace(' ','') : null;
                    mcShipment.zkmulti__Recipient_Name__c = oppOrder.ShipToContactId != null && oppOrder.ShipToContact.Name.length() > 35 ? oppOrder.ShipToContact.Name.substring(0,35) : oppOrder.ShipToContact.Name;
                } else {
                    shippingStreet = row.getDataCells()[columnIndexByColumnName.get('Opportunity.Shipping_Street__c')].getLabel();
                    opportunityState = row.getDataCells()[columnIndexByColumnName.get('Opportunity.Shipping_State_Province__c')].getLabel();
                    opportunityCountry = row.getDataCells()[columnIndexByColumnName.get('Opportunity.Shipping_Country__c')].getLabel();
                    mcShipment.zkmulti__Recipient_City__c = row.getDataCells()[columnIndexByColumnName.get('Opportunity.Shipping_City__c')].getLabel();
                    mcShipment.zkmulti__Recipient_Zip_Postal_Code__c = (row.getDataCells()[columnIndexByColumnName.get('Opportunity.Shipping_Zip_Postal_Code__c')].getLabel()).replace(' ','');
                    mcShipment.zkmulti__Recipient_Company__c = row.getDataCells()[columnIndexByColumnName.get('Opportunity.Ship_To_Name__c')].getLabel();// ASK, shoud this be company for bussness oppt?
                    mcShipment.zkmulti__Recipient_Name__c = row.getDataCells()[columnIndexByColumnName.get('Opportunity.Ship_To_Name__c')].getLabel() != null && row.getDataCells()[columnIndexByColumnName.get('Opportunity.Ship_To_Name__c')].getLabel().length() > 35 ? row.getDataCells()[columnIndexByColumnName.get('Opportunity.Ship_To_Name__c')].getLabel().substring(0,35) : row.getDataCells()[columnIndexByColumnName.get('Opportunity.Ship_To_Name__c')].getLabel();
                }
                
                if(shippingStreet != null){
                    for(integer i =0; i < 3; i++){
                        if(shippingStreet.length() > maxSize){          
                            if(!string.isblank(newshippingStreet)) newshippingStreet += '\n';
                            newshippingStreet += shippingStreet.substring(0, maxSize);               
                            shippingStreet = shippingStreet.substring(maxSize, shippingStreet.length());                        
                        } else {
                            if(string.isblank(newshippingStreet)) newshippingStreet = shippingStreet;                    
                            else newshippingStreet += '\n' + shippingStreet;
                            break;
                        }
                    }
                }
                system.debug('###newshippingStreet=='+newshippingStreet);
                //mcShipment.zkmulti__Recipient_Opportunity__c = row.getDataCells()[columnIndexByColumnName.get('OPPORTUNITY_ID')].getLabel(); // Default opportunity lookup which comes with the zenkraft package
                mcShipment.Opportunity__c = row.getDataCells()[columnIndexByColumnName.get('OPPORTUNITY_ID')].getLabel(); // Custom opportunity package to make everything work with custom opportunity address
                mcShipment.zkmulti__Recipient_Address_is_Residential__c = false;
                 
                //mcShipment.zkmulti__Recipient_Street__c = row.getDataCells()[columnIndexByColumnName.get('Opportunity.Shipping_Street__c')].getLabel();
                mcShipment.zkmulti__Recipient_Street__c = newshippingStreet;
                
                shippingStateCodeByState = QE_GenerateShippingLabels_UPS.getDependentOptionsImpl(User.statecode, User.countrycode, opportunityCountry, opportunityState);
                
                System.debug('opportunityState code: ' + shippingStateCodeByState.get(opportunityCountry));
                mcShipment.zkmulti__Recipient_State_Province__c = shippingStateCodeByState.ContainsKey(opportunityCountry) ? (shippingStateCodeByState.get(opportunityCountry).ContainsKey(opportunityState) ? shippingStateCodeByState.get(opportunityCountry).get(opportunityState) : '') : '';
                   
                mcShipment.zkmulti__Recipient_Country__c = countryMap.containskey(opportunityCountry.toUpperCase()) ? countryMap.get(opportunityCountry.toUpperCase()):'';
                
                mcShipment.zkmulti__Recipient_Email__c = row.getDataCells()[columnIndexByColumnName.get('Opportunity.Email__c')].getLabel();
                           
                mcShipment.zkmulti__Recipient_Phone__c = row.getDataCells()[columnIndexByColumnName.get('Opportunity.Phone__c')].getLabel();
                
                // Other
                mcShipment.Event__c = bulkShipment.Event__c;
                
                // Add to list
                
                // Updated on 10/31/2018
                system.debug('###Country=='+row.getDataCells()[columnIndexByColumnName.get('Opportunity.Shipping_Country__c')].getLabel());
                system.debug('###Paid in Full =='+row.getDataCells()[columnIndexByColumnName.get('Opportunity.Paid_in_Full__c')].getLabel());
                system.debug('###OpportunityLineItem =='+row.getDataCells()[columnIndexByColumnName.get('OpportunityLineItem.Record_Type__c')].getLabel());
                
                mcShipmentsToInsert.add(mcShipment);
            }       
            
            System.debug('@@@mcShipmentsToInsert: '+mcShipmentsToInsert);
            if(mcShipmentsToInsert.size()>0){
                insert mcShipmentsToInsert;
            }
            System.debug('mcShipmentsToInsert: '+mcShipmentsToInsert);
            
            List<zkmulti__MCShipment_Special_Services__c> mcSpecialServiceToInsert = new List<zkmulti__MCShipment_Special_Services__c>();         
            for (zkmulti__MCShipment__c mcShipment : mcShipmentsToInsert) {
                // Create Shipment Special Services
                Reports.ReportDetailRow row = mapOfRowsByOpportunityId.get(mcShipment.Opportunity__c);
                if(mcShipment.zkmulti__Carrier__c == 'UPS'){
                    zkmulti__MCShipment_Special_Services__c shipmentSS  = new zkmulti__MCShipment_Special_Services__c (
                        zkmulti__Shipment__c = mcShipment.Id,
                        //zkmulti__DirectDeliveryOnly__c = true,
                        //zkmulti__SelectedSignatureOption__c = 'SIGNATURE_REQUIRED', //'DIRECT',
                        zkmulti__SignatureReleaseNumber__c = mcShipment.Opportunity__c                                                
                    );

                    if(bulkshipment.Signature_Required__c == true && !isUPSPackageDeliveryConfirmationIsSupported(mcShipment)){
                        shipmentSS.zkmulti__DeliveryConfirmation__c = true;
                        shipmentSS.zkmulti__SelectedSignatureOption__c = 'SIGNATURE_REQUIRED';
                    }

                    mcSpecialServiceToInsert.add(shipmentSS);
                }            
                
            }
            if(mcSpecialServiceToInsert.size()>0){
                insert mcSpecialServiceToInsert;
            }
            System.debug('mcSpecialServiceToInsert: '+mcSpecialServiceToInsert);      
            
            // Create Queued Packages
            List<zkmulti__MCPackage__c> mcPackagesToInsert = new List<zkmulti__MCPackage__c>();
            for(zkmulti__MCShipment__c mcShipment : mcShipmentsToInsert) {
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
                
                if (mcShipment.zkmulti__Carrier__c == 'UPS') {
                    if(bulkshipment.Signature_Required__c == true && isUPSPackageDeliveryConfirmationIsSupported(mcShipment)){
                        mcPackage.zkmulti__SsSignatureOption__c = 'SIGNATURE_REQUIRED';
                    }
                    
                }
                
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
                if(qs != null && qs.zkmulti__Carrier__c == 'UPS'){
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
                        system.debug('###mapOppAmount11=='+mapOppAmount);
                        String oppId = string.valueof(qs.Opportunity__c).substring(0,15);
                        if(mapOppAmount.containskey(oppId) && mapOppAmount.get(oppId) != null){
                            system.debug('###mapOppAmount22=='+mapOppAmount);
                            if(mapOppAmount.get(oppId)<=2500){
                             system.debug('###mapOppAmount.get(oppId)=='+mapOppAmount.get(oppId));
                             mcCommercialInvoice.zkmulti__Comments__c = 'Goods qualify under the USMCA';
                             //mcCommercialInvoice.zkmulti__DeclarationStatement__c = 'Goods qualify under the USMCA';
                            }
                        }
                        mapCommercialInvoiceToInsert.put(icount,mcCommercialInvoice);
                        mapShipment.put(icount,qs);
                        icount++;
                    }
                }
                
            }
            
            if(customItemsToInsert.size()>0){
                insert customItemsToInsert;
            }
            System.debug('###customItemsToInsert=='+customItemsToInsert);
            
            if(mapCommercialInvoiceToInsert.size()>0){
                insert mapCommercialInvoiceToInsert.values();            
            }        
            System.debug('###mapCommercialInvoiceToInsert.values()=='+mapCommercialInvoiceToInsert.values());
            System.debug('###mapShipment=='+mapShipment);
            // Create Requestshipment Documents
            List<zkmulti__RequestedShipmentDocuments__c> lstRequestedShipmentDocuments = new List<zkmulti__RequestedShipmentDocuments__c>();
            if(mapShipment.size()>0 && mapCommercialInvoiceToInsert.size()>0){
                Integer i = 0;
                for(zkmulti__MCShipment__c ship: mapShipment.values()){                   
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
            System.debug('###lstRequestedShipmentDocuments=='+lstRequestedShipmentDocuments);  
            
            
            //To update commercial Invoice for existing Shipment
            List<zkmulti__MCCustoms_Item__c> newcustomItemsToInsert = new List<zkmulti__MCCustoms_Item__c>();            
            Map<Id,zkmulti__RequestedShipmentDocuments__c> mapRequestedShipmentDocToupdate = new Map<Id,zkmulti__RequestedShipmentDocuments__c>();           
            for (zkmulti__MCShipment__c qs : mapexistingShipmentsforOpps.values()) {                               
                if(qs != null && qs.zkmulti__Carrier__c == 'UPS'){
                    // Create Custom Items
                    if(mapexistingCustomItems.size()>0){
                        for(string strcount: mapexistingCustomItems.keyset()){
                            System.debug('strcount: '+strcount);
                            if(strcount.split('###')[1] == qs.Opportunity__c){                        
                                zkmulti__MCCustoms_Item__c customItem = new zkmulti__MCCustoms_Item__c();
                                if(mapexistingCustomItems.containskey(strcount) && mapexistingCustomItems.get(strcount) != null){
                                    customItem.zkmulti__Weight__c = mapexistingCustomItems.get(strcount).get('Weight') != null && mapexistingCustomItems.get(strcount).get('Weight') != '-' ? double.valueof(mapexistingCustomItems.get(strcount).get('Weight')) : null;
                                    customItem.zkmulti__Harmonized_Code__c = mapexistingCustomItems.get(strcount).get('Harmonized Code') != null ? string.valueof(mapexistingCustomItems.get(strcount).get('Harmonized Code')) : '';
                                    customItem.zkmulti__Quantity__c = mapexistingCustomItems.get(strcount).get('Quantity') != null && mapexistingCustomItems.get(strcount).get('Quantity') != '-' ? double.valueof(mapexistingCustomItems.get(strcount).get('Quantity')) : null;
                                    customItem.zkmulti__Value__c = mapexistingCustomItems.get(strcount).get('Unit Price') != null && mapexistingCustomItems.get(strcount).get('Unit Price') != '-' ? double.valueof(mapexistingCustomItems.get(strcount).get('Unit Price'))*double.valueof(mapexistingCustomItems.get(strcount).get('Quantity')): null;
                                    customItem.zkmulti__Description__c = mapexistingCustomItems.get(strcount).get('Description') != null ? string.valueof(mapexistingCustomItems.get(strcount).get('Description')) : '';
                                    customItem.zkmulti__UnitPrice__c = mapexistingCustomItems.get(strcount).get('Unit Price') != null && mapexistingCustomItems.get(strcount).get('Unit Price') != '-' ? double.valueof(mapexistingCustomItems.get(strcount).get('Unit Price')): null;
                                }
                                customItem.zkmulti__Weight_Units__c = 'LB';
                                customItem.zkmulti__Country_of_Manufacture__c = 'US';                
                                customItem.zkmulti__Value_Currency__c = 'USD';                  
                                customItem.zkmulti__Shipment__c = qs.Id;
                                customItem.zkmulti__Carrier__c = 'UPS';
                                customItem.zkmulti__UnitOfMeasurement__c = 'Each';                 
                                customItem.zkmulti__UnitPriceCurrency__c = 'USD';                
                                newcustomItemsToInsert.add(customItem);
                                if(qs.zkmulti__FedEx2_Requested_Shipment_Documents__r != null){
                                    for(zkmulti__RequestedShipmentDocuments__c rs: qs.zkmulti__FedEx2_Requested_Shipment_Documents__r){
                                        mapRequestedShipmentDocToupdate.put(rs.id,rs);
                                    }
                                }
                                
                            }
                        }                         
                                                
                    }
                }                
            }  
            
            if(newcustomItemsToInsert.size()>0){
                insert newcustomItemsToInsert;
            }
            if(mapRequestedShipmentDocToupdate.size()>0){
                update mapRequestedShipmentDocToupdate.values();
            }
            System.debug('###newcustomItemsToInsert existing=='+newcustomItemsToInsert);   
            System.debug('###mapRequestedShipmentDocToupdate existing=='+mapRequestedShipmentDocToupdate.values());      
            
        }
        catch(exception ex){
            system.debug('Exception-'+ex.getLineNumber() +'--' + ex.getMessage());
        }
        //return null;
    }
    
    // Return to bulk shipment page
    public PageReference redirectToBulkShipmentDetailPage(){
        PageReference bulkShipmentDetailPage = new PageReference('/'+bulkShipment.Id);
        bulkShipmentDetailPage.setRedirect(true);
        return bulkShipmentDetailPage;
    }
    
    public static Map<String, Map<String, String>> getDependentOptionsImpl(Schema.SObjectField theField, Schema.SObjectField ctrlField, String cntrlValue, String dependentValue) {
        // validFor property cannot be accessed via a method or a property,
        // so we need to serialize the PicklistEntry object and then deserialize into a wrapper.
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        
        // Set up the return container - Map<ControllingValue, List<DependentValues>>
        Map<String, Map<String, String>> objResults = new Map<String, Map<String, String>>();
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            //if(label == cntrlValue) {
            objResults.put(label, new Map<String, String>());
            controllingValues.add(label);
            //system.debug('@@@label=='+label);
            // }
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            if(dependentValue == label) {
                String validForBits = base64ToBits(plew.validFor);
                for (Integer i = 0; i < validForBits.length(); i++) {
                    // For each bit, in order: if it's a 1, add this label to the dependent list for the corresponding controlling value
                    String bit = validForBits.mid(i, 1);
                    if (bit == '1') {
                        objResults.get(controllingValues.get(i)).put(label, plew.value);
                        //system.debug('@@@objResults=='+label+' '+plew.value);
                    }
                }
            }
        }
        
        return objResults;
    }

    public static Boolean isUPSPackageDeliveryConfirmationIsSupported(zkmulti__MCShipment__c shipment) {
        if (shipment.zkmulti__Sender_Country__c == 'US' && (shipment.zkmulti__Recipient_Country__c == 'US' || shipment.zkmulti__Recipient_Country__c == 'PR')) {
            return true;
        }
        if (shipment.zkmulti__Sender_Country__c == 'CA' && shipment.zkmulti__Recipient_Country__c == 'CA') {
            return true;
        }
        if (shipment.zkmulti__Sender_Country__c == 'PR' && (shipment.zkmulti__Recipient_Country__c == 'US' || shipment.zkmulti__Recipient_Country__c == 'PR')) {
            return true;
        } 

        return false;
    }
    
    // Convert decimal to binary representation (alas, Apex has no native method :-(
    //    eg. 4 => '100', 19 => '10011', etc.
    // Method: Divide by 2 repeatedly until 0. At each step note the remainder (0 or 1).
    // These, in reverse order, are the binary.
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    // Convert a base64 token into a binary/bits representation
    // e.g. 'gAAA' => '100000000000000000000'
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        String validForBits = '';
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        return validForBits;
    }
    
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper {
        public String active {get; set;}
        public String defaultValue {get; set;}
        public String label {get; set;}
        public String value {get; set;}
        public String validFor {get; set;}
    }
}
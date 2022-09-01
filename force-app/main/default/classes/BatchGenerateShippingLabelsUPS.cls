/**
* @File Name          : BatchGenerateShippingLabelsUPS.cls
* @Description        : This class is used to create batch for shipping labels report data. This is reference to QE360V3_GenerateShippingLabels_UPS class
* @Author             : kchavda@addonblue.com

* @Last Modified By   : fsuraitawala@addonblue.com
* @Last Modified On   : 01-17-2022
* @Modification Log   : 
* Ver       Date            Author               Modification
* 1.0       02/13/2020      kchavda              Initial Version
* 1.1       09/02/2020  kchavda@addonblue.com    #492 Shipping Label V2 and V3 logic change
* 1.2       05/06/2021  kchavda@addonblue.com    #944 Pricebook Name needs to be added to Shipping Label and Invoice for Bulk Shipment
* 1.3       02/02/2022      VKHOPADE             #1149 for enabling FedEx international shipment
* 1.4       03/02/2022      VKHOPADE             #1172 for enabling FedEx One Rate special service on US domestic shipments
**/
public class BatchGenerateShippingLabelsUPS implements Database.Batchable<Reports.ReportDetailRow>,Database.AllowsCallouts, Database.Stateful{

    public final Map<String,Integer> columnIndexByColumnName;
    Public final zkmulti__MCShipmate_Preference__c shipmatePreference;
    public final List<Reports.ReportDetailRow> reportRowDetails;
    public final zkmulti__MCBulk_Shipment__c bulkShipment;    
    public final zkmulti__MCShipmentInfo__c shipInfo;   
    
     /**
    * @description  : To assign public valirables in constructor
    * @author       : kchavda@addonblue.com
    * @param        : List<Reports.ReportDetailRow>, zkmulti__MCShipmate_Preference__c, Map<String,Integer>, zkmulti__MCBulk_Shipment__c
    * @return       : 
    **/
    public BatchGenerateShippingLabelsUPS( List<Reports.ReportDetailRow> reportRowDetail, zkmulti__MCShipmate_Preference__c shipmatePrefer,Map<String,Integer> colIndexByColumnName,zkmulti__MCBulk_Shipment__c bulkShip,zkmulti__MCShipmentInfo__c spInfo){
        this.reportRowDetails = reportRowDetail;        
        this.shipmatePreference = shipmatePrefer;        
        this.columnIndexByColumnName = colIndexByColumnName;
        this.bulkShipment = bulkShip;
        this.shipInfo = spInfo;
    }
    
     /**
    * @description  : To retrun report detail row information
    * @author       : kchavda@addonblue.com
    * @param        : Database.BatchableContext
    * @return       : Iterable<Reports.ReportDetailRow>
    **/
    public Iterable<Reports.ReportDetailRow> start(Database.BatchableContext BC){        
        return reportRowDetails;
    }
    
    /**
    * @description  : To execute busines logic for report detail row
    * @author       : kchavda@addonblue.com
    * @param        : Database.BatchableContext, List<Reports.ReportDetailRow>
    * @return       : void 
    **/
    public void execute(Database.BatchableContext info, List<Reports.ReportDetailRow> factDetails) {
        Map<String, String> countryMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
          countryMap.put(f.getLabel().toUpperCase(), f.getValue().toUpperCase());
        }
        
        // Process report result        
        // Create map to get only one product row for each Order as all product rows will have Order data.
        Map<Id,Reports.ReportDetailRow> mapOfRowsByOrderId = new Map<Id,Reports.ReportDetailRow>();           
        
        Map<string,Map<string,string>> mapOrderLineItemsforCustomItems = New Map<string,Map<string,string>>();
        Map<string,Map<string,string>> mapexistingCustomItems = New Map<string,Map<string,string>>();
        Map<string,Double> mapOrderAmount = New Map<string,Double>();
        
        for(Reports.ReportDetailRow reportrow : factDetails){
            System.debug('reportrow: '+reportrow.getDataCells()[columnIndexByColumnName.get('ORDER_ID')].getLabel());
            mapOfRowsByOrderId.put(reportrow.getDataCells()[columnIndexByColumnName.get('ORDER_ID')].getLabel(),reportrow);
            Double amount = (reportrow.getDataCells()[columnIndexByColumnName.get('ORDER_TOTAL_AMOUNT.CONVERT')].getLabel() != null ? double.valueof(reportrow.getDataCells()[columnIndexByColumnName.get('ORDER_TOTAL_AMOUNT.CONVERT')].getLabel().replace(',','').split(' ')[1]): 0);
            mapOrderAmount.put(reportrow.getDataCells()[columnIndexByColumnName.get('ORDER_ID')].getLabel(),amount);
            
        } 
        
        //Check existing shipment records
        Map<Id,zkmulti__MCShipment__c> mapexistingShipmentsforOrders = New Map<Id,zkmulti__MCShipment__c>();
        for(zkmulti__MCShipment__c mcship: [select id,Order__c,zkmulti__Carrier__c, (select id from zkmulti__FedEx2_Requested_Shipment_Documents__r) from zkmulti__MCShipment__c where Order__c in: mapOfRowsByOrderId.keyset() and zkmulti__Bulk_Shipment__c =: bulkShipment.Id]){
            mapexistingShipmentsforOrders.put(mcship.Order__c,mcship);
        }      
                
        List<OrderItem> OrderItems = new List<OrderItem>();
        if(!Test.isrunningTest())  OrderItems = [select id,OrderId,Product2.Commodity_Harmonized_Code__c,Product2.Commodity_Weight__c,Product2.Commodity_Unit_Price__c,Product2.Commodity_Description__c,Quantity from OrderItem where OrderId in: mapOfRowsByOrderId.keyset() and Product2.Commodity_Harmonized_Code__c != null];    
        else OrderItems = [select id,OrderId,Product2.Commodity_Harmonized_Code__c,Product2.Commodity_Weight__c,Product2.Commodity_Unit_Price__c,Product2.Commodity_Description__c,Quantity from OrderItem where Product2.Commodity_Harmonized_Code__c != null];
        
        Integer countCI = 0; 
        Integer intCI = 0;  
        for(OrderItem row : OrderItems){
            System.debug('Row: '+row.OrderId);                       
            
            if(shipmatePreference.zkmulti__Carrier__c.equals('UPS') || shipmatePreference.zkmulti__Carrier__c.equals('FedEx') || shipmatePreference.zkmulti__Carrier__c.equals('DHL Express')) { //VKHOPADE #1149 - added FedEx
                //For Custom Items 
                if(mapexistingShipmentsforOrders.containskey(row.OrderId) && mapexistingShipmentsforOrders.get(row.OrderId) != null){
                     if(row.Product2.Commodity_Harmonized_Code__c != '-' && row.Product2.Commodity_Harmonized_Code__c != null && row.Product2.Commodity_Harmonized_Code__c != ''){                          
                        mapexistingCustomItems.put(intCI+'###'+row.OrderId,new Map<string,string>{'Weight'=>(row.Product2.Commodity_Weight__c != null?string.valueof(row.Product2.Commodity_Weight__c):''),'Harmonized Code'=>row.Product2.Commodity_Harmonized_Code__c,'Unit Price'=>(row.Product2.Commodity_Unit_Price__c != null ? string.valueof(row.Product2.Commodity_Unit_Price__c): ''),'Description'=>row.Product2.Commodity_Description__c,'Quantity'=>(row.Quantity != null ? string.valueof(row.Quantity):'')});
                        intCI++; 
                        //system.debug('intCI = ' + intCI + ' :: mapexistingCustomItems = ' + mapexistingCustomItems.values() + ' :: row = ' + row.OrderId + ' : ' + row.Quantity);
                    }
                }
                else{     
                    if(row.Product2.Commodity_Harmonized_Code__c != '-' && row.Product2.Commodity_Harmonized_Code__c != null && row.Product2.Commodity_Harmonized_Code__c != ''){                          
                        mapOrderLineItemsforCustomItems.put(countCI+'###'+row.OrderId,new Map<string,string>{'Weight'=>(row.Product2.Commodity_Weight__c != null?string.valueof(row.Product2.Commodity_Weight__c):''),'Harmonized Code'=>row.Product2.Commodity_Harmonized_Code__c,'Unit Price'=>(row.Product2.Commodity_Unit_Price__c != null ? string.valueof(row.Product2.Commodity_Unit_Price__c): ''),'Description'=>row.Product2.Commodity_Description__c,'Quantity'=>(row.Quantity != null ? string.valueof(row.Quantity):'')});
                        countCI++; 
                        //system.debug('countCI = ' + countCI + ' :: mapOrderLineItemsforCustomItems = ' + mapOrderLineItemsforCustomItems.values() + ' :: row = ' + row.OrderId + ' : ' + row.Quantity);
                    }
                }
            }         
        }
        
        System.debug('mapOfRowsByOrderId.values(): '+mapOfRowsByOrderId.values());
        System.debug('@@@mapOfRowsByOrderId.values() size: '+mapOfRowsByOrderId.size());        
       
        system.debug('###mapexistingShipmentsforOrders=='+mapexistingShipmentsforOrders.values());
        system.debug('###mapexistingCustomItems=='+mapexistingCustomItems.values());
            
        Map<String,Map<String,String>> shippingStateCodeByState = new Map<String,Map<String,String>>();
        
         // Create Queued Shipments
        List<zkmulti__MCShipment__c> mcShipmentsToInsert = new List<zkmulti__MCShipment__c>();               
        For(Reports.ReportDetailRow row : mapOfRowsByOrderId.values()){   
            if(mapexistingShipmentsforOrders.containskey(row.getDataCells()[columnIndexByColumnName.get('ORDER_ID')].getLabel())) continue;     
            // Queued Shipment
            zkmulti__MCShipment__c mcShipment = new zkmulti__MCShipment__c();
            // Carrier
            mcShipment.zkmulti__Bulk_Shipment__c = bulkShipment.Id;
            mcShipment.zkmulti__Carrier__c = shipmatePreference.zkmulti__Carrier__c;
            mcShipment.zkmulti__Shipmate_Preference__c = shipmatePreference.Id;
            mcShipment.zkmulti__Currency__c = 'USD'; // ASK, shoud it be same as Order?            
            mcShipment.zkmulti__Shipment_Type__c = 'Outbound';
            mcShipment.zkmulti__DropoffType__c = 'DROP_BOX';            
            mcShipment.zkmulti__Billing_Account_Number__c = shipmatePreference.zkmulti__AccountNumber__c;
            mcShipment.zkmulti__Billing_Country__c = shipmatePreference.zkmulti__Billing_Country__c;            
            mcShipment.zkmulti__Label_Image_Type__c = shipmatePreference.zkmulti__Label_Image_Type_Default__c; // This may need to change.
            if(shipmatePreference.zkmulti__Shipping_Country__c == 'GB') mcShipment.zkmulti__Dimension_Units__c = 'CM'; // ASK    
            else mcShipment.zkmulti__Dimension_Units__c = 'IN';        
            // If UPS
            if(shipmatePreference.zkmulti__Carrier__c.equals('UPS')) {
                if(shipmatePreference.zkmulti__Shipping_Country__c == 'GB') mcShipment.zkmulti__Weight_Units__c = 'KGS';  
                else mcShipment.zkmulti__Weight_Units__c = 'LBS';
            }else{
                mcShipment.zkmulti__Weight_Units__c = 'LB'; // ASK  
            }
            
            // If UPS International
            if(shipmatePreference.zkmulti__Carrier__c.equals('UPS') || shipmatePreference.zkmulti__Carrier__c.equals('FedEx') || shipmatePreference.zkmulti__Carrier__c.equals('DHL Express')) { 
                mcShipment.zkmulti__ShipmentDescription__c = 'None';
                mcShipment.zkmulti__Shipment_Info__c = shipInfo.Id;  
                mcShipment.zkmulti__Service_Type__c = bulkShipment.Service_Type__c;    
                mcShipment.zkmulti__Package_Type__c = bulkShipment.Package_Type__c;   
                if(bulkShipment.PriceBook__c != null){
                    mcShipment.zkmulti__Reference1_Value__c = bulkShipment.PriceBook__r.Name.length() > 35 ? bulkShipment.PriceBook__r.Name.substring(0,35) : bulkShipment.PriceBook__r.Name;
                }
                mcShipment.Weight__c = bulkShipment.Weight__c; 
            }
            
            /*if(shipmatePreference.zkmulti__Carrier__c.equals('UPS') && countryMap.get(row.getDataCells()[columnIndexByColumnName.get('ORDER_SHIPPING_COUNTRY_CODE')].getLabel().toUpperCase()) == 'US') {
                              
                system.debug('###bulkShipment.Service_Type__c=='+bulkShipment.Service_Type__c);
                
                if(bulkShipment.PriceBook__c != null){
                    mcShipment.zkmulti__Reference1_Value__c = bulkShipment.PriceBook__r.Name.length() > 35 ? bulkShipment.PriceBook__r.Name.substring(0,35) : bulkShipment.PriceBook__r.Name;
                }
                mcShipment.Weight__c = bulkShipment.Weight__c;
                mcShipment.zkmulti__Service_Type__c = bulkShipment.Service_Type__c;
                mcShipment.zkmulti__Package_Type__c = bulkShipment.Package_Type__c;
            }*/
            
            // If DHLExpress
            /*if(shipmatePreference.zkmulti__Carrier__c.equals('DHLExpress')) {
                mcShipment.zkmulti__Service_Type__c = 'Express1030NonDoc';
                mcShipment.zkmulti__Package_Type__c = 'JumboParcel';
                mcShipment.zkmulti__Package_Type__c = 'OtherDHLPackaging';
            }*/
            
            // Sender info
            mcShipment.zkmulti__Payment_Type__c = 'SENDER';
            if(shipmatePreference.zkmulti__Carrier__c.equals('DHL Express')){  //VKHOPADE - #1177
            	mcShipment.zkmulti__Payment_Type__c = 'shipper';    
            }
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
            
            if(bulkShipment.Ship_Date__c != null && bulkShipment.Ship_Date__c >= Date.today()){
            	mcShipment.zkmulti__Ship_Date__c = bulkShipment.Ship_Date__c; //VKHOPADE - issue 1172    
            }
            else
            {
            	mcShipment.zkmulti__Ship_Date__c = Date.today();    
            }
            
                
            // Recipient info            
            Integer maxSize = 35;
            String newshippingStreet = '';
            String shippingStreet = row.getDataCells()[columnIndexByColumnName.get('ORDER_SHIPPING_STREET')].getLabel();
            if(shippingStreet != null){
                for(integer i =0; i<3;i++){
                    if(shippingStreet.length() > maxSize){          
                        if(!string.isblank(newshippingStreet)) newshippingStreet += '\n';
                        newshippingStreet += shippingStreet.substring(0, maxSize);               
                        shippingStreet = shippingStreet.substring(maxSize, shippingStreet.length());                        
                    }else{
                        if(string.isblank(newshippingStreet)) newshippingStreet = shippingStreet;                    
                        else newshippingStreet += '\n' + shippingStreet;
                        break;
                    }
                }
            }
            
            mcShipment.Order__c = row.getDataCells()[columnIndexByColumnName.get('ORDER_ID')].getLabel(); // Custom Order package to make everything work with custom Order address
            mcShipment.zkmulti__Recipient_Address_is_Residential__c = false;
            mcShipment.zkmulti__Recipient_Company__c = row.getDataCells()[columnIndexByColumnName.get('ORDER_SHIPPING_FIRST_NAME')].getLabel() + ' ' + row.getDataCells()[columnIndexByColumnName.get('ORDER_SHIPPING_LAST_NAME')].getLabel(); // ASK, shoud this be company for bussness Order?
            mcShipment.zkmulti__Recipient_Street__c = newshippingStreet;
            mcShipment.zkmulti__Recipient_City__c = row.getDataCells()[columnIndexByColumnName.get('ORDER_SHIPPING_CITY')].getLabel();
            
            String OrderState = row.getDataCells()[columnIndexByColumnName.get('ORDER_SHIPPING_STATE_CODE')].getLabel();
            String OrderCountry = row.getDataCells()[columnIndexByColumnName.get('ORDER_SHIPPING_COUNTRY_CODE')].getLabel();
            shippingStateCodeByState = getDependentOptionsImpl(User.statecode, User.countrycode, OrderCountry, OrderState);
            
            
            System.debug('OrderState code: ' + shippingStateCodeByState.get(OrderCountry));
            mcShipment.zkmulti__Recipient_State_Province__c = shippingStateCodeByState.ContainsKey(OrderCountry) ? (shippingStateCodeByState.get(OrderCountry).ContainsKey(OrderState) ? shippingStateCodeByState.get(OrderCountry).get(OrderState) : '') : '';
            mcShipment.zkmulti__Recipient_Zip_Postal_Code__c = (row.getDataCells()[columnIndexByColumnName.get('ORDER_SHIPPING_ZIP')].getLabel()).replace(' ','');    
            mcShipment.zkmulti__Recipient_Country__c = countryMap.containskey(OrderCountry.toUpperCase()) ? countryMap.get(OrderCountry.toUpperCase()):'';
            mcShipment.zkmulti__Recipient_Email__c = row.getDataCells()[columnIndexByColumnName.get('ORDER_SHIPPING_EMAIL')].getLabel();
            String ShipToContactName = row.getDataCells()[columnIndexByColumnName.get('ORDER_SHIPPING_FIRST_NAME')].getLabel() + ' ' + row.getDataCells()[columnIndexByColumnName.get('ORDER_SHIPPING_LAST_NAME')].getLabel();
            mcShipment.zkmulti__Recipient_Name__c = ShipToContactName != null && ShipToContactName.length() >35 ? ShipToContactName.substring(0,35) : ShipToContactName;            
            mcShipment.zkmulti__Recipient_Phone__c = row.getDataCells()[columnIndexByColumnName.get('ORDER_SHIPPING_PHONE')].getLabel();
            
            // Other
            mcShipment.PriceBook__c = bulkShipment.PriceBook__c; 
            mcShipmentsToInsert.add(mcShipment); 
        }
        
        if(mcShipmentsToInsert.size()>0){
            Utility.processRecords(mcShipmentsToInsert, 'insert');           
        }
        System.debug('mcShipmentsToInsert: '+mcShipmentsToInsert);
        
        List<zkmulti__MCShipment_Special_Services__c> mcSpecialServiceToInsert = new List<zkmulti__MCShipment_Special_Services__c>();         
        for (zkmulti__MCShipment__c mcShipment : mcShipmentsToInsert) {
            // Create Shipment Special Services
            Reports.ReportDetailRow row = mapOfRowsByOrderId.get(mcShipment.Order__c);
            
            if(mcShipment.zkmulti__Carrier__c == 'UPS'){
                zkmulti__MCShipment_Special_Services__c shipmentSS  = new zkmulti__MCShipment_Special_Services__c (
                    zkmulti__Shipment__c = mcShipment.Id,                    
                    zkmulti__SignatureReleaseNumber__c = mcShipment.Order__c                                                
                );

                if(bulkshipment.Signature_Required__c == true && !isUPSPackageDeliveryConfirmationIsSupported(mcShipment)){
                    shipmentSS.zkmulti__DeliveryConfirmation__c = true;
                    shipmentSS.zkmulti__SelectedSignatureOption__c = 'SIGNATURE_REQUIRED';
                }

                mcSpecialServiceToInsert.add(shipmentSS);
            }   
            
            //One Rate special Service //VKHOPADE - issue 1172 - start
            if(mcShipment.zkmulti__Carrier__c == 'FedEx'){ 
                if(mcShipment.zkmulti__Recipient_Country__c == 'US' && mcShipment.zkmulti__Sender_Country__c == 'US'){
                	zkmulti__MCShipment_Special_Services__c shipmentSS  = new zkmulti__MCShipment_Special_Services__c (
                    zkmulti__Shipment__c = mcShipment.Id,                    
                    zkmulti__SignatureReleaseNumber__c = mcShipment.Order__c                                                
                	);
                    
                    if(isOneRatePackageType(mcShipment)){
                    	//shipmentSS.zkmulti__DeliveryConfirmation__c = true;
                    	shipmentSS.zkmulti__OneRate__c = true;    
                    }
                    if(bulkshipment.Signature_Required__c == true){ //VKHOPADE - #1203
                        shipmentSS.zkmulti__DeliveryConfirmation__c = true;
                        shipmentSS.zkmulti__SelectedSignatureOption__c = 'DIRECT'; //VKHOPADE - issue 1203
                    }
                    mcSpecialServiceToInsert.add(shipmentSS);
                }
                else if (bulkshipment.Signature_Required__c == true){  //VKHOPADE - issue 1203 - start
                    zkmulti__MCShipment_Special_Services__c shipmentSS  = new zkmulti__MCShipment_Special_Services__c (
                    zkmulti__Shipment__c = mcShipment.Id,                    
                    zkmulti__SignatureReleaseNumber__c = mcShipment.Order__c
                    );
                    //shipmentSS.zkmulti__DeliveryConfirmation__c = true;
                    shipmentSS.zkmulti__SelectedSignatureOption__c = 'DIRECT'; //VKHOPADE - issue 1203 - end
                }
            }
            //VKHOPADE - #1172 - end
        }
        if(mcSpecialServiceToInsert.size()>0){
            Utility.processRecords(mcSpecialServiceToInsert, 'insert');            
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
                //zkmulti__Packaging_Type__c = mcShipment.zkmulti__Package_Type__c,
                //zkmulti__Quantity__c = 1,
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
            Utility.processRecords(mcPackagesToInsert, 'insert');            
        }
        System.debug('mcPackagesToInsert: '+mcPackagesToInsert);
        System.debug('mapOrderLineItemsforCustomItems: '+mapOrderLineItemsforCustomItems);
        
        //For UPS
        List<zkmulti__MCCustoms_Item__c> customItemsToInsert = new List<zkmulti__MCCustoms_Item__c>();                
        Map<Integer,zkmulti__CommercialInvoice__c> mapCommercialInvoiceToInsert = new Map<Integer,zkmulti__CommercialInvoice__c>();
        Map<Integer,zkmulti__MCShipment__c> mapShipment = new Map<Integer,zkmulti__MCShipment__c>();
        Integer icount = 0;
        for (zkmulti__MCShipment__c qs : mcShipmentsToInsert) {
            if(qs.zkmulti__Carrier__c == 'UPS' || qs.zkmulti__Carrier__c == 'FedEx' || qs.zkmulti__Carrier__c == 'DHL Express'){ //VKHOPADE #1149 - added for FedEx
                // Create Custom Items
                if(mapOrderLineItemsforCustomItems.size()>0){
                    for(string count: mapOrderLineItemsforCustomItems.keyset()){
                        System.debug('count: '+count);
                        if(count.split('###')[1] == qs.Order__c){                        
                            zkmulti__MCCustoms_Item__c customItem = new zkmulti__MCCustoms_Item__c();
                            if(mapOrderLineItemsforCustomItems.containskey(count) && mapOrderLineItemsforCustomItems.get(count) != null){
                                customItem.zkmulti__Weight__c = mapOrderLineItemsforCustomItems.get(count).get('Weight') != null && mapOrderLineItemsforCustomItems.get(count).get('Weight') != '-' ? double.valueof(mapOrderLineItemsforCustomItems.get(count).get('Weight')) : null;
                                customItem.zkmulti__Harmonized_Code__c = mapOrderLineItemsforCustomItems.get(count).get('Harmonized Code') != null ? string.valueof(mapOrderLineItemsforCustomItems.get(count).get('Harmonized Code')) : '';
                                customItem.zkmulti__Quantity__c = mapOrderLineItemsforCustomItems.get(count).get('Quantity') != null && mapOrderLineItemsforCustomItems.get(count).get('Quantity') != '-' ? double.valueof(mapOrderLineItemsforCustomItems.get(count).get('Quantity')) : null;
                                customItem.zkmulti__Value__c = mapOrderLineItemsforCustomItems.get(count).get('Unit Price') != null && mapOrderLineItemsforCustomItems.get(count).get('Unit Price') != '-' ? double.valueof(mapOrderLineItemsforCustomItems.get(count).get('Unit Price'))*double.valueof(mapOrderLineItemsforCustomItems.get(count).get('Quantity')): null;
                                customItem.zkmulti__Description__c = mapOrderLineItemsforCustomItems.get(count).get('Description') != null ? string.valueof(mapOrderLineItemsforCustomItems.get(count).get('Description')) : '';
                                customItem.zkmulti__UnitPrice__c = mapOrderLineItemsforCustomItems.get(count).get('Unit Price') != null && mapOrderLineItemsforCustomItems.get(count).get('Unit Price') != '-' ? double.valueof(mapOrderLineItemsforCustomItems.get(count).get('Unit Price')): null;
                            }
                            customItem.zkmulti__Weight_Units__c = 'LB';
                            customItem.zkmulti__QuantityUnits__c  = 'EA'; //VKHOPADE #1149 - added for FedEx International
                            if(qs.zkmulti__Carrier__c == 'DHL Express')
                            	customItem.zkmulti__QuantityUnits__c  = '2no';
                            
                            customItem.zkmulti__NumberOfPieces__c = 1;	  //VKHOPADE #1149 - added for FedEx International
                            customItem.zkmulti__Country_of_Manufacture__c = 'US';                
                            customItem.zkmulti__Value_Currency__c = 'USD';                  
                            customItem.zkmulti__Shipment__c = qs.Id;
                            customItem.zkmulti__Carrier__c = qs.zkmulti__Carrier__c;
                            customItem.zkmulti__UnitOfMeasurement__c = 'Each';                 
                            customItem.zkmulti__UnitPriceCurrency__c = 'USD';                
                            customItemsToInsert.add(customItem);
                        }
                    }  

                    // Create Commercial Invoices
                    zkmulti__CommercialInvoice__c mcCommercialInvoice  = new zkmulti__CommercialInvoice__c();                
                    mcCommercialInvoice.zkmulti__InvoiceDate__c = System.today();               
                    mcCommercialInvoice.zkmulti__Carrier__c = qs.zkmulti__Carrier__c;
                    mcCommercialInvoice.zkmulti__OriginatorName__c = qs.zkmulti__Sender_Name__c;
                    mcCommercialInvoice.zkmulti__ReasonForExport__c = 'Sample';
                    system.debug('###mapOrderAmount11=='+mapOrderAmount);
                    String orderId = string.valueof(qs.Order__c).substring(0,15);
                    if(mapOrderAmount.containskey(orderId) && mapOrderAmount.get(orderId) != null){
                        system.debug('###mapOrderAmount22=='+mapOrderAmount);
                        if(mapOrderAmount.get(orderId)<=2500){
                         mcCommercialInvoice.zkmulti__Comments__c = 'Goods qualify under the USMCA';
                        }
                    }
                    mapCommercialInvoiceToInsert.put(icount,mcCommercialInvoice);
                    mapShipment.put(icount,qs);
                    icount++;
                }                
            }
            
        }
        
        if(customItemsToInsert.size()>0){
            Utility.processRecords(customItemsToInsert, 'insert');            
        }
        System.debug('###customItemsToInsert=='+customItemsToInsert);
        
        if(mapCommercialInvoiceToInsert.size()>0){
            Utility.processRecords(mapCommercialInvoiceToInsert.values(), 'insert');                       
        }        
        System.debug('###mapCommercialInvoiceToInsert.values()=='+mapCommercialInvoiceToInsert.values());
        System.debug('###mapShipment=='+mapShipment);
        
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
            Utility.processRecords(lstRequestedShipmentDocuments, 'insert');
        }             
        System.debug('###lstRequestedShipmentDocuments=='+lstRequestedShipmentDocuments); 
        
         //To update commercial Invoice for existing Shipment
        List<zkmulti__MCCustoms_Item__c> newcustomItemsToInsert = new List<zkmulti__MCCustoms_Item__c>();            
        Map<Id,zkmulti__RequestedShipmentDocuments__c> mapRequestedShipmentDocToupdate = new Map<Id,zkmulti__RequestedShipmentDocuments__c>();           
        for (zkmulti__MCShipment__c qs : mapexistingShipmentsforOrders.values()) {                               
            if(qs != null && (qs.zkmulti__Carrier__c == 'UPS')){
                // Create Custom Items
                if(mapexistingCustomItems.size()>0){
                    for(string strcount: mapexistingCustomItems.keyset()){
                        System.debug('strcount: '+strcount);
                        if(strcount.split('###')[1] == qs.Order__c){                        
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
    
    /**
    * @description  : Finish method of batch apex
    * @author       : kchavda@addonblue.com
    * @param        : Database.BatchableContext
    * @return       : void 
    **/
    public void finish(Database.BatchableContext info) {
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
            Utility.processRecords(bulkShipment, 'update');                       
        }
    }
    
    
    /**
    * @description  : To get dependent state value based on country value
    * @author       : kchavda@addonblue.com
    * @param        : Schema.SObjectField, Schema.SObjectField, string, string
    * @return       : Map<String, Map<String, String>>
    **/
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
    
    /**
    * @description  : To check UPS Package Delivery Confirmation Support
    * @author       : kchavda@addonblue.com
    * @param        : zkmulti__MCShipment__c
    * @return       : Boolean 
    **/
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
    
     /**
    * @description  : To check package types eligible for FedEx One Rate service
    * @author       : vaibhav.khopade@addonblue.com
    * @param        : zkmulti__MCShipment__c
    * @return       : Boolean 
    **/
    //VKHOPADE issue 1172
    public static boolean isOneRatePackageType(zkmulti__MCShipment__c shipment){
        if(shipment.zkmulti__Package_Type__c == 'FEDEX_ENVELOPE' || shipment.zkmulti__Package_Type__c == 'FEDEX_SMALL_BOX' || shipment.zkmulti__Package_Type__c == 'FEDEX_MEDIUM_BOX' || shipment.zkmulti__Package_Type__c == 'FEDEX_LARGE_BOX' || shipment.zkmulti__Package_Type__c == 'FEDEX_EXTRA_LARGE_BOX' || shipment.zkmulti__Package_Type__c == 'FEDEX_TUBE' || shipment.zkmulti__Package_Type__c == 'FEDEX_PAK')
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    
     /**
    * @description  : Convert decimal to binary representation
    * @author       : kchavda@addonblue.com
    * @param        : Integer
    * @return       : String  
    **/
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    
    /**
    * @description  : Convert a base64 token into a binary/bits representation
    * @author       : kchavda@addonblue.com
    * @param        : String 
    * @return       : String  
    **/
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
    
     /**
    * @description  : Deserialize picklist entries
    * @author       : kchavda@addonblue.com
    * @param        : List<Schema.PicklistEntry>
    * @return       : List<PicklistEntryWrapper>  
    **/
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    
    /**
    * @description  : Wrapper class for picklist
    * @author       : kchavda@addonblue.com
    * @param        : 
    * @return       :   
    **/
    public class PicklistEntryWrapper {
        public String active {get; set;}
        public String defaultValue {get; set;}
        public String label {get; set;}
        public String value {get; set;}
        public String validFor {get; set;}
    }
    
}
/**
* @File Name          : GenerateShippingLabelsUPSTest.cls
* @Description        : This class is used to test generate shipping lables for UPS shipping.
* @Author             : kchavda@addonblue.com

* @Last Modified By   : kchavda@addonblue.com
* @Last Modified On   : 03/23/2020
* @Modification Log   : 
* Ver       Date            Author               Modification
* 1.0       03/23/2020      kchavda              Initial Version
* 1.1       09/02/2020  kchavda@addonblue.com    #492 Shipping Label V2 and V3 logic change
**/
@Istest

public class GenerateShippingLabelsUPSTest{          
    
    /**
    * @description  : Test Method
    * @author       : kchavda@addonblue.com
    * @param        : void
    * @return       :  
    **/
     public static testmethod void GenerateShippingLabels() {
         
        TestDataFactory.createTriggerSettingsEntry();  
         
        // Create Shipment Preferene to use with Bulk Shipment record
        TestDataFactory.createMCShipmatePreference();
        
        // Insert bulk shipment
        zkmulti__MCBulk_Shipment__c objBulkShip = new zkmulti__MCBulk_Shipment__c();
        objBulkShip = TestDataFactory.createMCBulkShipment();
        objBulkShip.Signature_Required__c = true;
        Utility.processRecords(objBulkShip, 'update');        
        
        product2 objProd = TestDataFactory.createProduct(1,'Product',Test.getStandardPricebookId(),false)[0];
        objProd.Commodity_Harmonized_Code__c = '35675dsfdg';
        objProd.Commodity_Unit_Price__c = 50;
        objProd.Commodity_Weight__c = 2.0;
        objProd.Commodity_Description__c = 'testcomdesc';
        insert objProd;
       
        Product2 prod = [select id,Price__c,CurrencyIsoCode from product2 where id =: objProd.id];  
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod,Test.getStandardPricebookId());
        insert pbe;
        
        Quote qut = TestDataFactory.createQuote();
        QuoteLineItem QLI = TestDataFactory.createQuoteLineItem(qut.id,pbe.id,'Product','','',true);
        
        quote objquote = [select id,opportunityId,Opportunity.Primary_Contact__c from quote where id =: qut.id];
        Order odr = TestDataFactory.createOrder(1,objquote.opportunityId,objquote.id,objquote.Opportunity.Primary_Contact__c,Test.getStandardPricebookId())[0];
        OrderItem odi = TestDataFactory.createOrderItem(1,odr.id,QLI)[0];
        
       // Custom settings to get report id        
        ZK_Print_Labels_Settings__c objPrintLabel = new ZK_Print_Labels_Settings__c();
        objPrintLabel = TestDataFactory.createZKPrintLabelsSettings();        
        String reportId = GenerateShippingLabelsUPS.toGetReportId(objBulkShip.id);
        System.assertEquals(objPrintLabel.Masterspread_Report_Id__c,reportId);  
        GenerateShippingLabelsUPS.generateShippingLabels(GenerateShippingLabelsUPS.toGetBulkshipment(objBulkShip.id),reportId);

     }


         public static testmethod void GenerateShippingLabelsFedEx() {
         
        TestDataFactory.createTriggerSettingsEntry();  
         
        // Create Shipment Preferene to use with Bulk Shipment record
        //TestDataFactory.createMCShipmatePreference();
        List<zkmulti__MCShipmate_Preference__c> lstMCShipmatePreference = new List<zkmulti__MCShipmate_Preference__c>();
        zkmulti__MCShipmate_Preference__c objMCShipmatePreference = new zkmulti__MCShipmate_Preference__c(
            zkmulti__Shipping_Street__c = 'Test Strret',
            zkmulti__Shipping_State__c = 'CA',
            zkmulti__Shipping_Is_Residential__c = true,
            zkmulti__Shipping_Zip_Postal_Code__c = '45214',
            zkmulti__Shipping_Country__c = 'US',
            zkmulti__Shipping_City__c = 'CA',
            zkmulti__Carrier__c = 'FedEx'
            );
            lstMCShipmatePreference.add(objMCShipmatePreference);
        	lstMCShipmatePreference = Utility.processRecords(lstMCShipmatePreference, 'insert');
        
        
        // Insert bulk shipment
        zkmulti__MCBulk_Shipment__c objBulkShip = new zkmulti__MCBulk_Shipment__c();
        //objBulkShip = TestDataFactory.createMCBulkShipment();
        List<zkmulti__MCBulk_Shipment__c> lstMCBulkShipment = new List<zkmulti__MCBulk_Shipment__c>();
        zkmulti__MCBulk_Shipment__c objMCBulkShipment = new zkmulti__MCBulk_Shipment__c(
            Processed__c = false,
            PriceBook__c = TestDataFactory.createPricebook().id,
            zkmulti__Shipmate_Preference__c = lstMCShipmatePreference[0].id
        );
        lstMCBulkShipment.add(objMCBulkShipment);
        lstMCBulkShipment = Utility.processRecords(lstMCBulkShipment, 'insert');
        objBulkShip = lstMCBulkShipment[0];
        
        objBulkShip.Signature_Required__c = true;
        Utility.processRecords(objBulkShip, 'update');        
        
        product2 objProd = TestDataFactory.createProduct(1,'Product',Test.getStandardPricebookId(),false)[0];
        objProd.Commodity_Harmonized_Code__c = '35675dsfdg';
        objProd.Commodity_Unit_Price__c = 50;
        objProd.Commodity_Weight__c = 2.0;
        objProd.Commodity_Description__c = 'testcomdesc';
        insert objProd;
       
        Product2 prod = [select id,Price__c,CurrencyIsoCode from product2 where id =: objProd.id];  
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod,Test.getStandardPricebookId());
        insert pbe;
        
        Quote qut = TestDataFactory.createQuote();
        QuoteLineItem QLI = TestDataFactory.createQuoteLineItem(qut.id,pbe.id,'Product','','',true);
        
        quote objquote = [select id,opportunityId,Opportunity.Primary_Contact__c from quote where id =: qut.id];
        Order odr = TestDataFactory.createOrder(1,objquote.opportunityId,objquote.id,objquote.Opportunity.Primary_Contact__c,Test.getStandardPricebookId())[0];
        OrderItem odi = TestDataFactory.createOrderItem(1,odr.id,QLI)[0];
        
       // Custom settings to get report id        
        ZK_Print_Labels_Settings__c objPrintLabel = new ZK_Print_Labels_Settings__c();
        objPrintLabel = TestDataFactory.createZKPrintLabelsSettings();        
        String reportId = GenerateShippingLabelsUPS.toGetReportId(objBulkShip.id);
        System.assertEquals(objPrintLabel.Masterspread_Report_Id__c,reportId);  
        GenerateShippingLabelsUPS.generateShippingLabels(GenerateShippingLabelsUPS.toGetBulkshipment(objBulkShip.id),reportId);

     }
    
    //VKHOPADE - issue 1177 - added below function
    public static testmethod void GenerateShippingLabelsDHL() {
         
        TestDataFactory.createTriggerSettingsEntry();  
         
        // Create Shipment Preferene to use with Bulk Shipment record
        //TestDataFactory.createMCShipmatePreference();
        List<zkmulti__MCShipmate_Preference__c> lstMCShipmatePreference = new List<zkmulti__MCShipmate_Preference__c>();
        zkmulti__MCShipmate_Preference__c objMCShipmatePreference = new zkmulti__MCShipmate_Preference__c(
            zkmulti__Shipping_Street__c = 'Test Strret',
            zkmulti__Shipping_State__c = 'CA',
            zkmulti__Shipping_Is_Residential__c = true,
            zkmulti__Shipping_Zip_Postal_Code__c = '45214',
            zkmulti__Shipping_Country__c = 'US',
            zkmulti__Shipping_City__c = 'CA',
            zkmulti__Carrier__c = 'DHL Express'
            );
            lstMCShipmatePreference.add(objMCShipmatePreference);
        	lstMCShipmatePreference = Utility.processRecords(lstMCShipmatePreference, 'insert');
        
        
        // Insert bulk shipment
        zkmulti__MCBulk_Shipment__c objBulkShip = new zkmulti__MCBulk_Shipment__c();
        //objBulkShip = TestDataFactory.createMCBulkShipment();
        List<zkmulti__MCBulk_Shipment__c> lstMCBulkShipment = new List<zkmulti__MCBulk_Shipment__c>();
        zkmulti__MCBulk_Shipment__c objMCBulkShipment = new zkmulti__MCBulk_Shipment__c(
            Processed__c = false,
            PriceBook__c = TestDataFactory.createPricebook().id,
            zkmulti__Shipmate_Preference__c = lstMCShipmatePreference[0].id
        );
        lstMCBulkShipment.add(objMCBulkShipment);
        lstMCBulkShipment = Utility.processRecords(lstMCBulkShipment, 'insert');
        objBulkShip = lstMCBulkShipment[0];
        
        objBulkShip.Signature_Required__c = true;
        Utility.processRecords(objBulkShip, 'update');        
        
        product2 objProd = TestDataFactory.createProduct(1,'Product',Test.getStandardPricebookId(),false)[0];
        objProd.Commodity_Harmonized_Code__c = '35675dsfdg';
        objProd.Commodity_Unit_Price__c = 50;
        objProd.Commodity_Weight__c = 2.0;
        objProd.Commodity_Description__c = 'testcomdesc';
        insert objProd;
       
        Product2 prod = [select id,Price__c,CurrencyIsoCode from product2 where id =: objProd.id];  
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod,Test.getStandardPricebookId());
        insert pbe;
        
        Quote qut = TestDataFactory.createQuote();
        QuoteLineItem QLI = TestDataFactory.createQuoteLineItem(qut.id,pbe.id,'Product','','',true);
        
        quote objquote = [select id,opportunityId,Opportunity.Primary_Contact__c from quote where id =: qut.id];
        Order odr = TestDataFactory.createOrder(1,objquote.opportunityId,objquote.id,objquote.Opportunity.Primary_Contact__c,Test.getStandardPricebookId())[0];
        OrderItem odi = TestDataFactory.createOrderItem(1,odr.id,QLI)[0];
        
       // Custom settings to get report id        
        ZK_Print_Labels_Settings__c objPrintLabel = new ZK_Print_Labels_Settings__c();
        objPrintLabel = TestDataFactory.createZKPrintLabelsSettings();        
        String reportId = GenerateShippingLabelsUPS.toGetReportId(objBulkShip.id);
        System.assertEquals(objPrintLabel.Masterspread_Report_Id__c,reportId);  
        GenerateShippingLabelsUPS.generateShippingLabels(GenerateShippingLabelsUPS.toGetBulkshipment(objBulkShip.id),reportId);

     }
}
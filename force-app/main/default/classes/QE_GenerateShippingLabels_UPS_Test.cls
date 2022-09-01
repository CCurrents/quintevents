/**
 * @description       : 
 * @author            : jagrawal@addonblue.com
 * @group             : 
 * @last modified on  : 09-07-2020
 * @last modified by  : jagrawal@addonblue.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   09-07-2020   jagrawal@addonblue.com   Initial Version
**/
@isTest
public class QE_GenerateShippingLabels_UPS_Test {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }
    public static testmethod void GenerateShippingLabels() {
        // Event
        QE360_Event__c testEvent = new QE360_Event__c(Name='mexico');
        insert testEvent;
        // Create Shipment Preferene to use with Bulk Shipment record
        zkmulti__MCShipmate_Preference__c objMCShip = new zkmulti__MCShipmate_Preference__c();
        objMCShip.zkmulti__Shipping_Street__c = 'Test Strret';
        objMCShip.zkmulti__Shipping_State__c = 'CA';
        objMCShip.zkmulti__Shipping_Is_Residential__c = true;
        objMCShip.zkmulti__Shipping_Zip_Postal_Code__c = '45214';
        objMCShip.zkmulti__Shipping_Country__c = 'US';
        objMCShip.zkmulti__Shipping_City__c = 'CA';
        objMCShip.zkmulti__Carrier__c = 'FedEx';
        insert objMCShip;
        // Insert bulk shipment
        zkmulti__MCBulk_Shipment__c objBulkShip = new zkmulti__MCBulk_Shipment__c();
        objBulkShip.Processed__c = false;
        objBulkShip.Event__c = testEvent.id;
        objBulkShip.zkmulti__Shipmate_Preference__c = objMCShip.id;
        insert objBulkShip;
        // Custom settings to get report id
        ZK_Print_Labels_Settings__c objPrintLabel = new ZK_Print_Labels_Settings__c();
        objPrintLabel.FedEx_Shipmate_Preference_Id__c = objMCShip.id;
        objPrintLabel.Masterspread_V2_Report_Id__c  = '00O1Y000006dZKs'; //(production test report '00O1Y000006dZKs') '00OW0000000QPzk'; (qenewdev sandbox test report)  
        insert objPrintLabel;
        // Ren class methods on bulk shipment
        ApexPages.currentPage().getParameters().put('bulkshipmentid',objBulkShip.id);
        QE_GenerateShippingLabels_UPS objQG = new QE_GenerateShippingLabels_UPS();
        objQG.generateShippingLabels();
        objQG.redirectToBulkShipmentDetailPage();
    }
    public static testmethod void GenerateShippingLabels1() {
        // Event
        QE360_Event__c testEvent = new QE360_Event__c(Name='mexico');
        insert testEvent;
        // Create Shipment Preferene to use with Bulk Shipment record
        zkmulti__MCShipmate_Preference__c objMCShip = new zkmulti__MCShipmate_Preference__c();
        objMCShip.zkmulti__Shipping_Street__c = 'Test Strret';
        objMCShip.zkmulti__Shipping_State__c = 'CA';
        objMCShip.zkmulti__Shipping_Is_Residential__c = true;
        objMCShip.zkmulti__Shipping_Zip_Postal_Code__c = '45214';
        objMCShip.zkmulti__Shipping_Country__c = 'US';
        objMCShip.zkmulti__Shipping_City__c = 'CA';
        objMCShip.zkmulti__Carrier__c = 'UPS';
        insert objMCShip;
        // Insert bulk shipment
        zkmulti__MCBulk_Shipment__c objBulkShip = new zkmulti__MCBulk_Shipment__c();
        objBulkShip.Processed__c = false;
        objBulkShip.Event__c = testEvent.id;
        objBulkShip.zkmulti__Shipmate_Preference__c = objMCShip.id;
        insert objBulkShip;
        // Custom settings to get report id
        ZK_Print_Labels_Settings__c objPrintLabel = new ZK_Print_Labels_Settings__c();
        objPrintLabel.FedEx_Shipmate_Preference_Id__c = objMCShip.id;
        objPrintLabel.Masterspread_V2_Report_Id__c = '00O1Y000006dZKs'; //(production test report '00O1Y000006dZKs') '00OW0000000QPzk'; (qenewdev sandbox test report)  
        insert objPrintLabel;
        
        product2 objProd = TestDataFactory.createProduct(1,'Product',Test.getStandardPricebookId(),false)[0];
        objProd.Commodity_Harmonized_Code__c = '35675dsfdg';
        objProd.Commodity_Unit_Price__c = 50;
        objProd.Commodity_Weight__c = 2.0;
        objProd.Commodity_Description__c = 'testcomdesc';
        insert objProd;
       
        Opportunity opp = TestDataFactory.createOpportunity();
        
        Product2 prod = [select id,Price__c,CurrencyIsoCode from product2 where id =: objProd.id];  
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod,Test.getStandardPricebookId());
        insert pbe;
        
        OpportunityLineItem objoppLineItem = new OpportunityLineItem(
            OpportunityId = opp.id,
            TotalPrice = 100,
            Quantity = 3,
            ListPrice_Used__c = 10,
            PricebookEntryId = pbe.Id
        );
        insert objoppLineItem;
        // Ren class methods on bulk shipment
        ApexPages.currentPage().getParameters().put('bulkshipmentid',objBulkShip.id);
        QE_GenerateShippingLabels_UPS objQG = new QE_GenerateShippingLabels_UPS();
        objQG.generateShippingLabels();
        objQG.redirectToBulkShipmentDetailPage();
        
        objBulkShip.Processed__c = true;
        update objBulkShip;
        objQG.generateShippingLabels();
    }
    
}
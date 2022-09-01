@isTest
public class QE_GenerateShippingLabelsTest {

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
        objPrintLabel.Masterspread_Report_Id__c = '00O1Y000006dZKs'; //(production test report '00O1Y000006dZKs') '00OW0000000QPzk'; (qenewdev sandbox test report)  
        insert objPrintLabel;
        // Ren class methods on bulk shipment
        ApexPages.currentPage().getParameters().put('bulkshipmentid',objBulkShip.id);
        QE_GenerateShippingLabels objQG = new QE_GenerateShippingLabels();
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
        objPrintLabel.Masterspread_Report_Id__c = '00O1Y000006dZKs'; //(production test report '00O1Y000006dZKs') '00OW0000000QPzk'; (qenewdev sandbox test report)  
        insert objPrintLabel;
        // Ren class methods on bulk shipment
        ApexPages.currentPage().getParameters().put('bulkshipmentid',objBulkShip.id);
        QE_GenerateShippingLabels objQG = new QE_GenerateShippingLabels();
        objQG.generateShippingLabels();
        objQG.redirectToBulkShipmentDetailPage();
        
        objBulkShip.Processed__c = true;
        update objBulkShip;
        objQG.generateShippingLabels();
    }
    
}
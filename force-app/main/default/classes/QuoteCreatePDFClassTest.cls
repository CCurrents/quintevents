/**
 * @File Name          : QuoteCreatePDFClassTest.cls
 * @Description        : test class for the QuoteCreatePDFClass controller
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 04/24/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    04/24/2020    mpatel@addonblue.com       Initial Version
**/  
@isTest
private with sharing class QuoteCreatePDFClassTest {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void quotePdfTestExecution() {
        
        TestDataFactory.createSFDCIntacctMapping();
        QuoteLineItem quotelitem = TestDataFactory.createQuoteLineItem();
        /*Quote_Product_Package_Hotel__c qpph = new Quote_Product_Package_Hotel__c();
        qpph.Quote__c = quotelitem.QuoteId;
        qpph.Hotel__c = quotelitem.Product2Id;
        Utility.processRecords(qpph, 'insert');*/
        
        QE360_Quote_Additional_Signee__c quoteSine = new QE360_Quote_Additional_Signee__c();
        quoteSine.Quote_Standard__c = quotelitem.quoteId;
        quoteSine.Amount__c = 7384;
        Utility.processRecords(quoteSine, 'insert');
        
        Products_Bundle__c bf = new Products_Bundle__c();
        bf.Parent_Product__c = quotelitem.Product2Id;
        Utility.processRecords(bf, 'insert');
        
        PageReference pageRef = Page.QE360V3_QuoteCreatePDFPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',quotelitem.quoteId);
        ApexPages.StandardController sc = new ApexPages.StandardController(quotelitem);
        QE360V3_QuoteCreatePDFClass qcpc = new QE360V3_QuoteCreatePDFClass(sc);
        Test.startTest();
        qcpc.getHotelTransportationFromQuote();
        //qcpc.getQuotePackageList();
        qcpc.getQuotePackageAndPackageIdMap();
        qcpc.getQuotePackageCount();
        //qcpc.getQuotePackageProductMap();
        qcpc.getQuoteALaCarteCount();
        qcpc.getTotalShippingAndHandling();
        qcpc.getTotalTax();
        qcpc.getCCFeeAmount();
        qcpc.getQuoteAdditionalSignees();
        qcpc.getAmountPortionForMainClient();
        qcpc.getQuotePackageHotels();
        qcpc.getOpportunityPaymentTerms();
        Test.stopTest();
    }
}
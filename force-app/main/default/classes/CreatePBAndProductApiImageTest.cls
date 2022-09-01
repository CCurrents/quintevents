/**
 * @File Name          : CreatePBAndProductApiImageTest.cls
 * @Description        : 
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 9/4/2020, 3:23:57 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    13/4/2020   mpatel@addonblue.com     Initial Version
**/
@isTest
private with sharing class CreatePBAndProductApiImageTest {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void apiImageFirstTestExecution() {
        Product2 product = TestDataFactory.createProduct();
        PriceBook2 pricebook = TestDataFactory.createPricebook();
        CreatePBAndProductApiImage.getApiImageData(product.Id);
        CreatePBAndProductApiImage.getRecordType(pricebook.Id);
        CreatePBAndProductApiImage.getRecordType(product.Id);
        CreatePBAndProductApiImage.deleteRecord(product.Id,product.Id);
        System.assert(true, pricebook.Id != null);
    }
}
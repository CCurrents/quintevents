/**
 * @File Name          : APIImageTriggerHelperTest.cls
 * @Description        : 
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 28/2/2020
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    09/17/2020   mpatel@addonblue.com     Initial Version
**/
@isTest public with sharing class APIImageTriggerHelperTest {
    
    @isTest static void testMethod_one() {
        TestDataFactory.createTriggerSettingsEntry();
        Trigger_Settings__c objTriggerSetting = new Trigger_Settings__c();
        objTriggerSetting.Name = 'API_Image__c';
        objTriggerSetting.Max_Loop_Count__c = 1;
        Utility.processRecords(objTriggerSetting, 'insert');
        
        Api_Image__c image = new Api_Image__c();
        image.RecordTypeId = Schema.SObjectType.Api_Image__c.getRecordTypeInfosByName().get('Image for Event').getRecordTypeId();
        insert image;
        delete image;
        
    }    
}
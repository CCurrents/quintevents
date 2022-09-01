/**
* @File Name          : PostRefreshActivitiesTest.cls
* @Description        : 
* @Author             : jagrawal@addonblue.com
* @Group              : 
* @Last Modified By   : jagrawal@addonblue.com
* @Last Modified On   : 11-30-2020
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    6/16/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest public with sharing class PostRefreshActivitiesTest {
    
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        TestDataFactory.createAccount();
    }
    
    @isTest static void test1(){
        
        
        Slack_API_Detail__c objSAD = new Slack_API_Detail__c();
        objSAD.Accounting_Channel__c = 'Test';
        objSAD.Corp_Sales_Approvals_Channel__c = 'Test';
        objSAD.EGP_Approvals_Channel__c = 'Test';
        objSAD.H4H_Approvals_Channel__c = 'Test';
        objSAD.Operations_Channel__c = 'Test';
        objSAD.Sales_Approvals_Channel__c = 'Test';
        objSAD.Sales_Channel__c = 'Test';
        objSAD.Slack_API_Token__c = 'Test';
        objSAD.Slack_Client_Id__c = 'Test';
        objSAD.Slack_Client_Secret__c = 'Test';
        objSAD.Slack_Scope__c = 'Test';
        insert objSAD;
        ByPass_Rules__c objBypassRules = new ByPass_Rules__c();
        objBypassRules.Outbound_Messages__c = true;
        insert objBypassRules;
        Map<String, Object> metadataFieldValueMap = new Map<String, Object>();
        CustomMetadataUtils.createCustomMetadata('Integration_Setting__mdt', 'Intacct', metadataFieldValueMap);
        
        CustomMetadataUtils.updateCustomMetadata('Integration_Setting__mdt','Intacct', 'Intacct',metadataFieldValueMap);
        MetadataAPIUtility.createCustomLabel('GPE_Endpoint','GPE Endpoin','en_US','qeadmin@addonblue.com,jpatel@addonblue.com,jagrawal@addonblue.com',false);
        MetadataAPIUtility.updateCustomLabel('GPE_Endpoint','GPE Endpoint','en_US','qeadmin@addonblue.com,jpatel@addonblue.com,jagrawal@addonblue.com',false);
        //CustomMetadataUtils.createCustomMetadata('Integration_Setting__mdt', 'Xero', metadataFieldValueMap);
        
        Test.startTest();
        Test.testSandboxPostCopyScript(new PostRefreshActivities(), UserInfo.getOrganizationId(), UserInfo.getOrganizationId(), UserInfo.getOrganizationName());
        
        Test.stopTest();
        
    }
    
    @IsTest
    static void testMyCallback() {
        
        // Instantiate the callback.
        Metadata.DeployCallback callback = new CustomMetadataUtils();
        
        // Create test result and context objects.
        Metadata.DeployResult result = new Metadata.DeployResult();
        result.numberComponentErrors = 1;
        Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();
        
        // Invoke the callback's handleResult method.
        callback.handleResult(result, context);
    }
    
}
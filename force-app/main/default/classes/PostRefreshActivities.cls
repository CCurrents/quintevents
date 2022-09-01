/**
* @File Name          : PostRefreshActivities.cls
* @Description        : 
* @Author             : jagrawal@addonblue.com
* @Group              : 
* @Last Modified By   : jagrawal@addonblue.com
* @Last Modified On   : 12-12-2020
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    6/16/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class PostRefreshActivities implements SandboxPostCopy {
    
    public void runApexClass(SandboxContext context) {
        
        //Step -1 Comment all the triggers
        System.debug('===================Step-1 Comment all the triggers===================');
        List<Trigger_Settings__c> lstTriggerSettings = Trigger_Settings__c.getAll().values();
        for(Trigger_Settings__c objTS: lstTriggerSettings){
            objTS.Deactivate__c = true;
        }
        update lstTriggerSettings;
        System.debug(LoggingLevel.INFO, 'lstTriggerSettings-'+lstTriggerSettings);
        ByPass_Rules__c objBypassRules = ByPass_Rules__c.getOrgDefaults();
        objBypassRules.Outbound_Messages__c = true;
        update objBypassRules;
        
        System.debug('===================Step-2 Remove PROD URLS from Custom Settings and Metadata===================');
        Slack_API_Detail__c objSAD = Slack_API_Detail__c.getOrgDefaults();
        objSAD.Accounting_Channel__c = '';
        objSAD.Corp_Sales_Approvals_Channel__c = '';
        objSAD.EGP_Approvals_Channel__c = '';
        objSAD.H4H_Approvals_Channel__c = '';
        objSAD.Operations_Channel__c = '';
        objSAD.Sales_Approvals_Channel__c = '';
        objSAD.Sales_Channel__c = '';
        objSAD.Slack_API_Token__c = '';
        objSAD.Slack_Client_Id__c = '457678512738.535848604849';
        objSAD.Slack_Client_Secret__c = '5ef281477ac91d4753de50493db262f1';
        // objSAD.Slack_Code__c = '';
        objSAD.Slack_Scope__c = 'chat:write:bot';
        update objSAD;
        System.debug(LoggingLevel.INFO, 'objSAD-'+objSAD);
        
        Map<String, Object> metadataFieldValueMap = new Map<String, Object>();
        metadataFieldValueMap.put('CompanyId__c', 'QuintEvents-sandbox');
        metadataFieldValueMap.put('Password__c', 'JhVHD0?KT29!S24s');
        metadataFieldValueMap.put('UserId__c', 'jpatel');
        
        CustomMetadataUtils.updateCustomMetadata('Integration_Setting__mdt','Intacct', 'Intacct',metadataFieldValueMap);
        metadataFieldValueMap.put('Password__c', 'admin@123');
        metadataFieldValueMap.put('UserId__c', 'lpanchal@addonblue.com');
        CustomMetadataUtils.updateCustomMetadata('Integration_Setting__mdt','Xero', 'Xero',metadataFieldValueMap);
        System.debug('SenderPassword__c@'+metadataFieldValueMap);

        MetadataAPIUtility.updateCustomLabel('Account_CC_email','Account CC email','en_US','qeadmin@addonblue.com,jpatel@addonblue.com,jagrawal@addonblue.com',false);
        MetadataAPIUtility.updateCustomLabel('Account_To_Email','Account To Email','en_US','qeadmin@addonblue.com,jpatel@addonblue.com,jagrawal@addonblue.com',false);
        MetadataAPIUtility.updateCustomLabel('Email_Notification','Email Notification','en_US','qeadmin@addonblue.com,jpatel@addonblue.com,jagrawal@addonblue.com',false);
        MetadataAPIUtility.updateCustomLabel('Email_to_Aaron','Email to Aaron','en_US','qeadmin@addonblue.com,jpatel@addonblue.com,jagrawal@addonblue.com',false);
        MetadataAPIUtility.updateCustomLabel('GPE_Endpoint','GPE Endpoint','en_US','qeadmin@addonblue.com,jpatel@addonblue.com,jagrawal@addonblue.com',false);
        
        System.debug('===================Step-3 Run Masking Batch class===================');
        
        Set<String> setObjectNames = new Set<String>{'Lead', 'Account', 'Contact', 'Opportunity', 'Quote', 'Order'};
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        for(String objApiName : setObjectNames){
            Map<String, Schema.SObjectField> objFieldsMap = gd.get(objApiName).getDescribe().fields.getMap();
            String emailFields = '';
            List<String> lstEmailFields = new List<String>();
            String phoneFields = '';
            List<String> lstPhoneFields = new List<String>();
            
            for(Schema.SObjectField field : objFieldsMap.values()){
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                if(fieldDescribe.isUpdateable()){
                    if(fieldDescribe.getType() == Schema.DisplayType.EMAIL){
                        lstEmailFields.add(fieldDescribe.getName());
                        //emailFields += fieldDescribe.getName() + ',';
                    }
                    if(fieldDescribe.getType() == Schema.DisplayType.PHONE){
                        lstPhoneFields.add(fieldDescribe.getName());
                        //phoneFields += fieldDescribe.getName() + ',';
                    }
                    if(fieldDescribe.getType() == Schema.DisplayType.STRING){
                        if(fieldDescribe.getLabel().contains('Email')){
                            lstEmailFields.add(fieldDescribe.getName());
                            //emailFields += fieldDescribe.getName() + ',';
                        }
                        else if(fieldDescribe.getLabel().contains('Phone')){
                            lstPhoneFields.add(fieldDescribe.getName());
                            //phoneFields += fieldDescribe.getName() + ',';
                        }
                    }
                    emailFields = String.join(lstEmailFields, ';'); //emailFields.removeEnd(',');
                    phoneFields = String.join(lstPhoneFields, ';'); //phoneFields.removeEnd(',');
                }
            }
            MaskCustomerEmailsAndPhoneBatch batch = new MaskCustomerEmailsAndPhoneBatch(emailFields, phoneFields, objApiName, null);
            Id batchJobId = Database.executeBatch(batch, 1);
            System.debug('===================Step-4 Run Masking Batch class===================');
            
        }
        
    }
}
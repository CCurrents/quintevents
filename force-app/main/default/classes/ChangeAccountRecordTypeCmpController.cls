/**
 * @File Name          : ChangeAccountRecordTypeCmpController.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 4/10/2020, 1:04:05 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/10/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class ChangeAccountRecordTypeCmpController {
    @AuraEnabled 
    public static Account getAccountDetails(String currentRecordId) { 
        Account objAccount = [select Id,Company_Name__pc,Name from Account where Id =: currentRecordId];
        return objAccount; 
    }
  
    @AuraEnabled 
    public static Account h4hHotelSearchAPICall(String currentRecordId, Account accDetails) {
        System.debug('accDetails-->'+accDetails);
        if(accDetails.Company_Name__pc != null && accDetails.Company_Name__pc != ''){
            Account objAccount = new Account();
            Id businessAccountRecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
            objAccount = new Account(Id = accDetails.id, RecordTypeId = businessAccountRecordTypeId);
            Utility.processRecords(objAccount, 'update');
            //different update call because more fields can not be changed in recordtype change
            objAccount.Name = accDetails.Company_Name__pc;
            Utility.processRecords(objAccount, 'update');
            
            return objAccount;
        } else {
            throw new AuraHandledException('Company name is required to convert business account.');
        }
    }
}
/**
* @File Name          : SearchAccountLeadController.cls
* @Description        : 
* @Author             : jthakkar@addonblue.com
* @Group              : 
* @Last Modified By   : jthakkar@addonblue.com
* @Last Modified On   : 5/08/2020, 4:07:16 PM
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    5/08/2020   jthakkar@addonblue.com     Initial Version
**/

@isTest public class SearchAccountLeadControllerTest {
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    
    @isTest static void test_one(){
        SearchAccountLeadController.fetchAccounts();
        SearchAccountLeadController.fetchLead();
        
        List<Account> lstAccounts =  TestDataFactory.createAccount(1);
        SearchAccountLeadController.serchAccounts('Blue');
        
        List<Lead> lstLeads =  TestDataFactory.createLead(1);
        SearchAccountLeadController.searchLead('Blue');
        
        System.assertEquals('Addon', lstLeads[0].FirstName);
    }
}
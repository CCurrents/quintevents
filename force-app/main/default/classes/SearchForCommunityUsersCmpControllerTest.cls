/**
 * @File Name          : QuoteTriggerHelperTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/20/2020, 4:07:16 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/16/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest public class SearchForCommunityUsersCmpControllerTest {
	@TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }

    @isTest static void test1(){
        List<Account> lstAccounts =  TestDataFactory.createAccount(1);
        List<Lead> lstLeads =  TestDataFactory.createLead(1);
        Contact contact = TestDataFactory.createContact(lstAccounts[0].Id);
        
        SearchForCommunityUsersCmpController.fetchAccount('Blue');
        SearchForCommunityUsersCmpController.fetchLead('Blue');
        SearchForCommunityUsersCmpController.fetchContact('Test');
    }
}
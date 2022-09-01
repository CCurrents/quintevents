/**
 * @File Name          : ChangeAccountRecordTypeCmpController.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/8/2020, 2:12:07 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/10/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
public class ChangeAccountRecordTypeCmpControllerTest {
	@TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    @isTest static void testRun1(){
        TestDataFactory.createTriggerSettingsEntry();
        Account objAcc = TestDataFactory.createAccount();
        objAcc.Company_Name__pc = 'Testing Company';
        ChangeAccountRecordTypeCmpController.getAccountDetails(objAcc.Id);
        ChangeAccountRecordTypeCmpController.h4hHotelSearchAPICall(objAcc.Id, objAcc);
    }

    @isTest static void testRun2(){
        TestDataFactory.createTriggerSettingsEntry();
        Account objAcc = TestDataFactory.createAccount();
        try{
            ChangeAccountRecordTypeCmpController.h4hHotelSearchAPICall(objAcc.Id, objAcc);
        }catch(Exception ex){}
    }
}
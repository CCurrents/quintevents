/**
 * @File Name          : GetSlackTokenTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 6/15/2020, 2:19:25 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/15/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest public class GetSlackTokenTest {
    @testSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    @isTest static void Test1(){
        GetSlackToken obj = new GetSlackToken();
        obj.authCode = '';
        obj.baseUrl = '';
    }
}
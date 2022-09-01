/**
 * @File Name          : XeroOAuthControllerTest.cls
 * @Description        : test class for the XeroOAuthController controller
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 04/27/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    04/27/2020    mpatel@addonblue.com       Initial Version
**/
@isTest
private with sharing class XeroOAuthControllerTest {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void xeroOAuthFistTestExecution() {
       
        Test.setCurrentPage(Page.XeroOAuth);
        ApexPages.currentPage().getParameters().put('Code','True');
        Test.startTest();
        StaticResourceCalloutMock mock1 = new StaticResourceCalloutMock();
        mock1.setStaticResource('XeroAccessToken');
        mock1.setStatusCode(200);
        mock1.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock1);
        
        XeroOAuthController obj = new XeroOAuthController();
        obj.getAccessToken();
        XeroOAuthController.refreshAccessTokenOnFailure('refreshAccesstokenId');
        Test.stopTest();
    }
}
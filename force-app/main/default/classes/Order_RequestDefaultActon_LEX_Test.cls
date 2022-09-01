/**
 * @File Name          : Order_RequestDefaultActon_LEX_Test.cls
 * @Description        : This test class use for Order_RequestDefaultActon_LEX.
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 9/6/2020, 3:37:39 pm
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    8/12/2020   fsuraitawala@addonblue.com     Initial Version
**/
@isTest
private class Order_RequestDefaultActon_LEX_Test {
    /****************************************/
    @isTest
    static void testRunOne() {
        TestDataFactory.createTriggerSettingsEntry();
        Order testOrder = TestDataFactory.createOrder();
        Order_RequestDefaultActon_LEX.submitForDefaulted(testOrder.Id, 'Defaulted Comments');
    }

}
/**
 * @description       : 
 * @author            : jagrawal@addonblue.com
 * @group             : 
 * @last modified on  : 11-19-2020
 * @last modified by  : jagrawal@addonblue.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   11-19-2020   jagrawal@addonblue.com   Initial Version
**/
@isTest
public class SlackProductZeroInventoryTest {

    @testSetup
    public static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    
    @isTest
    public static void testMethod1(){
        List<Id> productIds = new List<Id>();
        Product2 objProduct = TestDataFactory.createProduct();
        productIds.add(objProduct.Id);
        SlackProductZeroInventory.invocableMethod(productIds);
    } 
    
}
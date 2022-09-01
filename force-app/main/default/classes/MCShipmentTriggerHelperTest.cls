/**
 * @File Name          : MCShipmentTriggerHelperTest.cls
 * @Description        : 
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 3/16/2020, 3:23:57 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    3/16/2020   mpatel@addonblue.com     Initial Version
**/
@isTest
private with sharing class MCShipmentTriggerHelperTest{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();
    }
    @isTest static void testMethodOne() {
        Opportunity objOpportunity = TestDataFactory.createOpportunity();
        Order order= new Order();
        order.AccountId = TestDataFactory.createAccount().Id;
        order.EffectiveDate = date.newInstance(2020, 3, 01);
        order.Status = 'Draft';
        insert order;
        zkmulti__MCShipment__c objShipment = new zkmulti__MCShipment__c(); 
        objShipment.Opportunity__c = objOpportunity.Id;
        objShipment.Order__c = order.Id;
        objShipment.zkmulti__Tracking_Number__c = '123456';
        Utility.processRecords(objShipment, 'insert');
        //System.assertEquals(false,objShipment.Id != null);
        Utility.processRecords(objShipment, 'update');
        System.assertEquals(false,objShipment.Name != null);
        Utility.processRecords(objShipment, 'delete'); 
        zkmulti__MCShipment__c[] undeletes = [Select id from zkmulti__MCShipment__c where id=:objShipment.Id ALL ROWS];
        undelete undeletes; 
    } 
}
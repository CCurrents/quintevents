/**
 * @File Name          : EventPaymentTermTriggerHelperTest.cls
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
private with sharing class EventPaymentTermTriggerHelperTest{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();        
    }
    @isTest static void eventPaymentTestFistExecution() {
        PriceBook2 pricebook = TestDataFactory.createPricebook();
        pricebook.GPE_Event__c = true;
        Utility.processRecords(pricebook, 'insert');

        Event_Payment_Terms__c eventTerm = TestDataFactory.createEventPaymentTerm(1,false)[0];
        Utility.processRecords(eventTerm, 'insert');
        System.assertEquals(false,eventTerm.Name != null);
        Utility.processRecords(eventTerm, 'update');
        System.assertEquals(false,eventTerm.Name != null);
        Utility.processRecords(eventTerm, 'delete');
        System.assertEquals(false ,eventTerm == null);
    }
}
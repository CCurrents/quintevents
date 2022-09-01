/**
 * @description       : 
 * @author            : Jheel Agrawal
 * @group             : 
 * @last modified on  : 01-26-2021
 * @last modified by  : Jheel Agrawal
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   01-26-2021   Jheel Agrawal   Initial Version
**/
@isTest
public with sharing class LeadTriggerHelperTest {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }

    @isTest
    static void testMethod1(){
        Lead objLead = TestDataFactory.createLead();

        objLead.Marketing_Email_Consent__c = 'Yes';
        update objLead;
    }

}
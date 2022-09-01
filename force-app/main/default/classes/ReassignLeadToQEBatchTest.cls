/**
 * @description       : #1180 Reassign Leads to QE if Communication Confirmed is false
 * @author            : fsuraitawala@addonblue.com
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : fsuraitawala@addonblue.com
**/
@isTest
public with sharing class ReassignLeadToQEBatchTest {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }

    @isTest
    static void testMethod1(){
        Lead objLead = TestDataFactory.createLead();
        objLead.Communication_Confirmed__c = false;
        
        Lead objNewLead = objLead;
        objNewLead.Id = null;
        objNewLead.CreatedDate = system.today() - 50;
        objNewLead.Email = 'testemail@test.com';
        Insert objNewLead;
        Database.executeBatch(new ReassignLeadToQEBatch());
    }
}
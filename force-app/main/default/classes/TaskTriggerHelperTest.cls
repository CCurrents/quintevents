/**
 * @File Name          : QuoteTriggerHelperTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/8/2020, 4:04:40 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    3/16/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest public with sharing class TaskTriggerHelperTest {
    
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
        Lead objLead = TestDataFactory.createLead();
    }

    @isTest static void updateTaskDescription(){
        List<Lead> lstLeads = [Select Id from Lead Limit 1];
        List<Task> lstTasks = new List<Task>();
        if(lstLeads.size() > 0){
            lstTasks = TestDataFactory.createTask(1, lstLeads[0].id);
        }
        System.assertEquals(1, lstTasks.size());
    }

    @isTest static void UpdateLeadwithTask(){
        List<Lead> lstLeads = [Select Id from Lead Limit 1];
        List<Task> lstTasks = new List<Task>();
        if(lstLeads.size() > 0){
            lstTasks = TestDataFactory.createTask(1,lstLeads[0].id);
        }
        System.assertEquals(1, lstTasks.size());
        Utility.processRecords(lstTasks, 'update');
        Utility.processRecords(lstTasks, 'delete');
        Task[] taskUndelete = [Select id from Task where id=:lstTasks[0].Id];
        Utility.processRecords(taskUndelete, 'undelete');
        //TriggerHandler.
        TriggerHandler.bypass('test');
        TriggerHandler.clearBypass('test');
        TriggerHandler.isBypassed('handlerName');
        TriggerHandler.clearAllBypasses();
        TriggerHandler tr = new TriggerHandler();
        tr.clearMaxLoopCount();
    }

}
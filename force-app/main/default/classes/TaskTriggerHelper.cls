/**
* @File Name          : TaskTriggerHelper.cls
* @Description        : 
* @Author             : jagrawal@addonblue.com
* @Group              : 
* @Last Modified By   : jagrawal@addonblue.com
* @Last Modified On   : 11/3/2020
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    11/3/2020   jagrawal@addonblue.com     Initial Version
**/
public class TaskTriggerHelper {
    
    private Map<Id, Task> newTaskMap; 
    private Map<Id, Task> oldTaskMap;
    private List<Task> newTaskList;
    private List<Task> oldTaskList;
    
    /**
    * @description Constructor to query all data at once and then pass it in the Helper methods for specific Trigger event
    * @author jagrawal@addonblue.com | 11/3/2020 
    * @return void 
    **/
    public TaskTriggerHelper(){
        
        this.newTaskMap = (Map<Id, Task>) Trigger.newMap;
        this.oldTaskMap = (Map<Id, Task>) Trigger.oldMap;
        this.newTaskList = (List<Task>) Trigger.new;
        this.oldTaskList = (List<Task>) Trigger.old;
        
        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
                System.debug('In Before Insert!');
                updateTaskDescription(newTaskList);
            }
            when BEFORE_UPDATE {
                System.debug('In Before Update!');
            }
            when BEFORE_DELETE {
                System.debug('In Before Delete!');
            }
            when AFTER_INSERT {
                System.debug('In After Insert!');
                List<Lead> LeadsToUpdate = new List<Lead>();
                Map<Id, Task> taskMap = new Map<Id, Task>();
                for(Task t: newTaskList){
                    if (t.WhoId  != null && t.Subject == 'Email: Thank you for contacting Derby Experiences!'){
                        taskMap.put(t.WhoId, t);
                    }
                }
                LeadsToUpdate = [SELECT Id, Email_Sent__c FROM Lead WHERE Id IN: taskMap.keySet()];
                updateLeadWithTask(LeadsToUpdate);
            }
            when AFTER_UPDATE {
                System.debug('In After Update!');
            }
            when AFTER_DELETE {
                System.debug('In After Delete!');
            }
            when AFTER_UNDELETE {
                System.debug('In After Undelete!');
            }
            when else{
                System.debug('Undefined Trigger Operation!');
            }
        }
    }
    
    private void updateTaskDescription(List<Task> newTaskList){
        for(Task task : newTaskList) {
            if (task.Description != null) {
                String description = task.Description;
                String regExp = 'reset_password_token=.+?\\)';
                String replacement = 'reset_password_token=fake)';
                String replaced = description.replaceAll(regExp, replacement);
                task.Description = replaced;
            }
        }
    }
    
    private void updateLeadWithTask(List<Lead> LeadsToUpdate){
        for(Lead l: LeadsToUpdate){ 
            l.Email_Sent__c = TRUE;
        }
        if(LeadsToUpdate.size() > 0){
            Utility.processRecords(LeadsToUpdate, 'update');
        }
    }
}
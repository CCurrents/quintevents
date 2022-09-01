/**
 * @File Name          : EventPaymentTermTriggerHelper.cls
 * @Description        : Trigger helper on Event Payment Term object and calling from the Event Payment Term Trigger
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 3/8/2020, 10:02:42 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.1     2/3/2020      mpatel@addonblue.com      Refactored the code by changing the name of Handler
**/
public with sharing class EventPaymentTermTriggerHelper{
    private Map<Id, Event_Payment_Terms__c> newEPTMap; 
    private Map<Id, Event_Payment_Terms__c> oldEPTMap;
    private List<Event_Payment_Terms__c> newEPTList;
    private List<Event_Payment_Terms__c> oldEPTList;
    
    public EventPaymentTermTriggerHelper(){
        Utility.getSOQLCount();
        Utility.getTriggerSize();
        this.newEPTMap = (Map<Id, Event_Payment_Terms__c>) Trigger.newMap;
        this.oldEPTMap = (Map<Id, Event_Payment_Terms__c>) Trigger.oldMap;
        this.newEPTList = (List<Event_Payment_Terms__c>) Trigger.new;
        this.oldEPTList = (List<Event_Payment_Terms__c>) Trigger.old;
        
        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
                System.debug('In Before Insert!');
            }
            
            when BEFORE_UPDATE {
                System.debug('In Before Update!');
            }
            
            when BEFORE_DELETE {
                System.debug('In Before Delete!');
            }
            
            when AFTER_INSERT {
                System.debug('In After Insert!');
            }
            
            when AFTER_UPDATE {
                System.debug('In After Update!');
            }
            
            when AFTER_DELETE {
                processToDeleteRecord(oldEPTList);
            }
            
            when AFTER_UNDELETE {
                System.debug('In After Undelete!');
            }
            
            when else{
                System.debug('Undefined Trigger Operation!');
            }
        }
    }
    /**
    * @description  : its a after delete method call while record is deleted in the opportunity object
    * @author       : mpatel@addonblue.com | 1/28/2020 
    * @param        : List<OpportunityLineItem> listOfOpportunityLineItem
    * @return       : void 
    **/
    private void processToDeleteRecord(List<Event_Payment_Terms__c> oldEPTList){
        try {
                Utility.processDeletedRecords(oldEPTList);
            } catch (Exception ex) {
                System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
                Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            }
    }
}
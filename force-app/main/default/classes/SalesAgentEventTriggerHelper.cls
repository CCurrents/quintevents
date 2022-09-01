/**
 * @File Name          : SalesAgentEventHelper.cls
 * @Description        : 
 * @Author             : jthakkar@addonblue.com
 * @Group              : 
 * @Last Modified By   : jthakkar@addonblue.com
 * @Last Modified On   : 28/2/2020
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    27/1/2020   jthakkar@addonblue.com     Initial Version
**/
public class SalesAgentEventTriggerHelper {
    
    private Map<Id, Sales_Agent_Event__c> newSAEMap; 
    private Map<Id, Sales_Agent_Event__c> oldSAEMap;
    private List<Sales_Agent_Event__c> newSAEList;
    private List<Sales_Agent_Event__c> oldSAEList;

    public SalesAgentEventTriggerHelper(){
        
        this.newSAEMap = (Map<Id, Sales_Agent_Event__c>) Trigger.newMap;
        this.oldSAEMap = (Map<Id, Sales_Agent_Event__c>) Trigger.oldMap;
        this.newSAEList = (List<Sales_Agent_Event__c>) Trigger.new;
        this.oldSAEList = (List<Sales_Agent_Event__c>) Trigger.old;

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
                captureDeletedSalesAgentEvents(oldSAEList);
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
    * @description  : Capture deleted reseller event
    * @author       : jthakkar@addonblue.com | 28/2/2020 
    * @param        : list of Sales_Agent_Event__c
    * @return       : 
    **/    
    public void captureDeletedSalesAgentEvents(List<Sales_Agent_Event__c> oldSAEList) {         
        try {
            Utility.processDeletedRecords(oldSAEList);
        } catch (Exception e) {
            System.debug('Exception: '+e);
        }
    }    
}
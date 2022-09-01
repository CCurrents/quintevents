/**
 * @File Name          : OpportunityContactRoleTriggerHelper.cls
 * @Description        : Trigger helper on OpportunityContactRole object and calling from the OpportunityContactRoleTriggerHelper
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 11/11/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    11/11/2020     kchavda@addonblue.com      Initial Version
**/

public with sharing class OpportunityContactRoleTriggerHelper {

    private List<OpportunityContactRoleChangeEvent> newOpportunityContactRoleChangeEventList;
   
    
    public OpportunityContactRoleTriggerHelper(){        
       
        this.newOpportunityContactRoleChangeEventList = (List<OpportunityContactRoleChangeEvent>) Trigger.new;
        
        
        switch on Trigger.operationType { 
            when AFTER_INSERT { 
               updateCommissionAddressonOpp(newOpportunityContactRoleChangeEventList);               
            }
            when else{
                System.debug('Undefined Trigger Operation!');
            }
        }
    }
    
    
     /**
    * @description  : Update Commission Address on related Opportunity
    * @author       : kchavda@addonblue.com | 11/11/2020 
    * @param        : List<OpportunityContactRoleChangeEvent> newOpportunityContactRoleChangeEventList(List of OpportunityContactRoleChangeEvent)
    * @return       : void 
    **/
    @TestVisible
    private void updateCommissionAddressonOpp( List<OpportunityContactRoleChangeEvent> newOpportunityContactRoleChangeEventList) {
        try{            
            set<id> ocrIDs = new set<id>();
            set<string> ocrFields = new set<string>();
            for(OpportunityContactRoleChangeEvent e : newOpportunityContactRoleChangeEventList){
                EventBus.ChangeEventHeader changeEventHeader = e.ChangeEventHeader;       
                ocrFields.addall(changeEventHeader.changedfields); 
                if(changeEventHeader.changetype == 'UPDATE' && ocrFields.contains('ContactId')){            
                    if(changeEventHeader.getRecordIds().size()==1) ocrIDs.add(changeEventHeader.getRecordIds()[0]);
                }
            }
            List<OpportunityContactRole> ocRoles = new list<OpportunityContactRole>([select id,contactId,OpportunityId,IsPrimary,contact.Commission_Address__c from OpportunityContactRole where Id in :ocrIDs and Role = 'Commission Contact']);
                                                                                           
            List<Opportunity> oppsToUpdate = new List<Opportunity>();                                                                            
            set<id> oppIDs = new set<id>(); 
            for(OpportunityContactRole ocr: ocRoles){       
                oppsToUpdate.add(new opportunity(id = ocr.OpportunityId, Commission_Address__c=ocr.contact.Commission_Address__c));            
            }                
           
            if(!oppsToUpdate.isEmpty()){
                Utility.processRecords(oppsToUpdate, 'update');
            }
        }catch(Exception ex){ Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }    
    
    
}
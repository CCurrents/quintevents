trigger QE_OpportunityLineItemTrigger on opportunityLineItem(Before insert, After Insert, Before Update, After Update, Before Delete, After delete) {
    
    QE_OpportunityLineItemHandler handler = new QE_OpportunityLineItemHandler(Trigger.isExecuting, Trigger.size);
    QE_opportunityProductHelper opportunityProductHelper = new QE_opportunityProductHelper();
    
    if(Trigger.isInsert && Trigger.isBefore) {
        // Before Insert
        /*List<OpportunityLineItem> oppList = new List<OpportunityLineItem>();
        Map<Id, OpportunityLineItem> newOppMap = Trigger.newMap;
        System.debug('Trigger.New-->'+Trigger.New);
        List<OpportunityLineItem> opportunityLineList = [Select Id,Opportunity.GPE_Online_Order__c from OpportunityLineItem where Id IN: Trigger.New];
        System.debug('opportunityLineList-->'+opportunityLineList);
        for(OpportunityLineItem opline : opportunityLineList){
            if(opline.Opportunity.GPE_Online_Order__c == false){
                oppList.add(newOppMap.get(opline.Id));
            }
        }
        handler.onBeforeInsert(oppList);*/
        //8:20 AM --> 18:48 PM
        handler.onBeforeInsert(Trigger.new);

    } else if(Trigger.isInsert && Trigger.isAfter) {

        // After Insert
        // Get opportunity ids
        Set<Id> opportunityIds = new Set<Id>();
        for (OpportunityLineItem lineItem : Trigger.new) {
            opportunityIds.add(lineItem.OpportunityId);
        }

        List<OpportunityLineItem> oppList = new List<OpportunityLineItem>();
        Map<Id, OpportunityLineItem> newOppMap = Trigger.newMap;
        Map<Id, OpportunityLineItem> oppMap = new Map<Id, OpportunityLineItem>();
        List<OpportunityLineItem> opportunityLineList = [Select Id,Opportunity.GPE_Online_Order__c from OpportunityLineItem where Id IN: Trigger.New];
        System.debug('opportunityLineList-->'+opportunityLineList);
        for(OpportunityLineItem opline : opportunityLineList){
            if(opline.Opportunity.GPE_Online_Order__c == false){
                oppList.add(newOppMap.get(opline.Id));
                oppMap.put(newOppMap.get(opline.Id).Id, newOppMap.get(opline.Id));
            }
        }

        handler.onAfterInsert(oppList, oppMap);
        //handler.onAfterInsert(Trigger.new, Trigger.newMap);
        opportunityProductHelper.captureOpportunityProducts(opportunityIds);
        QE_OpportunityLineItemHelper.InsertUpdateVatProductCnt(trigger.new,trigger.oldMap);
        
    } else if(Trigger.isUpdate && Trigger.isBefore) {

        // Before Update
        // Avoid recursive trigger
        if(QE_checkRecursive.runOnce()) {

            List<OpportunityLineItem> oppNewList = new List<OpportunityLineItem>();
            List<OpportunityLineItem> oppOldList = new List<OpportunityLineItem>();
            Map<Id, OpportunityLineItem> newOppMap = Trigger.newMap;
            Map<Id, OpportunityLineItem> oldOppMap = Trigger.oldMap;
            Map<Id, OpportunityLineItem> oppNewMap = new Map<Id, OpportunityLineItem>();
            Map<Id, OpportunityLineItem> oppOldMap = new Map<Id, OpportunityLineItem>();

            List<OpportunityLineItem> opportunityLineList = [Select Id,Opportunity.GPE_Online_Order__c from OpportunityLineItem where Id IN: Trigger.New];
            
            System.debug('opportunityLineList-->'+opportunityLineList);
            for(OpportunityLineItem opline : opportunityLineList){
                if(opline.Opportunity.GPE_Online_Order__c == false){
                    oppNewList.add(newOppMap.get(opline.Id));
                    oppOldList.add(oldOppMap.get(opline.Id));
                    oppNewMap.put(newOppMap.get(opline.Id).Id, newOppMap.get(opline.Id));
                    oppOldMap.put(oldOppMap.get(opline.Id).Id, oldOppMap.get(opline.Id));
                }
                
            }
            handler.onBeforeUpdate(oppOldList, oppNewList, oppOldMap, oppNewMap);
            //handler.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        } 
    } else if(Trigger.isUpdate && Trigger.isAfter) {

        // After Update
        // Get opportunity ids
        Set<Id> opportunityIds = new Set<Id>();
        for (OpportunityLineItem lineItem : Trigger.new) {
            opportunityIds.add(lineItem.OpportunityId);
        }
        // Avoid recursive trigger
        if(QE_checkRecursive.runTwo()) {
            List<OpportunityLineItem> oppNewList = new List<OpportunityLineItem>();
            List<OpportunityLineItem> oppOldList = new List<OpportunityLineItem>();
            Map<Id, OpportunityLineItem> newOppMap = Trigger.newMap;
            Map<Id, OpportunityLineItem> oldOppMap = Trigger.oldMap;
            Map<Id, OpportunityLineItem> oppNewMap = new Map<Id, OpportunityLineItem>();
            Map<Id, OpportunityLineItem> oppOldMap = new Map<Id, OpportunityLineItem>();

            List<OpportunityLineItem> opportunityLineList = [Select Id,Opportunity.GPE_Online_Order__c from OpportunityLineItem where Id IN: Trigger.New];
            
            System.debug('opportunityLineList-->'+opportunityLineList);
            for(OpportunityLineItem opline : opportunityLineList){
                if(opline.Opportunity.GPE_Online_Order__c == false){
                    oppNewList.add(newOppMap.get(opline.Id));
                    oppOldList.add(oldOppMap.get(opline.Id));
                    oppNewMap.put(newOppMap.get(opline.Id).Id, newOppMap.get(opline.Id));
                    oppOldMap.put(oldOppMap.get(opline.Id).Id, oldOppMap.get(opline.Id));
                }
                
            }
            handler.onAfterUpdate(oppOldList, oppNewList, oppOldMap, oppNewMap);
            //handler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            QE_OpportunityLineItemHelper.InsertUpdateVatProductCnt(trigger.new,trigger.oldMap);
        }
        opportunityProductHelper.captureOpportunityProducts(opportunityIds);
        
    } else if(Trigger.isDelete && Trigger.isBefore) {

        // Before Delete
        List<OpportunityLineItem> oppOldList = new List<OpportunityLineItem>();
        Map<Id, OpportunityLineItem> oldOppMap = Trigger.oldMap;
        Map<Id, OpportunityLineItem> oppOldMap = new Map<Id, OpportunityLineItem>();

        List<OpportunityLineItem> opportunityLineList = [Select Id,Opportunity.GPE_Online_Order__c from OpportunityLineItem where Id IN: Trigger.old];
        
        System.debug('opportunityLineList-->'+opportunityLineList);
        for(OpportunityLineItem opline : opportunityLineList){
            if(opline.Opportunity.GPE_Online_Order__c == false){
                oppOldList.add(oldOppMap.get(opline.Id));
                oppOldMap.put(oldOppMap.get(opline.Id).Id, oldOppMap.get(opline.Id));
            }
            
        }
        handler.onBeforeDelete(oppOldList, oppOldMap);
        //handler.onBeforeDelete(Trigger.old, Trigger.oldMap);
    } else if(Trigger.isDelete && Trigger.isAfter) {

        // After Delete
        // Get opportunity ids
        Set<Id> opportunityIds = new Set<Id>();        
        for (OpportunityLineItem lineItem : Trigger.old) {
            opportunityIds.add(lineItem.OpportunityId);            
        }

        /*List<OpportunityLineItem> oppOldList = new List<OpportunityLineItem>();
        Map<Id, OpportunityLineItem> oldOppMap = Trigger.oldMap;
        Map<Id, OpportunityLineItem> oppOldMap = new Map<Id, OpportunityLineItem>();*/

        System.debug('Trigger.old-->'+Trigger.old);
        System.debug('Trigger.new-->'+Trigger.new);
        
        //List<OpportunityLineItem> opportunityLineList = [Select Id,Opportunity.GPE_Online_Order__c from OpportunityLineItem where Id IN: Trigger.old];
        //Map<Id,Opportunity> mapOpps = new Map<Id,Opportunity>([Select Id,GPE_Online_Order__c from Opportunity where Id IN: mapOppIds.values()]);
        
        /* Added by MP System.debug('opportunityLineList-->'+opportunityLineList);
        for(OpportunityLineItem opline : opportunityLineList){
            if(opline.Opportunity.GPE_Online_Order__c == false){
                oppOldList.add(oldOppMap.get(opline.Id));
                oppOldMap.put(oldOppMap.get(opline.Id).Id, oldOppMap.get(opline.Id));
            }
           
        }*/        
       
        //handler.onAfterDelete(oppOldList, oppOldMap);
        handler.onAfterDelete(Trigger.old, Trigger.oldMap);
        // Capture opportunity products (in this case delete em)
        opportunityProductHelper.captureOpportunityProducts(opportunityIds);
        // Capture Deleted Opportunity Products for Sending Outbound messages
        //opportunityProductHelper.captureDeletedOpportunityProducts(Trigger.Old);
        QE_OpportunityLineItemHelper.DeleteVatProductCnt(trigger.old);
    }

}
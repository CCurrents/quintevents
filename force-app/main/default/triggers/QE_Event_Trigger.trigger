trigger QE_Event_Trigger on QE360_Event__c (Before Insert, Before Update,After Insert, After Update, After Delete) {
    
    // Before
    if (Trigger.isBefore) {
        // Insert
        if (Trigger.isInsert) {
            QE_eventHandler.checkNameUniqueness(Trigger.new);
        }
        // Update
        if (Trigger.isUpdate) {
            QE_eventHandler.checkNameUniqueness(Trigger.new);
        }
    }
    
    // After
    if (Trigger.isAfter) {
    //Insert
    if(Trigger.isInsert) {
          QE_eventHandler.createProducts(Trigger.new);
        //QE_eventHandler.createResellerEvent(Trigger.newMap, null);
          QE_eventHandler.resellerEventCreate(Trigger.newMap,null);
        //QE_eventHandler.uploadingFilesintoAWS(Trigger.new);
        //QE_eventHandler.sendImagetoAWS(Trigger.new);
          
    }
    //update 
    if(Trigger.isUpdate) {
        QE_eventHandler.chkIntrStripeAndcreatePBE(Trigger.newMap, Trigger.oldMap);
        
        for(QE360_Event__c eve : Trigger.new) {
            if(Trigger.newMap.get(eve.id).program__c != null && Trigger.newMap.get(eve.id).Active__C == true && (Trigger.oldMap.get(eve.id).Active__c == false || (Trigger.newMap.get(eve.id).program__c != Trigger.oldMap.get(eve.id).program__c))) { 
                QE_eventHandler.resellerEventCreate(Trigger.newMap,Trigger.oldMap);
            }
        }
        //QE_eventHandler.createResellerEvent(Trigger.newMap, Trigger.oldMap);
        //QE_eventHandler.updateCategorywithEvent(Trigger.newMap, Trigger.oldMap);
        QE_eventHandler.ResellerEventDelete(Trigger.newMap,Trigger.oldMap);
        
        //************added by manan patel for create Currency wise pricebook entry*************
        Set<Id> eventId = new Set<Id>();
        for(QE360_Event__c eve : Trigger.new){
            if(eve.GPE_Event__c != Trigger.oldMap.get(eve.Id).GPE_Event__c && eve.GPE_Event__c == true){
                //System.debug('gpt Event checkBox change false to true');
                eventId.add(eve.Id);
            }
        }
        QE_eventHandler.insertPriceBookEntryonGPTEventUpdate(eventId);
    }
        // Delete
        if (Trigger.isDelete) {
            QE_eventHandler.captureDeletedEvents(Trigger.old);
        }
    }
    
    /*
    if(Trigger.IsInsert){     
        DataBase.executeBatch(new QE_sendRecordsToQuintEvents(Trigger.newMap.KeySet(),'QE360_Event__c','QE360_Event__c','Insert'), 100);
    }
    if(Trigger.IsUpdate){
        DataBase.executeBatch(new QE_sendRecordsToQuintEvents(Trigger.newMap.KeySet(),'QE360_Event__c','QE360_Event__c','Update'), 100);
    }
    if(Trigger.IsDelete){        
        System.enqueueJob(new QE_sendDeletedRecordsToQuintEvents(Trigger.oldMap.values(),'QE360_Event__c','Delete'));
    }   
    */
}
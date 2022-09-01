trigger QE_Product2_Trigger on Product2 (After Insert, After Update, Before Delete) {
    /*
    if(Trigger.IsInsert){     
        DataBase.executeBatch(new QE_sendRecordsToQuintEvents(Trigger.newMap.KeySet(),'Product2','Product2','Insert'), 100);
    }
    if(Trigger.IsUpdate){
        DataBase.executeBatch(new QE_sendRecordsToQuintEvents(Trigger.newMap.KeySet(),'Product2','Product2','Update'), 100);
    }
    if(Trigger.IsDelete){        
        System.enqueueJob(new QE_sendDeletedRecordsToQuintEvents(Trigger.oldMap.values(),'Product2','Delete'));
    }   
    */
}
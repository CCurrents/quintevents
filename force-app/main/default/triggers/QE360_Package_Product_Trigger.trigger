trigger QE360_Package_Product_Trigger on QE360_Package_Product__c (after insert, after update, after delete, after undelete) {
    
    // modified objects whose parent records should be updated
    QE360_Package_Product__c[] objects = null;   
    
    if (Trigger.isDelete) {
        objects = Trigger.old;
    } else {
        /*
        Handle any filtering required, specially on Trigger.isUpdate event. If the rolled up fields
        are not changed, then please make sure you skip the rollup operation.
        We are not adding that for sake of similicity of this illustration.
        */ 
        objects = Trigger.new;
    }
        
    /*
    First step is to create a context for LREngine, by specifying parent and child objects and
    lookup relationship field name
    */
    QE360_LREngine.Context ctx = new QE360_LREngine.Context(QE360_Package__c.SobjectType, // parent object
                                                QE360_Package_Product__c.SobjectType,  // child object
                                                Schema.SObjectType.QE360_Package_Product__c.fields.Package__c // relationship field name
                                               );     
    /*
    Next, one can add multiple rollup fields on the above relationship. 
    Here specify 
    1. The field to aggregate in child object
    2. The field to which aggregated value will be saved in master/parent object
    3. The aggregate operation to be done i.e. SUM, AVG, COUNT, MIN/MAX
    */
    ctx.add(
        new QE360_LREngine.RollupSummaryField(
            Schema.SObjectType.QE360_Package__c.fields.Cost__c,
            Schema.SObjectType.QE360_Package_Product__c.fields.Cost__c,
            QE360_LREngine.RollupOperation.Sum 
        ));
    /* 
    Calling rollup method returns in memory master objects with aggregated values in them. 
    Please note these master records are not persisted back, so that client gets a chance 
    to post process them after rollup
    */ 
    Sobject[] masters = new SObject[]{};
    
    for(SObject master : QE360_LREngine.rollUp(ctx, objects)) {
      if(master.Id != null) masters.add(master);
    }
    
    // Persist the changes in master
    update masters;
}
trigger QE_productTrigger on Product2(before insert,after insert,after Update,before update,before delete,after delete)
{
    if(Trigger.IsBefore && Trigger.IsInsert)
    {
        /* Added by Jeet */
        QE_productHandler.checkNameUniqueness(Trigger.New);
        /* Added by Jeet Ends */
    }
    else
    {
        if(Trigger.IsAfter && Trigger.isInsert)
        {
            QE_productHandler.InsertMethod(Trigger.New); //Whenever Produt is created InsertMethod is going to fire
            /*Set<Id> productId = new Set<Id>();
                for(Product2 pro: Trigger.New){
                productId.add(pro.Id);
                }
                
                QE_productHandler.InsertMethod(productId);*/
        }
        if(Trigger.IsBefore && Trigger.isUpdate) 
        {
			QE_productHandler.checkIsProductAutoCreated(Trigger.New,Trigger.newMap,Trigger.OldMap);
            QE_productHandler.UpdateMethod(Trigger.New,Trigger.OldMap); //Whenever Produt is Updated UpdateMethod is going to fire
            /* Added by Jeet */
           QE_productHandler.checkNameUniqueness(Trigger.New);
            /* Added by Jeet Ends */
        }
        if(Trigger.IsAfter && Trigger.isUpdate  && (QE_productHandler.runOnce() || test.isRunningTest()))
        {
            /* Added By Jeet */
            //if(QE_checkRecursive.runOnce()) {
                // QE_Product_Active_Handler.afterUpdateMethod(Trigger.New,Trigger.OldMap); // Commented by Jeet, this is where package product is being deleted if product is set to InActive.
                QE_productHandler.updatePackageProducts(Trigger.oldMap, Trigger.newMap);
                QE_productHandler.updatePackageInventory(Trigger.oldMap, Trigger.newMap);
                QE_productHandler.updatePBEntrykUnitPrice(Trigger.oldMap, Trigger.newMap);
                
            //}
            /* Added By Jeet Ends */
        }
    }
    if(trigger.isbefore && Trigger.IsDelete  )
    {  
        //system.debug('Error==>'+Trigger.old);
        //   QE_productHandler.beforedeleteMethod(Trigger.old);
        QE_productHandler.checkIsProductAutoCreated(Trigger.old,null,Trigger.oldMap);
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Product2' and Name = 'Package'].Id;
        system.debug('strRecordTypeId==>'+strRecordTypeId);
        Set<id> prodSet = new set<id>();
        for(Product2 pr : Trigger.old){
            // system.debug('pr.id==>'+pr.id);
            // system.debug('RecordType.Name==>'+RecordType.Name);
            if(pr.RecordTypeId==strRecordTypeId ){
                prodSet.add(pr.id);
            }
        }
        system.debug('prodSet==>'+prodSet);
        List<Package_Products__c> PPList = new List<Package_Products__c>();
        PPList = [select id from Package_Products__c where Package__c =:prodSet];
        system.debug('PPList ==>'+PPList );
        system.debug('PPList ==>'+PPList.size() );
        if(PPList.size() >0)
            delete PPList;
        /** Added By Jeet **/
        QE_productHandler.deletePackageProducts(Trigger.old);
        /** Added By Jeet Ends **/
    }
    
    // After Delete
    if (Trigger.isAfter && Trigger.IsDelete) {
        QE_productHandler.captureDeletedProducts(Trigger.old);
    }
}
trigger QE_contactTrigger on Contact (After Insert, After Update, Before Insert, Before Update) {
   
   QE_contactTriggerHandler handler = new QE_contactTriggerHandler();
       
   if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
   }else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
   }else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
   }else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
        QE_contactTriggerHandler.updateContactNameToIntacct(Trigger.New,Trigger.oldmap);
   }
}
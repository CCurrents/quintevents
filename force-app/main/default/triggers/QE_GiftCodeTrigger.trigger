trigger QE_GiftCodeTrigger on Gift_Code__c (After Insert, After Update, After Delete) {
   if(Trigger.isInsert && Trigger.isAfter){
       QE_GiftCodeHandler.onAfterInsertGiftCode(Trigger.New);      
   }  
   if(Trigger.isUpdate && Trigger.isAfter && QE_GiftCodeHandler.isRecursive==false){
       QE_GiftCodeHandler.giftCodesCount(Trigger.New);      
   }
   
   // After Delete
    if (Trigger.isAfter && Trigger.IsDelete) {
        QE_GiftCodeHandler.captureDeletedProducts(Trigger.old);
    }
}
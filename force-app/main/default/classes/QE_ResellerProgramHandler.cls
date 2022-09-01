Public Class QE_ResellerProgramHandler {

    //To Create multiple Reseller Events based on Event and Reseller program
    Public Static Void onAfterInsert(Map<Id,Reseller_program__C> newMapResProgs) {
       Map<Id,Id> resellerMapIds = new Map<Id,Id>();
       
       for(Reseller_program__c resProg : newMapResProgs.values()) {
           if(resProg.program__c != null && resProg.reseller__c != null) {
             resellerMapIds.put(resProg.Program__c,resProg.reseller__c); //Holds Reseller program and its associated reseller.  
           }          
       }        
       
       //List to hold events with similar reseller program
       List<QE360_event__c> evProgList = [Select id,program__c from QE360_event__c where Active__c = true AND Program__C != null AND program__C IN: resellerMapIds.keySet()];  
       List<Reseller_event__c> resEventList = [Select id,event__r.id,reseller__C,event__C from Reseller_event__c where Reseller__C IN: resellerMapIds.values()];
       List<Reseller_Event__C> resEvList = new List<Reseller_Event__C>();
       System.debug('*** res list 1**'+resEventList.size());
       Map<Id,Set<Id>> resEvntMap = new Map<Id,Set<Id>>();
       
       for(reseller_event__c resEvnt : resEventList) {
      if(resEvntMap.get(resEvnt.reseller__C) == null) {
          resEvntMap.put(resEvnt.reseller__C,new Set<Id>{resEvnt.event__r.id});
      }
      else {
          resEvntMap.get(resEvnt.reseller__C).add(resEvnt.event__c);  
      }         
       }
     System.debug('*** res mapc 1**'+resEvntMap.size());
     System.debug('*** res map 1**'+resEvntMap); 
       //Insert Reseller Events for reseller with program same as event program.
       if(!evProgList.isEmpty()) {       
           for(QE360_event__C eve : evProgList) {                      
                  for(Id res : resellerMapIds.values()) {
                  System.debug('*** ev id**'+eve.id);
                  System.debug('*** res id ***'+res);
                  System.debug('*** contains ***'+resEvntMap.containskey(res));
                  System.debug('*** res ***'+resevntMap.get(res));
                  if(!resEventList.isEmpty() && !resEvntMap.isEmpty() && !resEvntMap.get(res).contains(eve.id)) {
                  System.debug('*** not entered ***');
                      Reseller_Event__c resEv = new Reseller_event__c();
                      resEv.Reseller__c = res;
                      resEv.Event__c = eve.id;
                      system.debug('*** resEv **'+resEv);
                      resEvList.add(resEv);
                    }
                  else if(resEventList.isEmpty()){
                  System.debug('*** entered ***');
                      Reseller_Event__c resEv = new Reseller_event__c();
                      resEv.Reseller__c = res;
                      resEv.Event__c = eve.id;
                      resEvList.add(resEv);
                  }                
                  }        
           }      
       }
      
       //Insert reseller Events
       if(!resEvList.isEmpty()) {
       system.debug('*** res list**'+resEvList.size());
           insert resEvList;
       }
    
    }


}
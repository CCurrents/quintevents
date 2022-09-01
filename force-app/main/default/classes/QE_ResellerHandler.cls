public class QE_ResellerHandler {

    // After Insert
    public void onAfterInsert(Reseller__c[] newListResellers, Map<Id, Reseller__c> newMapResellers) {
        /*** Create Partner Events ***/
        // Get partner ids
        Set<Id> partnerIds = new Set<Id>();
        for(Reseller__c reseller : newListResellers) {
          if(reseller.reseller_programs__r.size() != null) {
            partnerIds.add(reseller.Program__c);
          }
        }
        // Get all events related to partner and put that in map
        Map<Id,List<QE360_Event__c>> eventsByPartner = new Map<Id,List<QE360_Event__c>>();
        for(QE360_Event__c event : [Select Id, Program__c From QE360_Event__c Where Active__C = true And Program__c != null And program__C In :partnerIds]) {         
            if(eventsByPartner.containsKey(event.Program__c)) {
                    eventsByPartner.get(event.Program__c).add(event);
                } else {
                    List<QE360_Event__c> tempEvents = new List<QE360_Event__c>();
                    tempEvents.add(event);
                    eventsByPartner.put(event.Program__c, tempEvents);
                }
                
        }
        // Create "Reseller Event" for each Reseller
        List<Reseller_Event__c> resellerEventsToInsert = new List<Reseller_Event__c>();
        List<Reseller_Event__c> resEvNewInserted = new List<Reseller_Event__c>();
        Map<Id,Reseller_event__c> resMapIds = new  Map<Id,Reseller_event__c>();
        List<Reseller_Event__c> resExistingId = [Select id,Event__r.id from Reseller_event__c where reseller__C IN: newListResellers];
        
        if(!resExistingId.isEmpty()) {
            for(reseller_event__c res : resExistingId) {
                resMapIds.put(res.event__c,res);
             }
        }
        for(Reseller__c reseller : newListResellers) {
            
            // Get events by partner id
            if(reseller.reseller_programs__r.size() != null && eventsByPartner.containsKey(reseller.Program__c)) {
                for(QE360_Event__c event : eventsByPartner.get(reseller.Program__c)) {
                    // For each event create "Reseller Event"
                    Reseller_Event__c resellerEvent = new Reseller_Event__c();
                    resellerEvent.Reseller__c = reseller.Id;                   
                    resellerEvent.Event__c = event.Id;
                    System.debug('**** contains ***'+!resExistingId.contains(resellerEvent));
                    System.debug('*** count ***'+resExistingId);
                    system.debug('*** res eve **8'+resellerEvent);
                    
                    if(!resExistingId.IsEmpty() && !resMapIds.containsKey(event.id)) {
                        resellerEventsToInsert.add(resellerEvent);
                        System.debug('*** list ***'+resellerEventsToInsert);
                    }
                    else if(resExistingId.IsEmpty()) {
                        resEvNewInserted.add(resellerEvent);
                        System.debug('***new list ***'+resEvNewInserted);
                    }
                    
                }
            }
        }
        // Insert Reseller Events
        if(!resellerEventsToInsert.isEmpty()) {
            //Insert resellerEventsToInsert;
        }
        
        if(!resEvNewInserted.IsEmpty()) {
            //insert resEvNewInserted;
        }
    }

}
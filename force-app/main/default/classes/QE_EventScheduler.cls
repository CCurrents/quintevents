global class QE_EventScheduler implements Schedulable{
    
    
    global void execute(SchedulableContext sc) {   
       QE_EventScheduler.retrieveEventRecords();
    }
    
    global static void retrieveEventRecords(){
        List<QE360_Event__c> lstEvent = New List<QE360_Event__c>([Select id,End_Date__c,Active__c from QE360_Event__c where End_Date__c <: system.today() and active__c = true]);
        if(!lstEvent.Isempty()){
            for(QE360_Event__c eve: lstEvent){
                eve.Active__c = false;
            }
            Update lstEvent;
        }
        
    }
}
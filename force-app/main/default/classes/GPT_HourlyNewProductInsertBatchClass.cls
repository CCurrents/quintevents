global class GPT_HourlyNewProductInsertBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
   
   global final string query;
    
   global GPT_HourlyNewProductInsertBatchClass(string strquery){
      this.query = strquery;
   }
   
   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);      
   }

   global void execute(Database.BatchableContext BC, List<QE360_Event__c> eventScope){
       if(!eventScope.Isempty() && !Test.isrunningTest()){       
           GPT_EventCallOut_LEX.eventObjCallOut(eventScope[0].Id);
       }
   }
   
   global void finish(Database.BatchableContext BC){
   }
}
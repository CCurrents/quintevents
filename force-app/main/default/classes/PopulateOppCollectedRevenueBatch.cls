/**
 * @File Name          : PopulateOppCollectedRevenue.cls
 * @Description        : To populate Opp Collected Revenue
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 08/21/2020
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    08/21/2020   kchavda@addonblue.com     #506 Collected Revenue on Opportunities
**/
public class PopulateOppCollectedRevenueBatch implements Database.Batchable<sObject>,Database.Stateful{ 
    
    public string query;
    
    
    /**
    * @description Constructor
    * @author kchavda@addonblue.com | 08/21/2020
    * @param  set<Id>
    * @return
    **/        
    public PopulateOppCollectedRevenueBatch(string strquery){
      this.query = strquery;
    }
    
       
     /**
    * @description Start method
    * @author kchavda@addonblue.com | 08/21/2020
    * @param  Database.BatchableContext
    * @return Database.QueryLocator
    **/  
    public Database.QueryLocator start(Database.BatchableContext BC){        
        return Database.getQueryLocator(query);
    }
    
    /**
    * @description Execute method
    * @author kchavda@addonblue.com | 04/03/2020
    * @param  Database.BatchableContext, List<sObject>
    * @return void
    **/  
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
           if(scope != null){
               Map<id,opportunity> mapOppstoUpdate = new Map<id,opportunity>();
               for(order odr: (List<order>)scope){
                   if(odr.Collected_Revenue__c != null && odr.Collected_Revenue__c != odr.Opportunity.Collected_Revenue__c){
                       Opportunity opp = new Opportunity(id=odr.OpportunityId);
                       opp.Collected_Revenue__c = odr.Collected_Revenue__c;
                       mapOppstoUpdate.put(opp.id,opp);
                   }
               }
               if(mapOppstoUpdate.size()>0) Utility.processRecords(mapOppstoUpdate.values(), 'update'); 
           }
        }
        catch(exception ex){
            System.debug('Exception :'+ex.getlinenumber()+'--'+ex.getmessage());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
       
    }
    
    /**
    * @description Finish method
    * @author kchavda@addonblue.com | 08/21/2020
    * @param  Database.BatchableContext
    * @return void
    **/  
    public void finish(Database.BatchableContext BC){        
    }
}
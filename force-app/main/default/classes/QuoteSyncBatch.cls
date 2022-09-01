/**
 * @File Name          : QuoteSyncBatch.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 6/10/2020, 12:57:07 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    6/10/2020   jagrawal@addonblue.com     Initial Version
**/
global class QuoteSyncBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    global final String Query;
    Set<Id> setQuoteId =  new Set<Id>();
    List<Quote> newQuoteList;
    Map<String, String> mOppIdtoQuoteId;
    List < Opportunity > lOppsToUpdate;
    global QuoteSyncBatch(String q, List<Quote> lst, Set<Id> setIds){
        Query=q;
        setQuoteId = setIds;
        newQuoteList = new List<Quote>();
        newQuoteList = lst;
        lOppsToUpdate = new List < Opportunity > ();
        mOppIdtoQuoteId = new Map<String, String>();
        system.debug('###QuoteSyncBatch=='+newQuoteList);        
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('###QuoteSyncBatch-Query: '+query);
        System.debug('###QuoteSyncBatch-setQuoteId: '+setQuoteId);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('scope----'+scope );
        system.debug('###execute=='+newQuoteList);
        try{
            
            for(Quote quote : newQuoteList){
                mOppIdtoQuoteId.put(quote.OpportunityId, quote.Id);
            }
            System.debug('ImOppIdtoQuoteId----'+mOppIdtoQuoteId);                
            
            lOppsToUpdate = [SELECT Id, SyncedQuoteId FROM Opportunity WHERE Id IN : mOppIdToQuoteId.keySet()];
            system.debug('###lOppsToUpdate=='+lOppsToUpdate);
            Map<Id, Quote> mapOfQuote = new Map<Id, Quote>([select id, name, Status from Quote where Id IN : mOppIdtoQuoteId.values()]);
            system.debug('###mapOfQuote=='+mapOfQuote);
            Map<Id, Opportunity> mapOfOpportunity = new Map<Id, Opportunity>([select id, SyncedQuoteId from Opportunity where Id IN : mOppIdtoQuoteId.keyset()]);        
            system.debug('###mapOfOpportunity=='+mapOfOpportunity);
            for ( Opportunity op :lOppsToUpdate)
            {
                if(mapOfOpportunity.get(op.Id).SyncedQuoteId == null || String.isEmpty(mapOfOpportunity.get(op.Id).SyncedQuoteId)) {
                    system.debug('###IF 1.1');
                    op.SyncedQuoteId = mOppIdToQuoteId.get(op.Id);
                }else{
                    system.debug('###ELSE IF 1.2');                
                    if(mapOfQuote.get(mOppIdToQuoteId.get(op.Id)).status == 'Signed - Approved'){                
                        system.debug('###IF 1.3');
                        op.SyncedQuoteId = mOppIdToQuoteId.get(op.Id);
                    }
                }            
            }
            system.debug('###lOppsToUpdate=='+lOppsToUpdate);
        }catch(Exception ex){
            system.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
        }
    }
    
    global void finish(Database.BatchableContext BC){
        if(lOppsToUpdate.size() > 0){
            system.debug('###finish=='+lOppsToUpdate);        
            Utility.processRecords(lOppsToUpdate, 'update');
        }
    }    
}
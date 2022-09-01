/**
 * @File Name          : UpdatePricebookEntryBatch.cls
 * @Description        : update the price book entry with latest currency iso code
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 4/20/2020, 3:23:57 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/20/2020   mpatel@addonblue.com     Initial Version
**/
global class UpdatePricebookEntryBatch implements Database.Batchable<sObject>{
    global String query;
    global Map<string,double>  isoCodeMap;
    global  Set<String> code;
    global UpdatePricebookEntryBatch(String PriceBookquery, Map<string,double>  isoCodeMapKey, Set<String> codes){
      query = PriceBookquery;
      isoCodeMap = isoCodeMapkey;
      code = codes;
    }
    /**
    * @description  : start methos of the batch class to get the records from the query
    * @author       : mpatel@addonblue.com | 4/20/2020 
    * @return       : Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext BC){
      query += ' where CurrencyIsoCode in:code';
      If(Test.isRunningTest()){
        query += ' limit 10';
      }
      return Database.getQueryLocator(query);
    }
    /**
    * @description  : execute method of batch class to process the record and update price book entry
    * @author       : mpatel@addonblue.com | 4/20/2020 
    * @return       : void 
    **/
    global void execute(Database.BatchableContext BC, List<PricebookEntry> scope){
      try{
        list<PricebookEntry> priceBooklistToUpdate = new list<PricebookEntry>();
        if(!scope.isEmpty()){
          for(PricebookEntry p : scope){
            if(isoCodeMap.containskey(p.CurrencyIsoCode)){
              if(p.Product2.Price__c!= null){
                  p.UnitPrice = isoCodeMap.get(p.CurrencyIsoCode)* p.Product2.Price__c;
                  priceBooklistToUpdate.add(p);
              }
            }
          }
        }
        if(!priceBooklistToUpdate.isEmpty()){
          Utility.processRecords(priceBooklistToUpdate, 'update');
        }
      }catch(Exception ex){
        System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
      }
    }   
    /**
    * @description  : finish method of the batch class
    * @author       : mpatel@addonblue.com | 4/20/2020 
    * @return       : void 
    **/
    global void finish(Database.BatchableContext BC){
     }
}
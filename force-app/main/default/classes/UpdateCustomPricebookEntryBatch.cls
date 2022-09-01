/**
 * @File Name          : UpdateCustomPricebookEntryBatch.cls
 * @Description        : update the custom price book entry for products which are created in last 1 hour.
 * @Author             : cshah@addonblue.com
 * @Group              : 
 * @Last Modified By   : cshah@addonblue.com
 * @Last Modified On   : 3/23/2021
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    3/23/2021   cshah@addonblue.com     Initial Version
**/
global class UpdateCustomPricebookEntryBatch implements Database.Batchable<sObject> {
    global Datetime checkDate = system.now().addhours(-24);
    
    global Database.QueryLocator start(Database.BatchableContext BC){
      checkDate = system.now().addhours(-24);  
      String query = 'Select Id,Price__c,Is_Processed__c FROM Product2 WHERE Createddate >=: checkDate AND Is_Processed__c = false';
      return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Product2> scope){
        try{
              Set<String> setProductIds = new Set<String>();
              List<Price_Book_Entry_Custom__c> lstCPBEupdate = new List<Price_Book_Entry_Custom__c>();
              Map<String,PricebookEntry> mapStandardPriceBookEntry = new Map<String,PricebookEntry>();
              List<Product2> lstProductUpdate = new List<Product2>();
              
              for(Product2 objproduct: scope) {
                  setProductIds.add(objproduct.Id);
                  
                  Product2 p = new Product2();
                  p.Id = objProduct.Id;
                  p.Is_Processed__c = true;
                  lstProductUpdate.add(p);
              }
              system.debug('@@setProductIds=='+setProductIds);
              if(setProductIds.size() > 0) {
                  
                  for(PricebookEntry objPBE: [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id IN : setProductIds]) {
                      mapStandardPriceBookEntry.put(objPBE.Id,objPBE);
                  }
                     
                  if(mapStandardPriceBookEntry.size() > 0) {
                        for(Price_Book_Entry_Custom__c objCPB: [Select Id,List_Price__c,Price_Book_Entry_Id__c from Price_Book_Entry_Custom__c where Price_Book_Entry_Id__c in :mapStandardPriceBookEntry.keyset()]) {
                            Price_Book_Entry_Custom__c customPBE = new Price_Book_Entry_Custom__c();
                            customPBE.Id = objCPB.Id;
                            if(mapStandardPriceBookEntry.containsKey(objCPB.Price_Book_Entry_Id__c)) {
                                customPBE.List_Price__c = mapStandardPriceBookEntry.get(objCPB.Price_Book_Entry_Id__c).UnitPrice;
                            }
                            lstCPBEupdate.add(customPBE);
                        }
                    }
              }
              
              if(lstProductUpdate.size() > 0) {
                  update lstProductUpdate;
              }
              
              if(lstCPBEupdate.size() > 0) {
                  update lstCPBEupdate;
              }

          } catch(Exception ex) {
              System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
              Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
          }
    }
    
    global void finish(Database.BatchableContext BC){
    }
}
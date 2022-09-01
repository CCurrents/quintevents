/**
 * @File Name          : HourlyNewProductInsertBatchClass.cls
 * @Description        : insert new product on every hour
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 04/29/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    04/29/2020   mpatel@addonblue.com     Initial Version
*/
global class HourlyNewProductInsertBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    global final string query;
    
    global HourlyNewProductInsertBatchClass(string strquery){
        this.query = strquery;
    }
    /**
    * @description: start method execute on the class load
    * @author     : mpatel@addonblue.com | 04/29/2020
    * @param      : Database.BatchableContext BC
    * @return     : Database.QueryLocator
    **/    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);      
    }
    /**
    * @description: execute method
    * @author     : mpatel@addonblue.com | 04/29/2020
    * @param      : Database.BatchableContext BC
    * @param      : List<PriceBook2> priceBookScope
    * @return     : void
    **/    
    global void execute(Database.BatchableContext BC, List<PriceBook2> priceBookScope){
        if(!priceBookScope.Isempty() && !Test.isrunningTest()){       
            GenerateGPTProduct_LEX.priceBookObjCallOut(priceBookScope[0].Id);
        }
    }
    /**
    * @description: finish method
    * @author     : mpatel@addonblue.com | 04/29/2020
    * @param      : Database.BatchableContext BC
    * @return     : void
    **/    
    global void finish(Database.BatchableContext BC){
    }
}